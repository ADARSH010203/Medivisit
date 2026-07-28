import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef SyncHandler = Future<void> Function(Map<String, dynamic> payload);

class OfflineSyncService extends GetxService {
  late final Box<String> _outbox;
  
  final Map<String, SyncHandler> _handlers = {};
  
  final RxInt pendingCount = 0.obs;
  final RxInt failedCount = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxMap<String, double> uploadProgress = <String, double>{}.obs;
  
  bool _isOnline = false;
  bool get isOnline => _isOnline;
  StreamSubscription<InternetStatus>? _connectivitySub;

  Future<OfflineSyncService> init() async {
    await Hive.initFlutter();
    _outbox = await Hive.openBox<String>('offline_actions');
    _updateCounts();
    _listenToNetworkChanges();
    return this;
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  void registerHandler(String actionType, SyncHandler handler) {
    _handlers[actionType] = handler;
  }

  void updateImageProgress(String id, double progress) {
    uploadProgress[id] = progress.clamp(0.0, 1.0);
    if (progress >= 1.0) {
      uploadProgress.remove(id);
    }
  }

  Future<void> queueAction(String actionType, Map<String, dynamic> payload) async {
    final safePayload = _encodeTimestamps(payload);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final action = {
      'id': id,
      'type': actionType,
      'payload': safePayload,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
      'failed': false,
    };
    
    await _outbox.add(jsonEncode(action));
    _updateCounts();
    
    if (_isOnline) {
      flushOutbox();
    }
  }

  void _listenToNetworkChanges() {
    _connectivitySub = InternetConnection().onStatusChange.listen((InternetStatus status) {
      _isOnline = status == InternetStatus.connected;
      if (_isOnline) {
        flushOutbox();
      }
    });
  }

  void _updateCounts() {
    int pending = 0;
    int failed = 0;
    
    for (var key in _outbox.keys) {
      final actionStr = _outbox.get(key);
      if (actionStr == null) continue;
      try {
        final action = jsonDecode(actionStr) as Map<String, dynamic>;
        if (action['failed'] == true) {
          failed++;
        } else {
          pending++;
        }
      } catch (_) {
        pending++;
      }
    }
    
    pendingCount.value = pending;
    failedCount.value = failed;
  }

  Future<void> retryFailedActions() async {
    final keys = _outbox.keys.toList();
    for (var key in keys) {
      final actionStr = _outbox.get(key);
      if (actionStr == null) continue;
      try {
        final action = jsonDecode(actionStr) as Map<String, dynamic>;
        if (action['failed'] == true) {
          action['failed'] = false;
          action['retry_count'] = 0;
          await _outbox.put(key, jsonEncode(action));
        }
      } catch (_) {}
    }
    _updateCounts();
    await flushOutbox();
  }

  Future<void> retryAction(String id) async {
    final keys = _outbox.keys.toList();
    for (var key in keys) {
      final actionStr = _outbox.get(key);
      if (actionStr == null) continue;
      try {
        final action = jsonDecode(actionStr) as Map<String, dynamic>;
        if (action['id'] == id) {
          action['failed'] = false;
          action['retry_count'] = 0;
          await _outbox.put(key, jsonEncode(action));
          break;
        }
      } catch (_) {}
    }
    _updateCounts();
    await flushOutbox();
  }

  Future<void> retryActionByDocId(String docId) async {
    final keys = _outbox.keys.toList();
    for (var key in keys) {
      final actionStr = _outbox.get(key);
      if (actionStr == null) continue;
      try {
        final action = jsonDecode(actionStr) as Map<String, dynamic>;
        final payload = action['payload'] as Map<String, dynamic>?;
        if (payload != null && payload['_doc_id'] == docId) {
          action['failed'] = false;
          action['retry_count'] = 0;
          await _outbox.put(key, jsonEncode(action));
          break;
        }
      } catch (_) {}
    }
    _updateCounts();
    await flushOutbox();
  }

  bool isActionFailed(String docId) {
    for (var key in _outbox.keys) {
      final actionStr = _outbox.get(key);
      if (actionStr == null) continue;
      try {
        final action = jsonDecode(actionStr) as Map<String, dynamic>;
        final payload = action['payload'] as Map<String, dynamic>?;
        if (payload != null && payload['_doc_id'] == docId) {
          return action['failed'] == true;
        }
      } catch (_) {}
    }
    return false;
  }

  Future<void> flushOutbox() async {
    if (isSyncing.value || _outbox.isEmpty) return;
    
    // Check connectivity
    if (!await InternetConnection().hasInternetAccess) {
      _isOnline = false;
      return;
    }
    _isOnline = true;
    
    isSyncing.value = true;
    
    try {
      final keys = _outbox.keys.toList();
      
      for (var key in keys) {
        final actionStr = _outbox.get(key);
        if (actionStr == null) continue;
        
        Map<String, dynamic> action;
        try {
          action = jsonDecode(actionStr) as Map<String, dynamic>;
        } catch (e) {
          await _outbox.delete(key);
          continue;
        }
        
        // Skip permanently failed items until user manually retries them
        if (action['failed'] == true) continue;

        final type = action['type'] as String;
        final rawPayload = action['payload'] as Map<String, dynamic>;
        final payload = _decodeTimestamps(rawPayload);
        final int retryCount = (action['retry_count'] ?? 0) as int;
        
        final handler = _handlers[type];
        if (handler != null) {
          try {
            await handler(payload);
            await _outbox.delete(key);
            _updateCounts();
          } catch (e) {
            print('Sync handler failed for $type (attempt ${retryCount + 1}): $e');
            
            final nextRetry = retryCount + 1;
            action['retry_count'] = nextRetry;
            
            if (nextRetry >= 5) {
              action['failed'] = true;
              print('Action $type reached max retries (5). Marked as failed.');
            } else {
              // Exponential backoff delay: 1s, 2s, 4s, 8s, max 60s
              final backoffSeconds = min(60, pow(2, nextRetry - 1).toInt());
              await Future.delayed(Duration(seconds: backoffSeconds));
            }
            
            await _outbox.put(key, jsonEncode(action));
            _updateCounts();
            
            // Stop processing queue on failure to preserve order
            break;
          }
        } else {
          print('No handler registered for offline action type: $type');
        }
      }
    } finally {
      isSyncing.value = false;
      _updateCounts();
    }
  }

  Map<String, dynamic> _encodeTimestamps(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = {'__type': 'Timestamp', 'iso': value.toDate().toIso8601String()};
      } else if (value is DateTime) {
        result[key] = {'__type': 'Timestamp', 'iso': value.toIso8601String()};
      } else if (value is Map<String, dynamic>) {
        result[key] = _encodeTimestamps(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, dynamic> _decodeTimestamps(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (value is Map<String, dynamic> && value['__type'] == 'Timestamp') {
        result[key] = Timestamp.fromDate(DateTime.parse(value['iso']));
      } else if (value is Map<String, dynamic>) {
        result[key] = _decodeTimestamps(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}

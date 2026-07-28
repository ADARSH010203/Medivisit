import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseFunctionService {
  // Replace with the actual URL from admin_web config after deployment
  static const String _baseUrl = 'https://wrjxzzdqrbytufdpbeyo.supabase.co/functions/v1';

  static Future<Map<String, dynamic>?> getUploadSignature(String folder) async {
    return _callFunction('get-upload-signature', {'folder': folder});
  }

  static Future<Map<String, dynamic>?> verifyVisit({
    required String doctorId,
    required String visitId,
    required double lat,
    required double lng,
  }) async {
    return _callFunction('verify-visit', {
      'doctor_id': doctorId,
      'visit_id': visitId,
      'latitude': lat,
      'longitude': lng,
    });
  }

  static Future<Map<String, dynamic>?> verifyAttendance({
    required String territoryId,
    required double lat,
    required double lng,
  }) async {
    return _callFunction('verify-attendance', {
      'territory_id': territoryId,
      'latitude': lat,
      'longitude': lng,
    });
  }

  static Future<Map<String, dynamic>?> _callFunction(String functionName, Map<String, dynamic> payload) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final idToken = await user.getIdToken();
      final url = Uri.parse('$_baseUrl/$functionName');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // We pass Firebase token
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Supabase Edge Function $functionName error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception calling $functionName: $e');
      return null;
    }
  }

  static Future<void> sendNotification({
    required String title,
    required String body,
    required String targetType,
    String? targetId,
    String? notificationType,
    String? imageUrl,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final url = Uri.parse('$_baseUrl/send-notification');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idToken': token,
          'title': title,
          'body': body,
          'targetType': targetType,
          'targetId': targetId,
          'notificationType': notificationType,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Notification error: $e');
    }
  }

  static Future<void> notifyAdminSelfReport(String visitId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final url = Uri.parse('$_baseUrl/self-report-notification');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'visitId': visitId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Notification error: $e');
    }
  }
}

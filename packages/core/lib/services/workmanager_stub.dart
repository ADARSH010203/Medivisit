class Workmanager {
  factory Workmanager() => _instance;
  static final Workmanager _instance = Workmanager._internal();
  Workmanager._internal();

  void registerPeriodicTask(String id, String taskName, {Duration? frequency, dynamic constraints}) {}
  void executeTask(Function task) {}
  void initialize(Function callbackDispatcher, {bool isInDebugMode = false}) {}
}

class Constraints {
  Constraints({dynamic networkType});
}

class NetworkType {
  static const connected = 'connected';
}

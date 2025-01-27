import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetService {
  // Singleton instance of the InternetService
  static final InternetService _instance = InternetService._internal();

  factory InternetService() {
    return _instance;
  }

  InternetService._internal();

  // Stream to listen for internet status changes
  final StreamController<bool> _connectionStatusController = StreamController<bool>();

  // Method to start listening to internet connectivity
  void startListening() {
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected) {
        _connectionStatusController.add(true); // Internet connected
      } else {
        _connectionStatusController.add(false); // No internet connection
      }
    });
  }

  // Method to stop listening to internet connectivity
  void stopListening() {
    _connectionStatusController.close();
  }

  // Method to get the current internet connection status as a stream
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
}

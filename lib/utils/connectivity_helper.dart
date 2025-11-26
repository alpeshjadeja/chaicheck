import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  factory ConnectivityHelper() => _instance;
  ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();

  // Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.first != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  // Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.first != ConnectivityResult.none;
    });
  }

  // Get current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.first;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return ConnectivityResult.none;
    }
  }

  // Get connection type as string
  Future<String> getConnectionType() async {
    final result = await checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  // Check if connected to WiFi
  Future<bool> isWifiConnected() async {
    final result = await checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  // Check if connected to mobile data
  Future<bool> isMobileConnected() async {
    final result = await checkConnectivity();
    return result == ConnectivityResult.mobile;
  }
}

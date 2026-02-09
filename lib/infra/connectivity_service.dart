import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a stream of whether the device has network connectivity.
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map(
    (results) => results.any(_isConnected),
  );
});

/// One-shot check of current connectivity status.
Future<bool> checkConnectivity() async {
  final results = await Connectivity().checkConnectivity();
  return results.any(_isConnected);
}

bool _isConnected(ConnectivityResult result) {
  return result != ConnectivityResult.none;
}

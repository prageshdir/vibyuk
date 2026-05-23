import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityHelper {
  ConnectivityHelper(this._connectivity);

  final Connectivity _connectivity;
  final _statusController = BehaviorSubject<bool>();

  Stream<bool> get onConnectivityChanged => _statusController.stream;
  bool get isConnected => _statusController.valueOrNull ?? true;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _statusController.add(_hasConnection(results));

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _statusController.add(_hasConnection(results));
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<bool> check() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

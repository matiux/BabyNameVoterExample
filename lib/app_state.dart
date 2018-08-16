import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class AppStateModel extends Model {
  final Connectivity _connectivity = new Connectivity();
//  StreamSubscription<ConnectivityResult> _connectionSubscription;
  String _connectionStatus = 'Unknown';

  AppStateModel() {
    _initConnectionState();
  }

  void _initConnectionState() async {
    try {
      _connectionStatus =
          _formatStatus((await _connectivity.checkConnectivity()).toString());
      notifyListeners();
      _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        _connectionStatus = _formatStatus(result.toString());
        notifyListeners();
        debugPrint(_formatStatus(_connectionStatus));
      });
    } on PlatformException catch (e) {
      _connectionStatus = 'Failed to get connectivity.';
    }
  }

  String connectionStatus() {
    return _connectionStatus;
  }

  String _formatStatus(String string) {
    String status = string.split('.')[1];

    return "Connection status: " + status;
  }
}

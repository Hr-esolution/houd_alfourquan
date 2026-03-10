import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> hasInternet() async {
    var result = await Connectivity().checkConnectivity();

    return !result.contains(ConnectivityResult.none);
  }
}

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceHandler {
  static final DeviceHandler _singleton = DeviceHandler._internal();
  String deviceId = '';
  String devicename = '';
  String versionCode = '';
  String buildNumber = '';
  String modelName = '';

  factory DeviceHandler() {
    return _singleton;
  }

  DeviceHandler._internal();

  Future<void> getDeviceDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      versionCode = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      modelName = androidInfo.model;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
    } catch (e) {
      print('Error invalid');
    }
  }
}

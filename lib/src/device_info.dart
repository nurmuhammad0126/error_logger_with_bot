part of '../error_bot_service.dart';

class AppDeviceInfo {
  final String device;
  final String os;
  final String appVersion;
  final String timezone;
  final DateTime now;

  AppDeviceInfo({
    required this.now,
    required this.device,
    required this.os,
    required this.appVersion,
    required this.timezone,
  });

  static Future<AppDeviceInfo> getInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    final now = DateTime.now();
    final timeZone = now.timeZoneOffset;
    final tz = timeZone.isNegative
        ? "-${timeZone.inHours.abs().toString().padLeft(2, '0')}"
        : "+${timeZone.inHours.toString().padLeft(2, '0')}";

    String device = "Unknown";
    String os = "Unknown";

    if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;

      device = "${iosInfo.name} ${iosInfo.model}";
      os = "${iosInfo.systemName} ${iosInfo.systemVersion}";
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;

      device = "${androidInfo.manufacturer} ${androidInfo.model}";
      os = "Andriod ${androidInfo.version.release}";
    }

    return AppDeviceInfo(
      now: now,
      device: device,
      os: os,
      appVersion: "${packageInfo.version}+${packageInfo.buildNumber}",
      timezone: tz,
    );
  }
}

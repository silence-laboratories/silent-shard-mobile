// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:async';

import 'package:credential_manager/credential_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

String hexToAscii(String hexString) => List.generate(
      hexString.length ~/ 2,
      (i) => String.fromCharCode(int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16)),
    ).join();

String formatDurationFromNow(DateTime date) {
  final duration = DateTime.now().difference(date);
  return formatDuration(duration);
}

String formatDuration(Duration duration) {
  if (duration.inYears > 0) {
    return "${duration.inYears} ${duration.inYears == 1 ? "year" : "years"}";
  }
  if (duration.inMonths > 0) {
    return "${duration.inMonths} ${duration.inMonths == 1 ? "month" : "months"}";
  }
  if (duration.inWeeks > 0) {
    return "${duration.inWeeks} ${duration.inWeeks == 1 ? "week" : "weeks"}";
  }
  if (duration.inDays > 0) {
    return "${duration.inDays} ${duration.inDays == 1 ? "day" : "days"}";
  }
  if (duration.inHours > 0) {
    return "${duration.inHours} ${duration.inHours == 1 ? "hour" : "hours"}";
  }
  if (duration.inMinutes > 0) {
    return "${duration.inMinutes} ${duration.inMinutes == 1 ? "minute" : "minutes"}";
  }
  return "less than a minute";
}

String fileMessage(DateTime date) => "Last backup to file: ${formatDurationFromNow(date)} ago";

String cloudMessage(DateTime date) => "Last checked: ${formatDurationFromNow(date)} ago";

extension DateUtils on Duration {
  int get inYears => inMicroseconds ~/ (365 * Duration.microsecondsPerDay);
  int get inMonths => inMicroseconds ~/ (30 * Duration.microsecondsPerDay);
  int get inWeeks => inMicroseconds ~/ (7 * Duration.microsecondsPerDay);
}

extension PlatformUtils on Platform {
  static Future<bool> get isPad async {
    if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo info = await deviceInfo.iosInfo;
      return info.model.toLowerCase().contains("ipad");
    }
    return false;
  }
}

String parseCredentialExceptionMessage(Object error) {
  return error is CredentialException ? 'Code: ${error.code}, Message: ${error.message}\n ${error.details}' : error.toString();
}

class Version {
  final String _version;

  Version(this._version);

  String get version => _version;

  List<int> split() {
    final dotSplit = _version.split('.');
    final parsePatchVersion = dotSplit[2].split('-');
    dotSplit[2] = parsePatchVersion[0];
    final versionArray = dotSplit.map((e) => int.parse(e)).toList();
    if (versionArray.length < 4) versionArray.add(0);
    return versionArray;
  }

  int compareTo(Version v) {
    final versionArray = split();
    final secondVersionArray = v.split();
    for (int i = 0; i < 4; i++) {
      if (versionArray[i] < secondVersionArray[i]) return -1;
      if (versionArray[i] > secondVersionArray[i]) return 1;
    }
    return 0;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (length == 0) {
      return this;
    }
    return length > 1 ? "${this[0].toUpperCase()}${substring(1).toLowerCase()}" : this[0].toUpperCase();
  }
}

Future<void> loadImage(ImageProvider provider) {
  final ImageConfiguration config = ImageConfiguration(
    bundle: rootBundle,
    platform: defaultTargetPlatform,
  );
  final Completer<void> completer = Completer<void>();
  final ImageStream stream = provider.resolve(config);

  late final ImageStreamListener listener;

  listener = ImageStreamListener((ImageInfo image, bool sync) {
    debugPrint('Image ${image.debugLabel} finished loading');
    completer.complete();
    stream.removeListener(listener);
  }, onError: (Object exception, StackTrace? stackTrace) {
    completer.complete();
    stream.removeListener(listener);
    FlutterError.reportError(FlutterErrorDetails(
      context: ErrorDescription('image failed to load'),
      library: 'image resource service',
      exception: exception,
      stack: stackTrace,
      silent: true,
    ));
  });

  stream.addListener(listener);
  return completer.future;
}

Future<void> preloadImage() async {
  await loadImage(
    const AssetImage('assets/images/metamaskIcon.png'),
  );
  await loadImage(
    const AssetImage('assets/images/cloud-upload_light.png'),
  );
  await loadImage(
    const AssetImage('assets/images/cloud-upload_light.png'),
  );
  await loadImage(
    const AssetImage('assets/images/folder-open_light.png'),
  );
  await loadImage(
    const AssetImage('assets/images/socialApple.png'),
  );
  await loadImage(
    const AssetImage('assets/images/socialGoogle.png'),
  );
}

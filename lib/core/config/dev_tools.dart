import 'package:flutter/foundation.dart';

/// Device Preview frames the app in a device picker so phone, tablet and
/// desktop layouts can be checked in one browser window. Web only.
///
/// Turn it off for a public web build:
///   flutter build web --dart-define=DEVICE_PREVIEW=false
const bool devicePreviewEnabled = kIsWeb &&
    !kReleaseMode &&
    bool.fromEnvironment('DEVICE_PREVIEW', defaultValue: true);


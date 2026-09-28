import 'package:flutter/foundation.dart';

const bool devicePreviewEnabled = kIsWeb &&
    !kReleaseMode &&
    bool.fromEnvironment('DEVICE_PREVIEW', defaultValue: true);

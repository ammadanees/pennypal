abstract final class CloudinaryConfig {
  static const String cloudName = 'dkdeqminw';
  static const String uploadPreset = 'pennypal';

  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset != 'YOUR_UPLOAD_PRESET';
}

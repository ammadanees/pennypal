/// Fill these in from your Cloudinary dashboard (Settings > Upload > Upload
/// presets). The preset must be "Unsigned". Never put the API secret here
/// or anywhere in the app — unsigned uploads never need it.
abstract final class CloudinaryConfig {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  static bool get isConfigured =>
      cloudName != 'YOUR_CLOUD_NAME' && uploadPreset != 'YOUR_UPLOAD_PRESET';
}

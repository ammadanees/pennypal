/// Fill these in from your Cloudinary dashboard (Settings > Upload > Upload
/// presets). The preset must be "Unsigned". Never put the API secret here
/// or anywhere in the app — unsigned uploads never need it.
abstract final class CloudinaryConfig {
  static const String cloudName = 'dkdeqminw';
  static const String uploadPreset = 'pennypal';

  static bool get isConfigured =>
      cloudName != 'dkdeqminw' && uploadPreset != 'pennypal';
}

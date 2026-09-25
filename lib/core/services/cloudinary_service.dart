import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';
import '../errors/app_failure.dart';

/// Uploads an image to Cloudinary using an unsigned upload preset, so no
/// secret key ever ships in the app. Works on every platform, including
/// web, because it uploads raw bytes rather than a File path.
class CloudinaryService {
  const CloudinaryService();

  Future<String> uploadImage(Uint8List bytes, {required String fileName}) async {
    if (!CloudinaryConfig.isConfigured) {
      throw const AppFailure(
        'Photo uploads are not set up yet for this build.',
      );
    }
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw const AppFailure('The photo could not be uploaded. Please try again.');
    }
    final url = RegExp(r'"secure_url":"([^"]+)"').firstMatch(response.body)?.group(1);
    if (url == null) {
      throw const AppFailure('The photo could not be uploaded. Please try again.');
    }
    return url.replaceAll(r'\/', '/');
  }
}

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => const CloudinaryService(),
);

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String _cloudName = 'duwjixmck';
  static const String _uploadPreset = 'auracare_preset';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  // ── Upload Profile Image ──
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'auracare/profiles', // ← organizes in folder
          publicId: 'profile_$userId', // ← unique name per user
        ),
      );

      return response.secureUrl; // ← returns the image URL
    } catch (e) {
      return null; // return null if upload fails
    }
  }

  //Upload Medical Record
  Future<Map<String, String>?> uploadMedicalRecord(File file) async {
    try {
      print('☁️ Cloud: $_cloudName');
      print('📋 Preset: $_uploadPreset');
      print('📁 File: ${file.path}');

      // Detect if file is PDF
      final isPdf = file.path.toLowerCase().endsWith('.pdf');

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: isPdf
              ? CloudinaryResourceType
                    .Raw // ← PDF uses Raw
              : CloudinaryResourceType.Image, // ← images use Image
          folder: 'auracare/medical_records',
        ),
      );

      print('✅ Upload success: ${response.secureUrl}');

      return {'url': response.secureUrl, 'publicId': response.publicId};
    } on CloudinaryException catch (e) {
      print('❌ Cloudinary error: ${e.message}');
      return null;
    } catch (e) {
      print('❌ General error: $e');
      return null;
    }
  }
}

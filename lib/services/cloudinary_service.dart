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
}
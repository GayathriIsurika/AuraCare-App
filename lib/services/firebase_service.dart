import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {

  // ── Firebase instances ──
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Get current logged in user ──
  User? get currentUser => _auth.currentUser;

  // ════════════════════════════════════════
  // AUTH METHODS
  // ════════════════════════════════════════

  // ── Sign Up with email and password ──
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Creates user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user profile data to Firestore
      await _firestore
          .collection('users')           // users collection
          .doc(result.user!.uid)         // document id = user's unique id
          .set({
        'fullName': fullName,
        'email': email,
        'uid': result.user!.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'profileImageUrl': '',
        'username': '',
        'phone': '',
        'location': '',
        'dateOfBirth': '',
        'gender': '',
      });

      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return e.message; // returns error message
    }
  }

  // ── Login with email and password ──
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ── Log out ──
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ════════════════════════════════════════
  // USER PROFILE METHODS
  // ════════════════════════════════════════

  // ── Get user profile data from Firestore ──
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)  // get current user's document
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Update user profile data ──
  Future<String?> updateUserProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String phone,
    required String location,
    required String dateOfBirth,
    required String gender,
    required String bloodGroup,
  }) async {
    try {
      if (currentUser == null) return 'User not logged in';

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({                        // update only these fields
        'firstName': firstName,
        'lastName': lastName,
        'fullName': '$firstName $lastName',
        'username': username,
        'phone': phone,
        'location': location,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // ── Upload profile image to Firebase Storage ──
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      if (currentUser == null) return null;

      // Create a reference path in Storage
      // path: profile_images/userId.jpg
      Reference ref = _storage
          .ref()
          .child('profile_images')
          .child('${currentUser!.uid}.jpg');

      // Upload the file
      await ref.putFile(imageFile);

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      // Save URL to Firestore
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'profileImageUrl': downloadUrl});

      return downloadUrl; // return URL to display image
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════
  // MEDICAL DETAILS METHODS
  // ════════════════════════════════════════

  // ── Save medical details ──
  Future<String?> saveMedicalDetails({
    required String bloodType,
    required double weight,
    required double height,
    required List<String> allergies,
    required List<String> conditions,
    required List<String> healthEvents,
  }) async {
    try {
      if (currentUser == null) return 'User not logged in';

      // Save to a sub-collection inside user document
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('medical')        // sub-collection
          .doc('details')               // single document
          .set({
        'bloodType': bloodType,
        'weight': weight,
        'height': height,
        'allergies': allergies,
        'conditions': conditions,
        'healthEvents': healthEvents,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Get medical details ──
  Future<Map<String, dynamic>?> getMedicalDetails() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('medical')
          .doc('details')
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:auracare_app/services/cloudinary_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  User? get currentUser => _auth.currentUser;

  // GOOGLE SIGN IN

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign in cancelled';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      if (user == null) return 'Sign in failed';

      if (result.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': user.displayName ?? '',
          'email': user.email ?? '',
          'uid': user.uid,
          'profileImageUrl': user.photoURL ?? '',
          'username': '',
          'phone': '',
          'location': '',
          'dateOfBirth': '',
          'gender': '',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // AUTH METHODS

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
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

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // USER PROFILE METHODS

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
      await _firestore.collection('users').doc(currentUser!.uid).update({
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
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Update only the user's name ──
  Future<String?> updateUserName(String fullName) async {
    try {
      if (currentUser == null) return 'User not logged in';
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'fullName': fullName,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Upload profile image using Cloudinary ──
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      if (currentUser == null) return null;

      // Upload to Cloudinary
      String? imageUrl = await _cloudinaryService.uploadProfileImage(
        imageFile,
        currentUser!.uid, // ← user ID for unique filename
      );

      if (imageUrl != null) {
        // Save URL to Firestore
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'profileImageUrl': imageUrl,
        });

        return imageUrl;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // MEDICAL DETAILS METHODS

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
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('medical')
          .doc('details')
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

  //MEDICAL RECORDS

  Future<String?> saveMedicalRecord({
    required File file,
    required String title,
    required String category,
  }) async {
    try {
      if (currentUser == null) return 'User not logged in';

      final uploaded = await _cloudinaryService.uploadMedicalRecord(file);
      if (uploaded == null) return 'File upload failed';

      await _firestore.collection('medical_records').add({
        'uid': currentUser!.uid,
        'title': title,
        'category': category,
        'cloudinaryUrl': uploaded['url'],
        'publicId': uploaded['publicId'],
        'date': _formatDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getMedicalRecordsStream() {
    if (currentUser == null) return null;
    return _firestore
        .collection('medical_records')
        .where('uid', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String?> deleteMedicalRecord(String docId) async {
    try {
      await _firestore.collection('medical_records').doc(docId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  //private helper

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Auto-detects category from filename using keyword matching.
  /// Returns one of: 'lab', 'imaging', 'vaccine', 'consultation'
  String detectCategory(String filename) {
    final name = filename
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // ── Imaging keywords ──────────────────────────────
    const imagingKeywords = [
      'xray',
      'x ray',
      'mri',
      'ct scan',
      'ct',
      'scan',
      'ultrasound',
      'echo',
      'imaging',
      'radiology',
      'mammogram',
      'pet',
      'angiogram',
      'bone',
      'chest',
      'abdomen',
      'spine',
      'brain',
      'pelvis',
      'knee',
      'shoulder',
      'wrist',
      'ankle',
      'hip',
      'neck',
      'cardiac',
      'thyroid scan',
      'nuclear',
    ];

    // ── Vaccine keywords ──────────────────────────────
    const vaccineKeywords = [
      'vaccine',
      'vaccination',
      'immunization',
      'immunisation',
      'booster',
      'flu',
      'covid',
      'hepatitis',
      'mmr',
      'polio',
      'tetanus',
      'rabies',
      'typhoid',
      'yellow fever',
      'meningitis',
      'pneumonia',
      'hpv',
      'varicella',
      'dose',
      'jab',
      'shot',
      'inoculation',
    ];

    // ── Consultation keywords ─────────────────────────
    const consultationKeywords = [
      'prescription',
      'doctor',
      'consult',
      'consultation',
      'referral',
      'discharge',
      'summary',
      'note',
      'visit',
      'clinic',
      'hospital',
      'appointment',
      'diagnosis',
      'treatment',
      'medicine',
      'follow',
      'review',
      'op',
      'outpatient',
      'inpatient',
      'gp',
      'specialist',
      'letter',
      'certificate',
      'sick',
      'medical certificate',
      'dr ',
      'doc',
      'opd',
      'ipd',
    ];

    // ── Lab keywords ──────────────────────────────────
    const labKeywords = [
      'blood',
      'urine',
      'cbc',
      'test',
      'lab',
      'report',
      'hba1c',
      'glucose',
      'lipid',
      'cholesterol',
      'panel',
      'culture',
      'biopsy',
      'pathology',
      'hemoglobin',
      'platelet',
      'thyroid',
      'tsh',
      'creatinine',
      'kidney',
      'liver',
      'wbc',
      'rbc',
      'esr',
      'crp',
      'uric',
      'protein',
      'calcium',
      'sodium',
      'potassium',
      'stool',
      'sputum',
      'swab',
      'pcr',
      'antigen',
      'antibody',
      'serology',
      'hormone',
      'vitamin',
      'iron',
      'ferritin',
      'hiv',
      'dengue',
      'malaria',
      'typhoid test',
      'widal',
      'lft',
      'rft',
      'kft',
    ];

    // ── Check in priority order ───────────────────────
    // Check imaging first (most specific)
    for (final keyword in imagingKeywords) {
      if (name.contains(keyword)) return 'imaging';
    }
    for (final keyword in vaccineKeywords) {
      if (name.contains(keyword)) return 'vaccine';
    }
    for (final keyword in consultationKeywords) {
      if (name.contains(keyword)) return 'consultation';
    }
    for (final keyword in labKeywords) {
      if (name.contains(keyword)) return 'lab';
    }

    return 'lab'; // default
  }

  // ── REMINDER METHODS ──

  Future<String?> saveReminder({
    required String name,
    required String dose,
    required String instructions,
    String type =
        'medicine', // 'medicine' | 'appointment' | 'hydration' | 'custom'
    List<String> times = const [],
    DateTime? startDate,
    DateTime? endDate,
    String repeat = 'daily', // 'daily' | 'once' | 'mon,wed,fri'
    String doctorName = '',
    String location = '',
    bool isHydration = false,
    String? reminderId,
  }) async {
    try {
      if (currentUser == null) return 'User not logged in';

      final docId =
          reminderId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final data = <String, dynamic>{
        'id': docId,
        'type': type,
        'name': name,
        'dose': dose,
        'instructions': instructions,
        'times': times,
        'startDate': _dateKey(startDate),
        'endDate': _dateKey(endDate),
        'repeat': repeat,
        'doctorName': doctorName,
        'location': location,
        'isHydration': isHydration,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Only set createdAt + empty doseLog when creating a NEW reminder,
      // so editing doesn't wipe the completion history.
      if (reminderId == null) {
        data['createdAt'] = DateTime.now().toIso8601String();
        data['doseLog'] = <String, bool>{};
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('reminders')
          .doc(docId)
          .set(data, SetOptions(merge: true)); // merge keeps doseLog on edit

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      if (currentUser == null) return [];

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('reminders')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Mark a single dose (one time on one date) taken / not taken.
  /// Writes into the doseLog map: { '2026-06-20_08:00': true }
  Future<String?> setDoseTaken({
    required String reminderId,
    required DateTime day,
    required String time,
    required bool taken,
  }) async {
    try {
      if (currentUser == null) return 'User not logged in';

      final key = '${_dateKey(day)}_$time';

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('reminders')
          .doc(reminderId)
          .update({'doseLog.$key': taken});

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteReminder(String reminderId) async {
    try {
      if (currentUser == null) return 'User not logged in';

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('reminders')
          .doc(reminderId)
          .delete();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 'yyyy-MM-dd' (no time). Mirrors ReminderModel.dateKeyOf.
  String _dateKey(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}

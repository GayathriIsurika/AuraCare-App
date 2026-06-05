import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Map icon codePoint ↔ FaIconData for Firestore storage
const List<FaIconData> _allIcons = [
  FontAwesomeIcons.ambulance,
  FontAwesomeIcons.userDoctor,
  FontAwesomeIcons.userNurse,
  FontAwesomeIcons.house,
  FontAwesomeIcons.person,
  FontAwesomeIcons.heartPulse,
  FontAwesomeIcons.hospital,
  FontAwesomeIcons.pills,
  FontAwesomeIcons.phone,
  FontAwesomeIcons.star,
];

class ContactModel {
  final String id;
  String name;
  String phoneNumber;
  FaIconData icon;

  ContactModel({
    String? id,
    required this.name,
    required this.phoneNumber,
    required this.icon,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // ── Convert to Firestore map ──
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'iconCodePoint': icon.codePoint,
    };
  }

  // ── Build from Firestore document ──
  factory ContactModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final codePoint = data['iconCodePoint'] as int? ?? 0;

    // Find matching icon, fallback to phone icon
    final icon = _allIcons.firstWhere(
      (i) => i.codePoint == codePoint,
      orElse: () => FontAwesomeIcons.phone,
    );

    return ContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      icon: icon,
    );
  }
}

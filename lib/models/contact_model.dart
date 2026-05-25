import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
}

import 'package:auracare_app/models/contact_model.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onCall;

  const ContactCard({super.key, required this.contact, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // ── Left Icon ──
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(contact.icon, color: Colors.blue),
        ),

        // ── Name & Number ──
        title: Text(
          contact.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact.phoneNumber),

        // ── Call Button ──
        trailing: GestureDetector(
          onTap: onCall,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.phone, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

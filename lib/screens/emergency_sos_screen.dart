import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/contact_model.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:auracare_app/widgets/contact_card.dart';
import 'package:auracare_app/widgets/contact_sheet.dart';
import 'package:auracare_app/widgets/sos_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  // ── Hardcoded contacts list ──
  final List<ContactModel> _contacts = [
    ContactModel(
      name: 'Emergency Services',
      phoneNumber: '1990',
      icon: FontAwesomeIcons.ambulance,
    ),
    ContactModel(
      name: 'Dr. Kusal Perera',
      phoneNumber: '071 234 5678',
      icon: FontAwesomeIcons.userDoctor,
    ),
    ContactModel(
      name: 'Home',
      phoneNumber: '036 234 5687',
      icon: FontAwesomeIcons.house,
    ),
  ];

  // ── Delete a contact ──
  void _deleteContact(String id) {
    final Index = _contacts.indexWhere((c) => c.id == id);
    if (Index != -1) {
      setState(() {
        _contacts.removeAt(Index);
      });
    }
  }

  void _openContactSheet({ContactModel? existing}) {
    ContactSheet.show(
      context,
      existing: existing,
      onSave: (name, phone, icon) {
        // ← added icon
        setState(() {
          if (existing == null) {
            _contacts.add(
              ContactModel(
                name: name,
                phoneNumber: phone,
                icon: icon, // ← use selected icon
              ),
            );
          } else {
            existing.name = name;
            existing.phoneNumber = phone;
            existing.icon = icon; // ← update icon on edit
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Blue header background ──
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5DADE2), Color(0xFF72C6D5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      "Emergency SOS",
                      style: TextStyle(
                        color: textLight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFE5FAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),

                        // ── SOS Button ──
                        SosButton(onPressed: () {}),
                        SizedBox(height: 40),

                        // ── Header row: title + Add button ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Emergency Contacts",
                              style: TextStyle(
                                color: textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // ── Add Contact button ──
                            GestureDetector(
                              onTap: () => _openContactSheet(),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ── Swipe hint ──
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.swipe, size: 13, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Swipe right to edit  ·  Swipe left to delete',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),

                        // ── Contact list ──
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _contacts.length,
                          itemBuilder: (_, i) {
                            final c = _contacts[i];
                            return ContactCard(
                              contact: c,
                              onCall: () {},
                              onEdit: () => _openContactSheet(existing: c),
                              onDelete: () => _deleteContact(c.id),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: null),
    );
  }
}

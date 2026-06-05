import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/contact_model.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:auracare_app/widgets/contact_card.dart';
import 'package:auracare_app/widgets/contact_sheet.dart';
import 'package:auracare_app/widgets/sos_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  // ── Firestore collection ref ──
  CollectionReference get _contactsRef {
    final user = FirebaseAuth.instance.currentUser;
    print('🔥 Current user: $user');
    final uid = user!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('emergency_contacts');
  }

  // ── Fixed emergency contact doc ref ──
  DocumentReference get _emergencyDocRef => _contactsRef.doc('emergency_fixed');

  @override
  void initState() {
    super.initState();
    _seedEmergencyContact();
  }

  // ── Create fixed contact if it doesn't exist yet ──
  Future<void> _seedEmergencyContact() async {
    final doc = await _emergencyDocRef.get();
    if (!doc.exists) {
      await _emergencyDocRef.set({
        'name': 'Emergency',
        'phoneNumber': '1990',
        'iconCodePoint': FontAwesomeIcons.ambulance.codePoint,
        'isFixed': true,
      });
    }
  }

  // ── Add or Edit contact ──
  Future<void> _saveContact(
    String name,
    String phone,
    FaIconData icon, {
    ContactModel? existing,
  }) async {
    final isFixed = existing?.id == 'emergency_fixed';

    final data = {
      'name': isFixed ? 'Emergency' : name,
      'phoneNumber': phone,
      'iconCodePoint': icon.codePoint,
      if (isFixed) 'isFixed': true,
    };

    if (existing == null) {
      await _contactsRef.add(data);
    } else {
      await _contactsRef.doc(existing.id).update(data);
    }
  }

  // ── Delete contact ──
  Future<void> _deleteContact(String id) async {
    await _contactsRef.doc(id).delete();
  }

  // ── Open add/edit sheet ──
  void _openContactSheet({ContactModel? existing}) {
    final isFixed = existing?.id == 'emergency_fixed';

    ContactSheet.show(
      context,
      existing: existing,
      lockName: isFixed,
      onSave: (name, phone, icon) =>
          _saveContact(name, phone, icon, existing: existing),
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
            decoration: const BoxDecoration(
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
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5FAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        SosButton(onPressed: () {}),
                        const SizedBox(height: 40),

                        // ── Header row ──
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
                            GestureDetector(
                              onTap: () => _openContactSheet(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
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
                        const SizedBox(height: 10),
                        const Row(
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
                        const SizedBox(height: 5),

                        // ── Firestore real-time list ──
                        StreamBuilder<QuerySnapshot>(
                          stream: _contactsRef.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'Something went wrong.\nPlease try again.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red[300]),
                                ),
                              );
                            }

                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text(
                                  'No emergency contacts yet.\nTap Add to get started.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            // ── Sort: fixed contact always first ──
                            final contacts =
                                docs
                                    .map((doc) => ContactModel.fromDoc(doc))
                                    .toList()
                                  ..sort((a, b) {
                                    if (a.id == 'emergency_fixed') return -1;
                                    if (b.id == 'emergency_fixed') return 1;
                                    return 0;
                                  });

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: contacts.length,
                              itemBuilder: (_, i) {
                                final c = contacts[i];
                                return ContactCard(
                                  contact: c,
                                  isFixed: c.id == 'emergency_fixed',
                                  onCall: () {},
                                  onEdit: () => _openContactSheet(existing: c),
                                  onDelete: () => _deleteContact(c.id),
                                );
                              },
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

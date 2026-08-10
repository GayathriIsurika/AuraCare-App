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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  bool _showTip = false;

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
    _checkTipStatus();
  }

  // ── Check if user has already seen or dismissed the tip ──
  Future<void> _checkTipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTip = prefs.getBool('has_seen_sos_tip') ?? false;
    if (!hasSeenTip && mounted) {
      setState(() {
        _showTip = true;
      });
    }
  }

  // ── Save tip preference on dismiss ──
  Future<void> _dismissTip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_sos_tip', true);
    if (mounted) {
      setState(() {
        _showTip = false;
      });
    }
  }

  // ── Create fixed contact if it doesn't exist yet ──
  Future<void> _seedEmergencyContact() async {
    final doc = await _emergencyDocRef.get();
    if (!doc.exists) {
      await _emergencyDocRef.set({
        'name': 'Emergency',
        'phoneNumber': '1990',
        'iconCodePoint': FontAwesomeIcons.truckMedical.codePoint,
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

  // ── Make phone call / open dialer ──
  Future<void> _makeCall(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number provided.')),
        );
      }
      return;
    }

    final cleaned = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleaned.isNotEmpty ? cleaned : trimmed,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open phone dialer for $phoneNumber'),
          ),
        );
      }
    }
  }

  // ── Handle SOS button press ──
  Future<void> _handleSosPressed() async {
    try {
      final doc = await _emergencyDocRef.get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final phone = data['phoneNumber'] as String?;
        if (phone != null && phone.trim().isNotEmpty) {
          await _makeCall(phone);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error getting emergency doc: $e');
    }
    // Fallback to 1990
    await _makeCall('1990');
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

  // ── First-Time Tip Card Widget ──
  Widget _buildTipCard() {
    if (!_showTip) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFAED6F1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF2980B9),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '💡 Quick Tip & Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1B4F72),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Swipe right on any contact to edit details, or swipe left to delete.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2874A6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _dismissTip,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                size: 18,
                color: Color(0xFF5D6D7E),
              ),
            ),
          ),
        ],
      ),
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

                        SosButton(onPressed: _handleSosPressed),
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

                        // ── First-Time Tip / Instructions Card ──
                        _buildTipCard(),
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
                                  onCall: () => _makeCall(c.phoneNumber),
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

import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/screens/edit_profile_screen.dart';
import 'package:auracare_app/screens/medical_details_screen.dart';
import 'package:auracare_app/services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // Stores user data loaded from Firebase
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user profile from Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final data = await _firebaseService.getUserProfile();

    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  // Get initials from full name for avatar
  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return '?';
    List<String> parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF4FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // Show loading spinner while data loads
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: buttonStart))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Card ──
                  // Shows real data from Firebase
                  GestureDetector(
                    onTap: () async {
                      // Wait for edit screen to finish
                      // then reload data to show updated info
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      _loadUserData();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [buttonStart, buttonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // ── Profile Photo ──
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            // Show network image if available
                            backgroundImage:
                                (_userData?['profileImageUrl'] != null &&
                                    _userData!['profileImageUrl']
                                        .toString()
                                        .isNotEmpty)
                                ? NetworkImage(_userData!['profileImageUrl'])
                                : null,
                            child:
                                (_userData?['profileImageUrl'] == null ||
                                    _userData!['profileImageUrl']
                                        .toString()
                                        .isEmpty)
                                ? Text(
                                    // Show initials from real name
                                    _getInitials(_userData?['fullName']),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),

                          const SizedBox(width: 16),

                          // ── Name, Email, Username from Firebase ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // Show real name or placeholder
                                  _userData?['fullName'] ?? 'Your Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userData?['email'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _userData?['username'] != null &&
                                          _userData!['username']
                                              .toString()
                                              .isNotEmpty
                                      ? '@${_userData!['username']}'
                                      : '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //  arrow icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Personal Details Section
                  const Text(
                    'Personal Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Show real data or placeholder text
                        if (_userData?['location'] != null &&
                            _userData!['location'].toString().isNotEmpty)
                          _buildDetailRow(
                            Icons.location_on_outlined,
                            _userData!['location'],
                          ),

                        if (_userData?['dateOfBirth'] != null &&
                            _userData!['dateOfBirth'].toString().isNotEmpty)
                          _buildDetailRow(
                            Icons.cake_outlined,
                            _userData!['dateOfBirth'],
                          ),

                        if (_userData?['gender'] != null &&
                            _userData!['gender'].toString().isNotEmpty)
                          _buildDetailRow(
                            Icons.person_outline,
                            _userData!['gender'],
                          ),

                        // Show placeholder if no data yet
                        if ((_userData?['location'] == null ||
                                _userData!['location'].toString().isEmpty) &&
                            (_userData?['dateOfBirth'] == null ||
                                _userData!['dateOfBirth'].toString().isEmpty) &&
                            (_userData?['gender'] == null ||
                                _userData!['gender'].toString().isEmpty))
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No personal details yet. Tap Edit to add.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        //  Edit Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                              _loadUserData();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: buttonStart),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: buttonStart),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //  Medical Details Button
                  _buildActionButton(
                    icon: Icons.medical_information_outlined,
                    label: 'Medical Details',
                    buttonColor: buttonStart,
                    textColor: Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicalDetailsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Emergency Contacts Button ──
                  _buildActionButton(
                    icon: Icons.phone_outlined,
                    label: 'Manage Emergency Contacts',
                    buttonColor: Colors.red.shade50,
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    borderColor: Colors.red.shade200,
                    onTap: () {
                      Navigator.pushNamed(context, '/emergency');
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Reminder Setting Button ──
                  _buildActionButton(
                    icon: Icons.notifications_outlined,
                    label: 'Reminder Setting',
                    buttonColor: buttonStart,
                    textColor: Colors.black,
                    onTap: () {
                      Navigator.pushNamed(context, '/reminder');
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Log Out Button ──
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await _firebaseService.logout(); // ← Firebase logout
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 25,
                      ),
                      label: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5BB8D4)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color textColor = Colors.black,
    Color iconColor = Colors.black54,
    Color borderColor = const Color(0xFFDDDDDD),
    Color buttonColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

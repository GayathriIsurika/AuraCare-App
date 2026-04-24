import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'medical_details_screen.dart';
import 'package:auracare_app/screens/emergency_sos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ── AppBar with back and settings icons ──
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF4FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // goes back to dashboard
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Profile Card (blue card with photo, name, email) ──
            GestureDetector(
              onTap: () {
                // Tapping profile card opens Edit Profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [buttonStart,buttonEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Profile photo circle
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: const Text(
                        'SD', // initials - replace with Image.asset for real photo
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name, email, username
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smith Disanayaka',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'smithdisanayaka125@gmail.com',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '@smith125',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Personal Details Section ──
            const Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Personal details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Each detail row: icon + label
                  _buildDetailRow(Icons.location_on_outlined, 'Tissamaharama'),
                  _buildDetailRow(Icons.cake_outlined, '04/02/2002'),
                  _buildDetailRow(Icons.person_outline, 'Male'),

                  const SizedBox(height: 8),

                  // Edit button
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
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

            // ── Action Buttons List ──
            // Medical Details button
            _buildActionButton(
              icon:  Icons.medical_information_outlined,
              label: 'Medical Details',
              buttonColor: buttonStart,
              textColor: Colors.black,
              onTap: () { Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalDetailsScreen(),
                ),
              );
              },
            ),

            const SizedBox(height: 32),


            // Manage Emergency Contacts (red color)
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

            const SizedBox(height: 32),

            // Reminder Setting button
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
                onPressed: () {
                  // Log out → go back to welcome screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false, // removes all previous screens
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red,size: 25,),
                label: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  // ── Helper: builds each personal detail row ──
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

  // ── Helper: builds each action button ──
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
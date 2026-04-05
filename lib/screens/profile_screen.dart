import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:auracare_app/constant/app_colors.dart';

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
                          'pramodlakshan125@gmail.com',
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
                  _buildDetailRow(Icons.water_drop_outlined, 'O+'),

                  const SizedBox(height: 8),

                  // Edit button + See more
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // "See more details" - expand or navigate
                        },
                        child: const Text(
                          'See more details',
                          style: TextStyle(
                            color: buttonStart,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // Edit button opens Edit Profile
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5BB8D4)),
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
                          style: TextStyle(color: Color(0xFF5BB8D4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons List ──
            // Medical ID button
            _buildActionButton(
              icon: Icons.badge_outlined,
              label: 'Medical ID',
              textColor: Colors.black,
              onTap: () {
                // TODO: Navigate to Medical ID screen
              },
            ),

            const SizedBox(height: 12),

            // Share Medical ID button
            _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share Medical ID',
              textColor: Colors.black,
              onTap: () {
                // TODO: Navigate to Share Medical ID screen
              },
            ),

            const SizedBox(height: 12),

            // Manage Emergency Contacts (red color)
            _buildActionButton(
              icon: Icons.phone_outlined,
              label: 'Manage Emergency Contacts',
              textColor: Colors.red,
              iconColor: Colors.red,
              borderColor: Colors.red.shade200,
              onTap: () {
                // TODO: Navigate to Emergency Contacts screen
              },
            ),

            const SizedBox(height: 12),

            // Reminder Setting button
            _buildActionButton(
              icon: Icons.notifications_outlined,
              label: 'Reminder Setting',
              textColor: Colors.black,
              onTap: () {
                // TODO: Navigate to Reminder Settings screen
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
                    '/home',
                        (route) => false, // removes all previous screens
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.black54),
                label: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
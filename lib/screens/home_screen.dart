import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:auracare_app/services/firebase_service.dart';
import 'package:auracare_app/constant/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // ── Stores user data ──
  String _userName = 'User';
  String _userInitials = 'U';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ── Load user name from Firebase ──
  Future<void> _loadUserData() async {
    final data = await _firebaseService.getUserProfile();

    if (data != null && mounted) {
      setState(() {
        // Get first name only for greeting
        // Example: "Smith Disanayaka" → "Smith"
        final fullName = data['fullName'] ?? 'User';
        final nameParts = fullName.trim().split(' ');
        _userName = nameParts.isNotEmpty ? nameParts[0] : 'User';

        // Get initials for avatar
        // Example: "Smith Disanayaka" → "SD"
        if (nameParts.length >= 2) {
          _userInitials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
        } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
          _userInitials = nameParts[0][0].toUpperCase();
        }

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildMedicationCard(),
                    const SizedBox(height: 24),
                    _buildActionGrid(context),
                    const SizedBox(height: 24),
                    _buildSOSButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER — now shows real user name ──
  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // ← reload data when coming back from profile
        await Navigator.pushNamed(context, '/profile');
        _loadUserData(); // ← refresh name after returning
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5BB8D4), Color(0xFF3A9EC2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Shows real user name ──
                Text(
                  _isLoading
                      ? 'Hello!' // while loading
                      : 'Hello, $_userName!', // real name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'How can we help you today?',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),

            // ── Avatar shows initials or loading ──
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _userInitials, // ← real initials
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MEDICATION CARD ──
  Widget _buildMedicationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Color(0xFF5BB8D4),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming: Metformin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                'Take 500mg at 2:00 PM today',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ACTION GRID ──
  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.upload_file_rounded,
        label: 'Upload Report',
        color: const Color(0xFF5BB8D4),
      ),
      _ActionItem(
        icon: Icons.local_hospital_rounded,
        label: 'Nearby Hospital',
        color: const Color(0xFFE8B84B),
      ),
      _ActionItem(
        icon: Icons.notifications_rounded,
        label: 'Reminder',
        color: const Color(0xFF4CAF82),
      ),
      _ActionItem(
        icon: Icons.smart_toy_rounded,
        label: 'Ask Aura',
        color: const Color(0xFF5BB8D4),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: actions.map((item) => _buildActionCard(item, context)).toList(),
    );
  }

  Widget _buildActionCard(_ActionItem item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.label == 'Reminder') {
          Navigator.pushNamed(context, '/reminder');
        } else if (item.label == 'Upload Report') {
          Navigator.pushNamed(context, '/upload');
        } else if (item.label == 'Nearby Hospital') {
          Navigator.pushNamed(context, '/hospital');
        } else if (item.label == 'Ask Aura') {
          // TODO: add AI chat screen
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SOS BUTTON ──
  Widget _buildSOSButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/emergency');
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5BB8D4), Color(0xFF3A9EC2)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5BB8D4).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Emergency SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ──
class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;

  _ActionItem({required this.icon, required this.label, required this.color});
}

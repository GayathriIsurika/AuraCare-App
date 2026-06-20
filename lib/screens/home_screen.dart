import 'package:auracare_app/widgets/home_upcoming_reminder_card.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:auracare_app/services/firebase_service.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/reminder_model.dart';

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
  String _profileImageUrl = '';
  bool _isLoading = true;

  // ── Stores upcoming reminders (carousel) ──
  List<ReminderModel> _upcomingReminders = [];
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUpcomingReminders();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Load user name from Firebase ──
  Future<void> _loadUserData() async {
    final data = await _firebaseService.getUserProfile();

    if (data != null && mounted) {
      setState(() {
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
        _profileImageUrl = data['profileImageUrl'] ?? '';

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // ── Load upcoming reminders from Firebase ──
  Future<void> _loadUpcomingReminders() async {
    if (_firebaseService.currentUser == null) return;

    final reminders = await _firebaseService.getReminders();
    if (!mounted) return;

    final today = DateTime.now();

    // Earliest dose today that isn't taken yet ('99:99' = nothing left).
    String nextOpen(ReminderModel r) {
      final open = r.times.where((t) => !r.isDoseTaken(today, t)).toList()
        ..sort();
      return open.isEmpty ? '99:99' : open.first;
    }

    final list =
        reminders
            .map((m) => ReminderModel.fromMap(m))
            .where((r) => !r.isHydration && r.type != 'hydration')
            .where((r) => r.isActiveOn(today)) // active today
            .where((r) => nextOpen(r) != '99:99') // still has a dose due
            .toList()
          ..sort((a, b) => nextOpen(a).compareTo(nextOpen(b)));

    setState(() {
      _upcomingReminders = list;
      if (_currentPage >= list.length) _currentPage = 0;
    });
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

                    // ── Upcoming Reminder Card ──
                    HomeUpcomingCard(
                      reminder: _upcomingReminders.isEmpty
                          ? null
                          : _upcomingReminders[0],
                      onTap: () {
                        Navigator.pushNamed(context, '/reminder').then((_) {
                          // Reload when coming back from reminder screen
                          _loadUpcomingReminders();
                        });
                      },
                    ),

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
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              // ← Shows profile image if available, else initials
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? NetworkImage(_profileImageUrl)
                  : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : _profileImageUrl.isEmpty
                  ? Text(
                      _userInitials, // ← shows initials if no image
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ],
        ),
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
          Navigator.pushNamed(context, '/reminder').then((_) {
            _loadUpcomingReminders(); // Reload when back
          });
        } else if (item.label == 'Upload Report') {
          Navigator.pushNamed(context, '/upload');
        } else if (item.label == 'Nearby Hospital') {
          Navigator.pushNamed(context, '/hospital');
        } else if (item.label == 'Ask Aura') {
          Navigator.pushNamed(context, '/chatbot');
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

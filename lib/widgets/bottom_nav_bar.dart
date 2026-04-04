import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int? currentIndex; // ← ? means nullable

  const BottomNavBar({super.key, this.currentIndex}); // ← no required

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex ?? 0, // ← if null use 0
      type: BottomNavigationBarType.fixed,
      selectedItemColor: currentIndex == null
          ? Colors
                .grey // ← if null no blue color
          : Color(0xFF7CCBE8),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/vault');
            break;
          case 2:
            Navigator.pushNamed(context, '/reminder');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.briefcaseMedical),
          label: "M vault",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.bell),
          label: "Reminder",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.solidHeart),
          label: "Profile",
        ),
      ],
    );
  }
}

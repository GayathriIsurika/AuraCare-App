import 'package:auracare_app/screens/emergency_sos_screen.dart';
import 'package:auracare_app/screens/reminder_screen.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/upload_report.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90D9)),
        useMaterial3: true,
      ),

      //  Set OnboardingScreen as the first screen
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const Scaffold(),
        '/emergency': (context) =>  EmergencySosScreen(),
        '/reminder': (context) => const ReminderScreen(),
        '/upload': (context) => const UploadReportScreen(),
        '/nearby': (context) =>
            const PlaceholderScreen(title: 'Nearby Hospital'),
        '/ask_aura': (context) => const PlaceholderScreen(title: 'Ask Aura'),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// ── Placeholder Home Screen ──
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: null),
    );
  }
}

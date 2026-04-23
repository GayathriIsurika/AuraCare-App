import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  //   3 onboarding pages data
  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Your Health, Organized for Life',
      description:
          'Store all your medical reports, prescriptions, and test results in one secure place accessible anytime',
      imagePath: 'assets/images/onboard1.png',
    ),
    OnboardingData(
      title: 'Your Smart Health Companion',
      description:
          'Get AI-powered guidance, simple report summaries, and instant answers to everyday health questions',
      imagePath: 'assets/images/onboard2.png',
    ),
    OnboardingData(
      title: 'Never Miss Medicines or Appointments',
      description:
          'Set automatic reminders for medications, doctor visits, and important health tasks stay on track effortlessly',
      imagePath: 'assets/images/onboard3.png',
    ),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to your Home/Login screen on last page
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _onSkipPressed() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background  design
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF0FF), Color(0xFFF0FAFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _onSkipPressed,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF4A90D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PageView ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: _pages[index]);
                  },
                ),
              ),

              // ── Dot Indicators ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF4A90D9)
                          : const Color(0xFFBBCFEA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Next Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

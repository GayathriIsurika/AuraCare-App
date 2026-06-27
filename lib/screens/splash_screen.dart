import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/pin_service.dart'; // ← ADD

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoFadeController;
  late AnimationController _flashController;
  late AnimationController _backgroundController;
  late AnimationController _taglineController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _flashOpacity;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _taglineFade;
  late Animation<double> _taglineSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoFadeController, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoFadeController, curve: Curves.easeOutBack),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 50,
      ),
    ]).animate(_flashController);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoFadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _flashController.forward();
    await _backgroundController.forward();
    await _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _navigateToNextScreen();
  }

  // ── Navigate based on login + PIN status ──
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final pinService = PinService();

    if (user != null) {
      // ← User is logged in
      final pinSet = await pinService.isPinSet();

      if (pinSet) {
        // ← PIN exists → show PIN entry
        Navigator.pushReplacementNamed(context, '/pin-entry');
      } else {
        // ← No PIN yet → set PIN
        Navigator.pushReplacementNamed(context, '/set-pin');
      }
    } else {
      // ← Not logged in → onboarding
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _logoFadeController.dispose();
    _flashController.dispose();
    _backgroundController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoFadeController,
          _flashController,
          _backgroundController,
          _taglineController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Layer 1: Light blue background
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFDEEFF5),
              ),

              // Layer 2: Dark blue background fades in
              Opacity(
                opacity: _backgroundOpacity.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: buttonStart,
                ),
              ),

              // Layer 3: White flash
              Opacity(
                opacity: _flashOpacity.value,
                child: Center(
                  child: Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Layer 4: Logo + name + tagline
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Image.asset(
                          'assets/images/auracare_logo.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: _logoFade.value,
                      child: Text(
                        'AuraCare',
                        style: TextStyle(
                          color: Color.lerp(
                            const Color(0xFF1A3A5C),
                            Colors.white,
                            _backgroundOpacity.value,
                          ),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: Offset(0, _taglineSlide.value),
                      child: Opacity(
                        opacity: _taglineFade.value,
                        child: const Text(
                          'Your Health, Smarter',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
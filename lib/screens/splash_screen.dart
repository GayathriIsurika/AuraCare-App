import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──


  late AnimationController _logoFadeController;

  late AnimationController _flashController;

  late AnimationController _backgroundController;

  late AnimationController _taglineController;


  // ── Animations ──
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

  // Setup all animation controllers and animations
  void _setupAnimations() {

    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoFadeController,
        curve: Curves.easeIn,
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoFadeController,
        curve: Curves.easeOutBack,
      ),
    );



    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0), // fade in
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0), // fade out
        weight: 50,
      ),
    ]).animate(_flashController);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );


    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeIn,
      ),
    );

    _taglineSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeOut,
      ),
    );
  }


  Future<void> _startAnimationSequence() async {


    await Future.delayed(const Duration(milliseconds: 20));


    await _logoFadeController.forward();

    // Wait a little
    await Future.delayed(const Duration(milliseconds: 30));

    await _flashController.forward();
    await _backgroundController.forward();


    await _taglineController.forward();


    await Future.delayed(const Duration(milliseconds: 800));


    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Check if user is already logged in
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      Navigator.pushReplacementNamed(context, '/welcome');
    } else {

      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _logoFadeController.dispose();
    _flashController.dispose();
    _backgroundController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // ← screen size

    return Scaffold(
      body: AnimatedBuilder(
        // ← Rebuilds when any controller changes
        animation: Listenable.merge([
          _logoFadeController,
          _flashController,
          _backgroundController,
          _taglineController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [


              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFDEEFF5),
              ),


              Opacity(
                opacity: _backgroundOpacity.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: buttonStart,
                ),
              ),


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


              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Logo with fade + scale animation
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Image.asset(
                          'assets/images/auracare_logo.png',
                          width: 300,
                          height: 300,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // App name
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
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Tagline slides up and fades in ──
                    Transform.translate(
                      offset: Offset(0, _taglineSlide.value),
                      child: Opacity(
                        opacity: _taglineFade.value,
                        child: const Text(
                          'Your Health, Smarter',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
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
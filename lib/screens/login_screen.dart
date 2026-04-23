import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                // ── White Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // ── Title ──
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Email Field ──
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Password Field ──
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Login Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Add your login logic here
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonStart,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Forgot Password ──
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to forgot password screen
                        },
                        child: const Text(
                          'Forgot password',
                          style: TextStyle(
                            color: Color(0xFF4A90D9),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Google Sign In Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Add Google sign in logic
                          },
                          icon: Image.asset(
                            'assets/images/google_icon.png',
                            width: 22,
                            height: 22,
                          ),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFFF2F2F2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Sign Up Link ──
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Not Yet Registered? ',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF4A90D9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Bottom Logo ──
                Image.asset(
                  'assets/images/auracare_logo.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(height: 6),
                const Text(
                  'AuraCare',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A7A9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
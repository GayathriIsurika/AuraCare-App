import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auracare_app/constant/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false; // ← shows success screen after email sent

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Send password reset email ──
  Future<void> _sendResetEmail() async {
    // ── Validate email ──
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ── Basic email format check ──
    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ← Save messenger BEFORE await
    final messenger = ScaffoldMessenger.of(context);

    try {
      // ── Send reset email via Firebase ──
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // ── Success → show success state ──
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true; // ← switches to success screen
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      // ── Show specific error messages ──
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'Something went wrong';
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent
              ? _buildSuccessScreen()  // ← show after email sent
              : _buildEmailForm(),     // ← show initially
        ),
      ),
    );
  }

  // ── Email Input Form ──
  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 20),

        // ── Lock icon ──
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: buttonStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 50,
              color: buttonStart,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ── Title ──
        const Text(
          'Reset Your Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 10),

        // ── Description ──
        const Text(
          'Enter your registered email address. We will send you a link to reset your password.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        // ── Email label ──
        const Text(
          'Email Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        // ── Email field ──
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: buttonStart, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 32),

        // ── Send Reset Email Button ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Send Reset Link',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Back to Login ──
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: buttonStart,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Success Screen (shown after email is sent) ──
  Widget _buildSuccessScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // ── Success icon ──
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 60,
            color: Colors.green,
          ),
        ),

        const SizedBox(height: 32),

        // ── Success title ──
        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 12),

        // ── Show which email was used ──
        Text(
          'We sent a password reset link to:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        Text(
          _emailController.text.trim(), // ← shows the email they entered
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: buttonStart,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // ── Instructions ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: buttonStart, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'What to do next:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: buttonStart,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                '1. Check your email inbox\n'
                    '2. Click the reset link in the email\n'
                    '3. Enter your new password\n'
                    '4. Come back and login',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // ── Back to Login Button ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              // Go back to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Resend option ──
        TextButton(
          onPressed: () {
            // Reset to form so they can resend
            setState(() => _emailSent = false);
          },
          child: const Text(
            'Didn\'t receive the email? Send again',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
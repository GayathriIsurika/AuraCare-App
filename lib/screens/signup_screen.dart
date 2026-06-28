import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/firebase_service.dart';
import 'package:auracare_app/services/pin_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PinService _pinService = PinService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  int _currentStep = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Validate and go to PIN step
  void _goToSetPin() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _currentStep = 2);
  }

  // Handle PIN number press
  void _onNumberPressed(String number) {
    setState(() {
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() => _isConfirming = true);
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _completeSignup();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (!_isConfirming) {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  // Complete signup with Firebase ,save PIN
  Future<void> _completeSignup() async {
    if (_pin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final autoPassword =
        'AuraCare_${_pin}_${_emailController.text.trim()}';

    String? error = await _firebaseService.signUp(
      email: _emailController.text.trim(),
      password: autoPassword,
      fullName: _nameController.text.trim(),
    );

    if (error != null &&
        (error.contains('already') || error.contains('in-use'))) {
      error = await _firebaseService.login(
        email: _emailController.text.trim(),
        password: autoPassword,
      );

      if (error == null) {
        await _firebaseService.updateUserName(
          _nameController.text.trim(),
        );
      }
    }

    if (error == null) {
      // Save PIN to device
      await _pinService.savePin(_pin);

      setState(() => _isLoading = false);

      navigator.pushReplacementNamed('/home');
    } else {
      setState(() {
        _isLoading = false;
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  // Google Signup
  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    final messenger = ScaffoldMessenger.of(context);

    String? error = await _firebaseService.signInWithGoogle();

    setState(() => _isGoogleLoading = false);

    if (error == null) {
      // After Google auth go to PIN step
      setState(() => _currentStep = 2);
    } else if (error != 'Sign in cancelled') {
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _currentStep == 1
            ? _buildStep1()
            : _buildStep2(),
      ),
    );
  }

  // Name,Email
  Widget _buildStep1() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 36,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  // Logo
                  Image.asset(
                    'assets/images/auracare_logo.png',
                    width: 80,
                    height: 80,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'AuraCare',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A5C),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Create your account',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 28),

                  //Full Name
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: const Icon(
                        Icons.person_outline,
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

                  // Email
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

                  const SizedBox(height: 24),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _goToSetPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonStart,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey.shade300),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Google Sign Up
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed:
                      _isGoogleLoading ? null : _signUpWithGoogle,
                      icon: _isGoogleLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: buttonStart,
                        ),
                      )
                          : Image.asset(
                        'assets/images/google_icon.png',
                        width: 22,
                        height: 22,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFFF2F2F2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Set PIN
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          const SizedBox(height: 40),

          //Lock icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: buttonStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: buttonStart,
              size: 40,
            ),
          ),

          const SizedBox(height: 24),

          //Title
          Text(
            _isConfirming ? 'Confirm Your PIN' : 'Set Your PIN',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _isConfirming
                ? 'Enter your PIN again to confirm'
                : 'Create a 4-digit PIN to secure your app',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final currentPin = _isConfirming ? _confirmPin : _pin;
              final isFilled = index < currentPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? buttonStart : Colors.grey.shade300,
                  border: Border.all(
                    color:
                    isFilled ? buttonStart : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 60),

          // Number Pad or Loading
          _isLoading
              ? const CircularProgressIndicator(color: buttonStart)
              : _buildNumberPad(),

          const Spacer(),

          // Back button (only on PIN entry, not confirm)
          if (!_isConfirming)
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                  _pin = '';
                  _confirmPin = '';
                  _isConfirming = false;
                });
              },
              child: const Text(
                'Back',
                style: TextStyle(color: buttonStart, fontSize: 17),
              ),
            ),
        ],
      ),
    );
  }

  // Number Pad
  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 104),
            _buildNumberButton('0'),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: _onDeletePressed,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: Colors.black54,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((n) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildNumberButton(n),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _onNumberPressed(number),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
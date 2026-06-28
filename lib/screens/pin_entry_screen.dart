import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/pin_service.dart';
import 'package:auracare_app/services/firebase_service.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final PinService _pinService = PinService();
  final FirebaseService _firebaseService = FirebaseService();

  String _enteredPin = '';
  bool _hasError = false;
  int _attemptCount = 0;
  bool _isLoading = false;

  // Handle number press
  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _hasError = false;
      });

      // Auto verify when 4 digits entered
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
      });
    }
  }

  // Verify entered PIN
  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final isCorrect = await _pinService.verifyPin(_enteredPin);

    setState(() => _isLoading = false);

    if (isCorrect) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {

      _attemptCount++;
      setState(() {
        _hasError = true;
        _enteredPin = '';
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _attemptCount >= 3
                  ? 'Too many attempts. Use email login.'
                  : 'Wrong PIN. ${3 - _attemptCount} attempts left.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _useEmailLogin() async {
    // Delete PIN so they can reset it after login
    await _pinService.deletePin();
    await _firebaseService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const SizedBox(height: 60),

              // App logo
              Image.asset(
                'assets/images/auracare_logo.png',
                width: 80,
                height: 80,
              ),

              const SizedBox(height: 16),

              const Text(
                'AuraCare',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your PIN to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 48),

              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasError
                          ? Colors.red
                          : isFilled
                          ? buttonStart
                          : Colors.grey.shade300,
                      border: Border.all(
                        color: _hasError
                            ? Colors.red
                            : isFilled
                            ? buttonStart
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),

              //Number Pad
              _isLoading
                  ? const CircularProgressIndicator(color: buttonStart)
                  : _buildNumberPad(),

              const Spacer(),

              // Forgot PIN
              TextButton(
                onPressed: _useEmailLogin,
                child: const Text(
                  'Forgot PIN? Login with email',
                  style: TextStyle(
                    color: buttonStart,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

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
            const SizedBox(width: 80),
            const SizedBox(width: 16),
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
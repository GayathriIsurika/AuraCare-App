import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/firebase_service.dart';
import 'package:auracare_app/services/pin_service.dart';

class EmailVerificationWaitScreen extends StatefulWidget {
  final String email;
  final String name;
  final String tempPassword;

  const EmailVerificationWaitScreen({
    super.key,
    required this.email,
    required this.name,
    required this.tempPassword,
  });

  @override
  State<EmailVerificationWaitScreen> createState() =>
      _EmailVerificationWaitScreenState();
}

class _EmailVerificationWaitScreenState
    extends State<EmailVerificationWaitScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PinService _pinService = PinService();

  Timer? _checkTimer;
  bool _isChecking = false;
  bool _canResend = false;
  int _resendCountdown = 30;
  Timer? _resendTimer;

  // PIN state for after verification
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isPinStep = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  // Auto-check every 4 seconds
  void _startAutoCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkIfVerified(silent: true);
    });
  }

  // Resend countdown
  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  // Check verification status
  Future<void> _checkIfVerified({bool silent = false}) async {
    if (!silent) setState(() => _isChecking = true);

    final verified = await _firebaseService.isEmailVerified();

    if (!silent) setState(() => _isChecking = false);

    if (verified && mounted) {
      _checkTimer?.cancel();
      setState(() => _isPinStep = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Now set your PIN.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Resend email
  Future<void> _resendEmail() async {
    final error = await _firebaseService.resendVerificationEmail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error == null
                ? 'Verification email resent!'
                : 'Failed to resend: $error',
          ),
          backgroundColor: error == null ? Colors.green : Colors.red,
        ),
      );
    }
    if (error == null) _startResendCountdown();
  }

  // Go back and delete unverified account
  Future<void> _goBack() async {
    await _firebaseService.deleteUnverifiedAccount();
    if (mounted) Navigator.pop(context);
  }

  // PIN input
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
          if (_confirmPin.length == 4) _savePin();
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (!_isConfirming) {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  Future<void> _savePin() async {
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

    await _pinService.savePin(_pin);

    setState(() => _isLoading = false);

    navigator.pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _goBack,
          ),
          title: Text(
            _isPinStep ? 'Set Your PIN' : 'Verify Email',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: _isPinStep
              ? _buildPinStep()
              : _buildWaitStep(),
        ),
      ),
    );
  }

  // Waiting for email verification
  Widget _buildWaitStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          const SizedBox(height: 24),

          // Animated email icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: buttonStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_unread_outlined,
              color: buttonStart,
              size: 50,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Check Your Email',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'We sent a verification link to:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: buttonStart,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Click the link in the email to verify\nyour account.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          //  Already verified button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isChecking
                  ? null
                  : () => _checkIfVerified(),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isChecking
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'I Verified My Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Resend button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _canResend ? _resendEmail : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _canResend ? buttonStart : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _canResend
                    ? 'Resend Email'
                    : 'Resend in ${_resendCountdown}s',
                style: TextStyle(
                  fontSize: 15,
                  color: _canResend ? buttonStart : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          //  Spam tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tips:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• Check your spam or junk folder\n'
                      '• The link expires in 24 hours\n'
                      '• After clicking the link, tap "I Verified My Email"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade800,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PIN setup after verification
  Widget _buildPinStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          const SizedBox(height: 32),

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

          const SizedBox(height: 40),

          //  PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final currentPin = _isConfirming ? _confirmPin : _pin;
              final isFilled = index < currentPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 18,
                height: 18,
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

          const SizedBox(height: 40),

          _isLoading
              ? const CircularProgressIndicator(color: buttonStart)
              : _buildNumberPad(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 104),
            _buildBtn('0'),
            const SizedBox(width: 16),
            SizedBox(
              width: 75,
              height: 75,
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
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> nums) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: nums.map((n) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _buildBtn(n),
      )).toList(),
    );
  }

  Widget _buildBtn(String number) {
    return SizedBox(
      width: 75,
      height: 75,
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
                fontSize: 22,
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
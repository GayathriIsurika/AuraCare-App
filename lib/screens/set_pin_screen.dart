import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/pin_service.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final PinService _pinService = PinService();

  String _pin = '';           // first PIN entered
  String _confirmPin = '';    // confirmation PIN
  bool _isConfirming = false; // true when on confirm step
  bool _isLoading = false;

  // ── Handle number button press ──
  void _onNumberPressed(String number) {
    setState(() {
      if (!_isConfirming) {
        // ← First PIN entry
        if (_pin.length < 4) {
          _pin += number;
          // Auto move to confirm when 4 digits entered
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() => _isConfirming = true);
            });
          }
        }
      } else {
        // ← Confirming PIN
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          // Auto save when 4 digits entered
          if (_confirmPin.length == 4) {
            _savePin();
          }
        }
      }
    });
  }

  // ── Handle delete button ──
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

  // ── Save PIN after confirmation ──
  Future<void> _savePin() async {
    if (_pin != _confirmPin) {
      // PINs don't match — reset and start over
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
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

    // Save PIN securely
    await _pinService.savePin(_pin);

    setState(() => _isLoading = false);

    if (mounted) {
      // Go to dashboard after PIN set
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const SizedBox(height: 40),

              // ── Lock icon ──
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

              // ── Title changes based on step ──
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
                    : 'Create a 4-digit PIN to secure your account',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // ── PIN Dots ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  // Check how many digits entered
                  final currentPin = _isConfirming ? _confirmPin : _pin;
                  final isFilled = index < currentPin.length;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? buttonStart        // ← filled dot
                          : Colors.grey.shade300, // ← empty dot
                      border: Border.all(
                        color: isFilled ? buttonStart : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),

              // ── Number Pad ──
              _isLoading
                  ? const CircularProgressIndicator(color: buttonStart)
                  : _buildNumberPad(),

              const Spacer(),

              // ── Skip option ──
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Number Pad Widget ──
  Widget _buildNumberPad() {
    return Column(
      children: [
        // Row 1: 1 2 3
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 16),
        // Row 2: 4 5 6
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 16),
        // Row 3: 7 8 9
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 16),
        // Row 4: empty 0 delete
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty space
            const SizedBox(width: 80),
            const SizedBox(width: 16),
            // 0 button
            _buildNumberButton('0'),
            const SizedBox(width: 16),
            // Delete button
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

  // ── Build a row of 3 number buttons ──
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

  // ── Single number button ──
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
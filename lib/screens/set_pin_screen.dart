import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/pin_service.dart';

class SetPinScreen extends StatefulWidget {
  final bool isChangingPin;

  const SetPinScreen({super.key, this.isChangingPin = false});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final PinService _pinService = PinService();

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _isConfirming = true);
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _savePin();
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

  Future<void> _savePin() async {
    if (_pin != _confirmPin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PINs do not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    await _pinService.savePin(_pin);

    setState(() => _isLoading = false);

    if (mounted) {
      if (widget.isChangingPin) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN changed successfully!'),
            backgroundColor: buttonStart,
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      // Add appBar when changing PIN so user can go back
      appBar: widget.isChangingPin
          ? AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change PIN',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
              fontSize: 18
          ),
        ),
      )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                const SizedBox(height: 40),

                // Lock icon
                Container(
                  width: 70,
                  height: 70,
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

                const SizedBox(height: 12),

                // Title
                Text(
                  _isConfirming ? 'Confirm Your PIN' : 'Set Your PIN',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _isConfirming
                      ? 'Enter your PIN again to confirm'
                      : 'Create a 4-digit PIN to secure your account',
                  style: const TextStyle(fontSize: 14, color: buttonStart),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                //PIN Dots
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
                          color: isFilled ? buttonStart : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Number Pad or Loading
                _isLoading
                    ? const CircularProgressIndicator(color: buttonStart)
                    : _buildNumberPad(),

                const SizedBox(height: 24),

                if (!widget.isChangingPin)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: buttonStart, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
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
            const SizedBox(width: 104),
            _buildNumberButton('0'),
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
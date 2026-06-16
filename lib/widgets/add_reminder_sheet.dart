import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/firebase_service.dart';

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final FirebaseService _firebaseService = FirebaseService();

  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _instructionsController = TextEditingController();

  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m'; // 24-hour, e.g. "09:00", "14:30"
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _snack('Please enter a medicine name');
      return;
    }
    if (_selectedTime == null) {
      _snack('Please pick a time');
      return;
    }

    setState(() => _isSaving = true);

    final error = await _firebaseService.saveReminder(
      name: _nameController.text.trim(),
      dose: _doseController.text.trim(),
      instructions: _instructionsController.text.trim(),
      time: _formatTime(_selectedTime!),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      Navigator.pop(context, true); // tell screen to reload
    } else {
      _snack('Error: $error');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Add Reminder",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textBlue,
            ),
          ),
          const SizedBox(height: 20),

          _label("Medicine Name"),
          _field(_nameController, "e.g. Paracetamol"),
          const SizedBox(height: 14),

          _label("Dose"),
          _field(_doseController, "e.g. 1 pill / 500mg"),
          const SizedBox(height: 14),

          _label("Instructions"),
          _field(_instructionsController, "e.g. After food"),
          const SizedBox(height: 14),

          _label("Time"),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : "Select time",
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedTime != null
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Reminder",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
  );

  Widget _field(TextEditingController c, String hint) => TextField(
    controller: c,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/reminder_model.dart';
import 'package:auracare_app/services/firebase_service.dart';
import 'package:flutter/material.dart';

enum _DurationMode { endDate, days }

class AddReminderSheet extends StatefulWidget {
  final ReminderModel? reminder; // null = add, non-null = edit
  const AddReminderSheet({super.key, this.reminder});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final FirebaseService _firebaseService = FirebaseService();

  late final TextEditingController _nameController;
  late final TextEditingController _doseController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _doctorController;
  late final TextEditingController _locationController;
  late final TextEditingController _daysController;

  String _type = 'medicine'; // 'medicine' | 'appointment' | 'custom'
  final List<TimeOfDay> _times = [];
  DateTime? _startDate;
  DateTime? _endDate;
  _DurationMode _durationMode = _DurationMode.days;

  bool _isSaving = false;
  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;

    _type = r?.type ?? 'medicine';
    _nameController = TextEditingController(text: r?.name ?? '');
    _doseController = TextEditingController(text: r?.dose ?? '');
    _instructionsController = TextEditingController(
      text: r?.instructions ?? '',
    );
    _doctorController = TextEditingController(text: r?.doctorName ?? '');
    _locationController = TextEditingController(text: r?.location ?? '');
    _daysController = TextEditingController();

    for (final t in r?.times ?? <String>[]) {
      final parsed = _parseTime(t);
      if (parsed != null) _times.add(parsed);
    }

    _startDate = r?.startDate ?? DateTime.now();
    _endDate = r?.endDate;
    if (_endDate != null) _durationMode = _DurationMode.endDate;
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _instructionsController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        final exists = _times.any(
          (t) => t.hour == picked.hour && t.minute == picked.minute,
        );
        if (!exists) _times.add(picked);
        _times.sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final isAppointment = _type == 'appointment';

    // ── Validation ──
    final title = isAppointment
        ? _doctorController.text.trim()
        : _nameController.text.trim();
    if (title.isEmpty) {
      _snack(isAppointment ? 'Enter the doctor name' : 'Enter a name');
      return;
    }
    if (_times.isEmpty) {
      _snack('Add at least one time');
      return;
    }
    if (_startDate == null) {
      _snack('Pick a start date');
      return;
    }

    // ── Compute end date for medicine/custom courses ──
    DateTime? endDate;
    String repeat = 'daily';

    if (isAppointment) {
      endDate = _startDate; // single-day event
      repeat = 'once';
    } else if (_durationMode == _DurationMode.days) {
      final days = int.tryParse(_daysController.text.trim());
      if (days == null || days < 1) {
        _snack('Enter number of days (1 or more)');
        return;
      }
      endDate = _startDate!.add(Duration(days: days - 1));
    } else {
      if (_endDate == null) {
        _snack('Pick an end date');
        return;
      }
      if (_endDate!.isBefore(_startDate!)) {
        _snack('End date is before start date');
        return;
      }
      endDate = _endDate;
    }

    setState(() => _isSaving = true);

    final error = await _firebaseService.saveReminder(
      type: _type,
      name: isAppointment
          ? _doctorController.text.trim()
          : _nameController.text.trim(),
      dose: _doseController.text.trim(),
      instructions: _instructionsController.text.trim(),
      times: _times.map(_fmtTime).toList(),
      startDate: _startDate,
      endDate: endDate,
      repeat: repeat,
      doctorName: _doctorController.text.trim(),
      location: _locationController.text.trim(),
      reminderId: widget.reminder?.id,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      Navigator.pop(context, true);
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
    final isAppointment = _type == 'appointment';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
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
            Text(
              _isEditing ? "Edit Reminder" : "Add Reminder",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textBlue,
              ),
            ),
            const SizedBox(height: 16),

            // ── Type selector ──
            _label("Type"),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'medicine', label: Text('Medicine')),
                ButtonSegment(value: 'appointment', label: Text('Appointment')),
                ButtonSegment(value: 'custom', label: Text('Other')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 14),

            // ── Type-specific fields ──
            if (isAppointment) ...[
              _label("Doctor"),
              _field(_doctorController, "e.g. Dr. Silva"),
              const SizedBox(height: 14),
              _label("Location"),
              _field(_locationController, "e.g. City Clinic, Room 4"),
              const SizedBox(height: 14),
            ] else ...[
              _label(_type == 'medicine' ? "Medicine Name" : "Title"),
              _field(
                _nameController,
                _type == 'medicine' ? "e.g. Amoxicillin" : "e.g. Walk 20 min",
              ),
              const SizedBox(height: 14),
              if (_type == 'medicine') ...[
                _label("Dose"),
                _field(_doseController, "e.g. 1 pill / 500mg"),
                const SizedBox(height: 14),
              ],
              _label("Instructions"),
              _field(_instructionsController, "e.g. After food"),
              const SizedBox(height: 14),
            ],

            // ── Times ──
            _label(isAppointment ? "Time" : "Times per day"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._times.map(
                  (t) => Chip(
                    label: Text(_fmtTime(t)),
                    onDeleted: () => setState(() => _times.remove(t)),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add time'),
                  onPressed: () {
                    // Appointment = single time
                    if (isAppointment && _times.isNotEmpty) {
                      _snack('An appointment has one time');
                      return;
                    }
                    _addTime();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Dates ──
            _label(isAppointment ? "Date" : "Start date"),
            _dateField(
              value: _startDate,
              onTap: () => _pickDate(isStart: true),
            ),

            // ── Duration (medicine / custom only) ──
            if (!isAppointment) ...[
              const SizedBox(height: 14),
              _label("How long?"),
              SegmentedButton<_DurationMode>(
                segments: const [
                  ButtonSegment(
                    value: _DurationMode.days,
                    label: Text('Number of days'),
                  ),
                  ButtonSegment(
                    value: _DurationMode.endDate,
                    label: Text('End date'),
                  ),
                ],
                selected: {_durationMode},
                onSelectionChanged: (s) =>
                    setState(() => _durationMode = s.first),
              ),
              const SizedBox(height: 10),
              if (_durationMode == _DurationMode.days)
                TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "e.g. 30",
                    suffixText: "days",
                    filled: true,
                    fillColor: const Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                )
              else
                _dateField(
                  value: _endDate,
                  hint: "Select end date",
                  onTap: () => _pickDate(isStart: false),
                ),
            ],

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
                    : Text(
                        _isEditing ? "Update" : "Save",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
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

  Widget _dateField({
    required DateTime? value,
    required VoidCallback onTap,
    String hint = "Select date",
  }) => GestureDetector(
    onTap: onTap,
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
            value != null ? _fmtDate(value) : hint,
            style: TextStyle(
              fontSize: 14,
              color: value != null ? Colors.black87 : Colors.grey,
            ),
          ),
          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
        ],
      ),
    ),
  );
}

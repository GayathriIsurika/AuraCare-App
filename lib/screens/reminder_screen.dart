import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/reminder_model.dart';
import 'package:auracare_app/models/user_model.dart';
import 'package:auracare_app/services/firebase_service.dart';
import 'package:auracare_app/widgets/add_reminder_sheet.dart';
import 'package:auracare_app/widgets/appointment_card.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:auracare_app/widgets/dataPIckerWidget.dart';
import 'package:auracare_app/widgets/hydration_card.dart';
import 'package:auracare_app/widgets/medicine_card.dart';
import 'package:flutter/material.dart';

/// One dose = a reminder + one of its scheduled times, on the selected day.
class _DoseEntry {
  final ReminderModel reminder;
  final String time;
  _DoseEntry(this.reminder, this.time);
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;

  UserModel? user;

  /// Every reminder for this user (filtered per-day in the build).
  List<ReminderModel> _allReminders = [];

  DateTime _selectedDate = DateTime.now();

  bool _hydrationEnabled = false;
  String? _hydrationId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRemindersFromFirebase();
  }

  Future<void> _loadUserProfile() async {
    final data = await _firebaseService.getUserProfile();
    if (data != null && mounted) {
      setState(() => user = UserModel.fromMap(data));
    }
  }

  int _hourOf(String time) {
    final parts = time.split(':');
    if (parts.isEmpty) return -1;
    return int.tryParse(parts[0].trim()) ?? -1;
  }

  Future<void> _loadRemindersFromFirebase() async {
    if (_firebaseService.currentUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in to view reminders'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final reminders = await _firebaseService.getReminders();

    if (mounted) {
      setState(() {
        _allReminders = [];
        _hydrationEnabled = false;
        _hydrationId = null;

        for (var raw in reminders) {
          final model = ReminderModel.fromMap(raw);

          if (model.isHydration || model.type == 'hydration') {
            _hydrationEnabled = true;
            _hydrationId = model.id;
            continue;
          }
          _allReminders.add(model);
        }

        _isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = DateTime(date.year, date.month, date.day));
  }

  /// Expand active reminders into dose rows, then bucket by time of day.
  Map<String, List<_DoseEntry>> _groupedForSelectedDay() {
    final morning = <_DoseEntry>[];
    final afternoon = <_DoseEntry>[];
    final evening = <_DoseEntry>[];

    for (final r in _allReminders) {
      if (!r.isActiveOn(_selectedDate)) continue;

      // A reminder with no times still shows once (e.g. a note); use ''.
      final times = r.times.isEmpty ? [''] : r.times;
      for (final t in times) {
        final entry = _DoseEntry(r, t);
        final h = _hourOf(t);
        if (h >= 12 && h < 17) {
          afternoon.add(entry);
        } else if (h >= 17) {
          evening.add(entry);
        } else {
          morning.add(entry); // h < 12, or no/invalid time
        }
      }
    }

    int byTime(_DoseEntry a, _DoseEntry b) => a.time.compareTo(b.time);
    morning.sort(byTime);
    afternoon.sort(byTime);
    evening.sort(byTime);

    return {'Morning': morning, 'Afternoon': afternoon, 'Evening': evening};
  }

  Future<void> _setDose(ReminderModel r, String time, bool taken) async {
    final key = '${ReminderModel.dateKeyOf(_selectedDate)}_$time';
    setState(() => r.doseLog[key] = taken); // optimistic

    final error = await _firebaseService.setDoseTaken(
      reminderId: r.id,
      day: _selectedDate,
      time: time,
      taken: taken,
    );

    if (error != null && mounted) {
      setState(() => r.doseLog[key] = !taken); // revert on failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    final error = await _firebaseService.deleteReminder(reminderId);

    if (mounted) {
      if (error == null) {
        setState(() => _allReminders.removeWhere((r) => r.id == reminderId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Reminder deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _editReminder(ReminderModel reminder) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddReminderSheet(reminder: reminder),
    );

    if (updated == true) {
      await _loadRemindersFromFirebase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reminder updated'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openAddReminder() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddReminderSheet(),
    );

    if (added == true) {
      await _loadRemindersFromFirebase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reminder added'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleHydration(bool enable) async {
    if (enable) {
      final error = await _firebaseService.saveReminder(
        name: 'Drink Water',
        dose: '1 glass',
        instructions: 'Stay hydrated',
        type: 'hydration',
        isHydration: true,
      );
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_hydrationId != null) {
        await _firebaseService.deleteReminder(_hydrationId!);
      }
    }
    await _loadRemindersFromFirebase();
  }

  Future<void> _refresh() async {
    await _loadUserProfile();
    await _loadRemindersFromFirebase();
  }

  Widget _buildDoseTile(_DoseEntry entry) {
    final r = entry.reminder;
    final taken = r.isDoseTaken(_selectedDate, entry.time);

    final child = (r.type == 'appointment')
        ? AppointmentCard(
            reminder: r,
            isCheckedIn: taken,
            onCheckIn: (v) => _setDose(r, entry.time, v),
            onReschedule: () => _editReminder(r),
          )
        : MedicineCard(
            reminder: r,
            time: entry.time,
            isTaken: taken,
            onMarkTaken: (v) => _setDose(r, entry.time, v),
          );

    return Dismissible(
      // Date is part of the key so each day shows its OWN status, not a cached one.
      key: ValueKey(
        '${r.id}_${entry.time}_${ReminderModel.dateKeyOf(_selectedDate)}',
      ),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit, color: Colors.white, size: 26),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 26),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _editReminder(r);
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete reminder?'),
              content: Text('Remove "${r.name}" from your reminders?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteReminder(r.id);
        }
      },
      child: Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedForSelectedDay();
    final morning = groups['Morning']!;
    final afternoon = groups['Afternoon']!;
    final evening = groups['Evening']!;
    final bool noReminders =
        morning.isEmpty && afternoon.isEmpty && evening.isEmpty;

    return Scaffold(
      backgroundColor: background,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReminder,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user?.firstName.isNotEmpty ?? false)
                              ? "Hello, ${user!.firstName}"
                              : "Hello",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textBlue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Your health schedule for today",
                          style: TextStyle(fontSize: 16, color: textGrey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: (user?.profileImageUrl.isNotEmpty ?? false)
                        ? NetworkImage(user!.profileImageUrl)
                        : null,
                    child: (user?.profileImageUrl.isEmpty ?? true)
                        ? const Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFF2D9CDB),
                          )
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            DatePickerWidget(onDateSelected: _onDateSelected),
            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HydrationCard(
                              enabled: _hydrationEnabled,
                              onToggle: _toggleHydration,
                            ),

                            if (morning.isNotEmpty) ...[
                              _sectionTitle("Morning"),
                              ...morning.map(_buildDoseTile),
                              const SizedBox(height: 20),
                            ],
                            if (afternoon.isNotEmpty) ...[
                              _sectionTitle("Afternoon"),
                              ...afternoon.map(_buildDoseTile),
                              const SizedBox(height: 20),
                            ],
                            if (evening.isNotEmpty) ...[
                              _sectionTitle("Evening"),
                              ...evening.map(_buildDoseTile),
                              const SizedBox(height: 20),
                            ],

                            if (noReminders)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'Nothing for this day — tap + to add',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

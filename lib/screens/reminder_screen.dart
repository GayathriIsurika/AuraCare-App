import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/appointment_model.dart';
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

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;

  UserModel? user;

  List<ReminderModel> morningReminders = [];
  List<ReminderModel> afternoonReminders = [];
  List<ReminderModel> eveningReminders = [];
  List<AppointmentModel> appointments = [];

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
        morningReminders.clear();
        afternoonReminders.clear();
        eveningReminders.clear();
        _hydrationEnabled = false;
        _hydrationId = null;

        for (var reminder in reminders) {
          final model = ReminderModel.fromMap(reminder);

          if (model.isHydration) {
            _hydrationEnabled = true;
            _hydrationId = model.id;
            continue;
          }

          final hour = _hourOf(model.time);
          if (hour >= 0 && hour < 12) {
            morningReminders.add(model);
          } else if (hour >= 12 && hour < 17) {
            afternoonReminders.add(model);
          } else {
            eveningReminders.add(model);
          }
        }

        _isLoading = false;
      });
    }
  }

  Future<void> _updateReminderStatus(String reminderId, bool isTaken) async {
    final error = await _firebaseService.updateReminderStatus(
      reminderId: reminderId,
      isTaken: isTaken,
    );
    if (error != null && mounted) {
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
        setState(() {
          morningReminders.removeWhere((r) => r.id == reminderId);
          afternoonReminders.removeWhere((r) => r.id == reminderId);
          eveningReminders.removeWhere((r) => r.id == reminderId);
        });
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
        time: 'all-day',
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

  Widget _buildReminderTile(ReminderModel reminder) {
    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.horizontal, //
      // ── Swipe RIGHT (Edit) - Blue ──
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

      // ── Swipe LEFT (Delete) - Red ──
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
        // ── Swipe RIGHT → Edit ──
        if (direction == DismissDirection.startToEnd) {
          await _editReminder(reminder);
          return false; // Don't dismiss
        }

        // ── Swipe LEFT → Delete ──
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete reminder?'),
              content: Text('Remove "${reminder.name}" from your reminders?'),
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
          _deleteReminder(reminder.id);
        }
      },

      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: MedicineCard(
          reminder: reminder,
          onMarkTaken: (taken) => _updateReminderStatus(reminder.id, taken),
        ),
      ),
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
    final bool noReminders =
        morningReminders.isEmpty &&
        afternoonReminders.isEmpty &&
        eveningReminders.isEmpty;

    return Scaffold(
      backgroundColor: background,

      // ── FAB: bottom-right corner, ABOVE the nav bar ──
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReminder,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // ── Nav bar in the proper Scaffold slot ──
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
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (user?.profileImageUrl.isNotEmpty ?? false)
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            const DatePickerWidget(),
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
                            // ── Drink Water Card ──
                            HydrationCard(
                              enabled: _hydrationEnabled,
                              onToggle: _toggleHydration,
                            ),

                            // ── Morning ──
                            if (morningReminders.isNotEmpty) ...[
                              _sectionTitle("Morning"),
                              ...morningReminders.map(_buildReminderTile),

                              if (appointments.isNotEmpty) ...[
                                _sectionTitle("Appointments"),
                                ...appointments.map(
                                  (appointment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: AppointmentCard(
                                      appointment: appointment,
                                      onCheckIn: () {
                                        setState(() {
                                          appointment.isCheckedIn =
                                              !appointment.isCheckedIn;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                            ],

                            // ── Afternoon ──
                            if (afternoonReminders.isNotEmpty) ...[
                              _sectionTitle("Afternoon"),
                              ...afternoonReminders.map(_buildReminderTile),
                              const SizedBox(height: 20),
                            ],

                            // ── Evening ──
                            if (eveningReminders.isNotEmpty) ...[
                              _sectionTitle("Evening"),
                              ...eveningReminders.map(_buildReminderTile),
                              const SizedBox(height: 20),
                            ],

                            if (noReminders)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No reminders yet — tap + to add one',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                            // extra space so the FAB never covers the last card
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

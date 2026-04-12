import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/appointment_model.dart';
import 'package:auracare_app/models/reminder_model.dart';
import 'package:auracare_app/models/user_model.dart';
import 'package:auracare_app/widgets/appointment_card.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:auracare_app/widgets/dataPIckerWidget.dart';
import 'package:auracare_app/widgets/medicine_card.dart';
import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // user data
  final UserModel user = UserModel(
    name: "Smith",
    profileImageUrl:
        "https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    hasNotifications: true,
  );

  // Morning reminders
  List<ReminderModel> morningReminders = [
    ReminderModel(
      name: 'Lisinopril',
      dose: '10mg',
      instructions: 'Take with food',
      time: 'Morning',
      isTaken: true,
      isHydration: false,
    ),
  ];

  // Morning appointments
  List<AppointmentModel> appointments = [
    AppointmentModel(
      doctorName: 'Dr. Emily Chen',
      location: 'City Heart Clinic, Room 302',
      time: 'Morning',
      isCheckedIn: false,
    ),
  ];

  // Afternoon reminders
  List<ReminderModel> afternoonReminders = [
    ReminderModel(
      name: 'Vitamin D3',
      dose: '1 Capsule',
      instructions: 'After lunch',
      time: 'Afternoon',
      isTaken: false,
      isHydration: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Header (fixed - not scrolling)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${user.name}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textBlue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Your health schedule for today",
                        style: TextStyle(fontSize: 16, color: textGrey),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2D9CDB),
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user.profileImageUrl),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Date Picker (fixed)
            const DatePickerWidget(),

            const SizedBox(height: 20),

            // Scrollable Content: All reminders + appointments
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Morning Section ──
                    if (morningReminders.isNotEmpty) ...[
                      Text(
                        "Morning",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textGrey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Morning Medicine Card(s)
                      ...morningReminders.map(
                        (reminder) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MedicineCard(
                            reminder: reminder,
                            onMarkTaken: () {
                              setState(() {
                                reminder.isTaken = !reminder.isTaken;
                              });
                            },
                          ),
                        ),
                      ),

                      if (appointments.isNotEmpty) ...[
                        Text(
                          "Appointments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textGrey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Appointment Card(s)
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

                      const SizedBox(height: 30),

                      // ── Afternoon Section ──
                      if (afternoonReminders.isNotEmpty) ...[
                        Text(
                          "Afternoon",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textGrey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Afternoon Medicine Card(s)
                        ...afternoonReminders.map(
                          (reminder) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MedicineCard(
                              reminder: reminder,
                              onMarkTaken: () {
                                setState(() {
                                  reminder.isTaken = !reminder.isTaken;
                                });
                              },
                            ),
                          ),
                        ),
                      ],

                      // Add more sections (Evening, Night, etc.) the same way later
                      const SizedBox(height: 40), // extra space at bottom
                    ],
                  ],
                ),
              ),
            ),
            BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}

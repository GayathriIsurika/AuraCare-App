import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/appointment_model.dart';
import 'package:auracare_app/models/reminder_model.dart';
import 'package:auracare_app/models/user_model.dart';
import 'package:auracare_app/widgets/dataPIckerWidget.dart';
import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // user data---
  final UserModel user = UserModel(
    name: "Smith",
    profileImageUrl:
        "https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    hasNotifications: true,
  );
  // ── Morning reminders ──
  List<ReminderModel> morningReminders = [
    ReminderModel(
      name: 'Lisinopril',
      dose: '10mg',
      instructions: 'Take with food',
      time: 'Morning',
      isTaken: true,
    ),
  ];

  // ── Morning appointments ──
  List<AppointmentModel> appointments = [
    AppointmentModel(
      doctorName: 'Dr. Emily Chen',
      location: 'City Heart Clinic, Room 302',
      time: 'Morning',
      isCheckedIn: false,
    ),
  ];

  // ── Afternoon reminders ──
  List<ReminderModel> afternoonReminders = [
    ReminderModel(
      name: 'Vitamin D3',
      dose: '1 Capsule',
      instructions: 'After lunch',
      time: 'Afternoon',
      isTaken: false,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
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
                            color: Color(0xFF2D9CDB),
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
            SizedBox(height: 20),
            DatePickerWidget(),
          ],
        ),
      ),
    );
  }
}

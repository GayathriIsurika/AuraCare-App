// lib/widgets/appointment_card.dart

import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/appointment_model.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatefulWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCheckIn; // Optional callback

  const AppointmentCard({super.key, required this.appointment, this.onCheckIn});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  late bool isCheckedIn;

  @override
  void initState() {
    super.initState();
    isCheckedIn = widget.appointment.isCheckedIn;
  }

  void _toggleCheckIn() {
    setState(() {
      isCheckedIn = !isCheckedIn;
      widget.appointment.isCheckedIn = isCheckedIn;
    });

    // Call parent callback only when checking in (not when undoing)
    if (isCheckedIn && widget.onCheckIn != null) {
      widget.onCheckIn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: "Appointment" badge + Hospital Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Appointment',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.local_hospital_rounded,
                color: Colors.blue,
                size: 24,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Doctor Name
          Text(
            widget.appointment.doctorName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.appointment.location,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              // Reschedule Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    print(
                      'Reschedule tapped for ${widget.appointment.doctorName}',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reschedule',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Check In / Checked Button (with Undo)
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleCheckIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isCheckedIn ? Colors.green : buttonStart,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCheckedIn ? 'Checked ✅' : 'Check In',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

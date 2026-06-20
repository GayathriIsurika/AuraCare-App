import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/reminder_model.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final ReminderModel reminder;
  final bool isCheckedIn;
  final ValueChanged<bool> onCheckIn;
  final VoidCallback onReschedule;

  const AppointmentCard({
    super.key,
    required this.reminder,
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final time = reminder.times.isNotEmpty ? reminder.times.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: badge + hospital icon
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
                child: Text(
                  time.isNotEmpty ? 'Appointment • $time' : 'Appointment',
                  style: const TextStyle(
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

          // Doctor name (falls back to the reminder name)
          Text(
            reminder.doctorName.isNotEmpty
                ? reminder.doctorName
                : reminder.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Location (only if set)
          if (reminder.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reminder.location,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Reschedule → opens edit
              Expanded(
                child: OutlinedButton(
                  onPressed: onReschedule,
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

              // Check In / Checked (per selected day)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onCheckIn(!isCheckedIn),
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

import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class MedicineCard extends StatelessWidget {
  final ReminderModel reminder;
  final String time;
  final bool isTaken;
  final ValueChanged<bool> onMarkTaken;

  const MedicineCard({
    super.key,
    required this.reminder,
    required this.time,
    required this.isTaken,
    required this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (reminder.dose.isNotEmpty) reminder.dose,
      if (reminder.instructions.isNotEmpty) reminder.instructions,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reminder.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (time.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              time,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isTaken
                  ? GestureDetector(
                      onTap: () => onMarkTaken(false),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    )
                  : const Text(
                      "Due",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          if (!isTaken) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => onMarkTaken(true),
              child: const Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Mark as Taken",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

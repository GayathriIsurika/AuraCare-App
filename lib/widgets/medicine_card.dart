import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class MedicineCard extends StatefulWidget {
  final ReminderModel reminder;
  final ValueChanged<bool> onMarkTaken;

  const MedicineCard({
    super.key,
    required this.reminder,
    required this.onMarkTaken,
  });

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  late bool isTaken;

  @override
  void initState() {
    super.initState();
    isTaken = widget.reminder.isTaken;
  }

  void _setTaken(bool value) {
    setState(() {
      isTaken = value;
      widget.reminder.isTaken = value;
    });
    widget.onMarkTaken(value); // ← persists to Firebase
  }

  @override
  Widget build(BuildContext context) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.reminder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.reminder.dose} • ${widget.reminder.instructions}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              isTaken
                  ? GestureDetector(
                      onTap: () => _setTaken(false), // undo
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    )
                  : const Text(
                      "Due soon",
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
              onTap: () => _setTaken(true),
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

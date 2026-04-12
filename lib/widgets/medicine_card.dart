import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class MedicineCard extends StatefulWidget {
  final ReminderModel reminder;

  const MedicineCard({
    required this.reminder,
    required Null Function() onMarkTaken,
  });

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  late bool isTaken;

  @override
  void initState() {
    super.initState();
    isTaken = widget.reminder.isTaken; // ← get initial value
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Top row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Left side ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Medicine name ──
                  Text(
                    widget.reminder.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),

                  SizedBox(height: 4),

                  // ── Dose + instruction ──
                  Text(
                    "${widget.reminder.dose} • ${widget.reminder.instructions}",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),

              // ── Right side ──
              isTaken
                  // ── Green tick (tap to undo) ──
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isTaken = false; // ← undo!
                          widget.reminder.isTaken = false;
                        });
                      },
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    )
                  // ── Due soon (not taken) ──
                  : Text(
                      "Due soon",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),

          // ── Mark as Taken button (only if not taken) ──
          if (!isTaken) ...[
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  isTaken = true; // ← mark taken!
                  widget.reminder.isTaken = true;
                });
              },
              child: Row(
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

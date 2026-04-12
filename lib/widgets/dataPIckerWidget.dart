import 'package:auracare_app/constant/app_colors.dart';
import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int selectedIndex;
  late List<dynamic> items; // ← mix of DateTime and String

  @override
  void initState() {
    super.initState();

    DateTime today = DateTime.now();
    items = [];
    selectedIndex = 0;

    // ── Build list with month labels ──
    DateTime current = today;
    int lastMonth = -1;

    for (int i = 0; i < 365; i++) {
      current = today.add(Duration(days: i));

      // ── Add month label when month changes ──
      if (current.month != lastMonth) {
        items.add(getMonthName(current)); // ← add "March", "April"...
        lastMonth = current.month;
      }

      items.add(current); // ← add date
    }
  }

  // ── Get day name ──
  String getDayName(DateTime date) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return dayNames[date.weekday % 7];
  }

  // ── Get month name ──
  String getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }

  // ── Count only DateTime items for selectedIndex ──
  int getDateIndex(int itemIndex) {
    int count = 0;
    for (int i = 0; i < itemIndex; i++) {
      if (items[i] is DateTime) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          // ── Month label item ──
          if (items[index] is String) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Text(
                items[index],
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            );
          }

          // ── Date item ──
          DateTime date = items[index] as DateTime;
          int dateIndex = getDateIndex(index);
          bool isSelected = dateIndex == selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = dateIndex;
              });
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF1A4298) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Day name ──
                  Text(
                    getDayName(date),
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  SizedBox(height: 4),

                  // ── Date number ──
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? textLight : textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  // ── Dot ──
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

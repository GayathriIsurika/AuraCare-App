import 'package:auracare_app/constant/app_colors.dart';
import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerWidget({super.key, required this.onDateSelected});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int selectedIndex;
  late List<dynamic> items; // mix of DateTime and String (month labels)

  @override
  void initState() {
    super.initState();

    DateTime today = DateTime.now();
    items = [];
    selectedIndex = 0;

    DateTime current = today;
    int lastMonth = -1;

    for (int i = 0; i < 365; i++) {
      current = today.add(Duration(days: i));

      if (current.month != lastMonth) {
        items.add(getMonthName(current));
        lastMonth = current.month;
      }

      items.add(current);
    }

    // Tell the parent the initial selection (today) after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected(today);
    });
  }

  String getDayName(DateTime date) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return dayNames[date.weekday % 7];
  }

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
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          if (items[index] is String) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Text(
                items[index],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            );
          }

          DateTime date = items[index] as DateTime;
          int dateIndex = getDateIndex(index);
          bool isSelected = dateIndex == selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = dateIndex;
              });
              widget.onDateSelected(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A4298) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getDayName(date),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? textLight : textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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

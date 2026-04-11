class ReminderModel {
  final String name;
  final String dose;
  final String instructions;
  final String time;
  final bool isTaken;
  ReminderModel({
    required this.name,
    required this.dose,
    required this.instructions,
    required this.time,
    required this.isTaken,
  });
}

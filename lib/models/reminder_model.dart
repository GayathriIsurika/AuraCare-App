class ReminderModel {
  final String id;
  final String name;
  final String dose;
  final String instructions;
  final String time;
  bool isTaken;
  final bool isHydration;
  DateTime? snoozedUntil;

  ReminderModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.instructions,
    required this.time,
    required this.isTaken,
    required this.isHydration,
    this.snoozedUntil,
  });

  /// Build a ReminderModel from a Firestore document map.
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      instructions: map['instructions'] ?? '',
      time: map['time'] ?? '',
      isTaken: map['isTaken'] ?? false,
      isHydration: map['isHydration'] ?? false,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'])
          : null,
    );
  }

  /// Convert back to a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'instructions': instructions,
      'time': time,
      'isTaken': isTaken,
      'isHydration': isHydration,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
    };
  }

  bool get isOverdue {
    if (isTaken) return false;
    if (snoozedUntil != null && DateTime.now().isBefore(snoozedUntil!)) {
      return false; // Still snoozed
    }
    return true; // Time to remind!
  }

  DateTime snoozeUntil(int minutes) {
    return DateTime.now().add(Duration(minutes: minutes));
  }

  String getSnoozeText() {
    if (snoozedUntil == null) return '';
    final remaining = snoozedUntil!.difference(DateTime.now());
    if (remaining.inMinutes <= 0) return '';
    return '(Snoozed for ${remaining.inMinutes} min)';
  }
}

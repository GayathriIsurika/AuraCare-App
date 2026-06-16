class ReminderModel {
  final String id;
  final String name;
  final String dose;
  final String instructions;
  final String time;
  bool isTaken;
  final bool isHydration;

  ReminderModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.instructions,
    required this.time,
    required this.isTaken,
    required this.isHydration,
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
    };
  }
}

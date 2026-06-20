class ReminderModel {
  final String id;
  final String type;
  final String name;
  final String dose;
  final String instructions;

  // ── Course (medicine / custom) ──
  final List<String> times;
  final DateTime? startDate;
  final DateTime? endDate;
  final String repeat;

  // ── Appointment-only ──
  final String doctorName;
  final String location;

  final bool isHydration;

  // ── Per-dose completion: { '2026-06-18_08:00': true } ──
  final Map<String, bool> doseLog;

  ReminderModel({
    required this.id,
    required this.type,
    required this.name,
    required this.dose,
    required this.instructions,
    required this.times,
    required this.startDate,
    required this.endDate,
    required this.repeat,
    required this.doctorName,
    required this.location,
    required this.isHydration,
    required this.doseLog,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      type:
          map['type'] ??
          (map['isHydration'] == true ? 'hydration' : 'medicine'),
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      instructions: map['instructions'] ?? '',
      times: _readTimes(map),
      startDate: _readDate(map['startDate']),
      endDate: _readDate(map['endDate']),
      repeat: map['repeat'] ?? 'daily',
      doctorName: map['doctorName'] ?? '',
      location: map['location'] ?? '',
      isHydration: map['isHydration'] ?? false,
      doseLog: Map<String, bool>.from(map['doseLog'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'dose': dose,
      'instructions': instructions,
      'times': times,
      'startDate': _dateKey(startDate),
      'endDate': _dateKey(endDate),
      'repeat': repeat,
      'doctorName': doctorName,
      'location': location,
      'isHydration': isHydration,
      'doseLog': doseLog,
    };
  }

  // ── Helpers ──────────────────────────────────────────

  static List<String> _readTimes(Map<String, dynamic> map) {
    if (map['times'] is List) {
      return List<String>.from(map['times']);
    }
    // backward-compat: old docs had a single 'time' string
    if (map['time'] != null && map['time'] != 'all-day') {
      return [map['time']];
    }
    return [];
  }

  static DateTime? _readDate(dynamic v) {
    if (v == null || v is! String || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  /// 'yyyy-MM-dd' for a date (no time component).
  static String _dateKey(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String dateKeyOf(DateTime d) => _dateKey(d);

  /// Does this reminder apply on the given day?
  bool isActiveOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);

    if (startDate != null) {
      final s = DateTime(startDate!.year, startDate!.month, startDate!.day);
      if (d.isBefore(s)) return false;
    }
    if (endDate != null) {
      final e = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (d.isAfter(e)) return false;
    }

    if (repeat == 'once') {
      return startDate != null && _dateKey(startDate) == _dateKey(d);
    }
    if (repeat == 'daily') return true;

    // weekday list e.g. 'mon,wed,fri'
    const names = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final today = names[d.weekday - 1];
    return repeat.split(',').map((e) => e.trim()).contains(today);
  }

  String doseKey(DateTime day, String time) => '${_dateKey(day)}_$time';

  bool isDoseTaken(DateTime day, String time) =>
      doseLog[doseKey(day, time)] == true;

  /// How many of today's doses are done — for adherence display.
  int takenCountOn(DateTime day) =>
      times.where((t) => isDoseTaken(day, t)).length;
}

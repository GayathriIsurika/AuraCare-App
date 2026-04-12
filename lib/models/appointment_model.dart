class AppointmentModel {
  final String doctorName;
  final String location;
  final String time;
  bool isCheckedIn;
  AppointmentModel({
    required this.doctorName,
    required this.location,
    required this.time,
    required this.isCheckedIn,
  });
}

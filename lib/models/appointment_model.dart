class AppointmentModel {
  final String doctorName;
  final String location;
  final String time;
  final bool isCheckedIn;
  AppointmentModel({
    required this.doctorName,
    required this.location,
    required this.time,
    required this.isCheckedIn,
  });
}

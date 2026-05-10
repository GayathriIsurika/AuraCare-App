class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final double distanceKm;
  final String imageUrl;
  final String phone;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.distanceKm,
    required this.imageUrl,
    required this.phone,
  });

  factory DoctorModel.fromMap(String id, Map<String, dynamic> map) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      hospital: map['hospital'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'specialty': specialty,
    'hospital': hospital,
    'rating': rating,
    'distanceKm': distanceKm,
    'imageUrl': imageUrl,
    'phone': phone,
  };
}

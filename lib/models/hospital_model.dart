class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final String imageUrl;
  final String phone;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.imageUrl,
    required this.phone,
  });

  factory HospitalModel.fromMap(String id, Map<String, dynamic> map) {
    return HospitalModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'distanceKm': distanceKm,
    'imageUrl': imageUrl,
    'phone': phone,
  };
}

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final String imageUrl;
  final String phone;
  final String about;
  final double? lat;
  final double? lng;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.imageUrl,
    required this.phone,
    this.about = '',
    this.lat,
    this.lng,
  });

  factory HospitalModel.fromMap(String id, Map<String, dynamic> map) {
    return HospitalModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      phone: map['phone'] ?? '',
      about: map['about'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'distanceKm': distanceKm,
    'imageUrl': imageUrl,
    'phone': phone,
    'about': about,
    'lat': lat,
    'lng': lng,
  };
}

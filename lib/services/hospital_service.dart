import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/hospital_model.dart';

class HospitalService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<List<HospitalModel>> getNearbyHospitals(
    double lat,
    double lng,
  ) async {
    final query =
        '''
[out:json][timeout:25];
(
  node["amenity"="hospital"](around:5000,$lat,$lng);
  way["amenity"="hospital"](around:5000,$lat,$lng);
);
out center;
''';

    try {
      print('Calling Overpass API...');
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http
          .get(
            Uri.parse(
              'https://overpass-api.de/api/interpreter?data=$encodedQuery',
            ),
            headers: {'User-Agent': 'AuraCareApp/1.0'},
          )
          .timeout(const Duration(seconds: 60));

      print('Overpass status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final elements = data['elements'] as List;
      print('Elements found: ${elements.length}');

      List<HospitalModel> hospitals = [];

      for (var el in elements) {
        final elLat = el['lat'] ?? el['center']?['lat'] ?? 0.0;
        final elLng = el['lon'] ?? el['center']?['lon'] ?? 0.0;
        final tags = el['tags'] ?? {};

        final distanceM = Geolocator.distanceBetween(
          lat,
          lng,
          elLat.toDouble(),
          elLng.toDouble(),
        );
        final distanceKm = distanceM / 1000;

        hospitals.add(
          HospitalModel(
            id: el['id'].toString(),
            name: tags['name'] ?? 'Unknown Hospital',
            address: tags['addr:street'] ?? tags['addr:city'] ?? '',
            phone: tags['phone'] ?? tags['contact:phone'] ?? '',
            about: tags['description'] ?? '',
            imageUrl: '',
            distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
            lat: elLat.toDouble(),
            lng: elLng.toDouble(),
          ),
        );
      }

      hospitals.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return hospitals;
    } catch (e) {
      print('Overpass API error: $e');
      rethrow;
    }
  }
}

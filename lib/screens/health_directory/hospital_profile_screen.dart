import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/app_colors.dart';
import '../../models/hospital_model.dart';
import '../../widgets/health_directory/share_modal_widget.dart';

class HospitalProfileScreen extends StatelessWidget {
  final HospitalModel hospital;

  const HospitalProfileScreen({
    super.key,
    required this.hospital,
    required hospitalData,
  });

  Future<void> _callHospital() async {
    final uri = Uri(scheme: 'tel', path: hospital.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        hospital.lat != null &&
        hospital.lng != null &&
        hospital.lat != 0.0 &&
        hospital.lng != 0.0;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          'Hospital Profile',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _showShareModal(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.share_outlined, color: primary, size: 20),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: primary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    hospital.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hospital.address,
                        style: TextStyle(fontSize: 13, color: textGrey),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.directions_walk_outlined,
                        size: 15,
                        color: textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hospital.distanceKm}km',
                        style: TextStyle(fontSize: 13, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Map Card
            if (hasLocation)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(hospital.lat!, hospital.lng!),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.auracare.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(hospital.lat!, hospital.lng!),
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_pin,
                              color: primary,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Contact Card
            _sectionCard(
              title: 'Contact Information',
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: hospital.phone.isNotEmpty
                        ? hospital.phone
                        : 'Not available',
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: hospital.address.isNotEmpty
                        ? hospital.address
                        : 'Not available',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Card
            _sectionCard(
              title: 'About',
              child: Text(
                hospital.about.isNotEmpty
                    ? hospital.about
                    : 'No information available.',
                style: TextStyle(fontSize: 14, color: textGrey, height: 1.6),
              ),
            ),

            const SizedBox(height: 24),

            // Call Button
            GestureDetector(
              onTap: _callHospital,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [buttonStart, buttonEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Call Hospital',
                      style: TextStyle(
                        color: buttonText,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareModalWidget(
        title: hospital.name,
        subtitle: hospital.address,
        type: 'Hospital',
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: textGrey)),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

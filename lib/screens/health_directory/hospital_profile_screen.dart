import 'package:flutter/material.dart';
import '../../constant/app_colors.dart';
import '../../models/hospital_model.dart';
import '../../widgets/health_directory/share_modal_widget.dart';

class HospitalProfileScreen extends StatelessWidget {
  final HospitalModel hospital;

  const HospitalProfileScreen({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ── AppBar ────────────────────────────────────────────────────────────
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
          // Share Button
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

            // ── Header Card ─────────────────────────────────────────────────
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
                  // Hospital Icon
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

                  // Name
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

                  // Address
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

            // ── Contact Card ────────────────────────────────────────────────
            _sectionCard(
              title: 'Contact Information',
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: hospital.phone,
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: hospital.address,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── About Card ──────────────────────────────────────────────────
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

            // ── Call Button ─────────────────────────────────────────────────
            GestureDetector(
              onTap: () {},
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

  // ── Share Modal ───────────────────────────────────────────────────────────
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

  // ── Section Card ──────────────────────────────────────────────────────────
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

  // ── Info Row ──────────────────────────────────────────────────────────────
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

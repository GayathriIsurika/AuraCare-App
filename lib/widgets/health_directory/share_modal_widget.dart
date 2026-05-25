import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constant/app_colors.dart';

class ShareModalWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type;

  const ShareModalWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle Bar ──────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ────────────────────────────────────────────────────────
          Text(
            'Share $type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share this $type info with others',
            style: TextStyle(fontSize: 13, color: textGrey),
          ),
          const SizedBox(height: 20),

          // ── Info Card ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type == 'Hospital'
                        ? Icons.local_hospital_rounded
                        : Icons.person_rounded,
                    color: primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Share Options Row ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _shareOption(
                icon: Icons.copy_rounded,
                label: 'Copy Link',
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: '$type: $title - $subtitle'),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Copied to clipboard!'),
                      backgroundColor: primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _shareOption(
                icon: Icons.message_outlined,
                label: 'Message',
                onTap: () => Navigator.pop(context),
              ),
              _shareOption(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                onTap: () => Navigator.pop(context),
              ),
              _shareOption(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Cancel Button ────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Share Option Item ─────────────────────────────────────────────────────
  Widget _shareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class UploadFabMenu extends StatefulWidget {
  const UploadFabMenu({super.key});

  @override
  State<UploadFabMenu> createState() => _UploadFabMenuState();
}

class _UploadFabMenuState extends State<UploadFabMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  // ── 1. Scan Document ──────────────────────────────────────────────
  Future<void> _scanDocument() async {
    _close();
    try {
      List<String>? scannedImages = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
      );

      if (scannedImages != null && scannedImages.isNotEmpty) {
        _showSnack('✅ Scanned ${scannedImages.length} page(s) successfully!');
        // TODO: Save scannedImages paths to your records
      } else {
        _showSnack('No pages scanned.');
      }
    } catch (e) {
      _showSnack('❌ Scan failed: $e');
    }
  }

  // ── 2. Upload from Gallery ────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    _close();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _showSnack('✅ Image selected: ${image.name}');
        // TODO: Save image.path to your records
      } else {
        _showSnack('No image selected.');
      }
    } catch (e) {
      _showSnack('❌ Gallery error: $e');
    }
  }

  // ── 3. Browse Files / PDF ─────────────────────────────────────────
  Future<void> _pickFile() async {
    _close();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final fileName = result.files.single.name;
        _showSnack('✅ File selected: $fileName');
        // TODO: Save result.files.single.path to your records
      } else {
        _showSnack('No file selected.');
      }
    } catch (e) {
      _showSnack('❌ File picker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Menu Items ──────────────────────────────────────────────
        if (_isOpen) ...[
          _buildMenuItem(
            label: 'Scan Document',
            icon: Icons.document_scanner_outlined,
            color: const Color(0xFF4A90D9),
            onTap: _scanDocument,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            label: 'Upload from Gallery',
            icon: Icons.photo_outlined,
            color: const Color(0xFF27AE60),
            onTap: _pickFromGallery,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            label: 'Browse Files / PDF',
            icon: Icons.folder_outlined,
            color: const Color(0xFF9B59B6),
            onTap: _pickFile,
          ),
          const SizedBox(height: 16),
        ],

        // ── Main FAB Button ─────────────────────────────────────────
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: const Color(0xFF4A90D9),
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _expandAnimation,
      child: ScaleTransition(
        scale: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF4A90D9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

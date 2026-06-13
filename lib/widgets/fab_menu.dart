import 'dart:io';
import 'package:auracare_app/services/firebase_service.dart';
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
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _uploadAndSave(
    String filePath, {
    required String defaultTitle,
  }) async {
    // 1. Show dialog first — user types the name
    final result = await _showUploadDialog(defaultTitle);
    if (result == null) return; // user cancelled

    // 2. Detect category from FINAL title user typed ← moved here
    final autoCategory = _firebaseService.detectCategory(result['title']!);

    _showSnack('⏳ Uploading...');

    // 3. Upload with correct category
    final error = await _firebaseService.saveMedicalRecord(
      file: File(filePath),
      title: result['title']!,
      subtitle: result['title']!,
      category: autoCategory,
    );

    if (error != null) {
      _showSnack('❌ $error');
    } else {
      _showSnack('✅ Saved to ${_categoryLabel(autoCategory)}!');
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'lab':
        return 'Labs';
      case 'imaging':
        return 'Imaging';
      case 'vaccine':
        return 'Vaccines';
      case 'consultation':
        return 'Consultations';
      default:
        return 'Records';
    }
  }

  Future<Map<String, String>?> _showUploadDialog(String defaultTitle) async {
    final TextEditingController titleController = TextEditingController(
      text: defaultTitle,
    );

    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Save Record',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Title field only
              const Text(
                'Record Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Blood Test Report',
                  filled: true,
                  fillColor: const Color(0xFFF0F4F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.pop(context, {'title': title});
                  },
                  child: const Text(
                    'Upload & Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

  //Scan Document
  Future<void> _scanDocument() async {
    _close();
    try {
      List<String>? scannedImages = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
      );

      if (scannedImages != null && scannedImages.isNotEmpty) {
        await _uploadAndSave(
          scannedImages.first,
          defaultTitle: 'Scanned Document',
        );
      }
    } catch (e) {
      _showSnack('❌ Scan failed: $e');
    }
  }

  //Upload from Gallery
  Future<void> _pickFromGallery() async {
    _close();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final defaultTitle = image.name.replaceAll(RegExp(r'\.[^.]+$'), '');
        await _uploadAndSave(image.path, defaultTitle: defaultTitle);
      }
    } catch (e) {
      _showSnack('❌ Gallery error: $e');
    }
  }

  //Browse Files / PDF
  Future<void> _pickFile() async {
    _close();
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true, // ← ADD THIS
      );

      if (result != null) {
        final file = result.files.single;

        print('📄 File name: ${file.name}');
        print('📄 File path: ${file.path}');
        print('📄 File size: ${file.size}');

        // path can be null on some devices
        if (file.path == null) {
          _showSnack('❌ Could not get file path');
          return;
        }

        final defaultTitle = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
        await _uploadAndSave(file.path!, defaultTitle: defaultTitle);
      }
    } catch (e) {
      print('❌ File picker error: $e');
      _showSnack('❌ File picker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _isOpen
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                )
              : const SizedBox.shrink(),
        ),

        //Main FAB Button
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
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ],
          ),
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

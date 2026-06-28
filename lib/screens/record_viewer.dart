import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecordViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const RecordViewerScreen({super.key, required this.url, required this.title});

  @override
  State<RecordViewerScreen> createState() => _RecordViewerScreenState();
}

class _RecordViewerScreenState extends State<RecordViewerScreen> {
  bool _isLoading = true;
  String? _error;
  Uint8List? _imageBytes;

  bool get _isPdf =>
      widget.url.toLowerCase().contains('.pdf') ||
      widget.url.toLowerCase().contains('/raw/');

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    print('🔗 Loading URL: ${widget.url}');
    try {
      final response = await http.get(Uri.parse(widget.url));
      print('📡 Status code: ${response.statusCode}');

      setState(() {
        _imageBytes = response.bodyBytes; // ← store in memory, no disk needed
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _error = 'Failed to load file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
            )
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            )
          : _isPdf
          ? const Center(
              child: Text(
                'PDF preview not supported.\nOpen in browser to view.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            )
          : InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Image.memory(_imageBytes!, fit: BoxFit.contain),
              ),
            ),
    );
  }
}

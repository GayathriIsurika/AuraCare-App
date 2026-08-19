import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import '../services/gemini_service.dart';

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

  // AI summary state
  late final GeminiService _geminiService;
  String? _geminiInitError;
  bool _isSummarizing = false;

  bool get _isPdf =>
      widget.url.toLowerCase().contains('.pdf') ||
          widget.url.toLowerCase().contains('/raw/');

  String get _mimeType {
    final lower = widget.url.toLowerCase();
    if (_isPdf) return 'application/pdf';
    if (lower.contains('.png')) return 'image/png';
    if (lower.contains('.webp')) return 'image/webp';
    // Cloudinary image URLs are jpeg by default when no extension is present
    return 'image/jpeg';
  }

  @override
  void initState() {
    super.initState();
    _downloadFile();
    try {
      _geminiService = GeminiService();
    } catch (e) {
      _geminiInitError = e.toString();
    }
  }

  Future<void> _downloadFile() async {
    debugPrint('🔗 Loading URL: ${widget.url}');
    try {
      final response = await http.get(Uri.parse(widget.url));
      debugPrint('📡 Status code: ${response.statusCode}');

      setState(() {
        _imageBytes = response.bodyBytes; // ← store in memory, no disk needed
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() {
        _error = 'Failed to load file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _summarizeWithAI() async {
    if (_imageBytes == null) return;

    if (_geminiInitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI service unavailable: $_geminiInitError')),
      );
      return;
    }

    setState(() => _isSummarizing = true);

    final summary = await _geminiService.summarizeDocument(
      bytes: _imageBytes!,
      mimeType: _mimeType,
    );

    if (!mounted) return;
    setState(() => _isSummarizing = false);

    _showSummarySheet(summary);
  }

  void _showSummarySheet(String summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF9B59B6)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'AI Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: MarkdownBody(
                        data: summary,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          strong: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: const TextStyle(
                            color: Color(0xFF1B4F72),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          listBullet: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
      floatingActionButton: (!_isLoading && _error == null && _imageBytes != null)
          ? FloatingActionButton.extended(
        onPressed: _isSummarizing ? null : _summarizeWithAI,
        backgroundColor: const Color(0xFF9B59B6),
        icon: _isSummarizing
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          _isSummarizing ? 'Reading…' : 'Summarize with AI',
          style: const TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }
}
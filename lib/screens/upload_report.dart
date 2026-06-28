import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/fab_menu.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/firebase_service.dart';
import 'record_viewer.dart';

class MedicalRecord {
  final String docId;
  final String cloudinaryUrl;
  final String title;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String category;

  const MedicalRecord({
    required this.docId,
    required this.cloudinaryUrl,
    required this.title,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.category,
  });
}

Map<String, List<MedicalRecord>> groupByMonth(List<MedicalRecord> records) {
  final Map<String, List<MedicalRecord>> grouped = {};
  for (final record in records) {
    final month = _fullMonthLabel(record.date);
    grouped.putIfAbsent(month, () => []).add(record);
  }
  return grouped;
}

String _fullMonthLabel(String date) {
  const monthNames = {
    'Jan': 'JANUARY',
    'Feb': 'FEBRUARY',
    'Mar': 'MARCH',
    'Apr': 'APRIL',
    'May': 'MAY',
    'Jun': 'JUNE',
    'Jul': 'JULY',
    'Aug': 'AUGUST',
    'Sep': 'SEPTEMBER',
    'Oct': 'OCTOBER',
    'Nov': 'NOVEMBER',
    'Dec': 'DECEMBER',
  };
  final prefix = date.length >= 3 ? date.substring(0, 3) : date;
  final year = DateTime.now().year;
  return '${monthNames[prefix] ?? prefix} $year';
}

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';
  final FirebaseService _firebaseService = FirebaseService();

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'All', 'filter': null},
    {'label': 'Labs', 'filter': 'lab'},
    {'label': 'Imaging', 'filter': 'imaging'},
    {'label': 'Vaccines', 'filter': 'vaccine'},
    {'label': 'Consultations', 'filter': 'consultation'},
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>>? _recordsStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _recordsStream = FirebaseFirestore.instance
          .collection('medical_records')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  MedicalRecord _docToRecord(String docId, Map<String, dynamic> data) {
    final category = data['category'] ?? 'lab';
    return MedicalRecord(
      docId: docId,
      cloudinaryUrl: data['cloudinaryUrl'] ?? '',
      title: data['title'] ?? 'Untitled',
      date: data['date'] ?? '',
      category: category,
      icon: _iconForCategory(category),
      iconColor: _colorForCategory(category),
      iconBg: _bgForCategory(category),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'imaging':
        return Icons.image_outlined;
      case 'vaccine':
        return Icons.vaccines_outlined;
      case 'consultation':
        return Icons.medical_services_outlined;
      case 'lab':
        return Icons.science_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'imaging':
        return const Color(0xFF9B59B6);
      case 'vaccine':
        return const Color(0xFF27AE60);
      case 'consultation':
        return const Color(0xFFE67E22);
      case 'lab':
        return const Color(0xFF4A90D9);
      default:
        return const Color(0xFF4A90D9);
    }
  }

  Color _bgForCategory(String category) {
    switch (category) {
      case 'imaging':
        return const Color(0xFFF3E5F5);
      case 'vaccine':
        return const Color(0xFFE8F5E9);
      case 'consultation':
        return const Color(0xFFFFF3E0);
      case 'lab':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  Future<void> _deleteRecord(MedicalRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete record?'),
        content: Text('Are you sure you want to delete "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final error = await _firebaseService.deleteMedicalRecord(record.docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error == null ? '✅ Record deleted' : '❌ $error'),
            backgroundColor: const Color(0xFF4A90D9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _openRecord(MedicalRecord record) {
    print('🔗 cloudinaryUrl: "${record.cloudinaryUrl}"');
    if (record.cloudinaryUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file available')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecordViewerScreen(url: record.cloudinaryUrl, title: record.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Upload Report',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _recordsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  List<MedicalRecord> records = snapshot.data!.docs
                      .map((doc) => _docToRecord(doc.id, doc.data()))
                      .toList();

                  final filter = _tabs[_selectedTab]['filter'];
                  if (filter != null) {
                    records = records
                        .where((r) => r.category == filter)
                        .toList();
                  }

                  if (_searchQuery.isNotEmpty) {
                    records = records.where((r) {
                      return r.title.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (records.isEmpty) return _buildEmptyState();

                  final grouped = groupByMonth(records);
                  return ListView(
                    children: [
                      for (final entry in grouped.entries) ...[
                        _buildSectionLabel(entry.key),
                        const SizedBox(height: 8),
                        ...entry.value.map((r) => _buildRecordCard(r)),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const UploadFabMenu(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase().trim());
        },
        decoration: const InputDecoration(
          hintText: 'Search records...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A90D9) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _tabs[index]['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    return Dismissible(
      key: Key(record.docId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        await _deleteRecord(record);
        return false;
      },
      child: GestureDetector(
        onTap: () => _openRecord(record),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: record.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(record.icon, color: record.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first record',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/fab_menu.dart';
import '../widgets/bottom_nav_bar.dart';

class MedicalRecord {
  final String title;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String category; // 'lab', 'imaging', 'vaccine', 'consultation'

  const MedicalRecord({
    required this.title,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.category,
  });
}

const List<MedicalRecord> allRecords = [];

//Group records by month label
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
  final prefix = date.substring(0, 3);
  final year = DateTime.now().year;
  return '${monthNames[prefix] ?? prefix} $year';
}

// Main Screen
class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'All', 'filter': null},
    {'label': 'Labs', 'filter': 'lab'},
    {'label': 'Imaging', 'filter': 'imaging'},
    {'label': 'Vaccines', 'filter': 'vaccine'},
    {'label': 'Consultations', 'filter': 'consultation'},
  ];

  //Firestore stream
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

  //Convert Firestore doc to MedicalRecord
  MedicalRecord _docToRecord(Map<String, dynamic> data) {
    final category = data['category'] ?? 'lab';
    return MedicalRecord(
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
      default:
        return Icons.science_outlined; // lab
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
      default:
        return const Color(0xFF4A90D9); // lab
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
      default:
        return const Color(0xFFE3F2FD); // lab
    }
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
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // No data
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Convert docs to MedicalRecord list
                  List<MedicalRecord> records = snapshot.data!.docs
                      .map((doc) => _docToRecord(doc.data()))
                      .toList();

                  // Apply tab filter
                  final filter = _tabs[_selectedTab]['filter'];
                  if (filter != null) {
                    records = records
                        .where((r) => r.category == filter)
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    records = records.where((r) {
                      return r.title.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  // Still empty after filter
                  if (records.isEmpty) return _buildEmptyState();

                  // Group by month and show
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
    return Container(
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
          Text(
            record.date,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Shows when a tab has no records
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

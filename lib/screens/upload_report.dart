import 'package:flutter/material.dart';
import '../widgets/fab_menu.dart';
import '../widgets/bottom_nav_bar.dart';

class MedicalRecord {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String category; // 'lab', 'imaging', 'vaccine', 'consultation'

  const MedicalRecord({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.category,
  });
}

const List<MedicalRecord> allRecords = [
  //October)
  MedicalRecord(
    title: 'Complete Blood Count',
    subtitle: 'City General Hospital • Dr. Smith',
    date: 'Oct 24',
    icon: Icons.water_drop_outlined,
    iconColor: Color(0xFF4A90D9),
    iconBg: Color(0xFFDDEEFB),
    category: 'lab',
  ),
  MedicalRecord(
    title: 'Chest X-Ray',
    subtitle: 'Radiology Center • Dr. House',
    date: 'Oct 20',
    icon: Icons.image_outlined,
    iconColor: Color(0xFF4A90D9),
    iconBg: Color(0xFFDDEEFB),
    category: 'imaging',
  ),
  MedicalRecord(
    title: 'Post-Surgery Discharge Summary',
    subtitle: 'City General Hospital • Dr. Smith',
    date: 'Oct 10',
    icon: Icons.assignment_outlined,
    iconColor: Color(0xFF4A90D9),
    iconBg: Color(0xFFDDEEFB),
    category: 'consultation',
  ),

  // NOVEMBER
  MedicalRecord(
    title: 'Dermatology Follow-up Note',
    subtitle: 'Skin Care Center • Dr. Lee',
    date: 'Nov 28',
    icon: Icons.content_paste_outlined,
    iconColor: Color(0xFF4A90D9),
    iconBg: Color(0xFFDDEEFB),
    category: 'consultation',
  ),
  MedicalRecord(
    title: 'MRI Brain Scan',
    subtitle: 'Advanced Radiology • Dr. Banner',
    date: 'Nov 15',
    icon: Icons.image_search_outlined,
    iconColor: Color(0xFF4A90D9),
    iconBg: Color(0xFFDDEEFB),
    category: 'imaging',
  ),
  MedicalRecord(
    title: 'Annual Flu Vaccine',
    subtitle: 'City General Pharmacy • Nurse Joy',
    date: 'Nov 12',
    icon: Icons.vaccines_outlined,
    iconColor: Color(0xFF16A085),
    iconBg: Color(0xFFD5F5EF),
    category: 'vaccine',
  ),

  // SEPTEMBER
  MedicalRecord(
    title: 'Annual Checkup Report',
    subtitle: 'City General Hospital',
    date: 'Sep 02',
    icon: Icons.description_outlined,
    iconColor: Color(0xFF27AE60),
    iconBg: Color(0xFFE3F7EC),
    category: 'lab',
  ),

  // AUGUST
  MedicalRecord(
    title: 'Tetanus Booster',
    subtitle: 'Valley Clinic • Dr. Adams',
    date: 'Aug 05',
    icon: Icons.vaccines_outlined,
    iconColor: Color(0xFF16A085),
    iconBg: Color(0xFFD5F5EF),
    category: 'vaccine',
  ),

  MedicalRecord(
    title: 'Dental Panoramic X-Ray',
    subtitle: 'Smile Dental Clinic • Dr. Dent',
    date: 'Aug 30',
    icon: Icons.image_outlined,
    iconColor: Color(0xFF4A90D9),
    iconBg: Color(0xFFDDEEFB),
    category: 'imaging',
  ),
];

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
  const map = {
    'Jan': 'JANUARY 2023',
    'Feb': 'FEBRUARY 2023',
    'Mar': 'MARCH 2023',
    'Apr': 'APRIL 2023',
    'May': 'MAY 2023',
    'Jun': 'JUNE 2023',
    'Jul': 'JULY 2023',
    'Aug': 'AUGUST 2023',
    'Sep': 'SEPTEMBER 2023',
    'Oct': 'OCTOBER 2023',
    'Nov': 'NOVEMBER 2023',
    'Dec': 'DECEMBER 2023',
  };
  final prefix = date.substring(0, 3);
  return map[prefix] ?? prefix;
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

  // Tab definitions: label + which category to filter (null = All)
  final List<Map<String, dynamic>> _tabs = [
    {'label': 'All', 'filter': null},
    {'label': 'Labs', 'filter': 'lab'},
    {'label': 'Imaging', 'filter': 'imaging'},
    {'label': 'Vaccines', 'filter': 'vaccine'},
    {'label': 'Consultations', 'filter': 'consultation'},
  ];

  List<MedicalRecord> get _filteredRecords {
    List<MedicalRecord> records = List.from(allRecords);

    final filter = _tabs[_selectedTab]['filter'];
    if (filter != null) {
      records = records.where((r) => r.category == filter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      records = records.where((r) {
        return r.title.toLowerCase().contains(_searchQuery) ||
            r.subtitle.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return records;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth(_filteredRecords);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      //App Bar
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

      //Body
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

            // Show active filter chips
            const SizedBox(height: 12),

            // Records list
            Expanded(
              child: grouped.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      children: [
                        for (final entry in grouped.entries) ...[
                          _buildSectionLabel(entry.key),
                          const SizedBox(height: 8),
                          ...entry.value.map((r) => _buildRecordCard(r)),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: const UploadFabMenu(),

      //Bottom Nav
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
                const SizedBox(height: 4),
                Text(
                  record.subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

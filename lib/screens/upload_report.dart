import 'package:flutter/material.dart';
import '../widgets/fab_menu.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/bottom_nav_bar.dart';

// ─── Data Model ────────────────────────────────────────────────────────────────
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

// ─── All Records Data ──────────────────────────────────────────────────────────
const List<MedicalRecord> allRecords = [
  // ── THIS MONTH (October) ──────────────────────────────────────────
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

  // ── NOVEMBER 2023 ─────────────────────────────────────────────────
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

  // ── SEPTEMBER 2023 ────────────────────────────────────────────────
  MedicalRecord(
    title: 'Annual Checkup Report',
    subtitle: 'City General Hospital',
    date: 'Sep 02',
    icon: Icons.description_outlined,
    iconColor: Color(0xFF27AE60),
    iconBg: Color(0xFFE3F7EC),
    category: 'lab',
  ),

  // ── AUGUST 2023 ───────────────────────────────────────────────────
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

// ─── Helper: Group records by month label ─────────────────────────────────────
Map<String, List<MedicalRecord>> groupByMonth(List<MedicalRecord> records) {
  final Map<String, List<MedicalRecord>> grouped = {};
  for (final record in records) {
    // Use first 3 chars of date as month key e.g. "Nov", "Oct"
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
    'Oct': 'THIS MONTH',
    'Nov': 'NOVEMBER 2023',
    'Dec': 'DECEMBER 2023',
  };
  final prefix = date.substring(0, 3);
  return map[prefix] ?? prefix;
}

// ─── Main Screen ───────────────────────────────────────────────────────────────
class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  int _selectedTab = 0;
  FilterOptions _activeFilters = FilterOptions();

  // Tab definitions: label + which category to filter (null = All)
  final List<Map<String, dynamic>> _tabs = [
    {'label': 'All', 'filter': null},
    {'label': 'Labs', 'filter': 'lab'},
    {'label': 'Imaging', 'filter': 'imaging'},
    {'label': 'Vaccines', 'filter': 'vaccine'},
    {'label': 'Consultations', 'filter': 'consultation'},
  ];

  // Returns filtered records based on selected tab
  List<MedicalRecord> get _filteredRecords {
    List<MedicalRecord> records = List.from(allRecords);

    // 1. Filter by tab category
    final filter = _tabs[_selectedTab]['filter'];
    if (filter != null) {
      records = records.where((r) => r.category == filter).toList();
    }

    // 2. Filter by selected doctors
    if (_activeFilters.selectedDoctors.isNotEmpty) {
      records = records.where((r) {
        return _activeFilters.selectedDoctors.any(
          (doc) => r.subtitle.contains(doc),
        );
      }).toList();
    }

    // 3. Filter by selected facilities
    if (_activeFilters.selectedFacilities.isNotEmpty) {
      records = records.where((r) {
        return _activeFilters.selectedFacilities.any(
          (fac) => r.subtitle.contains(fac),
        );
      }).toList();
    }

    // 4. Filter by date range
    records = _applyDateFilter(records);

    // 5. Sort
    records = _applySorting(records);

    return records;
  }

  List<MedicalRecord> _applyDateFilter(List<MedicalRecord> records) {
    final now = DateTime.now();
    final range = _activeFilters.dateRange;

    if (range == 'All Time') return records;

    return records.where((r) {
      // Parse date like "Nov 12", "Oct 24"
      final parts = r.date.split(' ');
      if (parts.length < 2) return true;

      const monthMap = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };

      final month = monthMap[parts[0]] ?? 1;
      final day = int.tryParse(parts[1]) ?? 1;
      final recordDate = DateTime(2023, month, day);

      if (range == 'Last 30 Days') {
        return recordDate.isAfter(now.subtract(const Duration(days: 30)));
      } else if (range == 'Last 6 Months') {
        return recordDate.isAfter(now.subtract(const Duration(days: 180)));
      } else if (range == 'This Year') {
        return recordDate.year == now.year;
      }
      return true;
    }).toList();
  }

  List<MedicalRecord> _applySorting(List<MedicalRecord> records) {
    const monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    DateTime parseDate(String date) {
      final parts = date.split(' ');
      if (parts.length < 2) return DateTime(2023);
      final month = monthMap[parts[0]] ?? 1;
      final day = int.tryParse(parts[1]) ?? 1;
      return DateTime(2023, month, day);
    }

    final sorted = List<MedicalRecord>.from(records);

    if (_activeFilters.sortBy == 'Newest First') {
      sorted.sort((a, b) => parseDate(b.date).compareTo(parseDate(a.date)));
    } else if (_activeFilters.sortBy == 'Oldest First') {
      sorted.sort((a, b) => parseDate(a.date).compareTo(parseDate(b.date)));
    } else if (_activeFilters.sortBy == 'A-Z') {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    }

    return sorted;
  }

  void _openFilterSheet() async {
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true, // allows full height
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, // opens at 75% screen height
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) =>
            FilterBottomSheet(currentFilters: _activeFilters),
      ),
    );

    if (result != null) {
      setState(() => _activeFilters = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth(_filteredRecords);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      // ── App Bar ────────────────────────────────────────────────────
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

      // ── Body ───────────────────────────────────────────────────────
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
            if (_activeFilters.isActive) _buildActiveFilterChips(),

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

      // ── Bottom Nav ─────────────────────────────────────────────────
      bottomNavigationBar: const BottomNavBar(currentIndex: null),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Widget Builders
  // ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search records...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: GestureDetector(
            onTap: _openFilterSheet, // ← opens the filter sheet
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _activeFilters.isActive
                        ? const Color(0xFF4A90D9) // blue when active
                        : const Color(0xFFDDEEFB), // light when inactive
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: _activeFilters.isActive
                        ? Colors.white
                        : const Color(0xFF4A90D9),
                    size: 20,
                  ),
                ),
                // Badge dot when filters are active
                if (_activeFilters.isActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    // Sort chip
    if (_activeFilters.sortBy != 'Newest First') {
      chips.add(
        _filterChip(
          label: _activeFilters.sortBy,
          onRemove: () => setState(() {
            _activeFilters.sortBy = 'Newest First';
          }),
        ),
      );
    }

    // Date chip
    if (_activeFilters.dateRange != 'All Time') {
      chips.add(
        _filterChip(
          label: _activeFilters.dateRange,
          onRemove: () => setState(() {
            _activeFilters.dateRange = 'All Time';
          }),
        ),
      );
    }

    // Doctor chips
    for (final doc in _activeFilters.selectedDoctors) {
      chips.add(
        _filterChip(
          label: doc,
          onRemove: () => setState(() {
            _activeFilters.selectedDoctors.remove(doc);
          }),
        ),
      );
    }

    // Facility chips
    for (final fac in _activeFilters.selectedFacilities) {
      chips.add(
        _filterChip(
          label: fac,
          onRemove: () => setState(() {
            _activeFilters.selectedFacilities.remove(fac);
          }),
        ),
      );
    }

    // Format chips
    for (final fmt in _activeFilters.selectedFormats) {
      chips.add(
        _filterChip(
          label: fmt,
          onRemove: () => setState(() {
            _activeFilters.selectedFormats.remove(fmt);
          }),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
        const SizedBox(height: 6),
        // Results count + clear all
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filteredRecords.length} result(s) found',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4A90D9),
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _activeFilters = FilterOptions();
              }),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEEFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4A90D9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4A90D9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF4A90D9)),
          ),
        ],
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF4A90D9),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shield_outlined),
          label: 'M vault',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Reminder',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

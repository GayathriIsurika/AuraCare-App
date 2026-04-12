import 'package:flutter/material.dart';

// ─── Filter State Model ────────────────────────────────────────────────────────
class FilterOptions {
  String sortBy;
  String dateRange;
  List<String> selectedDoctors;
  List<String> selectedFacilities;
  List<String> selectedFormats;

  FilterOptions({
    this.sortBy = 'Newest First',
    this.dateRange = 'All Time',
    List<String>? selectedDoctors,
    List<String>? selectedFacilities,
    List<String>? selectedFormats,
  }) : selectedDoctors = selectedDoctors ?? [],
       selectedFacilities = selectedFacilities ?? [],
       selectedFormats = selectedFormats ?? [];

  // Check if any filter is active
  bool get isActive =>
      sortBy != 'Newest First' ||
      dateRange != 'All Time' ||
      selectedDoctors.isNotEmpty ||
      selectedFacilities.isNotEmpty ||
      selectedFormats.isNotEmpty;

  // Deep copy
  FilterOptions copy() => FilterOptions(
    sortBy: sortBy,
    dateRange: dateRange,
    selectedDoctors: List.from(selectedDoctors),
    selectedFacilities: List.from(selectedFacilities),
    selectedFormats: List.from(selectedFormats),
  );
}

// ─── Filter Bottom Sheet ───────────────────────────────────────────────────────
class FilterBottomSheet extends StatefulWidget {
  final FilterOptions currentFilters;

  const FilterBottomSheet({super.key, required this.currentFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _filters;

  // Collapsible section states
  bool _sortExpanded = true;
  bool _dateExpanded = true;
  bool _doctorExpanded = false;
  bool _facilityExpanded = false;
  bool _formatExpanded = false;

  // Available options
  final List<String> _sortOptions = ['Newest First', 'Oldest First', 'A-Z'];

  final List<String> _dateOptions = [
    'All Time',
    'Last 30 Days',
    'Last 6 Months',
    'This Year',
  ];

  final List<String> _doctors = [
    'Dr. Smith',
    'Dr. House',
    'Dr. Strange',
    'Dr. Lee',
    'Dr. Banner',
    'Dr. Adams',
    'Dr. Dent',
    'Nurse Joy',
  ];

  final List<String> _facilities = [
    'City General Hospital',
    'Radiology Center',
    'Valley Clinic',
    'Skin Care Center',
    'Advanced Radiology',
    'Central Pharmacy',
    'Smile Dental Clinic',
    'Pulmonology Associates',
  ];

  final List<String> _formats = ['PDF', 'Images (JPG/PNG)', 'Typed Notes'];

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters.copy();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ──────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: Color(0xFF4A90D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Scrollable filter content ────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 1. Sort By
                  _buildCollapsibleSection(
                    title: 'Sort By',
                    icon: Icons.sort,
                    isExpanded: _sortExpanded,
                    onToggle: () =>
                        setState(() => _sortExpanded = !_sortExpanded),
                    child: _buildSortOptions(),
                  ),

                  // 2. Date Range
                  _buildCollapsibleSection(
                    title: 'Date Range',
                    icon: Icons.calendar_today_outlined,
                    isExpanded: _dateExpanded,
                    onToggle: () =>
                        setState(() => _dateExpanded = !_dateExpanded),
                    child: _buildDateOptions(),
                  ),

                  // 3. Doctor / Provider
                  _buildCollapsibleSection(
                    title: 'Doctor / Provider',
                    icon: Icons.person_outline,
                    isExpanded: _doctorExpanded,
                    onToggle: () =>
                        setState(() => _doctorExpanded = !_doctorExpanded),
                    child: _buildCheckList(
                      items: _doctors,
                      selected: _filters.selectedDoctors,
                      onChanged: (val, checked) {
                        setState(() {
                          if (checked) {
                            _filters.selectedDoctors.add(val);
                          } else {
                            _filters.selectedDoctors.remove(val);
                          }
                        });
                      },
                    ),
                  ),

                  // 4. Facility
                  _buildCollapsibleSection(
                    title: 'Facility',
                    icon: Icons.local_hospital_outlined,
                    isExpanded: _facilityExpanded,
                    onToggle: () =>
                        setState(() => _facilityExpanded = !_facilityExpanded),
                    child: _buildCheckList(
                      items: _facilities,
                      selected: _filters.selectedFacilities,
                      onChanged: (val, checked) {
                        setState(() {
                          if (checked) {
                            _filters.selectedFacilities.add(val);
                          } else {
                            _filters.selectedFacilities.remove(val);
                          }
                        });
                      },
                    ),
                  ),

                  // 5. File Format
                  _buildCollapsibleSection(
                    title: 'File Format',
                    icon: Icons.insert_drive_file_outlined,
                    isExpanded: _formatExpanded,
                    onToggle: () =>
                        setState(() => _formatExpanded = !_formatExpanded),
                    child: _buildCheckList(
                      items: _formats,
                      selected: _filters.selectedFormats,
                      onChanged: (val, checked) {
                        setState(() {
                          if (checked) {
                            _filters.selectedFormats.add(val);
                          } else {
                            _filters.selectedFormats.remove(val);
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Sticky Apply Button ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _filters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Collapsible Section ────────────────────────────────────────────
  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF4A90D9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) child,
        const Divider(height: 1),
      ],
    );
  }

  // ── Sort Options (Radio style) ─────────────────────────────────────
  Widget _buildSortOptions() {
    return Column(
      children: _sortOptions.map((option) {
        final isSelected = _filters.sortBy == option;
        return InkWell(
          onTap: () => setState(() => _filters.sortBy = option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A90D9)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4A90D9),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? const Color(0xFF4A90D9)
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Date Range Options (Chip style) ───────────────────────────────
  Widget _buildDateOptions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _dateOptions.map((option) {
          final isSelected = _filters.dateRange == option;
          return GestureDetector(
            onTap: () => setState(() => _filters.dateRange = option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A90D9)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Checklist (Doctors / Facilities / Formats) ─────────────────────
  Widget _buildCheckList({
    required List<String> items,
    required List<String> selected,
    required Function(String, bool) onChanged,
  }) {
    return Column(
      children: items.map((item) {
        final isChecked = selected.contains(item);
        return InkWell(
          onTap: () => onChanged(item, !isChecked),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? const Color(0xFF4A90D9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFF4A90D9)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: isChecked ? const Color(0xFF4A90D9) : Colors.black87,
                    fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _resetAll() {
    setState(() {
      _filters = FilterOptions();
    });
  }
}

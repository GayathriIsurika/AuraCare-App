import 'package:auracare_app/screens/health_directory/doctor_profile_screen.dart';
import 'package:auracare_app/screens/health_directory/hospital_profile_screen.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import '../../constant/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../models/hospital_model.dart';
import '../../widgets/health_directory/search_bar_widget.dart';
import '../../widgets/health_directory/filter_chip_row.dart';
import '../../widgets/health_directory/hospital_card_widget.dart';
import '../../widgets/health_directory/doctor_card_widget.dart';

class HealthDirectoryScreen extends StatefulWidget {
  const HealthDirectoryScreen({super.key});

  @override
  State<HealthDirectoryScreen> createState() => _HealthDirectoryScreenState();
}

class _HealthDirectoryScreenState extends State<HealthDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['Hospitals', 'Doctors', 'Specialists'];

  String _selectedFilter = 'Hospitals';
  String _searchQuery = '';

  // ── Dummy Data (replace with Firestore later) ────────────────────────────

  final List<HospitalModel> _allHospitals = [
    HospitalModel(
      id: '1',
      name: 'City General Hospital',
      address: 'Colombo 02',
      distanceKm: 3.5,
      imageUrl: '',
      phone: '+94112345678',
      about: 'Leading hospital in Colombo.',
    ),
    HospitalModel(
      id: '2',
      name: 'Nawaloka Hospital',
      address: 'Colombo 02',
      distanceKm: 5.1,
      imageUrl: '',
      phone: '+94112345679',
      about: 'Multi-specialty hospital.',
    ),
    HospitalModel(
      id: '3',
      name: 'Lanka Hospital',
      address: 'Colombo 05',
      distanceKm: 6.3,
      imageUrl: '',
      phone: '+94112345680',
      about: 'Modern healthcare facility.',
    ),
    HospitalModel(
      id: '4',
      name: 'Asiri Medical Centre',
      address: 'Colombo 05',
      distanceKm: 7.8,
      imageUrl: '',
      phone: '+94112345681',
      about: 'Advanced medical centre.',
    ),
  ];

  final List<DoctorModel> _allDoctors = [
    DoctorModel(
      id: '1',
      name: 'Dr. Amara Silva',
      specialty: 'Cardiologist',
      hospital: 'Nawaloka Hospital',
      rating: 4.8,
      distanceKm: 3.5,
      imageUrl: '',
      phone: '+94771234567',
      about: 'Expert in cardiac care.',
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Rohan Perera',
      specialty: 'Neurologist',
      hospital: 'Lanka Hospital',
      rating: 4.7,
      distanceKm: 5.2,
      imageUrl: '',
      phone: '+94771234568',
      about: 'Specialist in neurology.',
    ),
    DoctorModel(
      id: '3',
      name: 'Dr. Nadia Fernando',
      specialty: 'Pediatrician',
      hospital: 'Asiri Medical',
      rating: 4.6,
      distanceKm: 6.1,
      imageUrl: '',
      phone: '+94771234569',
      about: 'Child health specialist.',
    ),
    DoctorModel(
      id: '4',
      name: 'Dr. Kasun Jayawardena',
      specialty: 'Orthopedic',
      hospital: 'City General',
      rating: 4.5,
      distanceKm: 4.0,
      imageUrl: '',
      phone: '+94771234570',
      about: 'Bone and joint specialist.',
    ),
  ];

  final List<DoctorModel> _allSpecialists = [
    DoctorModel(
      id: '5',
      name: 'Dr. Priya Mendis',
      specialty: 'Dermatologist',
      hospital: 'Nawaloka Hospital',
      rating: 4.9,
      distanceKm: 3.5,
      imageUrl: '',
      phone: '+94771234571',
      about: 'Skin care specialist.',
    ),
    DoctorModel(
      id: '6',
      name: 'Dr. Saman Bandara',
      specialty: 'Ophthalmologist',
      hospital: 'Lanka Hospital',
      rating: 4.7,
      distanceKm: 6.0,
      imageUrl: '',
      phone: '+94771234572',
      about: 'Eye care specialist.',
    ),
  ];

  // ── Filtered Lists ────────────────────────────────────────────────────────

  List<HospitalModel> get _filteredHospitals {
    if (_searchQuery.isEmpty) return _allHospitals;
    return _allHospitals
        .where(
          (h) =>
              h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              h.address.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<DoctorModel> get _filteredDoctors {
    if (_searchQuery.isEmpty) return _allDoctors;
    return _allDoctors
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.specialty.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<DoctorModel> get _filteredSpecialists {
    if (_searchQuery.isEmpty) return _allSpecialists;
    return _allSpecialists
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.specialty.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          _selectedFilter,
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Search Bar
            SearchBarWidget(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 16),

            // Filter Chips
            FilterChipRow(
              options: _filterOptions,
              selected: _selectedFilter,
              onSelected: (val) => setState(() => _selectedFilter = val),
            ),

            const SizedBox(height: 18),

            // List
            Expanded(child: _buildList()),
          ],
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── List Switcher ─────────────────────────────────────────────────────────

  Widget _buildList() {
    if (_selectedFilter == 'Hospitals') {
      final list = _filteredHospitals;
      if (list.isEmpty) return _emptyState('No hospitals found');
      return ListView.builder(
        itemCount: list.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, i) => HospitalCardWidget(
          hospital: list[i],
          onView: () => _onViewHospital(list[i]),
        ),
      );
    }

    if (_selectedFilter == 'Doctors') {
      final list = _filteredDoctors;
      if (list.isEmpty) return _emptyState('No doctors found');
      return ListView.builder(
        itemCount: list.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, i) => DoctorCardWidget(
          doctor: list[i],
          onView: () => _onViewDoctor(list[i]),
        ),
      );
    }

    // Specialists
    final list = _filteredSpecialists;
    if (list.isEmpty) return _emptyState('No specialists found');
    return ListView.builder(
      itemCount: list.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, i) => DoctorCardWidget(
        doctor: list[i],
        onView: () => _onViewDoctor(list[i]),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: textGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: textGrey, fontSize: 15)),
        ],
      ),
    );
  }

  // ── Navigation Callbacks (Step 4 will fill these) ────────────────────────

  void _onViewHospital(HospitalModel hospital) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalProfileScreen(hospital: hospital),
      ),
    );
  }

  void _onViewDoctor(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doctor)),
    );
  }

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return const BottomNavBar(currentIndex: 0);
  }
}

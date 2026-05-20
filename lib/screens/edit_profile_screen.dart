import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/firebase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final FirebaseService _firebaseService = FirebaseService();

  // ── Controllers ──
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCountryCode = '+94';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;      // save button loading
  bool _isLoadingData = true;   // initial data loading

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadExistingData(); // load existing data when screen opens
  }

  // ── Load existing profile data from Firebase ──
  Future<void> _loadExistingData() async {
    final data = await _firebaseService.getUserProfile();

    if (data != null) {
      setState(() {
        // Fill controllers with existing data
        // Split fullName into first and last
        final nameParts = (data['fullName'] ?? '').split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
        _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _locationController.text = data['location'] ?? '';

        // Fill phone without country code
        final phone = data['phone'] ?? '';
        if (phone.length > 3) {
          _phoneController.text = phone.substring(3); // remove +94
        }

        // Set gender dropdown
        _selectedGender = data['gender']?.isNotEmpty == true
            ? data['gender']
            : null;

        // Parse date string back to DateTime
        if (data['dateOfBirth'] != null && data['dateOfBirth'].toString().isNotEmpty) {
          try {
            final parts = data['dateOfBirth'].split('/');
            if (parts.length == 3) {
              _selectedDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          } catch (_) {}
        }

        _isLoadingData = false;
      });
    } else {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2002, 4, 2),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: buttonStart,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Profile Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: background,
                    child: Icon(Icons.camera_alt, color: buttonStart),
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxWidth: 500,
                    );
                    if (photo != null) {
                      setState(() => _profileImage = File(photo.path));
                    }
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: background,
                    child: Icon(Icons.photo_library, color: buttonStart),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 500,
                    );
                    if (image != null) {
                      setState(() => _profileImage = File(image.path));
                    }
                  },
                ),

                if (_profileImage != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEB),
                      child: Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _profileImage = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Save profile to Firebase ──
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Upload image if new one was picked
      if (_profileImage != null) {
        await _firebaseService.uploadProfileImage(_profileImage!);
      }

      // Step 2: Format date as string
      String dateString = '';
      if (_selectedDate != null) {
        dateString =
        '${_selectedDate!.day.toString().padLeft(2, '0')}/'
            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
            '${_selectedDate!.year}';
      }

      // Step 3: Save all profile fields to Firestore
      String? error = await _firebaseService.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        phone: '$_selectedCountryCode${_phoneController.text.trim()}',
        location: _locationController.text.trim(),
        dateOfBirth: dateString,
        gender: _selectedGender ?? '',
        bloodGroup: '',
      );

      setState(() => _isLoading = false);

      if (error == null) {
        // Success
        if (mounted) {
          Navigator.pop(context); // go back to profile
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: buttonStart,
            ),
          );
        }
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: buttonStart,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // ── Tick button saves profile ──
          IconButton(
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),

      // ── Show loading while fetching existing data ──
      body: _isLoadingData
          ? const Center(
        child: CircularProgressIndicator(color: buttonStart),
      )
          : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [

              // ── Blue header with photo ──
              Container(
                width: double.infinity,
                color: buttonStart,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor:
                          Colors.white.withValues(alpha: 0.3),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Text(
                            'SD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3A9EC2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Form Card ──
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: buttonStart, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildLabel('First Name'),
                    _buildTextField(_firstNameController, 'First Name'),
                    const SizedBox(height: 14),

                    _buildLabel('Last Name'),
                    _buildTextField(_lastNameController, 'Last Name'),
                    const SizedBox(height: 14),

                    _buildLabel('Username'),
                    _buildTextField(_usernameController, 'Username'),
                    const SizedBox(height: 14),

                    _buildLabel('Email'),
                    _buildTextField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Location'),
                    _buildTextField(
                      _locationController,
                      'City / Town',
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Phone Number'),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CountryCodePicker(
                            onChanged: (CountryCode code) {
                              setState(() {
                                _selectedCountryCode = code.dialCode!;
                              });
                            },
                            initialSelection: 'LK',
                            favorite: const ['LK', 'US', 'IN', 'GB'],
                            showFlag: true,
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            _phoneController,
                            'Phone Number',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Birth Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                  '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                  '${_selectedDate!.year}'
                                  : 'Select date',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Gender'),
                    _buildDropdown(
                      value: _selectedGender,
                      hint: 'Gender',
                      items: _genderOptions,
                      onChanged: (val) =>
                          setState(() => _selectedGender = val),
                    ),
                    const SizedBox(height: 28),

                    // ── Save Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonStart,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
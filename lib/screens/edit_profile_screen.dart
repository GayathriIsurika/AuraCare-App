import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:auracare_app/constant/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  // ── Controllers hold the text the user types ──
  final _firstNameController = TextEditingController(text: 'Smith');
  final _lastNameController = TextEditingController(text: 'Disanayaka');
  final _usernameController = TextEditingController(text: 'smith125');
  final _emailController = TextEditingController(text: 'smithdisanayaka125@gmail.com');
  final _phoneController = TextEditingController(text: '717193125');
  String _selectedCountryCode = '+94';
  File? _profileImage; // store the profile image
  final ImagePicker _picker=ImagePicker();
  // ── Dropdown selected values ──
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _selectedDate;

  // ── Dropdown options ──
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroupOptions = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Opens date picker calendar ──
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 4, 2), // default date
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Custom styling for the calendar
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5BB8D4), // header color
              onPrimary: Colors.white,    // header text
              onSurface: Colors.black,    // calendar text
            ),
          ),
          child: child!,
        );
      },

    );
    // If user picked a date, save it
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  // ── Opens bottom sheet to choose Camera or Gallery ──
  Future<void> _pickProfileImage() async {
    // Shows a popup at the bottom with two options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20), // rounded top corners
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // sheet only as tall as content
              children: [

                // Sheet title
                const Text(
                  'Choose Profile Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Camera option
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: background,
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFF5BB8D4),
                    ),
                  ),
                  title: const Text('Take a Photo'),   // opens camera
                  onTap: () async {
                    Navigator.pop(context); // close the bottom sheet first

                    // Opens camera
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,  // ← use camera
                      imageQuality: 80,            // compress to 80% quality
                      maxWidth: 500,               // resize to max 500px wide
                    );

                    // If user took a photo (didn't cancel)
                    if (photo != null) {
                      setState(() {
                        _profileImage = File(photo.path); // save the file
                      });
                    }
                  },
                ),

                // Gallery option
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: background,
                    child: Icon(
                      Icons.photo_library,
                      color: Color(0xFF5BB8D4),
                    ),
                  ),
                  title: const Text('Choose from Gallery'), // opens gallery
                  onTap: () async {
                    Navigator.pop(context); // close the bottom sheet first

                    // Opens photo gallery
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery, // ← use gallery
                      imageQuality: 80,
                      maxWidth: 500,
                    );

                    // If user picked an image (didn't cancel)
                    if (image != null) {
                      setState(() {
                        _profileImage = File(image.path); // save the file
                      });
                    }
                  },
                ),

                // Remove photo option (only shows if photo is already set)
                if (_profileImage != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEB),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _profileImage = null; // clears the image
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ── AppBar with back, title, save tick ──
      appBar: AppBar(
        backgroundColor: buttonStart,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // go back to Profile
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Tick/checkmark saves the profile
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // TODO: Save to database/backend
              // For now just go back
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile saved!'),
                  backgroundColor:background,
                ),
              );
            },
          ),
        ],
      ),

      body: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [

              // ── Blue header with profile photo ──
// ── Blue header with profile photo ──
              Container(
                width: double.infinity,
                color: const Color(0xFF5BB8D4),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      children: [

                        // ── Profile photo circle ──
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),

                          // Shows picked image OR initials if no image
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!) // ← shows the picked image
                              : null,                     // ← null means show child instead

                          child: _profileImage == null
                              ? const Text(              // ← shows 'SD' only if no image
                            'SD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,                    // ← null hides text when image shown
                        ),

                        // ── Camera icon button ──
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage, // ← tapping opens the bottom sheet
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3A9EC2),  // darker blue circle
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

              // ── White form card ──
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5BB8D4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // First Name field
                    _buildLabel('First Name'),
                    _buildTextField(_firstNameController, 'First Name'),

                    const SizedBox(height: 14),

                    // Last Name field
                    _buildLabel('Last Name'),
                    _buildTextField(_lastNameController, 'Last Name'),

                    const SizedBox(height: 14),

                    // Username field
                    _buildLabel('Username'),
                    _buildTextField(_usernameController, 'Username'),

                    const SizedBox(height: 14),

                    // Email field
                    _buildLabel('Email'),
                    _buildTextField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    // Phone number with country code
                    _buildLabel('Phone Number'),
                    Row(
                      children: [

                        // ── Country Code Picker ──
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),   // same grey background as text fields
                            borderRadius: BorderRadius.circular(10), // rounded corners
                          ),
                          child: CountryCodePicker(
                            onChanged: (CountryCode code) {
                              // This runs every time user picks a country
                              // code.dialCode gives the number like "+94", "+1", "+44"
                              setState(() {
                                _selectedCountryCode = code.dialCode!; // saves selected code
                              });
                            },

                            initialSelection: 'LK',   // LK = Sri Lanka, shows +94 by default
                            // Use 'US' for USA, 'IN' for India etc.

                            favorite: const ['LK', 'US', 'IN', 'GB'],
                            // ↑ these countries appear at TOP of the list for quick access

                            showFlag: true,            // shows the country flag icon
                            showCountryOnly: false,    // shows code like +94 not just country name
                            showOnlyCountryWhenClosed: false, // shows +94 when dropdown is closed
                            alignLeft: false,          // flag and code centered

                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,   // text color of the code shown
                            ),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,           // space inside the container
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),    // space between code picker and phone field

                        // ── Phone Number Text Field ──
                        Expanded(                      // takes remaining width on the row
                          child: _buildTextField(
                            _phoneController,
                            'Phone Number',
                            keyboardType: TextInputType.phone, // shows number keyboard
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 14),

                    // Birth date picker
                    _buildLabel('Birth'),
                    GestureDetector(
                      onTap: _pickDate, // opens calendar
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // Show selected date or placeholder
                              _selectedDate != null
                                  ? '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                  '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                  '${_selectedDate!.year}'
                                  : 'Birth',
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

                    // Gender dropdown
                    _buildLabel('Gender'),
                    _buildDropdown(
                      value: _selectedGender,
                      hint: 'Gender',
                      items: _genderOptions,
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),

                    const SizedBox(height: 14),

                    // Blood Group dropdown
                    _buildLabel('Blood Group'),
                    _buildDropdown(
                      value: _selectedBloodGroup,
                      hint: 'Blood Group',
                      items: _bloodGroupOptions,
                      onChanged: (val) =>
                          setState(() => _selectedBloodGroup = val),
                    ),

                    const SizedBox(height: 28),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final fullPhone = '$_selectedCountryCode${_phoneController.text}';
                          print('Full phone: $fullPhone');
                          // TODO: Save to backend
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile saved!'),
                              backgroundColor: Color(0xFF5BB8D4),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5BB8D4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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

  // ── Helper: field label text ──
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ── Helper: text input field ──
  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,       // connects to the controller above
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // no visible border line
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  // ── Helper: dropdown selector ──
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
          isExpanded: true,         // fills the full width
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,     // updates state when user picks
        ),
      ),
    );
  }
}
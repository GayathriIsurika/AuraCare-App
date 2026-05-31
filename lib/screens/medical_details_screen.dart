import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/services/firebase_service.dart';

class MedicalDetailsScreen extends StatefulWidget {
  const MedicalDetailsScreen({super.key});

  @override
  State<MedicalDetailsScreen> createState() => _MedicalDetailsScreenState();
}

class _MedicalDetailsScreenState extends State<MedicalDetailsScreen> {

  final FirebaseService _firebaseService = FirebaseService();

  // Stored medical data
  String bloodType = 'O+';
  double weight = 70;
  double height = 175;
  List<String> allergies = [];
  List<String> conditions = [];
  List<String> healthEvents = [];
  bool isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _newAllergyController;
  late TextEditingController _newConditionController;
  late TextEditingController _newEventController;

  // BMI calculation
  // Formula: weight(kg) / height(m)^2
  double get bmi {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get bmiColor {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: weight.toString());
    _heightController = TextEditingController(text: height.toString());
    _newAllergyController = TextEditingController();
    _newConditionController = TextEditingController();
    _newEventController = TextEditingController();
    _loadMedicalData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _newAllergyController.dispose();
    _newConditionController.dispose();
    _newEventController.dispose();
    super.dispose();
  }

  // Load existing medical data from Firebase
  Future<void> _loadMedicalData() async {
    setState(() => _isLoading = true);

    final data = await _firebaseService.getMedicalDetails();

    if (data != null && mounted) {
      setState(() {
        bloodType = data['bloodType'] ?? 'O+';
        weight = (data['weight'] ?? 70).toDouble();
        height = (data['height'] ?? 175).toDouble();

        allergies = List<String>.from(data['allergies'] ?? []);
        conditions = List<String>.from(data['conditions'] ?? []);
        healthEvents = List<String>.from(data['healthEvents'] ?? []);


        _weightController.text = weight.toString();
        _heightController.text = height.toString();

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  //  Save medical data to Firebase
  Future<void> _saveMedicalData() async {
    setState(() => _isSaving = true);

    // Save weight and height from controllers
    weight = double.tryParse(_weightController.text) ?? weight;
    height = double.tryParse(_heightController.text) ?? height;

    // Call Firebase save
    String? error = await _firebaseService.saveMedicalDetails(
      bloodType: bloodType,
      weight: weight,
      height: height,
      allergies: allergies,
      conditions: conditions,
      healthEvents: healthEvents,
    );

    setState(() {
      _isSaving = false;
      isEditing = false;
    });

    if (mounted) {
      if (error == null) {
        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical details saved!'),
            backgroundColor: buttonStart,
          ),
        );
      } else {
        // Error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
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
      appBar: AppBar(
        backgroundColor: buttonStart,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Medical Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [

          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
              : TextButton(
            onPressed: () {
              if (isEditing) {
                _saveMedicalData(); // save to Firebase when done
              } else {
                setState(() => isEditing = true); // enter edit mode
              }
            },
            child: Text(
              isEditing ? 'Save' : 'Edit', // changed Done to Save
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      // Show loading spinner while data loads
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: buttonStart,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //  Blood Type , BMI
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.water_drop_rounded,
                    iconColor: Colors.red,
                    iconBg: const Color(0xFFFFEBEE),
                    title: 'Blood Type',
                    value: bloodType,
                    isEditing: isEditing,
                    onEdit: () => _showBloodTypeDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildBMICard()),
              ],
            ),

            const SizedBox(height: 12),

            // Weight , Height
            Row(
              children: [
                Expanded(
                  child: _buildMeasurementCard(
                    icon: Icons.monitor_weight_outlined,
                    iconColor: Colors.purple,
                    iconBg: const Color(0xFFF3E5F5),
                    title: 'Weight',
                    controller: _weightController,
                    unit: 'kg',
                    isEditing: isEditing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementCard(
                    icon: Icons.height_rounded,
                    iconColor: Colors.teal,
                    iconBg: const Color(0xFFE0F2F1),
                    title: 'Height',
                    controller: _heightController,
                    unit: 'cm',
                    isEditing: isEditing,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            //  Allergies
            _buildSectionTitle(
              'Allergies',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildChipSection(
              items: allergies,
              chipColor: const Color(0xFFFFF3E0),
              textColor: Colors.orange,
              borderColor: Colors.orange.shade200,
              onRemove: isEditing
                  ? (item) => setState(() => allergies.remove(item))
                  : null,
            ),
            if (isEditing) ...[
              const SizedBox(height: 8),
              _buildAddItemRow(
                controller: _newAllergyController,
                hint: 'Add allergy...',
                onAdd: () {
                  if (_newAllergyController.text.trim().isNotEmpty) {
                    setState(() {
                      allergies.add(_newAllergyController.text.trim());
                      _newAllergyController.clear();
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // Medical Conditions
            _buildSectionTitle(
              'Medical Conditions',
              Icons.medical_services_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildChipSection(
              items: conditions,
              chipColor: const Color(0xFFE3F2FD),
              textColor: Colors.blue,
              borderColor: Colors.blue.shade200,
              onRemove: isEditing
                  ? (item) => setState(() => conditions.remove(item))
                  : null,
            ),
            if (isEditing) ...[
              const SizedBox(height: 8),
              _buildAddItemRow(
                controller: _newConditionController,
                hint: 'Add condition...',
                onAdd: () {
                  if (_newConditionController.text.trim().isNotEmpty) {
                    setState(() {
                      conditions
                          .add(_newConditionController.text.trim());
                      _newConditionController.clear();
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // Health Events
            _buildSectionTitle(
              'Significant Health Events',
              Icons.event_note_outlined,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            ...healthEvents.asMap().entries.map((entry) {
              return _buildEventCard(entry.value, entry.key);
            }),
            if (isEditing) ...[
              const SizedBox(height: 8),
              _buildAddItemRow(
                controller: _newEventController,
                hint: 'Add health event...',
                onAdd: () {
                  if (_newEventController.text.trim().isNotEmpty) {
                    setState(() {
                      healthEvents
                          .add(_newEventController.text.trim());
                      _newEventController.clear();
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Stat Card
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required bool isEditing,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isEditing)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // BMI Card
  Widget _buildBMICard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bmiColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.monitor_heart_outlined,
              color: bmiColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'BMI',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            bmi.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bmiColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              bmiCategory,
              style: TextStyle(
                fontSize: 11,
                color: bmiColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Measurement Card
  Widget _buildMeasurementCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required TextEditingController controller,
    required String unit,
    required bool isEditing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffix: Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Chip Section
  Widget _buildChipSection({
    required List<String> items,
    required Color chipColor,
    required Color textColor,
    required Color borderColor,
    Function(String)? onRemove,
  }) {
    if (items.isEmpty) {
      return Text(
        'None added',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onRemove(item),
                  child: Icon(Icons.close, size: 14, color: textColor),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // Event Card
  Widget _buildEventCard(String event, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: buttonStart,
                  shape: BoxShape.circle,
                ),
              ),
              if (index < healthEvents.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isEditing)
                    GestureDetector(
                      onTap: () {
                        setState(() => healthEvents.remove(event));
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add Item Row
  Widget _buildAddItemRow({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buttonStart,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // Blood Type Dialog
  void _showBloodTypeDialog() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Blood Type'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bloodTypes.map((type) {
              final isSelected = type == bloodType;
              return GestureDetector(
                onTap: () {
                  setState(() => bloodType = type);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? buttonStart : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? buttonStart
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
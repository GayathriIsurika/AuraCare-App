import 'package:flutter/material.dart';
import 'package:auracare_app/constant/app_colors.dart';

class MedicalDetailsScreen extends StatefulWidget {
  const MedicalDetailsScreen({super.key});

  @override
  State<MedicalDetailsScreen> createState() => _MedicalDetailsScreenState();
}

class _MedicalDetailsScreenState extends State<MedicalDetailsScreen> {

  // ── Stored medical data ──
  // These will be filled when user edits
  String bloodType = 'O+';
  double weight = 70;           // kg
  double height = 175;          // cm
  List<String> allergies = ['Penicillin', 'Peanuts'];
  List<String> conditions = ['Diabetes Type 2', 'Asthma'];
  List<String> healthEvents = ['Appendectomy - 2019'];
  bool isEditing = false;       // toggles between view and edit mode

  // ── Controllers for editing ──
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _newAllergyController;
  late TextEditingController _newConditionController;
  late TextEditingController _newEventController;

  // ── BMI calculation ──
  // Formula: weight(kg) / height(m)^2
  double get bmi {
    double heightInMeters = height / 100; // convert cm to meters
    return weight / (heightInMeters * heightInMeters);
  }

  // ── BMI category based on value ──
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // ── BMI color based on category ──
  Color get bmiColor {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    _weightController = TextEditingController(text: weight.toString());
    _heightController = TextEditingController(text: height.toString());
    _newAllergyController = TextEditingController();
    _newConditionController = TextEditingController();
    _newEventController = TextEditingController();
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
          // Edit / Done toggle button
          TextButton(
            onPressed: () {
              setState(() {
                if (isEditing) {
                  // Save values when done
                  weight = double.tryParse(_weightController.text) ?? weight;
                  height = double.tryParse(_heightController.text) ?? height;
                }
                isEditing = !isEditing; // toggle mode
              });
            },
            child: Text(
              isEditing ? 'Done' : 'Edit',   // changes label based on mode
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Row 1: Blood Type + BMI Cards ──
            Row(
              children: [

                // Blood Type Card
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

                // BMI Card (auto calculated)
                Expanded(
                  child: _buildBMICard(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Row 2: Weight + Height Cards ──
            Row(
              children: [

                // Weight Card
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

                // Height Card
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

            // ── Allergies Section ──
            _buildSectionTitle('Allergies', Icons.warning_amber_rounded, Colors.orange),
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

            // Add allergy input (only in edit mode)
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

            // ── Medical Conditions Section ──
            _buildSectionTitle('Medical Conditions', Icons.medical_services_outlined, Colors.blue),
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
                      conditions.add(_newConditionController.text.trim());
                      _newConditionController.clear();
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // ── Health Events Section ──
            _buildSectionTitle('Significant Health Events', Icons.event_note_outlined, Colors.purple),
            const SizedBox(height: 12),

            // Health events shown as timeline cards
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
                      healthEvents.add(_newEventController.text.trim());
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

  // ── Stat Card (Blood Type) ──
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
          // Icon circle
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
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
              // Show edit icon only in edit mode
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

  // ── BMI Card (special card with color indicator) ──
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
          // Icon circle
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
            bmi.toStringAsFixed(1),   // shows like "22.4"
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          // BMI category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  // ── Measurement Card (Weight / Height) ──
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

          // Shows text field in edit mode, plain text in view mode
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
              border: InputBorder.none, // no border box
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

  // ── Section Title with icon ──
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

  // ── Chips for Allergies and Conditions ──
  Widget _buildChipSection({
    required List<String> items,
    required Color chipColor,
    required Color textColor,
    required Color borderColor,
    Function(String)? onRemove,   // null means not editable
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // shrink to content width
            children: [
              Text(
                item,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Show X remove button only in edit mode
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

  // ── Timeline Event Card ──
  Widget _buildEventCard(String event, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
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
          // Event card
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
                  Text(
                    event,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  // Remove button in edit mode
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

  // ── Add Item Row (text field + add button) ──
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
        // Add button
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

  // ── Blood Type Picker Dialog ──
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
                  setState(() => bloodType = type); // update selected
                  Navigator.pop(context);            // close dialog
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
                      color: isSelected ? buttonStart : Colors.grey.shade300,
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
import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const List<FaIconData> _contactIcons = [
  FontAwesomeIcons.ambulance,
  FontAwesomeIcons.userDoctor,
  FontAwesomeIcons.userNurse,
  FontAwesomeIcons.house,
  FontAwesomeIcons.person,
  FontAwesomeIcons.heartPulse,
  FontAwesomeIcons.hospital,
  FontAwesomeIcons.pills,
  FontAwesomeIcons.phone,
  FontAwesomeIcons.star,
];

class ContactSheet extends StatefulWidget {
  final ContactModel? existing;
  final Function(String name, String phone, FaIconData icon) onSave;

  const ContactSheet({super.key, this.existing, required this.onSave});

  // ── Call this from anywhere to open the sheet ──
  static void show(
    BuildContext context, {
    ContactModel? existing,
    required Function(String name, String phone, FaIconData icon) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactSheet(existing: existing, onSave: onSave),
    );
  }

  @override
  State<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<ContactSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late FaIconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _phoneCtrl = TextEditingController(
      text: widget.existing?.phoneNumber ?? '',
    );
    _selectedIcon = widget.existing?.icon ?? _contactIcons.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle bar ──
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // ── Title ──
            Text(
              widget.existing == null ? 'Add Contact' : 'Edit Contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            SizedBox(height: 20),

            // ── Icon picker label ──
            Text(
              'Select Icon',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),

            // ── Icon picker row ──
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _contactIcons.length,
                separatorBuilder: (_, __) => SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final icon = _contactIcons[i];
                  final isSelected = _selectedIcon == icon;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: FaIcon(
                          icon,
                          size: 20,
                          color: isSelected ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18),

            // ── Name field ──
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 14),

            // ── Phone field ──
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),

            // ── Save button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  final phone = _phoneCtrl.text.trim();

                  if (name.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  widget.onSave(name, phone, _selectedIcon);
                  Navigator.pop(context);
                },
                child: Text(
                  widget.existing == null ? 'Add Contact' : 'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

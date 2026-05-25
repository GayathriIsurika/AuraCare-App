import 'package:auracare_app/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onCall;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onCall,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(contact.id),

      // ── Swipe RIGHT → Edit (green, left side) ──
      background: _buildSwipeBackground(
        color: Colors.green,
        icon: Icons.edit,
        label: 'Edit',
        alignment: Alignment.centerLeft,
      ),

      // ── Swipe LEFT → Delete (red, right side) ──
      secondaryBackground: _buildSwipeBackground(
        color: Colors.red,
        icon: Icons.delete,
        label: 'Delete',
        alignment: Alignment.centerRight,
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swiped left → show confirm dialog
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Delete Contact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to remove "${contact.name}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );

          // Only delete if user tapped Yes
          if (confirm == true) onDelete();
        } else {
          // Swiped right → Edit
          onEdit();
        }
        return false;
      },

      // ── The actual card ──
      child: Card(
        margin: EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child: FaIcon(contact.icon, color: Colors.blue),
          ),
          title: Text(
            contact.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(contact.phoneNumber),
          trailing: GestureDetector(
            onTap: onCall,
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: FaIcon(FontAwesomeIcons.phone, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: builds the colored background shown while swiping ──
  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

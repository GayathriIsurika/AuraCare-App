import 'package:auracare_app/constant/app_colors.dart';
import 'package:auracare_app/models/contact_model.dart';
import 'package:auracare_app/widgets/bottom_nav_bar.dart';
import 'package:auracare_app/widgets/contact_card.dart';
import 'package:auracare_app/widgets/sos_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmergencySosScreen extends StatelessWidget {
  final List<ContactModel> contacts = [
    ContactModel(
      name: 'Emergency Services',
      phoneNumber: '1990',
      icon: FontAwesomeIcons.ambulance,
    ),
    ContactModel(
      name: 'Dr. Kusal Perera',
      phoneNumber: '071 234 5678',
      icon: FontAwesomeIcons.userDoctor,
    ),
    ContactModel(
      name: 'Home',
      phoneNumber: '036 234 5687',
      icon: FontAwesomeIcons.home,
    ),
  ];

  EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5DADE2), Color(0xFF72C6D5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      "Emergency SOS",
                      style: TextStyle(
                        color: textLight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFE5FAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      const SizedBox(height: 60),
                      SosButton(
                        onPressed: () {
                          // Handle SOS button press
                        },
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Emergency Contacts",
                              style: TextStyle(
                                color: textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            ContactCard(
                              contact: ContactModel(
                                name: "Emergency servise",
                                phoneNumber: "1990",
                                icon: FontAwesomeIcons.ambulance,
                              ),
                              onCall: () {
                                // Handle call action
                              },
                            ),

                            SizedBox(height: 15),
                            ContactCard(
                              contact: ContactModel(
                                name: "Dr. Kusal Perera",
                                phoneNumber: "071 234 5678",
                                icon: FontAwesomeIcons.userDoctor,
                              ),
                              onCall: () {
                                // Handle call action
                              },
                            ),
                            SizedBox(height: 15),
                            ContactCard(
                              contact: ContactModel(
                                name: "Home",
                                phoneNumber: "036 234 5687",
                                icon: FontAwesomeIcons.home,
                              ),
                              onCall: () {
                                // Handle call action
                              },
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: null),
    );
  }
}

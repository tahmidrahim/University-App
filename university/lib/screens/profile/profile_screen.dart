import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  User? get user => FirebaseAuth.instance.currentUser;

  String getSafeUid() {
    final uid = user?.uid;
    if (uid == null || uid.isEmpty) return 'N/A';
    return uid.length >= 8 ? uid.substring(0, 8) : uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // HEADER
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade800, Colors.blue.shade500],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 50),

                    // PROFILE IMAGE
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: (user?.photoURL?.isNotEmpty ?? false)
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child:
                            (user?.photoURL == null || user!.photoURL!.isEmpty)
                            ? Icon(
                                Icons.person_rounded,
                                size: 65,
                                color: Colors.blue.shade700,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      user?.displayName ?? 'Guest Student',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    Text(
                      user?.email ?? 'Not logged in',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildCard(
                    title: 'Academic Profile',
                    icon: Icons.school,
                    items: [
                      {'label': 'Year', 'value': '1st Year'},
                      {'label': 'Semester', 'value': '2nd Semester'},
                      {'label': 'Section', 'value': 'C'},
                      {'label': 'Department', 'value': 'Computer Science'},
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildCard(
                    title: 'Account Details',
                    icon: Icons.person,
                    items: [
                      {'label': 'Login Method', 'value': 'Firebase Auth'},
                      {'label': 'UID', 'value': getSafeUid()},
                    ],
                  ),

                  const SizedBox(height: 30),

                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.red.shade50,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['label']!),
                      Text(
                        item['value']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

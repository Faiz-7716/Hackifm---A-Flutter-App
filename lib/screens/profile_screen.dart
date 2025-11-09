
import 'package:flutter/material.dart';
import 'package:hackifm/widgets/app_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF05060A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, size: 50, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Student Name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'student.email@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            const Text(
              'Saved Opportunities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'No saved opportunities yet.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white70),
              label: const Text('Edit Profile', style: TextStyle(color: Colors.white70)),
              onPressed: () { /* Placeholder */ },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            NeonButton(
              label: 'Logout',
              onPressed: () {
                // Navigate to login screen and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

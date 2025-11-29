import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignedInScreen extends StatelessWidget {
  const SignedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: FutureBuilder<String?>(
          future: AuthService().getCurrentUserRole(),
          builder: (context, snapshot) {
            final role = snapshot.data ?? 'user';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You signed in as ${user?.displayName ?? user?.email ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: $role',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    // Try to return to the app's root route. If the route stack
                    // was replaced earlier, this will at least pop to first.
                    if (!context.mounted) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Sign out'),
                ),
                const SizedBox(height: 8),
                if (role == 'admin')
                  ElevatedButton(
                    onPressed: () {
                      // placeholder admin action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Admin feature')),
                      );
                    },
                    child: const Text('Admin action'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

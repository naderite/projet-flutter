import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../config/routes.dart';
import '../collect_age_dialog.dart';

class GoogleButton extends StatefulWidget {
  final bool isSignIn;
  const GoogleButton({super.key, required this.isSignIn});

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _loading = false;

  Future<void> _handleSignIn() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      // Use AuthService to handle Google sign-in and Firestore user creation
      await AuthService().signInWithGoogle();

      // If the user document doesn't have an age, prompt for it and save.
      if (!mounted) return;
      final currentAge = await AuthService().getCurrentUserAge();
      if (currentAge == null) {
        if (!mounted) return;
        final provided = await showDialog<int?>(
          context: context,
          builder: (_) => const CollectAgeDialog(),
        );

        if (provided == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Age is required to continue')),
          );
          return;
        }

        try {
          await AuthService().setUserAge(provided);
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Failed to save age: $e')),
          );
          return;
        }
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('Signed in with Google')),
      );

      // Navigate to the role-based router which will redirect to admin/user home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.roleGate);
      }
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.message ?? 'Auth error')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _loading ? null : _handleSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: _loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  widget.isSignIn
                      ? 'sign in with google'
                      : 'sign up with google',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
    );
  }
}

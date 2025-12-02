import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart' show navigatorKey;
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'widget/input_field.dart';
import 'widget/google_button.dart';
import '../../config/routes.dart';

/// The authentication screen that handles both Sign In and Sign Up flows.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  bool _isLoading = false;
  bool _passwordsMatch = true;
  bool _confirmTouched = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(() {
      setState(() {
        _confirmTouched = _confirmPasswordController.text.isNotEmpty;
      });
      _validatePasswords();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    final match = _passwordController.text == _confirmPasswordController.text;
    if (match != _passwordsMatch) {
      setState(() => _passwordsMatch = match);
    }
  }

  void _toggleAuthMode() {
    setState(() => _isSignIn = !_isSignIn);
  }

  bool get _canSubmit {
    if (_isLoading) return false;
    if (_isSignIn) return true;

    final ageText = _ageController.text.trim();
    final ageVal = int.tryParse(ageText);

    return _nameController.text.trim().isNotEmpty &&
        ageText.isNotEmpty &&
        ageVal != null &&
        ageVal > 0 &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordsMatch;
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      if (_isSignIn) {
        await _signIn();
      } else {
        await _signUp();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Auth error');
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    _showSnackBar('Signed in');
    _navigateToSignedIn();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);

    // Validation
    if (name.isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please enter and confirm your password');
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }
    if (age == null || age <= 0) {
      _showSnackBar('Please enter a valid age');
      return;
    }

    await AuthService().registerWithEmail(
      email: _emailController.text.trim(),
      password: password,
      displayName: name,
      age: age,
    );
    _showSnackBar('Account created');
    _navigateToSignedIn();
  }

  void _showSnackBar(String message) {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _navigateToSignedIn() {
    navigatorKey.currentState?.pushReplacementNamed(AppRoutes.roleGate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        GoogleButton(isSignIn: _isSignIn),
                        const Spacer(),
                        _buildToggleAuthMode(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      _isSignIn ? 'Sign In' : 'Sign Up',
      style: AppTextStyles.heading,
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (!_isSignIn) ...[
          InputField(hint: 'Name', controller: _nameController),
          const SizedBox(height: 16),
          InputField(
            hint: 'Age',
            controller: _ageController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
        ],
        InputField(hint: 'E-mail', controller: _emailController),
        const SizedBox(height: 16),
        InputField(
          hint: 'Password',
          controller: _passwordController,
          obscure: true,
        ),
        if (!_isSignIn) ...[
          const SizedBox(height: 16),
          InputField(
            hint: 'Confirm Password',
            controller: _confirmPasswordController,
            obscure: true,
          ),
          if (_confirmTouched && !_passwordsMatch)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Passwords do not match',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canSubmit ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isSignIn ? 'Sign in' : 'Sign up',
                style: AppTextStyles.button,
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('or', style: TextStyle(color: Colors.white70)),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildToggleAuthMode() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isSignIn
                  ? "Don't you have an account? "
                  : 'Already have an account? ',
              style: AppTextStyles.subtitle,
            ),
            GestureDetector(
              onTap: _toggleAuthMode,
              child: Text(
                _isSignIn ? 'Sign Up' : 'Sign In',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

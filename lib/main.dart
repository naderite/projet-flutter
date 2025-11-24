import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'screens/auth/widget/input_field.dart';
import 'screens/auth/widget/google_button.dart';
import 'screens/auth/signed_in_screen.dart';

// Global navigator key to allow navigation/snackbars safely from async callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App',
      navigatorKey: navigatorKey,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppColors.bg),
      home: const SplashLoader(),
    );
  }
}

/// SplashLoader shows an animated GIF (assets/splash.gif) while Firebase
/// initializes, then shows the main `AuthScreen`. Keep the GIF file in
/// `assets/splash.gif` to have it animate. Native launch screen will show
/// the solid background until Flutter draws the first frame.
class SplashLoader extends StatefulWidget {
  const SplashLoader({super.key});

  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Show the splash for at least a short duration so the GIF is visible.
    // Increase delay so the GIF is visible longer and we avoid a quick flash.
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // If initialize fails, we still proceed to show the app and surface errors
      // via the AuthScreen's UI. Don't block forever.
    }
    await minDelay;
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const AuthScreen();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/splash.gif',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool passwordsMatch = true;
  bool confirmTouched = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    password.addListener(_validatePasswords);
    confirmPassword.addListener(() {
      setState(() {
        confirmTouched = confirmPassword.text.isNotEmpty;
      });
      _validatePasswords();
    });
  }

  void _validatePasswords() {
    final match = password.text == confirmPassword.text;
    if (match != passwordsMatch) {
      setState(() => passwordsMatch = match);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    nameController.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                isSignIn ? 'Sign In' : 'Sign Up',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 32),
              if (!isSignIn) ...[
                InputField(hint: 'Name', controller: nameController),
                const SizedBox(height: 16),
              ],
              InputField(hint: 'E-mail', controller: email),
              const SizedBox(height: 16),
              InputField(hint: 'Password', controller: password, obscure: true),
              if (!isSignIn) ...[
                const SizedBox(height: 16),
                InputField(
                  hint: 'Confirm Password',
                  controller: confirmPassword,
                  obscure: true,
                ),
                if (confirmTouched && !passwordsMatch)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Passwords do not match',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    final canSubmit =
                        !isLoading &&
                        (isSignIn ||
                            (nameController.text.trim().isNotEmpty &&
                                password.text.isNotEmpty &&
                                confirmPassword.text.isNotEmpty &&
                                passwordsMatch));

                    return ElevatedButton(
                      onPressed: canSubmit
                          ? () async {
                              setState(() => isLoading = true);
                              try {
                                if (isSignIn) {
                                  // Sign in with Firebase
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                        email: email.text.trim(),
                                        password: password.text,
                                      );
                                  if (navigatorKey.currentContext != null) {
                                    ScaffoldMessenger.of(
                                      navigatorKey.currentContext!,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text('Signed in'),
                                      ),
                                    );
                                  }
                                  navigatorKey.currentState?.pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const SignedInScreen(),
                                    ),
                                  );
                                  return;
                                }

                                // Sign up
                                final name = nameController.text.trim();
                                final pw = password.text;
                                final pw2 = confirmPassword.text;

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter your name'),
                                    ),
                                  );
                                  return;
                                }
                                if (pw.isEmpty || pw2.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter and confirm your password',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (pw != pw2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Passwords do not match'),
                                    ),
                                  );
                                  return;
                                }

                                final cred = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                      email: email.text.trim(),
                                      password: pw,
                                    );
                                // update display name if available
                                await cred.user?.updateDisplayName(name);
                                if (navigatorKey.currentContext != null) {
                                  ScaffoldMessenger.of(
                                    navigatorKey.currentContext!,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Account created'),
                                    ),
                                  );
                                }
                                navigatorKey.currentState?.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const SignedInScreen(),
                                  ),
                                );
                              } on FirebaseAuthException catch (e) {
                                if (navigatorKey.currentContext != null) {
                                  ScaffoldMessenger.of(
                                    navigatorKey.currentContext!,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(e.message ?? 'Auth error'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (navigatorKey.currentContext != null) {
                                  ScaffoldMessenger.of(
                                    navigatorKey.currentContext!,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('Unexpected error: $e'),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => isLoading = false);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isSignIn ? 'Sign in' : 'Sign up',
                              style: AppTextStyles.button,
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('or', style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 24),
              GoogleButton(isSignIn: isSignIn),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSignIn
                            ? "Don't you have an account? "
                            : 'Already have an account? ',
                        style: AppTextStyles.subtitle,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => isSignIn = !isSignIn),
                        child: Text(
                          isSignIn ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

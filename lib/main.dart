import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'config/routes.dart';

/// Global navigator key to allow navigation/snackbars safely from async callbacks.
/// Import this from other files when you need to navigate or show snackbars
/// outside of a widget's BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root application widget.
///
/// Configuration is kept minimal here. Theme, routes, and other settings
/// are organized into separate files for maintainability.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppColors.bg),
      initialRoute: AppRoutes.initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

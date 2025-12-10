import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/role/role_gate.dart';
import '../screens/admin/admin_root_page.dart';
import '../screens/home/user_home.dart';

/// Centralized route names for the application.
/// Using named routes makes navigation cleaner and easier to maintain.
abstract class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String roleGate = '/role-gate';
  static const String adminHome = '/admin-home';
  static const String userHome = '/user-home';
  static const String signedIn = '/signed-in';

  /// Route generator for MaterialApp.onGenerateRoute
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case roleGate:
        return MaterialPageRoute(builder: (_) => const RoleGate());
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminRootPage());
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserHome());
      case signedIn:
        // kept for backward compatibility — consider removing once callers updated
        return MaterialPageRoute(builder: (_) => const UserHome());
      default:
        return null;
    }
  }

  /// Initial route for the app
  static const String initialRoute = splash;
}

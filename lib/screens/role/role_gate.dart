import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

/// RoleGate decides where to send the user after authentication based on
/// the role stored in Firestore (e.g. 'admin' or 'user').
class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _routeByRole();
  }

  Future<void> _routeByRole() async {
    final role = await AuthService().getCurrentUserRole();
    if (!mounted) return;
    if (_navigated) return;
    _navigated = true;

    if (role == 'admin') {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminHome);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.userHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

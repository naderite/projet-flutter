import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final int age;
  final String email;
  final bool isActive;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.email,
    required this.isActive,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  Future<void> _setActive(bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'isActive': value});

      setState(() {
        _isActive = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'User activated' : 'User deactivated',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[700],
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 2,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('FirstName:', widget.firstName),
                  const SizedBox(height: 8),
                  _buildInfoRow('LastName:', widget.lastName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Age:', widget.age.toString()),
                  const SizedBox(height: 8),
                  _buildInfoRow('email:', widget.email),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Status:',
                    _isActive ? 'Active' : 'Disabled',
                    valueColor:
                    _isActive ? Colors.green : Colors.redAccent,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  // deactivate
                  Expanded(
                    child: InkWell(
                      onTap: _isActive
                          ? () {
                        _setActive(false);
                      }
                          : null,
                      child: Opacity(
                        opacity: _isActive ? 1 : 0.4,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE50914),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'deactivate',
                            style: TextStyle(
                              color: Color(0xFFE50914),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // activate
                  Expanded(
                    child: InkWell(
                      onTap: !_isActive
                          ? () {
                        _setActive(true);
                      }
                          : null,
                      child: Opacity(
                        opacity: !_isActive ? 1 : 0.4,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'activate',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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

  Widget _buildInfoRow(String label, String value,
      {Color valueColor = Colors.white}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }


}

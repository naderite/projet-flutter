import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_detail_page.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C23),
        elevation: 0,
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchField(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading users',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                final users = docs
                    .map(
                      (doc) => AppUser.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                    .where((user) {
                  if (_query.isEmpty) return true;
                  final q = _query.toLowerCase();
                  return user.displayName.toLowerCase().contains(q) ||
                      user.email.toLowerCase().contains(q);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailPage(
                              userId: user.id,
                              firstName: user.firstName,
                              lastName: user.lastName,
                              age: user.age,
                              email: user.email,
                              isActive: user.isActive,
                            ),
                          ),
                        );
                      },
                      child: _buildUserRow(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C23),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0D6EFD),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search user',
            hintStyle: TextStyle(color: Colors.grey),
            icon: Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildUserRow(AppUser user) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C23),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey[700],
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(user.isActive),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green, width: 1.2),
        ),
        child: const Text(
          'ACTIVE',
          style: TextStyle(
            color: Colors.green,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent, width: 1.2),
        ),
        child: const Text(
          'DISABLED',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }


}

class AppUser {
  final String id;
  final String displayName;
  final String email;
  final bool isActive;
  final String firstName;
  final String lastName;
  final int age;

  AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isActive,
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    final displayName = (data['displayName'] ?? '') as String;
    final email = (data['email'] ?? '') as String;
    final isActive = (data['isActive'] ?? true) as bool;

    String f = displayName;
    String l = '';
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      f = parts.first;
      l = parts.sublist(1).join(' ');
    }

    final age = (data['age'] ?? 0) as int;

    return AppUser(
      id: id,
      displayName: displayName,
      email: email,
      isActive: isActive,
      firstName: f,
      lastName: l,
      age: age,
    );
  }

  String get initials {
    if (displayName.trim().isEmpty) return '?';
    final parts = displayName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }
}

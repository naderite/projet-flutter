import 'package:flutter/material.dart';

import 'admin_home_page.dart';
import 'users_list_page.dart';
import 'search_movies_page.dart';
import 'watch_list_page.dart';

class AdminRootPage extends StatefulWidget {
  const AdminRootPage({super.key});

  @override
  State<AdminRootPage> createState() => _AdminRootPageState();
}

class _AdminRootPageState extends State<AdminRootPage> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_currentIndex) {
      case 0:
        body = AdminHomePage(
          onGoToUsers: () => _goToTab(1),
          onGoToSearch: () => _goToTab(2),
          onGoToWatchList: () => _goToTab(3),
        );
        break;
      case 1:
        body = const UsersListPage();
        break;
      case 2:
        body = const SearchMoviesPage();
        break;
      case 3:
        body = const WatchListPage();
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101015),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1C1C23),
        selectedItemColor: const Color(0xFFE50914),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'movie list',
          ),
        ],
      ),
    );
  }
}

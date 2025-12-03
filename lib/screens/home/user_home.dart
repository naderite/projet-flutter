import 'package:flutter/material.dart';
import 'package:test/screens/home/home.dart';
import 'package:test/screens/home/search.dart';
import 'package:test/screens/home/watchlist.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  int index = 0;
  List<Widget> pages = [Home(), Search(), Watchlist()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF121011),
        fontFamily: 'Montserrat',
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: Scaffold(
        body: pages[index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          selectedItemColor: Color(0xFFEB2F3D),
          unselectedItemColor: Color(0xFF67686D),
          backgroundColor: Color(0xFF242A32),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: index == 0
                  ? Image.asset("assets/img/Home_red.png")
                  : Image.asset("assets/img/Home_gray.png"),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: index == 1
                  ? Image.asset("assets/img/Search_red.png")
                  : Image.asset("assets/img/Search_gray.png"),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: index == 2
                  ? Image.asset("assets/img/Save_red.png")
                  : Image.asset("assets/img/Save_gray.png"),
              label: "Watchlist",
            ),
          ],
        ),
      ),
    );
  }
}

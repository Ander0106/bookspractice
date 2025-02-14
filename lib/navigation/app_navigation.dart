import 'package:book_review_final/screens/main/library_screen.dart';
import 'package:flutter/material.dart';
import '../screens/main/mybook_screen.dart';
import '../screens/main/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialTab; // Recibe el índice inicial desde la ruta
  const MainNavigation({super.key, this.initialTab = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    MyBooksScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab; // Usa el valor inicial
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Librería',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mis Libros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

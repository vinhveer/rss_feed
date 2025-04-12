import 'package:flutter/material.dart';
import 'package:rss_feed/pages/page_home.dart';
import 'package:rss_feed/pages/page_settings.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class PageInfo {
  final Widget page;
  final String title;
  final String id;

  PageInfo({required this.page, required this.title, required this.id});
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<PageInfo> _pages = [
    PageInfo(page: PageHome(), title: 'RSS', id: 'page_rss'),
    PageInfo(page: PageSettings(), title: 'Cài đặt', id: 'page_settings'),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDrawerItemTapped(int index) {
    Navigator.pop(context); // Đóng drawer
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_currentIndex].title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Tài khoản',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () => _onDrawerItemTapped(1),
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

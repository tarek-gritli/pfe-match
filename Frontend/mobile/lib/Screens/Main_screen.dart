import 'package:flutter/material.dart';
import 'Student/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Start on Profile tab

  // Global keys for each tab's navigator to control navigation stacks
  final GlobalKey<NavigatorState> _discoverNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _matchesNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _messagesNavigatorKey = GlobalKey<NavigatorState>();

  // List of navigators for each tab
  late final List<Widget> _tabNavigators;

  @override
  void initState() {
    super.initState();
    _tabNavigators = [
      _buildNavigator(_discoverNavigatorKey, const DiscoverPage()),
      _buildNavigator(_matchesNavigatorKey, const MatchesPage()),
      _buildNavigator(_profileNavigatorKey, const StudentProfileScreen()),
      _buildNavigator(_messagesNavigatorKey, const MessagesPage()),
    ];
  }

  // Helper to create a Navigator for a tab with an initial widget
  Widget _buildNavigator(GlobalKey<NavigatorState> key, Widget initialWidget) {
    return Navigator(
      key: key,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) => initialWidget,
          settings: settings,
        );
      },
    );
  }

  // Handle tab tap: pop to root if same tab, otherwise switch
  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      // Pop to the root of the current tab's stack
      switch (index) {
        case 0:
          _discoverNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          break;
        case 1:
          _matchesNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          break;
        case 2:
          _profileNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          break;
        case 3:
          _messagesNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          break;
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabNavigators,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.explore, 'Discover', 0),
              _buildNavItem(Icons.auto_awesome_motion, 'Matches', 1),
              _buildNavItem(Icons.account_circle, 'Profile', 2),
              _buildNavItem(Icons.chat_bubble, 'Messages', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1B8D98) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF1B8D98) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages - replace with your actual implementations
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Discover Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Example of nested navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        body: Center(child: Text('Detail Page')),
                      ),
                    ),
                  );
                },
                child: const Text('Go to Detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchesPage extends StatelessWidget {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: SafeArea(
        child: Center(
          child: Text(
            'Matches Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: SafeArea(
        child: Center(
          child: Text(
            'Messages Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
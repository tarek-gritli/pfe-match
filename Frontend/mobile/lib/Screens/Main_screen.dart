import 'package:flutter/material.dart';
import 'Student/profile_screen.dart';
import 'Student/explore_screen.dart';
import 'Student/applications_screen.dart';

// InheritedWidget to provide tab navigation callback
class TabNavigator extends InheritedWidget {
  final Function(int) onNavigateToTab;

  const TabNavigator({
    Key? key,
    required this.onNavigateToTab,
    required Widget child,
  }) : super(key: key, child: child);

  static TabNavigator? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabNavigator>();
  }

  @override
  bool updateShouldNotify(TabNavigator oldWidget) {
    return false;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Start on Explore tab

  // Global keys for each tab's navigator to control navigation stacks
  final GlobalKey<NavigatorState> _exploreNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _applicationsNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

  // List of navigators for each tab
  late final List<Widget> _tabNavigators;

  @override
  void initState() {
    super.initState();
    _tabNavigators = [
      _buildNavigator(_exploreNavigatorKey, const ExploreScreen()),
      _buildNavigator(_applicationsNavigatorKey, const ApplicationsScreen()),
      _buildNavigator(_profileNavigatorKey, const StudentProfileScreen()),
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
          _exploreNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          break;
        case 1:
          _applicationsNavigatorKey.currentState?.popUntil((route) => route.isFirst);
          break;
        case 2:
          _profileNavigatorKey.currentState?.popUntil((route) => route.isFirst);
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
    return TabNavigator(
      onNavigateToTab: _onTabTapped,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabNavigators,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.explore, 'Explore', 0),
              _buildNavItem(Icons.description, 'Applications', 1),
              _buildNavItem(Icons.account_circle, 'Profile', 2),
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


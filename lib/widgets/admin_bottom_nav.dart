// lib/widgets/admin_bottom_nav.dart
import 'package:flutter/material.dart';

// ✅ Admin Screens - matching your file names exactly
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_programs_screen.dart';
import '../screens/admin/admin_announcements_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/admin/admin_profile_screen.dart';

// Color constants (matching learner style)
const kPrimary = Color(0xFFE0194A);
const kPurple = Color(0xFF9B59B6);
const kMutedFg = Color(0xFF949494);
const kAuthAccentDark = Color(0xFFE53935);

/// Enum for the 5 bottom nav destinations
enum AdminNavDestination {
  dashboard,
  users,
  programs,
  analytics,
  profile,
}

class AdminBottomNav extends StatelessWidget {
  final AdminNavDestination currentDestination;
  final bool useReplacement;

  const AdminBottomNav({
    super.key,
    required this.currentDestination,
    this.useReplacement = true,
  });

  int get _currentIndex {
    switch (currentDestination) {
      case AdminNavDestination.dashboard:
        return 0;
      case AdminNavDestination.users:
        return 1;
      case AdminNavDestination.programs:
        return 2;
      case AdminNavDestination.analytics:
        return 3;
      case AdminNavDestination.profile:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_rounded,
                label: 'Home',
                index: 0,
                destination: AdminNavDestination.dashboard,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.people_alt_rounded,
                label: 'Users',
                index: 1,
                destination: AdminNavDestination.users,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.menu_book_rounded,
                label: 'Programs',
                index: 2,
                destination: AdminNavDestination.programs,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.analytics_rounded,
                label: 'Analytics',
                index: 3,
                destination: AdminNavDestination.analytics,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_rounded,
                label: 'Profile',
                index: 4,
                destination: AdminNavDestination.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required AdminNavDestination destination,
  }) {
    final isActive = _currentIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleTap(context, destination),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? kPrimary : kMutedFg, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? kPrimary : kMutedFg,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, AdminNavDestination destination) {
    if (destination == currentDestination) return;

    Widget? nextScreen;
    switch (destination) {
      case AdminNavDestination.dashboard:
        nextScreen = const AdminHomeScreen();  // ✅ Changed from AdminDashboardScreen
        break;
      case AdminNavDestination.users:
        nextScreen = const AdminUsersScreen();
        break;
      case AdminNavDestination.programs:
        nextScreen = const AdminProgramsScreen();
        break;
      case AdminNavDestination.analytics:
        nextScreen = const AdminAnalyticsScreen();
        break;
      case AdminNavDestination.profile:
        nextScreen = const AdminProfileScreen();
        break;
    }

    if (nextScreen == null) return;

    if (useReplacement) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen!),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => nextScreen!),
      );
    }
  }
}
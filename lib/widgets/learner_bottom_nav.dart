// lib/widgets/learner_bottom_nav.dart
import 'package:flutter/material.dart';

// Screens that bottom nav can route to
import '../screens/learner_home_screen.dart';
import '../screens/learner_explore_screen.dart';
import '../screens/learner_learning_screen.dart';
import '../screens/learner_progress_screen.dart';
import '../screens/learner_profile_screen.dart';

// Color constants
const kPrimary = Color(0xFFE0194A);
const kMutedFg = Color(0xFF949494);

/// Enum for the 5 bottom nav destinations
enum HomeNavDestination {
  home,
  explore,
  learning,
  progress,
  profile,
}

class BottomNav extends StatelessWidget {
  final HomeNavDestination currentDestination;
  final bool useReplacement;

  const BottomNav({
    super.key,
    required this.currentDestination,
    this.useReplacement = true,
  });

  int get _currentIndex {
    switch (currentDestination) {
      case HomeNavDestination.home:
        return 0;
      case HomeNavDestination.explore:
        return 1;
      case HomeNavDestination.learning:
        return 2;
      case HomeNavDestination.progress:
        return 3;
      case HomeNavDestination.profile:
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
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                destination: HomeNavDestination.home,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.explore_outlined,
                label: 'Explore',
                index: 1,
                destination: HomeNavDestination.explore,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.school_outlined,
                label: 'Learning',
                index: 2,
                destination: HomeNavDestination.learning,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.trending_up_outlined,
                label: 'Progress',
                index: 3,
                destination: HomeNavDestination.progress,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                label: 'Profile',
                index: 4,
                destination: HomeNavDestination.profile,
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
    required HomeNavDestination destination,
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

  void _handleTap(BuildContext context, HomeNavDestination destination) {
    if (destination == currentDestination) return;

    Widget? nextScreen;
    switch (destination) {
      case HomeNavDestination.home:
        nextScreen = const LearnerHomeScreen();
        break;
      case HomeNavDestination.explore:
        nextScreen = const LearnerExploreScreen();
        break;
      case HomeNavDestination.learning:
        nextScreen = const LearnerLearningScreen();
        break;
      case HomeNavDestination.progress:
        nextScreen = const LearnerProgressScreen();
        break;
      case HomeNavDestination.profile:
        nextScreen = const ProfileScreen();
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
// lib/widgets/tutor_bottom_nav.dart
import 'package:flutter/material.dart';
import '../screens/tutor/tutor_home_screen.dart';
import '../screens/learner/learner_profile_screen.dart'; // Reuse profile for simplicity or create tutor specific

enum TutorNavDestination { home, sessions, feedback, profile }

class TutorBottomNav extends StatelessWidget {
  final TutorNavDestination currentDestination;

  const TutorBottomNav({super.key, required this.currentDestination});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF863CAC); // Tutor theme: Purple
    const kMuted = Color(0xFF949494);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, Icons.grid_view_rounded, 'Hub', TutorNavDestination.home, kPrimary, kMuted),
              _buildItem(context, Icons.video_call_rounded, 'Live', TutorNavDestination.sessions, kPrimary, kMuted),
              _buildItem(context, Icons.analytics_rounded, 'Pulse', TutorNavDestination.feedback, kPrimary, kMuted),
              _buildItem(context, Icons.person_rounded, 'Profile', TutorNavDestination.profile, kPrimary, kMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, TutorNavDestination dest, Color active, Color inactive) {
    final isActive = currentDestination == dest;
    return GestureDetector(
      onTap: () {
        if (isActive) return;
        Widget next;
        switch (dest) {
          case TutorNavDestination.home: next = const TutorHomeScreen(); break;
          default: next = const TutorHomeScreen(); // Placeholder for others
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? active : inactive),
          Text(label, style: TextStyle(color: isActive ? active : inactive, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

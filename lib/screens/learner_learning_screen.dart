// lib/screens/learner_learning_screen.dart
import 'package:flutter/material.dart';
import '../widgets/learner_bottom_nav.dart';
import 'learner_home_screen.dart';

const kPrimary = Color(0xFFE0194A);
const kPurple = Color(0xFF9B59B6);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;
const kTeal = Color(0xFF0891B2);
const kOrange = Color(0xFFEA580C);
const kSuccess = Color(0xFF22C55E);
const kRed = Color(0xFFDC2E44);

class LearnerLearningScreen extends StatelessWidget {
  const LearnerLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),  // ✅ Pass context
              const SizedBox(height: 20),
              _buildLiveNowSection(),
              const SizedBox(height: 24),
              _buildUpcomingSection(),
              const SizedBox(height: 24),
              _buildRecordedSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentDestination: HomeNavDestination.learning,
      ),
    );
  }

  // ✅ Accept context as parameter
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // ✅ Navigate to LearnerHomeScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LearnerHomeScreen(),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: kFg),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kFg,
                ),
              ),
              Text(
                'Live sessions & recorded courses',
                style: TextStyle(fontSize: 12, color: kMutedFg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveNowSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kRed, kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE NOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Neural Network Architectures',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dr. Elena Rodriguez',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: kRed, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Join Now',
                      style: TextStyle(
                        color: kRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.people_alt_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              const Text(
                '124 watching',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection() {
    final upcoming = [
      {
        'title': 'Agile Product Leadership',
        'speaker': 'Marcus Thorne',
        'time': 'Tomorrow, 3:00 PM',
        'icon': Icons.bolt_rounded,
        'color': kOrange,
      },
      {
        'title': 'Advanced Threat Detection',
        'speaker': 'Sarah Chen',
        'time': 'Sep 24, 2:00 PM',
        'icon': Icons.security_rounded,
        'color': kPurple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Sessions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: kFg,
          ),
        ),
        const SizedBox(height: 12),
        ...upcoming.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildSessionCard(s),
        )),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final sessionColor = session['color'] as Color;
    final sessionIcon = session['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: sessionColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              sessionIcon,
              color: sessionColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kFg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session['speaker'] as String,
                  style: const TextStyle(fontSize: 11, color: kMutedFg),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 11, color: kMutedFg),
                    const SizedBox(width: 4),
                    Text(
                      session['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kMutedFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: kPrimary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Remind Me',
              style: TextStyle(
                color: kPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recorded Courses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: kFg,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            _buildCourseCard('Intro to Python', '12 lessons', kTeal, Icons.code_rounded),
            _buildCourseCard('Design Thinking', '8 lessons', kPurple, Icons.lightbulb_rounded),
            _buildCourseCard('Marketing 101', '15 lessons', kOrange, Icons.campaign_rounded),
            _buildCourseCard('Data Analytics', '10 lessons', kPrimary, Icons.bar_chart_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseCard(String title, String lessons, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                lessons,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
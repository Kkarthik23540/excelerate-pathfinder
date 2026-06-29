// lib/screens/learner_explore_screen.dart
import 'package:flutter/material.dart';
import '../widgets/learner_bottom_nav.dart';
import 'learner_program_details_screen.dart';
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

class LearnerExploreScreen extends StatefulWidget {
  const LearnerExploreScreen({super.key});

  @override
  State<LearnerExploreScreen> createState() => _LearnerExploreScreenState();
}

class _LearnerExploreScreenState extends State<LearnerExploreScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _programs = [
    {
      'id': 'p1',
      'title': 'AI & Machine Learning',
      'category': 'Technology',
      'instructor': 'Dr. Sarah Chen',
      'duration': '12 weeks',
      'students': 1234,
      'rating': 4.8,
      'iconColor': kTeal.value,
      'iconCode': Icons.psychology_rounded.codePoint,
      'tag': 'Popular',
    },
    {
      'id': 'p2',
      'title': 'Digital Marketing Pro',
      'category': 'Marketing',
      'instructor': 'Marcus Thorne',
      'duration': '8 weeks',
      'students': 892,
      'rating': 4.6,
      'iconColor': kOrange.value,
      'iconCode': Icons.trending_up_rounded.codePoint,
      'tag': 'New',
    },
    {
      'id': 'p3',
      'title': 'UX/UI Design Bootcamp',
      'category': 'Design',
      'instructor': 'Emma Wilson',
      'duration': '10 weeks',
      'students': 2103,
      'rating': 4.9,
      'iconColor': kPurple.value,
      'iconCode': Icons.palette_rounded.codePoint,
      'tag': 'Trending',
    },
    {
      'id': 'p4',
      'title': 'Full-Stack Web Development',
      'category': 'Technology',
      'instructor': 'James Rodriguez',
      'duration': '16 weeks',
      'students': 3456,
      'rating': 4.7,
      'iconColor': kPrimary.value,
      'iconCode': Icons.code_rounded.codePoint,
      'tag': 'Bestseller',
    },
    {
      'id': 'p5',
      'title': 'Business Strategy Mastery',
      'category': 'Business',
      'instructor': 'Lisa Anderson',
      'duration': '6 weeks',
      'students': 567,
      'rating': 4.5,
      'iconColor': kTeal.value,
      'iconCode': Icons.business_center_rounded.codePoint,
      'tag': null,
    },
    {
      'id': 'p6',
      'title': 'Data Science with Python',
      'category': 'Technology',
      'instructor': 'Dr. Raj Patel',
      'duration': '14 weeks',
      'students': 1890,
      'rating': 4.8,
      'iconColor': kOrange.value,
      'iconCode': Icons.bar_chart_rounded.codePoint,
      'tag': 'Popular',
    },
  ];

  final List<Map<String, dynamic>> _competitions = [
    {
      'title': 'Startup Pitch Challenge',
      'prize': '\$5,000',
      'teams': 42,
      'daysLeft': 3,
      'color': kPurple,
    },
    {
      'title': 'FinTech Algorithm Contest',
      'prize': '\$2,500',
      'teams': 18,
      'daysLeft': 7,
      'color': kOrange,
    },
  ];

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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 20),
              _buildFeaturedBanner(),
              const SizedBox(height: 24),
              _buildSectionTitle('Programs', '${_programs.length} available'),
              const SizedBox(height: 12),
              _buildProgramsList(),
              const SizedBox(height: 24),
              _buildSectionTitle('Competitions', 'Win prizes'),
              const SizedBox(height: 12),
              _buildCompetitionsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentDestination: HomeNavDestination.explore,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // ✅ Back button - navigates to LearnerHomeScreen
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // Use pushReplacement to avoid stacking screens
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
                'Explore',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kFg,
                ),
              ),
              Text(
                'Discover new opportunities',
                style: TextStyle(fontSize: 12, color: kMutedFg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = ['All', 'Technology', 'Business', 'Marketing', 'Design'];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kCardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? kPrimary : kBorder,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : kFg,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚀 FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'AI & Machine\nLearning Bootcamp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start your AI journey today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Enroll Now →',
                    style: TextStyle(
                      color: kPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: kFg,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: kMutedFg),
        ),
      ],
    );
  }

  Widget _buildProgramsList() {
    final filtered = _selectedCategory == 'All'
        ? _programs
        : _programs.where((p) => p['category'] == _selectedCategory).toList();

    return Column(
      children: filtered.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildProgramCard(p),
      )).toList(),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final iconColor = Color(program['iconColor'] as int);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearnerProgramDetailsScreen(
                program: {
                  'id': program['id'],
                  'title': program['title'],
                  'modules': '0 of 12 modules',
                  'progress': 0.0,
                  'iconColor': iconColor.value,
                  'iconCode': program['iconCode'],
                },
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(program['iconCode'], fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: kFg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (program['tag'] != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              program['tag'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '👤 ${program['instructor']}',
                      style: const TextStyle(fontSize: 11, color: kMutedFg),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 11, color: kMutedFg),
                        const SizedBox(width: 3),
                        Text(
                          program['duration'],
                          style: const TextStyle(fontSize: 10, color: kMutedFg),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.people, size: 11, color: kMutedFg),
                        const SizedBox(width: 3),
                        Text(
                          '${program['students']}',
                          style: const TextStyle(fontSize: 10, color: kMutedFg),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.star, size: 11, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          program['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: kMutedFg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitionsList() {
    return Column(
      children: _competitions.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildCompetitionCard(c),
      )).toList(),
    );
  }

  Widget _buildCompetitionCard(Map<String, dynamic> comp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: comp['color'],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRIZE POOL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${comp['daysLeft']} days left',
                style: const TextStyle(
                  fontSize: 11,
                  color: kPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comp['prize'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: kPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comp['title'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kFg,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${comp['teams']} Teams Registered',
                style: const TextStyle(fontSize: 11, color: kMutedFg),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Join Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
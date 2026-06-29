// lib/screens/learner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/learner_bottom_nav.dart';
import 'learner_program_details_screen.dart';
import 'learner_announcements_screen.dart';
import 'learner_browse_programs_screen.dart';
import 'learner_login_screen.dart';

const kPrimary = Color(0xFFE0194A);
const kPurple = Color(0xFF9B59B6);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;
const kTeal = Color(0xFF0891B2);
const kOrange = Color(0xFFEA580C);
const kIndigo = Color(0xFF6366F1);
const kAuthAccentDark = Color(0xFFE53935);

class LearnerHomeScreen extends StatefulWidget {
  const LearnerHomeScreen({super.key});

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen>
    with TickerProviderStateMixin {
  String? _userId;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  // ✅ Logo animations (scale + glow, stays in place)
  late final AnimationController _logoScaleController;
  late final AnimationController _logoGlowController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;

    // ✅ Logo entrance animation
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = CurvedAnimation(
      parent: _logoScaleController,
      curve: Curves.elasticOut,
    );

    // ✅ Logo glow pulse
    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _logoGlowController, curve: Curves.easeInOut),
    );

    // ✅ Start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logoScaleController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _logoScaleController.dispose();
    _logoGlowController.dispose();
    super.dispose();
  }

  DocumentReference? get _userRef => _userId != null
      ? FirebaseFirestore.instance.collection('users').doc(_userId)
      : null;
  DocumentReference? get _achievementsRef => _userId != null
      ? FirebaseFirestore.instance.collection('achievements').doc(_userId)
      : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppBar(),
              const SizedBox(height: 20),
              _buildHeroSection(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildCategoryTabs(),
              const SizedBox(height: 24),
              _buildContinueLearning(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildAnnouncements(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentDestination: HomeNavDestination.home,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  APP BAR with Logo + Brand Name (same as login/signup)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Row(
      children: [
        // ✅ Animated Logo Icon (Left side)
        _buildAnimatedLogo(),
        const SizedBox(width: 12),
        // ✅ Brand Name "Excelerate" + "PATHFINDER" (same as login)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Excelerate',
                style: TextStyle(
                  color: kAuthAccentDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  height: 1.0,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: kAuthAccentDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PATHFINDER',
                  style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    height: 1.1,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildIconButton(
          icon: Icons.notifications_none_rounded,
          badge: '2',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications - coming soon'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.settings_outlined,
          badge: null,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings - coming soon'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  ✅ ANIMATED LOGO (scale + glow, stays in place)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScaleController,
        _logoGlowController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing glow background
                Container(
                  width: 38 + (_logoGlow.value * 6),
                  height: 38 + (_logoGlow.value * 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kAuthAccentDark.withOpacity(_logoGlow.value * 0.3),
                        kAuthAccentDark.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // Main logo body
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [kPrimary, kPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Icon(icon, color: kFg, size: 20),
            ),
            if (badge != null)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kCardBg, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  HERO SECTION (Welcome with gradient banner)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userRef?.snapshots() ?? const Stream.empty(),
      builder: (context, snapshot) {
        String firstName = 'Learner';
        String tier = 'Velocity Tier 1';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data is Map) {
            firstName = (data['displayName'] as String?)?.split(' ').first ?? 'Learner';
            tier = (data['tier'] as String?) ?? 'Velocity Tier 1';
          }
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.3),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          tier.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$firstName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's continue your learning journey",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // ✅ Level progress strip
              StreamBuilder<DocumentSnapshot>(
                stream: _achievementsRef?.snapshots() ?? const Stream.empty(),
                builder: (context, achSnapshot) {
                  int totalXP = 390;
                  int level = 1;
                  if (achSnapshot.hasData && achSnapshot.data!.exists) {
                    final data = achSnapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null) {
                      totalXP = (data['totalXP'] as int?) ?? 390;
                      level = (data['level'] as int?) ?? 1;
                    }
                  }
                  final progress = totalXP > 0
                      ? ((totalXP % 500) / 500).clamp(0.0, 1.0)
                      : 0.78;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $level',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$totalXP XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  SEARCH BAR
  // ════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: kMutedFg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14, color: kFg),
              decoration: const InputDecoration(
                hintText: 'Search programs, courses...',
                hintStyle: TextStyle(color: kMutedFg, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearnerBrowseProgramsScreen(
                        searchQuery: query.trim(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: kPrimary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  STATS ROW
  // ════════════════════════════════════════════════════════════════════
  Widget _buildStatsRow() {
    if (_achievementsRef == null) {
      return _buildStatsRowContent(5, 0.78, 12);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _achievementsRef!.snapshots(),
      builder: (context, snapshot) {
        int activeCount = 5;
        int completedCount = 12;
        double progress = 0.78;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            try {
              final completedList = data['completedProgrammes'];
              completedCount = (completedList is List) ? completedList.length : 12;
              final totalXP = (data['totalXP'] as int?) ?? 390;
              progress = totalXP > 0 ? ((totalXP % 500) / 500) : 0.78;
              if (progress == 0) progress = 0.78;
              final activeList = data['activeProgrammes'];
              activeCount = (activeList is List) ? activeList.length : 5;
            } catch (e) {
              debugPrint('Stats parse error: $e');
            }
          }
        }

        return _buildStatsRowContent(activeCount, progress, completedCount);
      },
    );
  }

  Widget _buildStatsRowContent(int activeCount, double progress, int completedCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            color: kTeal,
            icon: Icons.menu_book_rounded,
            value: activeCount.toString(),
            label: 'Active',
            subtitle: 'Programs',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            color: kOrange,
            icon: Icons.local_fire_department_rounded,
            value: '${(progress * 100).round()}%',
            label: 'Progress',
            subtitle: 'This Level',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            color: kPurple,
            icon: Icons.workspace_premium_rounded,
            value: completedCount.toString(),
            label: 'Completed',
            subtitle: 'Certificates',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Color color,
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  CATEGORY TABS
  // ════════════════════════════════════════════════════════════════════
  Widget _buildCategoryTabs() {
    final categories = [
      {'icon': Icons.all_inclusive_rounded, 'label': 'All'},
      {'icon': Icons.psychology_rounded, 'label': 'Tech'},
      {'icon': Icons.business_rounded, 'label': 'Business'},
      {'icon': Icons.design_services_rounded, 'label': 'Design'},
      {'icon': Icons.campaign_rounded, 'label': 'Marketing'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kPrimary : kBorder,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? Colors.white : kMutedFg,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : kFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  CONTINUE LEARNING (Horizontal scroll cards)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildContinueLearning() {
    final programs = [
      {
        'title': 'Digital Marketing Fundamentals',
        'modules': '8 of 12 modules',
        'progress': 0.67,
        'iconColor': kTeal,
        'icon': Icons.menu_book_rounded,
        'tag': 'POPULAR',
      },
      {
        'title': 'Agile & Scrum Methodology',
        'modules': '5 of 10 modules',
        'progress': 0.50,
        'iconColor': kPurple,
        'icon': Icons.people_alt_rounded,
        'tag': 'TRENDING',
      },
      {
        'title': 'Data Analytics Basics',
        'modules': '3 of 8 modules',
        'progress': 0.38,
        'iconColor': kOrange,
        'icon': Icons.bar_chart_rounded,
        'tag': 'NEW',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: kFg,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(width: 6),
                Text('🚀', style: TextStyle(fontSize: 16)),
              ],
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearnerBrowseProgramsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'See All →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final p = programs[index];
              return Padding(
                padding: EdgeInsets.only(
                    right: 12, left: index == 0 ? 0 : 0),
                child: _buildProgramCard(
                  title: p['title'] as String,
                  modules: p['modules'] as String,
                  progress: p['progress'] as double,
                  iconColor: p['iconColor'] as Color,
                  icon: p['icon'] as IconData,
                  tag: p['tag'] as String,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard({
    required String title,
    required String modules,
    required double progress,
    required Color iconColor,
    required IconData icon,
    required String tag,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearnerProgramDetailsScreen(
                program: {
                  'id': 'demo_${title.hashCode}',
                  'title': title,
                  'modules': modules,
                  'progress': progress,
                  'iconColor': iconColor.value,
                  'iconCode': icon.codePoint,
                },
              ),
            ),
          );
        },
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kFg,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                modules,
                style: const TextStyle(fontSize: 11, color: kMutedFg),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).round()}% done',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      color: kPrimary, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  QUICK ACTIONS (4 tile grid)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: kFg,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.grid_view_rounded,
                label: 'Browse',
                color: kPrimary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearnerBrowseProgramsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.notifications_active_outlined,
                label: 'Announce',
                color: kTeal,
                badge: '3',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearnerAnnouncementsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements',
                color: kOrange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View your achievements'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.support_agent_rounded,
                label: 'Support',
                color: kPurple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support - coming soon'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kFg,
                  ),
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: kMutedFg, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  ANNOUNCEMENTS
  // ════════════════════════════════════════════════════════════════════
  Widget _buildAnnouncements() {
    final announcements = [
      {
        'icon': Icons.notifications_active_outlined,
        'iconColor': kTeal,
        'title': 'New Program: Sales & Negotiation Mastery',
        'body':
        'Enroll now in our latest program on advanced sales techniques and deal-closing strategies.',
        'time': '2 hours ago',
        'isNew': true,
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'iconColor': kPurple,
        'title': 'System Maintenance Notice',
        'body':
        'Platform will undergo scheduled maintenance on Sunday, 2 AM - 4 AM EST.',
        'time': '1 day ago',
        'isNew': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Announcements',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: kFg,
                letterSpacing: -0.3,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearnerAnnouncementsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...announcements.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildAnnouncementCard(
            icon: a['icon'] as IconData,
            iconColor: a['iconColor'] as Color,
            title: a['title'] as String,
            body: a['body'] as String,
            time: a['time'] as String,
            isNew: a['isNew'] as bool,
          ),
        )),
      ],
    );
  }

  Widget _buildAnnouncementCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String time,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isNew ? kPrimary.withOpacity(0.2) : kBorder,
            width: isNew ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kFg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
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
                  body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kMutedFg,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 10, color: kMutedFg),
                    const SizedBox(width: 3),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: kMutedFg,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
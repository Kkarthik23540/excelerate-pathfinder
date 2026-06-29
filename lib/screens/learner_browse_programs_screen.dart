// lib/screens/learner_browse_programs_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'learner_program_details_screen.dart';

const kPrimary = Color(0xFFE0194A);
const kPurple = Color(0xFF9B59B6);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;
const kTeal = Color(0xFF0891B2);
const kOrange = Color(0xFFEA580C);

class LearnerBrowseProgramsScreen extends StatefulWidget {
  final String? searchQuery;

  const LearnerBrowseProgramsScreen({super.key, this.searchQuery});

  @override
  State<LearnerBrowseProgramsScreen> createState() =>
      _LearnerBrowseProgramsScreenState();
}

class _LearnerBrowseProgramsScreenState
    extends State<LearnerBrowseProgramsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchCtrl.text = widget.searchQuery!;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _programs = [
    {
      'id': 'prog_001',
      'title': 'Digital Marketing Fundamentals',
      'category': 'Marketing',
      'modules': '12 modules',
      'duration': '8 weeks',
      'progress': 0.67,
      'iconColor': kTeal.value,
      'iconCode': Icons.menu_book_rounded.codePoint,
      'level': 'Beginner',
    },
    {
      'id': 'prog_002',
      'title': 'Agile & Scrum Methodology',
      'category': 'Business',
      'modules': '10 modules',
      'duration': '6 weeks',
      'progress': 0.50,
      'iconColor': kPurple.value,
      'iconCode': Icons.people_alt_rounded.codePoint,
      'level': 'Intermediate',
    },
    {
      'id': 'prog_003',
      'title': 'Data Science with Python',
      'category': 'Technology',
      'modules': '15 modules',
      'duration': '12 weeks',
      'progress': 0.0,
      'iconColor': kOrange.value,
      'iconCode': Icons.bar_chart_rounded.codePoint,
      'level': 'Advanced',
    },
    {
      'id': 'prog_004',
      'title': 'UX/UI Design Bootcamp',
      'category': 'Design',
      'modules': '14 modules',
      'duration': '10 weeks',
      'progress': 0.25,
      'iconColor': kPrimary.value,
      'iconCode': Icons.palette_rounded.codePoint,
      'level': 'Intermediate',
    },
    {
      'id': 'prog_005',
      'title': 'Sales & Negotiation Mastery',
      'category': 'Business',
      'modules': '8 modules',
      'duration': '5 weeks',
      'progress': 0.0,
      'iconColor': kPurple.value,
      'iconCode': Icons.handshake_rounded.codePoint,
      'level': 'Beginner',
    },
    {
      'id': 'prog_006',
      'title': 'Full-Stack Web Development',
      'category': 'Technology',
      'modules': '20 modules',
      'duration': '16 weeks',
      'progress': 0.10,
      'iconColor': kTeal.value,
      'iconCode': Icons.code_rounded.codePoint,
      'level': 'Advanced',
    },
  ];

  List<Map<String, dynamic>> get _filteredPrograms {
    var list = _programs;
    if (_selectedFilter != 'All') {
      list = list.where((p) => p['category'] == _selectedFilter).toList();
    }
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      list = list.where((p) =>
          (p['title'] as String).toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchAndFilters(),
            Expanded(child: _buildProgramsGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.arrow_back, size: 20, color: kFg),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Browse Programs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kFg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: kMutedFg, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search programs...',
                      hintStyle: TextStyle(color: kMutedFg, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Technology'),
                const SizedBox(width: 8),
                _buildFilterChip('Business'),
                const SizedBox(width: 8),
                _buildFilterChip('Marketing'),
                const SizedBox(width: 8),
                _buildFilterChip('Design'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? kPrimary : kCardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? kPrimary : kBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : kFg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgramsGrid() {
    final programs = _filteredPrograms;
    if (programs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: kMutedFg),
            const SizedBox(height: 12),
            Text(
              'No programs found',
              style: TextStyle(
                fontSize: 14,
                color: kMutedFg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        return _buildProgramGridCard(programs[index]);
      },
    );
  }

  Widget _buildProgramGridCard(Map<String, dynamic> program) {
    final iconCode = program['iconCode'] as int;
    final iconColor = Color(program['iconColor'] as int);
    final progress = program['progress'] as double;
    final isStarted = progress > 0;

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
                  'modules': isStarted
                      ? '${(progress * 12).round()} of 12 modules completed'
                      : '0 of 12 modules completed',
                  'progress': progress,
                  'iconColor': iconColor.value,
                  'iconCode': iconCode,
                },
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top color banner with icon
              Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [iconColor, iconColor.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Icon(
                    IconData(iconCode, fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: kFg,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.book_outlined,
                            size: 11, color: kMutedFg),
                        const SizedBox(width: 4),
                        Text(
                          program['modules'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: kMutedFg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 11, color: kMutedFg),
                        const SizedBox(width: 4),
                        Text(
                          program['duration'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: kMutedFg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isStarted)
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
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
}
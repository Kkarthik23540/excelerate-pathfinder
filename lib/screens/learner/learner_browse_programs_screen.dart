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
                _buildFilterChip('Tech'),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('programs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 48, color: kMutedFg),
                const SizedBox(height: 12),
                const Text(
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

        var programs = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        // Apply Search Filter
        if (_searchCtrl.text.isNotEmpty) {
          final q = _searchCtrl.text.toLowerCase();
          programs = programs.where((p) {
            final title = (p['title'] as String? ?? '').toLowerCase();
            final category = (p['category'] as String? ?? '').toLowerCase();
            final instructor = (p['instructor'] as String? ?? '').toLowerCase();
            return title.contains(q) || category.contains(q) || instructor.contains(q);
          }).toList();
        }

        // Apply Category Filter
        if (_selectedFilter != 'All') {
          programs = programs.where((p) =>
              (p['category'] as String? ?? '') == _selectedFilter).toList();
        }

        if (programs.isEmpty) {
          return const Center(child: Text('No matching programs.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: programs.length,
          itemBuilder: (context, index) {
            return _buildProgramGridCard(programs[index]);
          },
        );
      },
    );
  }

  Widget _buildProgramGridCard(Map<String, dynamic> program) {
    final iconCode = program['iconCode'] as int? ?? Icons.menu_book.codePoint;
    final iconColor = Color(program['iconColor'] as int? ?? kTeal.value);
    final progress = (program['progress'] as num?)?.toDouble() ?? 0.0;
    final isStarted = progress > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearnerProgramDetailsScreen(
                program: program,
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
                height: 80,
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
                    size: 30,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program['title'] as String? ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 12,
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
                        Expanded(
                          child: Text(
                            program['modules'] as String? ?? 'Modules',
                            style: const TextStyle(
                              fontSize: 10,
                              color: kMutedFg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program['category'] as String? ?? 'General',
                      style: TextStyle(
                        fontSize: 10,
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                            widthFactor: progress.clamp(0.0, 1.0),
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

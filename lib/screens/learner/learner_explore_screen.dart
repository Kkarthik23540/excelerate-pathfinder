// lib/screens/learner_explore_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/learner_bottom_nav.dart';
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
              const SizedBox(height: 24),
              _buildSectionTitle('Programs', 'Available now'),
              const SizedBox(height: 12),
              _buildProgramsList(),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('programs').snapshots(),
      builder: (context, snapshot) {
        List<String> categories = ['All'];
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          final Set<String> uniqueCats = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['category'] != null) {
              uniqueCats.add(data['category']);
            }
          }
          categories.addAll(uniqueCats.toList()..sort());
        }

        return SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
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
            },
          ),
        );
      },
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('programs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No programs found.'));
        }

        var docs = snapshot.data!.docs;
        
        // Filter by category
        if (_selectedCategory != 'All') {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['category'] ?? '') == _selectedCategory;
          }).toList();
        }

        if (docs.isEmpty) {
          return const Center(child: Text('No programs in this category.'));
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildProgramCard(data),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final iconColor = Color(program['iconColor'] as int? ?? kTeal.value);
    final rating = (program['rating'] as num?)?.toDouble() ?? 0.0;
    final students = (program['students'] as num?)?.toInt() ?? 0;
    final duration = program['duration'] as String? ?? 'N/A';

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
                  IconData(program['iconCode'] ?? Icons.menu_book.codePoint, fontFamily: 'MaterialIcons'),
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
                            program['title'] ?? 'Untitled',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: kFg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (program['tag'] != null && program['tag'].toString().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              program['tag'].toString(),
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
                      '👤 ${program['instructor'] ?? 'Expert'}',
                      style: const TextStyle(fontSize: 11, color: kMutedFg),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 11, color: kMutedFg),
                        const SizedBox(width: 3),
                        Text(
                          duration,
                          style: const TextStyle(fontSize: 10, color: kMutedFg),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.people, size: 11, color: kMutedFg),
                        const SizedBox(width: 3),
                        Text(
                          '$students',
                          style: const TextStyle(fontSize: 10, color: kMutedFg),
                        ),
                        if (rating > 0) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.star, size: 11, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: kMutedFg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

}
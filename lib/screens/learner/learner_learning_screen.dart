// lib/screens/learner_learning_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/learner_bottom_nav.dart';
import 'learner_home_screen.dart';
import 'learner_program_details_screen.dart';
import 'learner_browse_programs_screen.dart';
import 'learner_profile_screen.dart';

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
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildSectionHeader('Continue Learning', 'Your journey to mastery'),
              const SizedBox(height: 16),
              _buildMyLearningList(context, userId),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LearnerHomeScreen())),
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
              Text('Learning Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kFg, letterSpacing: -0.5)),
              Text('Unlock your full potential', style: TextStyle(fontSize: 12, color: kMutedFg, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: kTeal.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium_rounded, color: kTeal, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 18, decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kFg)),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: kMutedFg, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }


  Widget _buildMyLearningList(BuildContext context, String? userId) {
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('enrolledPrograms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: kPrimary));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context, 'No Active Courses', 'Enroll in a program and start learning today!');
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
            final isCompleted = data['status'] == 'completed';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kBorder),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: (isCompleted ? kSuccess : kTeal).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(isCompleted ? Icons.verified_rounded : Icons.play_circle_fill_rounded, color: isCompleted ? kSuccess : kTeal, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['title'] ?? 'Course', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kFg), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(3))),
                            FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(height: 6, decoration: BoxDecoration(color: isCompleted ? kSuccess : kPrimary, borderRadius: BorderRadius.circular(3))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(isCompleted ? 'Certification Earned' : '${(progress * 100).round()}% Completed', style: TextStyle(fontWeight: FontWeight.w700, color: isCompleted ? kSuccess : kMutedFg, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: kBorder)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.school_outlined, size: 48, color: kPrimary),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kFg)),
          const SizedBox(height: 8),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: kMutedFg, fontSize: 12, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnerBrowseProgramsScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Browse Catalog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

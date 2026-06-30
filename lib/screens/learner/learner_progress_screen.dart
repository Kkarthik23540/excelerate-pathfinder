// lib/screens/learner_progress_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/learner_bottom_nav.dart';
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
const kMuted = Color(0xFFE8E8E8);

class LearnerProgressScreen extends StatefulWidget {
  const LearnerProgressScreen({super.key});

  @override
  State<LearnerProgressScreen> createState() => _LearnerProgressScreenState();
}

class _LearnerProgressScreenState extends State<LearnerProgressScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  DocumentReference? get _userRef => _userId != null
      ? FirebaseFirestore.instance.collection('users').doc(_userId)
      : null;
  DocumentReference? get _profileRef => _userId != null
      ? FirebaseFirestore.instance.collection('learnerProfiles').doc(_userId)
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildJourneyCard(),
              const SizedBox(height: 20),
              _buildEnrollmentsCard(),
              const SizedBox(height: 20),
              _buildQuizAnswersCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentDestination: HomeNavDestination.progress,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
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
                'Your Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kFg,
                ),
              ),
              Text(
                'Track your learning journey',
                style: TextStyle(fontSize: 12, color: kMutedFg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  USER JOURNEY TIMELINE (REAL-TIME)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildJourneyCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userRef?.snapshots() ?? const Stream.empty(),
      builder: (context, userSnap) {
        return StreamBuilder<DocumentSnapshot>(
          stream: _achievementsRef?.snapshots() ?? const Stream.empty(),
          builder: (context, achSnap) {
            bool accountCreated = userSnap.hasData && userSnap.data!.exists;
            
            bool quizCompleted = false;
            int certCount = 0;
            if (userSnap.hasData && userSnap.data!.exists) {
              final data = userSnap.data!.data() as Map<String, dynamic>?;
              quizCompleted = data?['onboardingCompleted'] ?? false;
              final certs = data?['certificates'];
              certCount = certs is List ? certs.length : 0;
            }

            bool firstProgramEnrolled = false;
            if (achSnap.hasData && achSnap.data!.exists) {
              final data = achSnap.data!.data() as Map<String, dynamic>?;
              final activeList = data?['activeProgrammes'];
              firstProgramEnrolled = (activeList is List && activeList.isNotEmpty);
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR JOURNEY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: kMutedFg,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildJourneyStep(
                    icon: Icons.person_add_rounded,
                    color: kSuccess,
                    title: 'Account Created',
                    subtitle: 'You joined Excelerate',
                    isCompleted: accountCreated,
                    isFirst: true,
                  ),
                  _buildJourneyStep(
                    icon: Icons.quiz_rounded,
                    color: kSuccess,
                    title: 'Onboarding Quiz Completed',
                    subtitle: 'Personalized your experience',
                    isCompleted: quizCompleted,
                    isCurrent: accountCreated && !quizCompleted,
                  ),
                  _buildJourneyStep(
                    icon: Icons.rocket_launch_rounded,
                    color: kPrimary,
                    title: 'First Program Enrolled',
                    subtitle: firstProgramEnrolled ? 'Successfully enrolled' : 'Start your first program',
                    isCompleted: firstProgramEnrolled,
                    isCurrent: quizCompleted && !firstProgramEnrolled,
                  ),
                  _buildJourneyStep(
                    icon: Icons.workspace_premium_rounded,
                    color: kPurple,
                    title: 'Earn Your First Certificate',
                    subtitle: certCount > 0 ? 'Verified achievement!' : 'Complete a program to earn',
                    isCompleted: certCount > 0,
                    isCurrent: firstProgramEnrolled && certCount == 0,
                    isLast: true,
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildJourneyStep({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isCurrent = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 12,
                  color: isCompleted ? kSuccess : kMuted,
                ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted ? color : (isCurrent ? color : kMuted),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: color, width: 3)
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? kSuccess : kMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isCompleted || isCurrent ? kFg : kMutedFg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCurrent ? kPrimary : kMutedFg,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  USER ENROLLMENTS (REAL-TIME)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildEnrollmentsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRef?.collection('enrolledPrograms').snapshots() ?? const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MY ENROLLMENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: kMutedFg,
                    ),
                  ),
                  Text(
                    '${docs.length} TOTAL',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No programs enrolled yet.',
                      style: TextStyle(color: kMutedFg, fontSize: 13),
                    ),
                  ),
                )
              else
                Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['title'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kFg,
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: kPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: kBg,
                              valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  QUIZ ANSWERS (REAL-TIME)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildQuizAnswersCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _profileRef?.snapshots() ?? const Stream.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildQuizAnswersFallback();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final responses = data?['quizResponses'] as Map<String, dynamic>?;

        if (responses == null) return _buildQuizAnswersFallback();

        final questionLabels = {
          'goal': ('Main Goal', Icons.flag_rounded),
          'field': ('Field of Interest', Icons.interests_rounded),
          'experience': ('Experience Level', Icons.psychology_rounded),
          'time': ('Time Commitment', Icons.access_time_rounded),
          'learning_style': ('Learning Style', Icons.school_rounded),
        };

        final answerLabels = {
          'job': 'Land a Job',
          'skills': 'Build New Skills',
          'scholarship': 'Find a Scholarship',
          'explore': 'Just Exploring',
          'tech': 'Technology',
          'business': 'Business & Finance',
          'health': 'Health & Sciences',
          'creative': 'Creative & Design',
          'beginner': 'Complete Beginner',
          'some': 'Some Knowledge',
          'intermediate': 'Intermediate',
          'advanced': 'Advanced',
          'casual': '1-3 hours/week',
          'regular': '4-7 hours/week',
          'serious': '8-15 hours/week',
          'intensive': '15+ hours/week',
          'video': 'Video Lessons',
          'reading': 'Reading & Articles',
          'hands_on': 'Hands-on Projects',
          'interactive': 'Interactive Exercises',
        };

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: kPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Quiz Answers',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kFg,
                          ),
                        ),
                        Text(
                          'Personalized based on your responses',
                          style: TextStyle(fontSize: 11, color: kMutedFg),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...responses.entries.map((entry) {
                final qId = entry.key;
                final info = questionLabels[qId];
                if (info == null) return const SizedBox.shrink();

                final label = info.$1;
                final icon = info.$2;
                final rawValue = entry.value;

                List<String> answers = [];
                if (rawValue is List) {
                  answers = rawValue.map((v) => answerLabels[v] ?? v.toString()).toList();
                } else if (rawValue is String) {
                  answers = [answerLabels[rawValue] ?? rawValue];
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildQuizAnswerRow(icon, label, answers),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizAnswerRow(IconData icon, String label, List<String> answers) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: kPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: kPurple, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kMutedFg,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: answers.map((a) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimary.withOpacity(0.3)),
                  ),
                  child: Text(
                    a,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizAnswersFallback() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: const [
          Icon(Icons.quiz_rounded, color: kMutedFg, size: 40),
          SizedBox(height: 10),
          Text(
            'Complete the onboarding quiz to see your answers here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kMutedFg),
          ),
        ],
      ),
    );
  }
}

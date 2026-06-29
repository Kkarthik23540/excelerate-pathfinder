// lib/screens/learner_onboarding_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'learner_home_screen.dart';  // ← CHANGED: route to home after quiz

// ─── Color constants (SAME AS YOUR APP THEME) ────────────────────────────────
const kPrimary = Color(0xFFE0194A);
const kCrimson = Color(0xFFC0392B);
const kPurple = Color(0xFF9B59B6);
const kPurpleLight = Color(0xFFF3E8FF);
const kBorder = Color(0xFFE8E8E8);
const kMuted = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kBg = Color(0xFFF7F7F7);
const kFg = Colors.black;
const kCardBg = Colors.white;
const kAccentColor = Color(0xFFDC2E44);
const kInactive = Color(0xFFE4E1E7);
const kSuccess = Color(0xFF22C55E);

// ============================================================
//  QUIZ DATA MODELS
// ============================================================
class QuizOption {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final Color iconBackground;
  final Color iconColor;

  const QuizOption({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.iconBackground,
    this.iconColor = Colors.white,
  });
}

class QuizQuestion {
  final String id;
  final String prompt;
  final String? description;
  final List<QuizOption> options;
  final bool allowMultiSelect;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    this.description,
    required this.options,
    this.allowMultiSelect = false,
  });
}

// ============================================================
//  ONBOARDING QUIZ SCREEN
// ============================================================
class OnboardingQuizScreen extends StatefulWidget {
  const OnboardingQuizScreen({super.key});

  @override
  State<OnboardingQuizScreen> createState() => _OnboardingQuizScreenState();
}

class _OnboardingQuizScreenState extends State<OnboardingQuizScreen> {
  // ── Quiz Questions (5 Questions for Personalization) ──────────────────
  static final List<QuizQuestion> _questions = [
    // Q1: Main Goal
    QuizQuestion(
      id: 'goal',
      prompt: "What's your main goal right now?",
      description: 'Help us understand what you want to achieve',
      options: [
        QuizOption(
          id: 'job',
          title: 'Land a Job',
          description: 'Find full-time employment that matches my skills.',
          iconData: Icons.work_outline,
          iconBackground: const Color(0xFFDC2E44),
        ),
        QuizOption(
          id: 'skills',
          title: 'Build New Skills',
          description: 'Learn and earn credentials in a new field.',
          iconData: Icons.auto_awesome_outlined,
          iconBackground: const Color(0xFFD789FD),
        ),
        QuizOption(
          id: 'scholarship',
          title: 'Find a Scholarship',
          description: 'Looking for funding opportunities to continue studies.',
          iconData: Icons.school_outlined,
          iconBackground: const Color(0xFFA86500),
        ),
        QuizOption(
          id: 'explore',
          title: 'Just Exploring',
          description: 'See what opportunities and resources are available.',
          iconData: Icons.explore_outlined,
          iconBackground: const Color(0xFF6B7280),
        ),
      ],
    ),

    // Q2: Field of Interest
    QuizQuestion(
      id: 'field',
      prompt: 'Which field interests you most?',
      description: 'Choose your preferred learning area',
      options: [
        QuizOption(
          id: 'tech',
          title: 'Technology',
          description: 'Software, data, IT, and digital products.',
          iconData: Icons.computer_outlined,
          iconBackground: const Color(0xFF3B82F6),
        ),
        QuizOption(
          id: 'business',
          title: 'Business & Finance',
          description: 'Management, accounting, marketing, and operations.',
          iconData: Icons.trending_up_outlined,
          iconBackground: const Color(0xFF10B981),
        ),
        QuizOption(
          id: 'health',
          title: 'Health & Sciences',
          description: 'Medicine, research, and laboratory work.',
          iconData: Icons.biotech_outlined,
          iconBackground: const Color(0xFFEF4444),
        ),
        QuizOption(
          id: 'creative',
          title: 'Creative & Design',
          description: 'Art, media, writing, and visual design.',
          iconData: Icons.palette_outlined,
          iconBackground: const Color(0xFFF59E0B),
        ),
      ],
    ),

    // Q3: Experience Level
    QuizQuestion(
      id: 'experience',
      prompt: 'What is your current experience level?',
      description: 'We\'ll match content to your skill level',
      options: [
        QuizOption(
          id: 'beginner',
          title: 'Complete Beginner',
          description: 'I\'m just starting out in this field.',
          iconData: Icons.spa_outlined,
          iconBackground: const Color(0xFF22C55E),
        ),
        QuizOption(
          id: 'some',
          title: 'Some Knowledge',
          description: 'I know the basics and want to expand.',
          iconData: Icons.book_outlined,
          iconBackground: const Color(0xFF3B82F6),
        ),
        QuizOption(
          id: 'intermediate',
          title: 'Intermediate',
          description: 'I have working experience and want to level up.',
          iconData: Icons.psychology_outlined,
          iconBackground: const Color(0xFF9B59B6),
        ),
        QuizOption(
          id: 'advanced',
          title: 'Advanced',
          description: 'I\'m experienced and want to specialize further.',
          iconData: Icons.workspace_premium_outlined,
          iconBackground: const Color(0xFFE0194A),
        ),
      ],
    ),

    // Q4: Time Commitment
    QuizQuestion(
      id: 'time',
      prompt: 'How much time can you dedicate per week?',
      description: 'We\'ll recommend a pace that fits your schedule',
      options: [
        QuizOption(
          id: 'casual',
          title: '1-3 hours/week',
          description: 'Casual learning pace.',
          iconData: Icons.coffee_outlined,
          iconBackground: const Color(0xFF6B7280),
        ),
        QuizOption(
          id: 'regular',
          title: '4-7 hours/week',
          description: 'Steady, regular commitment.',
          iconData: Icons.access_time_outlined,
          iconBackground: const Color(0xFF3B82F6),
        ),
        QuizOption(
          id: 'serious',
          title: '8-15 hours/week',
          description: 'Serious learner, fast progress.',
          iconData: Icons.bolt_outlined,
          iconBackground: const Color(0xFFF59E0B),
        ),
        QuizOption(
          id: 'intensive',
          title: '15+ hours/week',
          description: 'Full-time intensive learning.',
          iconData: Icons.local_fire_department_outlined,
          iconBackground: const Color(0xFFE0194A),
        ),
      ],
    ),

    // Q5: Learning Style (Multi-Select)
    QuizQuestion(
      id: 'learning_style',
      prompt: 'How do you learn best?',
      description: 'Select all that apply',
      allowMultiSelect: true,
      options: [
        QuizOption(
          id: 'video',
          title: 'Video Lessons',
          description: 'Watch tutorials and demonstrations.',
          iconData: Icons.play_circle_outline,
          iconBackground: const Color(0xFFDC2E44),
        ),
        QuizOption(
          id: 'reading',
          title: 'Reading & Articles',
          description: 'In-depth text-based content.',
          iconData: Icons.menu_book_outlined,
          iconBackground: const Color(0xFF3B82F6),
        ),
        QuizOption(
          id: 'hands_on',
          title: 'Hands-on Projects',
          description: 'Learn by building real things.',
          iconData: Icons.build_outlined,
          iconBackground: const Color(0xFF10B981),
        ),
        QuizOption(
          id: 'interactive',
          title: 'Interactive Exercises',
          description: 'Quizzes, challenges, and practice.',
          iconData: Icons.quiz_outlined,
          iconBackground: const Color(0xFF9B59B6),
        ),
      ],
    ),
  ];

  // ── Quiz State ─────────────────────────────────────────────────────────
  int _currentQuestionIndex = 0;
  final Map<String, Set<String>> _selections = {};
  bool _saving = false;

  // ── Computed Properties ────────────────────────────────────────────────
  QuizQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  bool get _canContinue {
    final selected = _selections[_currentQuestion.id];
    return selected != null && selected.isNotEmpty;
  }

  double get _progress => (_currentQuestionIndex + 1) / _questions.length;

  // ── Handlers ───────────────────────────────────────────────────────────

  void _toggleOption(String optionId) {
    setState(() {
      final questionId = _currentQuestion.id;
      final current = _selections.putIfAbsent(questionId, () => <String>{});

      if (_currentQuestion.allowMultiSelect) {
        if (current.contains(optionId)) {
          current.remove(optionId);
        } else {
          current.add(optionId);
        }
      } else {
        _selections[questionId] = {optionId};
      }
    });
  }

  Future<void> _handleContinue() async {
    if (!_canContinue) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      // Move to next question
      setState(() => _currentQuestionIndex++);
    } else {
      // Last question - save to Firebase and navigate to HOME
      await _completeQuiz();
    }
  }

  /// Save quiz answers to Firebase and navigate to HOME SCREEN
  Future<void> _completeQuiz() async {
    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Not signed in. Please login again.');
        if (mounted) {
          // Bounce back to login if no user
          Navigator.pushReplacementNamed(context, '/learner-login');
        }
        return;
      }

      // Save quiz responses to learner profile
      final db = FirebaseFirestore.instance;
      final profileRef = db.collection('learnerProfiles').doc(user.uid);

      // Convert selections to Firestore-friendly format
      final responses = <String, dynamic>{};
      _selections.forEach((questionId, optionIds) {
        responses[questionId] = optionIds.toList();
      });

      debugPrint('📝 Saving quiz responses: $responses');

      // Save to learnerProfiles
      await profileRef.set({
        'userId': user.uid,
        'quizResponses': responses,
        'quizCompletedAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
        // Top-level fields for quick access
        'careerField': _selections['field']?.first,
        'primaryGoal': _selections['goal']?.first,
        'experienceLevel': _selections['experience']?.first,
        'weeklyHours': _selections['time']?.first,
        'topPriority': _selections['learning_style']?.toList(),
        'roadmapId': null,
      }, SetOptions(merge: true));

      // Also update user document with onboardingCompleted flag
      await db.collection('users').doc(user.uid).update({
        'onboardingCompleted': true,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Quiz saved successfully');

      // ✅ NAVIGATE TO LEARNER HOME SCREEN (instead of personalized roadmap)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LearnerHomeScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Quiz save error: $e');
      _showError('Failed to save quiz: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _handleBack() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    } else {
      // First question - confirm exit
      _showExitConfirmation();
    }
  }

  Future<void> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Skip Quiz?'),
        content: const Text(
          'The quiz helps us create your personalized roadmap. '
              'You can always take it later from your profile settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Skip',
              style: TextStyle(color: kPrimary),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Skip - still mark as completed so they go to home (with limited personalization)
      await _skipQuiz();
    }
  }

  /// Skip quiz but still go to home (no personalized data)
  Future<void> _skipQuiz() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'onboardingCompleted': true,
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LearnerHomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('❌ Skip quiz error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final selectedIds = _selections[_currentQuestion.id] ?? <String>{};

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Question Prompt ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentQuestion.prompt,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kFg,
                    height: 1.3,
                  ),
                ),
                if (_currentQuestion.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _currentQuestion.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kMutedFg,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Multi-select hint ──────────────────────────────────────────
          if (_currentQuestion.allowMultiSelect)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: kMutedFg),
                  const SizedBox(width: 6),
                  Text(
                    'Select multiple options',
                    style: TextStyle(
                      fontSize: 12,
                      color: kMutedFg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // ── Option Cards ───────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: _currentQuestion.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _currentQuestion.options[index];
                return _QuizOptionCard(
                  option: option,
                  isSelected: selectedIds.contains(option.id),
                  onTap: () => _toggleOption(option.id),
                );
              },
            ),
          ),

          // ── Continue Button ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: kCardBg,
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
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_canContinue && !_saving) ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    disabledBackgroundColor: kMuted,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Continue'
                            : 'Go to Home',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AppBar with Progress ───────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCardBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kFg),
        onPressed: _handleBack,
        tooltip: 'Back',
      ),
      title: Text(
        'Step ${_currentQuestionIndex + 1} of ${_questions.length}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: kMutedFg,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: ClipRRect(
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            backgroundColor: kMuted,
            valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  QUIZ OPTION CARD
// ============================================================
class _QuizOptionCard extends StatelessWidget {
  const _QuizOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final QuizOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? kPrimary : kBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: kPrimary.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: option.iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  option.iconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kFg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kMutedFg,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  key: ValueKey(isSelected),
                  color: isSelected ? kPrimary : kMutedFg,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
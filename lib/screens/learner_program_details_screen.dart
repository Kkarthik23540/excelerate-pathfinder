// lib/screens/learner_program_details_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Color constants (matches home + profile screens)
const kPrimary = Color(0xFFE0194A);
const kPurple = Color(0xFF9B59B6);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;
const kTeal = Color(0xFF0891B2);
const kOrange = Color(0xFFEA580C);

class LearnerProgramDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> program;

  const LearnerProgramDetailsScreen({super.key, required this.program});

  @override
  State<LearnerProgramDetailsScreen> createState() =>
      _LearnerProgramDetailsScreenState();
}

class _LearnerProgramDetailsScreenState
    extends State<LearnerProgramDetailsScreen> {
  bool _isEnrolling = false;
  bool _isEnrolled = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    if (_userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('enrolledPrograms')
          .doc(widget.program['id'])
          .get();
      if (mounted) {
        setState(() => _isEnrolled = doc.exists);
      }
    } catch (_) {}
  }

  Future<void> _enrollInProgram() async {
    if (_userId == null || _isEnrolling) return;

    setState(() => _isEnrolling = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('enrolledPrograms')
          .doc(widget.program['id'])
          .set({
        'programId': widget.program['id'],
        'title': widget.program['title'],
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': widget.program['progress'] ?? 0.0,
        'status': 'active',
      });

      // Also add to achievements
      final achievementsRef = FirebaseFirestore.instance
          .collection('achievements')
          .doc(_userId);
      await achievementsRef.set({
        'activeProgrammes': FieldValue.arrayUnion([
          {'programId': widget.program['id'], 'title': widget.program['title']}
        ])
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() => _isEnrolled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enrolled in ${widget.program['title']}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  IconData get _icon {
    final code = widget.program['iconCode'] as int? ?? Icons.menu_book.codePoint;
    return IconData(code, fontFamily: 'MaterialIcons');
  }

  Color get _iconColor {
    final value = widget.program['iconColor'] as int? ?? kTeal.value;
    return Color(value);
  }

  double get _progress =>
      (widget.program['progress'] as double?) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final title = widget.program['title'] as String? ?? 'Program';
    final modules = widget.program['modules'] as String? ?? '0 of 0 modules';

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildHeader(title),
              const SizedBox(height: 20),
              _buildProgressCard(modules),
              const SizedBox(height: 20),
              _buildAboutSection(),
              const SizedBox(height: 20),
              _buildCurriculumSection(),
              const SizedBox(height: 20),
              _buildInstructorSection(),
              const SizedBox(height: 24),
              _buildEnrollButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
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
        const Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to bookmarks'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
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
              child: const Icon(Icons.bookmark_outline, size: 20, color: kFg),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _iconColor,
            _iconColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _iconColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PROGRAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String modules) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kFg,
                ),
              ),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            modules,
            style: const TextStyle(fontSize: 12, color: kMutedFg),
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kPurple],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About this Program',
      child: const Text(
        'This comprehensive program covers all the essential topics you need to master. Learn from industry experts, complete hands-on projects, and earn a recognized certification upon completion.',
        style: TextStyle(
          fontSize: 13,
          color: kFg,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCurriculumSection() {
    final modules = [
      {'num': 1, 'title': 'Introduction & Setup', 'duration': '45 min', 'done': true},
      {'num': 2, 'title': 'Core Concepts', 'duration': '1h 20min', 'done': true},
      {'num': 3, 'title': 'Advanced Topics', 'duration': '2h 10min', 'done': false},
      {'num': 4, 'title': 'Final Project', 'duration': '3h 00min', 'done': false},
    ];

    return _buildSection(
      title: 'Curriculum',
      child: Column(
        children: modules.map((m) {
          final isDone = m['done'] as bool;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? kPrimary : kBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? kPrimary : kBorder,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.play_arrow,
                    color: isDone ? Colors.white : kMutedFg,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Module ${m['num']}: ${m['title']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDone ? kFg : kMutedFg,
                        ),
                      ),
                      Text(
                        m['duration'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: kMutedFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructorSection() {
    return _buildSection(
      title: 'Instructor',
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'DR',
                style: TextStyle(
                  color: kPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Elena Rodriguez',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kFg,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Senior Industry Expert',
                  style: TextStyle(fontSize: 12, color: kMutedFg),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: kPrimary, size: 18),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kFg,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEnrollButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isEnrolling || _isEnrolled ? null : _enrollInProgram,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          disabledBackgroundColor: kPrimary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isEnrolling
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEnrolled ? Icons.check_circle : Icons.school_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _isEnrolled ? 'Already Enrolled' : 'Enroll in Program',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
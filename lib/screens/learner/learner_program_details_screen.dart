// lib/screens/learner_program_details_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Added for live links

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

    // ✅ ADDED: Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enroll in Program?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you ready to start your journey with ${widget.program['title']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Maybe later')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Yes, let\'s go!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isEnrolling = true);
    try {
      // 1. Add to user's enrolledPrograms
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('enrolledPrograms')
          .doc(widget.program['id'])
          .set({
        'programId': widget.program['id'],
        'title': widget.program['title'],
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': 0.0,
        'status': 'active',
      });

      // 2. Add to achievements
      final achievementsRef = FirebaseFirestore.instance
          .collection('achievements')
          .doc(_userId);
      await achievementsRef.set({
        'activeProgrammes': FieldValue.arrayUnion([
          {'programId': widget.program['id'], 'title': widget.program['title']}
        ])
      }, SetOptions(merge: true));

      // 3. Add to global enrollments for Admin dashboard
      await FirebaseFirestore.instance.collection('enrollments').add({
        'userId': _userId,
        'programId': widget.program['id'],
        'title': widget.program['title'],
        'enrolledAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isEnrolled = true);
        _showSnackBar('Enrolled in ${widget.program['title']}!');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  Future<void> _completeProgram() async {
    if (_userId == null) return;

    setState(() => _isEnrolling = true);
    try {
      final cert = {
        'id': 'cert_${widget.program['id']}',
        'title': widget.program['title'],
        'date': DateTime.now().toString(),
        'programId': widget.program['id'],
      };

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'certificates': FieldValue.arrayUnion([cert]),
      });

      await FirebaseFirestore.instance.collection('certificates').doc(cert['id']).set({
        ...cert,
        'userId': _userId,
        'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'Learner',
        'issuedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('enrolledPrograms')
          .doc(widget.program['id'])
          .update({'status': 'completed', 'progress': 1.0});

      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Congratulations!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('You have successfully completed ${widget.program['title']}. Your certificate is now available in your profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : kPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('programs').doc(widget.program['id']).snapshots(),
      builder: (context, snapshot) {
        Map<String, dynamic> liveProgram = widget.program;
        if (snapshot.hasData && snapshot.data!.exists) {
          liveProgram = snapshot.data!.data() as Map<String, dynamic>;
          liveProgram['id'] = snapshot.data!.id;
        }

        final title = liveProgram['title'] as String? ?? 'Program';
        final modules = liveProgram['modules'] as String? ?? '0 of 0 modules';
        final description = liveProgram['description'] as String? ??
            'This comprehensive program covers all the essential topics you need to master. Learn from industry experts, complete hands-on projects, and earn a recognized certification upon completion.';
        final instructor = liveProgram['instructor'] as String? ?? 'Excelerate Expert';
        final iconCode = liveProgram['iconCode'] as int? ?? Icons.menu_book.codePoint;
        final iconColorValue = liveProgram['iconColor'] as int? ?? kTeal.value;
        final Color iconColor = Color(iconColorValue);
        final List<dynamic> curriculum = liveProgram['curriculum'] ?? [];

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
                  _buildHeader(title, iconColor, iconCode),
                  const SizedBox(height: 20),
                  _buildLiveSessionBanner(), // ✅ Added Live Session Banner
                  const SizedBox(height: 10),
                  _buildProgressCard(modules),
                  const SizedBox(height: 20),
                  _buildAboutSection(description),
                  const SizedBox(height: 20),
                  _buildCurriculumSection(curriculum),
                  const SizedBox(height: 20),
                  _buildInstructorSection(instructor),
                  const SizedBox(height: 24),
                  _buildEnrollButton(title),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildLiveSessionBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('live_sessions').doc(widget.program['id']).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        final data = snapshot.data!.data() as Map<String, dynamic>;
        if (data['isLive'] != true) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.video_camera_front_rounded, color: Colors.redAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LIVE SESSION NOW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12)),
                    Text('Join Prof. ${data['tutorName']} for a live explanation.', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(data['link'])),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0),
                child: const Text('JOIN'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String title, Color iconColor, int iconCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor,
            iconColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
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
            child: Icon(IconData(iconCode, fontFamily: 'MaterialIcons'), color: Colors.white, size: 36),
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
    if (_userId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('enrolledPrograms')
          .doc(widget.program['id'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final double progress = (data['progress'] as num?)?.toDouble() ?? 0.0;

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
                    '${(progress * 100).round()}%',
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
                    widthFactor: progress.clamp(0.0, 1.0),
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
      },
    );
  }

  Widget _buildAboutSection(String description) {
    return _buildSection(
      title: 'About this Program',
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 13,
          color: kFg,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCurriculumSection(List<dynamic> curriculum) {
    final List<dynamic> modulesData = curriculum.isNotEmpty ? curriculum : [
      {'num': 1, 'title': 'Introduction & Setup', 'duration': '45 min', 'done': true},
      {'num': 2, 'title': 'Core Concepts', 'duration': '1h 20min', 'done': true},
      {'num': 3, 'title': 'Advanced Topics', 'duration': '2h 10min', 'done': false},
      {'num': 4, 'title': 'Final Project', 'duration': '3h 00min', 'done': false},
    ];

    return _buildSection(
      title: 'Curriculum',
      child: Column(
        children: modulesData.map((m) {
          final isDone = m['done'] as bool? ?? false;
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
                        (m['duration'] ?? '') as String,
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

  Widget _buildInstructorSection(String instructor) {
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
            child: Center(
              child: Text(
                _getInitials(instructor),
                style: const TextStyle(
                  color: kPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kFg,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
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

  String _getInitials(String name) {
    if (name.isEmpty) return 'EX';
    return name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
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

  Widget _buildEnrollButton(String title) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isEnrolling 
            ? null 
            : (!_isEnrolled ? _enrollInProgram : _completeProgram),
        style: ElevatedButton.styleFrom(
          backgroundColor: !_isEnrolled ? kPrimary : Colors.green,
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
              !_isEnrolled ? Icons.school_rounded : Icons.verified_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              !_isEnrolled ? 'Enroll in Program' : 'Mark as Complete',
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

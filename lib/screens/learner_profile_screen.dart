// lib/screens/learner_profile_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import '../widgets/learner_bottom_nav.dart';
import 'splash_screen.dart';  // ✅ Import the splash screen

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
const kYellowTip = Color(0xFFFFF8E1);
const kYellowBar = Color(0xFFF59E0B);
const kSuccess = Color(0xFF22C55E);
const kGradientRed = Color(0xFFC0392B);
const kGradientPurple = Color(0xFF9B59B6);
const kAuthAccentDark = Color(0xFFE53935);

// ============================================================
//  BADGE DEFINITIONS
// ============================================================
class _BadgeDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String criteria;

  const _BadgeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.criteria,
  });

  static const List<_BadgeDef> all = [
    _BadgeDef(
      id: 'early_accelerator',
      name: 'EARLY ACCELERATOR',
      description: 'Joined Excelerate Pathfinder',
      icon: Icons.rocket,
      color: kPrimary,
      criteria: 'signup',
    ),
    _BadgeDef(
      id: 'quick_starter',
      name: 'QUICK STARTER',
      description: 'Completed your first step',
      icon: Icons.flash_on,
      color: kYellowBar,
      criteria: 'first_step',
    ),
    _BadgeDef(
      id: 'strategic_mind',
      name: 'STRATEGIC MIND',
      description: 'Reached 250 XP',
      icon: Icons.psychology,
      color: kPurple,
      criteria: 'xp_250',
    ),
    _BadgeDef(
      id: 'collaborator',
      name: 'COLLABORATOR',
      description: 'Shared progress 3 times',
      icon: Icons.group,
      color: kPrimary,
      criteria: 'shares_3',
    ),
    _BadgeDef(
      id: 'course_completion',
      name: 'COURSE COMPLETION',
      description: 'Completed your first course',
      icon: Icons.school,
      color: kPurple,
      criteria: 'first_course',
    ),
    _BadgeDef(
      id: 'master_pathfinder',
      name: 'MASTER PATHFINDER',
      description: 'Reached Level 5 (2500 XP)',
      icon: Icons.workspace_premium,
      color: kMutedFg,
      criteria: 'level_5',
    ),
  ];
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userId;
  bool _isEditMode = false;
  int _totalShares = 0;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _loadShareCount();
  }

  Future<void> _loadShareCount() async {
    if (_userId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('progressShares')
          .where('userId', isEqualTo: _userId)
          .count()
          .get();
      if (mounted) {
        setState(() => _totalShares = snapshot.count ?? 0);
      }
    } catch (_) {}
  }

  DocumentReference? get _userRef => _userId != null
      ? FirebaseFirestore.instance.collection('users').doc(_userId)
      : null;
  DocumentReference? get _achievementsRef => _userId != null
      ? FirebaseFirestore.instance.collection('achievements').doc(_userId)
      : null;

  // ============================================================
  //  BADGE UNLOCK LOGIC
  // ============================================================
  Future<bool> _unlockBadge(String badgeId) async {
    if (_userId == null) return false;

    final def = _BadgeDef.all.firstWhere(
          (b) => b.id == badgeId,
      orElse: () => const _BadgeDef(
        id: '',
        name: '',
        description: '',
        icon: Icons.error,
        color: Colors.grey,
        criteria: '',
      ),
    );
    if (def.id.isEmpty) return false;

    try {
      final achievementsRef = FirebaseFirestore.instance
          .collection('achievements')
          .doc(_userId);
      final doc = await achievementsRef.get();

      if (doc.exists) {
        final badges = doc.data()?['badges'];
        if (badges is List) {
          final alreadyUnlocked =
          badges.any((b) => b is Map && b['badgeId'] == badgeId);
          if (alreadyUnlocked) return false;
        }
      }

      await achievementsRef.set({
        'badges': FieldValue.arrayUnion([
          {
            'badgeId': badgeId,
            'name': def.name,
            'description': def.description,
            'unlockedAt': DateTime.now().toIso8601String(),
          }
        ]),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Badge unlock error: $e');
      return false;
    }
  }

  // ============================================================
  //  CHECK AND UNLOCK BADGES (with celebration!)
  // ============================================================
  Future<List<String>> _checkAndUnlockBadges({
    required int totalXP,
    required int level,
  }) async {
    final List<String> newlyUnlocked = [];

    if (totalXP >= 50) {
      if (await _unlockBadge('quick_starter')) {
        newlyUnlocked.add('quick_starter');
      }
    }

    if (totalXP >= 250) {
      if (await _unlockBadge('strategic_mind')) {
        newlyUnlocked.add('strategic_mind');
      }
    }

    if (_totalShares >= 3) {
      if (await _unlockBadge('collaborator')) {
        newlyUnlocked.add('collaborator');
      }
    }

    if (totalXP >= 500) {
      if (await _unlockBadge('course_completion')) {
        newlyUnlocked.add('course_completion');
      }
    }

    if (level >= 5) {
      if (await _unlockBadge('master_pathfinder')) {
        newlyUnlocked.add('master_pathfinder');
      }
    }

    if (newlyUnlocked.isNotEmpty && mounted) {
      for (int i = 0; i < newlyUnlocked.length; i++) {
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 3500));
        }
        if (!mounted) break;

        final def = _BadgeDef.all.firstWhere(
              (b) => b.id == newlyUnlocked[i],
        );
        await _showBadgeCelebration(
          badgeName: def.name,
          description: def.description,
          icon: def.icon,
          color: def.color,
        );
      }
    }

    return newlyUnlocked;
  }

  // ============================================================
  //  BADGE CELEBRATION OVERLAY
  // ============================================================
  Future<void> _showBadgeCelebration({
    required String badgeName,
    required String description,
    required IconData icon,
    required Color color,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Badge Celebration',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _BadgeCelebrationOverlay(
          badgeName: badgeName,
          description: description,
          icon: icon,
          color: color,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null || _userRef == null) {
      return Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: kPrimary),
              const SizedBox(height: 16),
              const Text('Not signed in'),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: const Text('Go to Login',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: _buildProfileTab(),
      bottomNavigationBar: const BottomNav(
        currentDestination: HomeNavDestination.profile,
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            _isEditMode
                ? _buildEditProfileLayout()
                : _buildProfileHeaderCard(),
            const SizedBox(height: 20),
            _buildBadgesSection(),
            const SizedBox(height: 20),
            _buildAccountSection(),
            const SizedBox(height: 16),
            _buildAcceleratorTip(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TOP BAR (Logo + Brand Name only - NO avatar on right)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
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
      ],
    );
  }

  // ✅ Profile Header Card with gradient banner + avatar
  Widget _buildProfileHeaderCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userRef!.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(280);
        }
        if (snapshot.hasError) {
          return _buildErrorCard('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildErrorCard('User profile not found.');
        }

        final rawData = snapshot.data!.data();
        if (rawData is! Map) {
          return _buildErrorCard('Invalid data format');
        }
        final userData = Map<String, dynamic>.from(rawData);

        final name = (userData['displayName'] as String?) ?? 'No name';
        final title = (userData['title'] as String?) ?? 'Learner';
        final tier = (userData['tier'] as String?) ?? 'Velocity Tier 1';
        final email = (userData['email'] as String?) ?? '';
        final phone = (userData['phone'] as String?) ?? '';

        return Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, kPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(name),
                              style: const TextStyle(
                                  color: kPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isEditMode = true);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: kPurple,
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: kFg,
                            letterSpacing: -0.3,
                            height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildInfoPill(
                          icon: Icons.badge_rounded,
                          label: title,
                          color: kPrimary,
                        ),
                        _buildInfoPill(
                          icon: Icons.workspace_premium_rounded,
                          label: tier,
                          color: kPurple,
                        ),
                      ],
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildContactRow(Icons.email_outlined, email),
                    ],
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildContactRow(Icons.phone_outlined, phone),
                    ],
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _isEditMode = true);
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: kMutedFg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: kMutedFg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileLayout() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final tierCtrl = TextEditingController();

    return StreamBuilder<DocumentSnapshot>(
      stream: _userRef!.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (nameCtrl.text.isEmpty) {
            nameCtrl.text = data['displayName'] ?? '';
            phoneCtrl.text = data['phone'] ?? '';
            titleCtrl.text = data['title'] ?? 'Learner';
            tierCtrl.text = data['tier'] ?? 'Velocity Tier 1';
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPurple.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: kPurple, size: 20),
                  const SizedBox(width: 8),
                  const Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _isEditMode = false),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: kMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: kMutedFg),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildEditField(
                  label: 'Full Name',
                  controller: nameCtrl,
                  icon: Icons.person_outline),
              const SizedBox(height: 12),
              _buildEditField(
                  label: 'Phone Number',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined),
              const SizedBox(height: 12),
              _buildEditField(
                  label: 'Title',
                  controller: titleCtrl,
                  icon: Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildEditField(
                  label: 'Tier',
                  controller: tierCtrl,
                  icon: Icons.workspace_premium_outlined),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditMode = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: kBorder, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: kFg, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveProfile(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            title: titleCtrl.text.trim(),
                            tier: tierCtrl.text.trim(),
                          );
                          if (mounted) {
                            setState(() => _isEditMode = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save Changes',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
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

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: kMutedFg),
          prefixIcon: Icon(icon, color: kPurple, size: 18),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _saveProfile({
    required String name,
    required String phone,
    required String title,
    required String tier,
  }) async {
    if (name.isEmpty) {
      _showSnackbar('Name cannot be empty', isError: true);
      return;
    }
    try {
      await _userRef!.update({
        'displayName': name,
        'phone': phone,
        'title': title,
        'tier': tier,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      _showSnackbar('✅ Profile updated!');
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  Widget _buildBadgesSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _achievementsRef!.snapshots(),
      builder: (context, snapshot) {
        List<String> unlockedIds = [];
        if (snapshot.hasData && snapshot.data!.exists) {
          final rawData = snapshot.data!.data();
          if (rawData is Map) {
            final badgesList = rawData['badges'];
            if (badgesList is List) {
              for (var badge in badgesList) {
                if (badge is Map) {
                  final badgeId = badge['badgeId'];
                  if (badgeId is String) {
                    unlockedIds.add(badgeId);
                  }
                }
              }
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Earned Badges',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${unlockedIds.length}/${_BadgeDef.all.length}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kPrimary),
                      ),
                    ),
                  ],
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showAllBadgesDialog(unlockedIds),
                    child: const Row(
                      children: [
                        Text('View All',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kPrimary)),
                        Icon(Icons.chevron_right, color: kPrimary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: _BadgeDef.all.map((b) {
                final isUnlocked = unlockedIds.contains(b.id);
                return _buildBadgeCard(
                  name: b.name,
                  description: b.description,
                  icon: b.icon,
                  color: b.color,
                  unlocked: isUnlocked,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeCard({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required bool unlocked,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showBadgeDetails(name, description, unlocked, color),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked ? kCardBg : kMuted.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: unlocked ? color.withOpacity(0.3) : kMuted,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: unlocked ? color.withOpacity(0.15) : kMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: unlocked ? color : kMutedFg, size: 22),
              ),
              const SizedBox(height: 8),
              Text(name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: unlocked ? kFg : kMutedFg,
                      letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                unlocked ? 'UNLOCKED' : 'LOCKED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: unlocked ? kSuccess : kMutedFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              _buildAccountRow(
                icon: Icons.lock_outline,
                title: 'Security & Privacy',
                subtitle: 'Change password',
                onTap: _showChangePasswordDialog,
              ),
              const Divider(color: kBorder, height: 1, indent: 60),
              _buildAccountRow(
                icon: Icons.workspace_premium_outlined,
                title: 'Subscription',
                subtitle: 'Manage your Pathfinder Pro membership',
                onTap: _showSubscriptionMessage,
              ),
              const Divider(color: kBorder, height: 1, indent: 60),
              _buildAccountRow(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Alerts and progress updates',
                onTap: _showNotificationPrefsDialog,
              ),
              const Divider(color: kBorder, height: 1, indent: 60),
              _buildAccountRow(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: '',
                isDestructive: true,
                onTap: _handleLogout,
              ),
              const Divider(color: kBorder, height: 1, indent: 60),
              _buildAccountRow(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                isDestructive: true,
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? kPrimary : kFg;
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color)),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 11, color: kMutedFg),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: kMutedFg, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcceleratorTip() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
      decoration: BoxDecoration(
        color: kYellowTip,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: kYellowBar, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 17, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accelerator Tip',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E))),
                SizedBox(height: 3),
                Text(
                  "Complete more steps to unlock new badges and climb the leaderboard!",
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF78350F),
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(double height) => Container(
    height: height,
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2)),
  );

  Widget _buildErrorCard(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kPrimary.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline, color: kPrimary),
      const SizedBox(width: 12),
      Expanded(
          child: Text(msg, style: const TextStyle(color: kPrimary))),
    ]),
  );

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? kPrimary : kSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: kPrimary),
            SizedBox(width: 8),
            Text('Change Password'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (currentPassCtrl.text.isEmpty ||
                  newPassCtrl.text.isEmpty ||
                  confirmPassCtrl.text.isEmpty) {
                _showSnackbar('All fields are required', isError: true);
                return;
              }
              if (newPassCtrl.text != confirmPassCtrl.text) {
                _showSnackbar('New passwords do not match', isError: true);
                return;
              }
              if (newPassCtrl.text.length < 6) {
                _showSnackbar('Password must be 6+ characters', isError: true);
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.email == null) return;

                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPassCtrl.text,
                );
                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPassCtrl.text);
                Navigator.pop(context, true);
              } on FirebaseAuthException catch (e) {
                String errorMsg = 'Failed to change password';
                if (e.code == 'wrong-password') {
                  errorMsg = 'Current password is incorrect';
                } else if (e.code == 'weak-password') {
                  errorMsg = 'New password is too weak';
                } else if (e.message != null) {
                  errorMsg = e.message!;
                }
                if (mounted) {
                  _showSnackbar(errorMsg, isError: true);
                }
                Navigator.pop(context, false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Update',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      _showSnackbar('✅ Password changed successfully!');
    }
  }

  void _showSubscriptionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '⭐ Subscription feature will be added soon!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ✅ CHANGED: Delete Account - goes to SplashScreen
  Future<void> _showDeleteAccountDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: kPrimary),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
            'Are you sure? This will PERMANENTLY delete:\n\n• Your profile\n• Your achievements\n• Your learner data\n\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Delete Forever',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await _userRef!.delete();
        await _achievementsRef!.delete();
        final learnerProfileRef = FirebaseFirestore.instance
            .collection('learnerProfiles')
            .doc(user.uid);
        await learnerProfileRef.delete().catchError((_) {});

        await user.delete();

        if (mounted) {
          // ✅ Navigate to SplashScreen (not the loading circle)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
          );
          _showSnackbar('Account deleted');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          _showSnackbar(
              'Please logout and login again before deleting account',
              isError: true);
        } else {
          _showSnackbar('Error: ${e.message}', isError: true);
        }
      } catch (e) {
        _showSnackbar('Error: $e', isError: true);
      }
    }
  }

  Future<void> _showNotificationPrefsDialog() async {
    try {
      final userDoc = await _userRef!.get();
      final rawData = userDoc.data();
      final userData = rawData is Map ? rawData : <String, dynamic>{};

      final notifRaw = userData['notificationPrefs'];
      final prefs = notifRaw is Map
          ? Map<String, bool>.from(notifRaw)
          : <String, bool>{};

      if (!mounted) return;

      final result = await showDialog<Map<String, bool>>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Notification Preferences'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Deadline Reminders'),
                    value: prefs['deadlineReminders'] ?? true,
                    activeColor: kPrimary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setState(() => prefs['deadlineReminders'] = v),
                  ),
                  SwitchListTile(
                    title: const Text('Session Alerts'),
                    value: prefs['sessionAlerts'] ?? true,
                    activeColor: kPrimary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setState(() => prefs['sessionAlerts'] = v),
                  ),
                  SwitchListTile(
                    title: const Text('Progress Updates'),
                    value: prefs['progressUpdates'] ?? true,
                    activeColor: kPrimary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setState(() => prefs['progressUpdates'] = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, prefs),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: const Text('Save',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ),
      );

      if (result != null) {
        await _userRef!.update({'notificationPrefs': result});
        if (mounted) _showSnackbar('✅ Preferences saved!');
      }
    } catch (e) {
      if (mounted) _showSnackbar('Error: $e', isError: true);
    }
  }

  void _showBadgeDetails(
      String name, String description, bool unlocked, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: unlocked ? color.withOpacity(0.15) : kMuted,
              shape: BoxShape.circle,
              border: unlocked
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Icon(
                unlocked ? Icons.workspace_premium : Icons.lock_outline,
                color: unlocked ? color : kMutedFg,
                size: 36),
          ),
          const SizedBox(height: 16),
          Text(name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kMutedFg)),
          const SizedBox(height: 12),
          if (unlocked)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: kSuccess),
                  SizedBox(width: 4),
                  Text('Unlocked!',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kSuccess)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('🔒 Locked',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kMutedFg)),
            ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAllBadgesDialog(List<String> unlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
        Text('All Badges (${unlocked.length}/${_BadgeDef.all.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _BadgeDef.all.map((b) {
              final isUnlocked = unlocked.contains(b.id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isUnlocked
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isUnlocked ? kSuccess : kMutedFg,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color:
                                  isUnlocked ? kFg : kMutedFg)),
                          Text(b.description,
                              style: const TextStyle(
                                  fontSize: 11, color: kMutedFg)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  // ✅ CHANGED: Logout - goes to SplashScreen (not loading circle)
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: const Text('Logout',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userRef!.update(
            {'lastActiveAt': FieldValue.serverTimestamp()});
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          // ✅ Navigate to SplashScreen (not the loading circle)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
          );
        }
      } catch (e) {
        if (mounted) _showSnackbar('Logout failed: $e', isError: true);
      }
    }
  }
}

// ============================================================
//  BADGE CELEBRATION OVERLAY (unchanged)
// ============================================================
class _BadgeCelebrationOverlay extends StatefulWidget {
  final String badgeName;
  final String description;
  final IconData icon;
  final Color color;

  const _BadgeCelebrationOverlay({
    required this.badgeName,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  State<_BadgeCelebrationOverlay> createState() =>
      _BadgeCelebrationOverlayState();
}

class _BadgeCelebrationOverlayState extends State<_BadgeCelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _rotateController;
  late final AnimationController _shineController;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _shineController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Color(0xFFE0194A),
                Color(0xFF9B59B6),
                Color(0xFFF59E0B),
                Color(0xFF22C55E),
                Color(0xFF0284C7),
                Color(0xFFEC4899),
                Color(0xFFFBBF24),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 0,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.08,
              numberOfParticles: 15,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Color(0xFFE0194A),
                Color(0xFF9B59B6),
                Color(0xFFF59E0B),
                Color(0xFF22C55E),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.08,
              numberOfParticles: 15,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Color(0xFFE0194A),
                Color(0xFF9B59B6),
                Color(0xFFF59E0B),
                Color(0xFF22C55E),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _scaleController,
                      curve: const Interval(0.1, 1.0, curve: Curves.elasticOut),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.celebration,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'BADGE UNLOCKED!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.celebration,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.elasticOut,
                    ),
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _rotateController,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.color.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: CustomPaint(
                                painter: _DashedCirclePainter(
                                    color: widget.color),
                              ),
                            ),
                          ),
                          _PulsingGlowRing(color: widget.color),
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  widget.color.withOpacity(0.9),
                                  widget.color.withOpacity(0.5),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.6),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _shineController,
                                  builder: (context, child) {
                                    return ClipOval(
                                      child: Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment(
                                              -1.0 +
                                                  _shineController.value * 2,
                                              -0.3,
                                            ),
                                            end: Alignment(
                                              -0.5 +
                                                  _shineController.value * 2,
                                              0.3,
                                            ),
                                            colors: [
                                              Colors.transparent,
                                              Colors.white
                                                  .withOpacity(0.4),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.5, 1.0],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _scaleController,
                      curve: const Interval(0.5, 1.0),
                    ),
                    child: Text(
                      widget.badgeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _scaleController,
                      curve: const Interval(0.6, 1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _scaleController,
                      curve: const Interval(0.7, 1.0),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_forward_rounded,
                                  color: widget.color, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Continue',
                                style: TextStyle(
                                  color: widget.color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  PULSING GLOW RING
// ============================================================
class _PulsingGlowRing extends StatefulWidget {
  final Color color;
  const _PulsingGlowRing({required this.color});

  @override
  State<_PulsingGlowRing> createState() => _PulsingGlowRingState();
}

class _PulsingGlowRingState extends State<_PulsingGlowRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          width: 130 + (_ctrl.value * 40),
          height: 130 + (_ctrl.value * 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(1 - _ctrl.value),
              width: 3,
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
//  DASHED CIRCLE PAINTER
// ============================================================
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const dashCount = 24;
    final dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// lib/screens/learner_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../widgets/learner_bottom_nav.dart';
import '../splash_screen.dart';

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
            _buildCertificatesSection(),
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
                    // Display Title and Stats in real-time
                    StreamBuilder<DocumentSnapshot>(
                      stream: _achievementsRef?.snapshots() ?? const Stream.empty(),
                      builder: (context, achSnap) {
                        int level = 1;
                        if (achSnap.hasData && achSnap.data!.exists) {
                          final data = achSnap.data!.data() as Map<String, dynamic>?;
                          level = data?['level'] ?? 1;
                        }

                        return Wrap(
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
                              icon: Icons.auto_graph_rounded,
                              label: 'Level $level',
                              color: kPurple,
                            ),
                          ],
                        );
                      }
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

    return StreamBuilder<DocumentSnapshot>(
      stream: _userRef!.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (nameCtrl.text.isEmpty) {
            nameCtrl.text = data['displayName'] ?? '';
            phoneCtrl.text = data['phone'] ?? '';
            titleCtrl.text = data['title'] ?? 'Learner';
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
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      _showSnackbar('✅ Profile updated!');
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }


  Widget _buildCertificatesSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userRef!.snapshots(),
      builder: (context, snapshot) {
        List<dynamic> certs = [];
        String userName = 'Learner';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          certs = data['certificates'] ?? [];
          userName = data['displayName'] ?? 'Learner';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Certificates',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                if (certs.isNotEmpty)
                  Text('${certs.length} Total',
                      style: const TextStyle(
                          color: kPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (certs.isEmpty)
              _buildEmptyCertCard()
            else
              Column(
                children: certs.map((c) => _buildCertTile(c, userName)).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCertCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium_outlined, color: kMutedFg, size: 40),
          const SizedBox(height: 12),
          const Text('No certificates yet',
              style: TextStyle(fontWeight: FontWeight.w700, color: kFg)),
          const Text('Complete programs to earn verified certificates.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kMutedFg)),
        ],
      ),
    );
  }

  Widget _buildCertTile(dynamic cert, String userName) {
    final title = cert is Map ? cert['title'] ?? 'Program Certificate' : 'Certificate';
    final date = cert is Map ? cert['date'] ?? '' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CertificateViewScreen(
                  userName: userName,
                  programName: title,
                  date: date,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: kPrimary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const Text('Verified by Excelerate', style: TextStyle(fontSize: 11, color: kMutedFg)),
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

// ════════════════════════════════════════════════════════════════════
//  CERTIFICATE VIEW SCREEN (LANDSCAPE)
// ════════════════════════════════════════════════════════════════════
class CertificateViewScreen extends StatefulWidget {
  final String userName;
  final String programName;
  final String date;

  const CertificateViewScreen({
    super.key,
    required this.userName,
    required this.programName,
    required this.date,
  });

  @override
  State<CertificateViewScreen> createState() => _CertificateViewScreenState();
}

class _CertificateViewScreenState extends State<CertificateViewScreen> {
  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Return to portrait when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(widget.date);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    final formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
    final year = parsedDate.year.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Container(color: Colors.white),
          
          // Main Certificate Content
          Center(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    width: 842, // Standard A4 Landscape width in points
                    height: 595, // Standard A4 Landscape height in points
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      border: Border.all(color: kPrimary, width: 12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kPurple.withOpacity(0.3), width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch_rounded, color: kPrimary, size: 60),
                            const SizedBox(height: 10),
                            const Text(
                              'EXCELERATE PATHFINDER',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(width: 400, child: Divider(thickness: 1, color: kBorder)),
                            const SizedBox(height: 20),
                            const Text(
                              'CERTIFICATE OF COMPLETION',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: kFg,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'This is to certify that',
                              style: TextStyle(fontSize: 16, color: kMutedFg),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.userName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: kPurple,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'serif',
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'has successfully completed the program',
                              style: TextStyle(fontSize: 16, color: kMutedFg),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.programName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: kFg,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSignPart(formattedDate, 'DATE'),
                                const SizedBox(width: 40),
                                _buildSignPart(year, 'YEAR'),
                                const SizedBox(width: 40),
                                _buildSignPart('Excelerate Team', 'AUTHORIZED SIGNATURE', isItalic: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Close Button
          Positioned(
            top: 20,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.05),
              child: IconButton(
                icon: const Icon(Icons.close, color: kFg, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignPart(String value, String label, {bool isItalic = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 160,
          height: 1,
          color: kBorder,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: kMutedFg, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}


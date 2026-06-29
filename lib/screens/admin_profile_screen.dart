// lib/screens/admin/admin_profile_screen.dart
import 'package:excelerate_pathfinder/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_bottom_nav.dart';
import 'admin_login_screen.dart';

const kAdminPrimary = Color(0xFF1E40AF);
const kAdminAccent = Color(0xFF0EA5E9);
const kAdminSuccess = Color(0xFF059669);
const kAdminDanger = Color(0xFFDC2626);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _adminId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildAccountSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(
        currentDestination: AdminNavDestination.profile,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text('Admin Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: kFg),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    if (_adminId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_adminId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildLoadingCard();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['displayName'] ?? 'Admin';
        final email = data['email'] ?? '';
        final role = data['role'] ?? 'admin';

        return Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAdminPrimary, kAdminAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -45),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: kAdminAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(name),
                              style: const TextStyle(
                                color: kAdminPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _showEditDialog,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: kAdminAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kAdminDanger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: kAdminDanger,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.email_outlined,
                              size: 14, color: kMutedFg),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(email,
                                style: const TextStyle(
                                    fontSize: 12, color: kMutedFg),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildAccountRow(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your admin password',
            onTap: _showChangePasswordDialog,
          ),
          const Divider(color: kBorder, height: 1, indent: 60),
          _buildAccountRow(
            icon: Icons.security,
            title: 'Two-Factor Auth',
            subtitle: 'Add extra security',
            onTap: _show2FADialog,
          ),
          const Divider(color: kBorder, height: 1, indent: 60),
          _buildAccountRow(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Manage admin alerts',
            onTap: () {},
          ),
          const Divider(color: kBorder, height: 1, indent: 60),
          _buildAccountRow(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of admin panel',
            isDestructive: true,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? kAdminDanger : kFg;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
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
                              fontSize: 11, color: kMutedFg)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMutedFg, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() => Container(
    height: 200,
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name.split(' ').where((s) => s.isNotEmpty).take(2)
        .map((s) => s[0].toUpperCase()).join();
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController();
    FirebaseFirestore.instance.collection('users').doc(_adminId).get().then((doc) {
      if (doc.exists) {
        nameCtrl.text = doc['displayName'] ?? '';
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(_adminId).update({
                  'displayName': nameCtrl.text.trim(),
                });
                Navigator.pop(context);
                _showSnackBar('✅ Profile updated');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAdminPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: const Text(
            'A password reset email will be sent to your registered email address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user?.email != null) {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                  Navigator.pop(context);
                  _showSnackBar('✅ Reset email sent');
                }
              } catch (e) {
                _showSnackBar('Error: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAdminPrimary),
            child: const Text('Send Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Two-Factor Authentication'),
        content: const Text(
            '2FA adds an extra layer of security. This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kAdminDanger),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'ADMIN_LOGOUT',
        'performedBy': adminId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
        );
      }
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? kAdminDanger : kAdminSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
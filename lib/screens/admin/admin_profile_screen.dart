// lib/screens/admin/admin_profile_screen.dart
import 'package:excelerate_pathfinder/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_bottom_nav.dart';
import 'admin_announcements_screen.dart';

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
  bool _viewingFeedback = false;
  bool _isEditingName = false;
  String? _infoPageTitle;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adminId = FirebaseAuth.instance.currentUser?.uid;
    _loadCurrentName();
  }

  void _loadCurrentName() {
    if (_adminId != null) {
      FirebaseFirestore.instance.collection('users').doc(_adminId).get().then((doc) {
        if (doc.exists && mounted) {
          setState(() {
            _nameController.text = doc['displayName'] ?? '';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    if (_viewingFeedback) {
      currentView = _buildFeedbackView();
    } else if (_isEditingName) {
      currentView = _buildEditNameView();
    } else {
      currentView = _buildProfileView();
    }

    bool hideNav = _viewingFeedback || _isEditingName;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: currentView,
        ),
      ),
      bottomNavigationBar: hideNav 
        ? null 
        : const AdminBottomNav(currentDestination: AdminNavDestination.profile),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      key: const ValueKey('profile_view'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildAccountSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text('Admin Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        _buildNotificationIcon(),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: kFg),
              onPressed: () {
                // ✅ Notification icon now opens Announcements
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen()),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: kAdminDanger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard() {
    if (_adminId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_adminId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return _buildLoadingCard();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['displayName'] ?? 'Admin';
        final email = data['email'] ?? '';
        final role = data['role'] ?? 'admin';

        return Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [kAdminPrimary, kAdminAccent]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 41,
                            backgroundColor: kAdminAccent.withOpacity(0.1),
                            child: Text(_getInitials(name), style: const TextStyle(color: kAdminPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _isEditingName = true), // ✅ UI edit mode
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: kAdminAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)]),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(role.toUpperCase(), style: const TextStyle(color: kAdminDanger, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(email, style: const TextStyle(fontSize: 13, color: kMutedFg)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildSimpleStat('Feedbacks', 'feedback', Icons.chat_bubble_outline, kAdminAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildSimpleStat('Programs', 'programs', Icons.auto_stories_outlined, kAdminSuccess)),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String collection, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snap) {
        String val = snap.hasData ? snap.data!.docs.length.toString() : '...';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 12),
              Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(fontSize: 11, color: kMutedFg, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        children: [
          _buildAccountRow(
            icon: Icons.campaign_outlined,
            title: 'Announcement Portal',
            subtitle: 'Broadcast global updates',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
          ),
          const Divider(color: kBorder, height: 1, indent: 60),
          _buildAccountRow(
            icon: Icons.forum_outlined,
            title: 'User Feedback Center',
            subtitle: 'View live learner insights',
            onTap: () => setState(() => _viewingFeedback = true),
          ),
          const Divider(color: kBorder, height: 1, indent: 60),
          _buildAccountRow(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Exit admin dashboard',
            isDestructive: true,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }


  // ════════════════════════════════════════════════════════════════════
  //  NEW: IN-SCREEN EDIT NAME VIEW
  // ════════════════════════════════════════════════════════════════════
  Widget _buildEditNameView() {
    return Container(
      key: const ValueKey('edit_name_view'),
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: kFg),
                onPressed: () => setState(() => _isEditingName = false),
              ),
              const SizedBox(width: 10),
              const Text('Edit Profile Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Display Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kMutedFg)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveName,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAdminPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_adminId).update({
        'displayName': _nameController.text.trim(),
      });
      setState(() => _isEditingName = false);
      _showSnackBar('✅ Profile updated');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }


  // ════════════════════════════════════════════════════════════════════
  //  IN-SCREEN FEEDBACK VIEW
  // ════════════════════════════════════════════════════════════════════
  Widget _buildFeedbackView() {
    return Container(
      key: const ValueKey('feedback_view'),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: kFg),
                  onPressed: () => setState(() => _viewingFeedback = false),
                ),
                const SizedBox(width: 10),
                const Text('User Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('feedback').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No feedback records found.', style: TextStyle(color: kMutedFg)));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 12, backgroundColor: kAdminPrimary, child: const Icon(Icons.person, size: 12, color: Colors.white)),
                              const SizedBox(width: 8),
                              Text(data['email'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(data['message'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4, color: kFg)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.access_time, size: 12, color: kMutedFg),
                              const SizedBox(width: 4),
                              Text('Just now', style: const TextStyle(fontSize: 10, color: kMutedFg)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildAccountRow({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    final color = isDestructive ? kAdminDanger : kFg;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: kMutedFg)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kMutedFg, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() => Container(height: 200, margin: const EdgeInsets.all(20), decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)), child: const Center(child: CircularProgressIndicator()));

  String _getInitials(String name) => name.isEmpty ? '?' : name.split(' ').take(2).map((s) => s[0].toUpperCase()).join();

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Text('Logout?'), content: const Text('Are you sure?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: kAdminDanger), child: const Text('Logout', style: TextStyle(color: Colors.white)))]));
    if (confirm == true) {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      
      // Log logout activity
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'ADMIN_LOGOUT',
        'performedBy': adminId,
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Admin signed out safely',
      });

      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? kAdminDanger : kAdminSuccess, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2))); }
}

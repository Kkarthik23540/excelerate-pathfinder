// lib/screens/admin/admin_user_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kAdminPrimary = Color(0xFF1E40AF);
const kAdminAccent = Color(0xFF0EA5E9);
const kAdminSuccess = Color(0xFF059669);
const kAdminWarning = Color(0xFFF59E0B);
const kAdminDanger = Color(0xFFDC2626);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;

class AdminUserDetailsScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailsScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  String? _selectedRole;
  String? _selectedStatus;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameCtrl.text = data['displayName'] ?? '';
        _phoneCtrl.text = data['phone'] ?? '';
        _titleCtrl.text = data['title'] ?? 'Learner';
        _selectedRole = data['role'] ?? 'learner';
        _selectedStatus = data['status'] ?? 'active';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('User Management',
            style: TextStyle(color: kFg, fontWeight: FontWeight.w900, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kFg),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAdminPrimary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserHeader(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Performance Overview'),
                        const SizedBox(height: 12),
                        _buildUserLiveStats(),
                        const SizedBox(height: 28),
                        _buildSectionHeader('Account Information'),
                        const SizedBox(height: 12),
                        _buildAccountInfoSection(),
                        const SizedBox(height: 28),
                        _buildSectionHeader('Access & Permissions'),
                        const SizedBox(height: 12),
                        _buildRoleAndPermissionsSection(),
                        const SizedBox(height: 32),
                        _buildDangerZoneSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomActionArea(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: kAdminPrimary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kFg)),
      ],
    );
  }

  Widget _buildUserHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final name = data['displayName'] ?? 'No name';
        final email = data['email'] ?? '';
        final status = data['status'] ?? 'active';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [kAdminPrimary, kAdminAccent]),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: kAdminPrimary.withOpacity(0.2), blurRadius: 8)],
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kFg)),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 13, color: kMutedFg, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text('USER ID: ${widget.userId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontSize: 10, color: kMutedFg, fontFamily: 'monospace', letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = kAdminSuccess;
    if (status == 'suspended') color = kAdminDanger;
    if (status == 'pending_verification') color = kAdminWarning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase().replaceAll('_', ' '),
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildUserLiveStats() {
    return Row(
      children: [
        Expanded(
          child: _buildRealTimeStatCard(
            label: 'Enrollments',
            stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('enrolledPrograms').snapshots(),
            icon: Icons.menu_book_rounded,
            color: kAdminAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRealTimeStatCard(
            label: 'Certificates',
            stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
            icon: Icons.workspace_premium_rounded,
            color: kAdminSuccess,
            field: 'certificates',
          ),
        ),
      ],
    );
  }

  Widget _buildRealTimeStatCard({
    required String label,
    required Stream<dynamic> stream,
    required IconData icon,
    required Color color,
    String? field,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          StreamBuilder<dynamic>(
            stream: stream,
            builder: (context, snapshot) {
              String value = '0';
              if (snapshot.hasData) {
                if (snapshot.data is QuerySnapshot) {
                  value = (snapshot.data as QuerySnapshot).docs.length.toString();
                } else if (snapshot.data is DocumentSnapshot && field != null) {
                  final data = (snapshot.data as DocumentSnapshot).data() as Map<String, dynamic>?;
                  final list = data?[field];
                  value = (list is List ? list.length : 0).toString();
                }
              }
              return Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kFg));
            },
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: kMutedFg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildDetailField('Display Name', _nameCtrl, Icons.person_outline),
          const SizedBox(height: 16),
          _buildDetailField('Phone Number', _phoneCtrl, Icons.phone_outlined),
          const SizedBox(height: 16),
          _buildDetailField('Professional Title', _titleCtrl, Icons.badge_outlined),
        ],
      ),
    );
  }

  Widget _buildRoleAndPermissionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'User Role',
              labelStyle: const TextStyle(color: kMutedFg, fontWeight: FontWeight.w600),
              prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: kAdminPrimary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
            ),
            items: const [
              DropdownMenuItem(value: 'learner', child: Text('Learner')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) => setState(() => _selectedRole = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Account Status',
              labelStyle: const TextStyle(color: kMutedFg, fontWeight: FontWeight.w600),
              prefixIcon: const Icon(Icons.info_outline, color: kAdminPrimary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
            ),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
              DropdownMenuItem(value: 'pending_verification', child: Text('Pending')),
            ],
            onChanged: (v) => setState(() => _selectedStatus = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kAdminDanger.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAdminDanger.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DANGER ZONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kAdminDanger, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildDangerButton('Reset Password', 'Send recovery link to user', Icons.lock_reset_rounded, kAdminPrimary, _resetPassword),
          const SizedBox(height: 10),
          _buildDangerButton('Suspend User', 'Temporarily disable access', Icons.block_flipped, kAdminWarning, _suspendUser),
          const SizedBox(height: 10),
          _buildDangerButton('Delete Permanently', 'Remove all user data (IRREVERSIBLE)', Icons.delete_forever_rounded, kAdminDanger, _deleteUser, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildDangerButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, {bool isDestructive = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: kMutedFg, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.5), size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kMutedFg, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, size: 20, color: kAdminPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAdminPrimary, width: 2)),
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAdminPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Save User Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'displayName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'role': _selectedRole,
        'status': _selectedStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminId,
      });

      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'USER_UPDATED',
        'performedBy': adminId,
        'targetId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Updated details for ${_nameCtrl.text.trim()}',
      });

      _showSnackBar('✅ User data synchronized successfully');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _resetPassword() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      final email = doc['email'];
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar('✅ Password reset link sent to $email');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _suspendUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Suspension'),
        content: const Text('This will block the user from accessing the platform until unsuspended.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: kAdminWarning), child: const Text('Suspend User', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'status': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspendedBy': adminId,
      });

      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'USER_SUSPENDED',
        'performedBy': adminId,
        'targetId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Suspended access for ${_nameCtrl.text}',
      });

      _showSnackBar('⚠️ User access restricted');
      setState(() => _selectedStatus = 'suspended');
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?'),
        content: const Text('This will permanently destroy all learner data and records. This action is terminal.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: kAdminDanger), child: const Text('Permanent Delete', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final adminId = FirebaseAuth.instance.currentUser?.uid;
        final userName = _nameCtrl.text;
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
        await FirebaseFirestore.instance.collection('achievements').doc(widget.userId).delete();
        await FirebaseFirestore.instance.collection('learnerProfiles').doc(widget.userId).delete();

        await FirebaseFirestore.instance.collection('audit_logs').add({
          'action': 'USER_DELETED',
          'performedBy': adminId,
          'targetId': widget.userId,
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Permanently removed user $userName',
        });

        _showSnackBar('🗑️ User purged from system');
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0].toUpperCase()).join();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? kAdminDanger : kAdminSuccess, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}

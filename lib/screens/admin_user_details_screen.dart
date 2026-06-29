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
  final _tierCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  String? _selectedRole;
  String? _selectedStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _tierCtrl.dispose();
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
        _tierCtrl.text = data['tier'] ?? 'Velocity Tier 1';
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
        backgroundColor: kCardBg,
        elevation: 0,
        title: const Text('User Details',
            style: TextStyle(color: kFg, fontWeight: FontWeight.w900, fontSize: 16)),
        iconTheme: const IconThemeData(color: kFg),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: kAdminPrimary),
            onPressed: _saveChanges,
            tooltip: 'Save changes',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 16),
            _buildAccountInfoSection(),
            const SizedBox(height: 16),
            _buildRoleAndPermissionsSection(),
            const SizedBox(height: 16),
            _buildDangerZoneSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['displayName'] ?? 'No name';
        final email = data['email'] ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAdminPrimary.withOpacity(0.1),
                  border: Border.all(color: kAdminPrimary, width: 2),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: kAdminPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: const TextStyle(fontSize: 11, color: kMutedFg)),
                    const SizedBox(height: 4),
                    Text('ID: ${widget.userId.substring(0, 12)}...',
                        style: const TextStyle(
                            fontSize: 9, color: kMutedFg, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACCOUNT INFORMATION',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: kMutedFg)),
          const SizedBox(height: 14),
          _buildField('Full Name', _nameCtrl, Icons.person),
          const SizedBox(height: 10),
          _buildField('Phone', _phoneCtrl, Icons.phone),
          const SizedBox(height: 10),
          _buildField('Title', _titleCtrl, Icons.badge),
          const SizedBox(height: 10),
          _buildField('Tier', _tierCtrl, Icons.workspace_premium),
        ],
      ),
    );
  }

  Widget _buildRoleAndPermissionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ROLE & STATUS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: kMutedFg)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'learner', child: Text('Learner')),
              DropdownMenuItem(value: 'mentor', child: Text('Mentor')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) => setState(() => _selectedRole = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAdminDanger.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DANGER ZONE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: kAdminDanger,
                  letterSpacing: 1.2)),
          const SizedBox(height: 14),
          _buildDangerButton(
            'Reset Password',
            'Send password reset email',
            Icons.lock_reset,
            kAdminPrimary,
            _resetPassword,
          ),
          const SizedBox(height: 8),
          _buildDangerButton(
            'Suspend User',
            'Block user from logging in',
            Icons.block,
            kAdminWarning,
            _suspendUser,
          ),
          const SizedBox(height: 8),
          _buildDangerButton(
            'Delete User Permanently',
            'This action cannot be undone',
            Icons.delete_forever,
            kAdminDanger,
            _deleteUser,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
            color: isDestructive ? color.withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: kMutedFg)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
      ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'displayName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'tier': _tierCtrl.text.trim(),
        'role': _selectedRole,
        'status': _selectedStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminId,
      });

      // Log action
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'USER_UPDATED',
        'performedBy': adminId,
        'targetId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'role': _selectedRole,
          'status': _selectedStatus,
        },
      });

      _showSnackBar('✅ User updated successfully');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _resetPassword() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      final email = doc['email'];
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar('✅ Password reset email sent');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _suspendUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User?'),
        content: const Text('This will prevent the user from logging in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kAdminWarning),
            child: const Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
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
      });

      _showSnackBar('✅ User suspended');
      setState(() => _selectedStatus = 'suspended');
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User Permanently?'),
        content: const Text('This will DELETE all user data. This CANNOT be undone!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kAdminDanger),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final adminId = FirebaseAuth.instance.currentUser?.uid;
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
        await FirebaseFirestore.instance.collection('achievements').doc(widget.userId).delete();
        await FirebaseFirestore.instance.collection('learnerProfiles').doc(widget.userId).delete();

        await FirebaseFirestore.instance.collection('audit_logs').add({
          'action': 'USER_DELETED',
          'performedBy': adminId,
          'targetId': widget.userId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _showSnackBar('✅ User deleted');
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name.split(' ').where((s) => s.isNotEmpty).take(2)
        .map((s) => s[0].toUpperCase()).join();
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
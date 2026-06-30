// lib/screens/admin/admin_users_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_user_details_screen.dart';
import 'admin_home_screen.dart';

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

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterRole = 'all';
  String _filterStatus = 'all';
  bool _isAdding = false;

  // Form Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _passwordCtrl.clear();
    setState(() {
      _isAdding = false;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isAdding ? _buildAddUserForm() : _buildMainList(),
        ),
      ),
    );
  }

  Widget _buildMainList() {
    return Column(
      key: const ValueKey('main_list'),
      children: [
        _buildHeader(),
        _buildSearchAndFilters(),
        Expanded(child: _buildUsersList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
                );
              },
              child: const Icon(Icons.arrow_back, color: kFg),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Management',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                Text('Manage all platform users',
                    style: TextStyle(fontSize: 11, color: kMutedFg)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: kAdminPrimary),
            onPressed: () => setState(() => _isAdding = true),
            tooltip: 'Add new user',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      color: kCardBg,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () =>
                    setState(() => _searchController.clear()),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorder),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildRoleFilter()),
              const SizedBox(width: 8),
              Expanded(child: _buildStatusFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterRole,
          isExpanded: true,
          isDense: true,
          items: const [
            DropdownMenuItem(
                value: 'all', child: Text('All Roles', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'learner', child: Text('Learners', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'admin', child: Text('Admins', style: TextStyle(fontSize: 12))),
          ],
          onChanged: (v) => setState(() => _filterRole = v!),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterStatus,
          isExpanded: true,
          isDense: true,
          items: const [
            DropdownMenuItem(
                value: 'all', child: Text('All Status', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'active', child: Text('Active', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'suspended', child: Text('Suspended', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(
                value: 'pending_verification', child: Text('Pending', style: TextStyle(fontSize: 12))),
          ],
          onChanged: (v) => setState(() => _filterStatus = v!),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: kAdminDanger),
                  const SizedBox(height: 12),
                  const Text(
                    'Error loading users',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kAdminDanger),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: kMutedFg),
                  ),
                ],
              ),
            ),
          );
        }

        final allUsers = snapshot.data?.docs ?? [];
        final filteredUsers = _filterUsers(allUsers);

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: kMutedFg),
                const SizedBox(height: 16),
                const Text('No users found',
                    style: TextStyle(color: kMutedFg, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final userDoc = filteredUsers[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            return _buildUserCard(userDoc.id, userData);
          },
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> users) {
    final searchQuery = _searchController.text.trim().toLowerCase();

    return users.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['displayName'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final role = (data['role'] ?? 'learner').toString();
      final status = (data['status'] ?? 'active').toString();

      final matchesSearch = searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          email.contains(searchQuery);
      final matchesRole = _filterRole == 'all' || role == _filterRole;
      final matchesStatus = _filterStatus == 'all' || status == _filterStatus;

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final name = userData['displayName'] ?? 'No name';
    final email = userData['email'] ?? '';
    final role = userData['role'] ?? 'learner';
    final status = userData['status'] ?? 'active';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminUserDetailsScreen(userId: userId),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getRoleColor(role).withOpacity(0.15),
                  border: Border.all(color: _getRoleColor(role), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: TextStyle(
                      color: _getRoleColor(role),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status == 'suspended')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: kAdminDanger,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('SUSPENDED',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 11, color: kMutedFg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    _buildBadge(role.toUpperCase(), _getRoleColor(role)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMutedFg, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return kAdminDanger;
      case 'mentor':
        return kAdminAccent;
      default:
        return kAdminPrimary;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0].toUpperCase()).join();
  }

  // ════════════════════════════════════════════════════════════════════
  //  NEW: IN-SCREEN ADD USER FORM
  // ════════════════════════════════════════════════════════════════════
  Widget _buildAddUserForm() {
    return Container(
      key: const ValueKey('add_form'),
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: kFg),
                onPressed: _resetForm,
              ),
              const SizedBox(width: 10),
              const Text('Add New Learner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('FULL NAME'),
                  _buildTextField(_nameCtrl, 'Enter full name', Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildLabel('EMAIL ADDRESS'),
                  _buildTextField(_emailCtrl, 'example@email.com', Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildLabel('PHONE NUMBER'),
                  _buildTextField(_phoneCtrl, '+1 (555) 000-0000', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildLabel('TEMPORARY PASSWORD'),
                  _buildTextField(_passwordCtrl, '••••••••', Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 20),
                  _buildLabel('ROLE'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.school_outlined, color: kAdminPrimary, size: 20),
                        SizedBox(width: 12),
                        Text('Learner', style: TextStyle(fontWeight: FontWeight.w600)),
                        Spacer(),
                        Icon(Icons.lock, size: 16, color: kMutedFg),
                      ],
                    ),
                  ),
                  const Text('Note: New users are restricted to the Learner role by default.', style: TextStyle(fontSize: 10, color: kMutedFg, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _handleCreateUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAdminPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kMutedFg, letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kAdminPrimary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _handleCreateUser() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    setState(() => _saving = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': _emailCtrl.text.trim(),
        'displayName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': 'learner',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
      });

      // Log action
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'USER_CREATED',
        'performedBy': adminId,
        'targetId': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Created user ${_nameCtrl.text.trim()} (${_emailCtrl.text.trim()})',
      });

      _showSnackBar('✅ User created successfully');
      _resetForm();
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to create user';
      if (e.code == 'email-already-in-use') msg = 'Email already exists';
      else if (e.code == 'weak-password') msg = 'Password too weak (min 6 chars)';
      _showSnackBar(msg, isError: true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _saving = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? kAdminDanger : kAdminSuccess, behavior: SnackBarBehavior.floating));
  }
}

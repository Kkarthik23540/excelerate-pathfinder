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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilters(),
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
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
            onPressed: _showAddUserDialog,
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

  // ✅ FIXED: Fetch ALL users and filter on client side (no index needed)
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
                  Text(
                    'Error loading users',
                    style: const TextStyle(
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

        // ✅ Apply filters on client side
        final filteredUsers = _filterUsers(allUsers);

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: kMutedFg),
                const SizedBox(height: 16),
                const Text('No users found',
                    style: TextStyle(color: kMutedFg, fontSize: 14)),
                if (_searchController.text.isNotEmpty ||
                    _filterRole != 'all' ||
                    _filterStatus != 'all')
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Try adjusting your filters',
                        style: TextStyle(color: kMutedFg, fontSize: 12)),
                  ),
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

  // ✅ NEW: Client-side filtering function
  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> users) {
    final searchQuery = _searchController.text.trim().toLowerCase();

    return users.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['displayName'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final role = (data['role'] ?? 'learner').toString();
      final status = (data['status'] ?? 'active').toString();

      // Search filter
      final matchesSearch = searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          email.contains(searchQuery);

      // Role filter
      final matchesRole = _filterRole == 'all' || role == _filterRole;

      // Status filter
      final matchesStatus =
          _filterStatus == 'all' || status == _filterStatus;

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final name = userData['displayName'] ?? 'No name';
    final email = userData['email'] ?? '';
    final role = userData['role'] ?? 'learner';
    final tier = userData['tier'] ?? 'Velocity Tier 1';
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
                        if (status == 'pending_verification')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: kAdminWarning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('PENDING',
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
                    Row(
                      children: [
                        _buildBadge(role.toUpperCase(), _getRoleColor(role)),
                        const SizedBox(width: 5),
                        _buildBadge(tier, kAdminAccent),
                      ],
                    ),
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
      case 'super_admin':
        return kAdminDanger;
      case 'mentor':
        return kAdminAccent;
      default:
        return kAdminPrimary;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'learner';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: kAdminPrimary),
              SizedBox(width: 8),
              Text('Add New User'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Temporary Password *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'learner', child: Text('Learner')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _createUser(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  password: passwordCtrl.text,
                  role: selectedRole,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kAdminPrimary),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': name,
        'phone': phone,
        'role': role,
        'tier': 'Velocity Tier 1',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
      });

      _showSnackBar('✅ User created successfully');
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to create user';
      if (e.code == 'email-already-in-use') msg = 'Email already exists';
      else if (e.code == 'weak-password') {
        msg = 'Password too weak (min 6 chars)';
      }
      _showSnackBar(msg, isError: true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
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
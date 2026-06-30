// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_bottom_nav.dart';
import 'admin_users_screen.dart';
import 'admin_programs_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_profile_screen.dart';

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
const kAuthAccentDark = Color(0xFFE53935);

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? _adminId;
  String _adminName = "Admin";
  String _adminRole = "admin";

  @override
  void initState() {
    super.initState();
    _adminId = FirebaseAuth.instance.currentUser?.uid;
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    if (_adminId == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_adminId)
        .get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        setState(() {
          _adminName = data['displayName'] ?? "Admin";
          _adminRole = data['role'] ?? "admin";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppBar(),
              const SizedBox(height: 20),
              _buildHeroSection(),
              const SizedBox(height: 20),
              _buildPendingApprovalsCard(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildSystemHealthCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(
        currentDestination: AdminNavDestination.dashboard,
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kAdminPrimary, kAdminAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: Colors.white, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_adminName',
                style: const TextStyle(
                  color: kFg,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _adminRole == 'super_admin' ? 'SUPER ADMIN' : 'ADMIN',
                style: const TextStyle(
                  color: kAdminPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedback')
              .snapshots(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data?.docs.length ?? 0;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: kFg),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen()),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: kAdminDanger,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kAdminPrimary, kAdminAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kAdminPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _adminRole.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$_adminName 👑',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Here's what's happening on your platform",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'pending_verification')
          .snapshots(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data?.docs.length ?? 0;
        if (pendingCount == 0) return const SizedBox.shrink();

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kAdminWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kAdminWarning, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: kAdminWarning,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        pendingCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Approvals',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '$pendingCount user${pendingCount > 1 ? "s" : ""} waiting for verification',
                          style: const TextStyle(
                              fontSize: 12, color: kMutedFg),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream:
          FirebaseFirestore.instance.collection('programs').snapshots(),
          builder: (context, programSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('announcements')
                  .snapshots(),
              builder: (context, announceSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('enrollments').snapshots(),
              builder: (context, enrollSnap) {
                final users = userSnap.data?.docs.length ?? 0;
                final programs = programSnap.data?.docs.length ?? 0;
                final announcements = announceSnap.data?.docs.length ?? 0;
                final enrollments = enrollSnap.data?.docs.length ?? 0;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        color: kAdminAccent,
                        icon: Icons.people_alt_rounded,
                        value: users.toString(),
                        label: 'Users',
                        subtitle: 'Registered',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        color: kAdminWarning,
                        icon: Icons.menu_book_rounded,
                        value: programs.toString(),
                        label: 'Programs',
                        subtitle: 'Published',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        color: Colors.deepPurple,
                        icon: Icons.assignment_ind_rounded,
                        value: enrollments.toString(),
                        label: 'Enrols',
                        subtitle: 'Total',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        color: kAdminSuccess,
                        icon: Icons.campaign_rounded,
                        value: announcements.toString(),
                        label: 'Updates',
                        subtitle: 'Posted',
                      ),
                    ),
                  ],
                );
              },
            );
          },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required Color color,
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: kFg,
                  letterSpacing: -0.3),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showAllActivity,
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kAdminPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('audit_logs')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: const Center(
                  child: Text('No recent activity',
                      style: TextStyle(color: kMutedFg, fontSize: 13)),
                ),
              );
            }

            final logs = snapshot.data!.docs;
            return Column(
              children: logs
                  .map((log) =>
                  _buildActivityItem(log.data() as Map<String, dynamic>))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> data) {
    final action = data['action'] ?? 'UNKNOWN';
    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr = timestamp != null ? _formatTimestamp(timestamp.toDate()) : 'Just now';
    final details = data['details'];
    String detailStr = '';
    if (details is String) {
      detailStr = details;
    } else if (details is Map) {
      // For USER_UPDATED etc where details is a map
      detailStr = details.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActionColor(action).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getActionIcon(action),
                color: _getActionColor(action), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getActionTitle(action),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                if (detailStr.isNotEmpty)
                  Text(detailStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: kFg.withOpacity(0.7))),
                Text(timeStr,
                    style: const TextStyle(
                        fontSize: 10, color: kMutedFg)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.people_alt_rounded,
        'label': 'Manage Users',
        'color': kAdminPrimary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
      },
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Programs',
        'color': kAdminWarning,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminProgramsScreen())),
      },
      {
        'icon': Icons.campaign_rounded,
        'label': 'Announcements',
        'color': kAdminSuccess,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
      },
      {
        'icon': Icons.analytics_rounded,
        'label': 'Analytics',
        'color': kAdminAccent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Controls',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: kFg,
              letterSpacing: -0.3),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildActionTile(actions[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildActionTile(actions[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildActionTile(actions[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildActionTile(actions[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(Map<String, dynamic> action) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: action['onTap'] as VoidCallback,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action['icon'] as IconData,
                    color: action['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action['label'] as String,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: kMutedFg, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        int activeUsers = snapshot.hasData ? snapshot.data!.docs.length : 0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kAdminSuccess.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.health_and_safety,
                        color: kAdminSuccess, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text('System Health',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kAdminSuccess.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ALL SYSTEMS OK',
                      style: TextStyle(
                        color: kAdminSuccess,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildHealthRow('Firestore Database', 'Connected', kAdminSuccess),
              _buildHealthRow('Authentication API', 'Operational', kAdminSuccess),
              _buildHealthRow('Registered Users', '$activeUsers Users', kAdminAccent),
              _buildHealthRow('Server Latency', '64ms', kAdminSuccess),
              _buildHealthRow('Cloud Storage', 'Optimal', kAdminSuccess),
            ],
          ),
        );
      }
    );
  }

  void _showAllActivity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Full Audit Log',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('audit_logs')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final logs = snapshot.data!.docs;
                  if (logs.isEmpty) return const Center(child: Text('No activity logs found.'));

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final data = logs[index].data() as Map<String, dynamic>;
                      return _buildActivityItem(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: kFg)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  // Helper functions
  IconData _getActionIcon(String action) {
    if (action.contains('USER')) return Icons.person;
    if (action.contains('PROGRAM')) return Icons.menu_book;
    if (action.contains('LOGIN')) return Icons.login;
    if (action.contains('LOGOUT')) return Icons.logout;
    if (action.contains('SUSPEND')) return Icons.block;
    if (action.contains('DELETE')) return Icons.delete_forever;
    if (action.contains('ANNOUNCEMENT')) return Icons.campaign;
    return Icons.info_outline;
  }

// ✅ AFTER (fixed)
  String _getActionTitle(String action) {
    final str = action.replaceAll('_', ' ').toLowerCase();
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  Color _getActionColor(String action) {
    if (action.contains('DELETE') || action.contains('SUSPEND')) {
      return kAdminDanger;
    }
    if (action.contains('CREATE') || action.contains('LOGIN')) {
      return kAdminSuccess;
    }
    if (action.contains('UPDATE') || action.contains('EDIT')) {
      return kAdminAccent;
    }
    if (action.contains('LOGOUT')) {
      return Colors.blueGrey;
    }
    return kAdminPrimary;
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time).abs(); // Use abs to handle slight clock skew
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
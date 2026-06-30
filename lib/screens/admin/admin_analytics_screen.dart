// lib/screens/admin/admin_analytics_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/admin_bottom_nav.dart';
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

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text('Live Platform Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('programs').snapshots(),
            builder: (context, programSnap) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
                builder: (context, feedbackSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting ||
                      programSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: kAdminPrimary));
                  }

                  final users = userSnap.data?.docs ?? [];
                  final programs = programSnap.data?.docs ?? [];
                  final feedbacks = feedbackSnap.data?.docs ?? [];

                  // Logic for Category Distribution
                  Map<String, int> catCounts = {};
                  for (var p in programs) {
                    final cat = (p.data() as Map<String, dynamic>)['category'] ?? 'Other';
                    catCounts[cat] = (catCounts[cat] ?? 0) + 1;
                  }

                  // Logic for Tier Distribution
                  Map<String, int> tierCounts = {};
                  for (var u in users) {
                    final tier = (u.data() as Map<String, dynamic>)['tier'] ?? 'Free';
                    tierCounts[tier] = (tierCounts[tier] ?? 0) + 1;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroMetric(users.length),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Real-time Stats'),
                        const SizedBox(height: 16),
                        _buildHighlightedGrid(context, programs.length, feedbacks.length),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Program Categories'),
                        const SizedBox(height: 16),
                        _buildCategoryBreakdown(catCounts, programs.length),
                        const SizedBox(height: 28),
                        _buildSectionTitle('User Tiers'),
                        const SizedBox(height: 16),
                        _buildTierChips(tierCounts),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Newest Members'),
                        const SizedBox(height: 16),
                        _buildLatestUsersList(users),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(
        currentDestination: AdminNavDestination.analytics,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: kAdminPrimary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kFg)),
      ],
    );
  }

  Widget _buildHeroMetric(int totalUsers) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kAdminPrimary, kAdminAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: kAdminPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Platform Users', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$totalUsers', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text('Live', style: TextStyle(color: kAdminSuccess, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_graph_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Real-time synchronization active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedGrid(BuildContext context, int programCount, int feedbackCount) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Programs',
            programCount.toString(),
            Icons.menu_book_rounded,
            kAdminWarning,
            onTap: () => _showDetailSheet(context, 'programs', 'Active Programs'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Feedback',
            feedbackCount.toString(),
            Icons.maps_ugc_rounded,
            kAdminSuccess,
            onTap: () => _showDetailSheet(context, 'feedback', 'User Feedback'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 16),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(fontSize: 12, color: kMutedFg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, String collection, String title) {
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
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(collection).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return Center(child: Text('No $title found.'));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      if (collection == 'programs') {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kAdminPrimary.withOpacity(0.1),
                            child: const Icon(Icons.book, color: kAdminPrimary, size: 16),
                          ),
                          title: Text(data['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(data['category'] ?? 'General'),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['email'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(data['message'] ?? '', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }
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

  Widget _buildCategoryBreakdown(Map<String, int> counts, int total) {
    if (total == 0) return _buildEmptyCard('No programs published yet');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
      child: Column(
        children: counts.entries.map((e) {
          final percent = e.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('${(percent * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: kAdminPrimary)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: kBg,
                    color: kAdminPrimary,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTierChips(Map<String, int> tierCounts) {
    if (tierCounts.isEmpty) return _buildEmptyCard('No user data available');

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tierCounts.entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kAdminAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kAdminAccent.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(e.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kAdminPrimary)),
              const SizedBox(height: 4),
              Text('${e.value}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kFg)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLatestUsersList(List<QueryDocumentSnapshot> users) {
    final latest = users.take(5).toList();
    if (latest.isEmpty) return _buildEmptyCard('Waiting for new signups...');

    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
      child: Column(
        children: latest.map((u) {
          final data = u.data() as Map<String, dynamic>;
          final isNew = true; // Since it's from the latest list
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: kAdminPrimary.withOpacity(0.1),
              child: Text(data['displayName']?[0] ?? '?', style: const TextStyle(color: kAdminPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            title: Text(data['displayName'] ?? 'Unknown User', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(data['email'] ?? '', style: const TextStyle(fontSize: 11, color: kMutedFg)),
            trailing: isNew ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: kAdminSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Text('NEW', style: TextStyle(color: kAdminSuccess, fontSize: 9, fontWeight: FontWeight.w900)),
            ) : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder, style: BorderStyle.solid)),
      child: Center(child: Text(msg, style: const TextStyle(color: kMutedFg, fontSize: 14, fontWeight: FontWeight.w600))),
    );
  }
}

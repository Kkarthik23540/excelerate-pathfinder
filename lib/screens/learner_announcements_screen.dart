// lib/screens/learner_announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

const kPrimary = Color(0xFFE0194A);
const kPurple = Color(0xFF9B59B6);
const kBg = Color(0xFFF7F7F7);
const kCardBg = Colors.white;
const kBorder = Color(0xFFE8E8E8);
const kMutedFg = Color(0xFF949494);
const kFg = Colors.black;
const kTeal = Color(0xFF0891B2);
const kOrange = Color(0xFFEA580C);

class LearnerAnnouncementsScreen extends StatelessWidget {
  const LearnerAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error loading announcements:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kMutedFg),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildSampleAnnouncements();
                  }
                  return _buildAnnouncementsList(snapshot.data!.docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.arrow_back, size: 20, color: kFg),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Announcements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: kFg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleAnnouncements() {
    final samples = [
      {
        'icon': Icons.notifications_active_outlined,
        'iconColor': kTeal,
        'title': 'New Program: Sales & Negotiation Mastery',
        'body':
        'Enroll now in our latest program on advanced sales techniques and deal-closing strategies.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'iconColor': kPurple,
        'title': 'System Maintenance Notice',
        'body':
        'Platform will undergo scheduled maintenance on Sunday, 2 AM - 4 AM EST.',
        'time': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'icon': Icons.event_available_rounded,
        'iconColor': kOrange,
        'title': 'Live Masterclass This Friday',
        'body':
        'Join Dr. Elena Rodriguez for a deep-dive into Data Architecture this Friday at 3 PM EST.',
        'time': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: samples.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final a = samples[index];
        return _buildAnnouncementCard(
          icon: a['icon'] as IconData,
          iconColor: a['iconColor'] as Color,
          title: a['title'] as String,
          body: a['body'] as String,
          time: a['time'] as DateTime,
        );
      },
    );
  }

  Widget _buildAnnouncementsList(List<QueryDocumentSnapshot> docs) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.now();
        final iconCode = data['iconCode'] as int? ??
            Icons.notifications_active_outlined.codePoint;
        return _buildAnnouncementCard(
          icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
          iconColor: Color(data['iconColor'] as int? ?? kTeal.value),
          title: data['title'] as String? ?? 'Announcement',
          body: data['body'] as String? ?? '',
          time: createdAt,
        );
      },
    );
  }

  Widget _buildAnnouncementCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required DateTime time,
  }) {
    final timeAgo = _formatTimeAgo(time);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kFg,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kMutedFg,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: kMutedFg,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }
}
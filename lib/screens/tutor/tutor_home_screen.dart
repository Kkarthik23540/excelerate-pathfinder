// lib/screens/tutor/tutor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/tutor_bottom_nav.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> with SingleTickerProviderStateMixin {
  final kPrimary = const Color(0xFF863CAC); // Purple for Tutors
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(user?.displayName ?? "Tutor"),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 32),
              const Text('Assigned Programs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _buildProgramList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TutorBottomNav(currentDestination: TutorNavDestination.home),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      children: [
        CircleAvatar(radius: 25, backgroundColor: kPrimary, child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, Prof. $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const Text('Your students are waiting for you!', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Active Students', '124', Icons.people_rounded, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Average Rating', '4.9', Icons.star_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildProgramList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('programs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildTutorProgramCard(doc.id, data);
          }).toList(),
        );
      },
    );
  }

  Widget _buildTutorProgramCard(String id, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.school_rounded, color: kPrimary)),
              const SizedBox(width: 14),
              Expanded(child: Text(data['title'] ?? 'Program', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleGoLive(id, data['title']),
                  icon: FadeTransition(opacity: _pulseController, child: const Icon(Icons.circle, size: 10, color: Colors.white)),
                  label: const Text('GO LIVE NOW'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {}, // View Details
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('MANAGE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleGoLive(String programId, String title) {
    final linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Live Session: $title'),
        content: TextField(
          controller: linkController,
          decoration: const InputDecoration(hintText: 'Paste Zoom / Google Meet Link', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (linkController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('live_sessions').doc(programId).set({
                  'programId': programId,
                  'title': title,
                  'link': linkController.text.trim(),
                  'isLive': true,
                  'tutorName': FirebaseAuth.instance.currentUser?.displayName ?? "Expert",
                  'startedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔥 You are now LIVE!'), backgroundColor: Colors.green));
              }
            },
            child: const Text('LAUNCH LIVE'),
          ),
        ],
      ),
    );
  }
}

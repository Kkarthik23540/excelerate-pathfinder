// lib/screens/admin/admin_announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/admin_bottom_nav.dart';
import 'admin_home_screen.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdding = false;
  bool _isSubmitting = false;
  String? _editingDocId;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  void _resetForm() {
    _titleController.clear();
    _bodyController.clear();
    setState(() {
      _isAdding = false;
      _editingDocId = null;
    });
  }

  void _startEditing(String docId, Map<String, dynamic> data) {
    setState(() {
      _isAdding = true;
      _editingDocId = docId;
      _titleController.text = data['title'] ?? '';
      _bodyController.text = data['body'] ?? '';
    });
  }

  Future<void> _publishAnnouncement() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'body': _bodyController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    setState(() => _isSubmitting = true);
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      if (_editingDocId != null) {
        await _firestore.collection('announcements').doc(_editingDocId).update(data);
        await _firestore.collection('audit_logs').add({
          'action': 'ANNOUNCEMENT_UPDATED',
          'performedBy': adminId,
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Updated ${_titleController.text.trim()}'
        });
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['iconCode'] = Icons.campaign_rounded.codePoint;
        data['iconColor'] = const Color(0xFF059669).value;
        await _firestore.collection('announcements').add(data);
        await _firestore.collection('audit_logs').add({
          'action': 'ANNOUNCEMENT_CREATED',
          'performedBy': adminId,
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Posted ${_titleController.text.trim()}'
        });
      }
      
      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingDocId != null ? 'Announcement updated!' : 'Announcement published!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(_isAdding 
            ? (_editingDocId != null ? 'Edit Announcement' : 'Post Announcement') 
            : 'Announcements',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black)),
        leading: _isAdding 
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: _resetForm,
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
              ),
            ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isAdding ? _buildAddForm() : _buildAnnouncementsList(),
      ),
      floatingActionButton: _isAdding 
        ? null 
        : FloatingActionButton.extended(
            onPressed: () => setState(() => _isAdding = true),
            backgroundColor: const Color(0xFF059669),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Post Update', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      bottomNavigationBar: const AdminBottomNav(
        currentDestination: AdminNavDestination.dashboard,
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      key: const ValueKey('add_form'),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Announcement Content',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share important updates with all learners.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(_titleController, 'Subject / Title', Icons.subject),
                  const SizedBox(height: 20),
                  _buildInputField(_bodyController, 'Message', Icons.chat_bubble_outline, maxLines: 6),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _publishAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_editingDocId != null ? 'Save Changes' : 'Post Now', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return StreamBuilder<QuerySnapshot>(
      key: const ValueKey('announcements_list'),
      stream: _firestore.collection('announcements').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.campaign_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No announcements yet', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Tap "Post Update" to share your first announcement', 
                  style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Color(0xFF059669)),
                ),
                title: Text(data['title'] ?? 'No Title', 
                  style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(data['body'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      onPressed: () => _startEditing(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete(doc.id, data['title'] ?? 'this announcement'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String docId, String title) {
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete Announcement?'),
          content: const Text('Are you sure you want to remove this update?'),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isDeleting ? null : () async {
                setDialogState(() => isDeleting = true);
                try {
                  final adminId = FirebaseAuth.instance.currentUser?.uid;
                  await _firestore.collection('announcements').doc(docId).delete();
                  await _firestore.collection('audit_logs').add({
                    'action': 'ANNOUNCEMENT_DELETED',
                    'performedBy': adminId,
                    'timestamp': FieldValue.serverTimestamp(),
                    'details': 'Deleted $title'
                  });
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  setDialogState(() => isDeleting = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete failed: $e')),
                    );
                  }
                }
              },
              child: isDeleting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF059669)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

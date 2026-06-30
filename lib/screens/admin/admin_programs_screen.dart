// lib/screens/admin/admin_programs_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/admin_bottom_nav.dart';
import 'admin_home_screen.dart';

class AdminProgramsScreen extends StatefulWidget {
  const AdminProgramsScreen({super.key});

  @override
  State<AdminProgramsScreen> createState() => _AdminProgramsScreenState();
}

class _AdminProgramsScreenState extends State<AdminProgramsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdding = false;
  String? _editingDocId;

  final _titleController = TextEditingController();
  final _modulesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _durationController = TextEditingController();
  final _ratingController = TextEditingController();
  final _studentsController = TextEditingController();
  String _selectedCategory = 'Tech';
  final List<String> _categories = ['Tech', 'Business', 'Design', 'Marketing'];

  void _resetForm() {
    _titleController.clear();
    _modulesController.clear();
    _descriptionController.clear();
    _instructorController.clear();
    _durationController.clear();
    _ratingController.clear();
    _studentsController.clear();
    setState(() {
      _selectedCategory = 'Tech';
      _isAdding = false;
      _editingDocId = null;
    });
  }

  void _startEditing(String docId, Map<String, dynamic> data) {
    setState(() {
      _isAdding = true;
      _editingDocId = docId;
      _titleController.text = data['title'] ?? '';
      _modulesController.text = data['modules'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _instructorController.text = data['instructor'] ?? '';
      _durationController.text = data['duration'] ?? '';
      _ratingController.text = (data['rating'] ?? '').toString();
      _studentsController.text = (data['students'] ?? '').toString();
      _selectedCategory = data['category'] ?? 'Tech';
    });
  }

  Future<void> _publishProgram() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a program title')),
      );
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'category': _selectedCategory,
      'modules': _modulesController.text.trim(),
      'description': _descriptionController.text.trim(),
      'instructor': _instructorController.text.trim(),
      'duration': _durationController.text.trim(),
      'rating': double.tryParse(_ratingController.text) ?? 4.5,
      'students': int.tryParse(_studentsController.text) ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;
      
      if (_editingDocId != null) {
        // Update existing
        await _firestore.collection('programs').doc(_editingDocId).update(data);
        await _firestore.collection('audit_logs').add({
          'action': 'PROGRAM_UPDATED',
          'performedBy': adminId,
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Updated ${_titleController.text.trim()}'
        });
      } else {
        // Create new
        data['progress'] = 0.0;
        data['createdAt'] = FieldValue.serverTimestamp();
        data['iconCode'] = Icons.menu_book_rounded.codePoint;
        data['iconColor'] = const Color(0xFFE0194A).value;
        data['tag'] = 'NEW';
        await _firestore.collection('programs').add(data);
        await _firestore.collection('audit_logs').add({
          'action': 'PROGRAM_CREATED',
          'performedBy': adminId,
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Created ${_titleController.text.trim()}'
        });
      }
      
      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingDocId != null ? 'Program updated!' : 'Program published!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
            ? (_editingDocId != null ? 'Edit Program' : 'Create New Program') 
            : 'Manage Programs',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black)),
        leading: _isAdding 
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: _resetForm,
            )
          : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isAdding ? _buildAddForm() : _buildProgramsList(),
      ),
      floatingActionButton: _isAdding 
        ? null 
        : FloatingActionButton.extended(
            onPressed: () => setState(() => _isAdding = true),
            backgroundColor: const Color(0xFFE0194A),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Program', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      bottomNavigationBar: const AdminBottomNav(
        currentDestination: AdminNavDestination.programs,
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
                  Text(
                    _editingDocId != null ? 'Edit Program Details' : 'Program Details',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _editingDocId != null 
                        ? 'Modify the information below to update the program.'
                        : 'Fill in the information below to create a new learning program.',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(_titleController, 'Program Title', Icons.title),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFFE0194A)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(_modulesController, 'Modules (e.g., 12 modules)', Icons.list_alt),
                  const SizedBox(height: 20),
                  _buildInputField(_instructorController, 'Instructor Name', Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildInputField(_durationController, 'Duration (e.g., 8 weeks)', Icons.access_time),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildInputField(_ratingController, 'Rating (0-5)', Icons.star_border, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInputField(_studentsController, 'Student Count', Icons.people_outline, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(_descriptionController, 'Description', Icons.description_outlined, maxLines: 4),
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
                  onPressed: _publishProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0194A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(_editingDocId != null ? 'Save Changes' : 'Publish Now', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsList() {
    return StreamBuilder<QuerySnapshot>(
      key: const ValueKey('programs_list'),
      stream: _firestore.collection('programs').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No programs published yet', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Tap "Add Program" to create your first one', 
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0194A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFFE0194A)),
                ),
                title: Text(data['title'] ?? 'Untitled', 
                  style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${data['category']} • ${data['modules']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _startEditing(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(doc.id, data['title'] ?? 'this program'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program?'),
        content: Text('Are you sure you want to remove "$title"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final adminId = FirebaseAuth.instance.currentUser?.uid;
              await _firestore.collection('programs').doc(docId).delete();
              await _firestore.collection('audit_logs').add({
                'action': 'PROGRAM_DELETED',
                'performedBy': adminId,
                'timestamp': FieldValue.serverTimestamp(),
                'details': 'Deleted $title'
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE0194A)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0194A), width: 2),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}

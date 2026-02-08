import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class EditCitizenScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditCitizenScreen({super.key, required this.user});

  @override
  State<EditCitizenScreen> createState() => _EditCitizenScreenState();
}

class _EditCitizenScreenState extends State<EditCitizenScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _birthPlaceController; // Should exist in backend
  String _role = 'User';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['fullName'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _addressController = TextEditingController(text: widget.user['address'] ?? '');
    _birthPlaceController = TextEditingController(text: widget.user['birthPlace'] ?? '');
    _role = widget.user['role'] ?? 'User';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'fullName': _nameController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'birthPlace': _birthPlaceController.text,
      'role': _role,
    };

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .updateUser(widget.user['_id'], data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
      Navigator.pop(context); // Return to list
    } else {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update user')),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Citizen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Email required' : null,
              ),
              const SizedBox(height: 10),
               TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 10),
               TextFormField(
                controller: _birthPlaceController,
                decoration: const InputDecoration(labelText: 'Place of Birth'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role,
                items: ['User', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => _role = val!),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    onPressed: _submit,
                    child: const Text('Updates User'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

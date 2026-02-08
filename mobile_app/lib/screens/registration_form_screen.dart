import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _placeController = TextEditingController();
  final _fatherController = TextEditingController();
  final _motherController = TextEditingController();
  final _dobController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }

    final data = {
      'childFullName': _fullNameController.text,
      'dob': _dobController.text,
      'gender': _selectedGender,
      'placeOfBirth': _placeController.text,
      'fatherName': _fatherController.text,
      'motherName': _motherController.text,
    };

    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    final success = await provider.createRequest('Birth Certificate', data);

    if (success && mounted) {
       ScaffoldMessenger.of(context).hideCurrentSnackBar();
       showDialog(
         context: context, 
         barrierDismissible: false,
         builder: (ctx) => Dialog(
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(20),
           ),
           elevation: 16,
           child: Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(20),
             ),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const SizedBox(height: 10),
                 Container(
                   decoration: BoxDecoration(
                     color: Colors.blue.shade50,
                     shape: BoxShape.circle,
                   ),
                   padding: const EdgeInsets.all(16),
                   child: const Icon(Icons.child_friendly, color: Colors.blue, size: 60),
                 ),
                 const SizedBox(height: 20),
                 const Text(
                   'Submitted!',
                   style: TextStyle(
                     fontSize: 24, 
                     fontWeight: FontWeight.bold,
                     color: Colors.black87
                   ),
                 ),
                 const SizedBox(height: 10),
                 const Text(
                   'Birth Registration has been submitted successfully!',
                   textAlign: TextAlign.center,
                   style: TextStyle(fontSize: 16, color: Colors.grey),
                 ),
                 const SizedBox(height: 24),
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primaryBlue,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                       padding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                     onPressed: () {
                         Navigator.pop(ctx); // Close Dialog
                         Navigator.pop(context); // Close Screen
                     },
                     child: const Text('OK', style: TextStyle(fontSize: 16, color: Colors.white)),
                   ),
                 ),
               ],
             ),
           ),
         )
       );
    } else {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage ?? 'Submission Failed')),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Child Details'),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Child Full Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth', 
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Place of Birth', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Parents Details'),
              TextFormField(
                controller: _fatherController,
                decoration: const InputDecoration(labelText: 'Father\'s Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motherController,
                decoration: const InputDecoration(labelText: 'Mother\'s Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              Consumer<RegistrationProvider>(
                builder: (ctx, provider, _) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: provider.isLoading ? null : _submit,
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Registration', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
    );
  }
}

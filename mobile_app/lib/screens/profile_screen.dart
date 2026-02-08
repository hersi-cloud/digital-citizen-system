import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController.text = user['name'] ?? '';
  }

  void _saveProfile() async {
     setState(() => _isEditing = false);
     if (_nameController.text.isNotEmpty) {
         await Provider.of<AuthProvider>(context, listen: false).updateUserInfo(
             fullName: _nameController.text,
             password: _passwordController.text.isNotEmpty ? _passwordController.text : null
         );
         
         if (mounted && _passwordController.text.isNotEmpty) {
             ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Password updated successfully')),
             );
             _passwordController.clear();
         }
     }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
      _uploadImage(); 
    }
  }

  Future<void> _uploadImage() async {
      if (_imageFile == null) return;
      
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      
      // Show blocking loading dialog
      if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
               child: Card(
                 color: Colors.white,
                 child: Padding(
                   padding: EdgeInsets.all(20.0),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       CircularProgressIndicator(),
                       SizedBox(height: 16),
                       Text('Uploading image...')
                     ],
                   ),
                 ),
               )
            )
          );
      }

      final success = await Provider.of<AuthProvider>(context, listen: false).updateUserInfo(
          profileImage: base64Image
      );
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (success && mounted) {
           showDialog(
             context: context,
             builder: (ctx) => AlertDialog(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.check_circle, color: Colors.green, size: 60),
                   const SizedBox(height: 16),
                   const Text('Success!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   const Text('Your profile picture has been updated.', textAlign: TextAlign.center),
                   const SizedBox(height: 20),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primaryBlue,
                         foregroundColor: Colors.white
                       ),
                       onPressed: () => Navigator.pop(ctx),
                       child: const Text('OK'),
                     ),
                   )
                 ],
               ),
             )
           );
      }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
            IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                    if (_isEditing) {
                        _saveProfile();
                    } else {
                        setState(() => _isEditing = true);
                    }
                },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             // Profile Picture Section


// ... inside _ProfileScreenState



// ... in build method ...

             Center(
               child: Stack(
                 children: [
                   CircleAvatar(
                     radius: 60,
                     backgroundColor: Colors.grey.shade300,
                     backgroundImage: _imageFile != null 
                        ? FileImage(_imageFile!) as ImageProvider
                        : (user['profileImage'] != null && (user['profileImage'] as String).isNotEmpty)
                            ? NetworkImage(user['profileImage']!)
                            : const AssetImage('assets/images/user_placeholder.png'),
                     child: (_imageFile == null && (user['profileImage'] == null || (user['profileImage'] as String).isEmpty))
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                   ),
                   Positioned(
                     bottom: 0,
                     right: 0,
                     child: CircleAvatar(
                       backgroundColor: AppColors.primaryBlue,
                       radius: 18,
                       child: IconButton(
                         icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                         onPressed: _pickImage,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 24),
             
             // User Info
             _buildInfoTile(
                 label: 'Username / Name', 
                 value: user['name'] ?? 'Guest',
                 isEditing: _isEditing,
                 controller: _nameController,
                 icon: Icons.person
             ),
             _buildInfoTile(
                 label: 'Email', 
                 value: user['email'] ?? 'No Email',
                 isEditing: false, // Email usually immutable key
                 icon: Icons.email
             ),
             
             if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder()
                      ),
                  ),
                ),

             const Divider(height: 40),
             
             // Settings Section
             const Align(
                 alignment: Alignment.centerLeft,
                 child: Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
             ),
             const SizedBox(height: 16),
             SwitchListTile(
                 title: const Text('Dark Mode'),
                 secondary: const Icon(Icons.dark_mode),
                 value: themeProvider.isDarkMode,
                 onChanged: (val) {
                     themeProvider.toggleTheme(val);
                 },
             ),
             
             const SizedBox(height: 40),
             SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16)
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushReplacementNamed(context, '/login');
                    },
                 ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
      required String label, 
      required String value, 
      required bool isEditing, 
      TextEditingController? controller,
      required IconData icon
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
       child: isEditing && controller != null 
         ? TextField(
             controller: controller,
             decoration: InputDecoration(
                 labelText: label,
                 prefixIcon: Icon(icon),
                 border: const OutlineInputBorder()
             ),
           )
         : ListTile(
             leading: Icon(icon, color: AppColors.primaryBlue),
             title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
             subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
             contentPadding: EdgeInsets.zero,
         ),
    );
  }
}

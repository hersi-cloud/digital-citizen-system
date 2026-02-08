import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';

class IDRequestScreen extends StatefulWidget {
  const IDRequestScreen({super.key});

  @override
  State<IDRequestScreen> createState() => _IDRequestScreenState();
}

class _IDRequestScreenState extends State<IDRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _placeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  
  String? _selectedGender;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isFaceDetected = false;
  bool _isScanning = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isScanning = true;
          _isFaceDetected = false;
        });
        
        await _detectFace(pickedFile);
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _detectFace(XFile image) async {
    // Face detection using ML Kit
    // Note: This only works on Android/iOS. 
    // On Linux/Web we might need to bypass or mock for demonstration.
    if (defaultTargetPlatform == TargetPlatform.linux || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.macOS) {
          
        // Mock success for Desktop testing since ML Kit is mobile only
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isScanning = false;
          _isFaceDetected = true; 
        });
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Face Detected (Mocked for Desktop)')),
            );
        }
        return;
    }

    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      
      setState(() {
        _isScanning = false;
        if (faces.isNotEmpty) {
          _isFaceDetected = true;
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Face Verified Successfully! ✅'), backgroundColor: Colors.green),
          );
        } else {
          _isFaceDetected = false;
          _imageFile = null; // Clear invalid image
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No face detected! Please upload a clear photo of yourself. ❌'), backgroundColor: Colors.red),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error detecting face: $e')),
        );
      }
    } finally {
      faceDetector.close();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
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
    if (_imageFile == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your photo')),
      );
      return;
    }
    if (!_isFaceDetected) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a valid face photo')),
      );
      return;
    }

    // Use Provider to submit request
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    
    // In a real app, you would upload the image to a storage bucket (AWS S3, Firebase Storage)
    // and get a URL to send to the backend.
    // For this prototype, we will just send the metadata.
    
    final success = await provider.createRequest('National ID', {
      'fullName': _fullNameController.text,
      'dob': _dobController.text,
      'gender': _selectedGender,
      'phone': _phoneController.text,
      'placeOfBirth': _placeController.text,
    });

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
                     color: Colors.green.shade50,
                     shape: BoxShape.circle,
                   ),
                   padding: const EdgeInsets.all(16),
                   child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                 ),
                 const SizedBox(height: 20),
                 const Text(
                   'Success!',
                   style: TextStyle(
                     fontSize: 24, 
                     fontWeight: FontWeight.bold,
                     color: Colors.black87
                   ),
                 ),
                 const SizedBox(height: 10),
                 const Text(
                   'Your National ID Request has been submitted successfully!',
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
                     onPressed: () => Navigator.pop(ctx), 
                     child: const Text('OK', style: TextStyle(fontSize: 16, color: Colors.white)),
                   ),
                 ),
               ],
             ),
           ),
         )
       );
       _formKey.currentState!.reset();
       _dobController.clear();
       setState(() {
         _selectedGender = null;
         _imageFile = null;
         _isFaceDetected = false;
       });
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(provider.errorMessage ?? 'Request failed')),
         );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('National ID Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Personal Information'),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
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
                 controller: _phoneController,
                 keyboardType: TextInputType.phone,
                 decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                 validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
               const SizedBox(height: 12),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Place of Birth', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
               const SizedBox(height: 24),
              _buildSectionTitle('Upload Photo'),
               
               GestureDetector(
                 onTap: () {
                   _showImageSourceDialog();
                 },
                 child: Container(
                   height: 200,
                   decoration: BoxDecoration(
                     border: Border.all(color: _isFaceDetected ? Colors.green : Colors.grey),
                     borderRadius: BorderRadius.circular(12),
                     color: Colors.grey[200]
                   ),
                   child: _imageFile == null 
                     ? Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: const [
                           Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                           SizedBox(height: 8),
                           Text('Tap to upload Face Photo', style: TextStyle(color: Colors.grey)),
                         ],
                       ),
                     )
                     : Stack(
                       fit: StackFit.expand,
                       children: [
                         ClipRRect(
                           borderRadius: BorderRadius.circular(12),
                           child: Image.file(_imageFile!, fit: BoxFit.cover),
                         ),
                         if (_isScanning)
                           Container(
                             color: Colors.black45,
                             child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                           ),
                         if (_isFaceDetected)
                           Positioned(
                             top: 8,
                             right: 8,
                             child: CircleAvatar(
                               backgroundColor: Colors.green,
                               child: Icon(Icons.check, color: Colors.white),
                             ),
                           )
                       ],
                     ),
                 ),
               ),
               if (_imageFile != null && !_isScanning && !_isFaceDetected)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('No face detected. Please try again.', style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),

              const SizedBox(height: 32),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submit,
                  child: const Text('Submit Request', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
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

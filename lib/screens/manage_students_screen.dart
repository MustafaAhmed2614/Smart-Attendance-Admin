import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  // Controllers for handling input data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();

  // Variables for handling image picking in Flutter Web
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes; // Crucial for uploading files on the web

  final ApiService _apiService = ApiService();

  // State variable to manage submission without disrupting the layout with visual loaders
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  // Method to pick image from gallery/file explorer
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Read bytes for web compatibility
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  // Method to handle form submission
  Future<void> _submitForm() async {
    // Validate if all fields are filled
    if (_rollNoController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API Service to register student
      final response = await _apiService.registerStudent(
        rollNumber: _rollNoController.text,
        name: _nameController.text,
        imageFile: _imageBytes,
        fileName: _selectedImage!.name,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Student Registered Successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form for the next entry
        setState(() {
          _nameController.clear();
          _rollNoController.clear();
          _selectedImage = null;
          _imageBytes = null;
        });
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar Navigation
          const Sidebar(),

          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register New Student',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Modern Form Container
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Roll Number Field
                        TextField(
                          controller: _rollNoController,
                          decoration: const InputDecoration(
                            labelText: 'Roll Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name Field
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Image Upload Button and Preview Status
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(
                              _selectedImage != null
                                  ? Icons.check_circle
                                  : Icons.camera_alt_rounded,
                              color: _selectedImage != null
                                  ? Colors.green
                                  : const Color(0xFF4318FF),
                            ),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                _selectedImage != null
                                    ? 'Image Selected: ${_selectedImage!.name}'
                                    : 'Capture or Upload Face Image',
                                style: TextStyle(
                                  color: _selectedImage != null
                                      ? Colors.green
                                      : const Color(0xFF4318FF),
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _selectedImage != null
                                    ? Colors.green
                                    : const Color(0xFF4318FF),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height:
                              60, // Fixed height to maintain layout stability
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4318FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _isSubmitting
                                  ? 'Registering...'
                                  : 'Register Student',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

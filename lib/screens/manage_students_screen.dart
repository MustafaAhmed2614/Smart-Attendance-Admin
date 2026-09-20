import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  bool _isLoading = false;

  // Image Select karne ka function
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  // Backend API Call function
  Future<void> _registerStudent() async {
    if (_nameController.text.trim().isEmpty ||
        _rollController.text.trim().isEmpty ||
        _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Name, Roll Number aur Photo select karna zaroori hai!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse('http://127.0.0.1:8000/admin/register-student');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = _nameController.text.trim();
      request.fields['roll_number'] = _rollController.text.trim();

      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        _selectedImageBytes!,
        filename: _selectedFileName ?? 'student.jpg',
      );

      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student Successfully Register ho gaya!'),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _rollController.clear();
        setState(() {
          _selectedImageBytes = null;
          _selectedFileName = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $responseData'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Connect Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Student'),
        backgroundColor: const Color(0xFF4C6FFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Register New Student",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Student Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Roll Number Input
            TextField(
              controller: _rollController,
              decoration: const InputDecoration(
                labelText: 'Roll Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 20),

            // Image Selection Box
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo.shade200, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.indigo.shade50.withOpacity(0.3),
                ),
                child: _selectedImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: Color(0xFF4C6FFF),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Click to Upload Student Photo",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _registerStudent,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isLoading ? "Registering..." : "Register Student"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6FFF),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

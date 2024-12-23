import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import './contact_list.dart';

class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({super.key});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _occupationController = TextEditingController();
  bool _isLoading = false;
  String _loadingText = '';
  File? _imageFile;
  final _picker = ImagePicker();

  // Lists for random data generation
  final List<String> _firstNames = ['Rahul', 'Amit', 'Priya', 'Neha', 'Raj', 'Sanjay', 'Pooja', 'Ankit', 'Deepak', 'Ravi'];
  final List<String> _lastNames = ['Kumar', 'Singh', 'Sharma', 'Verma', 'Patel', 'Gupta', 'Yadav', 'Mishra', 'Jha', 'Pandey'];
  final List<String> _occupations = ['Farmer', 'Teacher', 'Doctor', 'Shopkeeper', 'Student', 'Business Owner', 'Driver', 'Mechanic'];
  final List<String> _villages = ['Pratappur', 'Rampur', 'Sultanpur', 'Mirzapur', 'Chandpur'];

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      setState(() {
        _loadingText = 'Compressing image...';
      });

      // Compress image before upload
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed.jpg';
      
      await FlutterImageCompress.compressAndGetFile(
        _imageFile!.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      setState(() {
        _loadingText = 'Uploading image...';
      });

      // Create a unique filename
      final fileName = 'contact_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('contact_images/$fileName');

      // Upload the compressed file
      final compressedFile = File(targetPath);
      final uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _loadingText = 'Uploading: ${progress.toStringAsFixed(0)}%';
        });
      });

      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void _fillRandomData() {
    final random = Random();
    
    // Generate random name
    final firstName = _firstNames[random.nextInt(_firstNames.length)];
    final lastName = _lastNames[random.nextInt(_lastNames.length)];
    _nameController.text = '$firstName $lastName';

    // Generate random 10-digit phone number
    String phone = '9';
    for (int i = 0; i < 9; i++) {
      phone += random.nextInt(10).toString();
    }
    _phoneController.text = phone;

    // Generate random address
    final village = _villages[random.nextInt(_villages.length)];
    _addressController.text = 'House No. ${random.nextInt(500) + 1}, Ward ${random.nextInt(15) + 1}, $village';

    // Generate random occupation
    _occupationController.text = _occupations[random.nextInt(_occupations.length)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload image if selected
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage();
      }

      // Get reference to Firestore collection
      final contactsCollection = FirebaseFirestore.instance.collection('contacts');

      // Create contact document
      await contactsCollection.add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _nameController.clear();
        _phoneController.clear();
        _addressController.clear();
        _occupationController.clear();
        setState(() {
          _imageFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
        actions: [
          // View Contacts Button
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'View Contacts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactListScreen(),
                ),
              );
            },
          ),
          // Quick Fill Button
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Quick Fill',
            onPressed: _fillRandomData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageFile == null
                        ? Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter occupation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _loadingText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : const Text(
                        'Save Contact',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

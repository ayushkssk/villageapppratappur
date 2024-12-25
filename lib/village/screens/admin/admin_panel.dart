import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../services/firestore_service.dart';
import '../../models/news_update.dart';
import '../../models/event.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  XFile? _selectedImage;
  String? _selectedAssetImage;
  final _formKey = GlobalKey<FormState>();
  final _videoUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();

  List<String> _assetImages = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _selectedAssetImage = null; // Clear any selected asset image
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _selectedAssetImage = null;
    });
  }

  void _showAssetImagePicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Image',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _assetImages.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAssetImage = _assetImages[index];
                          _selectedImage = null;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _assetImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAssetImages() async {
    // Add all your asset image paths here
    setState(() {
      _assetImages = [
        'assets/images/middle_school/middle_school.png',
        'assets/images/middle_school/middleschool0.png',
        'assets/images/middle_school/middleschool1.png',
        'assets/images/middle_school/middleschool2.png',
        'assets/images/middle_school/middleschool3.png',
        'assets/images/middle_school/middleschool4.png',
        'assets/images/middle_school/middleschool5.png',
        'assets/images/middle_school/middleschool6.png',
        'assets/images/middle_school/middleschool7.png',
        'assets/images/middle_school/middleschool8.png',
        'assets/images/middle_school/middleschool9.png',
        'assets/images/middle_school/middleschool10.png',
        'assets/images/middle_school/middleschool11.png',
        'assets/images/middle_school/middleschool12.png',
        'assets/images/middle_school/middleschool13.png',
        'assets/images/middle_school/middleschool14.png',
        'assets/images/village_header.png',
        'assets/images/village_image.png',
        'assets/images/village_logo.png',
        'assets/images/village.png',
        'assets/images/village1.png',
        'assets/images/village2.png',
        'assets/images/village3.png',
        'assets/images/village4.png',
      ];
    });
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              color: Colors.grey[100],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_selectedAssetImage != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.asset(
                      _selectedAssetImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No image selected',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                if (_selectedImage != null || _selectedAssetImage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _selectedAssetImage = null;
                          });
                        },
                        tooltip: 'Remove Image',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAssetImagePicker,
                    icon: const Icon(Icons.image),
                    label: const Text('Assets'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('news_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _showSnackBar('Error uploading image: $e');
      return null;
    }
  }

  void _quickFillNewsUpdate(TextEditingController titleController, TextEditingController descriptionController) {
    final titles = [
      'New Community Center Opening',
      'Village Cleanup Drive Success',
      'Cultural Festival Announcement',
      'Infrastructure Development Update',
      'Agricultural Training Program'
    ];
    final descriptions = [
      'The new community center will open next week, featuring modern facilities for all residents.',
      'Over 100 volunteers participated in the village cleanup drive, making our streets cleaner.',
      'Annual cultural festival to showcase local talent and traditions next month.',
      'Road construction project completed ahead of schedule, improving connectivity.',
      'Free training program for farmers on modern farming techniques starting next week.'
    ];
    
    final random = Random();
    titleController.text = titles[random.nextInt(titles.length)];
    descriptionController.text = descriptions[random.nextInt(descriptions.length)];
  }

  void _quickFillEvent(TextEditingController titleController, TextEditingController descriptionController, TextEditingController locationController, DateTime selectedDate) {
    final titles = [
      'Village Sports Tournament',
      'Health Camp',
      'Farmers Meeting',
      'Education Workshop',
      'Community Gathering'
    ];
    final descriptions = [
      'Annual sports tournament featuring cricket, kabaddi, and athletics.',
      'Free health checkup camp with specialist doctors from the city hospital.',
      'Discussion on new farming techniques and government schemes.',
      'Workshop on digital literacy and career guidance for students.',
      'Monthly community gathering to discuss village development.'
    ];
    final locations = [
      'Village Ground',
      'Primary Health Center',
      'Panchayat Hall',
      'Village School',
      'Community Center'
    ];
    
    final random = Random();
    titleController.text = titles[random.nextInt(titles.length)];
    descriptionController.text = descriptions[random.nextInt(descriptions.length)];
    locationController.text = locations[random.nextInt(locations.length)];
    
    // Set date to a random day within next 30 days
    final today = DateTime.now();
    final randomDays = random.nextInt(30) + 1;
    selectedDate = today.add(Duration(days: randomDays));
    setState(() {});
  }

  void _quickFillEmergencyAlert(TextEditingController messageController) {
    final alerts = [
      'Heavy rainfall expected in next 24 hours. Please stay indoors.',
      'Medical camp postponed due to unavoidable circumstances.',
      'Water supply will be interrupted for maintenance work tomorrow.',
      'Road blocked due to fallen tree near village entrance.',
      'Power outage expected from 2 PM to 4 PM for maintenance.'
    ];
    
    final random = Random();
    messageController.text = alerts[random.nextInt(alerts.length)];
  }

  Future<void> _addNewsUpdate() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? imageUrl;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add News Update',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _quickFillNewsUpdate(titleController, descriptionController);
                        },
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Quick Fill'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter news title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter news description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildImagePreview(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                                _showSnackBar('Please fill all fields');
                                return;
                              }

                              try {
                                _setLoading(true);
                                String? finalImageUrl;
                                
                                if (_selectedImage != null) {
                                  finalImageUrl = await _uploadImage(File(_selectedImage!.path));
                                } else if (_selectedAssetImage != null) {
                                  finalImageUrl = _selectedAssetImage;
                                }

                                final newsUpdate = NewsUpdate(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  imageUrl: finalImageUrl ?? '',
                                  timestamp: DateTime.now(),
                                );
                                
                                await _firestoreService.addNewsUpdate(newsUpdate);
                                _showSnackBar('News update added successfully');
                                Navigator.pop(context);
                              } catch (e) {
                                _showSnackBar('Error adding news update: $e');
                              } finally {
                                _setLoading(false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Add Update'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addEvent() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _quickFillEvent(titleController, descriptionController, locationController, selectedDate);
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Quick Fill'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter event title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter event description',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter event location',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      selectedDate = date;
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  locationController.text.isEmpty) {
                _showSnackBar('Please fill all fields');
                return;
              }

              try {
                _setLoading(true);
                final event = Event(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  date: selectedDate,
                  organizer: 'Village Administration', // Default organizer
                );
                await _firestoreService.addEvent(event);
                _showSnackBar('Event added successfully');
                Navigator.pop(context);
              } catch (e) {
                _showSnackBar('Error adding event: $e');
              } finally {
                _setLoading(false);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addEmergencyAlert() async {
    final messageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _quickFillEmergencyAlert(messageController);
              },
              icon: const Icon(Icons.flash_on),
              label: const Text('Quick Fill'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alert Message',
                hintText: 'Enter emergency alert message',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (messageController.text.isEmpty) {
                _showSnackBar('Please enter an alert message');
                return;
              }

              try {
                _setLoading(true);
                final alert = {
                  'message': messageController.text,
                  'timestamp': Timestamp.now(),
                  'isActive': true,
                };
                await _firestoreService.addEmergencyAlert(alert);
                _showSnackBar('Emergency alert added successfully');
                Navigator.pop(context);
              } catch (e) {
                _showSnackBar('Error adding emergency alert: $e');
              } finally {
                _setLoading(false);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPinDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Admin PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter 4-digit PIN',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            if (_pinController.text.length == 4 && _pinController.text != '0000')
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Invalid PIN',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_pinController.text == '0000') {
                setState(() => _isAuthenticated = true);
                Navigator.of(context).pop();
              } else {
                _pinController.clear();
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  // Memory efficient image loading
  Widget _buildNetworkImage(String url, {double? height}) {
    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      cacheHeight: 400, // Limit cached image size
      cacheWidth: 600,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(String itemType) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemType'),
        content: Text('Are you sure you want to delete this $itemType? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Future<bool> _showDeleteConfirmationWithId(String itemType, String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemType'),
        content: Text('Are you sure you want to delete this $itemType? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                _setLoading(true);
                await _firestoreService.deleteNewsUpdate(id);
                _showSnackBar('News update deleted successfully');
                Navigator.pop(context, true);
              } catch (e) {
                _showSnackBar('Error deleting news update: $e');
                Navigator.pop(context, false);
              } finally {
                _setLoading(false);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Widget _buildNewsUpdateCard(DocumentSnapshot newsUpdate) {
    final data = newsUpdate.data() as Map<String, dynamic>;
    final title = data['title'] ?? 'Untitled';
    final description = data['description'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final timestamp = (data['timestamp'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                image: DecorationImage(
                  image: imageUrl.startsWith('assets/')
                    ? AssetImage(imageUrl) as ImageProvider
                    : NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 8),
                Text(
                  'Posted: ${timestamp.toString().split('.')[0]}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Edit'),
                      onPressed: () => _editNewsUpdate(newsUpdate),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text('Delete'),
                      onPressed: () => _showDeleteConfirmationWithId('news update', newsUpdate.id),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editNewsUpdate(DocumentSnapshot newsUpdate) async {
    final data = newsUpdate.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['title']);
    final descriptionController = TextEditingController(text: data['description']);
    String? currentImageUrl = data['imageUrl'];
    XFile? newSelectedImage;
    String? newSelectedAssetImage;
    bool isLoading = false;

    bool validateInputs() {
      if (titleController.text.trim().isEmpty) {
        _showSnackBar('Please enter a title');
        return false;
      }
      if (descriptionController.text.trim().isEmpty) {
        _showSnackBar('Please enter a description');
        return false;
      }
      return true;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit News Update',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isLoading)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: titleController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter news title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            errorText: titleController.text.trim().isEmpty ? 'Title is required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          enabled: !isLoading,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter news description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            errorText: descriptionController.text.trim().isEmpty ? 'Description is required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Stack(
                            children: [
                              if (newSelectedImage != null)
                                Image.file(
                                  File(newSelectedImage!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              else if (newSelectedAssetImage != null)
                                Image.asset(
                                  newSelectedAssetImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              else if (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                                currentImageUrl!.startsWith('assets/')
                                  ? Image.asset(
                                      currentImageUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      currentImageUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.error, color: Colors.red),
                                      ),
                                    ),
                              if (!isLoading)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () async {
                                            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                            if (image != null) {
                                              setState(() {
                                                newSelectedImage = image;
                                                newSelectedAssetImage = null;
                                                currentImageUrl = null;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (newSelectedImage != null || newSelectedAssetImage != null || currentImageUrl != null)
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                newSelectedImage = null;
                                                newSelectedAssetImage = null;
                                                currentImageUrl = null;
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!isLoading)
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Choose an Image',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 400,
                                          child: GridView.builder(
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                            ),
                                            itemCount: _assetImages.length,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    newSelectedAssetImage = _assetImages[index];
                                                    newSelectedImage = null;
                                                    currentImageUrl = null;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Image.asset(
                                                  _assetImages[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Choose from Asset Images'),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isLoading) ...[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                            ],
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!validateInputs()) return;

                                      try {
                                        setState(() => isLoading = true);
                                        String? finalImageUrl = currentImageUrl;
                                        
                                        if (newSelectedImage != null) {
                                          finalImageUrl = await _uploadImage(File(newSelectedImage!.path));
                                          if (finalImageUrl == null) throw Exception('Failed to upload image');
                                        } else if (newSelectedAssetImage != null) {
                                          finalImageUrl = newSelectedAssetImage;
                                        }

                                        await _firestoreService.updateNewsUpdate(
                                          newsUpdate.id,
                                          {
                                            'title': titleController.text.trim(),
                                            'description': descriptionController.text.trim(),
                                            'imageUrl': finalImageUrl ?? '',
                                            'timestamp': DateTime.now(),
                                          },
                                        );
                                        
                                        _showSnackBar('News update edited successfully');
                                        Navigator.pop(context);
                                      } catch (e) {
                                        setState(() => isLoading = false);
                                        _showSnackBar('Error editing news update: ${e.toString()}');
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(DocumentSnapshot event) {
    final data = event.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.event,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(data['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${(data['date'] as Timestamp).toDate().day}/${(data['date'] as Timestamp).toDate().month}/${(data['date'] as Timestamp).toDate().year}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              'Location: ${data['location']}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _isLoading
              ? null
              : () async {
                  if (await _showDeleteConfirmation('event')) {
                    try {
                      _setLoading(true);
                      await _firestoreService.deleteEvent(event.id);
                      _showSnackBar('Event deleted successfully');
                    } catch (e) {
                      _showSnackBar('Error deleting event: $e');
                    } finally {
                      _setLoading(false);
                    }
                  }
                },
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmergencyAlertCard(DocumentSnapshot alert) {
    final data = alert.data() as Map<String, dynamic>;
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(data['message']),
        subtitle: Text(
          'Posted: ${(data['timestamp'] as Timestamp).toDate().toString().split('.')[0]}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _isLoading
              ? null
              : () async {
                  if (await _showDeleteConfirmation('emergency alert')) {
                    try {
                      _setLoading(true);
                      await _firestoreService.deleteEmergencyAlert(alert.id);
                      _showSnackBar('Emergency alert deleted successfully');
                    } catch (e) {
                      _showSnackBar('Error deleting emergency alert: $e');
                    } finally {
                      _setLoading(false);
                    }
                  }
                },
        ),
      ),
    );
  }

  Future<void> _submitReel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      _setLoading(true);
      final reel = {
        'videoUrl': _videoUrlController.text,
        'description': _descriptionController.text,
        'timestamp': Timestamp.now(),
      };
      await _firestoreService.addReel(reel);
      _showSnackBar('Reel added successfully');
      _videoUrlController.clear();
      _descriptionController.clear();
    } catch (e) {
      _showSnackBar('Error adding reel: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAssetImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isAuthenticated) {
        _showPinDialog();
      }
    });
    _videoUrlController.text = 'https://ia800106.us.archive.org/2/items/milleschool_v0/VIDEO-2024-12-23-13-16-31.mp4';
    _descriptionController.text = 'Mille School Video - December 23, 2024';
    _submitReel();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _videoUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'News Updates'),
              Tab(text: 'Events'),
              Tab(text: 'Emergency'),
              Tab(text: 'Reels'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // News Updates Tab
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addNewsUpdate,
                      icon: const Icon(Icons.add),
                      label: const Text('Add News Update'),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getNewsUpdates(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final newsUpdates = snapshot.data?.docs ?? [];
                        if (newsUpdates.isEmpty) {
                          return const Text('No news updates found');
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: newsUpdates.length,
                          itemBuilder: (context, index) {
                            final newsUpdate = newsUpdates[index];
                            return _buildNewsUpdateCard(newsUpdate);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Events Tab
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addEvent,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Event'),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getEvents(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final events = snapshot.data?.docs ?? [];
                        if (events.isEmpty) {
                          return const Text('No events found');
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return _buildEventCard(event);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Emergency Alerts Tab
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addEmergencyAlert,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Emergency Alert'),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getEmergencyAlerts(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final alerts = snapshot.data?.docs ?? [];
                        if (alerts.isEmpty) {
                          return const Text('No emergency alerts found');
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return _buildEmergencyAlertCard(alert);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Reels Tab
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Reel',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _videoUrlController,
                                decoration: InputDecoration(
                                  labelText: 'Video URL',
                                  hintText: 'Enter the video URL',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.link),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter video URL';
                                  }
                                  if (!Uri.tryParse(value)!.isAbsolute) {
                                    return 'Please enter a valid URL';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText: 'Enter reel description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.description),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _submitReel,
                                  icon: const Icon(Icons.video_library),
                                  label: Text(_isLoading ? 'Adding...' : 'Add Reel'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // List of existing reels
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestoreService.getReels(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final reels = snapshot.data?.docs ?? [];
                          if (reels.isEmpty) {
                            return const Center(
                              child: Text('No reels found'),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reels.length,
                            itemBuilder: (context, index) {
                              final reel = reels[index];
                              final data = reel.data() as Map<String, dynamic>;
                              return Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.video_library),
                                  ),
                                  title: Text(data['description'] ?? 'No description'),
                                  subtitle: Text(data['videoUrl'] ?? 'No URL'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      if (await _showDeleteConfirmation('reel')) {
                                        try {
                                          await _firestoreService.deleteReel(reel.id);
                                          _showSnackBar('Reel deleted successfully');
                                        } catch (e) {
                                          _showSnackBar('Error deleting reel: $e');
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

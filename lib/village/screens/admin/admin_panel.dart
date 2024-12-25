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
  final _formKey = GlobalKey<FormState>();
  final _videoUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();

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
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose Image'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(_selectedImage!.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _removeSelectedImage,
              tooltip: 'Remove Image',
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _pickImage,
              tooltip: 'Change Image',
            ),
          ),
        ),
      ],
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
      builder: (context) => AlertDialog(
        title: const Text('Add News Update'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _quickFillNewsUpdate(titleController, descriptionController);
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Quick Fill'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter news title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter news description',
                ),
              ),
              const SizedBox(height: 16),
              _buildImagePreview(),
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
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                _showSnackBar('Please fill all fields');
                return;
              }

              try {
                _setLoading(true);
                String imageUrl = '';
                
                if (_selectedImage != null) {
                  imageUrl = await _uploadImage(File(_selectedImage!.path)) ?? '';
                }

                final newsUpdate = NewsUpdate(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  imageUrl: imageUrl,
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
            child: const Text('Add'),
          ),
        ],
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
            if (_pinController.text.length == 4 && _pinController.text != '0471')
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

  Widget _buildNewsUpdateCard(DocumentSnapshot newsUpdate) {
    final data = newsUpdate.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        title: Text(data['title']),
        subtitle: Text(
          data['description'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _isLoading
              ? null
              : () async {
                  if (await _showDeleteConfirmation('news update')) {
                    try {
                      _setLoading(true);
                      await _firestoreService.deleteNewsUpdate(newsUpdate.id);
                      _showSnackBar('News update deleted successfully');
                    } catch (e) {
                      _showSnackBar('Error deleting news update: $e');
                    } finally {
                      _setLoading(false);
                    }
                  }
                },
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

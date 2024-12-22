import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class ImportantContacts extends StatelessWidget {
  const ImportantContacts({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  Future<void> _openMap(String address) async {
    final Uri launchUri = Uri.parse('https://www.google.com/maps/place/Post+Office+Pratappur/@25.4795062,84.7226335,437m/data=!3m1!1e3!4m6!3m5!1s0x398d597b7e6aec21:0x188176fdd7894b61!8m2!3d25.4795062!4d84.723533!16s%2Fg%2F11bwp5skm0?entry=ttu&g_ep=EgoyMDI0MTIxMS4wIKXMDSoASAFQAw%3D%3D');
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> contacts = [
      {
        'name': 'Village Head',
        'phone': '9876543210',
        'email': 'pradhan@example.com',
        'role': 'Village Administration',
        'icon': Icons.person,
      },
      {
        'name': 'Panchayat Secretary',
        'phone': '9876543211',
        'email': 'secretary@example.com',
        'role': 'Panchayat Administration',
        'icon': Icons.admin_panel_settings,
      },
      {
        'name': 'Health Worker',
        'phone': '9876543212',
        'email': 'health@example.com',
        'role': 'Health Services',
        'icon': Icons.health_and_safety,
      },
      {
        'name': 'Education Officer',
        'phone': '9876543213',
        'email': 'education@example.com',
        'role': 'Education Department',
        'icon': Icons.school,
      },
      {
        'name': 'Agriculture Officer',
        'phone': '9876543214',
        'email': 'agriculture@example.com',
        'role': 'Agriculture Department',
        'icon': Icons.agriculture,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Contacts'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 20),
              const Text(
                'Important Contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              // Post Office Section
              Card(
                elevation: 4,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.asset(
                        'assets/images/post_office.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Post Office',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildContactItem(
                            'Address',
                            'FPHF+RC3, Pratappur, Jalpura Tapa, Bihar 802352',
                            Icons.location_on,
                            onTap: () => _openMap('Post Office Pratappur'),
                          ),
                          _buildContactItem(
                            'Phone',
                            '+91 XXXXX XXXXX',
                            Icons.phone,
                            onTap: () => _makePhoneCall('+91XXXXXXXXXX'),
                          ),
                          _buildContactItem(
                            'Timing',
                            'Monday - Saturday: 9:00 AM - 5:00 PM',
                            Icons.access_time,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Contacts
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildEmergencyContact(
                        'Police',
                        '100',
                        Icons.local_police,
                      ),
                      _buildEmergencyContact(
                        'Ambulance',
                        '108',
                        Icons.medical_services,
                      ),
                      _buildEmergencyContact(
                        'Fire Station',
                        '101',
                        Icons.fire_truck,
                      ),
                      _buildEmergencyContact(
                        'Women Helpline',
                        '1091',
                        Icons.woman,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Important Contacts
              const Text(
                'Village Officials',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(contact['icon'], color: Colors.white),
                      ),
                      title: Text(
                        contact['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(contact['role']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () => _makePhoneCall(contact['phone']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.email, color: Colors.blue),
                            onPressed: () => _sendEmail(contact['email']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String name, String number, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(name),
      subtitle: Text(number),
      trailing: IconButton(
        icon: const Icon(Icons.phone, color: Colors.red),
        onPressed: () => _makePhoneCall(number),
      ),
    );
  }
}

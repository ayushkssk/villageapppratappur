import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './important_helplines.dart';

enum CardPosition { topLeft, topRight, bottomLeft, bottomRight }

class EmergencyServices extends StatelessWidget {
  const EmergencyServices({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.22;  // 22% of screen height

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'आपातकालीन सेवाएं / Emergency Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: cardHeight * 2 + 20,  // Height for 2 rows + spacing
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: constraints.maxWidth / (cardHeight * 2),
                            children: [
                              _buildEmergencyCard(
                                'Police',
                                'पुलिस',
                                '100',
                                Icons.local_police,
                                Colors.blue,
                                position: CardPosition.topLeft,
                              ),
                              _buildEmergencyCard(
                                'Ambulance',
                                'एम्बुलेंस',
                                '108',
                                Icons.medical_services,
                                Colors.green,
                                position: CardPosition.topRight,
                              ),
                              _buildEmergencyCard(
                                'Fire',
                                'दमकल',
                                '101',
                                Icons.fire_truck,
                                Colors.orange,
                                position: CardPosition.bottomLeft,
                              ),
                              _buildEmergencyCard(
                                'Women Helpline',
                                'महिला हेल्पलाइन',
                                '1091',
                                Icons.woman,
                                Colors.purple,
                                position: CardPosition.bottomRight,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.red, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ImportantHelplines(),
                              ),
                            );
                          },
                          customBorder: const CircleBorder(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.phone_in_talk,
                                color: Colors.red,
                                size: 24,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'हेल्पलाइन',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Local Emergency Contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                  ),
                  title: const Text(
                    'Primary Health Center',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Sandesh PHC'),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.white),
                      onPressed: () => _makePhoneCall('+91XXXXXXXXXX'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security, color: Colors.white, size: 24),
                  ),
                  title: const Text(
                    'Local Police Station',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Sandesh Thana'),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.white),
                      onPressed: () => _makePhoneCall('+91XXXXXXXXXX'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => _makePhoneCall('112'),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.emergency),
          label: const Text(
            'Emergency - 112',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Path getClipPath(Size size, CardPosition position) {
    final path = Path();
    const radius = 20.0;  // Outer corner radius
    const innerRadius = 40.0;  // Inner corner radius (near center)
    const circleRadius = 50.0;

    switch (position) {
      case CardPosition.topLeft:
        // Top-left corner
        path.moveTo(radius, 0);
        path.quadraticBezierTo(0, 0, 0, radius);
        
        // Left side
        path.lineTo(0, size.height - radius);
        
        // Bottom-left corner
        path.quadraticBezierTo(0, size.height, radius, size.height);
        
        // Bottom side to center curve
        path.lineTo(size.width - circleRadius, size.height);
        
        // Inner corner curve
        path.quadraticBezierTo(
          size.width - innerRadius,
          size.height - innerRadius,
          size.width,
          size.height - innerRadius,
        );
        
        // Right side
        path.lineTo(size.width, radius);
        
        // Top-right corner
        path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
        
        path.close();
        break;

      case CardPosition.topRight:
        // Top-left corner
        path.moveTo(radius, 0);
        path.quadraticBezierTo(0, 0, 0, radius);
        
        // Left side to center curve
        path.lineTo(0, size.height - innerRadius);
        
        // Inner corner curve
        path.quadraticBezierTo(
          innerRadius,
          size.height - innerRadius,
          circleRadius,
          size.height,
        );
        
        // Bottom side
        path.lineTo(size.width - radius, size.height);
        
        // Bottom-right corner
        path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
        
        // Right side
        path.lineTo(size.width, radius);
        
        // Top-right corner
        path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
        
        path.close();
        break;

      case CardPosition.bottomLeft:
        // Top-left corner
        path.moveTo(radius, 0);
        path.quadraticBezierTo(0, 0, 0, radius);
        
        // Left side
        path.lineTo(0, size.height - radius);
        
        // Bottom-left corner
        path.quadraticBezierTo(0, size.height, radius, size.height);
        
        // Bottom side
        path.lineTo(size.width - radius, size.height);
        
        // Bottom-right corner
        path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
        
        // Right side to center curve
        path.lineTo(size.width, innerRadius);
        
        // Inner corner curve
        path.quadraticBezierTo(
          size.width - innerRadius,
          innerRadius,
          size.width - circleRadius,
          0,
        );
        
        path.close();
        break;

      case CardPosition.bottomRight:
        // Top side from center curve
        path.moveTo(circleRadius, 0);
        
        // Inner corner curve
        path.quadraticBezierTo(
          innerRadius,
          innerRadius,
          0,
          innerRadius,
        );
        
        // Left side
        path.lineTo(0, size.height - radius);
        
        // Bottom-left corner
        path.quadraticBezierTo(0, size.height, radius, size.height);
        
        // Bottom side
        path.lineTo(size.width - radius, size.height);
        
        // Bottom-right corner
        path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
        
        // Right side
        path.lineTo(size.width, radius);
        
        // Top-right corner
        path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
        
        path.close();
        break;
    }
    return path;
  }

  Widget _buildEmergencyCard(
    String title,
    String subtitle,
    String number,
    IconData icon,
    Color color, {
    required CardPosition position,
  }) {
    return ClipPath(
      clipper: CustomCardClipper(
        position: position,
        getClipPath: (size) => getClipPath(size, position),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _makePhoneCall(number),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;

                return Padding(
                  padding: EdgeInsets.all(maxWidth * 0.04),  // Responsive padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.all(maxWidth * 0.06),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: maxWidth * 0.15,  // Responsive icon size
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.02),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: maxWidth * 0.08,  // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: maxWidth * 0.07,  // Responsive font size
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.02),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: maxWidth * 0.04,
                          vertical: maxHeight * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(maxWidth * 0.08),
                        ),
                        child: Text(
                          number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: maxWidth * 0.12,  // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCardClipper extends CustomClipper<Path> {
  final CardPosition position;
  final Path Function(Size) getClipPath;

  CustomCardClipper({
    required this.position,
    required this.getClipPath,
  });

  @override
  Path getClip(Size size) => getClipPath(size);

  @override
  bool shouldReclip(CustomCardClipper oldClipper) => false;
}

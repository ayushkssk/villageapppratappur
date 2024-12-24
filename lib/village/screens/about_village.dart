import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'events_screen.dart';
import 'reels_screen.dart';
import 'home_screen.dart';

class AboutVillage extends StatefulWidget {
  const AboutVillage({super.key});

  @override
  State<AboutVillage> createState() => _AboutVillageState();
}

class _AboutVillageState extends State<AboutVillage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        return;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReelsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Pratappur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/village.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Basic Information', [
                    _buildInfoRow('Village Name', 'Pratappur (प्रतापुर)'),
                    _buildInfoRow('Village Code', '247004'),
                    _buildInfoRow('Gram Panchayat', 'Akhgaon'),
                    _buildInfoRow('Block', 'Sandesh'),
                    _buildInfoRow('District', 'Bhojpur'),
                    _buildInfoRow('State', 'Bihar'),
                    _buildInfoRow('Division', 'Patna'),
                    _buildInfoRow('Pin Code', '802161'),
                    _buildInfoRow('Post Office', 'Pratappur'),
                    _buildInfoRow('Phone Code', '06135'),
                  ]),
                  
                  _buildSection('Demographics', [
                    _buildInfoRow('Total Population', '1,552'),
                    _buildInfoRow('Male Population', '769'),
                    _buildInfoRow('Female Population', '783'),
                    _buildInfoRow('Number of Households', '287'),
                    _buildInfoRow('Total Area', '57 hectares'),
                    _buildInfoRow('Literacy Rate', '68.62%'),
                    _buildInfoRow('Male Literacy', '77.76%'),
                    _buildInfoRow('Female Literacy', '59.64%'),
                    _buildInfoRow('Languages', 'Bhojpuri, Maithili, Hindi, Urdu'),
                    _buildInfoRow('Main Language', 'Bhojpuri'),
                  ]),

                  _buildSection('Location & Geography', [
                    _buildInfoRow('Distance from District HQ', '30 km from Arrah'),
                    _buildInfoRow('Distance from Block HQ', '12 km from Sandesh'),
                    _buildInfoRow('Distance from Patna', '54 km'),
                    _buildInfoRow('Elevation', '67 meters above sea level'),
                    _buildInfoRow('Nearby Rivers', 'Son, Punpun (पुनपुन नदी)'),
                  ]),

                  _buildSection('Political Information', [
                    _buildInfoRow('Assembly Constituency', 'Sandesh'),
                    _buildInfoRow('Assembly MLA', 'Kiran Devi'),
                    _buildInfoRow('Lok Sabha Constituency', 'Arrah'),
                    _buildInfoRow('Parliament MP', 'R. K. Singh'),
                    _buildInfoRow('Major Parties', 'JD(U), BJP, LJP, RJD'),
                  ]),

                  _buildSection('Educational Institutions', [
                    _buildInfoRow('1.', 'Sri Angadh Rajkiya Madhya Vidhyalay Pratappur'),
                    _buildInfoRow('2.', 'S.N Lal High School'),
                    _buildInfoRow('3.', 'Others'),
                  ]),

                  _buildSection('Connectivity', [
                    _buildInfoRow('Railway Stations', 'Arrah Railway Station, Kulhariya Halt'),
                    _buildInfoRow('Nearest Town', 'Arrah (15 km)'),
                    _buildInfoRow('Surrounding Blocks', 'Agiaon (West), Bikram (East), Dulhin Bazar (East), Paliganj (East)'),
                  ]),

                  const SizedBox(height: 20),
                  const SelectableText(
                    'About Pratappur',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    'Pratappur (Village Code: 247004) is a village located in Sandesh subdivision of Bhojpur district in Bihar, India. It is situated 12km away from sub-district headquarter Sandesh (tehsildar office) and 30km away from district headquarter Arrah. The village comes under Akhgaon gram panchayat.\n\n'
                    'The total geographical area of the village is 57 hectares. Pratappur has a total population of 1,552 people, with 769 males and 783 females. The village has a literacy rate of 68.62%, with male literacy at 77.76% and female literacy at 59.64%. There are about 287 households in Pratappur.\n\n'
                    'Arrah, which is approximately 15km away, is the nearest town and serves as the hub for all major economic activities.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Village',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Reels',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SelectableText(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SelectableText(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

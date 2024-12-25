import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportantHelplines extends StatelessWidget {
  const ImportantHelplines({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.shade500],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHelplineCard(
    String title,
    String subtitle,
    List<String> numbers, {
    Color? color,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final titleSize = isTablet ? 16.0 : 14.0;
        final subtitleSize = isTablet ? 14.0 : 12.0;
        final numberSize = isTablet ? 15.0 : 13.0;
        final iconSize = isTablet ? 32.0 : 28.0;
        final cardColor = color ?? Colors.blue;
        final darkerColor = HSLColor.fromColor(cardColor).withLightness(0.4).toColor();

        return Card(
          elevation: 4,
          shadowColor: cardColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: cardColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  cardColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.all(isTablet ? 12 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 10),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon ?? Icons.phone_in_talk,
                    color: darkerColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(height: isTablet ? 10 : 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isTablet ? 10 : 8),
                ...numbers.map((number) => Padding(
                      padding: EdgeInsets.only(top: isTablet ? 4 : 3),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _makePhoneCall(number),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 8,
                              vertical: isTablet ? 8 : 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cardColor.withOpacity(0.15),
                                  cardColor.withOpacity(0.05),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cardColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  number,
                                  style: TextStyle(
                                    fontSize: numberSize,
                                    fontWeight: FontWeight.w600,
                                    color: darkerColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: isTablet ? 8 : 6),
                                Icon(
                                  Icons.phone,
                                  size: numberSize,
                                  color: darkerColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildHelplineGrid(List<Widget> children, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: isTablet ? 1.0 : 0.9,
      mainAxisSpacing: isTablet ? 12 : 8,
      crossAxisSpacing: isTablet ? 12 : 8,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('महत्वपूर्ण हेल्पलाइन नंबर'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade500],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
                    child: Column(
                      children: [
                        _buildSectionHeader('सरकारी सेवाएं / Government Services'),
                        _buildHelplineGrid([
                          _buildHelplineCard(
                            'CM शिकायत पोर्टल',
                            'CM Complaint Portal',
                            ['181'],
                            color: Colors.indigo,
                            icon: Icons.account_balance,
                          ),
                          _buildHelplineCard(
                            'भ्रष्टाचार विरोधी',
                            'Anti-Corruption',
                            ['1031'],
                            color: Colors.indigo,
                            icon: Icons.gavel,
                          ),
                          _buildHelplineCard(
                            'सी एम सहायता लाइन',
                            'CM Help Line',
                            ['1076'],
                            color: Colors.indigo,
                            icon: Icons.support_agent,
                          ),
                          _buildHelplineCard(
                            'क्राइम स्टॉपर',
                            'Crime Stopper',
                            ['1090'],
                            color: Colors.indigo,
                            icon: Icons.security,
                          ),
                          _buildHelplineCard(
                            'महिला सहायता लाइन',
                            'Women Helpline',
                            ['1091'],
                            color: Colors.indigo,
                            icon: Icons.woman,
                          ),
                          _buildHelplineCard(
                            'पृथ्वी भूकम्प',
                            'Earthquake',
                            ['1092'],
                            color: Colors.indigo,
                            icon: Icons.waves,
                          ),
                        ], context),

                        _buildSectionHeader('यातायात और रेलवे / Transport & Railway'),
                        _buildHelplineGrid([
                          _buildHelplineCard(
                            'यातायात पुलिस',
                            'Traffic Police',
                            ['103'],
                            color: Colors.blue,
                            icon: Icons.traffic,
                          ),
                          _buildHelplineCard(
                            'रेलवे पूछताछ',
                            'Railway Enquiry',
                            ['139'],
                            color: Colors.blue,
                            icon: Icons.train,
                          ),
                          _buildHelplineCard(
                            'रेल दुर्घटना',
                            'Railway Accident',
                            ['1072'],
                            color: Colors.blue,
                            icon: Icons.railway_alert,
                          ),
                          _buildHelplineCard(
                            'सड़क दुर्घटना',
                            'Road Accident',
                            ['1073'],
                            color: Colors.blue,
                            icon: Icons.car_crash,
                          ),
                        ], context),

                        _buildSectionHeader('अन्य सेवाएं / Other Services'),
                        _buildHelplineGrid([
                          _buildHelplineCard(
                            'विद्युत सेवा',
                            'Electricity Service',
                            ['1912'],
                            color: Colors.amber,
                            icon: Icons.electric_bolt,
                          ),
                          _buildHelplineCard(
                            'पशु सेवा',
                            'Animal Service',
                            ['1962'],
                            color: Colors.brown,
                            icon: Icons.pets,
                          ),
                          _buildHelplineCard(
                            'किसान काल सेन्टर',
                            'Farmer Call Center',
                            ['1551'],
                            color: Colors.green,
                            icon: Icons.agriculture,
                          ),
                          _buildHelplineCard(
                            'नागरिक काल सेन्टर',
                            'Citizen Call Center',
                            ['155300'],
                            color: Colors.teal,
                            icon: Icons.contact_phone,
                          ),
                        ], context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'government_projects/har_ghar_nal_jal.dart'; // Added import for the new page

class GovernmentSchemes extends StatefulWidget {
  const GovernmentSchemes({super.key});

  @override
  State<GovernmentSchemes> createState() => _GovernmentSchemesState();
}

class _GovernmentSchemesState extends State<GovernmentSchemes> {
  int? _expandedIndex;

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> schemes = [
      {
        'title': 'हर घर नल का जल',
        'description': 'जल आपूर्ति योजना',
        'details': '''
• मुख्य उद्देश्य:
  - हर घर में नल का कनेक्शन
  - स्वच्छ पेयजल की आपूर्ति
• सुविधाएं:
  - 24x7 जल आपूर्ति
  - शिकायत निवारण सिस्टम
  - टोल फ्री हेल्पलाइन
• संपर्क:
  - जिला नियंत्रण कक्ष
  - कार्यपालक अभियंता
  - टोल फ्री: 18001231121''',
        'url': 'http://www.phedcgrc.in',
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HarGharNalJal(),
          ),
        ),
      },
      {
        'title': 'प्रधानमंत्री किसान सम्मान निधि',
        'description': 'किसानों को वित्तीय सहायता',
        'details': '''
• योजना का लाभ: प्रति वर्ष ₹6,000 की वित्तीय सहायता
• पात्रता: सभी छोटे और सीमांत किसान
• किश्त: ₹2,000 की 3 किश्तों में
• आवेदन प्रक्रिया: 
  - ऑनलाइन पंजीकरण
  - आधार कार्ड अनिवार्य
  - बैंक खाता जरूरी
• दस्तावेज़:
  - आधार कार्ड
  - बैंक पासबुक
  - भूमि रिकॉर्ड''',
        'url': 'https://pmkisan.gov.in/',
        'icon': Icons.agriculture,
        'color': Colors.green,
      },
      {
        'title': 'आयुष्मान भारत',
        'description': 'स्वास्थ्य बीमा योजना',
        'details': '''
• कवरेज: प्रति परिवार ₹5 लाख तक का स्वास्थ्य बीमा
• लाभ:
  - मुफ्त इलाज
  - कैशलेस उपचार
  - सभी पुरानी बीमारियां शामिल
• पात्रता:
  - SECC डेटाबेस में शामिल परिवार
  - गरीबी रेखा के नीचे के परिवार
• सुविधाएं:
  - 1,500+ प्रक्रियाएं कवर
  - पूरे भारत में मान्य
  - 24x7 हेल्पलाइन''',
        'url': 'https://pmjay.gov.in/',
        'icon': Icons.health_and_safety,
        'color': Colors.blue,
      },
      {
        'title': 'प्रधानमंत्री आवास योजना',
        'description': 'आवास सहायता',
        'details': '''
• सहायता राशि:
  - मैदानी क्षेत्र: ₹1.5 लाख
  - पहाड़ी क्षेत्र: ₹1.6 लाख
• पात्रता:
  - BPL परिवार
  - कच्चे मकान में रहने वाले
  - बेघर परिवार
• आवेदन प्रक्रिया:
  - ग्राम पंचायत में आवेदन
  - ऑनलाइन पंजीकरण
• आवश्यक दस्तावेज:
  - आधार कार्ड
  - BPL कार्ड
  - जमीन के कागजात''',
        'url': 'https://pmaymis.gov.in/',
        'icon': Icons.home,
        'color': Colors.orange,
      },
      {
        'title': 'सौभाग्य योजना',
        'description': 'विद्युतीकरण योजना',
        'details': '''
• मुख्य लाभ:
  - मुफ्त बिजली कनेक्शन
  - LED बल्ब मुफ्त
• कवरेज:
  - ग्रामीण क्षेत्र
  - शहरी क्षेत्र
• विशेष सुविधाएं:
  - 24x7 बिजली आपूर्ति
  - स्मार्ट मीटर
• आवेदन प्रक्रिया:
  - स्थानीय बिजली कार्यालय
  - ऑनलाइन आवेदन
• दस्तावेज:
  - पहचान प्रमाण
  - निवास प्रमाण''',
        'url': 'https://saubhagya.gov.in/',
        'icon': Icons.electric_bolt,
        'color': Colors.yellow[800]!,
      },
      {
        'title': 'जन धन योजना',
        'description': 'वित्तीय समावेश',
        'details': '''
• खाता सुविधाएं:
  - शून्य बैलेंस खाता
  - रुपे डेबिट कार्ड
  - ₹2 लाख का दुर्घटना बीमा
• अतिरिक्त लाभ:
  - ₹30,000 का जीवन बीमा
  - ओवरड्राफ्ट सुविधा
• पात्रता:
  - 18+ आयु
  - कोई भी भारतीय
• आवश्यक दस्तावेज:
  - आधार कार्ड
  - पैन कार्ड (वैकल्पिक)
  - फोटो''',
        'url': 'https://pmjdy.gov.in/',
        'icon': Icons.account_balance,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('सरकारी योजनाएं', style: TextStyle(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionPanelList(
            elevation: 1,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (index, isExpanded) {
              setState(() {
                _expandedIndex = _expandedIndex == index ? null : index;
              });
            },
            children: List.generate(
              schemes.length,
              (index) {
                final scheme = schemes[index];
                return ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme['color'],
                        child: Icon(
                          scheme['icon'] as IconData,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        scheme['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(scheme['description'] as String),
                    );
                  },
                  body: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scheme['details'] as String,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: scheme['onTap'] != null
                                  ? scheme['onTap'] as void Function()?
                                  : () => _launchURL(scheme['url'] as String),
                              icon: const Icon(Icons.launch),
                              label: const Text('अधिक जानकारी'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme['color'],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isExpanded: _expandedIndex == index,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

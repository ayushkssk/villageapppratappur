import 'package:flutter/material.dart';

class NewsNotices extends StatelessWidget {
  const NewsNotices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News & Notices'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 20),
              const Text(
                'समाचार और सूचनाएं / News & Notices',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              // Latest News Section
              _buildNewsSection(
                'ताज़ा समाचार / Latest News',
                [
                  NewsItem(
                    title: 'ग्राम सभा की बैठक / Village Council Meeting',
                    date: '25 दिसंबर 2023',
                    content: 'आगामी ग्राम सभा की बैठक 25 दिसंबर को सुबह 10 बजे पंचायत भवन में होगी। सभी ग्रामवासियों से अनुरोध है कि वे समय पर उपस्थित हों।',
                    type: NewsType.important,
                  ),
                  NewsItem(
                    title: 'स्वच्छता अभियान / Cleanliness Drive',
                    date: '20 दिसंबर 2023',
                    content: 'गाँव में स्वच्छता अभियान का आयोजन किया जा रहा है। सभी ग्रामवासियों से सहयोग की अपेक्षा है।',
                    type: NewsType.normal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Important Notices
              _buildNewsSection(
                'महत्वपूर्ण सूचनाएं / Important Notices',
                [
                  NewsItem(
                    title: 'राशन कार्ड अपडेट / Ration Card Update',
                    date: '18 दिसंबर 2023',
                    content: 'सभी राशन कार्ड धारकों को सूचित किया जाता है कि वे अपने राशन कार्ड का वार्षिक सत्यापन करवाएं।',
                    type: NewsType.important,
                  ),
                  NewsItem(
                    title: 'टीकाकरण कैंप / Vaccination Camp',
                    date: '15 दिसंबर 2023',
                    content: 'प्राथमिक स्वास्थ्य केंद्र में बच्चों के लिए टीकाकरण कैंप का आयोजन किया जाएगा।',
                    type: NewsType.normal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Development Updates
              _buildNewsSection(
                'विकास कार्य अपडेट / Development Updates',
                [
                  NewsItem(
                    title: 'सड़क निर्माण / Road Construction',
                    date: '10 दिसंबर 2023',
                    content: 'मुख्य मार्ग का निर्माण कार्य प्रगति पर है। कृपया वैकल्पिक मार्ग का प्रयोग करें।',
                    type: NewsType.normal,
                  ),
                  NewsItem(
                    title: 'सौर ऊर्जा परियोजना / Solar Energy Project',
                    date: '5 दिसंबर 2023',
                    content: 'गाँव में सौर ऊर्जा परियोजना की शुरुआत की जा रही है। इच्छुक परिवार संपर्क करें।',
                    type: NewsType.important,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement news submission
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coming Soon: Submit your news/notice'),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNewsSection(String title, List<NewsItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildNewsCard(item)),
      ],
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.type == NewsType.important)
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.date,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

enum NewsType {
  normal,
  important,
}

class NewsItem {
  final String title;
  final String date;
  final String content;
  final NewsType type;

  NewsItem({
    required this.title,
    required this.date,
    required this.content,
    this.type = NewsType.normal,
  });
}

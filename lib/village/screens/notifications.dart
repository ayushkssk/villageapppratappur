import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Widget _buildNotificationCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onTap: () {
          // Add animation when tapped
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: $title'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          late String title;
          late String subtitle;
          late IconData icon;

          switch (index) {
            case 0:
              title = 'Gram Sabha Meeting';
              subtitle = 'Tomorrow at 10:00 AM at Gram Panchayat Bhavan';
              icon = Icons.event;
              break;
            case 1:
              title = 'Covid Vaccination Camp';
              subtitle = 'Sunday at 9:00 AM';
              icon = Icons.medical_services;
              break;
            case 2:
              title = 'Kisan Sammelan';
              subtitle = 'Next Saturday at 2:00 PM';
              icon = Icons.agriculture;
              break;
            case 3:
              title = 'New Road Construction Completed';
              subtitle = 'The road construction from main market to village has been completed.';
              icon = Icons.construction;
              break;
            default:
              title = 'Cleanliness Drive';
              subtitle = 'A cleanliness drive was organized in the village.';
              icon = Icons.cleaning_services;
          }

          return _buildNotificationCard(context, title, subtitle, icon);
        },
      ),
    );
  }
}

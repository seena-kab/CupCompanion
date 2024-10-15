import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Example notifications data (this can be replaced with real data)
  List<Map<String, dynamic>> allNotifications = [
    {
      'title': 'Message from John',
      'subtitle': 'Hey, let\'s catch up tomorrow!',
      'time': '5 minutes ago',
      'icon': Icons.message,
      'unread': true,
    },
    {
      'title': 'System Update',
      'subtitle': 'Your app has a new update available.',
      'time': '1 hour ago',
      'icon': Icons.system_update,
      'unread': false,
    },
    {
      'title': 'Promotion Offer',
      'subtitle': '50% off on all items this weekend!',
      'time': '2 hours ago',
      'icon': Icons.local_offer,
      'unread': true,
    },
    {
      'title': 'Reminder',
      'subtitle': 'Your meeting is in 30 minutes.',
      'time': '3 hours ago',
      'icon': Icons.alarm,
      'unread': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Messages'),
            Tab(text: 'System Alerts'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to notification settings
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(allNotifications), // "All" notifications tab
          _buildNotificationList(_filterNotifications('Messages')), // "Messages" tab
          _buildNotificationList(_filterNotifications('System Alerts')), // "System Alerts" tab
        ],
      ),
    );
  }

  // Function to build the notification list
  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications available.'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: Icon(notification['icon'], color: notification['unread'] ? Colors.red : Colors.grey),
          title: Text(notification['title']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['subtitle']),
              Text(notification['time'], style: const TextStyle(fontSize: 12)),
            ],
          ),
          trailing: Icon(
            notification['unread'] ? Icons.circle : Icons.check_circle,
            color: notification['unread'] ? Colors.red : Colors.green,
          ),
          onTap: () {
            // Handle notification tap (e.g., navigate to details page)
            _showNotificationActions(notification, index);
          },
        );
      },
    );
  }

  // Function to filter notifications based on category
  List<Map<String, dynamic>> _filterNotifications(String category) {
    switch (category) {
      case 'Messages':
        return allNotifications
            .where((notification) => notification['icon'] == Icons.message)
            .toList();
      case 'System Alerts':
        return allNotifications
            .where((notification) => notification['icon'] == Icons.system_update || notification['icon'] == Icons.alarm)
            .toList();
      default:
        return allNotifications;
    }
  }

  // Function to show actions when a notification is tapped
  void _showNotificationActions(Map<String, dynamic> notification, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: notification['unread'] ? Colors.red : Colors.green),
              title: Text(notification['unread'] ? 'Mark as Read' : 'Mark as Unread'),
              onTap: () {
                setState(() {
                  allNotifications[index]['unread'] = !allNotifications[index]['unread'];
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Notification'),
              onTap: () {
                setState(() {
                  allNotifications.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

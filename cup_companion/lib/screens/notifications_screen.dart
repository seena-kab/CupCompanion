import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();

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

  // Task manager data
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Add an extra tab for Tasks
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
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
            Tab(text: 'Tasks'), // New Task Manager tab
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
          _buildTaskManager(), // "Tasks" tab content
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

  // Task Manager functions
  Widget _buildTaskManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _taskTitleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _taskDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'Enter task description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('Add Task'),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? const Center(child: Text('No tasks available.'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Icon(
                        task['completed'] ? Icons.check_circle : Icons.circle_outlined,
                        color: task['completed'] ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          decoration: task['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: task['description'] != null
                          ? Text(task['description'] as String)
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
                      onTap: () => _toggleTaskCompletion(index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _addTask() {
    final taskTitle = _taskTitleController.text;
    final taskDescription = _taskDescriptionController.text;
    if (taskTitle.isNotEmpty) {
      setState(() {
        tasks.add({
          'title': taskTitle,
          'description': taskDescription,
          'completed': false,
        });
        _taskTitleController.clear();
        _taskDescriptionController.clear();
      });
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }
}

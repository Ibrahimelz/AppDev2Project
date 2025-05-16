import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/notification_service.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({Key? key}) : super(key: key);

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _priority = 'normal';
  String _searchQuery = '';
  Set<String> _deletedNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _fetchDeletedNotifications();
  }

  Future<void> _fetchDeletedNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final deletedDocs = await FirebaseFirestore.instance
        .collection('Admins')
        .where('email', isEqualTo: user.email)
        .get();
    if (deletedDocs.docs.isEmpty) return;
    final userDoc = deletedDocs.docs.first.reference;
    final deletedNotifs = await userDoc.collection('deletedNotifications').get();
    setState(() {
      _deletedNotificationIds = deletedNotifs.docs.map((d) => d.id).toSet();
    });
  }

  Future<void> _deleteNotificationForAdmin(String notifId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final deletedDocs = await FirebaseFirestore.instance
        .collection('Admins')
        .where('email', isEqualTo: user.email)
        .get();
    if (deletedDocs.docs.isEmpty) return;
    final userDoc = deletedDocs.docs.first.reference;
    await userDoc.collection('deletedNotifications').doc(notifId).set({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
    setState(() {
      _deletedNotificationIds.add(notifId);
    });
  }

  Future<void> _createNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required.')),
      );
      return;
    }
    // Fetch current admin's name
    final user = await FirebaseFirestore.instance.collection('Admins').where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email).get();
    String adminName = 'Unknown';
    if (user.docs.isNotEmpty) {
      final data = user.docs.first.data();
      adminName = (data['fname'] ?? '') + ' ' + (data['lname'] ?? '');
    }
    await FirebaseFirestore.instance.collection('Notifications').add({
      'title': _titleController.text,
      'message': _messageController.text,
      'date': Timestamp.now(),
      'priority': _priority,
      'adminName': adminName,
    });
    // Trigger local notification for admin (and for demo, on this device)
    await NotificationService().showNotification(
      title: _titleController.text,
      body: _messageController.text,
    );
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _priority = 'normal';
    });
    Navigator.of(context).pop(); // Close the dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent!')),
    );
  }

  void _showCreateNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Notification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('High Priority')),
                  ],
                  onChanged: (val) => setState(() => _priority = val ?? 'normal'),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _createNotification,
              child: const Text('Send Notification'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontFamily: 'MyFont')),
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 16),
          child: FloatingActionButton(
            onPressed: _showCreateNotificationDialog,
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
            heroTag: 'createNotificationFAB',
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search notifications...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          // Notification list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Notifications')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No notifications.'));
                }
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final message = (data['message'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery) || message.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No notifications found for your search.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    if (_deletedNotificationIds.contains(doc.id)) return SizedBox.shrink();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((data['adminName'] ?? '').isNotEmpty)
                              Text(
                                data['adminName'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepPurple),
                              ),
                            Text(
                              data['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['message'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              data['date'] != null
                                  ? (data['date'] as Timestamp).toDate().toString()
                                  : '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (data['priority'] == 'high')
                              const Icon(Icons.priority_high, color: Colors.red),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Notification'),
                                    content: const Text('Are you sure you want to delete this notification?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteNotificationForAdmin(doc.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Notification deleted for you.')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

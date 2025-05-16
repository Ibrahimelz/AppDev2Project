import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeNotifications extends StatefulWidget {
  final String userEmail;
  const EmployeeNotifications({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<EmployeeNotifications> createState() => _EmployeeNotificationsState();
}

class _EmployeeNotificationsState extends State<EmployeeNotifications> {
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
        .collection('Employees')
        .where('email', isEqualTo: user.email)
        .get();
    if (deletedDocs.docs.isEmpty) return;
    final userDoc = deletedDocs.docs.first.reference;
    final deletedNotifs = await userDoc.collection('deletedNotifications').get();
    setState(() {
      _deletedNotificationIds = deletedNotifs.docs.map((d) => d.id).toSet();
    });
  }

  Future<void> _deleteNotificationForUser(String notifId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final deletedDocs = await FirebaseFirestore.instance
        .collection('Employees')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontFamily: 'MyFont')),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
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
                        if (_deletedNotificationIds.contains(doc.id)) return false;
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
                                        await _deleteNotificationForUser(doc.id);
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
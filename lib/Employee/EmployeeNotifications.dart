import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeNotifications extends StatefulWidget {
  final String userEmail;
  const EmployeeNotifications({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<EmployeeNotifications> createState() => _EmployeeNotificationsState();
}

class _EmployeeNotificationsState extends State<EmployeeNotifications> {
  String _searchQuery = '';
  Set<String> _readNotificationIds = {};
  bool _loadingRead = true;

  @override
  void initState() {
    super.initState();
    _fetchReadNotifications();
  }

  Future<void> _fetchReadNotifications() async {
    final readDocs = await FirebaseFirestore.instance
        .collection('Notifications')
        .get();
    Set<String> readIds = {};
    for (var doc in readDocs.docs) {
      final readBy = await doc.reference.collection('readBy').doc(widget.userEmail).get();
      if (readBy.exists) {
        readIds.add(doc.id);
      }
    }
    setState(() {
      _readNotificationIds = readIds;
      _loadingRead = false;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    final readRef = FirebaseFirestore.instance
        .collection('Notifications')
        .doc(notificationId)
        .collection('readBy')
        .doc(widget.userEmail);
    await readRef.set({'read': true});
    setState(() {
      _readNotificationIds.add(notificationId);
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
            child: _loadingRead
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
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
                          final isRead = _readNotificationIds.contains(doc.id);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              onTap: () => _markAsRead(doc.id),
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
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                    ),
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
                              trailing: data['priority'] == 'high'
                                  ? const Icon(Icons.priority_high, color: Colors.red)
                                  : null,
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
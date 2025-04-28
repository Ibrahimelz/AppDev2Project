import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeNotifications extends StatefulWidget {
  const EmployeeNotifications({Key? key}) : super(key: key);

  @override
  State<EmployeeNotifications> createState() => _EmployeeNotificationsState();
}

class _EmployeeNotificationsState extends State<EmployeeNotifications> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontFamily: 'MyFont')),
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
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
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
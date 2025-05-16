import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrashNotifications extends StatefulWidget {
  const TrashNotifications({Key? key}) : super(key: key);

  @override
  State<TrashNotifications> createState() => _TrashNotificationsState();
}

class _TrashNotificationsState extends State<TrashNotifications> {
  List<Map<String, dynamic>> _trashedNotifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrashedNotifications();
  }

  Future<void> _fetchTrashedNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final deletedDocs = await FirebaseFirestore.instance
        .collection('Employees')
        .where('email', isEqualTo: user.email)
        .get();
    if (deletedDocs.docs.isEmpty) return;
    final userDoc = deletedDocs.docs.first.reference;
    final deletedNotifs = await userDoc.collection('deletedNotifications').get();
    final now = DateTime.now();
    List<Map<String, dynamic>> trash = [];
    for (var doc in deletedNotifs.docs) {
      final deletedAt = (doc['deletedAt'] as Timestamp?)?.toDate();
      if (deletedAt == null) continue;
      final diff = now.difference(deletedAt).inDays;
      if (diff > 20) {
        // Delete from trash and main notifications
        await userDoc.collection('deletedNotifications').doc(doc.id).delete();
        await FirebaseFirestore.instance.collection('Notifications').doc(doc.id).delete();
        continue;
      }
      // Fetch notification data
      final notifSnap = await FirebaseFirestore.instance.collection('Notifications').doc(doc.id).get();
      if (notifSnap.exists) {
        trash.add({
          'id': doc.id,
          ...?notifSnap.data(),
          'deletedAt': deletedAt,
        });
      }
    }
    setState(() {
      _trashedNotifications = trash;
      _loading = false;
    });
  }

  Future<void> _restoreNotification(String notifId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final deletedDocs = await FirebaseFirestore.instance
        .collection('Employees')
        .where('email', isEqualTo: user.email)
        .get();
    if (deletedDocs.docs.isEmpty) return;
    final userDoc = deletedDocs.docs.first.reference;
    await userDoc.collection('deletedNotifications').doc(notifId).delete();
    setState(() {
      _trashedNotifications.removeWhere((n) => n['id'] == notifId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trash', style: TextStyle(fontFamily: 'MyFont'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trashedNotifications.isEmpty
              ? const Center(child: Text('Trash is empty.'))
              : ListView.builder(
                  itemCount: _trashedNotifications.length,
                  itemBuilder: (context, index) {
                    final data = _trashedNotifications[index];
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
                            Text('Deleted at: ${data['deletedAt']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () => _restoreNotification(data['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 
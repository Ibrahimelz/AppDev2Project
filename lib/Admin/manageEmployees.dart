import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class manageEmployees extends StatefulWidget {
  const manageEmployees({super.key});

  @override
  State<manageEmployees> createState() => _manageEmployeesState();
}

class _manageEmployeesState extends State<manageEmployees> {
  final CollectionReference employees =
  FirebaseFirestore.instance.collection('Employees');

  Set<String> expandedDocs = {};

  void toggleCard(String docId) {
    setState(() {
      if (expandedDocs.contains(docId)) {
        expandedDocs.remove(docId);
      } else {
        expandedDocs.add(docId);
      }
    });
  }

  Future<void> deleteEmployee(String docId, String fullName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning', style: TextStyle(fontFamily: 'MyFont')),
        content: Text('Are you sure you want to fire $fullName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await employees.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Manage Employees', style: TextStyle(fontFamily: 'MyFont')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: employees.orderBy('employeeID').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching employees'));
          }

          final employeeDocs = snapshot.data!.docs;

          if (employeeDocs.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employeeDocs.length,
            itemBuilder: (context, index) {
              final doc = employeeDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              final isExpanded = expandedDocs.contains(docId);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: () => toggleCard(docId),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Always-visible fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${data['fname']} ${data['lname']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('ID: ${data['employeeID']}'),
                          ],
                        ),
                        if (isExpanded) const SizedBox(height: 12),
                        if (isExpanded)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: data['profilePicture'] != null
                                    ? NetworkImage(data['profilePicture'])
                                    : null,
                                child: data['profilePicture'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${data['email']}'),
                                    Text('Phone: ${data['phoneNumber']}'),
                                    Text('Address: ${data['address']}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteEmployee(
                                    docId, '${data['fname']} ${data['lname']}'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageClients extends StatefulWidget {
  const ManageClients({super.key});

  @override
  State<ManageClients> createState() => _ManageClientsState();
}

class _ManageClientsState extends State<ManageClients> {
  final CollectionReference clients = FirebaseFirestore.instance.collection('Clients');
  Set<String> expandedDocs = {};
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allClients = [];
  List<QueryDocumentSnapshot> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchClients() async {
    final snapshot = await clients.orderBy('createdAt', descending: true).get();
    setState(() {
      _allClients = snapshot.docs;
      _filteredClients = _allClients;
    });
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredClients = _allClients;
      });
    } else {
      setState(() {
        _filteredClients = _allClients.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final fname = data['fname'].toString().toLowerCase();
          final lname = data['lname'].toString().toLowerCase();
          return fname.contains(query) || lname.contains(query);
        }).toList();
      });
    }
  }

  void toggleCard(String docId) {
    setState(() {
      if (expandedDocs.contains(docId)) {
        expandedDocs.remove(docId);
      } else {
        expandedDocs.add(docId);
      }
    });
  }

  Future<void> deleteClient(String docId, String fullName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning', style: TextStyle(fontFamily: 'MyFont')),
        content: Text('Are you sure you want to delete $fullName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await clients.doc(docId).delete();
      _fetchClients();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client deleted')));
    }
  }

  void showEditClientDialog(String docId, Map<String, dynamic> data) {
    final fnameController = TextEditingController(text: data['fname']);
    final lnameController = TextEditingController(text: data['lname']);
    final ageController = TextEditingController(text: data['age'].toString());
    final descController = TextEditingController(text: data['description']);
    bool isMember = data['isMember'] ?? false;
    String gender = data['gender'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Client', style: TextStyle(fontFamily: 'MyFont')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: fnameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lnameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Gender: "),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: gender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                        Navigator.of(context).pop();
                        showEditClientDialog(docId, {
                          ...data,
                          'fname': fnameController.text,
                          'lname': lnameController.text,
                          'age': int.tryParse(ageController.text) ?? 0,
                          'description': descController.text,
                          'gender': value,
                          'isMember': isMember,
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Member: "),
                    Switch(
                      value: isMember,
                      onChanged: (value) {
                        setState(() {
                          isMember = value;
                        });
                        Navigator.of(context).pop();
                        showEditClientDialog(docId, {
                          ...data,
                          'fname': fnameController.text,
                          'lname': lnameController.text,
                          'age': int.tryParse(ageController.text) ?? 0,
                          'description': descController.text,
                          'gender': gender,
                          'isMember': value,
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await clients.doc(docId).update({
                  'fname': fnameController.text,
                  'lname': lnameController.text,
                  'age': int.tryParse(ageController.text) ?? 0,
                  'description': descController.text,
                  'gender': gender,
                  'isMember': isMember,
                });
                _fetchClients();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client updated')),
                );
              },
              child: const Text('Save'),
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
        title: const Text('Manage Clients', style: TextStyle(fontFamily: 'MyFont')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filteredClients.isEmpty
                ? const Center(child: Text('No clients found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredClients.length,
              itemBuilder: (context, index) {
                final doc = _filteredClients[index];
                final data = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final isExpanded = expandedDocs.contains(docId);

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    onTap: () => toggleCard(docId),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${data['fname']} ${data['lname']}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('Age: ${data['age']}'),
                            ],
                          ),
                          if (isExpanded) const SizedBox(height: 12),
                          if (isExpanded)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: data['profileImage'] != null
                                      ? NetworkImage(data['profileImage']) as ImageProvider
                                      : null,
                                  child: data['profileImage'] == null ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email: ${data['email']}'),
                                      Text('Gender: ${data['gender']}'),
                                      Text('Member: ${data['isMember'] ? 'Yes' : 'No'}'),
                                      if (data['description'] != null &&
                                          data['description'].toString().isNotEmpty)
                                        Text('Notes: ${data['description']}'),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => showEditClientDialog(docId, data),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () =>
                                          deleteClient(docId, '${data['fname']} ${data['lname']}'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

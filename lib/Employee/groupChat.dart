// import 'package:flutter/material.dart';
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:uuid/uuid.dart';
//
// class GroupChat extends StatefulWidget {
//   final String employeeID;
//   final String name;
//
//   const GroupChat({required this.employeeID, required this.name, Key? key}) : super(key: key);
//
//   @override
//   _GroupChatState createState() => _GroupChatState();
// }
//
// class _GroupChatState extends State<GroupChat> {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   late types.User _currentUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentUser = types.User(
//       id: widget.employeeID.toString(),
//       firstName: widget.name,
//     );
//   }
//
//   void _handleSendPressed(types.PartialText message) {
//     final messageId = const Uuid().v4();
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     final messageData = {
//       'id': messageId,
//       'text': message.text,
//       'createdAt': DateTime.now().millisecondsSinceEpoch,
//       'authorId': _currentUser.id,
//       'authorName': currentUser?.email ?? 'Unknown', // use email as name
//     };
//
//     _firestore.collection('groupChatMessages').doc(messageId).set(messageData);
//   }
//
//   Stream<List<types.Message>> _messageStream() {
//     return _firestore
//         .collection('groupChatMessages')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return types.TextMessage(
//           id: data['id'],
//           author: types.User(
//             id: data['authorId'],
//             firstName: data['authorName'], // this will now be their email
//           ),
//           createdAt: data['createdAt'],
//           text: data['text'],
//         );
//       }).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Group Chat'),
//       ),
//       body: StreamBuilder<List<types.Message>>(
//         stream: _messageStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return Chat(
//             messages: snapshot.data ?? [],
//             onSendPressed: _handleSendPressed,
//             user: _currentUser,
//             showUserAvatars: false, // optional but avoids duplicate avatar
//             showUserNames: true,    // 👈 this triggers display of names above messages
//             customMessageBuilder: (message, {required int messageWidth}) {
//               if (message is types.TextMessage) {
//                 final textMsg = message as types.TextMessage;
//
//                 return Column(
//                   crossAxisAlignment: message.author.id == _currentUser.id
//                       ? CrossAxisAlignment.end
//                       : CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 2.0),
//                       child: Text(
//                         message.author.firstName ?? 'Unknown',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: message.author.id == _currentUser.id
//                             ? Colors.blue.shade100
//                             : Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(textMsg.text),
//                     ),
//                   ],
//                 );
//               }
//               return const SizedBox();
//             },
//           );
//         },
//       ),
//     );
//   }
// }

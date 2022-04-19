import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';

class UsersListWidget extends StatelessWidget {
  const UsersListWidget({
    Key? key,
    this.searchController,
    required this.rawUsers,
    this.headerText = "",
  }) : super(key: key);

  final TextEditingController? searchController;
  final Future<QuerySnapshot<Map<String, dynamic>>> rawUsers;
  final String headerText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerText.isNotEmpty
          ? AppBar(
              backgroundColor: mobileBackgroundColor,
              elevation: 1,
              shadowColor: Colors.white30,
              title: Text(headerText),
            )
          : null,
      body: FutureBuilder(
        future: rawUsers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data! as dynamic;
          return ListView.builder(
            // shrinkWrap: true,
            itemCount: users.docs.length,
            itemBuilder: (context, index) {
              var user = users.docs[index];
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileScreen(uid: user['uid'])),
                ),
                child: ListTile(
                  leading:
                      CircleAvatar(backgroundImage: NetworkImage(user['photoUrl']), radius: 16),
                  title: Text(user['username']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

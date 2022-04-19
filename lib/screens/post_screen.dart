import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/post_card.dart';

class PostScreen extends StatelessWidget {
  final post;

  const PostScreen({Key? key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 1,
        shadowColor: Colors.white30,
        title: const Text("Post"),
        centerTitle: false,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('postId', isEqualTo: post['postId'])
              .snapshots(),
          builder: (context,  AsyncSnapshot<QuerySnapshot<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return PostCard(post: snapshot.data!.docs[0].data());
          }),
    );
  }
}

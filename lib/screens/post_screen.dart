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
      body: PostCard(snap: post),
    );
  }
}

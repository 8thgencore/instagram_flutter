import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/comments_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/global_variable.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/dialog_button.dart';
import 'package:instagram_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  final snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        ),
      ),
      child: Column(
        children: [
          HeaderSectionWidget(snap: snap),
          ImageWidget(snap: snap),
          BorderSectionWidget(snap: snap),
          DescriptionWidget(snap: snap),
        ],
      ),
    );
  }
}

class HeaderSectionWidget extends StatefulWidget {
  final snap;

  const HeaderSectionWidget({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<HeaderSectionWidget> createState() => _HeaderSectionWidgetState();
}

class _HeaderSectionWidgetState extends State<HeaderSectionWidget> {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16).copyWith(right: 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.snap['profImage']),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.snap['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          widget.snap['uid'].toString() == user.uid
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            DialogButton(
                              onTap: () async {
                                FirestoreMethods().deletePost(widget.snap['postId']);
                                Navigator.of(context).pop();
                              },
                              text: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                )
              : Container(height: 50),
        ],
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final snap;

  const ImageWidget({Key? key, required this.snap}) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return GestureDetector(
      onDoubleTap: () {
        FirestoreMethods().likePost(
          widget.snap['postId'].toString(),
          user.uid,
          widget.snap['likes'],
        );
        setState(() => isLikeAnimating = true);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: Image.network(widget.snap['postUrl'], fit: BoxFit.cover),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isLikeAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isLikeAnimating,
              child: const Icon(Icons.favorite, color: Colors.white, size: 100),
              duration: const Duration(milliseconds: 400),
              onEnd: () {
                setState(() => isLikeAnimating = false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionWidget extends StatefulWidget {
  final snap;

  const DescriptionWidget({Key? key, required this.snap}) : super(key: key);

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(context, err.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            child: Text(
              "${widget.snap['likes'].length} likes",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: primaryColor),
                children: [
                  TextSpan(
                    text: widget.snap['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " ${widget.snap['description']}"),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(postId: widget.snap['postId'].toString()),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "View all $commentLen comments",
                style: const TextStyle(fontSize: 14, color: secondaryColor),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
              style: const TextStyle(fontSize: 12, color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class BorderSectionWidget extends StatefulWidget {
  final snap;

  const BorderSectionWidget({Key? key, required this.snap}) : super(key: key);

  @override
  State<BorderSectionWidget> createState() => _BorderSectionWidgetState();
}

class _BorderSectionWidgetState extends State<BorderSectionWidget> {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Row(
      children: [
        LikeAnimation(
          isAnimating: widget.snap['likes'].contains(user.uid),
          smallLike: true,
          child: IconButton(
            icon: widget.snap['likes'].contains(user.uid)
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
            onPressed: () => FirestoreMethods().likePost(
              widget.snap['postId'],
              user.uid,
              widget.snap['likes'],
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CommentsScreen(postId: widget.snap['postId'].toString()),
          )),
          icon: const Icon(Icons.comment_outlined),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.send),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border),
            ),
          ),
        ),
      ],
    );
  }
}

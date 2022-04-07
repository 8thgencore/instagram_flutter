import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  final snap;

  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
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

class HeaderSectionWidget extends StatelessWidget {
  final snap;

  const HeaderSectionWidget({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(snap['profImage']),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snap['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shrinkWrap: true,
                    children: [
                      'Delete',
                    ]
                        .map(
                          (e) => InkWell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Text(e),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final snap;

  const ImageWidget({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onDoubleTap: () {
        FirestoreMethods().likePost(
          widget.snap['postId'].toString(),
          userProvider.getUser.uid,
          widget.snap['likes'],
        );
        setState(() => isLikeAnimating = true);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Image.network(
              widget.snap['postUrl'],
              fit: BoxFit.cover,
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isLikeAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isLikeAnimating,
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 100,
              ),
              duration: const Duration(
                milliseconds: 400,
              ),
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

class DescriptionWidget extends StatelessWidget {
  final snap;

  const DescriptionWidget({
    Key? key,
    required this.snap,
  }) : super(key: key);

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
              "${snap['likes'].length} likes",
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
                    text: snap['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: snap['description']),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "View all 200 comments",
                style: const TextStyle(fontSize: 16, color: secondaryColor),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormat.yMMMd().format(snap['datePublished'].toDate()),
              style: const TextStyle(fontSize: 16, color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class BorderSectionWidget extends StatelessWidget {
  final snap;

  const BorderSectionWidget({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Row(
      children: [
        LikeAnimation(
          isAnimating: snap['likes'].contains(userProvider.getUser.uid),
          smallLike: true,
          child: IconButton(
            icon: snap['likes'].contains(userProvider.getUser.uid)
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.favorite_border,
                  ),
            onPressed: () => FirestoreMethods().likePost(
              snap['postId'],
              userProvider.getUser.uid,
              snap['likes'],
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
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
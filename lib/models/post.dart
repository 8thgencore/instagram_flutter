import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String postId;
  final String description;
  final String username;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;
  final likes;

  Post({
    required this.uid,
    required this.username,
    required this.postId,
    required this.description,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      uid: snapshot["uid"],
      username: snapshot["username"],
      postId: snapshot["postId"],
      description: snapshot["description"],
      datePublished: snapshot["datePublished"],
      postUrl: snapshot["postUrl"],
      profImage: snapshot["profImage"],
      likes: snapshot["likes"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "postId": postId,
        "description": description,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profImage": profImage,
        "likes": likes,
      };
}

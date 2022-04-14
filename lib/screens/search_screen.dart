import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/global_variable.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 1,
        shadowColor: Colors.white30,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: "Search for a user",
          ),
          onFieldSubmitted: (String _) {
            setState(() => isShowUsers = true);
            print(_);
          },
        ),
      ),
      body: isShowUsers
          ? SearchUserWidget(searchController: searchController)
          : const ImageGridWidget(),
    );
  }
}

class ImageGridWidget extends StatelessWidget {
  const ImageGridWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('posts').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var posts = snapshot.data! as dynamic;
        return StaggeredGridView.countBuilder(
          crossAxisCount: 3,
          itemCount: posts.docs.length,
          itemBuilder: (context, index) => Image.network(
            posts.docs[index]['postUrl'],
            fit: BoxFit.cover,
          ),
          staggeredTileBuilder: (index) => MediaQuery.of(context).size.width > webScreenSize
              ? StaggeredTile.count((index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
              : StaggeredTile.count((index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        );
      },
    );
  }
}

class SearchUserWidget extends StatelessWidget {
  const SearchUserWidget({
    Key? key,
    required this.searchController,
  }) : super(key: key);

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: searchController.text)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data! as dynamic;
          return ListView.builder(
            // shrinkWrap: true,
            itemCount: users.docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                // onTap: () => Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => ProfileScreen(
                //       uid: (snapshot.data! as dynamic).docs[index]['uid'],
                //     ),
                //   ),
                // ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(users.docs[index]['photoUrl']),
                    radius: 16,
                  ),
                  title: Text(users.docs[index]['username']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

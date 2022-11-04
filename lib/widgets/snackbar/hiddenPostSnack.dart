import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/feedProvider.dart';
import '../../providers/myProfileProvider.dart';

class HiddenSnack extends StatelessWidget {
  final String postID;
  final dynamic previewSetstate;
  final void Function() helperUnhide;
  const HiddenSnack({
    required this.postID,
    required this.helperUnhide,
    required this.previewSetstate,
  });
  Future<void> unhide(String myUsername, void Function(String) unhide) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final targetPost = firestore
        .collection('Users')
        .doc(myUsername)
        .collection('HiddenPosts')
        .doc(postID);
    return targetPost.delete().then((value) {
      unhide(postID);
      previewSetstate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final MyProfile _nolistenMyProfile =
        Provider.of<MyProfile>(context, listen: false);
    final void Function(String) profileunhidePost =
        _nolistenMyProfile.unhidePost;
    final void Function(String) feedHideHandler =
        Provider.of<FeedProvider>(context, listen: false).hidePost;
    final String myUsername = _nolistenMyProfile.getUsername;
    void unhidePost(String postID) {
      profileunhidePost(postID);
      feedHideHandler(postID);
      helperUnhide();
    }

    const Widget _icon =
        const Icon(Icons.visibility_off, color: Colors.white, size: 31.0);
    const Widget _message = const Text('Post hidden',
        style: TextStyle(fontSize: 25.0, color: Colors.white));
    final Widget _snackBar = Container(
        height: 30.0,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _icon,
              const Spacer(flex: 1),
              _message,
              const Spacer(flex: 2),
              GestureDetector(
                  onTap: () {
                    unhide(myUsername, unhidePost);
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  },
                  child: Text('Undo',
                      style: TextStyle(
                          color: _accentColor,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold)))
            ]));
    return _snackBar;
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/feedProvider.dart';
import '../providers/myProfileProvider.dart';
import 'favSnack.dart';
import 'hiddenPostSnack.dart';
import 'blockSnack.dart';
import 'reportDialog.dart';
import 'deleteSnack.dart';
import 'removedSnack.dart';
import 'load.dart';

class MyPopUpMenuButton extends StatefulWidget {
  final String id;
  final String postID;
  final bool postedByMe;
  final bool isInProfile;
  final bool isBlocked;
  final bool isLinkedToMe;
  final List<String> postTopics;
  final List<String> postMedia;
  final DateTime postDate;
  final dynamic block;
  final dynamic unblock;
  final dynamic remove;
  final dynamic hidePost;
  final dynamic deletePost;
  final dynamic unhidePost;
  final dynamic previewSetstate;
  const MyPopUpMenuButton({
    required this.id,
    required this.postID,
    required this.postedByMe,
    required this.isInProfile,
    required this.postTopics,
    required this.postMedia,
    required this.postDate,
    required this.isBlocked,
    required this.isLinkedToMe,
    required this.block,
    required this.unblock,
    required this.remove,
    required this.hidePost,
    required this.deletePost,
    required this.unhidePost,
    required this.previewSetstate,
  });

  @override
  _MyPopUpMenuButtonState createState() => _MyPopUpMenuButtonState();
}

class _MyPopUpMenuButtonState extends State<MyPopUpMenuButton> {
  bool linkRemoved = false;
  bool isBlocked = false;
  bool isUnBlocked = false;
  bool isDeleted = false;
  void _showIt(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Load());
        });
  }

  Future<void>? blockUser(
      BuildContext context,
      String myUsername,
      void Function(String) block,
      void Function() profileBlock,
      bool isNotBlocked) {
    if (!isBlocked) {
      setState(() {
        isBlocked = true;
      });
      if (isNotBlocked) {
        _showIt(context);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        var batch = firestore.batch();
        final myBlockedCollection =
            firestore.collection('Users').doc(myUsername).collection('Blocked');
        batch.set(myBlockedCollection.doc(widget.id), {'0': '1'});
        batch.update(firestore.collection('Users').doc(myUsername),
            {'numOfBlocked': FieldValue.increment(1)});
        return batch.commit().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(
                seconds: 2,
              ),
              backgroundColor: Colors.amber,
              content: const BlockSnack('User blocked'),
            ),
          );
          Future.delayed(const Duration(milliseconds: 10), () {
            profileBlock();
            block(widget.id);
          });
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {}
    }
  }

  Future<void>? unblockUser(
      BuildContext context,
      String myUsername,
      void Function(String) unblock,
      void Function() profileunBlock,
      bool isMyBlocked) {
    if (!isUnBlocked) {
      setState(() {
        isUnBlocked = true;
      });
      if (isMyBlocked) {
        _showIt(context);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        var batch = firestore.batch();
        final myBlockedCollection =
            firestore.collection('Users').doc(myUsername).collection('Blocked');
        batch.delete(myBlockedCollection.doc(widget.id));
        batch.update(firestore.collection('Users').doc(myUsername),
            {'numOfBlocked': FieldValue.increment(-1)});
        return batch.commit().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(
                seconds: 2,
              ),
              backgroundColor: Colors.amber,
              content: const BlockSnack('User unblocked'),
            ),
          );
          Future.delayed(const Duration(milliseconds: 10), () {
            profileunBlock();
            unblock(widget.id);
          });
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {}
    }
  }

  Future<void>? removeUser(
    BuildContext context,
    String myUsername,
    void Function() remove,
    void Function() subtractTheir,
  ) {
    if (!linkRemoved) {
      setState(() {
        linkRemoved = true;
      });
      if (widget.isLinkedToMe) {
        _showIt(context);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        var batch = firestore.batch();
        final myLinksCollection =
            firestore.collection('Users').doc(myUsername).collection('Links');
        final theirLinkedCollection =
            firestore.collection('Users').doc(widget.id).collection('Linked');
        batch.delete(myLinksCollection.doc(widget.id));
        batch.update(firestore.collection('Users').doc(myUsername),
            {'numOfLinks': FieldValue.increment(-1)});
        batch.delete(theirLinkedCollection.doc(myUsername));
        batch.update(firestore.collection('Users').doc(widget.id),
            {'numOfLinked': FieldValue.increment(-1)});
        return batch.commit().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(
                seconds: 2,
              ),
              backgroundColor: Colors.red,
              content: const RemovedSnack(),
            ),
          );
          Future.delayed(const Duration(milliseconds: 10), () {
            remove();
            subtractTheir();
          });
          Navigator.pop(context);
          Navigator.pop(context);
        }).catchError((_) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyProfile _listenMyProfile = Provider.of<MyProfile>(context);
    final List<String> _likedPosts = _listenMyProfile.getLikedPostIDs;
    final bool uppedByMe = _likedPosts.contains(widget.postID);
    final String myUsername = _listenMyProfile.getUsername;
    final MyProfile _nolistenMyProfile =
        Provider.of<MyProfile>(context, listen: false);
    bool isFav = _listenMyProfile.getfavPostIDs.contains(widget.id);
    bool isHidden = _listenMyProfile.getHiddenPostIDs.contains(widget.id);
    final void Function(String) __block = _nolistenMyProfile.blockUser;
    final void Function(String) __unblock = _nolistenMyProfile.unblockUser;
    final void Function(String) _favPost = _nolistenMyProfile.favPost;
    final void Function(String) _unfavPost = _nolistenMyProfile.removeFavPost;
    final void Function(String) profilehidePost = _nolistenMyProfile.hidePost;
    final void Function(String) feedHide =
        Provider.of<FeedProvider>(context, listen: false).hidePost;
    final void Function(String) profileDelete = _nolistenMyProfile.deletePost;
    final void Function(String) feedDelete =
        Provider.of<FeedProvider>(context, listen: false).deletePost;
    final bool isMyBlocked =
        Provider.of<MyProfile>(context).getBlockedIDs.contains(widget.id);
    final bool exists = _listenMyProfile.getPostIDs.contains(widget.id);
    Future<void> favPost(String myUsername, void Function(String) favPost,
        void Function(String) unfavPost) {
      Navigator.pop(context);
      Future.delayed(
          const Duration(milliseconds: 300), () => favPost(widget.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(
            seconds: 2,
          ),
          backgroundColor: Colors.indigo.shade900,
          content: const FavSnack(true),
        ),
      );
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final targetPost = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('FavPosts')
          .doc(widget.postID);
      return targetPost.set({'date': widget.postDate}).catchError((_) {
        unfavPost(widget.id);
      });
    }

    Future<void> unfavPost(
      String myUsername,
      void Function(String) unfavPost,
      void Function(String) favPost,
    ) {
      Navigator.pop(context);
      Future.delayed(
          const Duration(milliseconds: 300), () => unfavPost(widget.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(
            seconds: 2,
          ),
          backgroundColor: Colors.indigo.shade900,
          content: const FavSnack(false),
        ),
      );
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final targetPost = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('FavPosts')
          .doc(widget.postID);
      return targetPost.delete().catchError((_) {
        unfavPost(widget.id);
      });
    }

    Future<void> hide(String myUsername, void Function(String) hide) {
      Navigator.pop(context);
      hide(widget.postID);
      widget.hidePost();
      widget.previewSetstate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(
            seconds: 5,
          ),
          backgroundColor: Colors.grey.shade800,
          content: HiddenSnack(
            postID: widget.id,
            helperUnhide: widget.unhidePost,
            previewSetstate: widget.previewSetstate,
          ),
        ),
      );
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final targetPost = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('HiddenPosts')
          .doc(widget.postID);
      return targetPost.set({});
    }

    Future<void>? deletePost(
        String myUsername, void Function(String) delete) async {
      if (!isDeleted) {
        setState(() {
          isDeleted = true;
        });
        Navigator.pop(context);
        Future.delayed(
            const Duration(milliseconds: 10), () => delete(widget.postID));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(
              seconds: 2,
            ),
            backgroundColor: Colors.red,
            content: const DeleteSnack(),
          ),
        );
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final storage = FirebaseStorage.instance;

        Reference getMediaRef(String url) {
          return storage.refFromURL(url);
        }

        List<Reference> getRefs(List<String> urls) {
          return urls.map((url) => getMediaRef(url)).toList();
        }

        var batch = firestore.batch();
        Future<void> deleteTopic(String topic) async {
          final topicDoc = firestore.collection('Topics').doc(topic);
          final targetPostDoc = topicDoc.collection('posts').doc(widget.postID);
          batch.delete(targetPostDoc);
          batch.update(topicDoc, {'count': FieldValue.increment(-1)});
        }

        Future<void> deleteTopicPost(List<String> topics) async {
          for (var topic in topics) {
            await deleteTopic(topic);
          }
        }

        final targetPost = firestore.collection('Posts').doc(widget.postID);
        final targetMyPosts = firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Posts')
            .doc(widget.postID);
        batch.delete(targetPost);
        batch.delete(targetMyPosts);
        batch.update(firestore.collection('Users').doc(myUsername),
            {'numOfPosts': FieldValue.increment(-1)});
        if (widget.postMedia.isNotEmpty) {
          _showIt(context);
          final references = getRefs(widget.postMedia);
          await deleteTopicPost(widget.postTopics);
          return batch.commit().then((value) {
            references.forEach((reference) => reference.delete());
            Navigator.pop(context);
            Navigator.pop(context);
          }).catchError((_) {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        } else {
          _showIt(context);
          await deleteTopicPost(widget.postTopics);
          return batch.commit().then((value) {
            Navigator.pop(context);
            Navigator.pop(context);
          }).catchError((_) {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }
      }
    }

    void deleteIT(String postID) {
      profileDelete(postID);
      feedDelete(postID);
      widget.deletePost();
      widget.previewSetstate();
    }

    void hidePost(String id) {
      profilehidePost(id);
      feedHide(id);
    }

    final Widget _report = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return ReportDialog(
                id: widget.id,
                postID: widget.postID,
                isInProfile: widget.isInProfile,
                isInPost: (widget.isInProfile) ? false : true,
                isInComment: false,
                isInReply: false,
                commentID: '',
              );
            },
          );
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          leading: Icon(
            Icons.flag,
            color: Colors.red.shade700,
          ),
          title: const Text(
            'Report',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _hide = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          hide(myUsername, hidePost);
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          leading: Icon(
            Icons.visibility_off_outlined,
            color: Colors.black,
          ),
          title: const Text(
            'Hide',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _block = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          blockUser(context, myUsername, __block, widget.block, !isMyBlocked);
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          leading: const Icon(
            customIcons.MyFlutterApp.no_stopping,
            color: Colors.amber,
          ),
          title: const Text(
            'Block',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _unblock = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          unblockUser(
              context, myUsername, __unblock, widget.unblock, isMyBlocked);
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          leading: const Icon(
            customIcons.MyFlutterApp.no_stopping,
            color: Colors.amber,
          ),
          title: const Text(
            'unblock',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _removeLink = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          removeUser(context, myUsername, _nolistenMyProfile.subtractMyLinks,
              widget.remove);
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          leading: const Icon(Icons.remove, color: Colors.red),
          title: const Text(
            'Remove',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _delete = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 150.0,
                    maxWidth: 150.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Delete post',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                            fontFamily: 'Roboto',
                            fontSize: 21.0,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(
                          thickness: 1.0,
                          indent: 0.0,
                          endIndent: 0.0,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () {
                                deletePost(myUsername, deleteIT);
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'No',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text(
            'Delete',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _favorite = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          favPost(myUsername, _favPost, _unfavPost);
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          enabled: false,
          leading: const Icon(
            Icons.star_border,
            color: Colors.yellow,
          ),
          title: const Text(
            'Favorite',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Widget _removeFavorite = Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          unfavPost(myUsername, _unfavPost, _favPost);
        },
        child: ListTile(
          horizontalTitleGap: 5.0,
          enabled: false,
          leading: const Icon(
            Icons.star,
            color: Colors.yellow,
          ),
          title: const Text(
            'Remove',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
    final Column _menu = Column(
      key: UniqueKey(),
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!widget.isInProfile && !isFav && !isHidden) _favorite,
        if (!widget.isInProfile && isFav) _removeFavorite,
        if (!widget.postedByMe &&
            !widget.isInProfile &&
            !isHidden &&
            !uppedByMe &&
            !isFav)
          _hide,
        if (widget.isInProfile && widget.isLinkedToMe) _removeLink,
        if (widget.isInProfile && !widget.isBlocked) _block,
        if (widget.isInProfile && widget.isBlocked) _unblock,
        if (exists) _delete,
        if (!widget.postedByMe && !isFav && !uppedByMe ||
            (widget.isInProfile && !widget.isBlocked))
          _report,
      ],
    );
    return _menu;
  }
}

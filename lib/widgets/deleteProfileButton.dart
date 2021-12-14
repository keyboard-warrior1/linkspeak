import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../providers/myProfileProvider.dart';
import '../providers/appBarProvider.dart';
import '../providers/addPostScreenState.dart';
import '../widgets/load.dart';
import '../routes.dart';

class DeleteProfileButton extends StatefulWidget {
  final bool isLoading;
  final void Function() loadIt;
  const DeleteProfileButton(this.isLoading, this.loadIt);

  @override
  State<DeleteProfileButton> createState() => _DeleteProfileButtonState();
}

class _DeleteProfileButtonState extends State<DeleteProfileButton> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  Future<void>? deletePost(
      String postID, WriteBatch batch, String myUsername) async {
    final thePost = await firestore.collection('Posts').doc(postID).get();
    if (thePost.exists) {
      final media = thePost.get('imgUrls') as List;
      final List<String> mediaList = media.map((e) => e as String).toList();
      final topics = thePost.get('topics') as List;
      final List<String> topicList = topics.map((e) => e as String).toList();
      Reference getMediaRef(String url) {
        return storage.refFromURL(url);
      }

      List<Reference> getRefs(List<String> urls) {
        return urls.map((url) => getMediaRef(url)).toList();
      }

      Future<void> deleteTopic(String topic) async {
        final topicDoc = firestore.collection('Topics').doc(topic);
        final targetPostDoc = topicDoc.collection('posts').doc(postID);
        batch.delete(targetPostDoc);
        batch.update(topicDoc, {'count': FieldValue.increment(-1)});
      }

      Future<void> deleteTopicPost(List<String> topics) async {
        for (var topic in topics) {
          await deleteTopic(topic);
        }
      }

      final targetPost = firestore.collection('Posts').doc(postID);

      if (mediaList.isNotEmpty) {
        final references = getRefs(mediaList);
        await deleteTopicPost(topicList);
        references.forEach((reference) => reference.delete());
        batch.delete(targetPost);
        batch.delete(firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Posts')
            .doc(postID));
      } else {
        await deleteTopicPost(topicList);
        batch.delete(targetPost);
        batch.delete(firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Posts')
            .doc(postID));
      }
    } else {
      batch.delete(firestore
          .collection('Users')
          .doc(myUsername)
          .collection('Posts')
          .doc(postID));
    }
  }

  Future<void>? removeUser(String myUsername, String userID, WriteBatch batch) {
    final theirLinkedCollection =
        firestore.collection('Users').doc(userID).collection('Linked');
    batch.delete(theirLinkedCollection.doc(myUsername));
    batch.update(firestore.collection('Users').doc(userID),
        {'numOfLinked': FieldValue.increment(-1)});
    batch.delete(firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Links')
        .doc(userID));
  }

  Future<void> unlink(
      String userID, String myUsername, WriteBatch batch) async {
    final userLinks =
        firestore.collection('Users').doc(userID).collection('Links');
    batch.delete(userLinks.doc(myUsername));
    batch.update(firestore.collection('Users').doc(userID),
        {'numOfLinks': FieldValue.increment(-1)});
    batch.delete(firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Linked')
        .doc(userID));
  }

  @override
  Widget build(BuildContext context) {
    final _myUsername = Provider.of<MyProfile>(context).getUsername;
    final profileImgUrl = Provider.of<MyProfile>(context).getProfileImage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () {
              if (widget.isLoading) {
              } else {
                showDialog(
                  context: context,
                  builder: (_) {
                    void _showIt() {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.transparent,
                          builder: (_) {
                            return Load();
                          });
                    }

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
                                'Delete my profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Roboto',
                                  fontSize: 17.0,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                    style: ButtonStyle(
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () async {
                                      widget.loadIt();
                                      _showIt();
                                      final myprofile = firestore
                                          .collection('Users')
                                          .doc('$_myUsername');
                                      final getit = await myprofile.get();
                                      final email = getit.get('Email');
                                      final getpostIDs = await myprofile
                                          .collection('Posts')
                                          .get();
                                      final postIDdocs = getpostIDs.docs;
                                      final List<String> postIDs = postIDdocs
                                          .map((post) => post.id)
                                          .toList();
                                      final getLinksIDs = await myprofile
                                          .collection('Linked')
                                          .get();
                                      final linkIDdocs = getLinksIDs.docs;
                                      final List<String> linkIDs =
                                          linkIDdocs.map((e) => e.id).toList();
                                      final getLinkedIDs = await myprofile
                                          .collection('Links')
                                          .get();
                                      final linkedIDdocs = getLinkedIDs.docs;
                                      final List<String> linkedIDs =
                                          linkedIDdocs
                                              .map((e) => e.id)
                                              .toList();
                                      final getChats = await myprofile
                                          .collection('chats')
                                          .get();
                                      final chatDocs = getChats.docs;
                                      final getBlocked = await myprofile
                                          .collection('Blocked')
                                          .get();
                                      final blockedDocs = getBlocked.docs;
                                      final getFavPosts = await myprofile
                                          .collection('FavPosts')
                                          .get();
                                      final favDocs = getFavPosts.docs;
                                      final getLikedPosts = await myprofile
                                          .collection('LikedPosts')
                                          .get();
                                      final likedDocs = getLikedPosts.docs;
                                      final getHiddenPosts = await myprofile
                                          .collection('HiddenPosts')
                                          .get();
                                      final hiddenDocs = getHiddenPosts.docs;
                                      final linksNotifs = await myprofile
                                          .collection('NewLinksNotifs')
                                          .get();
                                      final linksDocs = linksNotifs.docs;
                                      final likesNotifs = await myprofile
                                          .collection('PostLikesNotifs')
                                          .get();
                                      final likesDocs = likesNotifs.docs;

                                      final requests = await myprofile
                                          .collection('LinkRequestsNotifs')
                                          .get();
                                      final requestDocs = requests.docs;
                                      final linkedN = await myprofile
                                          .collection('NewLinkedNotifs')
                                          .get();
                                      final linkedNDocs = linkedN.docs;
                                      final commentsN = await myprofile
                                          .collection('PostCommentsNotifs')
                                          .get();
                                      final commentsNDocs = commentsN.docs;
                                      final myEmail = firestore
                                          .collection('Emails')
                                          .doc(email);
                                      var user = auth.currentUser;
                                      if (profileImgUrl != 'none') {
                                        FirebaseStorage.instance
                                            .refFromURL(profileImgUrl)
                                            .delete()
                                            .then((value) async {
                                          var batch = firestore.batch();
                                          if (blockedDocs.isNotEmpty) {
                                            for (var doc in blockedDocs) {
                                              batch.delete(myprofile
                                                  .collection('Blocked')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (favDocs.isNotEmpty) {
                                            for (var doc in favDocs) {
                                              batch.delete(myprofile
                                                  .collection('FavPosts')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (likedDocs.isNotEmpty) {
                                            for (var doc in likedDocs) {
                                              batch.delete(myprofile
                                                  .collection('LikedPosts')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (hiddenDocs.isNotEmpty) {
                                            for (var doc in hiddenDocs) {
                                              batch.delete(myprofile
                                                  .collection('HiddenPosts')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (linksDocs.isNotEmpty) {
                                            for (var doc in linksDocs) {
                                              batch.delete(myprofile
                                                  .collection('NewLinksNotifs')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (likesDocs.isNotEmpty) {
                                            for (var doc in likesDocs) {
                                              batch.delete(myprofile
                                                  .collection('PostLikesNotifs')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (requestDocs.isNotEmpty) {
                                            for (var doc in requestDocs) {
                                              batch.delete(myprofile
                                                  .collection(
                                                      'LinkRequestsNotifs')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (linkedNDocs.isNotEmpty) {
                                            for (var doc in linkedNDocs) {
                                              batch.delete(myprofile
                                                  .collection('NewLinkedNotifs')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (commentsNDocs.isNotEmpty) {
                                            for (var doc in commentsNDocs) {
                                              batch.delete(myprofile
                                                  .collection(
                                                      'PostCommentsNotifs')
                                                  .doc(doc.id));
                                            }
                                          }
                                          if (postIDdocs.isNotEmpty) {
                                            for (var id in postIDs) {
                                              await deletePost(
                                                id,
                                                batch,
                                                _myUsername,
                                              );
                                            }
                                          }
                                          if (linkIDdocs.isNotEmpty) {
                                            for (var id in linkIDs) {
                                              await unlink(
                                                  id, _myUsername, batch);
                                            }
                                          }
                                          if (linkedIDdocs.isNotEmpty) {
                                            for (var id in linkedIDs) {
                                              await removeUser(
                                                  _myUsername, id, batch);
                                            }
                                          }
                                          if (chatDocs.isNotEmpty) {
                                            for (var doc in chatDocs) {
                                              batch.delete(myprofile
                                                  .collection('chats')
                                                  .doc(doc.id));
                                            }
                                          }
                                          batch.delete(myEmail);
                                          batch.delete(myprofile);
                                          batch.commit().then((value) async {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            final myBool =
                                                prefs.getBool('KeepLogged') ??
                                                    false;
                                            final myGmail =
                                                prefs.getString('GMAIL') ?? '';
                                            final myFb =
                                                prefs.getString('FB') ?? '';
                                            if (myBool) {
                                              prefs
                                                  .setBool('KeepLogged', false)
                                                  .then((value) {});
                                            }
                                            if (myGmail != '') {
                                              prefs
                                                  .remove('GMAIL')
                                                  .then((value) {
                                                GoogleSignIn()
                                                    .signIn()
                                                    .then((value) {
                                                  user!.delete().then((value) {
                                                    GoogleSignIn()
                                                        .signOut()
                                                        .then((value) {
                                                      FirebaseAuth.instance
                                                          .signInAnonymously()
                                                          .then((value) {
                                                        firestore
                                                            .collection('Users')
                                                            .doc('$_myUsername')
                                                            .delete()
                                                            .then((value) {
                                                          Provider.of<MyProfile>(
                                                                  context,
                                                                  listen: false)
                                                              .resetProfile();
                                                          Provider.of<AppBarProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .reset();
                                                          Provider.of<NewPostHelper>(
                                                                  context,
                                                                  listen: false)
                                                              .clear();
                                                          EasyLoading.dismiss();
                                                          Navigator.popUntil(
                                                            context,
                                                            (route) =>
                                                                route.isFirst,
                                                          );
                                                          Navigator
                                                              .pushReplacementNamed(
                                                            context,
                                                            RouteGenerator
                                                                .splashScreen,
                                                          );
                                                        });
                                                      });
                                                    });
                                                  });
                                                });
                                              });
                                            } else if (myFb != '') {
                                              prefs.remove('FB').then((value) {
                                                FacebookAuth.instance
                                                    .login()
                                                    .then((value) {
                                                  user!.delete().then((value) {
                                                    FacebookAuth.instance
                                                        .logOut()
                                                        .then((value) {
                                                      FirebaseAuth.instance
                                                          .signInAnonymously()
                                                          .then((value) {
                                                        firestore
                                                            .collection('Users')
                                                            .doc('$_myUsername')
                                                            .delete()
                                                            .then((_) {
                                                          Provider.of<MyProfile>(
                                                                  context,
                                                                  listen: false)
                                                              .resetProfile();
                                                          Provider.of<AppBarProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .reset();
                                                          Provider.of<NewPostHelper>(
                                                                  context,
                                                                  listen: false)
                                                              .clear();
                                                          EasyLoading.dismiss();
                                                          Navigator.popUntil(
                                                            context,
                                                            (route) =>
                                                                route.isFirst,
                                                          );
                                                          Navigator
                                                              .pushReplacementNamed(
                                                            context,
                                                            RouteGenerator
                                                                .splashScreen,
                                                          );
                                                        });
                                                      });
                                                    });
                                                  });
                                                });
                                              });
                                            } else {
                                              user!.delete().then((value) {
                                                Provider.of<MyProfile>(context,
                                                        listen: false)
                                                    .resetProfile();
                                                Provider.of<AppBarProvider>(
                                                        context,
                                                        listen: false)
                                                    .reset();
                                                Provider.of<NewPostHelper>(
                                                        context,
                                                        listen: false)
                                                    .clear();

                                                Navigator.popUntil(
                                                  context,
                                                  (route) => route.isFirst,
                                                );
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  RouteGenerator.splashScreen,
                                                );
                                              });
                                            }
                                          });
                                        });
                                      } else {
                                        var batch = firestore.batch();
                                        if (blockedDocs.isNotEmpty) {
                                          for (var doc in blockedDocs) {
                                            batch.delete(myprofile
                                                .collection('Blocked')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (favDocs.isNotEmpty) {
                                          for (var doc in favDocs) {
                                            batch.delete(myprofile
                                                .collection('FavPosts')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (likedDocs.isNotEmpty) {
                                          for (var doc in likedDocs) {
                                            batch.delete(myprofile
                                                .collection('LikedPosts')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (hiddenDocs.isNotEmpty) {
                                          for (var doc in hiddenDocs) {
                                            batch.delete(myprofile
                                                .collection('HiddenPosts')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (linksDocs.isNotEmpty) {
                                          for (var doc in linksDocs) {
                                            batch.delete(myprofile
                                                .collection('NewLinksNotifs')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (likesDocs.isNotEmpty) {
                                          for (var doc in likesDocs) {
                                            batch.delete(myprofile
                                                .collection('PostLikesNotifs')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (requestDocs.isNotEmpty) {
                                          for (var doc in requestDocs) {
                                            batch.delete(myprofile
                                                .collection(
                                                    'LinkRequestsNotifs')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (linkedNDocs.isNotEmpty) {
                                          for (var doc in linkedNDocs) {
                                            batch.delete(myprofile
                                                .collection('NewLinkedNotifs')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (commentsNDocs.isNotEmpty) {
                                          for (var doc in commentsNDocs) {
                                            batch.delete(myprofile
                                                .collection(
                                                    'PostCommentsNotifs')
                                                .doc(doc.id));
                                          }
                                        }
                                        if (postIDdocs.isNotEmpty) {
                                          for (var id in postIDs) {
                                            await deletePost(
                                                id, batch, _myUsername);
                                          }
                                        }
                                        if (linkIDdocs.isNotEmpty) {
                                          for (var id in linkIDs) {
                                            await unlink(
                                                id, _myUsername, batch);
                                          }
                                        }
                                        if (linkedIDdocs.isNotEmpty) {
                                          for (var id in linkedIDs) {
                                            await removeUser(
                                                _myUsername, id, batch);
                                          }
                                        }
                                        if (chatDocs.isNotEmpty) {
                                          for (var doc in chatDocs) {
                                            final getMessages = await myprofile
                                                .collection('chats')
                                                .doc(doc.id)
                                                .collection('messages')
                                                .get();
                                            final messagesDocs =
                                                getMessages.docs;
                                            for (var message in messagesDocs) {
                                              batch.delete(myprofile
                                                  .collection('chats')
                                                  .doc(doc.id)
                                                  .collection('messages')
                                                  .doc(message.id));
                                            }
                                            batch.delete(myprofile
                                                .collection('chats')
                                                .doc(doc.id));
                                          }
                                        }
                                        batch.delete(myEmail);
                                        batch.delete(myprofile);
                                        batch.commit().then((value) async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          final myGmail =
                                              prefs.getString('GMAIL') ?? '';
                                          final myFb =
                                              prefs.getString('FB') ?? '';
                                          if (myGmail != '') {
                                            prefs.remove('GMAIL').then((value) {
                                              GoogleSignIn()
                                                  .signIn()
                                                  .then((value) {
                                                user!.delete().then((value) {
                                                  GoogleSignIn()
                                                      .signOut()
                                                      .then((value) {
                                                    FirebaseAuth.instance
                                                        .signInAnonymously()
                                                        .then((value) {
                                                      firestore
                                                          .collection('Users')
                                                          .doc('$_myUsername')
                                                          .delete()
                                                          .then((_) {
                                                        Provider.of<MyProfile>(
                                                                context,
                                                                listen: false)
                                                            .resetProfile();
                                                        Provider.of<AppBarProvider>(
                                                                context,
                                                                listen: false)
                                                            .reset();
                                                        Provider.of<NewPostHelper>(
                                                                context,
                                                                listen: false)
                                                            .clear();
                                                        EasyLoading.dismiss();
                                                        Navigator.popUntil(
                                                          context,
                                                          (route) =>
                                                              route.isFirst,
                                                        );
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          RouteGenerator
                                                              .splashScreen,
                                                        );
                                                      });
                                                    });
                                                  });
                                                });
                                              });
                                            });
                                          } else if (myFb != '') {
                                            prefs.remove('FB').then((value) {
                                              FacebookAuth.instance
                                                  .login()
                                                  .then((value) {
                                                user!.delete().then((value) {
                                                  FacebookAuth.instance
                                                      .logOut()
                                                      .then((value) {
                                                    FirebaseAuth.instance
                                                        .signInAnonymously()
                                                        .then((value) {
                                                      firestore
                                                          .collection('Users')
                                                          .doc('$_myUsername')
                                                          .delete()
                                                          .then((_) {
                                                        Provider.of<MyProfile>(
                                                                context,
                                                                listen: false)
                                                            .resetProfile();
                                                        Provider.of<AppBarProvider>(
                                                                context,
                                                                listen: false)
                                                            .reset();
                                                        Provider.of<NewPostHelper>(
                                                                context,
                                                                listen: false)
                                                            .clear();
                                                        EasyLoading.dismiss();
                                                        Navigator.popUntil(
                                                          context,
                                                          (route) =>
                                                              route.isFirst,
                                                        );
                                                        Navigator
                                                            .pushReplacementNamed(
                                                          context,
                                                          RouteGenerator
                                                              .splashScreen,
                                                        );
                                                      });
                                                    });
                                                  });
                                                });
                                              });
                                            });
                                          } else {
                                            user!.delete().then((value) async {
                                              final myBool =
                                                  prefs.getBool('KeepLogged') ??
                                                      false;
                                              if (myBool) {
                                                prefs
                                                    .setBool(
                                                        'KeepLogged', false)
                                                    .then((value) {});
                                              }
                                              Provider.of<MyProfile>(context,
                                                      listen: false)
                                                  .resetProfile();
                                              Provider.of<AppBarProvider>(
                                                      context,
                                                      listen: false)
                                                  .reset();
                                              Provider.of<NewPostHelper>(
                                                      context,
                                                      listen: false)
                                                  .clear();

                                              Navigator.popUntil(
                                                context,
                                                (route) => route.isFirst,
                                              );
                                              Navigator.pushReplacementNamed(
                                                context,
                                                RouteGenerator.splashScreen,
                                              );
                                            });
                                          }
                                        });
                                      }
                                    },
                                    child: Text(
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
                                    child: Text(
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
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(Colors.red),
            ),
            child: const Center(
              child: const Text(
                'Delete profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

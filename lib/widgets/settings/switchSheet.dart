import 'package:auth_buttons/auth_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general.dart';
import '../../models/miniSavedProfile.dart';
import '../../providers/addPostScreenState.dart';
import '../../providers/appBarProvider.dart';
import '../../providers/feedProvider.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../auth/loginAuth.dart';
import '../common/chatprofileImage.dart';
import '../common/load.dart';
import '../common/settingsBar.dart';

enum View { Switch, SignIn }

class SwitchSheet extends StatefulWidget {
  const SwitchSheet();

  @override
  _SwitchSheetState createState() => _SwitchSheetState();
}

class _SwitchSheetState extends State<SwitchSheet> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  List<MiniProfileSaved> savedUsers = [];
  View viewMode = View.Switch;
  late Future<void> _getSavedUsers;
  Widget giveAddTile(dynamic handler) {
    final lang = General.language(context);
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
            onTap: handler,
            horizontalTitleGap: 2.0,
            leading: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                    color: Colors.grey, shape: BoxShape.circle),
                child: const Icon(Icons.add, size: 18.0, color: Colors.white)),
            title: Text(lang.widgets_profile25,
                style: const TextStyle(color: Colors.black, fontSize: 17.0))));
  }

  Widget giveUserTile(
      int index,
      String currentUsername,
      void Function(String) handler,
      Future<void> Function(String, String) switchUser) {
    final String username = savedUsers[index].username;
    final bool isCurrentUser = username == currentUsername;
    final bool isFB = savedUsers[index].isFbUser;
    final bool isGmail = savedUsers[index].isGmailUser;
    return Container(
        key: UniqueKey(),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
            horizontalTitleGap: 2.0,
            onTap: () {
              if (isCurrentUser) {
              } else {
                switchUser(currentUsername, username);
              }
            },
            leading: ChatProfileImage(
                username: username, factor: 0.04, inEdit: false, asset: null),
            title: Text('$username',
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17.0,
                    color: Colors.black)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              if (isCurrentUser)
                Icon(Icons.check_circle,
                    color: Colors.lightGreenAccent.shade400),
              if (!isCurrentUser && !isFB && !isGmail)
                IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () {
                      if (isCurrentUser || isFB || isGmail) {
                      } else {
                        handler(username);
                      }
                    }),
              if (isFB || isGmail) const SizedBox(width: 5.0),
              if (isFB)
                FacebookAuthButton(
                    style: AuthButtonStyle(
                        height: 25.0,
                        width: 25.0,
                        borderWidth: 0.0,
                        iconSize: 20.0,
                        elevation: 0.0,
                        borderColor: Colors.transparent,
                        iconBackground: Colors.white,
                        iconType: AuthIconType.secondary,
                        buttonType: AuthButtonType.icon),
                    onPressed: () {}),
              if (isGmail)
                GoogleAuthButton(
                    onPressed: () {},
                    style: AuthButtonStyle(
                        height: 25.0,
                        width: 25.0,
                        borderWidth: 0.0,
                        iconSize: 20.0,
                        elevation: 0.0,
                        borderColor: Colors.transparent,
                        iconBackground: Colors.transparent,
                        iconType: AuthIconType.secondary,
                        buttonType: AuthButtonType.icon))
            ])));
  }

  void changeView() {
    setState(() {
      if (viewMode == View.SignIn) viewMode = View.Switch;
      if (viewMode == View.Switch) viewMode = View.SignIn;
    });
  }

  void _showIt() {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) {
          return const Load();
        });
  }

  Future<void> getSavedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final myBool = prefs.getBool('KeepLogged') ?? false;
    final user2 = prefs.getStringList('User2') ?? [];
    final user3 = prefs.getStringList('User3') ?? [];
    final user4 = prefs.getStringList('User4') ?? [];
    final fbUser = prefs.getString('FB') ?? '';
    final gmailUser = prefs.getString('GMAIL') ?? '';
    if (myBool) {
      final savedUser = prefs.getString('username');
      final savedPass = prefs.getString('password');
      final getUser = await firestore.collection('Users').doc(savedUser).get();
      final userAvatar = getUser.get('Avatar');
      final MiniProfileSaved profile = MiniProfileSaved(
        username: savedUser!,
        password: savedPass!,
        imgUrl: userAvatar,
        isKeepLogged: true,
        isFbUser: false,
        isGmailUser: false,
      );
      if (!savedUsers.any((element) => element.username == savedUser))
        savedUsers.add(profile);
    }
    if (user2.isNotEmpty) {
      final savedUser = user2[0];
      final savedPass = user2[1];
      final getUser = await firestore.collection('Users').doc(savedUser).get();
      final userAvatar = getUser.get('Avatar');
      final MiniProfileSaved profile = MiniProfileSaved(
        username: savedUser,
        password: savedPass,
        imgUrl: userAvatar,
        isKeepLogged: false,
        isFbUser: false,
        isGmailUser: false,
      );
      if (!savedUsers.any((element) => element.username == savedUser))
        savedUsers.add(profile);
    }
    if (user3.isNotEmpty) {
      final savedUser = user3[0];
      final savedPass = user3[1];
      final getUser = await firestore.collection('Users').doc(savedUser).get();
      final userAvatar = getUser.get('Avatar');
      final MiniProfileSaved profile = MiniProfileSaved(
        username: savedUser,
        password: savedPass,
        imgUrl: userAvatar,
        isKeepLogged: false,
        isFbUser: false,
        isGmailUser: false,
      );
      if (!savedUsers.any((element) => element.username == savedUser))
        savedUsers.add(profile);
    }
    if (user4.isNotEmpty) {
      final savedUser = user4[0];
      final savedPass = user4[1];
      final getUser = await firestore.collection('Users').doc(savedUser).get();
      final userAvatar = getUser.get('Avatar');
      final MiniProfileSaved profile = MiniProfileSaved(
        username: savedUser,
        password: savedPass,
        imgUrl: userAvatar,
        isKeepLogged: false,
        isFbUser: false,
        isGmailUser: false,
      );
      if (!savedUsers.any((element) => element.username == savedUser))
        savedUsers.add(profile);
    }
    if (fbUser != '') {
      final email = fbUser;
      final getUsername = await firestore.collection('Emails').doc(email).get();
      final username = getUsername.get('username');
      final getUser = await firestore.collection('Users').doc(username).get();
      final userAvatar = getUser.get('Avatar');
      final MiniProfileSaved profile = MiniProfileSaved(
        username: username,
        password: '',
        imgUrl: userAvatar,
        isKeepLogged: false,
        isFbUser: true,
        isGmailUser: false,
      );
      if (!savedUsers.any((element) => element.username == username))
        savedUsers.add(profile);
    }
    if (gmailUser != '') {
      final email = gmailUser;
      final getUsername = await firestore.collection('Emails').doc(email).get();
      final username = getUsername.get('username');
      final getUser = await firestore.collection('Users').doc(username).get();
      final userAvatar = getUser.get('Avatar');
      final MiniProfileSaved profile = MiniProfileSaved(
        username: username,
        password: '',
        imgUrl: userAvatar,
        isKeepLogged: false,
        isFbUser: false,
        isGmailUser: true,
      );
      if (!savedUsers.any((element) => element.username == username))
        savedUsers.add(profile);
    }
  }

  Future<void> addUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final user2 = prefs.getStringList('User2') ?? [];
    final user3 = prefs.getStringList('User3') ?? [];
    final user4 = prefs.getStringList('User4') ?? [];
    if (user2.isEmpty) {
      return prefs.setStringList('User2', ['$username', '$password']).then(
          (value) async {
        final getUser = await firestore.collection('Users').doc(username).get();
        final imgUrl = getUser.get('Avatar');
        final mini = MiniProfileSaved(
          username: username,
          imgUrl: imgUrl,
          isKeepLogged: false,
          password: password,
          isFbUser: false,
          isGmailUser: false,
        );
        savedUsers.add(mini);
        viewMode = View.Switch;
        setState(() {});
      });
    }
    if (user3.isEmpty) {
      return prefs.setStringList('User3', ['$username', '$password']).then(
          (value) async {
        final getUser = await firestore.collection('Users').doc(username).get();
        final imgUrl = getUser.get('Avatar');
        final mini = MiniProfileSaved(
          username: username,
          imgUrl: imgUrl,
          isKeepLogged: false,
          password: password,
          isFbUser: false,
          isGmailUser: false,
        );
        savedUsers.add(mini);
        viewMode = View.Switch;
        setState(() {});
      });
    }
    if (user4.isEmpty) {
      return prefs.setStringList('User4', ['$username', '$password']).then(
          (value) async {
        final getUser = await firestore.collection('Users').doc(username).get();
        final imgUrl = getUser.get('Avatar');
        final mini = MiniProfileSaved(
          username: username,
          imgUrl: imgUrl,
          isKeepLogged: false,
          password: password,
          isFbUser: false,
          isGmailUser: false,
        );
        savedUsers.add(mini);
        viewMode = View.Switch;
        setState(() {});
      });
    }
  }

  Future<void> switchUser(String currentUsername, String targetUsername) async {
    _showIt();
    final prefs = await SharedPreferences.getInstance();
    final myBool = prefs.getBool('KeepLogged') ?? false;
    final user2 = prefs.getStringList('User2') ?? [];
    final user3 = prefs.getStringList('User3') ?? [];
    final user4 = prefs.getStringList('User4') ?? [];
    final fbUser = prefs.getString('FB') ?? '';
    final gmailUser = prefs.getString('GMAIL') ?? '';
    if (myBool) {
      final previousUsername = prefs.getString('username');
      final previousPassword = prefs.getString('password');
      final _users = firestore.collection('Users');
      if (fbUser != '') {
        final email = await firestore.collection('Emails').doc(fbUser).get();
        final username = email.get('username');
        if (targetUsername == username) {
          prefs.setBool('KeepLogged', false).then((value) {
            auth.signOut().then((value) {
              FacebookAuth.instance.login().then((result) {
                if (result.status == LoginStatus.success) {
                  final OAuthCredential credential =
                      FacebookAuthProvider.credential(
                          result.accessToken!.token);
                  FirebaseAuth.instance
                      .signInWithCredential(credential)
                      .then((value) {
                    _users.doc(previousUsername).set({
                      'Activity': 'Away',
                      'Sign-out': DateTime.now(),
                    }, SetOptions(merge: true)).then((value) async {
                      await General.logout(previousUsername!);
                      Provider.of<MyProfile>(context, listen: false)
                          .resetProfile();
                      Provider.of<AppBarProvider>(context, listen: false)
                          .reset();
                      Provider.of<NewPostHelper>(context, listen: false)
                          .clear();
                      Provider.of<FeedProvider>(context, listen: false)
                          .clearPosts();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacementNamed(
                          context, RouteGenerator.splashScreen);
                    });
                  });
                }
              });
            });
          });
        }
      }
      if (gmailUser != '') {
        final email = await firestore.collection('Emails').doc(gmailUser).get();
        final username = email.get('username');
        if (targetUsername == username) {
          prefs.setBool('KeepLogged', false).then((value) {
            auth.signOut().then((value) {
              GoogleSignIn().signIn().then((value) async {
                final GoogleSignInAuthentication googleAuth =
                    await value!.authentication;
                final credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );
                auth.signInWithCredential(credential).then((value) {
                  _users.doc(previousUsername).set({
                    'Activity': 'Away',
                    'Sign-out': DateTime.now(),
                  }, SetOptions(merge: true)).then((value) async {
                    await General.logout(previousUsername!);
                    Provider.of<MyProfile>(context, listen: false)
                        .resetProfile();
                    Provider.of<AppBarProvider>(context, listen: false).reset();
                    Provider.of<NewPostHelper>(context, listen: false).clear();
                    Provider.of<FeedProvider>(context, listen: false)
                        .clearPosts();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacementNamed(
                        context, RouteGenerator.splashScreen);
                  });
                });
              });
            });
          });
        }
      }
      if (user2.isNotEmpty) {
        if (targetUsername == user2[0]) {
          final pass = user2[1];
          prefs.setString('username', targetUsername).then((_) {
            prefs.setString('password', pass).then((_) {
              prefs.setStringList('User2',
                  [previousUsername!, previousPassword!]).then((value) {
                _users.doc(previousUsername).set({
                  'Activity': 'Away',
                  'Sign-out': DateTime.now(),
                }, SetOptions(merge: true)).then((value) {
                  auth.signOut().then((value) {
                    auth.signInAnonymously().then((value) async {
                      await General.logout(previousUsername);
                      Provider.of<MyProfile>(context, listen: false)
                          .resetProfile();
                      Provider.of<AppBarProvider>(context, listen: false)
                          .reset();
                      Provider.of<NewPostHelper>(context, listen: false)
                          .clear();
                      Provider.of<FeedProvider>(context, listen: false)
                          .clearPosts();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacementNamed(
                          context, RouteGenerator.splashScreen);
                    });
                  });
                });
              });
            });
          });
        }
      }
      if (user3.isNotEmpty) {
        if (targetUsername == user3[0]) {
          final pass = user3[1];
          prefs.setString('username', targetUsername).then((_) {
            prefs.setString('password', pass).then((_) {
              prefs.setStringList('User3',
                  [previousUsername!, previousPassword!]).then((value) {
                _users.doc(previousUsername).set({
                  'Activity': 'Away',
                  'Sign-out': DateTime.now(),
                }, SetOptions(merge: true)).then((value) {
                  auth.signOut().then((value) {
                    auth.signInAnonymously().then((value) async {
                      await General.logout(previousUsername);
                      Provider.of<MyProfile>(context, listen: false)
                          .resetProfile();
                      Provider.of<AppBarProvider>(context, listen: false)
                          .reset();
                      Provider.of<NewPostHelper>(context, listen: false)
                          .clear();
                      Provider.of<FeedProvider>(context, listen: false)
                          .clearPosts();

                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacementNamed(
                          context, RouteGenerator.splashScreen);
                    });
                  });
                });
              });
            });
          });
        }
      }
      if (user4.isNotEmpty) {
        if (targetUsername == user4[0]) {
          final pass = user4[1];
          prefs.setString('username', targetUsername).then((_) {
            prefs.setString('password', pass).then((_) {
              prefs.setStringList('User4',
                  [previousUsername!, previousPassword!]).then((value) {
                _users.doc(previousUsername).set({
                  'Activity': 'Away',
                  'Sign-out': DateTime.now(),
                }, SetOptions(merge: true)).then((value) {
                  auth.signOut().then((value) {
                    auth.signInAnonymously().then((value) async {
                      await General.logout(previousUsername);
                      Provider.of<MyProfile>(context, listen: false)
                          .resetProfile();
                      Provider.of<AppBarProvider>(context, listen: false)
                          .reset();
                      Provider.of<NewPostHelper>(context, listen: false)
                          .clear();
                      Provider.of<FeedProvider>(context, listen: false)
                          .clearPosts();

                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacementNamed(
                          context, RouteGenerator.splashScreen);
                    });
                  });
                });
              });
            });
          });
        }
      }
    } else {
      final _users = firestore.collection('Users');
      if (user2.isNotEmpty) {
        if (targetUsername == user2[0]) {
          final currentIndex = savedUsers
              .indexWhere((element) => element.username == currentUsername);
          final isFb = savedUsers[currentIndex].isFbUser;
          final isGmail = savedUsers[currentIndex].isGmailUser;
          final pass = user2[1];
          prefs.setBool('KeepLogged', true).then((value) {
            prefs.setString('username', targetUsername).then((_) {
              prefs.setString('password', pass).then((_) {
                _users.doc(currentUsername).set({
                  'Activity': 'Away',
                  'Sign-out': DateTime.now(),
                }, SetOptions(merge: true)).then((value) {
                  if (isFb) {
                    FacebookAuth.instance.logOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  } else if (isGmail) {
                    GoogleSignIn().signOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  } else {
                    auth.signOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  }
                });
              });
            });
          });
        }
      }
      if (user3.isNotEmpty) {
        if (targetUsername == user3[0]) {
          final currentIndex = savedUsers
              .indexWhere((element) => element.username == currentUsername);
          final isFb = savedUsers[currentIndex].isFbUser;
          final isGmail = savedUsers[currentIndex].isGmailUser;
          final pass = user3[1];
          prefs.setBool('KeepLogged', true).then((value) {
            prefs.setString('username', targetUsername).then((_) {
              prefs.setString('password', pass).then((_) {
                _users.doc(currentUsername).set({
                  'Activity': 'Away',
                  'Sign-out': DateTime.now(),
                }, SetOptions(merge: true)).then((value) {
                  if (isFb) {
                    FacebookAuth.instance.logOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  } else if (isGmail) {
                    GoogleSignIn().signOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  } else {
                    auth.signOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  }
                });
              });
            });
          });
        }
      }
      if (user4.isNotEmpty) {
        if (targetUsername == user4[0]) {
          final currentIndex = savedUsers
              .indexWhere((element) => element.username == currentUsername);
          final isFb = savedUsers[currentIndex].isFbUser;
          final isGmail = savedUsers[currentIndex].isGmailUser;
          final pass = user4[1];
          prefs.setBool('KeepLogged', true).then((value) {
            prefs.setString('username', targetUsername).then((_) {
              prefs.setString('password', pass).then((_) {
                _users.doc(currentUsername).set({
                  'Activity': 'Away',
                  'Sign-out': DateTime.now(),
                }, SetOptions(merge: true)).then((value) {
                  if (isFb) {
                    FacebookAuth.instance.logOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  } else if (isGmail) {
                    GoogleSignIn().signOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  } else {
                    auth.signOut().then((value) {
                      auth.signInAnonymously().then((value) async {
                        await General.logout(currentUsername);
                        Provider.of<MyProfile>(context, listen: false)
                            .resetProfile();
                        Provider.of<AppBarProvider>(context, listen: false)
                            .reset();
                        Provider.of<NewPostHelper>(context, listen: false)
                            .clear();
                        Provider.of<FeedProvider>(context, listen: false)
                            .clearPosts();

                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, RouteGenerator.splashScreen);
                      });
                    });
                  }
                });
              });
            });
          });
        }
      }
    }
  }

  Future removeUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final user2 = prefs.getStringList('User2') ?? [];
    final user3 = prefs.getStringList('User3') ?? [];
    final user4 = prefs.getStringList('User4') ?? [];
    if (user2.isNotEmpty) {
      if (username == user2[0]) return prefs.remove('User2');
    }
    if (user3.isNotEmpty) {
      if (username == user3[0]) return prefs.remove('User3');
    }
    if (user4.isNotEmpty) {
      if (username == user4[0]) return prefs.remove('User4');
    }
  }

  void _showFirst(String username) {
    showDialog(
        context: context,
        builder: (_) {
          final lang = General.language(context);
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
                          color: Colors.white),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(lang.widgets_profile26,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Roboto',
                                    fontSize: 21.0,
                                    color: Colors.black)),
                            const Divider(
                                thickness: 1.0, indent: 0.0, endIndent: 0.0),
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () async {
                                        _showIt();
                                        removeUser(username).then((value) {
                                          firestore
                                              .collection('Users')
                                              .doc(username)
                                              .set({
                                            'fcm': ''
                                          }, SetOptions(merge: true)).then(
                                                  (value) {
                                            setState(() {
                                              savedUsers.removeWhere(
                                                  (element) =>
                                                      element.username ==
                                                      username);
                                            });
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          });
                                        });
                                      },
                                      child: Text(lang.clubs_alerts3,
                                          style: const TextStyle(
                                              color: Colors.red))),
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(lang.clubs_alerts4,
                                          style: const TextStyle(
                                              color: Colors.red)))
                                ])
                          ]))));
        });
  }

  @override
  void initState() {
    super.initState();
    _getSavedUsers = getSavedUsers();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final String currentUsername = Provider.of<MyProfile>(context).getUsername;
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SizedBox(
                height: _deviceHeight * 0.45,
                child: FutureBuilder(
                    future: _getSavedUsers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SettingsBar(lang.widgets_profile27),
                              const Spacer(),
                              const Icon(Icons.switch_account_outlined,
                                  color: Colors.grey),
                              const Spacer()
                            ]);

                      if (snapshot.hasError)
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SettingsBar(lang.widgets_profile27),
                              const Spacer(),
                              Text(lang.clubs_adminScreen2,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15.0)),
                              const Spacer()
                            ]);

                      return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SettingsBar(lang.widgets_profile27),
                            if (viewMode == View.SignIn)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LogInAuthBox(true, addUser),
                              ),
                            if (viewMode == View.Switch &&
                                savedUsers.length >= 1)
                              giveUserTile(
                                  0, currentUsername, _showFirst, switchUser),
                            if (viewMode == View.Switch &&
                                savedUsers.length >= 2)
                              giveUserTile(
                                  1, currentUsername, _showFirst, switchUser),
                            if (viewMode == View.Switch &&
                                savedUsers.length >= 3)
                              giveUserTile(
                                  2, currentUsername, _showFirst, switchUser),
                            if (viewMode == View.Switch &&
                                savedUsers.length >= 4)
                              giveUserTile(
                                  3, currentUsername, _showFirst, switchUser),
                            if (viewMode == View.Switch &&
                                savedUsers.length >= 5)
                              giveUserTile(
                                  4, currentUsername, _showFirst, switchUser),
                            if (viewMode == View.Switch &&
                                savedUsers.length == 6)
                              giveUserTile(
                                  5, currentUsername, _showFirst, switchUser),
                            if (viewMode == View.Switch && savedUsers.isEmpty)
                              giveAddTile(changeView),
                            if (viewMode == View.Switch &&
                                savedUsers.length < 2)
                              giveAddTile(changeView),
                            if (viewMode == View.Switch &&
                                savedUsers.length < 3)
                              giveAddTile(changeView)
                          ]);
                    }))));
  }
}

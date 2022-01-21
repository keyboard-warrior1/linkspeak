import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/miniProfile.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import 'profileImage.dart';

class LikesView extends StatefulWidget {
  final int numOfLikes;
  final ScrollController scrollController;
  final void Function(BuildContext, String) handler;
  final String postID;
  LikesView(this.numOfLikes, this.scrollController, this.handler, this.postID);
  @override
  _LikesViewState createState() => _LikesViewState();
}

class _LikesViewState extends State<LikesView> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getLikers;
  List<MiniProfile> uppers = [];
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> getLikers(String myUsername, String myIMG) async {
    if (widget.numOfLikes == 0) {
      return;
    } else {
      final myLike = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .doc(myUsername)
          .get();

      if (myLike.exists) {
        final MiniProfile _liker =
            MiniProfile(username: myUsername, imgUrl: myIMG);
        uppers.insert(0, _liker);
      }
      final postLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .limit(20)
          .get();
      final likersList = postLikers.docs;
      for (var liker in likersList) {
        if (liker.id == myUsername) {
        } else {
          final likerName = liker.id;
          final likerUser =
              await firestore.collection('Users').doc(likerName).get();
          if (likerUser.exists) {
            final likerIMG = likerUser.get('Avatar');
            final MiniProfile _liker =
                MiniProfile(username: likerName, imgUrl: likerIMG);
            uppers.add(_liker);
          } else {
            final MiniProfile _liker =
                MiniProfile(username: likerName, imgUrl: '');
            uppers.add(_liker);
          }
        }
      }
      if (likersList.length < 20) {
        isLastPage = true;
      }
      setState(() {});
    }
  }

  Future<void> getMoreLikers(String myUsername) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final lastLiker = uppers.last.username;
      final getLastLiker = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .doc(lastLiker)
          .get();
      final postLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .startAfterDocument(getLastLiker)
          .limit(20)
          .get();
      final likersList = postLikers.docs;
      for (var liker in likersList) {
        if (liker.id == myUsername) {
        } else {
          final likerName = liker.id;
          final likerUser =
              await firestore.collection('Users').doc(likerName).get();
          if (likerUser.exists) {
            final likerIMG = likerUser.get('Avatar');
            final MiniProfile _liker =
                MiniProfile(username: likerName, imgUrl: likerIMG);
            uppers.add(_liker);
          } else {
            final MiniProfile _liker =
                MiniProfile(username: likerName, imgUrl: '');
            uppers.add(_liker);
          }
        }
      }
      if (likersList.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    _getLikers = getLikers(myUsername, myIMG);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLikers(myUsername);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final themeIconHelper = Provider.of<ThemeModel>(context, listen: false);
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final String inactiveIconPath = themeIconHelper.themeIconPathInactive;
    final int numOfUppers = Provider.of<FullHelper>(context).getNumOfLikes;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return FutureBuilder(
      future: _getLikers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: deviceHeight * 0.3,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  const Center(
                    child: const CircularProgressIndicator(),
                  ),
                ]),
          );
        }
        if (snapshot.hasError) {
          Container(
            height: deviceHeight * 0.3,
            width: deviceWidth,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'An error has occured, please try again',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                        const EdgeInsets.all(0.0),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () => setState(
                        () => _getLikers = getLikers(myUsername, myIMG)),
                    child: Center(
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]),
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (numOfUppers == 0)
              Container(
                height: deviceHeight * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentIconName != 'Custom')
                      Icon(
                        currentIcon,
                        color: Colors.grey.shade400,
                        size: 75.0,
                      ),
                    if (currentIconName == 'Custom')
                      ImageIcon(
                        FileImage(
                          File(inactiveIconPath),
                        ),
                        size: 75.0,
                      ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: Text(
                        'Be the first to upvote!',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (numOfUppers != 0)
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 10.0,
                  maxHeight: deviceHeight * 0.7,
                ),
                child: NotificationListener<OverscrollNotification>(
                  onNotification: (OverscrollNotification value) {
                    if (value.overscroll < 0 &&
                        widget.scrollController.offset + value.overscroll <=
                            0) {
                      if (widget.scrollController.offset != 0)
                        widget.scrollController.jumpTo(0);
                      return true;
                    }
                    if (widget.scrollController.offset + value.overscroll >=
                        widget.scrollController.position.maxScrollExtent) {
                      if (widget.scrollController.offset !=
                          widget.scrollController.position.maxScrollExtent)
                        widget.scrollController.jumpTo(
                            widget.scrollController.position.maxScrollExtent);
                      return true;
                    }
                    widget.scrollController.jumpTo(
                        widget.scrollController.offset + value.overscroll);
                    return true;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 85.0),
                    controller: _scrollController,
                    itemCount: uppers.length + 1,
                    itemBuilder: (_, index) {
                      if (index == uppers.length) {
                        if (isLoading) {
                          return Center(
                            child: SizedBox(
                              height: 35.0,
                              width: 35.0,
                              child: Center(
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }
                        if (isLastPage) {
                          return emptyBox;
                        }
                      } else {
                        final upper = uppers[index];
                        return ListTile(
                          leading: ProfileImage(
                            username: upper.username,
                            url: upper.imgUrl,
                            factor: 0.05,
                            inEdit: false,
                            asset: null,
                          ),
                          title: Text(' ${upper.username}'),
                          onTap: () {
                            if (upper.username ==
                                context.read<MyProfile>().getUsername) {
                            } else {
                              widget.handler(
                                context,
                                upper.username,
                              );
                            }
                          },
                        );
                      }
                      return emptyBox;
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/themeModel.dart';

class PostBar extends StatefulWidget {
  final String postID;
  final bool isInFeed;
  final dynamic upButtonHandler;
  final dynamic likeTextHandler;
  final dynamic commentButtonHandler;
  final dynamic topicButtonHandler;
  final dynamic shareButtonHandler;
  final bool upView;
  final bool commentView;
  final bool topicsView;
  final bool shareView;
  final bool isInOtherProfile;
  final bool isClubPost;

  const PostBar(
      {required this.postID,
      required this.isInFeed,
      required this.isClubPost,
      required this.upButtonHandler,
      required this.likeTextHandler,
      required this.commentButtonHandler,
      required this.topicButtonHandler,
      required this.shareButtonHandler,
      required this.upView,
      required this.commentView,
      required this.topicsView,
      required this.shareView,
      required this.isInOtherProfile});

  @override
  _PostBarState createState() => _PostBarState();
}

class _PostBarState extends State<PostBar> {
  bool likeLoading = false;

  Color? upvoteColor(
      Color _accentColor, bool uppedByMe, Color selectedLikeColor) {
    if (widget.upView && uppedByMe)
      return _accentColor;
    else if (widget.upView && !uppedByMe)
      return _accentColor;
    else if (!widget.upView && !uppedByMe)
      return Colors.white;
    else if (!widget.upView && uppedByMe) return selectedLikeColor;
    return Colors.transparent;
  }

  Future<void> _likeClubPost(
      void Function() helperLike,
      final bool isLiked,
      final String posterUsername,
      final String clubName,
      final String _myUsername,
      final String _myUserImg,
      final String postId) async {
    if (!likeLoading) {
      setState(() {
        likeLoading = true;
      });
      helperLike();
      final DateTime _rightNow = DateTime.now();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      var likebatch = firestore.batch();
      var unlikeBatch = firestore.batch();
      final posts = firestore.collection('Posts');
      final myUser = firestore.collection('Users').doc(_myUsername);
      final thisPost = posts.doc(postId);
      final myLikedPosts = myUser.collection('Liked Club Posts');
      final myUnlikedPosts = myUser.collection('Unliked Club Posts');
      final postLikers = thisPost.collection('likers');
      final postUnlikers = thisPost.collection('unlikers');
      var thislikedPost = myLikedPosts.doc(postId);
      var thisUnlikedPost = myUnlikedPosts.doc(postId);
      var myLike = postLikers.doc(_myUsername);
      var myUnlike = postUnlikers.doc(_myUsername);
      final options = SetOptions(merge: true);
      likebatch.set(thislikedPost, {
        'date': _rightNow,
        'club name': clubName,
      });

      likebatch.set(myLike, {'date': _rightNow});
      likebatch.update(thisPost, {'likes': FieldValue.increment(1)});
      unlikeBatch.delete(thislikedPost);
      unlikeBatch.delete(myLike);
      unlikeBatch.set(myUnlike,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisUnlikedPost,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.update(thisPost, {'likes': FieldValue.increment(-1)});
      unlikeBatch.set(
          myUser, {'post unlikes': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisPost, {'unlikes': FieldValue.increment(1)}, options);
      final checkExists = await General.checkExists('Posts/$postId');
      if (checkExists) {
        if (isLiked) {
          Map<String, dynamic> fields = {
            'club post unlikes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'clubName': clubName,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'club post unlikes',
              docID: '$postId',
              docFields: docFields);

          return unlikeBatch.commit().then((_) async {
            setState(() {
              likeLoading = false;
            });
          }).catchError((_) {
            setState(() {
              likeLoading = false;
            });
          });
        } else if (!isLiked) {
          Map<String, dynamic> fields = {
            'club post likes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'clubName': clubName,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'club post likes',
              docID: '$postId',
              docFields: docFields);
          return likebatch.commit().then((_) async {
            final targetUser =
                await firestore.collection('Users').doc(posterUsername).get();
            final token = targetUser.get('fcm');
            var secondBatch = firestore.batch();
            final otherLikesNotifs = firestore
                .collection('Users')
                .doc(posterUsername)
                .collection('PostLikesNotifs');
            final status = targetUser.get('Status');
            if (status != 'Banned') {
              if (targetUser.data()!.containsKey('AllowLikes')) {
                final allowLikes = targetUser.get('AllowLikes');
                if (allowLikes) {
                  if (posterUsername != _myUsername) {
                    secondBatch.set(otherLikesNotifs.doc(), {
                      'post': '$postId',
                      'user': _myUsername,
                      'recipient': posterUsername,
                      'token': token,
                      'date': _rightNow,
                      'clubName': clubName,
                    });
                    secondBatch.update(
                        firestore.collection('Users').doc(posterUsername),
                        {'numOfPostLikesNotifs': FieldValue.increment(1)});
                    secondBatch.commit();
                  }
                }
              } else {
                if (posterUsername != _myUsername) {
                  secondBatch.set(otherLikesNotifs.doc(), {
                    'post': '$postId',
                    'user': _myUsername,
                    'recipient': posterUsername,
                    'token': token,
                    'date': _rightNow,
                    'clubName': clubName,
                  });
                  secondBatch.update(
                      firestore.collection('Users').doc(posterUsername),
                      {'numOfPostLikesNotifs': FieldValue.increment(1)});
                  secondBatch.commit();
                }
              }
            }
            setState(() {
              likeLoading = false;
            });
          }).catchError((onError) {
            setState(() {
              likeLoading = false;
            });
          });
        }
      } else {
        setState(() {
          likeLoading = false;
        });
      }
    }
  }

  Future<void> _upVote(
      void Function() helperLike,
      final bool isLiked,
      final String posterUsername,
      final String _myUsername,
      final String _myUserImg,
      final String postId,
      final String clubName) async {
    if (!likeLoading) {
      setState(() {
        likeLoading = true;
      });
      helperLike();
      final DateTime _rightNow = DateTime.now();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      var likebatch = firestore.batch();
      var unlikeBatch = firestore.batch();
      final posts = firestore.collection('Posts');
      final myUser = firestore.collection('Users').doc(_myUsername);
      final thisPost = posts.doc(postId);
      final myLikedPosts = myUser.collection('LikedPosts');
      final myUnlikedPosts = myUser.collection('Unliked Posts');
      final postLikers = thisPost.collection('likers');
      final postUnlikers = thisPost.collection('unlikers');
      var thislikedPost = myLikedPosts.doc(postId);
      var thisUnlikedPost = myUnlikedPosts.doc(postId);
      var myLike = postLikers.doc(_myUsername);
      var myUnlike = postUnlikers.doc(_myUsername);
      final options = SetOptions(merge: true);
      likebatch.set(thislikedPost, {'date': _rightNow});
      likebatch.set(myLike, {'date': _rightNow});
      likebatch.update(thisPost, {'likes': FieldValue.increment(1)});
      unlikeBatch.delete(thislikedPost);
      unlikeBatch.delete(myLike);
      unlikeBatch.set(myUnlike,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisUnlikedPost,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.update(thisPost, {'likes': FieldValue.increment(-1)});
      unlikeBatch.set(
          myUser, {'post unlikes': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisPost, {'unlikes': FieldValue.increment(1)}, options);
      final checkExists = await General.checkExists('Posts/$postId');
      if (checkExists) {
        if (isLiked) {
          Map<String, dynamic> fields = {
            'post unlikes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {'date': _rightNow};
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'post unlikes',
              docID: '$postId',
              docFields: docFields);
          return unlikeBatch.commit().then((_) async {
            setState(() {
              likeLoading = false;
            });
          }).catchError((_) {
            setState(() {
              likeLoading = false;
            });
          });
        } else if (!isLiked) {
          Map<String, dynamic> fields = {'post likes': FieldValue.increment(1)};
          Map<String, dynamic> docFields = {'date': _rightNow};
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'post likes',
              docID: '$postId',
              docFields: docFields);
          return likebatch.commit().then((_) async {
            final targetUser =
                await firestore.collection('Users').doc(posterUsername).get();
            final token = targetUser.get('fcm');
            var secondBatch = firestore.batch();
            final otherLikesNotifs = firestore
                .collection('Users')
                .doc(posterUsername)
                .collection('PostLikesNotifs');
            final status = targetUser.get('Status');
            if (status != 'Banned') {
              if (targetUser.data()!.containsKey('AllowLikes')) {
                final allowLikes = targetUser.get('AllowLikes');
                if (allowLikes) {
                  if (posterUsername != _myUsername) {
                    secondBatch.set(otherLikesNotifs.doc(), {
                      'post': '$postId',
                      'user': _myUsername,
                      'recipient': posterUsername,
                      'token': token,
                      'date': _rightNow,
                      'clubName': clubName,
                    });
                    secondBatch.update(
                        firestore.collection('Users').doc(posterUsername),
                        {'numOfPostLikesNotifs': FieldValue.increment(1)});
                    secondBatch.commit();
                  }
                }
              } else {
                if (posterUsername != _myUsername) {
                  secondBatch.set(otherLikesNotifs.doc(), {
                    'post': '$postId',
                    'user': _myUsername,
                    'recipient': posterUsername,
                    'token': token,
                    'date': _rightNow,
                    'clubName': clubName,
                  });
                  secondBatch.update(
                      firestore.collection('Users').doc(posterUsername),
                      {'numOfPostLikesNotifs': FieldValue.increment(1)});
                  secondBatch.commit();
                }
              }
            }
            setState(() {
              likeLoading = false;
            });
          }).catchError((onError) {
            setState(() {
              likeLoading = false;
            });
          });
        }
      } else {
        setState(() {
          likeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = _sizeQuery.height;
    Color _primarySwatch = _theme.colorScheme.primary;
    Color _accentColor = _theme.colorScheme.secondary;
    final themeIconHelper = Provider.of<ThemeModel>(context);
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    Color currentIconColor = themeIconHelper.likeColor;
    final File? inactiveIconPath = themeIconHelper.inactiveLikeFile;
    final File? activeIconPath = themeIconHelper.activeLikeFile;
    var helper = Provider.of<FullHelper>(context);
    final String poster = helper.posterId;
    final String _clubName = helper.clubName;
    final int numOfLikes = helper.getNumOfLikes;
    final int numOfComments = helper.getNumOfComments;
    final List<String> postImgUrls = helper.postImgUrls;
    final bool _noComments = numOfComments == 0;
    final bool isClubPost = helper.isClubPost;
    final String _myUsername = Provider.of<MyProfile>(context).getUsername;
    final String _myUserImg = Provider.of<MyProfile>(context).getProfileImage;
    final bool uppedByMe = helper.isLiked;
    final void Function() helperLikePost =
        Provider.of<FullHelper>(context, listen: false).like;
    if (widget.isInOtherProfile) {
      final otherProfile = Provider.of<OtherProfile>(context, listen: false);
      _primarySwatch = otherProfile.getPrimaryColor;
      _accentColor = otherProfile.getAccentColor;
      currentIconColor = otherProfile.getLikeColor;
    }
    void likeLogic() {
      if (isClubPost)
        _likeClubPost(helperLikePost, uppedByMe, poster, _clubName, _myUsername,
            _myUserImg, widget.postID);
      else
        _upVote(helperLikePost, uppedByMe, poster, _myUsername, _myUserImg,
            widget.postID, _clubName);
    }

    final Widget _upvoteButton = ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: _deviceWidth * 1 / 6,
            maxWidth: (!widget.isInFeed)
                ? _deviceWidth * 1 / 4
                : _deviceWidth * 1 / 3,
            minHeight: _deviceHeight * 0.05,
            maxHeight: _deviceHeight * 0.05),
        child: TextButton(
            onPressed: null,
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.only(left: 10.0, right: 5.0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                        onTap: (likeLoading)
                            ? () {}
                            : (widget.isInFeed)
                                ? (!isClubPost)
                                    ? () => _upVote(
                                        helperLikePost,
                                        uppedByMe,
                                        poster,
                                        _myUsername,
                                        _myUserImg,
                                        widget.postID,
                                        _clubName)
                                    : () => _likeClubPost(
                                        helperLikePost,
                                        uppedByMe,
                                        poster,
                                        _clubName,
                                        _myUsername,
                                        _myUserImg,
                                        widget.postID)
                                : () => widget.upButtonHandler(likeLogic),
                        child: (currentIconName != 'Custom')
                            ? Icon(currentIcon,
                                size: 32.0,
                                color: upvoteColor(
                                    _accentColor, uppedByMe, currentIconColor))
                            : IconButton(
                                padding: const EdgeInsets.all(0.0),
                                onPressed: (likeLoading)
                                    ? () {}
                                    : (widget.isInFeed)
                                        ? (!isClubPost)
                                            ? () => _upVote(
                                                helperLikePost,
                                                uppedByMe,
                                                poster,
                                                _myUsername,
                                                _myUserImg,
                                                widget.postID,
                                                _clubName)
                                            : () => _likeClubPost(
                                                helperLikePost,
                                                uppedByMe,
                                                poster,
                                                _clubName,
                                                _myUsername,
                                                _myUserImg,
                                                widget.postID)
                                        : () =>
                                            widget.upButtonHandler(likeLogic),
                                icon:
                                    Image.file(uppedByMe ? activeIconPath! : inactiveIconPath!))),
                  ),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GestureDetector(
                        onTap: widget.likeTextHandler,
                        child: Text(
                            (numOfLikes != 0)
                                ? "  ${General.optimisedNumbers(numOfLikes)}"
                                : '   ',
                            textAlign: TextAlign.start,
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: (uppedByMe)
                                    ? currentIconColor
                                    : Colors.white,
                                fontFamily: 'RobotoCondensed')),
                      ))
                ])));
    final _commentsButton = ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: _deviceHeight * 0.05,
            maxHeight: _deviceHeight * 0.05,
            minWidth: _deviceWidth * 1 / 6,
            maxWidth: (!widget.isInFeed)
                ? _deviceWidth * 1 / 4
                : _deviceWidth * 1 / 3),
        child: TextButton(
            onPressed: widget.commentButtonHandler,
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.only(left: 10.0, right: 5.0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                          widget.commentView
                              ? Icons.chat_bubble_rounded
                              : Icons.chat_bubble_outline_rounded,
                          size: 32.0,
                          color: widget.commentView
                              ? _accentColor
                              : Colors.white)),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                          child: Text(
                              (!_noComments)
                                  ? "   ${General.optimisedNumbers(numOfComments)}"
                                  : '   ',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: widget.commentView
                                      ? _accentColor
                                      : Colors.white,
                                  fontFamily: 'RobotoCondensed'))))
                ])));

    final Widget _topicsButton = TextButton(
        style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            splashFactory: NoSplash.splashFactory,
            padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                const EdgeInsets.only(left: 10.0, right: 5.0))),
        onPressed: widget.topicButtonHandler,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: _deviceWidth * 1 / 6,
                maxWidth: _deviceWidth * 1 / 4,
                minHeight: _deviceHeight * 0.05,
                maxHeight: _deviceHeight * 0.05),
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Text('Topics',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: widget.topicsView
                                      ? _accentColor
                                      : Colors.white)))
                    ]))));
    final Widget _shareButton = ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: _deviceHeight * 0.05,
            maxHeight: _deviceHeight * 0.05,
            minWidth: _deviceWidth * 1 / 6 - 16,
            maxWidth: (!widget.isInFeed)
                ? _deviceWidth * 1 / 4
                : _deviceWidth * 1 / 3 - 16),
        child: TextButton(
            onPressed: (widget.isInFeed)
                ? () => widget.shareButtonHandler(
                    context, widget.postID, _clubName, isClubPost)
                : widget.shareButtonHandler,
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.only(left: 10.0, right: 5.0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(customIcons.MyFlutterApp.right,
                          color:
                              (widget.shareView) ? _accentColor : Colors.white,
                          size: 32.0))
                ])));
    final Widget _baseline = Container(
        key: UniqueKey(),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(color: _primarySwatch),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          _upvoteButton,
          _commentsButton,
          if (!widget.isInFeed) _topicsButton,
          _shareButton,
          if (widget.isInFeed && postImgUrls.isNotEmpty)
            const BaselineFocusCircles()
        ]));
    return _baseline;
  }
}

class BaselineFocusCircles extends StatelessWidget {
  const BaselineFocusCircles();

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    var helper = Provider.of<FullHelper>(context);
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = _sizeQuery.height;
    final int carouselIndex = helper.previewCarouselIndex;
    final List<String> postImgUrls = helper.postImgUrls;
    Color accentColor = _theme.colorScheme.secondary;
    return ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: _deviceWidth * 1 / 4,
            maxWidth: _deviceWidth * 2 / 4 - 16,
            minHeight: _deviceHeight * 0.05,
            maxHeight: _deviceHeight * 0.05),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // listview animation bug
              //   Noglow(
              //       child: SingleChildScrollView(
              //           scrollDirection: Axis.horizontal,
              //           child:
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...postImgUrls.map((url) {
                      int index = postImgUrls.indexOf(url);
                      return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: carouselIndex == index
                                  ? accentColor
                                  : Colors.white));
                    })
                    // })
                    // ])))
                  ])
            ]));
  }
}

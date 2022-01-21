import 'dart:io';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../providers/themeModel.dart';
import '../my_flutter_app_icons.dart' as customIcons;

class PostBar extends StatefulWidget {
  final String postID;
  final bool isInFeed;
  final dynamic upButtonHandler;
  final dynamic commentButtonHandler;
  final dynamic topicButtonHandler;
  final dynamic shareButtonHandler;
  final bool upView;
  final bool commentView;
  final bool topicsView;
  final bool shareView;
  final bool isInOtherProfile;

  const PostBar({
    required this.postID,
    required this.isInFeed,
    required this.upButtonHandler,
    required this.commentButtonHandler,
    required this.topicButtonHandler,
    required this.shareButtonHandler,
    required this.upView,
    required this.commentView,
    required this.topicsView,
    required this.shareView,
    required this.isInOtherProfile,
  });

  @override
  _PostBarState createState() => _PostBarState();
}

class _PostBarState extends State<PostBar> {
  bool likeLoading = false;
  String _optimisedNumbers(num value) {
    if (value < 1000) {
      return '${value.toString()}';
    } else if (value >= 1000) {
      num dividedVal = value / 1000;
      return '${dividedVal.toStringAsFixed(1)}K';
    } else if (value >= 1000000) {
      num dividedVal = value / 1000000;
      return '${dividedVal.toStringAsFixed(1)}M';
    } else if (value >= 1000000000) {
      num dividedVal = value / 1000000000;
      return '${dividedVal.toStringAsFixed(1)}B';
    }
    return 'null';
  }

  String _topicNumber(num value) {
    if (value >= 99) {
      return '99+';
    } else {
      return value.toString();
    }
  }

  Color? upvoteColor(
      Color _accentColor, bool uppedByMe, Color selectedLikeColor) {
    if (widget.upView && uppedByMe) {
      return _accentColor;
    } else if (widget.upView && !uppedByMe) {
      return _accentColor;
    } else if (!widget.upView && !uppedByMe) {
      return Colors.white;
    } else if (!widget.upView && uppedByMe) {
      return selectedLikeColor;
    }
  }

  Future<void> _upVote(
    void Function(String) like,
    void Function(String, String) likePost,
    void Function(String, String) unlikePost,
    final String posterUsername,
    final String _myUsername,
    final String _myUserImg,
    final List<String> myLiked,
    final String postId,
    final DateTime postedDate,
  ) async {
    if (!likeLoading) {
      setState(() {
        likeLoading = true;
      });
      final DateTime _rightNow = DateTime.now();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      var likebatch = firestore.batch();
      var unlikeBatch = firestore.batch();
      final posts = firestore.collection('Posts');
      final myLikedPosts = firestore
          .collection('Users')
          .doc(_myUsername)
          .collection('LikedPosts');
      final postLikers = posts.doc(postId).collection('likers');
      var thislikedPost = myLikedPosts.doc(postId);
      var myLike = postLikers.doc(_myUsername);
      var addLikers = posts.doc(postId);
      likebatch.set(thislikedPost, {'date': postedDate});
      likebatch.set(myLike, {'date': _rightNow});
      likebatch.update(addLikers, {'likes': FieldValue.increment(1)});
      unlikeBatch.delete(thislikedPost);
      unlikeBatch.delete(myLike);
      unlikeBatch.update(addLikers, {'likes': FieldValue.increment(-1)});
      if (myLiked.contains(postId)) {
        return unlikeBatch.commit().then((_) async {
          like(postId);
          unlikePost(_myUsername, _myUserImg);

          setState(() {
            likeLoading = false;
          });
        }).catchError((_) {
          setState(() {
            likeLoading = false;
          });
        });
      } else if (!myLiked.contains(postId)) {
        return likebatch.commit().then((_) async {
          like(postId);
          likePost(_myUsername, _myUserImg);
          final targetUser =
              await firestore.collection('Users').doc(posterUsername).get();
          final token = targetUser.get('fcm');
          var secondBatch = firestore.batch();
          final otherLikesNotifs = firestore
              .collection('Users')
              .doc(posterUsername)
              .collection('PostLikesNotifs');
          if (targetUser.data()!.containsKey('AllowLikes')) {
            final allowLikes = targetUser.get('AllowLikes');
            if (allowLikes) {
              if (posterUsername != _myUsername) {
                secondBatch.set(otherLikesNotifs.doc(), {
                  'post': '$postId',
                  'user': _myUsername,
                  'token': token,
                  'date': _rightNow,
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
                'token': token,
                'date': _rightNow,
              });
              secondBatch.update(
                  firestore.collection('Users').doc(posterUsername),
                  {'numOfPostLikesNotifs': FieldValue.increment(1)});
              secondBatch.commit();
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
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = _sizeQuery.width;
    final double _deviceHeight = _sizeQuery.height;
    Color _primarySwatch = _theme.primaryColor;
    Color _accentColor = _theme.accentColor;
    final themeIconHelper = Provider.of<ThemeModel>(context);
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final Color currentIconColor = themeIconHelper.likeColor;
    final String inactiveIconPath = themeIconHelper.themeIconPathInactive;
    final String activeIconPath = themeIconHelper.themeIconPathActive;
    final String poster = Provider.of<FullHelper>(context).posterId;
    final DateTime postDate = Provider.of<FullHelper>(context).postedDate;
    final int numOfLikes = Provider.of<FullHelper>(context).getNumOfLikes;
    final int numOfComments = Provider.of<FullHelper>(context).getNumOfComments;
    final int numOfTopics = Provider.of<FullHelper>(context).numOfTopics;
    final bool _noComments = numOfComments == 0;
    final List<String> _likedPosts = context.watch<MyProfile>().getLikedPostIDs;
    final String _myUsername = Provider.of<MyProfile>(context).getUsername;
    final String _myUserImg = Provider.of<MyProfile>(context).getProfileImage;
    final bool uppedByMe = _likedPosts.contains(widget.postID);
    final void Function(String, String) likePost =
        Provider.of<FullHelper>(context, listen: false).likePost;
    final void Function(String, String) unlikePost =
        Provider.of<FullHelper>(context, listen: false).unlikePost;
    final void Function(String) like =
        Provider.of<MyProfile>(context, listen: false).likePost;
    if (widget.isInOtherProfile) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    void likeLogic() {
      _upVote(like, likePost, unlikePost, poster, _myUsername, _myUserImg,
          _likedPosts, widget.postID, postDate);
    }

    final Widget _upvoteButton = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _deviceWidth * 1 / 6,
        maxWidth:
            (!widget.isInFeed) ? _deviceWidth * 1 / 4 : _deviceWidth * 1 / 3,
        minHeight: _deviceHeight * 0.05,
        maxHeight: _deviceHeight * 0.05,
      ),
      child: TextButton(
        onPressed: (likeLoading)
            ? () {}
            : (widget.isInFeed)
                ? () => _upVote(like, likePost, unlikePost, poster, _myUsername,
                    _myUserImg, _likedPosts, widget.postID, postDate)
                : () => widget.upButtonHandler(likeLogic),
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.only(left: 10.0, right: 5.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: (currentIconName != 'Custom')
                  ? Icon(
                      currentIcon,
                      size: 32.0,
                      color: upvoteColor(
                          _accentColor, uppedByMe, currentIconColor),
                    )
                  : ImageIcon(
                      FileImage(
                        File(uppedByMe ? activeIconPath : inactiveIconPath),
                      ),
                    ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                (numOfLikes != 0)
                    ? "  ${_optimisedNumbers(numOfLikes)}"
                    : '   ',
                textAlign: TextAlign.start,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15.0,
                  color: (uppedByMe)
                      ? currentIconColor
                      : Colors.white,
                  fontFamily: 'RobotoCondensed',
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final _commentsButton = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _deviceHeight * 0.05,
        maxHeight: _deviceHeight * 0.05,
        minWidth: _deviceWidth * 1 / 6,
        maxWidth:
            (!widget.isInFeed) ? _deviceWidth * 1 / 4 : _deviceWidth * 1 / 3,
      ),
      child: TextButton(
        onPressed: widget.commentButtonHandler,
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.only(left: 10.0, right: 5.0),
          ),
        ),
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
                color: widget.commentView ? _accentColor : Colors.white,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                child: Text(
                  (!_noComments)
                      ? "   ${_optimisedNumbers(numOfComments)}"
                      : '   ',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: widget.commentView ? _accentColor : Colors.white,
                    fontFamily: 'RobotoCondensed',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget _topicsButton = TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashFactory: NoSplash.splashFactory,
        padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
          const EdgeInsets.only(left: 10.0, right: 5.0),
        ),
      ),
      onPressed: widget.topicButtonHandler,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: _deviceWidth * 1 / 6,
          maxWidth: _deviceWidth * 1 / 4,
          minHeight: _deviceHeight * 0.05,
          maxHeight: _deviceHeight * 0.05,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: widget.topicsView ? _accentColor : Colors.white,
                  ),
                ),
              ),
              if (numOfTopics != 0) SizedBox(width: 7.0),
              if (numOfTopics != 0)
                Badge(
                  toAnimate: false,
                  badgeContent: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      _topicNumber(numOfTopics),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  badgeColor: widget.topicsView
                      ? _accentColor
                      : Colors.lightGreenAccent.shade400,
                  borderRadius: BorderRadius.circular(5.0),
                  shape: BadgeShape.square,
                ),
            ],
          ),
        ),
      ),
    );
    final Widget _shareButton = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.05,
          maxHeight: _deviceHeight * 0.05,
          minWidth: _deviceWidth * 1 / 6 - 16,
          maxWidth: (!widget.isInFeed)
              ? _deviceWidth * 1 / 4
              : _deviceWidth * 1 / 3 - 16,
        ),
        child: TextButton(
          onPressed: (widget.isInFeed)
              ? () => widget.shareButtonHandler(context, widget.postID)
              : widget.shareButtonHandler,
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            splashFactory: NoSplash.splashFactory,
            padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
              const EdgeInsets.only(left: 10.0, right: 5.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  customIcons.MyFlutterApp.right,
                  color: (widget.shareView) ? _accentColor : Colors.white,
                  size: 32.0,
                ),
              ),
            ],
          ),
        ));
    final Widget _baseline = Container(
      key: UniqueKey(),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: _primarySwatch,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _upvoteButton,
          _commentsButton,
          if (!widget.isInFeed) _topicsButton,
          _shareButton,
        ],
      ),
    );
    return _baseline;
  }
}

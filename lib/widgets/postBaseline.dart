import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import 'package:badges/badges.dart';
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

  Color? upvoteColor(Color _accentColor, bool uppedByMe) {
    if (widget.upView && uppedByMe) {
      return _accentColor;
    } else if (widget.upView && !uppedByMe) {
      return _accentColor;
    } else if (!widget.upView && !uppedByMe) {
      return Colors.white;
    } else if (!widget.upView && uppedByMe) {
      return Colors.lightGreenAccent.shade400;
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
      likebatch.set(myLike, {'0': 1});
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
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
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
    void likeLogic() {
      _upVote(like, likePost, unlikePost, poster, _myUsername, _myUserImg,
          _likedPosts, widget.postID, postDate);
    }

    final Widget _upvoteButton = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _deviceWidth * 0.20,
        maxWidth: _deviceWidth * 0.20,
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
          padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.all(0.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                customIcons.MyFlutterApp.upvote,
                size: 32.0,
                color: upvoteColor(_accentColor, uppedByMe),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                (numOfLikes != 0) ? _optimisedNumbers(numOfLikes) : ' ',
                textAlign: TextAlign.start,
                softWrap: false,
                style: TextStyle(
                  fontSize: _deviceHeight * 0.02,
                  color: (uppedByMe)
                      ? Colors.lightGreenAccent.shade400
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
        minWidth: _deviceWidth * 0.20,
        maxWidth: _deviceWidth * 0.20,
      ),
      child: TextButton(
        onPressed: widget.commentButtonHandler,
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.all(0.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            if (!_noComments)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  child: Text(
                    _optimisedNumbers(numOfComments),
                    style: TextStyle(
                      fontSize: _deviceHeight * 0.02,
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
      onPressed: widget.topicButtonHandler,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: _deviceWidth * 0.20,
          maxWidth: _deviceWidth * 0.20,
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
                        fontSize: _deviceHeight * 0.02,
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
          minWidth: _deviceWidth * 0.20,
          maxWidth: _deviceWidth * 0.20,
        ),
        child: TextButton(
          onPressed: (widget.isInFeed)
              ? () => widget.shareButtonHandler(context, widget.postID)
              : widget.shareButtonHandler,
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
              const EdgeInsets.all(0.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

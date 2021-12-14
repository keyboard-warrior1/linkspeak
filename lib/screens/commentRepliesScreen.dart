import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/miniProfile.dart';
import '../models/comment.dart';
import '../models/reply.dart';
import '../providers/myProfileProvider.dart';
import '../providers/commentProvider.dart';
import '../widgets/settingsBar.dart';
import '../widgets/addReply.dart';
import '../widgets/replyTile.dart';

class CommentRepliesScreen extends StatefulWidget {
  final dynamic instance;
  final dynamic postID;
  final dynamic commentID;
  final dynamic isNotif;
  const CommentRepliesScreen({
    required this.instance,
    required this.postID,
    required this.commentID,
    required this.isNotif,
  });

  @override
  _CommentRepliesScreenState createState() => _CommentRepliesScreenState();
}

class _CommentRepliesScreenState extends State<CommentRepliesScreen> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getReplies;
  bool isLoading = false;
  bool isLastPage = false;
  List<Reply> replies = [];
  List<Reply> cacheReplies = [];
  late Comment? theComment;
  Future<void> getReplies(String myUsername, String myIMG) async {
    if (widget.isNotif) {
      final comment = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('comments')
          .doc(widget.commentID)
          .get();

      dynamic getter(String field) => comment.get(field);
      if (comment.exists) {
        bool hasNSFW = false;
        if (comment.data()!.containsKey('hasNSFW')) {
          final value = getter('hasNSFW');
          hasNSFW = value;
        }
        final commentID = comment.id;
        final FullCommentHelper _instance = FullCommentHelper();
        final String commenterName = getter('commenter');
        final getMyLike = await firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(commentID)
            .collection('likes')
            .doc(myUsername)
            .get();
        final bool isLiked = getMyLike.exists;
        final int numOfLikes = getter('likeCount');

        final commenterUser =
            await firestore.collection('Users').doc(commenterName).get();
        final String _commenterImageUrl = commenterUser.get('Avatar');
        final MiniProfile commenter =
            MiniProfile(username: commenterName, imgUrl: _commenterImageUrl);
        final String thecomment = getter('description');
        final int numOfReplies = getter('replyCount');
        final commentDate = getter('date').toDate();
        final bool containsMedia = getter('containsMedia');

        final String url = getter('downloadURL');
        final commentModel = Comment(
          comment: thecomment,
          commenter: commenter,
          commentDate: commentDate,
          commentID: commentID,
          numOfReplies: numOfReplies,
          instance: _instance,
          containsMedia: containsMedia,
          downloadURL: url,
          numOfLikes: numOfLikes,
          isLiked: isLiked,
          hasNSFW: hasNSFW,
        );
        theComment = commentModel;
      }
    }
    List<Reply> tempReplies = [];
    final _myReplies = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('replies')
        .where('replier', isEqualTo: myUsername);
    final _myCollection = await _myReplies.get();
    final myDocs = _myCollection.docs.reversed;

    if (myDocs.isNotEmpty) {
      for (var reply in myDocs) {
        final replyID = reply.id;
        dynamic getter(String field) => reply.get(field);
        final MiniProfile replier =
            MiniProfile(username: myUsername, imgUrl: myIMG);
        final replyDate = getter('date').toDate();
        final replyDescription = getter('description');
        final theReply = Reply(
          replier: replier,
          replyID: replyID,
          reply: replyDescription,
          replyDate: replyDate,
        );
        tempReplies.add(theReply);
      }
    }
    final _currentPostAndComment = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('replies')
        .orderBy('date')
        .limit(10);
    final repliesCollection = await _currentPostAndComment.get();
    final theReplies = repliesCollection.docs.reversed;
    for (var reply in theReplies) {
      final replyID = reply.id;
      dynamic getter(String field) => reply.get(field);
      final replierName = getter('replier');
      final replyDate = getter('date').toDate();
      final replyDescription = getter('description');
      final replierUser =
          await firestore.collection('Users').doc(replierName).get();
      if (replierUser.exists) {
        if (replierName == myUsername) {
        } else {
          final replierImage = replierUser.get('Avatar');
          final MiniProfile replier =
              MiniProfile(username: replierName, imgUrl: replierImage);
          final theReply = Reply(
            replier: replier,
            replyID: replyID,
            reply: replyDescription,
            replyDate: replyDate,
          );
          tempReplies.add(theReply);
          cacheReplies.add(theReply);
        }
      } else {
        final MiniProfile replier =
            MiniProfile(username: replierName, imgUrl: '');
        final theReply = Reply(
          replier: replier,
          replyID: replyID,
          reply: replyDescription,
          replyDate: replyDate,
        );
        tempReplies.add(theReply);
        cacheReplies.add(theReply);
      }
    }
    if (theReplies.length < 10) {
      isLastPage = true;
    }
    replies = [...tempReplies];
    setState(() {});
  }

  Future<void> getMoreReplies(String myUsername) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Reply> tempReplies = [];
      if (cacheReplies.isNotEmpty) {
        final lastReply = cacheReplies.last.replyID;
        final getLastReply = await firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('replies')
            .doc(lastReply)
            .get();
        final _currentPostAndComment = firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('replies')
            .orderBy('date')
            .startAfterDocument(getLastReply)
            .limit(10);
        final repliesCollection = await _currentPostAndComment.get();
        final theReplies = repliesCollection.docs.reversed;
        if (theReplies.isNotEmpty) {
          for (var reply in theReplies) {
            final replyID = reply.id;
            dynamic getter(String field) => reply.get(field);
            final replierName = getter('replier');

            final replyDescription = getter('description');
            final replyDate = getter('date').toDate();
            final replierUser =
                await firestore.collection('Users').doc(replierName).get();
            if (replierUser.exists) {
              final replierImage = replierUser.get('Avatar');
              final MiniProfile replier =
                  MiniProfile(username: replierName, imgUrl: replierImage);
              final theReply = Reply(
                replier: replier,
                replyID: replyID,
                reply: replyDescription,
                replyDate: replyDate,
              );
              if (replierName == myUsername) {
                cacheReplies.add(theReply);
              } else {
                if (!cacheReplies
                    .any((element) => element.replyID == replyID)) {
                  cacheReplies.add(theReply);
                  tempReplies.add(theReply);
                }
              }
            } else {
              final MiniProfile replier =
                  MiniProfile(username: replierName, imgUrl: '');
              final theReply = Reply(
                replier: replier,
                replyID: replyID,
                reply: replyDescription,
                replyDate: replyDate,
              );
              if (!cacheReplies.any((element) => element.replyID == replyID)) {
                cacheReplies.add(theReply);
                tempReplies.add(theReply);
              }
            }
          }
        }
        replies.addAll(tempReplies);
        if (theReplies.length < 10) {
          isLastPage = true;
        }
        isLoading = false;
        setState(() {});
      } else {
        final _currentPostAndComment = firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('replies')
            .orderBy('date')
            .limit(10);
        final repliesCollection = await _currentPostAndComment.get();
        final theReplies = repliesCollection.docs.reversed;
        if (theReplies.isNotEmpty) {
          for (var reply in theReplies) {
            final replyID = reply.id;
            dynamic getter(String field) => reply.get(field);
            final replierName = getter('replier');

            final replyDescription = getter('description');
            final replyDate = getter('date').toDate();
            final replierUser =
                await firestore.collection('Users').doc(replierName).get();
            if (replierUser.exists) {
              final replierImage = replierUser.get('Avatar');
              final MiniProfile replier =
                  MiniProfile(username: replierName, imgUrl: replierImage);
              final theReply = Reply(
                replier: replier,
                replyID: replyID,
                reply: replyDescription,
                replyDate: replyDate,
              );
              if (replierName == myUsername) {
                cacheReplies.add(theReply);
              } else {
                if (!cacheReplies
                    .any((element) => element.replyID == replyID)) {
                  cacheReplies.add(theReply);
                  tempReplies.add(theReply);
                }
              }
            } else {
              final MiniProfile replier =
                  MiniProfile(username: replierName, imgUrl: '');
              final theReply = Reply(
                replier: replier,
                replyID: replyID,
                reply: replyDescription,
                replyDate: replyDate,
              );
              if (!cacheReplies.any((element) => element.replyID == replyID)) {
                cacheReplies.add(theReply);
                tempReplies.add(theReply);
              }
            }
          }
        }
        if (theReplies.length < 10) {
          isLastPage = true;
        }
        replies.addAll(tempReplies);
        isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    _getReplies = getReplies(myUsername, myIMG);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreReplies(myUsername);
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
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _primaryColor = Theme.of(context).primaryColor;
    final _accentColor = Theme.of(context).accentColor;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return FutureBuilder(
      future: _getReplies,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SettingsBar('Replies'),
                const Spacer(),
                const CircularProgressIndicator(),
                const Spacer(),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SettingsBar('Replies'),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'An error has occured, please try again',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
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
                      onPressed: () => setState(() {}),
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
                  ],
                ),
                const Spacer(),
              ],
            ),
          );
        }
        return Builder(
          builder: (context) => ChangeNotifierProvider<FullCommentHelper>.value(
            value: (widget.isNotif) ? theComment!.instance : widget.instance,
            child: Builder(
              builder: (context) {
                Provider.of<FullCommentHelper>(context, listen: false)
                    .setReplies(replies);
                if (widget.isNotif) {
                  Provider.of<FullCommentHelper>(context, listen: false)
                      .setNumOfReplies(theComment!.numOfReplies);
                }
                return Builder(
                  builder: (context) {
                    final List<Reply> _replies =
                        Provider.of<FullCommentHelper>(context).replies;
                    final int _numOfReplies =
                        Provider.of<FullCommentHelper>(context).numOfReplies;
                    return Scaffold(
                      appBar: null,
                      body: SafeArea(
                        child: Container(
                          color: Colors.white,
                          child: SizedBox(
                            height: _deviceHeight,
                            width: _deviceWidth,
                            child: Column(
                              children: [
                                const SettingsBar('Replies'),
                                AddReply(
                                  postID: widget.postID,
                                  commentID: widget.commentID,
                                ),
                                const Divider(),
                                if (_numOfReplies == 0)
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        const Text(
                                          'Be the first to reply',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 21.0,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                if (_numOfReplies != 0)
                                  Expanded(
                                    child: NotificationListener<
                                        OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll.disallowGlow();
                                        return false;
                                      },
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: _replies.length + 1,
                                        itemBuilder: (_, index) {
                                          if (index == _replies.length) {
                                            if (isLoading) {
                                              return Center(
                                                child: Container(
                                                  margin: const EdgeInsets.all(
                                                      10.0),
                                                  height: 35.0,
                                                  width: 35.0,
                                                  child: Center(
                                                    child:
                                                        const CircularProgressIndicator(),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (isLastPage) {
                                              return emptyBox;
                                            }
                                          } else {
                                            final Reply _currentReply =
                                                _replies[index];
                                            final String replyID =
                                                _currentReply.replyID;
                                            final String replierUsername =
                                                _currentReply.replier.username;
                                            final String replierImg =
                                                _currentReply.replier.imgUrl;
                                            final String _reply =
                                                _currentReply.reply;
                                            final DateTime _replyDate =
                                                _currentReply.replyDate;

                                            final Widget _replyTile = ReplyTile(
                                              postID: widget.postID,
                                              commentID: widget.commentID,
                                              replyID: replyID,
                                              replierImageUrl: replierImg,
                                              replierUsername: replierUsername,
                                              reply: _reply,
                                              replyDate: _replyDate,
                                            );
                                            return _replyTile;
                                          }
                                          return emptyBox;
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

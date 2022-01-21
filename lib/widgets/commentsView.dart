import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../models/miniProfile.dart';
import '../providers/fullPostHelper.dart';
import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import 'comment.dart';
import 'addComment.dart';

class CommentsView extends StatefulWidget {
  final int numOfComments;
  final ScrollController scrollController;
  final String postId;
  final void Function(BuildContext, String) handler;
  CommentsView(
    this.numOfComments,
    this.scrollController,
    this.postId,
    this.handler,
  );

  @override
  _CommentsViewState createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final _scrollController = ScrollController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getComments;
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> removeComment({
    required String commentID,
    required void Function(String) removeComment,
    required String commenter,
    required String description,
    required int likeCount,
    required int replyCount,
    required bool containsMedia,
    required bool hasNsfw,
    required String downloadUrl,
    required DateTime commentDate,
  }) async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var batch = firestore.batch();
    final _theseComments =
        firestore.collection('Posts').doc(widget.postId).collection('comments');
    final targetComment = _theseComments.doc(commentID);
    final thisDeletedComment =
        firestore.collection('Deleted Comments').doc(commentID);
    final currentpost = firestore.collection('Posts').doc(widget.postId);
    batch.set(thisDeletedComment, {
      'post': widget.postId,
      'comment': commentID,
      'commenter': commenter,
      'description': description,
      'likeCount': likeCount,
      'replyCount': replyCount,
      'containsMedia': containsMedia,
      'downloadURL': downloadUrl,
      'hasNSFW': hasNsfw,
      'date': commentDate,
      'date deleted': DateTime.now(),
    });
    batch.delete(targetComment);
    batch.update(currentpost, {'comments': FieldValue.increment(-1)});
    batch.commit().then((value) {
      removeComment(commentID);
      EasyLoading.showSuccess(
        'Comment deleted',
        dismissOnTap: true,
      );
    });
  }

  List<Comment> commentCache = [];
  List<Comment> morecommentCache = [];

  Future<void> getComments(String myUsername, String myIMG,
      void Function(List<Comment>) setComments) async {
    List<Comment> tempComments = [];
    if (widget.numOfComments == 0) {
      return;
    } else {
      final myComments = firestore
          .collection('Posts')
          .doc(widget.postId)
          .collection('comments')
          .where('commenter', isEqualTo: myUsername);

      final _myComments = await myComments.get();
      final _myDocs = _myComments.docs.reversed;
      if (_myDocs.isNotEmpty) {
        for (var comment in _myDocs) {
          bool hasNSFW = false;
          dynamic getter(String field) => comment.get(field);
          final commentID = comment.id;
          final getMyLike = await firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .doc(commentID)
              .collection('likes')
              .doc(myUsername)
              .get();
          final FullCommentHelper _instance = FullCommentHelper();
          if (comment.data().containsKey('hasNSFW')) {
            final value = getter('hasNSFW');
            hasNSFW = value;
          }
          final String thecomment = getter('description');
          final int numOfReplies = getter('replyCount');
          final int numOfLikes = getter('likeCount');
          final bool containsMedia = getter('containsMedia');
          final String url = getter('downloadURL');
          final commentDate = getter('date').toDate();
          final bool isLiked = getMyLike.exists;
          final MiniProfile commenter =
              MiniProfile(username: myUsername, imgUrl: myIMG);
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
          tempComments.add(commentModel);
          commentCache.add(commentModel);
        }
        setComments(commentCache);
      }
      final _theseComments = firestore
          .collection('Posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('date')
          .limit(10);
      final _commentsCollection = await _theseComments.get();
      final _theComments = _commentsCollection.docs.reversed;
      if (_theComments.isNotEmpty) {
        for (var comment in _theComments) {
          bool hasNSFW = false;
          dynamic getter(String field) => comment.get(field);
          final commentID = comment.id;
          final FullCommentHelper _instance = FullCommentHelper();
          final String commenterName = getter('commenter');
          final getMyLike = await firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .doc(commentID)
              .collection('likes')
              .doc(myUsername)
              .get();
          final bool isLiked = getMyLike.exists;
          final int numOfLikes = getter('likeCount');

          final commenterUser =
              await firestore.collection('Users').doc(commenterName).get();
          if (commenterUser.exists) {
            if (commenterName == myUsername) {
            } else {
              if (comment.data().containsKey('hasNSFW')) {
                final value = getter('hasNSFW');
                hasNSFW = value;
              }
              final String _commenterImageUrl = commenterUser.get('Avatar');
              final MiniProfile commenter = MiniProfile(
                  username: commenterName, imgUrl: _commenterImageUrl);
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
              tempComments.add(commentModel);
              commentCache.add(commentModel);
            }
          } else {
            if (comment.data().containsKey('hasNSFW')) {
              final value = getter('hasNSFW');
              hasNSFW = value;
            }
            final MiniProfile commenter =
                MiniProfile(username: commenterName, imgUrl: '');
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
            tempComments.add(commentModel);
            morecommentCache.add(commentModel);
            commentCache.add(commentModel);
          }
        }
      }
      if (_theComments.length < 10) {
        isLastPage = true;
      }
      setComments(commentCache);
      setState(() {});
    }
  }

  Future<void> getMoreComments(
      String myUsername, void Function(List<Comment>) setComments) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Comment> tempComments = [];
      if (morecommentCache.isNotEmpty) {
        final lastComment = morecommentCache.last.commentID;
        final getLastComment = await firestore
            .collection('Posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(lastComment)
            .get();
        final getComments = await firestore
            .collection('Posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('date')
            .startAfterDocument(getLastComment)
            .limit(10)
            .get();
        final _theComments = getComments.docs.reversed;
        for (var comment in _theComments) {
          bool hasNSFW = false;
          dynamic getter(String field) => comment.get(field);
          final commentID = comment.id;
          final String commenterName = getter('commenter');
          final getMyLike = await firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .doc(commentID)
              .collection('likes')
              .doc(myUsername)
              .get();
          final bool isLiked = getMyLike.exists;
          final int numOfLikes = getter('likeCount');
          final FullCommentHelper _instance = FullCommentHelper();
          final commenterUser =
              await firestore.collection('Users').doc(commenterName).get();
          if (commenterUser.exists) {
            if (comment.data().containsKey('hasNSFW')) {
              final value = getter('hasNSFW');
              hasNSFW = value;
            }
            final String _commenterImageUrl = commenterUser.get('Avatar');
            final MiniProfile commenter = MiniProfile(
                username: commenterName, imgUrl: _commenterImageUrl);
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
            if (commenterName == myUsername) {
              morecommentCache.add(commentModel);
            } else {
              if (!commentCache
                  .any((element) => element.commentID == commentID)) {
                tempComments.add(commentModel);
              }
            }
          } else {
            if (comment.data().containsKey('hasNSFW')) {
              final value = getter('hasNSFW');
              hasNSFW = value;
            }
            final MiniProfile commenter =
                MiniProfile(username: commenterName, imgUrl: '');
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
            if (!commentCache
                .any((element) => element.commentID == commentID)) {
              tempComments.add(commentModel);
            }
          }
        }
        commentCache.addAll(tempComments);
        morecommentCache.addAll(tempComments);
        if (_theComments.length < 10) {
          isLastPage = true;
        }
        isLoading = false;
        setComments(commentCache);
        setState(() {});
      } else {
        final getComments = await firestore
            .collection('Posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('date')
            .limit(10)
            .get();
        final _theComments = getComments.docs.reversed;
        for (var comment in _theComments) {
          bool hasNSFW = false;
          dynamic getter(String field) => comment.get(field);
          final commentID = comment.id;
          final String commenterName = getter('commenter');
          final getMyLike = await firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .doc(commentID)
              .collection('likes')
              .doc(myUsername)
              .get();
          final bool isLiked = getMyLike.exists;
          final int numOfLikes = getter('likeCount');
          final FullCommentHelper _instance = FullCommentHelper();
          final commenterUser =
              await firestore.collection('Users').doc(commenterName).get();
          if (commenterUser.exists) {
            if (comment.data().containsKey('hasNSFW')) {
              final value = getter('hasNSFW');
              hasNSFW = value;
            }
            final String _commenterImageUrl = commenterUser.get('Avatar');
            final MiniProfile commenter = MiniProfile(
                username: commenterName, imgUrl: _commenterImageUrl);
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
            if (commenterName == myUsername) {
              morecommentCache.add(commentModel);
            } else {
              if (!commentCache
                  .any((element) => element.commentID == commentID)) {
                tempComments.add(commentModel);
              }
            }
          } else {
            if (comment.data().containsKey('hasNSFW')) {
              final value = getter('hasNSFW');
              hasNSFW = value;
            }
            final MiniProfile commenter =
                MiniProfile(username: commenterName, imgUrl: '');
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
            if (!commentCache
                .any((element) => element.commentID == commentID)) {
              tempComments.add(commentModel);
            }
          }
        }
        commentCache.addAll(tempComments);
        morecommentCache.addAll(tempComments);
        if (_theComments.length < 10) {
          isLastPage = true;
        }
        isLoading = false;
        setComments(commentCache);

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
    final setComments =
        Provider.of<FullHelper>(context, listen: false).setComments;
    _getComments = getComments(myUsername, myIMG, setComments);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreComments(myUsername, setComments);
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
    final int numOfComments = Provider.of<FullHelper>(context).getNumOfComments;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    final setComments =
        Provider.of<FullHelper>(context, listen: false).setComments;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return FutureBuilder(
      future: _getComments,
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
                    onPressed: () => setState(() => _getComments =
                        getComments(myUsername, myIMG, setComments)),
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
        return Builder(
          builder: (context) {
            return Builder(builder: (context) {
              final List<Comment> comments =
                  Provider.of<FullHelper>(context).getComments;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (numOfComments == 0)
                    Container(
                      height: deviceHeight * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const AddComment(),
                          const Divider(
                            thickness: 1.5,
                          ),
                          const Center(
                            child: const Text(
                              'Be the first to comment',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (numOfComments != 0) const AddComment(),
                  if (numOfComments != 0)
                    if (numOfComments != 0) const Divider(),
                  if (numOfComments != 0)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 10.0,
                        maxHeight: deviceHeight * 0.7,
                      ),
                      child: NotificationListener<OverscrollNotification>(
                        onNotification: (OverscrollNotification value) {
                          if (value.overscroll < 0 &&
                              widget.scrollController.offset +
                                      value.overscroll <=
                                  0) {
                            if (widget.scrollController.offset != 0)
                              widget.scrollController.jumpTo(0);
                            return true;
                          }
                          if (widget.scrollController.offset +
                                  value.overscroll >=
                              widget
                                  .scrollController.position.maxScrollExtent) {
                            if (widget.scrollController.offset !=
                                widget
                                    .scrollController.position.maxScrollExtent)
                              widget.scrollController.jumpTo(widget
                                  .scrollController.position.maxScrollExtent);
                            return true;
                          }

                          widget.scrollController.jumpTo(
                              widget.scrollController.offset +
                                  value.overscroll);
                          return true;
                        },
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 85.0),
                            controller: _scrollController,
                            itemCount: comments.length + 1,
                            itemBuilder: (_, index) {
                              if (index == comments.length) {
                                if (isLoading) {
                                  return Center(
                                    child: SizedBox(
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
                                final comment = comments[index];
                                final bool hasNSFW = comment.hasNSFW;
                                final String _commenterName =
                                    comment.commenter.username;
                                final String _commenterImage =
                                    comment.commenter.imgUrl;
                                final String? _comment = comment.comment;
                                final String _commentID = comment.commentID;
                                final DateTime _commentDate =
                                    comment.commentDate;
                                final int commentReplies = comment.numOfReplies;
                                final int commentLikes = comment.numOfLikes;
                                final bool isLiked = comment.isLiked;
                                final bool containsMedia =
                                    comment.containsMedia;
                                final downloadURL = comment.downloadURL;
                                final FullCommentHelper _instance =
                                    comment.instance;
                                final CommentTile _widget = CommentTile(
                                  commentId: _commentID,
                                  postID: widget.postId,
                                  handler2: () {
                                    removeComment(
                                      commentID: _commentID,
                                      removeComment: context
                                          .read<FullHelper>()
                                          .removeComment,
                                      commenter: _commenterName,
                                      description: _comment!,
                                      likeCount: commentLikes,
                                      replyCount: commentReplies,
                                      containsMedia: containsMedia,
                                      hasNsfw: hasNSFW,
                                      downloadUrl: downloadURL,
                                      commentDate: _commentDate,
                                    );
                                  },
                                  handler: () {
                                    (_commenterName ==
                                            context
                                                .read<MyProfile>()
                                                .getUsername)
                                        ? Navigator.pushNamed(context,
                                            RouteGenerator.myProfileScreen)
                                        : widget.handler(
                                            context,
                                            _commenterName,
                                          );
                                  },
                                  commenterImageUrl: _commenterImage,
                                  commenterUsername: _commenterName,
                                  comment: _comment!,
                                  commentDate: _commentDate,
                                  numOfReplies: commentReplies,
                                  instance: _instance,
                                  containsMedia: containsMedia,
                                  downloadURL: downloadURL,
                                  numOfLikes: commentLikes,
                                  isLiked: isLiked,
                                  hasNSFW: hasNSFW,
                                );
                                return ChangeNotifierProvider<
                                        FullCommentHelper>.value(
                                    value: _instance, child: _widget);
                              }
                              return emptyBox;
                            }),
                      ),
                    ),
                ],
              );
            });
          },
        );
      },
    );
  }
}

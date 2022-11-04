import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/comment.dart';
import '../../models/miniProfile.dart';
import '../../providers/commentProvider.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/nestedScroller.dart';
import '../common/sortationWidget.dart';
import 'addComment.dart';
import 'comment.dart';

class CommentsView extends StatefulWidget {
  final int numOfComments;
  final ScrollController scrollController;
  final String postId;
  final bool isClubPost;
  final void Function(BuildContext, String, String) handler;
  final Section section;
  final String singleCommentID;
  const CommentsView(
      {required this.numOfComments,
      required this.scrollController,
      required this.postId,
      required this.handler,
      required this.isClubPost,
      required this.section,
      required this.singleCommentID});

  @override
  _CommentsViewState createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getComments;
  Sortation sortation = Sortation.newest;
  Section section = Section.multiple;
  bool singleCommentExists = true;
  bool isLoading = false;
  bool isLastPage = false;
  /*FIX THE ABYSSMAL BUG THAT RUINS THE STATE GAINED BY COMMENTS OR REPLY
      AFTER A COMMENT OR REPLY IS ADDED,
      THE BUG OCCURS IF YOU LIKE OR REPLY TO A COMMENT/REPLY AND THEN ADD OR REMOVE 
      ANOTHER COMMENT/REPLY; THE STATE GAINED FROM LIKING/REPLYING IE: THE ADDED NUM OF LIKES
      OR THE ADDED NUM OF REPLIES IS LOST UPON ADDITION OR REMOVAL OF A COMMENT
      TO THE PREEXISTING LIST OF COMMENTS.*/
  Future<void> removeComment(
      {required String commentID,
      // required void Function(String) removeComment,
      required String myUsername,
      required dynamic myIMG,
      required dynamic clearComments,
      required dynamic setComments,
      required String commenter,
      required String description,
      required int likeCount,
      required int replyCount,
      required bool containsMedia,
      required bool hasNsfw,
      required String downloadUrl,
      required DateTime commentDate,
      required String clubName}) async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    final commenterUser = firestore.collection('Users').doc(commenter);
    final commenterDeleted =
        commenterUser.collection('Deleted Comments').doc(commentID);
    final getCommenter = await commenterUser.get();
    final commenterDocument = firestore.collection('Users').doc(commenter);
    var batch = firestore.batch();
    final _now = DateTime.now();
    final currentpost = firestore.collection('Posts').doc(widget.postId);
    final getPost = await currentpost.get();
    final _theseComments = currentpost.collection('comments');
    final _theseDeletedComments = currentpost.collection('Deleted Comments');
    final targetPostDeleted = _theseDeletedComments.doc(commentID);
    final targetComment = _theseComments.doc(commentID);
    final getTargetComment = await targetComment.get();
    Map<String, dynamic> commentData = getTargetComment.data()!;
    Map<String, dynamic> de = {'date deleted': _now, 'deletedBy': myUsername};
    commentData.addAll(de);
    final thisDeletedComment =
        firestore.collection('Deleted Comments').doc(commentID);
    batch.set(thisDeletedComment, commentData);
    final options = SetOptions(merge: true);
    batch.delete(targetComment);
    batch.set(targetPostDeleted, {'date': _now, 'by': myUsername});
    batch.update(currentpost, {'comments': FieldValue.increment(-1)});
    if (commenter != myUsername)
      batch.update(
          commenterDocument, {'CommentsRemoved': FieldValue.increment(1)});
    if (widget.isClubPost) {
      Map<String, dynamic> fields = {
        'club comments': FieldValue.increment(-1),
        'deleted club comments': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {'date': _now, 'postID': widget.postId};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'deleted club comments',
          docID: '$commentID',
          docFields: docFields);
    } else {
      Map<String, dynamic> fields = {
        'comments': FieldValue.increment(-1),
        'deleted comments': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {'date': _now, 'postID': widget.postId};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'deleted comments',
          docID: '$commentID',
          docFields: docFields);
    }
    if (getPost.exists)
      batch.set(
          currentpost, {'removed comments': FieldValue.increment(1)}, options);
    if (getCommenter.exists) {
      batch.set(
          commenterUser,
          {
            'deleted comments': FieldValue.increment(1),
            'comments': FieldValue.increment(-1)
          },
          options);
      batch.set(commenterDeleted, {'date': _now, 'by': myUsername}, options);
    }
    return batch.commit().then((value) {
      // removeComment(commentID);
      listHandler(clearComments, myUsername, myIMG, setComments, clubName);
      EasyLoading.showSuccess('Comment deleted',
          duration: const Duration(seconds: 1), dismissOnTap: true);
    });
  }

  void listHandler(dynamic clearComments, String myUsername, dynamic myIMG,
      dynamic setComments, dynamic clubName) {
    setState(() {
      isLoading = false;
      isLastPage = false;
      clearComments();
      morecommentCache.clear();
      commentCache.clear();
      _getComments = getComments(myUsername, myIMG, setComments, clubName);
    });
  }

  List<Comment> commentCache = [];
  List<Comment> morecommentCache = [];
  Future<void> initializeComment(
      {required bool isInMoreComments,
      required List<Comment> tempComments,
      required String myUsername,
      required QueryDocumentSnapshot<Map<String, dynamic>>? comment,
      required DocumentSnapshot<Map<String, dynamic>>? opComment,
      required String clubName}) async {
    bool hasNSFW = false;
    dynamic getter(String field) =>
        opComment != null ? opComment.get(field) : comment!.get(field);
    final commentID = opComment != null ? opComment.id : comment!.id;
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
    final MiniProfile commenter = MiniProfile(username: commenterName);
    final String thecomment = getter('description');
    final int numOfReplies = getter('replyCount');
    final commentDate = getter('date').toDate();
    final bool containsMedia = getter('containsMedia');
    final String url = getter('downloadURL');
    if (opComment != null) {
      if (opComment.data()!.containsKey('hasNSFW')) {
        final value = getter('hasNSFW');
        hasNSFW = value;
      }
    } else {
      if (comment!.data().containsKey('hasNSFW')) {
        final value = getter('hasNSFW');
        hasNSFW = value;
      }
    }
    final int numOfLikes = getter('likeCount');
    final FullCommentHelper _instance = FullCommentHelper();
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
        hasNSFW: hasNSFW);
    if (!tempComments.any((element) => element.commentID == commentID))
      tempComments.add(commentModel);
    if (!isInMoreComments) {
      if (!commentCache.any((element) => element.commentID == commentID))
        commentCache.add(commentModel);
      morecommentCache.add(commentModel);
    }
    // if (commenterName == myUsername) {
    //   if (isInMoreComments) morecommentCache.add(commentModel);
    // } else {
    // }
  }

  void scrollDown() => Future.delayed(
      const Duration(milliseconds: 50),
      () => widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: kThemeAnimationDuration,
          curve: Curves.easeOut));
  String sortWord() {
    if (sortation == Sortation.newest)
      return 'date';
    else
      return 'likeCount';
  }

  Future<void> getComments(String myUsername, String myIMG,
      void Function(List<Comment>) setComments, String clubName) async {
    List<Comment> tempComments = [];
    if (widget.numOfComments == 0) {
      return;
    } else {
      if (section == Section.single) {
        final targetComment = await firestore
            .collection('Posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(widget.singleCommentID)
            .get();
        final exists = targetComment.exists;
        if (exists)
          await initializeComment(
              isInMoreComments: false,
              tempComments: tempComments,
              myUsername: myUsername,
              comment: null,
              opComment: targetComment,
              clubName: clubName);
        else
          singleCommentExists = false;

        setComments(commentCache);
        setState(() {});
        scrollDown();
      } else {
        if (sortation == Sortation.mine) {
          final myComments = firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .where('commenter', isEqualTo: myUsername)
              .limit(15);
          final _myComments = await myComments.get();
          final _myDocs = _myComments.docs;
          if (_myDocs.isNotEmpty) {
            for (var comment in _myDocs)
              await initializeComment(
                  isInMoreComments: false,
                  tempComments: tempComments,
                  myUsername: myUsername,
                  comment: comment,
                  opComment: null,
                  clubName: clubName);
            if (_myDocs.length < 15) isLastPage = true;
            setComments(commentCache);
            setState(() {});
            scrollDown();
          }
        } else {
          final sorter = sortWord();
          final _theseComments = firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .orderBy(sorter, descending: true)
              .limit(15);
          final _commentsCollection = await _theseComments.get();
          final _theComments = _commentsCollection.docs;
          if (_theComments.isNotEmpty)
            for (var comment in _theComments)
              await initializeComment(
                  isInMoreComments: false,
                  tempComments: tempComments,
                  myUsername: myUsername,
                  comment: comment,
                  clubName: clubName,
                  opComment: null);
          if (_theComments.length < 15) isLastPage = true;
          setComments(commentCache);
          setState(() {});
          scrollDown();
        }
      }
    }
  }

  Future<void> getMoreComments(String myUsername,
      void Function(List<Comment>) setComments, String clubName) async {
    if (isLoading) {
    } else {
      if (section == Section.single) {
      } else {
        isLoading = true;
        setState(() {});
        List<Comment> tempComments = [];
        final sorter = sortWord();
        if (morecommentCache.isNotEmpty) {
          final lastComment = morecommentCache.last.commentID;
          final getLastComment = await firestore
              .collection('Posts')
              .doc(widget.postId)
              .collection('comments')
              .doc(lastComment)
              .get();
          final getComments = sortation == Sortation.mine
              ? await firestore
                  .collection('Posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .where('commenter', isEqualTo: myUsername)
                  .startAfterDocument(getLastComment)
                  .limit(15)
                  .get()
              : await firestore
                  .collection('Posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy(sorter, descending: true)
                  .startAfterDocument(getLastComment)
                  .limit(15)
                  .get();
          final _theComments = getComments.docs;
          for (var comment in _theComments)
            await initializeComment(
                isInMoreComments: true,
                tempComments: tempComments,
                myUsername: myUsername,
                comment: comment,
                clubName: clubName,
                opComment: null);
          commentCache.addAll(tempComments);
          morecommentCache.addAll(tempComments);
          if (_theComments.length < 15) isLastPage = true;
          isLoading = false;
          setComments(commentCache);
          setState(() {});
        } else {
          final getComments = sortation == Sortation.mine
              ? await firestore
                  .collection('Posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .where('commenter', isEqualTo: myUsername)
                  .limit(15)
                  .get()
              : await firestore
                  .collection('Posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy(sorter, descending: true)
                  .limit(15)
                  .get();
          final _theComments = getComments.docs;
          for (var comment in _theComments)
            await initializeComment(
                isInMoreComments: true,
                tempComments: tempComments,
                myUsername: myUsername,
                comment: comment,
                clubName: clubName,
                opComment: null);
          commentCache.addAll(tempComments);
          morecommentCache.addAll(tempComments);
          if (_theComments.length < 15) isLastPage = true;
          isLoading = false;
          setComments(commentCache);
          setState(() {});
        }
      }
    }
  }

  Widget buildShowAllButton(dynamic setSortation) => TextButton(
      onPressed: () => setSortation(Sortation.newest),
      child: const Text('Show all comments'));

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    final setComments =
        Provider.of<FullHelper>(context, listen: false).setComments;
    final String clubName =
        Provider.of<FullHelper>(context, listen: false).clubName;
    section = widget.section;
    _getComments = getComments(myUsername, myIMG, setComments, clubName);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreComments(myUsername, setComments, clubName);
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
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final helper = Provider.of<FullHelper>(context, listen: false);
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = myProfile.getUsername;
    final String myIMG = myProfile.getProfileImage;
    final setComments = helper.setComments;
    final clearComments = helper.clearComments;
    final bool isClubPost = helper.isClubPost;
    final bool isMod = helper.isMod;
    final String posterName = helper.posterId;
    final String clubName = helper.clubName;
    final bool isMyPost = posterName == myUsername;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    const String noComments = 'No comments found';
    void _listHandler() =>
        listHandler(clearComments, myUsername, myIMG, setComments, clubName);
    void setSortation(Sortation newSort) {
      clearComments();
      morecommentCache.clear();
      commentCache.clear();
      setState(() {
        section = Section.multiple;
        sortation = newSort;
        isLoading = false;
        isLastPage = false;
        _getComments = getComments(myUsername, myIMG, setComments, clubName);
      });
    }

    return ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: 10.0, maxHeight: deviceHeight * 0.90),
        child: FutureBuilder(
            future: _getComments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Container(
                    color: Colors.white,
                    height: deviceHeight * 0.3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const <Widget>[
                          const Center(
                              child: const CircularProgressIndicator(
                                  strokeWidth: 1.50))
                        ]));

              if (snapshot.hasError)
                return Container(
                    color: Colors.white,
                    height: deviceHeight * 0.90,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Spacer(),
                          const Text('An error has occured, please try again',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18)),
                          const SizedBox(height: 10.0),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color?>(
                                              _primaryColor),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                              const EdgeInsets.all(0.0)),
                                      shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)))),
                                  onPressed: () => setState(() => _getComments =
                                      getComments(myUsername, myIMG, setComments, clubName)),
                                  child: Center(child: Text('Retry', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))),
                          const Spacer()
                        ]));

              return Builder(builder: (context) {
                final List<Comment> comments =
                    Provider.of<FullHelper>(context).getComments;
                final int numOfComments = comments.length;
                return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (section == Section.single && !singleCommentExists)
                        Container(
                            height: deviceHeight * 0.90,
                            color: Colors.white,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AddComment(_listHandler),
                                  SortationWidget(
                                      currentSortation: sortation,
                                      setSortation: setSortation,
                                      isComments: true,
                                      isReplies: false,
                                      isPosts: false),
                                  const Center(
                                      child: const Text('Comment not found',
                                          softWrap: true,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 17.0))),
                                  Center(
                                      child: buildShowAllButton(setSortation)),
                                  const Spacer()
                                ])),
                      if (numOfComments == 0 && section != Section.single)
                        Container(
                            height: deviceHeight * 0.90,
                            color: Colors.white,
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AddComment(_listHandler),
                                  SortationWidget(
                                      currentSortation: sortation,
                                      setSortation: setSortation,
                                      isComments: true,
                                      isReplies: false,
                                      isPosts: false),
                                  const Center(
                                      child: const Text(noComments,
                                          softWrap: true,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 17.0))),
                                  const Spacer()
                                ])),
                      if (numOfComments != 0) AddComment(_listHandler),
                      if (numOfComments != 0)
                        SortationWidget(
                            currentSortation: sortation,
                            setSortation: setSortation,
                            isComments: true,
                            isReplies: false,
                            isPosts: false),
                      if (numOfComments != 0 &&
                          section == Section.single &&
                          singleCommentExists)
                        Expanded(
                            child: NestedScroller(
                                controller: widget.scrollController,
                                child: ListView(
                                    padding:
                                        const EdgeInsets.only(bottom: 85.0),
                                    controller: _scrollController,
                                    // addAutomaticKeepAlives: false,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    shrinkWrap: true,
                                    children: [
                                      ...comments.map((e) {
                                        final index = comments.indexOf(e);
                                        final comment = comments[index];
                                        final bool hasNSFW = comment.hasNSFW;
                                        final String _commenterName =
                                            comment.commenter.username;
                                        final String? _comment =
                                            comment.comment;
                                        final String _commentID =
                                            comment.commentID;
                                        final DateTime _commentDate =
                                            comment.commentDate;
                                        final int commentReplies =
                                            comment.numOfReplies;
                                        final int commentLikes =
                                            comment.numOfLikes;
                                        final bool isLiked = comment.isLiked;
                                        final bool containsMedia =
                                            comment.containsMedia;
                                        final downloadURL = comment.downloadURL;
                                        final FullCommentHelper _instance =
                                            comment.instance;
                                        return Container(
                                            key: ValueKey<String>(_commentID),
                                            child: ChangeNotifierProvider<
                                                    FullCommentHelper>.value(
                                                value: _instance,
                                                child: CommentTile(
                                                    isInReply: false,
                                                    isMyPost: isMyPost,
                                                    commentId: _commentID,
                                                    clubName: clubName,
                                                    isClubPost: isClubPost,
                                                    postID: widget.postId,
                                                    isMod: isMod,
                                                    posterName: posterName,
                                                    handler2: () {
                                                      removeComment(
                                                          myUsername:
                                                              myUsername,
                                                          myIMG: myIMG,
                                                          setComments:
                                                              setComments,
                                                          clearComments:
                                                              clearComments,
                                                          clubName: clubName,
                                                          commentID: _commentID,
                                                          // removeComment: context
                                                          //     .read<
                                                          //         FullHelper>()
                                                          //     .removeComment,
                                                          commenter:
                                                              _commenterName,
                                                          description:
                                                              _comment!,
                                                          likeCount:
                                                              commentLikes,
                                                          replyCount:
                                                              commentReplies,
                                                          containsMedia:
                                                              containsMedia,
                                                          hasNsfw: hasNSFW,
                                                          downloadUrl:
                                                              downloadURL,
                                                          commentDate:
                                                              _commentDate);
                                                    },
                                                    handler: () {
                                                      (_commenterName ==
                                                              context
                                                                  .read<
                                                                      MyProfile>()
                                                                  .getUsername)
                                                          ? Navigator.pushNamed(
                                                              context,
                                                              RouteGenerator
                                                                  .myProfileScreen)
                                                          : widget.handler(
                                                              context,
                                                              _commenterName,
                                                              myUsername);
                                                    },
                                                    commenterUsername:
                                                        _commenterName,
                                                    comment: _comment!,
                                                    commentDate: _commentDate,
                                                    numOfReplies:
                                                        commentReplies,
                                                    instance: _instance,
                                                    containsMedia:
                                                        containsMedia,
                                                    downloadURL: downloadURL,
                                                    numOfLikes: commentLikes,
                                                    isLiked: isLiked,
                                                    hasNSFW: hasNSFW)));
                                      }).toList(),
                                      const SizedBox(height: 10),
                                      buildShowAllButton(setSortation)
                                    ]))),
                      if (numOfComments != 0 && section == Section.multiple)
                        Expanded(
                            child: NestedScroller(
                                controller: widget.scrollController,
                                child: ListView.builder(
                                    padding:
                                        const EdgeInsets.only(bottom: 85.0),
                                    controller: _scrollController,
                                    itemCount: comments.length + 1,
                                    // addAutomaticKeepAlives: false,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    shrinkWrap: true,
                                    itemBuilder: (_, index) {
                                      if (index == comments.length) {
                                        if (isLoading) {
                                          return Center(
                                              child: SizedBox(
                                                  height: 35.0,
                                                  width: 35.0,
                                                  child: Center(
                                                      child:
                                                          const CircularProgressIndicator(
                                                              strokeWidth:
                                                                  1.50))));
                                        }
                                        if (isLastPage) {
                                          return emptyBox;
                                        }
                                      } else {
                                        final comment = comments[index];
                                        final bool hasNSFW = comment.hasNSFW;
                                        final String _commenterName =
                                            comment.commenter.username;
                                        final String? _comment =
                                            comment.comment;
                                        final String _commentID =
                                            comment.commentID;
                                        final DateTime _commentDate =
                                            comment.commentDate;
                                        final int commentReplies =
                                            comment.numOfReplies;
                                        final int commentLikes =
                                            comment.numOfLikes;
                                        final bool isLiked = comment.isLiked;
                                        final bool containsMedia =
                                            comment.containsMedia;
                                        final downloadURL = comment.downloadURL;
                                        final FullCommentHelper _instance =
                                            comment.instance;
                                        return Container(
                                          key: ValueKey<String>(_commentID),
                                          child: ChangeNotifierProvider<
                                                  FullCommentHelper>.value(
                                              value: _instance,
                                              child: CommentTile(
                                                  isInReply: false,
                                                  isMyPost: isMyPost,
                                                  commentId: _commentID,
                                                  clubName: clubName,
                                                  isClubPost: isClubPost,
                                                  postID: widget.postId,
                                                  isMod: isMod,
                                                  posterName: posterName,
                                                  handler2: () {
                                                    removeComment(
                                                        myUsername: myUsername,
                                                        myIMG: myIMG,
                                                        setComments:
                                                            setComments,
                                                        clearComments:
                                                            clearComments,
                                                        clubName: clubName,
                                                        commentID: _commentID,
                                                        // removeComment: context
                                                        //     .read<FullHelper>()
                                                        //     .removeComment,
                                                        commenter:
                                                            _commenterName,
                                                        description: _comment!,
                                                        likeCount: commentLikes,
                                                        replyCount:
                                                            commentReplies,
                                                        containsMedia:
                                                            containsMedia,
                                                        hasNsfw: hasNSFW,
                                                        downloadUrl:
                                                            downloadURL,
                                                        commentDate:
                                                            _commentDate);
                                                  },
                                                  handler: () {
                                                    (_commenterName ==
                                                            context
                                                                .read<
                                                                    MyProfile>()
                                                                .getUsername)
                                                        ? Navigator.pushNamed(
                                                            context,
                                                            RouteGenerator
                                                                .myProfileScreen)
                                                        : widget.handler(
                                                            context,
                                                            _commenterName,
                                                            myUsername);
                                                  },
                                                  commenterUsername:
                                                      _commenterName,
                                                  comment: _comment!,
                                                  commentDate: _commentDate,
                                                  numOfReplies: commentReplies,
                                                  instance: _instance,
                                                  containsMedia: containsMedia,
                                                  downloadURL: downloadURL,
                                                  numOfLikes: commentLikes,
                                                  isLiked: isLiked,
                                                  hasNSFW: hasNSFW)),
                                        );
                                      }
                                      return emptyBox;
                                    })))
                    ]);
              });
            }));
  }
}

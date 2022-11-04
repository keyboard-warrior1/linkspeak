// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/comment.dart';
import '../models/miniProfile.dart';
import '../models/reply.dart';
import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/common/sortationWidget.dart';
import '../widgets/fullPost/addReply.dart';
import '../widgets/fullPost/comment.dart';
import '../widgets/fullPost/replyTile.dart';

class CommentRepliesScreen extends StatefulWidget {
  final dynamic instance;
  final dynamic postID;
  final dynamic commentID;
  final dynamic isNotif;
  final dynamic commenterName;
  final dynamic isClubPost;
  final dynamic clubName;
  final dynamic posterName;
  final dynamic section;
  final dynamic singleReplyID;
  const CommentRepliesScreen(
      {required this.instance,
      required this.postID,
      required this.commentID,
      required this.isNotif,
      required this.commenterName,
      required this.clubName,
      required this.isClubPost,
      required this.posterName,
      required this.section,
      required this.singleReplyID});

  @override
  _CommentRepliesScreenState createState() => _CommentRepliesScreenState();
}

class _CommentRepliesScreenState extends State<CommentRepliesScreen> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String sessionID = '';
  String myName = '';
  late Future<void> _viewComment;
  late Future<void> _initSession;
  late Future<void> _endSession;
  late Future<void> _getReplies;
  bool isLoading = false;
  bool isLastPage = false;
  bool isMod = false;
  Sortation sortation = Sortation.newest;
  Section section = Section.multiple;
  bool singleReplyExists = true;
  List<Reply> replies = [];
  List<Reply> cacheReplies = [];
  List<Reply> morecommentCache = [];

  Comment? theComment;
  Future<void> initSession(String myUsername) async {
    var batch = firestore.batch();
    final _rightNow = DateTime.now();
    final commentsCollection =
        firestore.collection('Posts').doc(widget.postID).collection('comments');
    final thisComment = commentsCollection.doc(widget.commentID);
    final getComment = await thisComment.get();
    final exists = getComment.exists;
    if (exists) {
      final sessions = thisComment.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (!hasSession) {
        final options = SetOptions(merge: true);
        batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
        batch.set(thisComment, {'sessions': FieldValue.increment(1)}, options);
      }
    }
    return batch.commit();
  }

  Future<void> endSession(String myUsername) async {
    final _rightNow = DateTime.now();
    var batch = firestore.batch();
    final options = SetOptions(merge: true);
    final commentsCollection =
        firestore.collection('Posts').doc(widget.postID).collection('comments');
    final thisComment = commentsCollection.doc(widget.commentID);
    final getComment = await thisComment.get();
    final exists = getComment.exists;
    if (exists) {
      final commentViewers = thisComment.collection('Viewers');
      final myCommentSessions =
          commentViewers.doc(myUsername).collection('Sessions');
      final thisSession = await myCommentSessions.doc(sessionID).get();
      final thisSessionExists = thisSession.exists;
      final sessions = thisComment.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (hasSession) {
        batch.delete(sessions.doc(myUsername));
        batch.set(thisComment, {'sessions': FieldValue.increment(-1)}, options);
      }
      if (thisSessionExists) {
        batch.set(
            myCommentSessions.doc(sessionID), {'end': _rightNow}, options);
      }
    }
    return batch.commit();
  }

  Future<void> viewComment(String myUsername) async {
    var batch = firestore.batch();
    final _rightNow = DateTime.now();
    final _sessionID = _rightNow.toString();
    sessionID = _sessionID;
    final usersCollection = firestore.collection('Users');
    final commentsCollection =
        firestore.collection('Posts').doc(widget.postID).collection('comments');
    final thisComment = commentsCollection.doc(widget.commentID);
    final getComment = await thisComment.get();
    final exists = getComment.exists;
    if (exists) {
      final myUser = usersCollection.doc(myUsername);
      final myViewedComments = myUser.collection('Viewed Comments');
      final thisMyViewed = await myViewedComments.doc(widget.commentID).get();
      final alreadySeen = thisMyViewed.exists;
      final commentViewers = thisComment.collection('Viewers');
      final myViewerDoc = await commentViewers.doc(myUsername).get();
      final isViewed = myViewerDoc.exists;
      final initialdata = {
        'post': widget.postID,
        'comment': widget.commentID,
        'first viewed': _rightNow,
        'times': FieldValue.increment(1),
        'ID': myUsername,
      };
      final existingData = {
        'times': FieldValue.increment(1),
        'last viewed': _rightNow
      };
      final options = SetOptions(merge: true);
      if (alreadySeen) {
        batch.set(
            myViewedComments.doc(widget.commentID), existingData, options);
      } else {
        batch.set(myViewedComments.doc(widget.commentID), initialdata, options);
        batch.set(myUser, {'seen comments': FieldValue.increment(1)}, options);
      }
      if (isViewed) {
        batch.set(commentViewers.doc(myUsername), existingData, options);
        batch.set(
            commentViewers
                .doc(myUsername)
                .collection('Sessions')
                .doc(_sessionID),
            {'start': _rightNow},
            options);
      } else {
        batch.set(commentViewers.doc(myUsername), initialdata, options);
        batch.set(
            commentViewers
                .doc(myUsername)
                .collection('Sessions')
                .doc(_sessionID),
            {'start': _rightNow},
            options);
        batch.set(thisComment, {'viewers': FieldValue.increment(1)}, options);
      }
    }
    Map<String, dynamic> fields = {'viewed comments': FieldValue.increment(1)};
    Map<String, dynamic> docFields = {
      'post': widget.postID,
      'comment': widget.commentID,
      'date': _rightNow,
      'times': FieldValue.increment(1)
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'viewed comments',
        docID: widget.commentID,
        docFields: docFields);
    return batch.commit();
  }

  Future<void> initializeReply(
      {required bool isInMoreReplies,
      required List<Reply> tempReplies,
      required String myUsername,
      required QueryDocumentSnapshot<Map<String, dynamic>>? reply,
      required DocumentSnapshot<Map<String, dynamic>>? opReply}) async {
    final replyID = opReply != null ? opReply.id : reply!.id;
    final myLike = await firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('replies')
        .doc(replyID)
        .collection('likes')
        .doc(myUsername)
        .get();
    final likedByMe = myLike.exists;
    dynamic getter(String field) =>
        opReply != null ? opReply.get(field) : reply!.get(field);
    final replierName = getter('replier');
    final numLikes = getter('likeCount');
    final replyDate = getter('date').toDate();
    final replyDescription = getter('description');
    String mediaUrl = '';
    bool hasNSFW = false;
    bool containsMedia = false;
    if (opReply != null) {
      if (opReply.data()!.containsKey('containsMedia')) {
        containsMedia = getter('containsMedia');
        mediaUrl = getter('downloadURL');
        hasNSFW = getter('hasNSFW');
      }
    } else {
      if (reply!.data().containsKey('containsMedia')) {
        containsMedia = getter('containsMedia');
        mediaUrl = getter('downloadURL');
        hasNSFW = getter('hasNSFW');
      }
    }
    final MiniProfile replier = MiniProfile(username: replierName);
    final theReply = Reply(
        replier: replier,
        replyID: replyID,
        reply: replyDescription,
        replyDate: replyDate,
        likedByMe: likedByMe,
        numOfLikes: numLikes,
        downloadURL: mediaUrl,
        hasNSFW: hasNSFW,
        containsMedia: containsMedia);
    if (!tempReplies.any((element) => element.replyID == replyID))
      tempReplies.add(theReply);
    if (!morecommentCache.any((element) => element.replyID == replyID))
      morecommentCache.add(theReply);
    if (!cacheReplies.any((element) => element.replyID == replyID))
      cacheReplies.add(theReply);
  }

  String sortWord() {
    if (sortation == Sortation.newest)
      return 'date';
    else
      return 'likeCount';
  }

  Future<void> getReplies(String myUsername, String myIMG) async {
    if (widget.isClubPost) {
      final getModDoc = await firestore
          .collection('Clubs')
          .doc(widget.clubName)
          .collection('Moderators')
          .doc(myUsername)
          .get();
      isMod = getModDoc.exists;
    }
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
      final MiniProfile commenter = MiniProfile(username: commenterName);
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
          hasNSFW: hasNSFW);
      theComment = commentModel;
    }
    List<Reply> tempReplies = [];
    final theseReplies = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('replies');
    if (section == Section.single) {
      final targetReply = await theseReplies.doc(widget.singleReplyID).get();
      final exists = targetReply.exists;
      if (exists)
        await initializeReply(
            isInMoreReplies: false,
            tempReplies: tempReplies,
            myUsername: myUsername,
            reply: null,
            opReply: targetReply);
      else
        singleReplyExists = false;
      replies = tempReplies;
      setState(() {});
    } else {
      if (sortation == Sortation.mine) {
        final _myReplies =
            theseReplies.where('replier', isEqualTo: myUsername).limit(15);
        final _myCollection = await _myReplies.get();
        final myDocs = _myCollection.docs;
        if (myDocs.isNotEmpty)
          for (var reply in myDocs)
            await initializeReply(
                isInMoreReplies: false,
                tempReplies: tempReplies,
                myUsername: myUsername,
                reply: reply,
                opReply: null);
        if (myDocs.length < 15) isLastPage = true;
        replies = tempReplies;
        setState(() {});
      } else {
        final sorter = sortWord();
        final _currentPostAndComment =
            theseReplies.orderBy(sorter, descending: true).limit(15);
        final repliesCollection = await _currentPostAndComment.get();
        final theReplies = repliesCollection.docs;
        for (var reply in theReplies)
          await initializeReply(
              isInMoreReplies: false,
              tempReplies: tempReplies,
              myUsername: myUsername,
              reply: reply,
              opReply: null);
        if (theReplies.length < 15) isLastPage = true;
        replies = tempReplies;
        setState(() {});
      }
    }
  }

  Future<void> getMoreReplies(String myUsername) async {
    if (isLoading) {
    } else {
      if (section == Section.single) {
      } else {
        isLoading = true;
        setState(() {});
        List<Reply> tempReplies = [];
        final sorter = sortWord();
        final theseReplies = firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('replies');
        if (morecommentCache.isNotEmpty) {
          final lastReply = morecommentCache.last.replyID;
          final getLastReply = await firestore
              .collection('Posts')
              .doc(widget.postID)
              .collection('comments')
              .doc(widget.commentID)
              .collection('replies')
              .doc(lastReply)
              .get();
          final _currentPostAndComment = sortation == Sortation.mine
              ? theseReplies
                  .where('replier', isEqualTo: myUsername)
                  .startAfterDocument(getLastReply)
                  .limit(15)
              : theseReplies
                  .orderBy(sorter, descending: true)
                  .startAfterDocument(getLastReply)
                  .limit(15);
          final repliesCollection = await _currentPostAndComment.get();
          final theReplies = repliesCollection.docs;
          if (theReplies.isNotEmpty)
            for (var reply in theReplies)
              await initializeReply(
                  isInMoreReplies: true,
                  tempReplies: tempReplies,
                  myUsername: myUsername,
                  reply: reply,
                  opReply: null);
          replies.addAll(tempReplies);
          cacheReplies.addAll(tempReplies);
          morecommentCache.addAll(tempReplies);
          if (theReplies.length < 15) isLastPage = true;
          isLoading = false;
          setState(() {});
        } else {
          final _currentPostAndComment = sortation == Sortation.mine
              ? theseReplies.where('replier', isEqualTo: myUsername).limit(15)
              : theseReplies.orderBy(sorter, descending: true).limit(15);
          final repliesCollection = await _currentPostAndComment.get();
          final theReplies = repliesCollection.docs;
          if (theReplies.isNotEmpty)
            for (var reply in theReplies)
              await initializeReply(
                  isInMoreReplies: true,
                  tempReplies: tempReplies,
                  myUsername: myUsername,
                  reply: reply,
                  opReply: null);
          replies.addAll(tempReplies);
          cacheReplies.addAll(tempReplies);
          morecommentCache.addAll(tempReplies);
          if (theReplies.length < 15) isLastPage = true;
          isLoading = false;
          setState(() {});
        }
      }
    }
  }

  Widget buildShowAllButton(dynamic setSortation) => TextButton(
      onPressed: () => setSortation(Sortation.newest),
      child: const Text('Show all replies'));

  Future<void> pullRefresh(String myUsername, String myIMG) async {
    setState(() {
      replies.clear();
      cacheReplies.clear();
      morecommentCache.clear();
      isLastPage = false;
      isLoading = false;
      _getReplies = getReplies(myUsername, myIMG);
    });
  }

  listHandler(String myUsername, String myIMG) {
    setState(() {
      replies.clear();
      cacheReplies.clear();
      morecommentCache.clear();
      isLastPage = false;
      isLoading = false;
      _getReplies = getReplies(myUsername, myIMG);
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    myName = myUsername;
    section = widget.section;
    _viewComment = viewComment(myUsername);
    _initSession = initSession(myUsername);
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
    _endSession = endSession(myName);
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    const noReplies = 'No replies found';
    final myprofile = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = myprofile.getUsername;
    final String myIMG = myprofile.getProfileImage;
    void _listHandler() => listHandler(myUsername, myIMG);
    Future<void> _pullRefresh() {
      return pullRefresh(myUsername, myIMG);
    }

    return FutureBuilder(
        future: _getReplies,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
                color: Colors.white,
                child: SafeArea(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      const SettingsBar('Replies'),
                      const Spacer(),
                      const CircularProgressIndicator(strokeWidth: 1.50),
                      const Spacer()
                    ])));

          if (snapshot.hasError)
            return Container(
                color: Colors.white,
                child: SafeArea(
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
                            const Text('An error has occured, please try again',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15.0)),
                            const SizedBox(width: 10.0),
                            TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color?>(
                                            _primaryColor),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry?>(
                                      const EdgeInsets.all(0.0),
                                    ),
                                    shape: MaterialStateProperty.all<
                                            OutlinedBorder?>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)))),
                                onPressed: () => setState(() {
                                      _getReplies =
                                          getReplies(myUsername, myIMG);
                                    }),
                                child: Center(
                                    child: Text('Retry',
                                        style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold))))
                          ]),
                      const Spacer()
                    ])));

          return Builder(
              builder: (context) =>
                  ChangeNotifierProvider<FullCommentHelper>.value(
                      value: (widget.isNotif)
                          ? theComment!.instance
                          : widget.instance,
                      child: Builder(builder: (context) {
                        final helperNo = Provider.of<FullCommentHelper>(context,
                            listen: false);
                        helperNo.setReplies(replies);
                        final clearReplies = helperNo.clearReplies;
                        if (widget.isNotif)
                          helperNo.setNumOfReplies(theComment!.numOfReplies);
                        return Builder(builder: (context) {
                          final helper =
                              Provider.of<FullCommentHelper>(context);
                          final List<Reply> _replies = helper.replies;
                          final int _numOfReplies = _replies.length;
                          void setSortation(Sortation newSort) {
                            clearReplies();
                            replies.clear();
                            cacheReplies.clear();
                            morecommentCache.clear();
                            setState(() {
                              section = Section.multiple;
                              sortation = newSort;
                              isLoading = false;
                              isLastPage = false;
                              _getReplies = getReplies(myUsername, myIMG);
                            });
                          }

                          return Scaffold(
                              appBar: null,
                              backgroundColor: Colors.white,
                              floatingActionButton: (selectedAnchorMode)
                                  ? MyFab(_scrollController)
                                  : null,
                              floatingActionButtonLocation:
                                  FloatingActionButtonLocation.centerFloat,
                              body: GestureDetector(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: SafeArea(
                                      child: Container(
                                          color: Colors.white,
                                          child: SizedBox(
                                              height: _deviceHeight,
                                              width: _deviceWidth,
                                              child: Column(children: [
                                                const SettingsBar('Replies'),
                                                if (theComment != null)
                                                  CommentTile(
                                                      isInReply: true,
                                                      isMyPost: false,
                                                      postID: widget.postID,
                                                      commentId:
                                                          theComment!.commentID,
                                                      commenterUsername:
                                                          theComment!.commenter
                                                              .username,
                                                      handler2: () {},
                                                      handler: () {},
                                                      comment:
                                                          theComment!.comment,
                                                      commentDate: theComment!
                                                          .commentDate,
                                                      numOfReplies: theComment!
                                                          .numOfReplies,
                                                      instance:
                                                          theComment!.instance,
                                                      containsMedia: theComment!
                                                          .containsMedia,
                                                      downloadURL: theComment!
                                                          .downloadURL,
                                                      numOfLikes: theComment!
                                                          .numOfLikes,
                                                      isLiked:
                                                          theComment!.isLiked,
                                                      hasNSFW:
                                                          theComment!.hasNSFW,
                                                      isClubPost:
                                                          widget.isClubPost,
                                                      clubName: widget.clubName,
                                                      isMod: isMod,
                                                      posterName:
                                                          widget.posterName),
                                                AddReply(
                                                    commenterUsername:
                                                        widget.commenterName,
                                                    postID: widget.postID,
                                                    commentID: widget.commentID,
                                                    clubName: widget.clubName,
                                                    isClubPost:
                                                        widget.isClubPost,
                                                    posterUsername:
                                                        widget.posterName,
                                                    listHandler: _listHandler),
                                                SortationWidget(
                                                    currentSortation: sortation,
                                                    setSortation: setSortation,
                                                    isComments: false,
                                                    isReplies: true,
                                                    isPosts: false),
                                                if (section == Section.single &&
                                                    !singleReplyExists)
                                                  Expanded(
                                                      child: Column(
                                                          children: <Widget>[
                                                        const Text(
                                                            'Reply not found',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize:
                                                                    17.0)),
                                                        Center(
                                                            child:
                                                                buildShowAllButton(
                                                                    setSortation))
                                                      ])),
                                                if (_numOfReplies == 0 &&
                                                    section != Section.single)
                                                  Expanded(
                                                      child: Column(
                                                          children: <Widget>[
                                                        const Text(noReplies,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 17.0))
                                                      ])),
                                                if (_numOfReplies != 0 &&
                                                    section == Section.single &&
                                                    singleReplyExists)
                                                  Expanded(
                                                      child: Noglow(
                                                          child: RefreshIndicator(
                                                              backgroundColor: _primaryColor,
                                                              displacement: 2.0,
                                                              color: _accentColor,
                                                              onRefresh: _pullRefresh,
                                                              child: ListView(
                                                                  padding: EdgeInsets.only(bottom: 85.0),
                                                                  // addAutomaticKeepAlives:
                                                                  //     false,
                                                                  controller: _scrollController,
                                                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                                                  children: [
                                                                    ..._replies
                                                                        .map(
                                                                            (e) {
                                                                      var index =
                                                                          _replies
                                                                              .indexOf(e);
                                                                      var _currentReply =
                                                                          _replies[
                                                                              index];
                                                                      return Container(
                                                                          key: ValueKey<String>(_currentReply
                                                                              .replyID),
                                                                          child: ReplyTile(
                                                                              postID: widget.postID,
                                                                              commentID: widget.commentID,
                                                                              clubName: widget.clubName,
                                                                              isClubPost: widget.isClubPost,
                                                                              isMod: isMod,
                                                                              replyID: _currentReply.replyID,
                                                                              replierUsername: _currentReply.replier.username,
                                                                              reply: _currentReply.reply,
                                                                              replyDate: _currentReply.replyDate,
                                                                              numLikes: _currentReply.numOfLikes,
                                                                              liked: _currentReply.likedByMe,
                                                                              hasNSFW: _currentReply.hasNSFW,
                                                                              containsMedia: _currentReply.containsMedia,
                                                                              downloadURL: _currentReply.downloadURL,
                                                                              listHandler: _listHandler));
                                                                    }).toList(),
                                                                    const SizedBox(
                                                                        height:
                                                                            10),
                                                                    buildShowAllButton(
                                                                        setSortation)
                                                                  ])))),
                                                if (_numOfReplies != 0 &&
                                                    section == Section.multiple)
                                                  Expanded(
                                                      child: Noglow(
                                                          child: RefreshIndicator(
                                                              backgroundColor: _primaryColor,
                                                              displacement: 2.0,
                                                              color: _accentColor,
                                                              onRefresh: _pullRefresh,
                                                              child: ListView.builder(
                                                                  padding: EdgeInsets.only(bottom: 85.0),
                                                                  // addAutomaticKeepAlives: false,
                                                                  controller: _scrollController,
                                                                  itemCount: _replies.length + 1,
                                                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                                                  itemBuilder: (_, index) {
                                                                    if (index ==
                                                                        _replies
                                                                            .length) {
                                                                      if (isLoading) {
                                                                        return Center(
                                                                            child: Container(
                                                                                margin: const EdgeInsets.all(10.0),
                                                                                height: 35.0,
                                                                                width: 35.0,
                                                                                child: Center(child: const CircularProgressIndicator(strokeWidth: 1.50))));
                                                                      }
                                                                      if (isLastPage) {
                                                                        return emptyBox;
                                                                      }
                                                                    } else {
                                                                      var _currentReply =
                                                                          _replies[
                                                                              index];
                                                                      return Container(
                                                                          key: ValueKey<String>(_currentReply
                                                                              .replyID),
                                                                          child: ReplyTile(
                                                                              postID: widget.postID,
                                                                              commentID: widget.commentID,
                                                                              clubName: widget.clubName,
                                                                              isClubPost: widget.isClubPost,
                                                                              isMod: isMod,
                                                                              replyID: _currentReply.replyID,
                                                                              replierUsername: _currentReply.replier.username,
                                                                              reply: _currentReply.reply,
                                                                              replyDate: _currentReply.replyDate,
                                                                              numLikes: _currentReply.numOfLikes,
                                                                              liked: _currentReply.likedByMe,
                                                                              hasNSFW: _currentReply.hasNSFW,
                                                                              containsMedia: _currentReply.containsMedia,
                                                                              downloadURL: _currentReply.downloadURL,
                                                                              listHandler: _listHandler));
                                                                    }
                                                                    return emptyBox;
                                                                  }))))
                                              ]))))));
                        });
                      })));
        });
  }
}

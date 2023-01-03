import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/comment.dart';
import '../models/miniProfile.dart';
import '../models/screenArguments.dart';
import '../providers/commentProvider.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/sortationWidget.dart';
import 'addFlareComment.dart';
import 'flareComment.dart';

class FlareComments extends StatefulWidget {
  final String poster;
  final String collectionID;
  final String flareID;
  final int numOfComments;
  final void Function(List<Comment>) setComments;
  final FlareHelper instance;
  final Section section;
  final String singleCommentID;
  const FlareComments(
      {required this.poster,
      required this.collectionID,
      required this.flareID,
      required this.numOfComments,
      required this.setComments,
      required this.instance,
      required this.section,
      required this.singleCommentID});

  @override
  State<FlareComments> createState() => _FlareCommentsState();
}

class _FlareCommentsState extends State<FlareComments> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getComments;
  bool isLoading = false;
  bool isLastPage = false;
  Sortation sortation = Sortation.newest;
  Section section = Section.multiple;
  bool singleCommentExists = true;

  void visitHandler(String _commenterName) {
    final args = OtherProfileScreenArguments(otherProfileId: _commenterName);
    Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
        arguments: args);
  }

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
      required DateTime commentDate}) async {
    final lang = General.language(context);
    EasyLoading.show(status: lang.flares_comments1, dismissOnTap: false);
    final commenterUser = firestore.collection('Users').doc(commenter);
    final commenterDeleted =
        commenterUser.collection('Deleted Flare Comments').doc(commentID);
    final getCommenter = await commenterUser.get();
    final thisCollection = firestore
        .collection('Flares')
        .doc(widget.poster)
        .collection('collections')
        .doc(widget.collectionID);
    final collectionDeleteds = thisCollection.collection('Deleted comments');
    final thisFlare = thisCollection.collection('flares').doc(widget.flareID);
    final commenterDocument = firestore.collection('Users').doc(commenter);
    var batch = firestore.batch();
    final _now = DateTime.now();
    final getFlare = await thisFlare.get();
    final flareExists = getFlare.exists;
    final _theseComments = thisFlare.collection('comments');
    final _flareDeleteds = thisFlare.collection('deleted comments');
    final targetComment = _theseComments.doc(commentID);
    final getTargetComment = await targetComment.get();
    Map<String, dynamic> commentData = getTargetComment.data()!;
    Map<String, dynamic> de = {'date deleted': _now, 'deletedBy': myUsername};
    commentData.addAll(de);
    final thisDeletedComment =
        firestore.collection('Deleted Comments').doc(commentID);
    final options = SetOptions(merge: true);
    batch.set(thisDeletedComment, commentData);
    batch.delete(targetComment);
    batch.set(_flareDeleteds.doc(commentID),
        {'id': commentID, 'date': _now, 'deleted by': myUsername});
    batch.set(collectionDeleteds.doc(commentID), {
      'id': commentID,
      'flare': widget.flareID,
      'date': _now,
      'deleted by': myUsername
    });
    batch.set(
        thisCollection,
        {
          'deleted comments': FieldValue.increment(1),
          'comments': FieldValue.increment(-1)
        },
        options);
    if (flareExists)
      batch.set(
          thisFlare,
          {
            'comments': FieldValue.increment(-1),
            'deleted comments': FieldValue.increment(1)
          },
          options);
    if (commenter != myUsername)
      batch.update(
          commenterDocument, {'CommentsRemoved': FieldValue.increment(1)});
    Map<String, dynamic> fields = {
      'flare comments': FieldValue.increment(-1),
      'deleted flare comments': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {
      'flarePoster': widget.poster,
      'collection': widget.collectionID,
      'flare': widget.flareID,
      'comment': commentID,
      'date': _now
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'deleted flare comments',
        docID: '$commentID',
        docFields: docFields);
    batch.set(firestore.collection('Flares').doc(widget.poster),
        {'numOfComments': FieldValue.increment(-1)}, options);
    if (getCommenter.exists) {
      batch.set(
          commenterUser,
          {
            'deleted flare comments': FieldValue.increment(1),
            'flare comments': FieldValue.increment(-1)
          },
          options);
      batch.set(commenterDeleted, {'date': _now, 'by': myUsername}, options);
    }
    return batch.commit().then((value) {
      // removeComment(commentID);
      listHandler(myUsername, myIMG, setComments, clearComments);
      EasyLoading.showSuccess(lang.flares_comments2,
          duration: const Duration(seconds: 1), dismissOnTap: true);
    });
  }

  List<Comment> commentCache = [];
  List<Comment> morecommentCache = [];
  Future<void> initializeComment(
      {required bool isInMoreComments,
      required List<Comment> tempComments,
      required String myUsername,
      required QueryDocumentSnapshot<Map<String, dynamic>>? comment,
      required DocumentSnapshot<Map<String, dynamic>>? opComment}) async {
    bool hasNSFW = false;
    dynamic getter(String field) =>
        opComment != null ? opComment.get(field) : comment!.get(field);
    final commentID = opComment != null ? opComment.id : comment!.id;
    final String commenterName = getter('commenter');
    final getMyLike = await firestore
        .collection('Flares')
        .doc(widget.poster)
        .collection('collections')
        .doc(widget.collectionID)
        .collection('flares')
        .doc(widget.flareID)
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

  String sortWord() {
    if (sortation == Sortation.newest)
      return 'date';
    else
      return 'likeCount';
  }

  Future<void> getComments(String myUsername, String myIMG,
      void Function(List<Comment>) setComments) async {
    final theseComments = firestore
        .collection('Flares')
        .doc(widget.poster)
        .collection('collections')
        .doc(widget.collectionID)
        .collection('flares')
        .doc(widget.flareID)
        .collection('comments');
    List<Comment> tempComments = [];
    if (widget.numOfComments == 0) {
      return;
    } else {
      if (section == Section.single) {
        final targetComment =
            await theseComments.doc(widget.singleCommentID).get();
        final exists = targetComment.exists;
        if (exists)
          await initializeComment(
              isInMoreComments: false,
              tempComments: tempComments,
              myUsername: myUsername,
              comment: null,
              opComment: targetComment);
        else
          singleCommentExists = false;

        setComments(commentCache);
        setState(() {});
      } else {
        if (sortation == Sortation.mine) {
          final myComments =
              theseComments.where('commenter', isEqualTo: myUsername).limit(15);
          final _myComments = await myComments.get();
          final _myDocs = _myComments.docs;
          if (_myDocs.isNotEmpty)
            for (var comment in _myDocs)
              await initializeComment(
                  isInMoreComments: false,
                  tempComments: tempComments,
                  myUsername: myUsername,
                  comment: comment,
                  opComment: null);
          if (_myDocs.length < 15) isLastPage = true;
          setComments(commentCache);
          setState(() {});
        } else {
          final sorter = sortWord();
          final _theseComments =
              theseComments.orderBy(sorter, descending: true).limit(15);
          final _commentsCollection = await _theseComments.get();
          final _theComments = _commentsCollection.docs;
          if (_theComments.isNotEmpty)
            for (var comment in _theComments)
              await initializeComment(
                  isInMoreComments: false,
                  tempComments: tempComments,
                  myUsername: myUsername,
                  comment: comment,
                  opComment: null);
          if (_theComments.length < 15) isLastPage = true;
          setComments(commentCache);
          setState(() {});
        }
      }
    }
  }

  Future<void> getMoreComments(
      String myUsername, void Function(List<Comment>) setComments) async {
    final theseComments = firestore
        .collection('Flares')
        .doc(widget.poster)
        .collection('collections')
        .doc(widget.collectionID)
        .collection('flares')
        .doc(widget.flareID)
        .collection('comments');
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
          final getLastComment = await theseComments.doc(lastComment).get();
          final getComments = sortation == Sortation.mine
              ? await theseComments
                  .where('commenter', isEqualTo: myUsername)
                  .startAfterDocument(getLastComment)
                  .limit(15)
                  .get()
              : await theseComments
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
                opComment: null);
          commentCache.addAll(tempComments);
          morecommentCache.addAll(tempComments);
          if (_theComments.length < 15) isLastPage = true;
          isLoading = false;
          setComments(commentCache);
          setState(() {});
        } else {
          final getComments = sortation == Sortation.mine
              ? await theseComments
                  .where('commenter', isEqualTo: myUsername)
                  .limit(15)
                  .get()
              : await theseComments
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

  Widget buildShowAllButton(dynamic setSortation) {
    final lang = General.language(context);
    return TextButton(
        onPressed: () => setSortation(Sortation.newest),
        child:  Text(lang.flares_comments3));
  }

  void listHandler(dynamic myUsername, dynamic myIMG, dynamic setComments,
      dynamic clearComments) {
    setState(() {
      clearComments();
      morecommentCache.clear();
      commentCache.clear();
      isLoading = false;
      isLastPage = false;
      _getComments = getComments(myUsername, myIMG, setComments);
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    section = widget.section;
    _getComments = getComments(myUsername, myIMG, widget.setComments);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreComments(myUsername, widget.setComments);
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
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    final bool isMyFlare = widget.poster == myUsername;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final String noComments = lang.flares_comments4;
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5)),
                        height: 4,
                        width: 50)
                  ]),
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade200, width: 1))),
                  child: Row(children: <Widget>[
                     Text(lang.flares_comments5,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)),
                    if (widget.numOfComments > 0)
                      Text('${General.optimisedNumbers(widget.numOfComments)}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                    const Spacer(),
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black))
                  ])),
              Expanded(
                  child: FutureBuilder(
                      future: _getComments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Container(
                              height: _deviceHeight * 0.75,
                              // color: Colors.white,
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const <Widget>[
                                    const Spacer(),
                                    const Center(
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 1.50)),
                                    const Spacer()
                                  ]));

                        if (snapshot.hasError)
                          return Container(
                              height: _deviceHeight * 0.75,
                              // color: Colors.white,
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Spacer(),
                                     Text(
                                        lang.flares_commentLikes2,
                                        style:const TextStyle(
                                            color: Colors.grey, fontSize: 18)),
                                    const SizedBox(height: 10.0),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<Color?>(
                                                        _primaryColor),
                                                padding: MaterialStateProperty.all<
                                                        EdgeInsetsGeometry?>(
                                                    const EdgeInsets.all(0.0)),
                                                shape: MaterialStateProperty.all<
                                                        OutlinedBorder?>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(10.0)))),
                                            onPressed: () => setState(() => _getComments = getComments(myUsername, myIMG, widget.setComments)),
                                            child: Center(child: Text(lang.flares_commentLikes3, style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))),
                                    const Spacer()
                                  ]));

                        return ChangeNotifierProvider.value(
                            value: widget.instance,
                            child: Builder(builder: (context) {
                              final helper = Provider.of<FlareHelper>(context);
                              final helperNo = Provider.of<FlareHelper>(context,
                                  listen: false);
                              final List<Comment> comments = helper.comments;
                              final int numOfComments = comments.length;
                              final bool commentsDisabled =
                                  helper.commentsDisabled;
                              final addComment = helperNo.addComment;
                              // final _removeComment = helperNo.removeComment;
                              final setComments = helperNo.setComments;
                              final clearComments = helperNo.clearComments;
                              void _listHandler() => listHandler(myUsername,
                                  myIMG, setComments, clearComments);

                              void setSortation(Sortation newSort) {
                                clearComments();
                                morecommentCache.clear();
                                commentCache.clear();
                                setState(() {
                                  section = Section.multiple;
                                  sortation = newSort;
                                  isLoading = false;
                                  isLastPage = false;
                                  _getComments = getComments(
                                      myUsername, myIMG, setComments);
                                });
                              }

                              return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (section == Section.single &&
                                        !singleCommentExists)
                                      Container(
                                          height: _deviceHeight * 0.75,
                                          // color: Colors.white,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AddFlareComment(
                                                    poster: widget.poster,
                                                    collectionID:
                                                        widget.collectionID,
                                                    flareID: widget.flareID,
                                                    addComment: addComment,
                                                    listHandler: _listHandler,
                                                    commentsDisabled:
                                                        commentsDisabled),
                                                SortationWidget(
                                                    currentSortation: sortation,
                                                    setSortation: setSortation,
                                                    isComments: true,
                                                    isReplies: false,
                                                    isPosts: false),
                                                 Center(
                                                    child:  Text(
                                                        lang.flares_comments6,
                                                        softWrap: true,
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 17.0))),
                                                Center(
                                                    child: buildShowAllButton(
                                                        setSortation)),
                                                const Spacer()
                                              ])),
                                    if (numOfComments == 0 &&
                                        section != Section.single)
                                      Container(
                                          height: _deviceHeight * 0.75,
                                          // color: Colors.white,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AddFlareComment(
                                                    poster: widget.poster,
                                                    collectionID:
                                                        widget.collectionID,
                                                    flareID: widget.flareID,
                                                    addComment: addComment,
                                                    listHandler: _listHandler,
                                                    commentsDisabled:
                                                        commentsDisabled),
                                                SortationWidget(
                                                    currentSortation: sortation,
                                                    setSortation: setSortation,
                                                    isComments: true,
                                                    isReplies: false,
                                                    isPosts: false),
                                                 Center(
                                                    child:  Text(
                                                        noComments,
                                                        softWrap: true,
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 17.0))),
                                                const Spacer()
                                              ])),
                                    if (numOfComments != 0)
                                      AddFlareComment(
                                          poster: widget.poster,
                                          collectionID: widget.collectionID,
                                          flareID: widget.flareID,
                                          addComment: addComment,
                                          listHandler: _listHandler,
                                          commentsDisabled: commentsDisabled),
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
                                          child: ListView(
                                              // padding:
                                              //     const EdgeInsets.only(bottom: 85.0),
                                              // addAutomaticKeepAlives: false,
                                              controller: _scrollController,
                                              keyboardDismissBehavior:
                                                  ScrollViewKeyboardDismissBehavior
                                                      .onDrag,
                                              shrinkWrap: true,
                                              children: [
                                            ...comments.map((e) {
                                              final index = comments.indexOf(e);
                                              final comment = comments[index];
                                              final bool hasNSFW =
                                                  comment.hasNSFW;
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
                                              final bool isLiked =
                                                  comment.isLiked;
                                              final bool containsMedia =
                                                  comment.containsMedia;
                                              final downloadURL =
                                                  comment.downloadURL;
                                              final FullCommentHelper
                                                  _instance = comment.instance;
                                              return Container(
                                                  key: ValueKey<String>(
                                                      _commentID),
                                                  child: ChangeNotifierProvider<
                                                          FullCommentHelper>.value(
                                                      value: _instance,
                                                      child: FlareComment(
                                                          flarePoster:
                                                              widget.poster,
                                                          collectionID: widget
                                                              .collectionID,
                                                          flareID:
                                                              widget.flareID,
                                                          isMyFlare: isMyFlare,
                                                          isInReply: false,
                                                          commentId: _commentID,
                                                          handler2: () {
                                                            removeComment(
                                                                myUsername:
                                                                    myUsername,
                                                                commentID:
                                                                    _commentID,
                                                                myIMG: myIMG,
                                                                setComments:
                                                                    setComments,
                                                                clearComments:
                                                                    clearComments,
                                                                // removeComment:
                                                                //     _removeComment,
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
                                                                hasNsfw:
                                                                    hasNSFW,
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
                                                                : visitHandler(
                                                                    _commenterName);
                                                          },
                                                          commenterUsername:
                                                              _commenterName,
                                                          comment: _comment!,
                                                          commentDate:
                                                              _commentDate,
                                                          numOfReplies:
                                                              commentReplies,
                                                          instance: _instance,
                                                          containsMedia:
                                                              containsMedia,
                                                          downloadURL:
                                                              downloadURL,
                                                          numOfLikes:
                                                              commentLikes,
                                                          isLiked: isLiked,
                                                          hasNSFW: hasNSFW)));
                                            }).toList(),
                                            const SizedBox(height: 10),
                                            buildShowAllButton(setSortation)
                                          ])),
                                    if (numOfComments != 0 &&
                                        section == Section.multiple)
                                      Expanded(
                                          child: ListView.builder(
                                              // padding: const EdgeInsets.only(
                                              //     bottom: 85.0),
                                              // addAutomaticKeepAlives: false,
                                              controller: _scrollController,
                                              itemCount: comments.length + 1,
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
                                                                child: const CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        1.50))));
                                                  }
                                                  if (isLastPage) {
                                                    return emptyBox;
                                                  }
                                                } else {
                                                  final comment =
                                                      comments[index];
                                                  final bool hasNSFW =
                                                      comment.hasNSFW;
                                                  final String _commenterName =
                                                      comment
                                                          .commenter.username;
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
                                                  final bool isLiked =
                                                      comment.isLiked;
                                                  final bool containsMedia =
                                                      comment.containsMedia;
                                                  final downloadURL =
                                                      comment.downloadURL;
                                                  final FullCommentHelper
                                                      _instance =
                                                      comment.instance;
                                                  return Container(
                                                      key: ValueKey<String>(
                                                          _commentID),
                                                      child: ChangeNotifierProvider<
                                                              FullCommentHelper>.value(
                                                          value: _instance,
                                                          child: FlareComment(
                                                              flarePoster:
                                                                  widget.poster,
                                                              collectionID: widget
                                                                  .collectionID,
                                                              flareID: widget
                                                                  .flareID,
                                                              isMyFlare:
                                                                  isMyFlare,
                                                              isInReply: false,
                                                              commentId:
                                                                  _commentID,
                                                              handler2: () {
                                                                removeComment(
                                                                    myUsername:
                                                                        myUsername,
                                                                    commentID:
                                                                        _commentID,
                                                                    myIMG:
                                                                        myIMG,
                                                                    setComments:
                                                                        setComments,
                                                                    clearComments:
                                                                        clearComments,
                                                                    // removeComment:
                                                                    //     _removeComment,
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
                                                                    hasNsfw:
                                                                        hasNSFW,
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
                                                                    : visitHandler(
                                                                        _commenterName);
                                                              },
                                                              commenterUsername:
                                                                  _commenterName,
                                                              comment:
                                                                  _comment!,
                                                              commentDate:
                                                                  _commentDate,
                                                              numOfReplies:
                                                                  commentReplies,
                                                              instance:
                                                                  _instance,
                                                              containsMedia:
                                                                  containsMedia,
                                                              downloadURL:
                                                                  downloadURL,
                                                              numOfLikes:
                                                                  commentLikes,
                                                              isLiked: isLiked,
                                                              hasNSFW:
                                                                  hasNSFW)));
                                                }
                                                return emptyBox;
                                              }))
                                  ]);
                            }));
                      }))
            ]));
  }
}

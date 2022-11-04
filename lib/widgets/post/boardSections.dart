import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/comment.dart';
import '../../models/miniProfile.dart';
import '../../models/screenArguments.dart';
import '../../providers/commentProvider.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../../routes.dart';
import '../common/chatProfileImage.dart';
import '../common/noglow.dart';
import '../common/sortationWidget.dart';
import '../fullPost/addComment.dart';
import '../fullPost/comment.dart';
import '../topics/topicChip.dart';

class BoardSections extends StatefulWidget {
  final String postID;
  final bool isLikers;
  final bool isComments;
  final bool isTopics;
  final List<String> topics;
  final int numOfLikes;
  final int numOfComments;
  final String clubName;
  final bool isClubPost;
  final FullHelper instance;
  final Section section;
  final String singleCommentID;
  final void Function(List<Comment>) setComments;
  const BoardSections(
      {required this.isLikers,
      required this.postID,
      required this.isComments,
      required this.isTopics,
      required this.topics,
      required this.numOfLikes,
      required this.numOfComments,
      required this.clubName,
      required this.isClubPost,
      required this.instance,
      required this.section,
      required this.singleCommentID,
      required this.setComments});

  @override
  State<BoardSections> createState() => _BoardSectionsState();
}

class _BoardSectionsState extends State<BoardSections> {
  Widget buildTopicsSection(List<String> topics) {
    if (topics.length == 0) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    padding: const EdgeInsets.all(17.0),
                    margin: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(31.0),
                        border: Border.all(color: Colors.grey)),
                    child: const Text('No topics added',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 33.0))))
          ]);
    } else {
      return Expanded(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Wrap(children: <Widget>[
          ...topics.map((topic) {
            final String _name = topic;
            final Widget _chips = GestureDetector(
                onTap: () {
                  final screenArgs = TopicScreenArgs(_name);
                  Navigator.pushNamed(context, RouteGenerator.topicPostsScreen,
                      arguments: screenArgs);
                },
                child: TopicChip(
                    _name, null, null, Colors.white, FontWeight.normal));
            return _chips;
          })
        ]),
      ));
    }
  }

  final _likescrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool userSearchLoading = false;
  bool _clearable = false;
  late Future<void>? _getLikers;
  List<MiniProfile> uppers = [];
  List<MiniProfile> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullLikers = [];
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
        final MiniProfile _liker = MiniProfile(username: myUsername);
        uppers.insert(0, _liker);
      }
      final allPostLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .get();
      final allLikeDocs = allPostLikers.docs;
      fullLikers = allLikeDocs;
      final postLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .orderBy('date', descending: true)
          .limit(20)
          .get();
      final likersList = postLikers.docs;
      for (var liker in likersList) {
        if (liker.id == myUsername) {
        } else {
          final likerName = liker.id;
          final MiniProfile _liker = MiniProfile(username: likerName);
          uppers.add(_liker);
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
          .orderBy('date', descending: true)
          .startAfterDocument(getLastLiker)
          .limit(20)
          .get();
      final likersList = postLikers.docs;
      for (var liker in likersList) {
        if (liker.id == myUsername) {
        } else {
          final likerName = liker.id;
          final MiniProfile _liker = MiniProfile(username: likerName);
          uppers.add(_liker);
        }
      }
      if (likersList.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  void getUserResults(String name) {
    final lowerCaseName = name.toLowerCase();
    fullLikers.forEach((doc) {
      if (userSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String username = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
      }
    });
  }

  void visitProfile(String myUsername, String otherUsername) {
    if (otherUsername == myUsername) {
      Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
    } else {
      OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: otherUsername);
      Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
          arguments: args);
    }
  }

  Widget buildLikeSection() {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final themeIconHelper = Provider.of<ThemeModel>(context, listen: false);
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final File? inactiveIconPath = themeIconHelper.inactiveLikeFile;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      child: FutureBuilder(
          future: _getLikers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const <Widget>[
                    const Center(
                        child:
                            const CircularProgressIndicator(strokeWidth: 1.50))
                  ]));

            if (snapshot.hasError)
              return Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text('An error has occured, please try again',
                            style: TextStyle(color: Colors.grey, fontSize: 18)),
                        const SizedBox(height: 10.0),
                        TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      _primaryColor),
                              padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry?>(
                                const EdgeInsets.all(0.0),
                              ),
                              shape: MaterialStateProperty.all<OutlinedBorder?>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _getLikers = getLikers(myUsername, myIMG);
                              });
                            },
                            child: Center(
                                child: Text('Retry',
                                    style: TextStyle(
                                        color: _accentColor,
                                        fontWeight: FontWeight.bold))))
                      ]));

            int numOfUppers = uppers.length;
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (numOfUppers == 0)
                    Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          if (currentIconName != 'Custom')
                            Icon(currentIcon,
                                color: Colors.grey.shade400, size: 75.0),
                          if (currentIconName == 'Custom')
                            IconButton(
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () {},
                                icon: Image.file(inactiveIconPath!)),
                          const SizedBox(height: 10.0),
                          Center(
                              child: Text('Be the first to like!',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 25.0)))
                        ])),
                  if (numOfUppers != 0)
                    Expanded(
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: TextField(
                                    onChanged: (text) async {
                                      if (text.isEmpty) {
                                        if (userSearchResults.isNotEmpty)
                                          userSearchResults.clear();
                                      } else {
                                        if (!userSearchLoading) {
                                          if (userSearchResults.isNotEmpty)
                                            userSearchResults.clear();
                                        }
                                        if (!userSearchLoading) {
                                          setState(() {
                                            userSearchLoading = true;
                                          });
                                        }
                                        getUserResults(text);
                                        setState(() {
                                          userSearchLoading = false;
                                        });
                                      }
                                    },
                                    controller: _textController,
                                    decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.search,
                                            color: Colors.grey),
                                        suffixIcon: (_clearable)
                                            ? IconButton(
                                                splashColor: Colors.transparent,
                                                tooltip: 'Clear',
                                                onPressed: () {
                                                  setState(() {
                                                    _textController.clear();
                                                    userSearchResults.clear();
                                                    _clearable = false;
                                                  });
                                                },
                                                icon: const Icon(Icons.clear,
                                                    color: Colors.grey))
                                            : null,
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
                                        hintText: 'Search likes',
                                        hintStyle:
                                            const TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none)))),
                            if (_textController.value.text.isNotEmpty &&
                                userSearchResults.isEmpty &&
                                !userSearchLoading)
                              Container(
                                  child: const Center(
                                      child: const Text('No results found',
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 49, 49, 49))))),
                            if (userSearchResults.isNotEmpty &&
                                !userSearchLoading)
                              Expanded(
                                  child: Noglow(
                                      child: ListView(
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          children: <Widget>[
                                    ...userSearchResults.take(20).map((result) {
                                      final int index =
                                          userSearchResults.indexOf(result);
                                      final current = userSearchResults[index];
                                      final username = current.username;
                                      return ListTile(
                                          key: ValueKey<String>(username),
                                          horizontalTitleGap: 5,
                                          leading: ChatProfileImage(
                                              username: username,
                                              factor: 0.05,
                                              inEdit: false,
                                              asset: null),
                                          title: Text(' $username'),
                                          onTap: () {
                                            visitProfile(myUsername, username);
                                          });
                                    })
                                  ]))),
                            if (_textController.value.text.isEmpty)
                              Expanded(
                                  child: ListView.builder(
                                      padding:
                                          const EdgeInsets.only(bottom: 85.0),
                                      controller: _likescrollController,
                                      itemCount: uppers.length + 1,
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      itemBuilder: (_, index) {
                                        if (index == uppers.length) {
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
                                          final upper = uppers[index];
                                          return ListTile(
                                              key: ValueKey<String>(
                                                  upper.username),
                                              horizontalTitleGap: 5,
                                              leading: ChatProfileImage(
                                                  username: upper.username,
                                                  factor: 0.05,
                                                  inEdit: false,
                                                  asset: null),
                                              title: Text(' ${upper.username}'),
                                              onTap: () {
                                                visitProfile(
                                                    myUsername, upper.username);
                                              });
                                        }
                                        return emptyBox;
                                      }))
                          ]),
                    )
                ]);
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    if (widget.isLikers) {
      _getLikers = getLikers(myUsername, myIMG);
      _likescrollController.addListener(() {
        if (_likescrollController.position.pixels ==
            _likescrollController.position.maxScrollExtent) {
          if (isLastPage) {
          } else {
            if (!isLoading) {
              getMoreLikers(myUsername);
            }
          }
        }
      });
      _textController.addListener(() {
        if (_textController.value.text.isNotEmpty) {
          if (!_clearable)
            setState(() {
              _clearable = true;
            });
        } else {}

        if (_textController.value.text.isEmpty) {
          if (_clearable)
            setState(() {
              _clearable = false;
            });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isLikers) _likescrollController.removeListener(() {});
    _likescrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                        widget.isLikers
                            ? 'Likes  '
                            : widget.isComments
                                ? 'Comments  '
                                : 'Topics  ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)),
                    if (!widget.isTopics &&
                        ((widget.isComments && widget.numOfComments > 0) ||
                            (widget.isLikers && widget.numOfLikes > 0)))
                      Text(
                          widget.isLikers
                              ? '${General.optimisedNumbers(widget.numOfLikes)}'
                              : '${General.optimisedNumbers(widget.numOfComments)}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                    const Spacer(),
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black))
                  ])),
              if (widget.isTopics) buildTopicsSection(widget.topics),
              if (widget.isLikers) buildLikeSection(),
              if (widget.isComments)
                BoardCommentSection(
                    postID: widget.postID,
                    clubName: widget.clubName,
                    isClubPost: widget.isClubPost,
                    instance: widget.instance,
                    section: widget.section,
                    singleCommentID: widget.singleCommentID,
                    numOfComments: widget.numOfComments,
                    setComments: widget.setComments)
            ]));
  }
}

class BoardCommentSection extends StatefulWidget {
  final String postID;
  final String clubName;
  final bool isClubPost;
  final FullHelper instance;
  final Section section;
  final String singleCommentID;
  final void Function(List<Comment>) setComments;
  final int numOfComments;
  const BoardCommentSection(
      {required this.postID,
      required this.clubName,
      required this.isClubPost,
      required this.instance,
      required this.section,
      required this.singleCommentID,
      required this.numOfComments,
      required this.setComments});

  @override
  State<BoardCommentSection> createState() => _BoardCommentSectionState();
}

class _BoardCommentSectionState extends State<BoardCommentSection> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getComments;
  List<Comment> commentCache = [];
  List<Comment> morecommentCache = [];
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

  Widget buildShowAllButton(dynamic setSortation) => TextButton(
      onPressed: () => setSortation(Sortation.newest),
      child: const Text('Show all comments'));
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
    final currentpost = firestore.collection('Posts').doc(widget.postID);
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
      Map<String, dynamic> docFields = {'date': _now, 'postID': widget.postID};
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
      Map<String, dynamic> docFields = {'date': _now, 'postID': widget.postID};
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
        .doc(widget.postID)
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
      void Function(List<Comment>) setComments, String clubName) async {
    List<Comment> tempComments = [];
    if (widget.numOfComments == 0) {
      return;
    } else {
      if (section == Section.single) {
        final targetComment = await firestore
            .collection('Posts')
            .doc(widget.postID)
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
      } else {
        if (sortation == Sortation.mine) {
          final myComments = firestore
              .collection('Posts')
              .doc(widget.postID)
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
          }
        } else {
          final sorter = sortWord();
          final _theseComments = firestore
              .collection('Posts')
              .doc(widget.postID)
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
              .doc(widget.postID)
              .collection('comments')
              .doc(lastComment)
              .get();
          final getComments = sortation == Sortation.mine
              ? await firestore
                  .collection('Posts')
                  .doc(widget.postID)
                  .collection('comments')
                  .where('commenter', isEqualTo: myUsername)
                  .startAfterDocument(getLastComment)
                  .limit(15)
                  .get()
              : await firestore
                  .collection('Posts')
                  .doc(widget.postID)
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
                  .doc(widget.postID)
                  .collection('comments')
                  .where('commenter', isEqualTo: myUsername)
                  .limit(15)
                  .get()
              : await firestore
                  .collection('Posts')
                  .doc(widget.postID)
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

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    section = widget.section;
    _getComments =
        getComments(myUsername, myIMG, widget.setComments, widget.clubName);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreComments(myUsername, widget.setComments, widget.clubName);
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
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = myProfile.getUsername;
    final String myIMG = myProfile.getProfileImage;
    const String noComments = 'No comments found';
    return Expanded(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: FutureBuilder(
                future: _getComments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Container(
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
                                      getComments(myUsername, myIMG, widget.setComments, widget.clubName)),
                                  child: Center(child: Text('Retry', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))),
                          const Spacer()
                        ]));
                  return ChangeNotifierProvider.value(
                      value: widget.instance,
                      child: Builder(builder: (context) {
                        final List<Comment> comments =
                            Provider.of<FullHelper>(context).getComments;
                        final int numOfComments = comments.length;
                        final helper =
                            Provider.of<FullHelper>(context, listen: false);
                        final setComments = helper.setComments;
                        final clearComments = helper.clearComments;
                        final bool isClubPost = helper.isClubPost;
                        final bool isMod = helper.isMod;
                        final String posterName = helper.posterId;
                        final String clubName = helper.clubName;
                        final bool isMyPost = posterName == myUsername;
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
                                myUsername, myIMG, setComments, clubName);
                          });
                        }

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.90,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (section == Section.single &&
                                    !singleCommentExists)
                                  Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.90,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AddComment(() => listHandler(
                                                clearComments,
                                                myUsername,
                                                myIMG,
                                                setComments,
                                                clubName)),
                                            SortationWidget(
                                                currentSortation: sortation,
                                                setSortation: setSortation,
                                                isComments: true,
                                                isReplies: false,
                                                isPosts: false),
                                            const Center(
                                                child: const Text(
                                                    'Comment not found',
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.90,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AddComment(() => listHandler(
                                                clearComments,
                                                myUsername,
                                                myIMG,
                                                setComments,
                                                clubName)),
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
                                if (numOfComments != 0)
                                  AddComment(() => listHandler(
                                      clearComments,
                                      myUsername,
                                      myIMG,
                                      setComments,
                                      clubName)),
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
                                          padding: const EdgeInsets.only(
                                              bottom: 85.0),
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
                                          final downloadURL =
                                              comment.downloadURL;
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
                                                      postID: widget.postID,
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
                                                            commentID:
                                                                _commentID,
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
                                                            : visitHandler(
                                                                _commenterName);
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
                                      ])),
                                if (numOfComments != 0 &&
                                    section == Section.multiple)
                                  Expanded(
                                      child: ListView.builder(
                                          padding: const EdgeInsets.only(
                                              bottom: 85.0),
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
                                                    child: CommentTile(
                                                        isInReply: false,
                                                        isMyPost: isMyPost,
                                                        commentId: _commentID,
                                                        clubName: clubName,
                                                        isClubPost: isClubPost,
                                                        postID: widget.postID,
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
                                                              clubName:
                                                                  clubName,
                                                              commentID:
                                                                  _commentID,
                                                              // removeComment: context
                                                              //     .read<FullHelper>()
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
                                                        hasNSFW: hasNSFW)),
                                              );
                                            }
                                            return emptyBox;
                                          }))
                              ]),
                        );
                      }));
                })));
  }
}

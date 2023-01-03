import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import '../../widgets/common/adaptiveText.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Finders/findField.dart';

enum FindMode {
  post,
  postComment,
  postCommentReply,
  flare,
  flareComment,
  flareCommentReply
}

class FindScreen extends StatefulWidget {
  final dynamic searchMode;
  const FindScreen(this.searchMode);

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  FindMode mode = FindMode.post;
  final postIDController = TextEditingController();
  final postCommentController = TextEditingController();
  final postCommentReplyController = TextEditingController();
  final flarePosterController = TextEditingController();
  final flareCollectionController = TextEditingController();
  final flareIDController = TextEditingController();
  final flareCommentController = TextEditingController();
  final flareCommentReplyController = TextEditingController();

  String buildBarTitle() {
    final lang = General.language(context);
    switch (mode) {
      case FindMode.post:
        return lang.admin_barTitle1;
      case FindMode.postComment:
        return lang.admin_barTitle2;
      case FindMode.postCommentReply:
        return lang.admin_barTitle3;
      case FindMode.flare:
        return lang.admin_barTitle4;
      case FindMode.flareComment:
        return lang.admin_barTitle5;
      case FindMode.flareCommentReply:
        return lang.admin_barTitle6;
      default:
        return lang.admin_barTitle7;
    }
  }

  void handleFindButton() {
    String postID = postIDController.text;
    String postCommentID = postCommentController.text;
    String postCommentReplyID = postCommentReplyController.text;
    String flarePoster = flarePosterController.text;
    String collectionID = flareCollectionController.text;
    String flareID = flareIDController.text;
    String flareCommentID = flareCommentController.text;
    String flareReplyID = flareCommentReplyController.text;
    if (mode == FindMode.post) {
      var args = PostScreenArguments(
          viewMode: ViewMode.post,
          instance: null,
          previewSetstate: () {},
          isNotif: true,
          postID: postID,
          clubName: '',
          section: Section.multiple,
          singleCommentID: '');
      Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
    }
    if (mode == FindMode.postComment) {
      var args = PostScreenArguments(
          viewMode: ViewMode.post,
          instance: null,
          previewSetstate: () {},
          isNotif: true,
          postID: postID,
          clubName: '',
          section: Section.single,
          singleCommentID: postCommentID);
      Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
    }
    if (mode == FindMode.postCommentReply) {
      var args = CommentRepliesScreenArguments(
          isNotif: true,
          instance: null,
          commenterName: '',
          isClubPost: false,
          posterName: '',
          clubName: '',
          section: Section.single,
          postID: postID,
          commentID: postCommentID,
          singleReplyID: postCommentReplyID);
      Navigator.pushNamed(context, RouteGenerator.commentRepliesScreen,
          arguments: args);
    }
    if (mode == FindMode.flare) {
      var args = SingleFlareScreenArgs(
          flarePoster: flarePoster,
          collectionID: collectionID,
          flareID: flareID,
          isComment: false,
          isLike: false,
          section: Section.multiple,
          singleCommentID: '');
      Navigator.pushNamed(context, RouteGenerator.singleFlareScreen,
          arguments: args);
    }
    if (mode == FindMode.flareComment) {
      var args = SingleFlareScreenArgs(
          flarePoster: flarePoster,
          collectionID: collectionID,
          flareID: flareID,
          isComment: true,
          isLike: false,
          section: Section.single,
          singleCommentID: flareCommentID);
      Navigator.pushNamed(context, RouteGenerator.singleFlareScreen,
          arguments: args);
    }
    if (mode == FindMode.flareCommentReply) {
      var args = FlareReplyScreenArgs(
          instance: null,
          flarePoster: flarePoster,
          collectionID: collectionID,
          flareID: flareID,
          commentID: flareCommentID,
          commenterName: '',
          isNotif: true,
          section: Section.single,
          singleReplyID: flareReplyID);
      Navigator.pushNamed(context, RouteGenerator.flareCommentReplies,
          arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();
    mode = widget.searchMode;
  }

  @override
  void dispose() {
    super.dispose();
    postIDController.dispose();
    postCommentController.dispose();
    postCommentReplyController.dispose();
    flarePosterController.dispose();
    flareCollectionController.dispose();
    flareIDController.dispose();
    flareCommentController.dispose();
    flareCommentReplyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final lang = General.language(context);
    final bool flareCondition = mode == FindMode.flare ||
        mode == FindMode.flareComment ||
        mode == FindMode.flareCommentReply;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {});
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SettingsBar(buildBarTitle(), null),
                          Expanded(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Expanded(
                                      child: Noglow(
                                    child: ListView(children: <Widget>[
                                      if (mode == FindMode.post ||
                                          mode == FindMode.postComment ||
                                          mode == FindMode.postCommentReply)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField1,
                                            controller: postIDController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (mode == FindMode.postComment ||
                                          mode == FindMode.postCommentReply)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField2,
                                            controller: postCommentController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (mode == FindMode.postCommentReply)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField3,
                                            controller:
                                                postCommentReplyController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (flareCondition)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField4,
                                            controller: flarePosterController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (flareCondition)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField5,
                                            controller:
                                                flareCollectionController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (flareCondition)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField7,
                                            controller: flareIDController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (mode == FindMode.flareComment ||
                                          mode == FindMode.flareCommentReply)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField8,
                                            controller: flareCommentController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                      if (mode == FindMode.flareCommentReply)
                                        Field(
                                            validator: null,
                                            maxLength: 1000,
                                            label: lang.admin_findField9,
                                            controller:
                                                flareCommentReplyController,
                                            icon: Icons.verified,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            showSuffix: false,
                                            obscureText: false,
                                            handler: null,
                                            focusNode: null),
                                    ]),
                                  )),
                                  // const Spacer(),
                                  TextButton(
                                      style: ButtonStyle(
                                          enableFeedback: false,
                                          elevation: MaterialStateProperty.all<double?>(
                                              0.0),
                                          backgroundColor: MaterialStateProperty.all<Color?>(
                                              _primaryColor),
                                          shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: const Radius.circular(
                                                      15.0),
                                                  topLeft: const Radius.circular(
                                                      15.0))))),
                                      onPressed: handleFindButton,
                                      child: OptimisedText(
                                          minWidth: _deviceWidth * 0.5,
                                          maxWidth: _deviceWidth * 0.5,
                                          minHeight: _deviceHeight * 0.038,
                                          maxHeight: _deviceHeight * 0.038,
                                          fit: BoxFit.scaleDown,
                                          child: Text(lang.admin_findButton, style: TextStyle(fontSize: 35.0, color: _accentColor))))
                                ]),
                          )
                        ])))));
  }
}

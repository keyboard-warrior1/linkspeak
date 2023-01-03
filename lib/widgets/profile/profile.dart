import 'package:flutter/material.dart';

import 'postsAndTopicsTabs.dart';
import 'profileBox.dart';
import 'profileTabBar.dart';

class Profile extends StatefulWidget {
  final bool isMyProfile;
  final dynamic handler;
  final dynamic rightButton;
  final dynamic instance;
  const Profile(
      {required this.handler,
      required this.rightButton,
      required this.instance,
      required this.isMyProfile});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  _handleTabSelection() {
    if (_controller!.indexIsChanging) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller?.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(() {});
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.all(0.0),
        borderOnForeground: false,
        color: Colors.white,
        shadowColor: Colors.black,
        elevation: 5.0,
        semanticContainer: false,
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(55.0),
                topRight: const Radius.circular(55.0))),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: ProfileBox(
                isInPreview: false,
                showBio: true,
                isMyProfile: widget.isMyProfile,
                rightButton: widget.rightButton,
                handler: widget.handler,
                instance: widget.instance),
          ),
          Flexible(
              fit: FlexFit.loose,
              child: ProfileTabBar(_controller!, widget.isMyProfile)),
          Flexible(
              fit: FlexFit.loose,
              child: PostsAndTopics(
                  isMyProfile: widget.isMyProfile, controller: _controller))
        ]),
      );
}

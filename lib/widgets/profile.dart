import 'package:flutter/material.dart';
import 'profileBox.dart';
import 'profileTabBar.dart';
import 'postsAndTopicsTabs.dart';
import '../models/profile.dart';

class Profile extends StatefulWidget {
  final String additionalWebsite;
  final String additionalEmail;
  final String additionalNumber;
  final dynamic additionalAddress;
  final String additionalAddressName;
  final bool isMyProfile;
  final TheVisibility visibility;
  final String imageUrl;
  final String username;
  final String bio;
  final bool imLinkedToThem;
  final int numOfLinks;
  final int numOfLinkedTos;
  final int numOfPosts;
  final dynamic addTopic;
  final List<String> topicNames;
  final dynamic removeTopic;
  final dynamic handler;
  final dynamic rightButton;
  final dynamic instance;
  final ScrollController scrollController;
  final bool imBlocked;
  const Profile({
    required this.additionalWebsite,
    required this.additionalEmail,
    required this.additionalNumber,
    required this.additionalAddress,
    required this.additionalAddressName,
    required this.isMyProfile,
    required this.imLinkedToThem,
    required this.visibility,
    required this.imageUrl,
    required this.username,
    required this.bio,
    required this.numOfLinks,
    required this.numOfLinkedTos,
    required this.numOfPosts,
    required this.addTopic,
    required this.topicNames,
    required this.removeTopic,
    required this.handler,
    required this.rightButton,
    required this.scrollController,
    required this.instance,
    required this.imBlocked,
  });

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  _handleTabSelection() {
    if (_controller!.indexIsChanging) {
      setState(() {});
    }
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
  Widget build(BuildContext context) {
    final bool publicProfile = widget.visibility == TheVisibility.public;
    final ProfileBox _profileBox = ProfileBox(
      additionalWebsite: widget.additionalWebsite,
      additionalEmail: widget.additionalEmail,
      additionalNumber: widget.additionalNumber,
      additionalAddress: widget.additionalAddress,
      additionalAddressName: widget.additionalAddressName,
      isInPreview: false,
      showBio: true,
      isMyProfile: widget.isMyProfile,
      publicProfile: publicProfile,
      imLinkedToThem: widget.imLinkedToThem,
      heightRatio: 0.63,
      boxColor: Colors.white,
      rightButton: widget.rightButton,
      handler: widget.handler,
      myVisibility: widget.visibility,
      url: widget.imageUrl,
      userName: widget.username,
      bio: widget.bio,
      numOfLinks: widget.numOfLinks,
      numOfLinkedTos: widget.numOfLinkedTos,
      controller: widget.scrollController,
      instance: widget.instance,
      imBlocked: widget.imBlocked,
    );
    final ProfileTabBar _tabbar = ProfileTabBar(
      widget.numOfPosts,
      _controller!,
      widget.imBlocked,
      widget.isMyProfile,
    );
    final Widget _tabs = PostsAndTopics(
      publicProfile: publicProfile,
      imLinkedToThem: widget.imLinkedToThem,
      numOfPosts: widget.numOfPosts,
      isMyProfile: widget.isMyProfile,
      addTopic: widget.addTopic,
      removeTopic: widget.removeTopic,
      controller: _controller,
      scrollController: widget.scrollController,
    );
    final Widget _profile = Card(
      margin: const EdgeInsets.all(0.0),
      borderOnForeground: false,
      color: Colors.white,
      shadowColor: Colors.black,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(55.0),
            topRight: Radius.circular(55.0)),
      ),
      child: Column(
        children: <Widget>[
          _profileBox,
          _tabbar,
          _tabs,
        ],
      ),
    );
    return _profile;
  }
}

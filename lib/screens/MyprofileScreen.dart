import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/myProfileProvider.dart';
import '../widgets/title.dart';
import '../widgets/profile.dart';
import '../widgets/myFab.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen();
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Widget _heightBox = SizedBox(
      height: _deviceHeight * 0.07,
    );
    final Widget _title = Align(
      alignment: Alignment.topLeft,
      child: PreferredSize(
        preferredSize: Size.fromHeight(_deviceHeight * 0.05),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: const MyTitle(),
        ),
      ),
    );
    final Widget _myProfile =
        NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: ListView(
        controller: scrollController,
        children: <Widget>[
          _heightBox,
          Consumer<MyProfile>(
            builder: (ctx, profile, __) {
              final _visibility = profile.getVisibility;
              final String _imageUrl = profile.getProfileImage;
              final String _username = profile.getUsername;
              final String _bio = profile.getBio;
              final int _numOfLinks = profile.getNumberOflinks;
              final int _numOfLinkedTos = profile.getNumberOfLinkedTos;
              final int _numOfPosts = profile.getNumberOfPosts;
              final void Function(String) _addTopic = profile.addTopic;
              final List<String> _topicNames = profile.getTopics;
              final void Function(int) _removeTopic = profile.removeTopic;
              final Widget _profile = Profile(
                isMyProfile: true,
                imLinkedToThem: false,
                visibility: _visibility,
                imageUrl: _imageUrl,
                username: _username,
                bio: _bio,
                numOfLinks: _numOfLinks,
                numOfLinkedTos: _numOfLinkedTos,
                numOfPosts: _numOfPosts,
                addTopic: _addTopic,
                topicNames: _topicNames,
                removeTopic: _removeTopic,
                rightButton: null,
                handler: null,
                scrollController: scrollController,
                instance: null,
                imBlocked: false,
              );
              return _profile;
            },
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white10,
      floatingActionButton: MyFab(scrollController),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: null,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _title,
            _myProfile,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/themeModel.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/title.dart';
import '../widgets/profile.dart';
import '../widgets/myFab.dart';
import '../widgets/myProfileBanner.dart';

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
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    const Widget _myBanner = const MyProfileBanner(false);
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
          SizedBox(height: _deviceHeight * 0.12),
          Consumer<MyProfile>(
            builder: (ctx, profile, __) {
              final _visibility = profile.getVisibility;
              final String _additionalWebsite = profile.getAdditionalWebsite;
              final String _additionalEmail = profile.getAdditionalEmail;
              final String _additionalNumber = profile.getAdditionalNumber;
              final dynamic _additionalAddress = profile.getAdditionalAddress;
              final String _additionalAddressName =
                  profile.getAdditionalAddressName;
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
                additionalWebsite: _additionalWebsite,
                additionalEmail: _additionalEmail,
                additionalNumber: _additionalNumber,
                additionalAddress: _additionalAddress,
                additionalAddressName: _additionalAddressName,
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
      floatingActionButton:
          (selectedAnchorMode) ? MyFab(scrollController) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: null,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _myBanner,
            _title,
            _myProfile,
          ],
        ),
      ),
    );
  }
}

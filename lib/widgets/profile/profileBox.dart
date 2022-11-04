import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/profile.dart';
import '../../models/screenArguments.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/profileScrollProvider.dart';
import '../../routes.dart';
import '../../screens/feedScreen.dart';
import '../common/adaptiveText.dart';
import '../common/chatProfileImage.dart';
import '../common/myLinkify.dart';
import '../common/nestedScroller.dart';
import 'chatButton.dart';
import 'linkButton.dart';
import 'profileBackside.dart';
import 'qrCode.dart';

class ProfileBox extends StatefulWidget {
  final bool isMyProfile;
  final bool isInPreview;
  final bool showBio;
  final dynamic rightButton;
  final dynamic handler;
  final dynamic instance;
  const ProfileBox({
    required this.isInPreview,
    required this.showBio,
    required this.isMyProfile,
    required this.rightButton,
    required this.handler,
    required this.instance,
  });

  @override
  _ProfileBoxState createState() => _ProfileBoxState();
}

class _ProfileBoxState extends State<ProfileBox> {
  late String userName;
  late String bio;
  late int numOfLinks;
  late int numOfLinkedTos;
  late int joinedClubs;
  late String additionalWebsite;
  late String additionalEmail;
  late String additionalNumber;
  late dynamic additionalAddress;
  late String additionalAddressName;
  bool publicProfile = false;
  bool imLinkedToThem = false;
  bool imBlocked = false;
  bool isBanned = false;
  TheVisibility myVisibility = TheVisibility.public;
  double occupiedHeight = 0.0;
  late final FlipCardController _flipController;
  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[const QRcode()])));
        });
  }

  _showFullUsername(String username) {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[buildFullUsername(username)])));
        });
  }

  Widget buildFullUsername(String username) {
    final _deviceWidth = General.widthQuery(context);
    return OptimisedText(
        minWidth: _deviceWidth * 0.1,
        maxWidth: _deviceWidth,
        minHeight: 25,
        maxHeight: 50,
        fit: BoxFit.scaleDown,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(username,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18.0,
                      color: Colors.black))
            ]));
  }

  Widget? visIcon(TheVisibility myVis) {
    switch (myVis) {
      case TheVisibility.public:
        return const Icon(customIcons.MyFlutterApp.globe_no_map,
            size: 31.0, color: Colors.white);
      case TheVisibility.private:
        return const Icon(Icons.lock_outline, size: 37.0, color: Colors.white);
      default:
        const Icon(customIcons.MyFlutterApp.globe_no_map);
        break;
    }
    return null;
  }

  void _goToLinks() {
    final LinkScreenArguments args = LinkScreenArguments(
        userID: userName,
        publicProfile: publicProfile,
        imLinkedToThem: imLinkedToThem,
        instance: widget.instance);
    Navigator.pushNamed(context, RouteGenerator.linksScreen, arguments: args);
  }

  void _goToLinkedTos() {
    final LinkedToScreenArguments args = LinkedToScreenArguments(
        userID: userName,
        publicProfile: publicProfile,
        imLinkedToThem: imLinkedToThem,
        instance: widget.instance);
    Navigator.pushNamed(context, RouteGenerator.linkedToScreen,
        arguments: args);
  }

  void goToFlareProfile() {
    final FlareProfileScreenArgs args = FlareProfileScreenArgs(userName);
    Navigator.pushNamed(context, RouteGenerator.flareProfileScreen,
        arguments: args);
  }

  Widget giveStatWidget(String myUsername, int amount, String description,
      void Function() handler) {
    return OptimisedText(
        minWidth: 50,
        maxWidth: 50,
        minHeight: 100.0,
        maxHeight: 100.0,
        fit: BoxFit.none,
        child: TextButton(
            style: ButtonStyle(splashFactory: NoSplash.splashFactory),
            onPressed: (widget.isInPreview) ? () {} : handler,
            child: Column(children: <Widget>[
              Text(description,
                  style: const TextStyle(color: Colors.black, fontSize: 18.0)),
              const SizedBox(height: 5.0),
              if ((!imBlocked && !isBanned) ||
                  myUsername.startsWith('Linkspeak'))
                Text(General.optimisedNumbers(amount),
                    style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold))
            ])));
  }

  @override
  void initState() {
    super.initState();
    _flipController = FlipCardController();
  }

  @override
  Widget build(BuildContext context) {
    late ScrollController controller;
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = General.widthQuery(context);
    Color _primarySwatch = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    const SizedBox _heightbox1 = SizedBox(height: 25.0);
    const SizedBox _heightBox = SizedBox(height: 35.0);
    const SizedBox _widthBox = const SizedBox(width: 30.0);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    bool hasSpotlight =
        Provider.of<MyProfile>(context, listen: false).getHasSpotlight;
    bool hasUnseen = false;
    if (widget.isMyProfile) {
      final MyProfile myProfile = Provider.of<MyProfile>(context);
      controller = Provider.of<ProfileScrollProvider>(context, listen: false)
          .profileScrollController;
      userName = myProfile.getUsername;
      bio = myProfile.getBio;
      numOfLinks = myProfile.getNumberOflinks;
      numOfLinkedTos = myProfile.getNumberOfLinkedTos;
      myVisibility = myProfile.getVisibility;
      joinedClubs = myProfile.joinedClubs;
      additionalWebsite = myProfile.getAdditionalWebsite;
      additionalEmail = myProfile.getAdditionalEmail;
      additionalNumber = myProfile.getAdditionalNumber;
      additionalAddress = myProfile.getAdditionalAddress;
      additionalAddressName = myProfile.getAdditionalAddressName;
    } else {
      final OtherProfile myProfile = Provider.of<OtherProfile>(context);
      controller = myProfile.getProfileScrollController;
      userName = myProfile.getUsername;
      bio = myProfile.getBio;
      numOfLinks = myProfile.getNumberOflinks;
      numOfLinkedTos = myProfile.getNumberOfLinkedTos;
      joinedClubs = myProfile.getJoinedClubs;
      publicProfile = myProfile.getVisibility == TheVisibility.public;
      imLinkedToThem = myProfile.imLinkedToThem;
      imBlocked = myProfile.imBlocked;
      isBanned = myProfile.isBanned;
      myVisibility = myProfile.getVisibility;
      additionalWebsite = myProfile.getAdditionalWebsite;
      additionalEmail = myProfile.getAdditionalEmail;
      additionalNumber = myProfile.getAdditionalNumber;
      additionalAddress = myProfile.getAdditionalAddress;
      additionalAddressName = myProfile.getAdditionalAddressName;
    }
    String displayUsername = userName;
    if (userName.length > 15)
      displayUsername = '${userName.substring(0, 15)}..';
    if (!widget.isMyProfile && !widget.isInPreview) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
      hasSpotlight =
          Provider.of<OtherProfile>(context, listen: false).getHasSpotlight;
      hasUnseen =
          Provider.of<OtherProfile>(context, listen: false).getHasUnseen;
    }
    void _goToClubs() {
      if (widget.isMyProfile) {
        Navigator.pushNamed(context, RouteGenerator.myJoinedClubs);
      } else {
        if (myUsername.startsWith('Linkspeak')) {
          final OtherJoinedClubsArgs args = OtherJoinedClubsArgs(userName);
          Navigator.pushNamed(context, RouteGenerator.otherJoinedClubs,
              arguments: args);
        }
      }
    }

    return FlipCard(
      flipOnTouch: (widget.isInPreview)
          ? false
          : (widget.isMyProfile)
              ? (additionalWebsite != '' ||
                      additionalEmail != '' ||
                      additionalNumber != '' ||
                      additionalAddress != '')
                  ? true
                  : false
              : (imBlocked || isBanned)
                  ? (myUsername.startsWith('Linkspeak'))
                      ? true
                      : false
                  : (!publicProfile && !imLinkedToThem)
                      ? (myUsername.startsWith('Linkspeak'))
                          ? true
                          : false
                      : (additionalWebsite != '' ||
                              additionalEmail != '' ||
                              additionalNumber != '' ||
                              additionalAddress != '')
                          ? true
                          : false,
      controller: _flipController,
      front: MeasuredSize(
        onChange: (size) {
          setState(() {
            occupiedHeight = size.height;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: const Radius.circular(
                30.50,
              ),
              topRight: const Radius.circular(
                30.50,
              ),
            ),
            border: (widget.isInPreview)
                ? Border.all(
                    width: 0.50,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0)),
            child: Container(
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: _deviceHeight * 0.35,
                    maxHeight: _deviceHeight * 1.2),
                child: LimitedBox(
                  maxHeight: widget.isInPreview ? _deviceHeight * 0.4 : 0,
                  maxWidth: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          color: _primarySwatch,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'back',
                                  icon: const Icon(
                                      customIcons.MyFlutterApp.curve_arrow),
                                  onPressed: () {
                                    if (widget.isInPreview)
                                      FeedScreen.sheetOpen = false;
                                    Navigator.pop(context);
                                  },
                                  color: Colors.white,
                                ),
                                if ((!imBlocked && !isBanned) ||
                                    myUsername.startsWith('Linkspeak'))
                                  visIcon(myVisibility)!,
                                (widget.isMyProfile)
                                    ? IconButton(
                                        tooltip: 'More',
                                        icon: const Icon(Icons.menu_rounded,
                                            size: 31.0),
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              RouteGenerator.settingsScreen);
                                        },
                                      )
                                    : GestureDetector(
                                        onTap: widget.handler,
                                        child: widget.rightButton)
                              ])),
                      if ((!widget.isInPreview && widget.isMyProfile) ||
                          (!widget.isInPreview &&
                              !widget.isMyProfile &&
                              publicProfile &&
                              !imBlocked &&
                              !isBanned &&
                              hasSpotlight) ||
                          (!widget.isInPreview &&
                              !widget.isMyProfile &&
                              !publicProfile &&
                              !imBlocked &&
                              !isBanned &&
                              imLinkedToThem &&
                              hasSpotlight) ||
                          (!widget.isInPreview &&
                              hasSpotlight &&
                              myUsername.startsWith('Linkspeak')))
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  decoration: BoxDecoration(
                                      color: _primarySwatch,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft:
                                              const Radius.circular(25.0),
                                          bottomRight:
                                              const Radius.circular(25.0))),
                                  child: IconButton(
                                      icon: Stack(children: <Widget>[
                                        Positioned.fill(
                                            child: Icon(
                                                customIcons
                                                    .MyFlutterApp.spotlight,
                                                color: _accentColor,
                                                size: _deviceWidth < 480
                                                    ? 20
                                                    : 30.0)),
                                        if (!widget.isMyProfile && hasUnseen)
                                          Positioned(
                                              top: 3,
                                              right: 3,
                                              child: Container(
                                                  height: _deviceWidth < 480
                                                      ? 7
                                                      : 10.0,
                                                  width: _deviceWidth < 480
                                                      ? 7
                                                      : 10.0,
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .lightGreenAccent
                                                          .shade400,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                      shape: BoxShape.circle))),
                                      ]),
                                      onPressed: goToFlareProfile))
                            ]),
                      if (widget.showBio) _heightbox1,
                      if (!widget.showBio) const Spacer(),
                      if (!widget.isInPreview)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: widget.isMyProfile
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      padding: const EdgeInsets.only(left: 7.0),
                                      child: ChatProfileImage(
                                          username: userName,
                                          factor: 0.15,
                                          inEdit: false,
                                          asset: null,
                                          inOtherProfile: !widget.isMyProfile)),
                                  if (!widget.isMyProfile)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: _deviceHeight * 0.20,
                                          maxHeight: _deviceHeight * 0.20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          const Spacer(),
                                          OptimisedText(
                                            minWidth: _deviceWidth * 0.55,
                                            maxWidth: _deviceWidth * 0.55,
                                            minHeight: _deviceHeight * 0.05,
                                            maxHeight: _deviceHeight * 0.10,
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if ((imBlocked ||
                                                              isBanned) &&
                                                          !myUsername.startsWith(
                                                              'Linkspeak')) {
                                                      } else {
                                                        if (userName.length >
                                                            15)
                                                          _showFullUsername(
                                                              userName);
                                                      }
                                                    },
                                                    child: Text(
                                                      ((imBlocked ||
                                                                  isBanned) &&
                                                              !myUsername
                                                                  .startsWith(
                                                                      'Linkspeak'))
                                                          ? 'User'
                                                          : displayUsername,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 22.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (!widget.isInPreview)
                                                  const ChatButton(),
                                              ],
                                            ),
                                          ),
                                          if (!widget.isInPreview)
                                            const LinkButton(),
                                          const Spacer(),
                                        ],
                                      ),
                                    ),
                                  if (widget.isMyProfile)
                                    OptimisedText(
                                      minWidth: _deviceWidth * 0.55,
                                      maxWidth: _deviceWidth * 0.55,
                                      minHeight: _deviceHeight * 0.1,
                                      maxHeight: _deviceHeight * 0.1,
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (userName.length > 15)
                                                    _showFullUsername(userName);
                                                },
                                                child: Text(displayUsername,
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 22.0,
                                                        color: Colors.black)),
                                              )),
                                          IconButton(
                                            onPressed: () =>
                                                _showDialog(context),
                                            icon: const Icon(
                                              Icons.qr_code_2,
                                              color: Colors.black,
                                              size: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (widget.isMyProfile) const Spacer(flex: 6),
                                ],
                              ),
                              if (widget.showBio && widget.isMyProfile)
                                _heightBox,
                              if (!widget.showBio) const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  giveStatWidget(myUsername, numOfLinks,
                                      'Links', _goToLinks),
                                  _widthBox,
                                  giveStatWidget(myUsername, numOfLinkedTos,
                                      'Linked', _goToLinkedTos),
                                  _widthBox,
                                  giveStatWidget(myUsername, joinedClubs,
                                      'Clubs', _goToClubs),
                                ],
                              ),
                              if (!widget.showBio) const Spacer(),
                              if (widget.showBio) _heightBox,
                              if (widget.showBio &&
                                  ((!imBlocked && !isBanned) ||
                                      myUsername.startsWith('Linkspeak')))
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: _deviceHeight * 0.01,
                                      maxHeight: _deviceHeight * 0.50,
                                      minWidth: _deviceWidth * 0.10,
                                      maxWidth: _deviceWidth * 0.90),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: NestedScroller(
                                      controller: controller,
                                      child: ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: <Widget>[
                                          MyLinkify(
                                              text: bio,
                                              maxLines: 500,
                                              style: const TextStyle(
                                                  fontFamily: 'Roboto',
                                                  wordSpacing: 1.5,
                                                  fontSize: 18.0),
                                              textDirection: null),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.showBio) _heightBox,
                              if (!widget.showBio) const Spacer(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      back: (widget.isInPreview)
          ? Container()
          : BackSide(
              givenHeight: occupiedHeight, isMyProfile: widget.isMyProfile),
    );
  }
}

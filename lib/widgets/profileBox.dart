import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../screens/feedScreen.dart';
import '../models/profile.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import 'profileImage.dart';
import 'adaptiveText.dart';
import 'linkButton.dart';
import 'chatButton.dart';
import 'qrCode.dart';

class ProfileBox extends StatefulWidget {
  final bool isInPreview;
  final bool showBio;
  final bool isMyProfile;
  final bool? publicProfile;
  final bool? imLinkedToThem;
  final double heightRatio;
  final Color boxColor;
  final dynamic rightButton;
  final dynamic handler;
  final TheVisibility myVisibility;
  final String url;
  final String userName;
  final String bio;
  final int numOfLinks;
  final int numOfLinkedTos;
  final ScrollController? controller;
  final dynamic instance;
  final bool imBlocked;
  const ProfileBox({
    required this.isInPreview,
    required this.showBio,
    required this.isMyProfile,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.heightRatio,
    required this.boxColor,
    required this.rightButton,
    required this.handler,
    required this.myVisibility,
    required this.url,
    required this.userName,
    required this.bio,
    required this.numOfLinks,
    required this.numOfLinkedTos,
    required this.controller,
    required this.instance,
    required this.imBlocked,
  });

  @override
  _ProfileBoxState createState() => _ProfileBoxState();
}

class _ProfileBoxState extends State<ProfileBox> {
  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const QRcode(),
                ],
              ),
            ),
          );
        });
  }

  String _optimisedNumbers(num value) {
    if (value < 1000) {
      return '${value.toString()}';
    } else if (value >= 1000) {
      num dividedVal = value / 1000;
      return '${dividedVal.toStringAsFixed(1)}K';
    } else if (value >= 1000000) {
      num dividedVal = value / 1000000;
      return '${dividedVal.toStringAsFixed(1)}M';
    } else if (value >= 1000000000) {
      num dividedVal = value / 1000000000;
      return '${dividedVal.toStringAsFixed(1)}B';
    }
    return 'null';
  }

  Widget? visIcon(TheVisibility myVis) {
    switch (myVis) {
      case TheVisibility.public:
        return const Icon(
          customIcons.MyFlutterApp.globe_no_map,
          size: 31.0,
          color: Colors.white,
        );
      case TheVisibility.private:
        return const Icon(
          Icons.lock_outline,
          size: 37.0,
          color: Colors.white,
        );
      default:
        const Icon(customIcons.MyFlutterApp.globe_no_map);
        break;
    }
    return null;
  }

  void _goToLinks() {
    final LinkScreenArguments args = LinkScreenArguments(
      userID: widget.userName,
      publicProfile: widget.publicProfile,
      imLinkedToThem: widget.imLinkedToThem,
      instance: widget.instance,
    );
    Navigator.pushNamed(
      context,
      RouteGenerator.linksScreen,
      arguments: args,
    );
  }

  void _goToLinkedTos() {
    final LinkedToScreenArguments args = LinkedToScreenArguments(
      userID: widget.userName,
      publicProfile: widget.publicProfile,
      imLinkedToThem: widget.imLinkedToThem,
      instance: widget.instance,
    );
    Navigator.pushNamed(
      context,
      RouteGenerator.linkedToScreen,
      arguments: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = _querySize.width;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    const SizedBox _heightbox1 = SizedBox(height: 25.0);
    const SizedBox _heightBox = SizedBox(height: 50.0);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final List<Widget> _stuff = [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding:
                (widget.isInPreview) ? const EdgeInsets.only(left: 7.0) : null,
            child: GestureDetector(
              onTap: () {
                if (widget.isInPreview && !widget.isMyProfile) {
                  widget.handler();
                }
              },
              child: ProfileImage(
                username: widget.userName,
                url: widget.url,
                factor: 0.17,
                inEdit: false,
                asset: null,
              ),
            ),
          ),
          if (!widget.isMyProfile)
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _deviceHeight * 0.20,
                maxHeight: _deviceHeight * 0.20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              if (widget.isInPreview) {
                                widget.handler();
                              }
                            },
                            child: Text(
                              (widget.imBlocked &&
                                      !myUsername.startsWith('Linkspeak'))
                                  ? 'User'
                                  : widget.userName,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 27.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        if (!widget.isInPreview) const ChatButton(),
                      ],
                    ),
                  ),
                  if (!widget.isInPreview) const LinkButton(),
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
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      widget.userName,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 27.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (widget.isMyProfile && !widget.isInPreview)
                    const SizedBox(width: 5.0),
                  if (widget.isMyProfile && !widget.isInPreview)
                    IconButton(
                      onPressed: () => _showDialog(context),
                      icon: const Icon(
                        Icons.qr_code_2,
                        color: Colors.black,
                        size: 25.0,
                      ),
                    ),
                ],
              ),
            ),
          if (widget.isMyProfile)
            const Spacer(
              flex: 6,
            ),
        ],
      ),
      if (widget.showBio) _heightBox,
      if (!widget.showBio) const Spacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          OptimisedText(
            minWidth: _deviceWidth * 0.45,
            maxWidth: _deviceWidth * 0.45,
            minHeight: 50.0,
            maxHeight: 80.0,
            fit: BoxFit.scaleDown,
            child: TextButton(
              style: ButtonStyle(splashFactory: NoSplash.splashFactory),
              onPressed: (widget.isInPreview) ? () {} : _goToLinks,
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Links ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                    if (!widget.imBlocked || myUsername.startsWith('Linkspeak'))
                      TextSpan(
                        text: _optimisedNumbers(widget.numOfLinks),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          OptimisedText(
            minWidth: _deviceWidth * 0.45,
            maxWidth: _deviceWidth * 0.45,
            minHeight: 50.0,
            maxHeight: 80.0,
            fit: BoxFit.scaleDown,
            child: TextButton(
              style: ButtonStyle(splashFactory: NoSplash.splashFactory),
              onPressed: (widget.isInPreview) ? () {} : _goToLinkedTos,
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Linked ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                    if (!widget.imBlocked || myUsername.startsWith('Linkspeak'))
                      TextSpan(
                        text: _optimisedNumbers(widget.numOfLinkedTos),
                        style: const TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      if (!widget.showBio) const Spacer(),
      if (widget.showBio) _heightBox,
      if (widget.showBio &&
          (!widget.imBlocked || myUsername.startsWith('Linkspeak')))
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: _deviceHeight * 0.10,
            maxHeight: _deviceHeight * 0.50,
            minWidth: _deviceWidth * 0.10,
            maxWidth: _deviceWidth * 0.90,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: NotificationListener<OverscrollNotification>(
              onNotification: (OverscrollNotification value) {
                if (value.overscroll < 0 &&
                    widget.controller!.offset + value.overscroll <= 0) {
                  if (widget.controller!.offset != 0)
                    widget.controller!.jumpTo(0);
                  return true;
                }
                if (widget.controller!.offset + value.overscroll >=
                    widget.controller!.position.maxScrollExtent) {
                  if (widget.controller!.offset !=
                      widget.controller!.position.maxScrollExtent)
                    widget.controller!
                        .jumpTo(widget.controller!.position.maxScrollExtent);
                  return true;
                }
                widget.controller!
                    .jumpTo(widget.controller!.offset + value.overscroll);
                return true;
              },
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: <Widget>[
                  AutoSizeText(
                    widget.bio,
                    minFontSize: 17.0,
                    maxFontSize: 35.0,
                    maxLines: 500,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      wordSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (widget.showBio) _heightBox,
      if (!widget.showBio) const Spacer(),
    ];
    return Container(
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
          topLeft: const Radius.circular(
            30.0,
          ),
          topRight: const Radius.circular(
            30.0,
          ),
        ),
        child: Container(
          color: widget.boxColor,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _deviceHeight * 0.35,
              maxHeight: _deviceHeight * 1.2,
            ),
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
                            customIcons.MyFlutterApp.curve_arrow,
                          ),
                          onPressed: () {
                            if (widget.isInPreview)
                              FeedScreen.sheetOpen = false;
                            Navigator.pop(context);
                          },
                          color: Colors.white,
                        ),
                        if (!widget.imBlocked ||
                            myUsername.startsWith('Linkspeak'))
                          visIcon(widget.myVisibility)!,
                        (widget.isMyProfile)
                            ? IconButton(
                                tooltip: 'More',
                                icon: const Icon(
                                  Icons.menu_rounded,
                                  size: 31.0,
                                ),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteGenerator.settingsScreen,
                                  );
                                },
                              )
                            : GestureDetector(
                                onTap: widget.handler,
                                child: widget.rightButton),
                      ],
                    ),
                  ),
                  if (widget.showBio) _heightbox1,
                  if (!widget.showBio) const Spacer(),
                  if (!widget.isInPreview)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[..._stuff],
                      ),
                    ),
                  if (widget.isInPreview) ..._stuff,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

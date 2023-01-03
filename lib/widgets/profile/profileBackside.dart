import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
// import '../../routes.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/profileScrollProvider.dart';
import '../common/adaptiveText.dart';
import '../common/nestedScroller.dart';
import 'profileBackAddress.dart';
import 'profileBackLink.dart';
import 'profileMap.dart';

class BackSide extends StatefulWidget {
  final bool isMyProfile;
  final double givenHeight;
  const BackSide({required this.givenHeight, required this.isMyProfile});

  @override
  State<BackSide> createState() => _BackSideState();
}

class _BackSideState extends State<BackSide> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String additionalWebsite;
  late String additionalEmail;
  late String additionalNumber;
  late dynamic additionalAddress;
  late String additionalAddressName;
  Future<void> websiteHandler(
      String url, Color primaryColor, Color accentColor) async {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    Future.delayed(const Duration(seconds: 1), () {
      return myUrls.add({'url': url, 'date': DateTime.now()});
    });
    // final BrowserScreenArgs args = BrowserScreenArgs(url);
    // Navigator.pushNamed(context, RouteGenerator.browser, arguments: args);
    General.openBrowser(url, primaryColor, accentColor);
  }

  Future<void> websiteCopyHandler(String url) async {
    final lang = General.language(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(ClipboardData(text: '$url'));
    await myUrls.add({'url': url, 'date': DateTime.now()});
    EasyLoading.show(
        status: lang.widgets_common7,
        dismissOnTap: true,
        indicator: Icon(Icons.copy, color: Colors.white));
  }

  Future<void> phoneCopyHandler(String number) async {
    final lang = General.language(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(ClipboardData(text: '$number'));
    await myUrls.add({'url': number, 'date': DateTime.now()});
    EasyLoading.show(
        status: lang.widgets_common7,
        dismissOnTap: true,
        indicator: Icon(Icons.copy, color: Colors.white));
  }

  Future<void> emailHandler(String email) async {
    final lang = General.language(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(ClipboardData(text: '$email'));
    await myUrls.add({'url': email, 'date': DateTime.now()});
    EasyLoading.show(
        status: lang.widgets_common7,
        dismissOnTap: true,
        indicator: const Icon(Icons.copy, color: Colors.white));
  }

  Widget buildItem(
          {required String label,
          required IconData icon,
          required String value,
          required String textValue,
          required dynamic copyHandler,
          required dynamic handler,
          required Future<void> goBrowser(String url, Color prim, Color acc)?,
          required Color primarySwatch,
          required Color accentColor,
          required double deviceHeight,
          required double deviceWidth}) =>
      Container(
          margin: const EdgeInsets.only(top: 8.0, right: 25.0, bottom: 5.0),
          decoration: BoxDecoration(
              color: primarySwatch,
              borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(50.0),
                  bottomRight: const Radius.circular(50.0))),
          child: ListTile(
              leading: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Icon(icon, color: Colors.white),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                  ]),
              title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                            style: const ButtonStyle(
                                splashFactory: NoSplash.splashFactory),
                            onLongPress: () {
                              copyHandler('$value');
                            },
                            onPressed: () {
                              if (goBrowser != null)
                                goBrowser('$value', primarySwatch, accentColor);
                              else
                                handler('$value');
                            },
                            child: OptimisedText(
                                minHeight: deviceHeight * 0.04,
                                maxHeight: deviceHeight * 0.04,
                                minWidth: deviceWidth * 0.01,
                                maxWidth: deviceWidth * 0.55,
                                fit: BoxFit.scaleDown,
                                child: Text('$textValue',
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: accentColor,
                                        decoration: TextDecoration.none,
                                        decorationColor: accentColor,
                                        fontWeight: FontWeight.bold)))))
                  ])));

  @override
  Widget build(BuildContext context) {
    late ScrollController controller;
    final lang = General.language(context);
    Color _primarySwatch = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    if (widget.isMyProfile) {
      final MyProfile myProfile = Provider.of<MyProfile>(context);
      controller = Provider.of<ProfileScrollProvider>(context, listen: false)
          .profileScrollController;
      additionalWebsite = myProfile.getAdditionalWebsite;
      additionalEmail = myProfile.getAdditionalEmail;
      additionalNumber = myProfile.getAdditionalNumber;
      additionalAddress = myProfile.getAdditionalAddress;
      additionalAddressName = myProfile.getAdditionalAddressName;
    } else {
      final OtherProfile myProfile = Provider.of<OtherProfile>(context);
      controller = myProfile.getProfileScrollController;
      additionalWebsite = myProfile.getAdditionalWebsite;
      additionalEmail = myProfile.getAdditionalEmail;
      additionalNumber = myProfile.getAdditionalNumber;
      additionalAddress = myProfile.getAdditionalAddress;
      additionalAddressName = myProfile.getAdditionalAddressName;
    }
    if (!widget.isMyProfile) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    String displayWebsite = additionalWebsite;
    String displayEmail = additionalEmail;
    String displayNumber = additionalNumber;
    if (displayWebsite.length > 30) {
      final sub = additionalWebsite.substring(0, 30);
      displayWebsite = '$sub..';
    }
    if (displayEmail.length > 30) {
      final sub = additionalEmail.substring(0, 30);
      displayEmail = '$sub..';
    }
    if (displayNumber.length > 30) {
      final sub = additionalNumber.substring(0, 30);
      displayNumber = '$sub..';
    }
    return SizedBox(
        height: widget.givenHeight,
        width: _deviceWidth,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(30.50),
                    topRight: const Radius.circular(30.50))),
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(30.0),
                    topRight: const Radius.circular(30.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          color: _primarySwatch,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                    tooltip: lang.loading_profile,
                                    icon: const Icon(
                                        customIcons.MyFlutterApp.curve_arrow),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: Colors.white)
                              ])),
                      Expanded(
                          child: NestedScroller(
                              controller: controller,
                              child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        if (additionalWebsite != '')
                                          // buildItem(
                                          //     label: 'Link',
                                          //     icon: Icons.public_outlined,
                                          //     value: additionalWebsite,
                                          //     textValue: displayWebsite,
                                          //     copyHandler: websiteCopyHandler,
                                          //     handler: websiteHandler,
                                          //     goBrowser: websiteHandler,
                                          //     primarySwatch: _primarySwatch,
                                          //     accentColor: _accentColor,
                                          //     deviceHeight: _deviceHeight,
                                          //     deviceWidth: _deviceWidth),
                                          ProfileBackWebsite(
                                              additionalWebsite,
                                              displayWebsite,
                                              _primarySwatch,
                                              _accentColor),
                                        if (additionalEmail != '')
                                          buildItem(
                                              label: lang.screens_additional10,
                                              icon: Icons.mail_outline,
                                              value: additionalEmail,
                                              textValue: displayEmail,
                                              copyHandler: emailHandler,
                                              handler: emailHandler,
                                              goBrowser: null,
                                              primarySwatch: _primarySwatch,
                                              accentColor: _accentColor,
                                              deviceHeight: _deviceHeight,
                                              deviceWidth: _deviceWidth),
                                        if (additionalNumber != '')
                                          buildItem(
                                              label: lang.screens_additional12,
                                              icon: Icons.phone_outlined,
                                              value: additionalNumber,
                                              textValue: displayNumber,
                                              copyHandler: phoneCopyHandler,
                                              handler: phoneCopyHandler,
                                              goBrowser: null,
                                              primarySwatch: _primarySwatch,
                                              accentColor: _accentColor,
                                              deviceHeight: _deviceHeight,
                                              deviceWidth: _deviceWidth),
                                        if (additionalAddress != '')
                                          ProfileBackAddress(
                                              additionalAddress,
                                              additionalAddressName,
                                              widget.isMyProfile),
                                        if (additionalAddress != '' && !kIsWeb)
                                          ProfileMap(additionalAddress,
                                              additionalAddressName, false)
                                      ]))))
                    ]))));
  }
}

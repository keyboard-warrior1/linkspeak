import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import 'profileBackAddress.dart';
import 'profileMap.dart';
import 'adaptiveText.dart';

class BackSide extends StatelessWidget {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController controller;
  final double givenHeight;
  final String additionalWebsite;
  final String additionalEmail;
  final String additionalNumber;
  final bool isMyProfile;
  final dynamic additionalAddress;
  final String additionalAddressName;
  const BackSide({
    required this.controller,
    required this.givenHeight,
    required this.additionalWebsite,
    required this.additionalEmail,
    required this.additionalNumber,
    required this.additionalAddress,
    required this.additionalAddressName,
    required this.isMyProfile,
  });

  @override
  Widget build(BuildContext context) {
    Color _primarySwatch = Theme.of(context).primaryColor;
    Color _accentColor = Theme.of(context).accentColor;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    if (!isMyProfile) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    Future<void> websiteHandler(String url) async {
      final myUrls =
          firestore.collection('Users').doc(myUsername).collection('URLs');

      Future.delayed(const Duration(seconds: 1), () {
        return myUrls.add({'url': url, 'date': DateTime.now()});
      });
      final BrowserScreenArgs args = BrowserScreenArgs(url);
      Navigator.pushNamed(context, RouteGenerator.browser, arguments: args);
    }

    Future<void> websiteCopyHandler(String url) async {
      final myUrls =
          firestore.collection('Users').doc(myUsername).collection('URLs');
      await Clipboard.setData(ClipboardData(text: '$url'));
      await myUrls.add({'url': url, 'date': DateTime.now()});
      EasyLoading.show(
        status: 'Copied',
        dismissOnTap: true,
        indicator: Icon(Icons.copy, color: Colors.white),
      );
    }

    Future<void> phoneHandler(String number) async {
      final myUrls =
          firestore.collection('Users').doc(myUsername).collection('URLs');
      await Clipboard.setData(ClipboardData(text: '$number'));
      await myUrls.add({'url': number, 'date': DateTime.now()});
      EasyLoading.show(
        status: 'Copied',
        dismissOnTap: true,
        indicator: Icon(Icons.copy, color: Colors.white),
      );
    }

    Future<void> emailHandler(String email) async {
      final myUrls =
          firestore.collection('Users').doc(myUsername).collection('URLs');
      await Clipboard.setData(ClipboardData(text: '$email'));
      await myUrls.add({'url': email, 'date': DateTime.now()});
      EasyLoading.show(
        status: 'Copied',
        dismissOnTap: true,
        indicator: Icon(Icons.copy, color: Colors.white),
      );
    }

    return SizedBox(
      height: givenHeight,
      width: _deviceWidth,
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
                      tooltip: 'back',
                      icon: const Icon(
                        customIcons.MyFlutterApp.curve_arrow,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationListener<OverscrollNotification>(
                  key: PageStorageKey<String>('profileBackside'),
                  onNotification: (OverscrollNotification value) {
                    if (value.overscroll < 0 &&
                        controller.offset + value.overscroll <= 0) {
                      if (controller.offset != 0) controller.jumpTo(0);
                      return true;
                    }
                    if (controller.offset + value.overscroll >=
                        controller.position.maxScrollExtent) {
                      if (controller.offset !=
                          controller.position.maxScrollExtent)
                        controller.jumpTo(controller.position.maxScrollExtent);
                      return true;
                    }
                    controller.jumpTo(controller.offset + value.overscroll);
                    return true;
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (additionalWebsite != '')
                          Container(
                            margin: const EdgeInsets.only(
                              top: 8.0,
                              right: 25.0,
                              bottom: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: _primarySwatch.withOpacity(0.60),
                              borderRadius: BorderRadius.only(
                                topRight: const Radius.circular(50.0),
                                bottomRight: const Radius.circular(50.0),
                              ),
                            ),
                            child: ListTile(
                              leading: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  const Icon(
                                    Icons.web,
                                    color: Colors.black,
                                  ),
                                  const Text(
                                    'Link',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      style: const ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onLongPress: () {
                                        websiteCopyHandler(
                                            '$additionalWebsite');
                                      },
                                      onPressed: () {
                                        websiteHandler('$additionalWebsite');
                                      },
                                      child: OptimisedText(
                                        minWidth: _deviceWidth * 0.01,
                                        minHeight: _deviceHeight * 0.04,
                                        maxHeight: _deviceHeight * 0.04,
                                        maxWidth: _deviceWidth * 0.55,
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$additionalWebsite',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: _accentColor,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: _accentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (additionalEmail != '')
                          Container(
                            margin: const EdgeInsets.only(
                              top: 8.0,
                              right: 25.0,
                              bottom: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: _primarySwatch.withOpacity(0.60),
                              borderRadius: BorderRadius.only(
                                topRight: const Radius.circular(50.0),
                                bottomRight: const Radius.circular(50.0),
                              ),
                            ),
                            child: ListTile(
                              leading: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  const Icon(
                                    Icons.mail_outline,
                                    color: Colors.black,
                                  ),
                                  const Text(
                                    'Email',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      style: const ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () {
                                        emailHandler('$additionalEmail');
                                      },
                                      child: OptimisedText(
                                        minWidth: _deviceWidth * 0.01,
                                        minHeight: _deviceHeight * 0.04,
                                        maxHeight: _deviceHeight * 0.04,
                                        maxWidth: _deviceWidth * 0.55,
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$additionalEmail',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: _accentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (additionalNumber != '')
                          Container(
                            margin: const EdgeInsets.only(
                              top: 8.0,
                              right: 25.0,
                              bottom: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: _primarySwatch.withOpacity(0.60),
                              borderRadius: BorderRadius.only(
                                topRight: const Radius.circular(50.0),
                                bottomRight: const Radius.circular(50.0),
                              ),
                            ),
                            child: ListTile(
                                leading: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.phone_outlined,
                                      color: Colors.black,
                                    ),
                                    const Text(
                                      'Phone',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextButton(
                                        style: const ButtonStyle(
                                            splashFactory:
                                                NoSplash.splashFactory),
                                        onPressed: () {
                                          phoneHandler('$additionalNumber');
                                        },
                                        child: OptimisedText(
                                          minWidth: _deviceWidth * 0.01,
                                          minHeight: _deviceHeight * 0.04,
                                          maxHeight: _deviceHeight * 0.04,
                                          maxWidth: _deviceWidth * 0.55,
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '$additionalNumber',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              color: _accentColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        if (additionalAddress != '')
                          ProfileBackAddress(additionalAddress,
                              additionalAddressName, isMyProfile),
                        // if (additionalAddress != '')
                        //   ProfileMap(
                        //       additionalAddress, additionalAddressName, false),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

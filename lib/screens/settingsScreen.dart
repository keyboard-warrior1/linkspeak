import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../general.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/addPostScreenState.dart';
import '../providers/appBarProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/settings/switchSheet.dart';

class Settings extends StatefulWidget {
  const Settings();

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late FirebaseAuth? auth;
  late FirebaseFirestore? firestore;
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      setState(() {});
    });
  }

  Widget buildListTile(dynamic handler, IconData icon, String title) =>
      ListTile(
          horizontalTitleGap: 5.0,
          onTap: handler,
          leading: (title == 'Quick Link')
              ? Padding(
                  padding: const EdgeInsets.only(left: 3.50),
                  child: Icon(icon, color: Colors.black))
              : Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(color: Colors.black)));

  Widget buildTrailingTile(dynamic handler, IconData icon, String title) =>
      ListTile(
          horizontalTitleGap: 5.0,
          onTap: handler,
          title: Text(title,
              style: TextStyle(
                  color: (icon == Icons.logout) ? Colors.red : Colors.black)),
          leading: Icon(icon,
              color: (icon == Icons.logout) ? Colors.red : Colors.black));
  // trailing: Icon(
  //   icon,
  //   color: (icon == Icons.logout) ? Colors.red : Colors.black,
  // ),

  void logoutHandler(String username) => showDialog(
      context: context,
      builder: (_) {
        return Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 150.0, maxWidth: 150.0),
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('Sign out',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Roboto',
                                  fontSize: 21.0,
                                  color: Colors.black)),
                          const Divider(
                              thickness: 1.0, indent: 0.0, endIndent: 0.0),
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                TextButton(
                                    style: ButtonStyle(
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () async {
                                      EasyLoading.show(
                                          status: 'Signing out',
                                          dismissOnTap: false);
                                      GoogleSignInAccount? googleUser = null;
                                      LoginResult? fbResult = null;
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final myBool =
                                          prefs.getBool('KeepLogged') ?? false;
                                      final myGmail =
                                          prefs.getString('GMAIL') ?? '';
                                      final myFacebook =
                                          prefs.getString('FB') ?? '';
                                      if (myGmail != '') {
                                        prefs.setString('GMAIL', '');
                                        googleUser =
                                            await GoogleSignIn().signIn();
                                      }
                                      if (myBool) {
                                        prefs
                                            .setBool('KeepLogged', false)
                                            .then((value) {});
                                      }
                                      if (myFacebook != '') {
                                        prefs.setString('FB', '');
                                        fbResult =
                                            await FacebookAuth.instance.login();
                                      }
                                      final _users =
                                          firestore!.collection('Users');
                                      await firestore!
                                          .collection('Control')
                                          .doc('Details')
                                          .update({
                                        'online': FieldValue.increment(-1)
                                      }).then((_) async {
                                        await General.subtractDailyOnline();
                                        await General.logout(username);
                                        await _users.doc(username).set({
                                          'Activity': 'Away',
                                          'Sign-out': DateTime.now(),
                                          'fcm': '',
                                        }, SetOptions(merge: true)).then(
                                            (value) {
                                          if (googleUser != null) {
                                            GoogleSignIn()
                                                .signOut()
                                                .then((value) {
                                              Provider.of<MyProfile>(context,
                                                      listen: false)
                                                  .resetProfile();
                                              Provider.of<AppBarProvider>(
                                                      context,
                                                      listen: false)
                                                  .reset();
                                              Provider.of<NewPostHelper>(
                                                      context,
                                                      listen: false)
                                                  .clear();
                                              EasyLoading.dismiss();
                                              Navigator.popUntil(context,
                                                  (route) => route.isFirst);
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  RouteGenerator.splashScreen);
                                            });
                                          } else if (fbResult != null) {
                                            FacebookAuth.instance
                                                .logOut()
                                                .then((value) {
                                              Provider.of<MyProfile>(context,
                                                      listen: false)
                                                  .resetProfile();
                                              Provider.of<AppBarProvider>(
                                                      context,
                                                      listen: false)
                                                  .reset();
                                              Provider.of<NewPostHelper>(
                                                      context,
                                                      listen: false)
                                                  .clear();
                                              EasyLoading.dismiss();
                                              Navigator.popUntil(context,
                                                  (route) => route.isFirst);
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  RouteGenerator.splashScreen);
                                            });
                                          } else {
                                            auth!.signOut().then((value) {
                                              Provider.of<MyProfile>(context,
                                                      listen: false)
                                                  .resetProfile();
                                              Provider.of<AppBarProvider>(
                                                      context,
                                                      listen: false)
                                                  .reset();
                                              Provider.of<NewPostHelper>(
                                                      context,
                                                      listen: false)
                                                  .clear();
                                              EasyLoading.dismiss();
                                              Navigator.popUntil(context,
                                                  (route) => route.isFirst);
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  RouteGenerator.splashScreen);
                                            }).catchError((onError) {
                                              EasyLoading.showError('Failed',
                                                  duration: const Duration(
                                                      seconds: 5),
                                                  dismissOnTap: true);
                                            });
                                          }
                                        }).catchError((onError) {
                                          EasyLoading.showError('Failed',
                                              duration:
                                                  const Duration(seconds: 5),
                                              dismissOnTap: true);
                                        });
                                      }).catchError((onError) {
                                        EasyLoading.showError('Failed',
                                            duration:
                                                const Duration(seconds: 5),
                                            dismissOnTap: true);
                                      });
                                    },
                                    child: const Text('Yes',
                                        style: TextStyle(color: Colors.red))),
                                TextButton(
                                    style: ButtonStyle(
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('No',
                                        style: TextStyle(color: Colors.red)))
                              ])
                        ]))));
      });

  void push(String route) => Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<MyProfile>(context).getUsername;
    final themeIconHelper = Provider.of<ThemeModel>(context);
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final File? activeIconFile = themeIconHelper.activeLikeFile;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                child: Column(children: <Widget>[
          const SettingsBar('Settings'),
          Expanded(
              child: Noglow(
                  child: ListView(shrinkWrap: true, children: <Widget>[
            buildListTile(() => push(RouteGenerator.themeScreen),
                Icons.palette_outlined, 'Theme'),
            buildListTile(() => push(RouteGenerator.favPostScreen),
                Icons.star_border, 'Favorites'),
            if (!kIsWeb)
              buildListTile(() => push(RouteGenerator.linkMode),
                  Icons.phonelink_ring_outlined, 'Quick Link'),
            buildListTile(() => push(RouteGenerator.replyHistoryScreen),
                Icons.reply_all_rounded, 'My Replies'),
            buildListTile(() => push(RouteGenerator.clubCenterScreen),
                customIcons.MyFlutterApp.clubs, 'Club center'),
            buildListTile(() => push(RouteGenerator.commentHistoryScreen),
                Icons.chat_bubble_outline_rounded, 'My Comments'),
            buildListTile(() => push(RouteGenerator.likedFlares),
                customIcons.MyFlutterApp.spotlight, 'Liked flares'),
            buildListTile(() => push(RouteGenerator.flareHistory),
                Icons.history_rounded, 'Viewed flares'),
            buildListTile(() => push(RouteGenerator.notificationSettingScreen),
                Icons.notifications_outlined, 'Alert settings'),
            buildListTile(() => push(RouteGenerator.editProfileScreen),
                Icons.edit_outlined, 'Manage profile'),
            if (currentIconName != 'Custom')
              buildListTile(() => push(RouteGenerator.likedPostScreen),
                  currentIcon, "Posts you've liked"),
            if (currentIconName == 'Custom')
              ListTile(
                  horizontalTitleGap: 5.0,
                  onTap: () => push(RouteGenerator.likedPostScreen),
                  leading: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () => push(RouteGenerator.likedPostScreen),
                      icon: Image.file(activeIconFile!)),
                  title: Text("Posts you've liked",
                      style: const TextStyle(color: Colors.black))),
            buildListTile(
                () => Navigator.pushNamed(context, RouteGenerator.termScreen),
                Icons.rule,
                'Terms and Guidelines'),
            buildListTile(() => push(RouteGenerator.privacyPolicyScreen),
                Icons.policy_outlined, 'Privacy policy'),
            buildListTile(() => push(RouteGenerator.aboutScreen),
                Icons.help_outline, 'About'),
            buildTrailingTile(() {
              showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  context: context,
                  builder: (ctx) {
                    return const SwitchSheet();
                  });
            }, Icons.switch_account_outlined, 'Switch profile'),
            buildTrailingTile(
                () => logoutHandler(username), Icons.logout, 'Logout')
          ])))
        ]))));
  }
}

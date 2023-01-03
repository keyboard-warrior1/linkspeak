import 'package:flutter/material.dart';

import '../general.dart';
import '../routes.dart';
import '../widgets/common/settingsBar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SettingsBar(lang.screens_about2),
                      const Spacer(),
                      Center(
                          child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(lang.screens_about1,
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17.0)))),
                      const Spacer(),
                      Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: const Text('TECHLR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.transparent,
                                  fontFamily: 'RobotoCondensed',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0))),
                      Container(
                          margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: const Text('Linkspeak v3.0.9',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 10.0))),
                      const Divider(),
                      // Container(
                      //     child: ListTile(
                      //         horizontalTitleGap: 5.0,
                      //         onTap: () => Navigator.pushNamed(
                      //             context, RouteGenerator.featureDocs),
                      //         leading: const Icon(Icons.list_alt_rounded,
                      //             color: Colors.black),
                      //         title: const Text('Feature documentation',
                      //             style: TextStyle(
                      //                 color: Colors.black, fontSize: 17.0)))),
                      Container(
                          child: ListTile(
                              horizontalTitleGap: 5.0,
                              onTap: () => Navigator.pushNamed(
                                  context, RouteGenerator.feedbackScreen),
                              leading: const Icon(Icons.message_outlined,
                                  color: Colors.black),
                              title: Text(lang.screens_about3,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17.0))))
                    ]))));
  }
}

import 'package:flutter/material.dart';

import '../routes.dart';
import '../widgets/common/settingsBar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen();
  static const String _about =
      'Linkspeak is brought to you by a team of devoted developers with the idea of creating a safe and limitless platform in which anyone regardless of their background could participate and express themselves. The team wishes that you have a blast while surfing around Linkspeak!';
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
              height: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SettingsBar('About'),
                    const Spacer(),
                    const Center(
                        child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: const Text(_about,
                                softWrap: true,
                                textAlign: TextAlign.start,
                                style: TextStyle(
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
                            style:
                                TextStyle(color: Colors.grey, fontSize: 10.0))),
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
                            title: const Text('Send us your feedback',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17.0))))
                  ]))));
}

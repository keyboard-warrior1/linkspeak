import 'package:flutter/material.dart';
import '../widgets/settingsBar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen();
  static const String _about =
      'Linkspeak is brought to you by a team of devoted developers with the idea of creating a safe and limitless platform in which anyone regardless of their background could participate and express themselves. The team wishes that you have a blast while surfing around Linkspeak!';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: const Text(
                    _about,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: const Text(
                  'TECHLR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'RobotoCondensed',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: const Text(
                  'Linkspeak v2.0.2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.0,
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

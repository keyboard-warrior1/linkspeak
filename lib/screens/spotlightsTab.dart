import 'package:flutter/material.dart';

class SpotlightsTab extends StatefulWidget {
  const SpotlightsTab();

  @override
  _SpotlightsTabState createState() => _SpotlightsTabState();
}

class _SpotlightsTabState extends State<SpotlightsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text('SPOTLIGHTS'),
          ),
        ],
      ),
    );
  }
}

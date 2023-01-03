import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/clubProvider.dart';
import '../providers/themeModel.dart';

class ClubSensitiveBanner extends StatefulWidget {
  final bool isInFlare;
  const ClubSensitiveBanner(this.isInFlare);

  @override
  _ClubSensitiveBannerState createState() => _ClubSensitiveBannerState();
}

class _ClubSensitiveBannerState extends State<ClubSensitiveBanner> {
  bool showBanner = false;
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _selectedCensorMode = Provider.of<ThemeModel>(context).censorMode;
    bool _isAdmin = false;
    if (!widget.isInFlare)
      _isAdmin = Provider.of<ClubProvider>(context, listen: false).isMod;
    return Container(
        height: (showBanner || !_selectedCensorMode || _isAdmin) ? 0 : 150,
        width: (showBanner || !_selectedCensorMode || _isAdmin)
            ? 0
            : double.infinity,
        padding: const EdgeInsets.all(15.0),
        color: Colors.black,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 5.0),
              Center(
                  child: Text(lang.clubs_sensitive1,
                      softWrap: true,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15.0))),
              const SizedBox(width: 5.0),
              TextButton(
                  child: Text(lang.clubs_sensitive2,
                      style: const TextStyle(fontSize: 20.0)),
                  onPressed: () => setState(() => showBanner = true)),
              const Spacer()
            ]));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/otherProfileProvider.dart';

class ProfileSensitiveBanner extends StatelessWidget {
  const ProfileSensitiveBanner();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final void Function() showBanner =
        Provider.of<OtherProfile>(context, listen: false).showNSFWBanner;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    return Container(
        height: _deviceHeight * 0.12,
        width: _deviceWidth,
        padding: const EdgeInsets.all(15.0),
        color: Colors.black,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 5.0),
              Center(
                  child: Text(lang.widgets_profile21,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15.0))),
              const SizedBox(width: 10.0),
              TextButton(
                child: Text(lang.widgets_profile22,
                    style: const TextStyle(fontSize: 20.0)),
                onPressed: () => showBanner(),
              ),
              const Spacer()
            ]));
  }
}

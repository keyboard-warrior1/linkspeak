import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../clubs/clubSensitiveBanner.dart';
import '../providers/flareProfileProvider.dart';

class FlareProfileBanner extends StatelessWidget {
  const FlareProfileBanner();

  @override
  Widget build(BuildContext context) {
    final bannerURL =
        Provider.of<FlareProfile>(context, listen: false).bannerURL;
    final bannerNSFW =
        Provider.of<FlareProfile>(context, listen: false).bannerNSFW;
    return Stack(children: <Widget>[
      Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: Image.network(bannerURL, fit: BoxFit.cover)),
      if (bannerNSFW) const ClubSensitiveBanner(true)
    ]);
  }
}

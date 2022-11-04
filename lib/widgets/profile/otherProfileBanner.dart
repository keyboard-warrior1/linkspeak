import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';

class OtherProfileBanner extends StatefulWidget {
  const OtherProfileBanner();

  @override
  _OtherProfileBannerState createState() => _OtherProfileBannerState();
}

class _OtherProfileBannerState extends State<OtherProfileBanner> {
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final bool imBlocked = Provider.of<OtherProfile>(context).imBlocked;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String bannerUrl =
        Provider.of<OtherProfile>(context).getProfileBanner;
    return (imBlocked)
        ? (myUsername.startsWith('Linkspeak'))
            ? (bannerUrl == 'None')
                ? Container(
                    height: _deviceHeight * 0.15,
                    width: _deviceWidth,
                    color: Colors.transparent,
                  )
                : SizedBox(
                    height: _deviceHeight * 0.15,
                    width: _deviceWidth,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            height: _deviceHeight * 0.15,
                            width: _deviceWidth,
                            color: Colors.grey.shade200,
                            child: Image.network(
                              bannerUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
            : Container(
                height: _deviceHeight * 0.15,
                width: _deviceWidth,
                color: Colors.transparent,
              )
        : (bannerUrl == 'None')
            ? Container(
                height: _deviceHeight * 0.15,
                width: _deviceWidth,
                color: Colors.transparent,
              )
            : SizedBox(
                height: _deviceHeight * 0.15,
                width: _deviceWidth,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        height: _deviceHeight * 0.15,
                        width: _deviceWidth,
                        color: Colors.grey.shade200,
                        child: Image.network(
                          bannerUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              );
  }
}

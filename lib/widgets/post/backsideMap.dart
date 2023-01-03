import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/otherProfileProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';

class PostWidgetMap extends StatefulWidget {
  final bool isInOtherProfile;
  const PostWidgetMap(this.isInOtherProfile);
  @override
  _PostWidgetMapState createState() => _PostWidgetMapState();
}

class _PostWidgetMapState extends State<PostWidgetMap> {
  String theAddress = '';
  Future<void> buildAddress(dynamic address) async {
    return await placemarkFromCoordinates(address.latitude, address.longitude)
        .then((value) {
      final cityName = value[0].locality!;
      final countryName = value[0].country!;
      theAddress = '$cityName, $countryName';
    });
  }

  @override
  void initState() {
    super.initState();
    final postLocationName =
        Provider.of<FullHelper>(context, listen: false).getLocationName;
    final postLocation =
        Provider.of<FullHelper>(context, listen: false).getLocation;
    if (postLocationName != '') {
      theAddress = postLocationName;
    } else {
      buildAddress(postLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    // final String postID =
    // Provider.of<FullHelper>(context, listen: false).postId;
    final postLocation =
        Provider.of<FullHelper>(context, listen: false).getLocation;
    final postLocationName =
        Provider.of<FullHelper>(context, listen: false).getLocationName;
    final addressLength = theAddress.length;
    if (addressLength > 35) {
      final String sub = theAddress.substring(0, 35);
      theAddress = '$sub..';
    }
    if (widget.isInOtherProfile)
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
    if (postLocation != '') {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: const Radius.circular(10.0),
                  bottomLeft: const Radius.circular(10.0))),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: TextButton(
                        style: ButtonStyle(
                            animationDuration: const Duration(milliseconds: 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: MaterialStateProperty.all<double>(0.0),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0.0)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            shadowColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.transparent)),
                        onPressed: () {
                          PlaceScreenArgs args = PlaceScreenArgs(
                              locationName: postLocationName,
                              location: postLocation,
                              placeID: null);
                          Navigator.pushNamed(
                              context, RouteGenerator.placePostsScreen,
                              arguments: args);
                        },
                        onLongPress: () {
                          if (!kIsWeb) {
                            MapScreenArgs args = MapScreenArgs(
                                address: postLocation,
                                addressName: postLocationName);
                            Navigator.pushNamed(
                                context, RouteGenerator.fullMapScreen,
                                arguments: args);
                          }
                        },
                        child: OptimisedText(
                            minWidth: _deviceWidth * 0.55,
                            maxWidth: _deviceWidth * 0.85,
                            minHeight: _deviceHeight * 0.05,
                            maxHeight: _deviceHeight * 0.15,
                            fit: BoxFit.scaleDown,
                            child: Container(
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Row(children: <Widget>[
                                  const Icon(Icons.location_pin,
                                      color: Colors.white, size: 20.0),
                                  Text('  $theAddress',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20.0))
                                ])))))
              ]));
    } else {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: const Radius.circular(10.0),
                  bottomLeft: const Radius.circular(10.0))),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: OptimisedText(
                        minWidth: _deviceWidth * 0.55,
                        maxWidth: _deviceWidth * 0.55,
                        minHeight: _deviceHeight * 0.05,
                        maxHeight: _deviceHeight * 0.10,
                        fit: BoxFit.scaleDown,
                        child: Container(
                            padding: const EdgeInsets.all(21.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(31.0),
                                border: Border.all(color: Colors.grey)),
                            child: Text(lang.widgets_post1,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 35.0)))))
              ]));
    }
  }
}

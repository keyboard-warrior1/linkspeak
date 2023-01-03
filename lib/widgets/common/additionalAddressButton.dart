import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:location/location.dart' as geoloacation;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
// import '../../providers/addPostScreenState.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import 'adaptiveText.dart';

class AdditionalAddressButton extends StatefulWidget {
  final bool isInPostScreen;
  final bool isInPost;
  final void Function()? somethingChanged;
  final void Function(dynamic)? changeAddress;
  final void Function(String)? changeAddressName;
  final dynamic postLocation;
  final dynamic postLocationName;
  const AdditionalAddressButton(
      {required this.isInPostScreen,
      required this.isInPost,
      required this.somethingChanged,
      required this.changeAddress,
      required this.changeAddressName,
      required this.postLocation,
      required this.postLocationName});

  @override
  _AdditionalAddressButtonState createState() =>
      _AdditionalAddressButtonState();
}

class _AdditionalAddressButtonState extends State<AdditionalAddressButton> {
  final firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  late dynamic point;
  String stateAddressName = '';
  String countryName = '';
  String cityName = '';
  Future<void> getPlacemark(
      {required String myUsername,
      required double latitude,
      required double longitude,
      required dynamic newAddress,
      required dynamic changePostAddress,
      required dynamic changePostAddressName}) async {
    final myLocations = firestore
        .collection('Users')
        .doc(myUsername)
        .collection('My Locations')
        .doc();
    return geocoder
        .placemarkFromCoordinates(latitude, longitude)
        .then((value) async {
      cityName = value[0].locality!;
      countryName = value[0].country!;
      await myLocations.set({
        'location name': '$cityName, $countryName',
        'coordinates': newAddress,
        'date': DateTime.now(),
        'took in post': widget.isInPost,
        'took in profile': (!widget.isInPost && !widget.isInPostScreen),
        'took in chat': false,
        'took in place search': false
      });
      if (widget.isInPost) {
        changePostAddress(newAddress);
        changePostAddressName('$cityName, $countryName');
      } else {
        widget.changeAddress!(newAddress);
        widget.changeAddressName!('$cityName, $countryName');
        widget.somethingChanged!();
      }
      changeStateAddressName('');
      setState(() {
        isLoading = false;
      });
    });
  }

  void buttonSetState() {
    setState(() {});
  }

  void changeStateAddressName(String newName) {
    stateAddressName = newName;
    setState(() {});
  }

  void changePoint(dynamic newPoint) {
    point = newPoint;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.isInPost) {
      point = widget.postLocation;
      stateAddressName = widget.postLocationName;
    } else if (widget.isInPostScreen) {
      point = Provider.of<FullHelper>(context, listen: false).getLocation;
      stateAddressName =
          Provider.of<FullHelper>(context, listen: false).getLocationName;
    } else {
      point =
          Provider.of<MyProfile>(context, listen: false).getAdditionalAddress;
      stateAddressName = Provider.of<MyProfile>(context, listen: false)
          .getAdditionalAddressName;
    }
  }

  void _showSheet() {
    final lang = General.language(context);
    final dynamic changePostAddress = widget.changeAddress;
    final dynamic changePostAddressName = widget.changeAddressName;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    showModalBottomSheet(
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(31.0)),
        backgroundColor: Colors.white,
        builder: (_) {
          final ListTile currentLocation = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.gps_fixed, color: Colors.black),
              title: Text(lang.widgets_common1,
                  style: const TextStyle(color: Colors.black)),
              onTap: () async {
                Navigator.pop(context);
                geoloacation.Location location = geoloacation.Location();
                PermissionStatus status = await Permission.location.request();
                if (status == PermissionStatus.granted) {
                  setState(() {
                    isLoading = true;
                  });
                  var _locationData = await location.getLocation();
                  final newAddress = GeoPoint(
                      _locationData.latitude!, _locationData.longitude!);
                  point = newAddress;
                  return getPlacemark(
                      myUsername: myUsername,
                      latitude: point.latitude,
                      longitude: point.longitude,
                      newAddress: newAddress,
                      changePostAddress: changePostAddress,
                      changePostAddressName: changePostAddressName);
                } else if (status == PermissionStatus.permanentlyDenied) {
                  openAppSettings();
                } else {
                  return;
                }
              });
          // final ListTile _pickAnAddress = ListTile(
          //     horizontalTitleGap: 5.0,
          //     leading: const Icon(Icons.map, color: Colors.black),
          //     title: const Text('Use another address',
          //         style: TextStyle(color: Colors.black)),
          //     onTap: () {
          //       final ProfilePickAddressScreenArgs args =
          //           ProfilePickAddressScreenArgs(
          //               isInPost: widget.isInPost,
          //               isInChat: false,
          //               somethingChanged: widget.somethingChanged,
          //               changeAddress: widget.changeAddress,
          //               changeAddressName: widget.changeAddressName,
          //               changeStateAddressName: changeStateAddressName,
          //               changePoint: changePoint,
          //               chatHandler: () {});
          //       Navigator.pop(context);
          //       Navigator.pushNamed(context, RouteGenerator.profilePickAddress,
          //           arguments: args);
          //     });
          final ListTile _customLocation = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.map, color: Colors.black),
              title: Text(lang.widgets_common2,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                final ProfilePickAddressScreenArgs args =
                    ProfilePickAddressScreenArgs(
                        isInPost: widget.isInPost,
                        isInChat: false,
                        somethingChanged: widget.somethingChanged,
                        changeAddress: widget.changeAddress,
                        changeAddressName: widget.changeAddressName,
                        changeStateAddressName: changeStateAddressName,
                        changePoint: changePoint,
                        chatHandler: () {});
                Navigator.pop(context);
                Navigator.pushNamed(
                    context, RouteGenerator.customLocationScreen,
                    arguments: args);
              });
          final ListTile _removeAddress = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.remove_circle, color: Colors.black),
              title: Text(lang.widgets_common3,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                if (widget.isInPost) {
                  Future.delayed(const Duration(milliseconds: 100),
                      () => Navigator.pop(context));
                  changePostAddress('');
                  changePostAddressName('');
                  point = '';
                  stateAddressName = '';
                  setState(() {});
                } else {
                  Future.delayed(const Duration(milliseconds: 100),
                      () => Navigator.pop(context));
                  widget.changeAddress!('');
                  widget.changeAddressName!('');
                  widget.somethingChanged!();
                  point = '';
                  stateAddressName = '';
                  setState(() {});
                }
              });
          final Column _choices = Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (!kIsWeb) currentLocation,
                if (!kIsWeb) _customLocation,
                // _pickAnAddress,
                if (point != '') _removeAddress
              ]);

          final SizedBox _box = SizedBox(child: _choices);
          return _box;
        });
  }

  Widget buildButton() {
    final lang = General.language(context);
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    String displayName = stateAddressName;
    if (stateAddressName != '') {
      final length = stateAddressName.length;
      if (length > 50) {
        final sub = displayName.substring(0, 50);
        displayName = '$sub..';
      }
    }
    return TextButton(
        onLongPress: () {
          if (widget.isInPostScreen) {
            final postPoint =
                Provider.of<FullHelper>(context, listen: false).getLocation;
            final postAddressName =
                Provider.of<FullHelper>(context, listen: false).getLocationName;
            MapScreenArgs args =
                MapScreenArgs(address: postPoint, addressName: postAddressName);
            Navigator.pushNamed(context, RouteGenerator.fullMapScreen,
                arguments: args);
          }
        },
        onPressed: () {
          if (widget.isInPostScreen) {
            final postPoint =
                Provider.of<FullHelper>(context, listen: false).getLocation;
            final postAddressName =
                Provider.of<FullHelper>(context, listen: false).getLocationName;
            PlaceScreenArgs args = PlaceScreenArgs(
                locationName: postAddressName,
                location: postPoint,
                placeID: null);
            Navigator.pushNamed(context, RouteGenerator.placePostsScreen,
                arguments: args);
          } else {
            FocusScope.of(context).unfocus();
            _showSheet();
          }
        },
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          const Icon(Icons.location_pin, color: Colors.lightBlueAccent),
          const SizedBox(width: 5.0),
          if (isLoading)
            const SizedBox(
                height: 15.0,
                width: 15.0,
                child: const CircularProgressIndicator(strokeWidth: 1.50)),
          if (!isLoading)
            OptimisedText(
                minWidth: _deviceWidth * 0.01,
                minHeight: _deviceHeight * 0.04,
                maxHeight: _deviceHeight * 0.04,
                maxWidth: _deviceWidth * 0.85,
                fit: BoxFit.scaleDown,
                child: Text(
                    (point != '')
                        ? (stateAddressName != '')
                            ? '$displayName'
                            : '$cityName, $countryName'
                        : lang.widgets_common4,
                    softWrap: true,
                    style: TextStyle(color: Colors.lightBlueAccent)))
        ]));
  }

  @override
  Widget build(BuildContext context) => buildButton();
}

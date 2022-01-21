import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:location/location.dart' as geoloacation;
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/addPostScreenState.dart';
import '../providers/fullPostHelper.dart';
import '../routes.dart';
import 'adaptiveText.dart';

class AdditionalAddressButton extends StatefulWidget {
  final bool isInPostScreen;
  final bool isInPost;
  final void Function() somethingChanged;
  final void Function(dynamic) changeAddress;
  final void Function(String) changeAddressName;

  const AdditionalAddressButton({
    required this.isInPostScreen,
    required this.isInPost,
    required this.somethingChanged,
    required this.changeAddress,
    required this.changeAddressName,
  });

  @override
  _AdditionalAddressButtonState createState() =>
      _AdditionalAddressButtonState();
}

class _AdditionalAddressButtonState extends State<AdditionalAddressButton> {
  bool isLoading = false;
  late dynamic point;
  String stateAddressName = '';
  String countryName = '';
  String cityName = '';
  Future<void> getPlacemark(double latitude, double longitude) async {
    setState(() {
      isLoading = true;
    });
    return await geocoder
        .placemarkFromCoordinates(latitude, longitude)
        .then((value) {
      cityName = value[0].locality!;
      countryName = value[0].country!;
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
      point = Provider.of<NewPostHelper>(context, listen: false).getLocation;
      stateAddressName =
          Provider.of<NewPostHelper>(context, listen: false).getLocationName;
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
    if (point != '') {
      getPlacemark(point.latitude, point.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final void Function(dynamic) changePostAddress =
        Provider.of<NewPostHelper>(context, listen: false).changeLocation;
    final void Function(String) changePostAddressName =
        Provider.of<NewPostHelper>(context, listen: false).changeLocationName;
    return TextButton(
      onPressed: () {
        if (widget.isInPostScreen) {
          final postPoint =
              Provider.of<FullHelper>(context, listen: false).getLocation;
          final postAddressName =
              Provider.of<FullHelper>(context, listen: false).getLocationName;
          MapScreenArgs args =
              MapScreenArgs(address: postPoint, addressName: postAddressName);
          Navigator.pushNamed(context, RouteGenerator.fullMapScreen,
              arguments: args);
        } else {
          if (isLoading) {
          } else {
            FocusScope.of(context).unfocus();
            showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    31.0,
                  ),
                ),
                backgroundColor: Colors.white,
                builder: (_) {
                  final ListTile currentLocation = ListTile(
                    horizontalTitleGap: 5.0,
                    leading: const Icon(
                      Icons.gps_fixed,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Use current location',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () async {
                      geoloacation.Location location = geoloacation.Location();
                      await location.requestPermission().then((value) async {
                        if (value == geoloacation.PermissionStatus.granted) {
                          setState(() {
                            isLoading = true;
                          });
                          var _locationData = await location.getLocation();
                          final newAddress = GeoPoint(_locationData.latitude!,
                              _locationData.longitude!);
                          point = newAddress;
                          await getPlacemark(point.latitude, point.longitude)
                              .then((value) {
                            if (widget.isInPost) {
                              changePostAddress(newAddress);
                              changePostAddressName('');
                            } else {
                              widget.changeAddress(newAddress);
                              widget.changeAddressName('');
                              widget.somethingChanged();
                            }
                            changeStateAddressName('');
                          });
                        }
                      });
                    },
                  );
                  final ListTile _pickAnAddress = ListTile(
                    horizontalTitleGap: 5.0,
                    leading: const Icon(
                      Icons.map,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Use another address',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      final ProfilePickAddressScreenArgs args =
                          ProfilePickAddressScreenArgs(
                        isInPost: widget.isInPost,
                        somethingChanged: widget.somethingChanged,
                        changeAddress: widget.changeAddress,
                        changeAddressName: widget.changeAddressName,
                        changeStateAddressName: changeStateAddressName,
                        changePoint: changePoint,
                      );
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, RouteGenerator.profilePickAddress,
                          arguments: args);
                    },
                  );
                  final ListTile _removeAddress = ListTile(
                    horizontalTitleGap: 5.0,
                    leading: const Icon(
                      Icons.remove_circle,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Remove address',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
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
                        widget.changeAddress('');
                        widget.changeAddressName('');
                        widget.somethingChanged();
                        point = '';
                        stateAddressName = '';
                        setState(() {});
                      }
                    },
                  );
                  final Column _choices = Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      currentLocation,
                      _pickAnAddress,
                      if (point != '') _removeAddress,
                    ],
                  );

                  final SizedBox _box = SizedBox(
                    child: _choices,
                  );
                  return _box;
                });
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.location_pin,
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(width: 5.0),
          if (isLoading)
            const SizedBox(
              height: 15.0,
              width: 15.0,
              child: const CircularProgressIndicator(),
            ),
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
                        ? '$stateAddressName'
                        : '$cityName, $countryName'
                    : 'Add an address',
                softWrap: true,
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                ),
              ),
            )
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as geoloacation;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../../providers/myProfileProvider.dart';
import '../providers/addPostScreenState.dart';

class PickAddressScreen extends StatefulWidget {
  final dynamic isInPost;
  final dynamic isInChat;
  final dynamic somethingChanged;
  final dynamic changeAddress;
  final dynamic changeAddressName;
  final dynamic changeStateAddressName;
  final dynamic changePoint;
  final dynamic chatHandler;
  const PickAddressScreen(
      {required this.isInPost,
      required this.isInChat,
      required this.somethingChanged,
      required this.changeAddress,
      required this.changeAddressName,
      required this.changeStateAddressName,
      required this.changePoint,
      required this.chatHandler});

  @override
  _PickAddressScreenState createState() => _PickAddressScreenState();
}

class _PickAddressScreenState extends State<PickAddressScreen> {
  final firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool haveLocation = true;
  LatLon? userLocation;
  static const String apiKey = 'AIzaSyDXnNHNEwi0EnMoqa6736wkj99FQadBzvg';
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Future<void> getAndSetLocation(String myUsername) async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final myLocations = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('My Locations')
          .doc();
      geoloacation.Location location = geoloacation.Location();
      var _locationData = await location.getLocation();
      final latitude = _locationData.latitude;
      final longitude = _locationData.longitude;
      setState(() {
        haveLocation = true;
        userLocation = LatLon(latitude!, longitude!);
      });
      final newAddress = GeoPoint(latitude!, longitude!);
      final placemark =
          await geocoder.placemarkFromCoordinates(latitude, longitude);
      final cityName = placemark[0].locality!;
      final countryName = placemark[0].country!;
      await myLocations.set({
        'location name': '$cityName, $countryName',
        'coordinates': newAddress,
        'date': DateTime.now(),
        'took in post': false,
        'took in profile': false,
        'took in chat': false,
        'took in place search': true
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> initScreen(String myUsername) async {
    final status = await Permission.location.status;
    final isGranted = status.isGranted;
    if (isGranted) {
      final myLocations = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('My Locations')
          .doc();
      geoloacation.Location location = geoloacation.Location();
      var _locationData = await location.getLocation();
      final latitude = _locationData.latitude;
      final longitude = _locationData.longitude;
      final newAddress = GeoPoint(latitude!, longitude!);
      final placemark =
          await geocoder.placemarkFromCoordinates(latitude, longitude);
      final cityName = placemark[0].locality!;
      final countryName = placemark[0].country!;
      await myLocations.set({
        'location name': '$cityName, $countryName',
        'coordinates': newAddress,
        'date': DateTime.now(),
        'took in post': false,
        'took in profile': false,
        'took in chat': false,
        'took in place search': true
      });
      setState(() => userLocation = LatLon(latitude, longitude));
    } else {
      setState(() => haveLocation = false);
    }
  }

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(apiKey);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    initScreen(myUsername);
  }

  Future<void> pickLocation(
      String myUsername,
      String placeId,
      String shownName,
      void Function(dynamic) changePostAddress,
      void Function(String) changePostAddressName) async {
    final lang = General.language(context);
    if (isLoading) {
    } else {
      setState(() => isLoading = true);
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: lang.screens_pickAddress1, dismissOnTap: true);
      late DetailsResult detailsResult;
      var result = await this
          .googlePlace
          .details
          .get(placeId, fields: 'geometry/location');
      if (result != null && result.result != null && mounted) {
        setState(() => detailsResult = result.result!);
        final geo = detailsResult.geometry;
        final latitude = geo!.location!.lat;
        final longitude = geo.location!.lng;
        final point = GeoPoint(latitude!, longitude!);
        if (widget.isInPost) {
          changePostAddress(point);
          changePostAddressName(shownName);
          widget.changePoint(point);
          widget.changeStateAddressName(shownName);
          EasyLoading.dismiss();
          Navigator.pop(context);
        } else if (widget.isInChat) {
          widget.chatHandler(myUsername, shownName, point);
        } else {
          widget.changeAddress(point);
          widget.changeAddressName(shownName);
          widget.somethingChanged();
          widget.changeStateAddressName(shownName);
          EasyLoading.dismiss();
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final void Function(dynamic) changePostAddress =
        Provider.of<NewPostHelper>(context, listen: false).changeLocation;
    final void Function(String) changePostAddressName =
        Provider.of<NewPostHelper>(context, listen: false).changeLocationName;
    final lang = General.language(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Container(
                    margin: EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_ios,
                                        color: Colors.black)),
                                Text(lang.screens_pickAddress2,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold))
                              ]),
                          TextField(
                              decoration: InputDecoration(
                                  labelText: lang.screens_pickAddress3,
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 1.0)),
                                  enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black54, width: 1.0))),
                              onChanged: (value) {
                                if (value.isNotEmpty)
                                  autoCompleteSearch(value);
                                else if (predictions.length > 0 && mounted)
                                  setState(() => predictions = []);
                              }),
                          const SizedBox(height: 10.0),
                          if (!haveLocation && predictions.isEmpty)
                            Text(lang.screens_pickAddress4,
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          if (!haveLocation && predictions.isEmpty)
                            TextButton(
                                onPressed: () => getAndSetLocation(myUsername),
                                child: Text(lang.screens_pickAddress5)),
                          Expanded(
                              child: ListView.builder(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  itemCount: predictions.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                        leading: CircleAvatar(
                                            backgroundColor: _primaryColor,
                                            child: Icon(Icons.location_pin,
                                                color: _accentColor)),
                                        title: Text(
                                            predictions[index].description!),
                                        onTap: () {
                                          if (isLoading) {
                                          } else {
                                            pickLocation(
                                                myUsername,
                                                predictions[index].placeId!,
                                                predictions[index].description!,
                                                changePostAddress,
                                                changePostAddressName);
                                          }
                                        });
                                  }))
                        ])))));
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value,
        radius: haveLocation ? 50000 : null,
        location: haveLocation ? userLocation : null);
    if (result != null && result.predictions != null && mounted) {
      setState(() => predictions = result.predictions!);
    }
  }
}

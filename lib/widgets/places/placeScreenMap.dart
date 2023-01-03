import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/placesScreenProvider.dart';
import '../../routes.dart';

class PlaceScreenMap extends StatefulWidget {
  const PlaceScreenMap();
  @override
  _PlaceScreenMapState createState() => _PlaceScreenMapState();
}

class _PlaceScreenMapState extends State<PlaceScreenMap> {
  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = General.widthQuery(context);
    // final showMap = Provider.of<PlacesScreenProvider>(context).showMap;
    return AnimatedContainer(
      height: 150.0,
      width: _deviceWidth,
      duration: kThemeAnimationDuration,
      child: const NestedMapWidget(),
    );
  }
}

class NestedMapWidget extends StatefulWidget {
  const NestedMapWidget();

  @override
  State<NestedMapWidget> createState() => _NestedMapWidgetState();
}

class _NestedMapWidgetState extends State<NestedMapWidget> {
  late Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final placeProvider =
        Provider.of<PlacesScreenProvider>(context, listen: false);
    final dynamic locationName = placeProvider.placeName;
    final dynamic location = placeProvider.place;
    final initialLatitude = location.latitude;
    final initialLongitude = location.longitude;
    final initialPosition = CameraPosition(
        target: LatLng(initialLatitude, initialLongitude), zoom: 15.50);
    return GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: (_) {
          MapScreenArgs args =
              MapScreenArgs(address: location, addressName: locationName);
          Navigator.pushNamed(context, RouteGenerator.fullMapScreen,
              arguments: args);
        },
        initialCameraPosition: initialPosition,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        mapType: MapType.normal,
        markers: {
          Marker(
              markerId: const MarkerId('home'),
              position: LatLng(initialLatitude, initialLongitude))
        });
  }
}

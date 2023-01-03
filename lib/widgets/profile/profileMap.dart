import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/screenArguments.dart';
import '../../routes.dart';

class ProfileMap extends StatefulWidget {
  final dynamic address;
  final String addressName;
  final bool isInEdit;
  const ProfileMap(
    this.address,
    this.addressName,
    this.isInEdit,
  );

  @override
  _ProfileMapState createState() => _ProfileMapState();
}

class _ProfileMapState extends State<ProfileMap> {
  late Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final initialLatitude = widget.address.latitude;
    final initialLongitude = widget.address.longitude;
    final initialPosition = CameraPosition(
      target: LatLng(
        initialLatitude,
        initialLongitude,
      ),
      zoom: 15.50,
    );

    return Container(
      height: _deviceHeight * 0.35,
      width: double.infinity,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: GoogleMap(
          onTap: (_) {
            if (widget.isInEdit) {
            } else {
              MapScreenArgs args = MapScreenArgs(
                  address: widget.address, addressName: widget.addressName);
              Navigator.pushNamed(context, RouteGenerator.fullMapScreen,
                  arguments: args);
            }
          },
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
              position: LatLng(
                initialLatitude,
                initialLongitude,
              ),
            )
          },
          initialCameraPosition: initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}

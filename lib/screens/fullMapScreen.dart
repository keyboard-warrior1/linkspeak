import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../general.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/fullMapText.dart';

class FullScreenMap extends StatefulWidget {
  final dynamic address;
  final dynamic addressName;
  const FullScreenMap({required this.address, required this.addressName});

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  late Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    var displayName = widget.addressName;
    final length = displayName.length;
    if (length > 50) {
      final sub = displayName.substring(0, 50);
      displayName = '$sub..';
    }
    final initialLatitude = widget.address.latitude;
    final initialLongitude = widget.address.longitude;
    final initialPosition = CameraPosition(
        zoom: 15.50, target: LatLng(initialLatitude, initialLongitude));
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Stack(children: <Widget>[
                  Positioned.fill(
                      child: GoogleMap(
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: false,
                          mapType: MapType.normal,
                          markers: {
                            Marker(
                                markerId: const MarkerId('home'),
                                position:
                                    LatLng(initialLatitude, initialLongitude))
                          },
                          initialCameraPosition: initialPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          })),
                  Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          width: _deviceWidth,
                          color: _primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_ios,
                                        color: Colors.white)),
                                if (widget.addressName != '')
                                  OptimisedText(
                                      minWidth: _deviceWidth * 0.05,
                                      maxWidth: _deviceWidth * 0.75,
                                      minHeight: _deviceHeight * 0.05,
                                      maxHeight: _deviceHeight * 0.10,
                                      fit: BoxFit.scaleDown,
                                      child: Text(displayName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold))),
                                if (widget.addressName == '')
                                  FullMapText(widget.address),
                                const Spacer()
                              ])))
                ]))));
  }
}

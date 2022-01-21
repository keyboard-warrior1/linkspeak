import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/screenArguments.dart';
import '../providers/fullPostHelper.dart';
import '../routes.dart';
import 'adaptiveText.dart';

class PostWidgetMap extends StatefulWidget {
  const PostWidgetMap();

  @override
  _PostWidgetMapState createState() => _PostWidgetMapState();
}

class _PostWidgetMapState extends State<PostWidgetMap> {
  late Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final postLocation =
        Provider.of<FullHelper>(context, listen: false).getLocation;
    final postLocationName =
        Provider.of<FullHelper>(context, listen: false).getLocationName;
    if (postLocation != '') {
      final initialLatitude = postLocation.latitude;
      final initialLongitude = postLocation.longitude;
      final initialPosition = CameraPosition(
        target: LatLng(
          initialLatitude,
          initialLongitude,
        ),
        zoom: 15.50,
      );
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomRight: const Radius.circular(10.0),
          bottomLeft: const Radius.circular(10.0),
        ),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          onTap: (_) {
            MapScreenArgs args = MapScreenArgs(
                address: postLocation, addressName: postLocationName);
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
              position: LatLng(
                initialLatitude,
                initialLongitude,
              ),
            ),
          },
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: const Radius.circular(10.0),
            bottomLeft: const Radius.circular(10.0),
          ),
        ),
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
                  padding: const EdgeInsets.all(
                    21.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      31.0,
                    ),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    'No location added',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 35.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

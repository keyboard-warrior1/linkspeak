import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/screenArguments.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';

class ChatLocationWidget extends StatefulWidget {
  final String messageID;
  final String locationName;
  final dynamic location;
  final bool isMySide;
  final bool isRead;
  final Widget dateWidget;
  const ChatLocationWidget({
    required this.messageID,
    required this.location,
    required this.locationName,
    required this.isMySide,
    required this.isRead,
    required this.dateWidget,
  });

  @override
  State<ChatLocationWidget> createState() => _ChatLocationWidgetState();
}

class _ChatLocationWidgetState extends State<ChatLocationWidget> {
  late Completer<GoogleMapController> _controller = Completer();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> copyHandler(String myUsername) async {
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(
      ClipboardData(text: '${widget.locationName}'),
    );

    await myUrls.add({'url': '${widget.locationName}', 'date': DateTime.now()});
    EasyLoading.show(
      status: 'Copied',
      dismissOnTap: true,
      indicator: Icon(Icons.copy, color: Colors.white),
    );
  }

  Widget buildMap(dynamic initialPosition, dynamic initialLatitude,
      dynamic initialLongitude) {
    return Expanded(
      child: kIsWeb
          ? Container()
          : ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (_) {
                  MapScreenArgs args = MapScreenArgs(
                      address: widget.location,
                      addressName: widget.locationName);
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
                compassEnabled: false,
                trafficEnabled: false,
                liteModeEnabled: false,
                buildingsEnabled: false,
                indoorViewEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
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
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final _deviceHeight = mediaQuery.height;
    final _deviceWidth = mediaQuery.width;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final initialLatitude = widget.location.latitude;
    final initialLongitude = widget.location.longitude;
    final initialPosition = CameraPosition(
      target: LatLng(
        initialLatitude,
        initialLongitude,
      ),
      zoom: 15.50,
    );
    String displayAddress = widget.locationName;
    if (widget.locationName.length > 20) {
      displayAddress = '${widget.locationName.substring(0, 20)}..';
    }
    return Expanded(
      key: ValueKey<String>(widget.messageID),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.isMySide
                ? widget.isRead
                    ? Colors.green
                    : _primaryColor
                : Colors.grey[300]),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: _deviceHeight * 0.35,
            maxHeight: _deviceHeight * 0.35,
            minWidth: _deviceWidth * 0.65,
            maxWidth: _deviceWidth * 0.65,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: widget.isMySide
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              buildMap(initialPosition, initialLatitude, initialLongitude),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (!kIsWeb) {
                        MapScreenArgs args = MapScreenArgs(
                            address: widget.location,
                            addressName: widget.locationName);
                        Navigator.pushNamed(
                            context, RouteGenerator.fullMapScreen,
                            arguments: args);
                      }
                    },
                    onLongPress: () {
                      copyHandler(myUsername);
                    },
                    child: Text(
                      '$displayAddress',
                      style: TextStyle(
                        color: widget.isMySide
                            ? widget.isRead
                                ? Colors.black
                                : _accentColor
                            : _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              widget.dateWidget,
            ],
          ),
        ),
      ),
    );
  }
}

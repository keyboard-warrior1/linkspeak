import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/myProfileProvider.dart';
import '../widgets/common/adaptiveText.dart';
// import '../providers/addPostScreenState.dart';
import '../widgets/common/settingsBar.dart';

enum ViewMode { map, label }

class CustomLocationScreen extends StatefulWidget {
  final dynamic isInPost;
  final dynamic isInChat;
  final dynamic somethingChanged;
  final dynamic changeAddress;
  final dynamic changeAddressName;
  final dynamic changeStateAddressName;
  final dynamic changePoint;
  final dynamic chatHandler;
  const CustomLocationScreen(
      {required this.isInPost,
      required this.isInChat,
      required this.somethingChanged,
      required this.changeAddress,
      required this.changeAddressName,
      required this.changeStateAddressName,
      required this.changePoint,
      required this.chatHandler});

  @override
  State<CustomLocationScreen> createState() => _CustomLocationScreenState();
}

class _CustomLocationScreenState extends State<CustomLocationScreen> {
  ViewMode view = ViewMode.label;
  final TextEditingController labelController = TextEditingController();
  late Completer<GoogleMapController> _controller = Completer();
  final _formKey = GlobalKey<FormState>();
  LatLng? myLatLng;
  String? labelValidator(String? value) {
    if (value!.isEmpty || value.replaceAll(' ', '') == '' || value.trim() == '')
      return 'Please enter a valid name';
    if (value.length < 2 || value.length > 50)
      return 'Name must be between 2-50 characters';
    return null;
  }

  void finishHandler(void Function(dynamic) changePostAddress,
      void Function(String) changePostAddressName) {
    final shownName = labelController.value.text.trim();
    final lat = myLatLng!.latitude;
    final lng = myLatLng!.longitude;
    final point = GeoPoint(lat, lng);
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
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

  Widget buildNext(Color _primarySwatch, Color _accentColor) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(8),
                width: 100.0,
                child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                            const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 5.0)),
                        shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: _accentColor))),
                        elevation: MaterialStateProperty.all<double?>(0.0),
                        enableFeedback: false,
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(_accentColor)),
                    onPressed: () {
                      if (_formKey.currentState!.validate())
                        setState(() => view = ViewMode.map);
                    },
                    child: OptimisedText(
                        minWidth: 75.0,
                        maxWidth: 100.0,
                        minHeight: 25.0,
                        maxHeight: 25.0,
                        fit: BoxFit.scaleDown,
                        child: Text('Next',
                            style: TextStyle(
                                fontSize: 15.0, color: _primarySwatch)))))
          ]);
  Widget decoratedContainer(Widget child, bool isFinish) {
    return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isFinish
                ? Theme.of(context).colorScheme.primary
                : Colors.black54,
            borderRadius: BorderRadius.circular(10)),
        child: child);
  }

  Widget buildHint(
          Color _primarySwatch,
          Color _accentColor,
          void Function(dynamic) changePostAddress,
          void Function(String) changePostAddressName) =>
      Align(
          alignment: Alignment.topLeft,
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                decoratedContainer(
                    const Text('Tap a location',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    false),
                const Spacer(),
                if (myLatLng != null)
                  GestureDetector(
                      onTap: () {
                        finishHandler(changePostAddress, changePostAddressName);
                      },
                      child: decoratedContainer(
                          Text('Done',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold)),
                          true))
              ]));

  Widget buildField() => Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
          controller: labelController,
          maxLength: 50,
          validator: labelValidator,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: InputDecoration(
              label: const Text('Place name'),
              floatingLabelBehavior: FloatingLabelBehavior.always)));
  @override
  Widget build(BuildContext context) {
    final bool isLabel = view == ViewMode.label;
    final bool isMap = view == ViewMode.map;
    final theme = Theme.of(context).colorScheme;
    final _primarySwatch = theme.primary;
    final _accentColor = theme.secondary;
    final changePostAddress = widget.changeAddress;
    final changePostAddressName = widget.changeAddressName;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SettingsBar('Custom Place'),
                      if (isLabel) buildField(),
                      if (isLabel) buildNext(_primarySwatch, _accentColor),
                      if (isMap)
                        Expanded(
                            child:
                                Stack(fit: StackFit.expand, children: <Widget>[
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
                                    if (myLatLng != null)
                                      Marker(
                                          markerId:
                                              const MarkerId('chosen location'),
                                          position: myLatLng!)
                                  },
                                  initialCameraPosition: const CameraPosition(
                                      target: LatLng(0, 0)),
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                  onTap: (LatLng latLng) =>
                                      setState(() => myLatLng = latLng))),
                          buildHint(_primarySwatch, _accentColor,
                              changePostAddress, changePostAddressName)
                        ]))
                    ]))));
  }
}

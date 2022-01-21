import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'adaptiveText.dart';

class FullMapText extends StatefulWidget {
  final dynamic address;
  const FullMapText(this.address);

  @override
  _FullMapTextState createState() => _FullMapTextState();
}

class _FullMapTextState extends State<FullMapText> {
  late final Future<void> _buildText;
  String theAddress = '';
  Future<void> buildAddress() async {
    return await placemarkFromCoordinates(
            widget.address.latitude, widget.address.longitude)
        .then((value) {
      final cityName = value[0].locality!;
      final countryName = value[0].country!;
      theAddress = '$cityName, $countryName';
    });
  }

  @override
  void initState() {
    super.initState();
    _buildText = buildAddress();
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: _buildText,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return OptimisedText(
            minWidth: _deviceWidth * 0.05,
            maxWidth: _deviceWidth * 0.90,
            minHeight: _deviceHeight * 0.05,
            maxHeight: _deviceHeight * 0.10,
            fit: BoxFit.scaleDown,
            child: Text(
              '${widget.address.latitude.toString()} ${widget.address.longitude.toString()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return OptimisedText(
          minWidth: _deviceWidth * 0.05,
          maxWidth: _deviceWidth * 0.90,
          minHeight: _deviceHeight * 0.05,
          maxHeight: _deviceHeight * 0.10,
          fit: BoxFit.scaleDown,
          child: Text(
            theAddress,
            style: const TextStyle(
              fontSize: 17.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

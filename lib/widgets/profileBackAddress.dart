import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../routes.dart';
import 'adaptiveText.dart';

class ProfileBackAddress extends StatefulWidget {
  final dynamic additionalAddress;
  final String additionalAddressName;
  final bool isMyProfile;
  const ProfileBackAddress(
      this.additionalAddress, this.additionalAddressName, this.isMyProfile);

  @override
  _ProfileBackAddressState createState() => _ProfileBackAddressState();
}

class _ProfileBackAddressState extends State<ProfileBackAddress> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String theAddress = '';
  late final Future<void> _buildAddress;
  Future<void> buildAddress() async {
    if (widget.additionalAddressName != '') {
      return;
    } else {
      return await placemarkFromCoordinates(widget.additionalAddress.latitude,
              widget.additionalAddress.longitude)
          .then((value) {
        final cityName = value[0].locality!;
        final countryName = value[0].country!;
        theAddress = '$cityName, $countryName';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _buildAddress = buildAddress();
  }

  Future<void> copyHandler(String myUsername) async {
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(
      ClipboardData(
          text: (widget.additionalAddressName != '')
              ? '${widget.additionalAddressName}'
              : '${widget.additionalAddress.latitude}, ${widget.additionalAddress.longitude}'),
    );

    await myUrls.add({
      'url': (widget.additionalAddressName != '')
          ? '${widget.additionalAddressName}'
          : '${widget.additionalAddress.latitude}, ${widget.additionalAddress.longitude}',
      'date': DateTime.now()
    });
    EasyLoading.show(
      status: 'Copied',
      dismissOnTap: true,
      indicator: Icon(Icons.copy, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color _primarySwatch = Theme.of(context).primaryColor;
    Color _accentColor = Theme.of(context).accentColor;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    if (!widget.isMyProfile) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    return FutureBuilder(
      future: _buildAddress,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.only(
              top: 8.0,
              right: 25.0,
              bottom: 5.0,
            ),
            decoration: BoxDecoration(
              color: _primarySwatch.withOpacity(0.60),
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(50.0),
                bottomRight: const Radius.circular(50.0),
              ),
            ),
            child: ListTile(
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Icon(
                    Icons.map_outlined,
                    color: Colors.black,
                  ),
                  const Text(
                    'Address',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 15.0,
                    width: 15.0,
                    child: const CircularProgressIndicator(color: Colors.white),
                  )
                ],
              ),
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.only(
            top: 8.0,
            right: 25.0,
            bottom: 5.0,
          ),
          decoration: BoxDecoration(
            color: _primarySwatch.withOpacity(0.60),
            borderRadius: BorderRadius.only(
              topRight: const Radius.circular(50.0),
              bottomRight: const Radius.circular(50.0),
            ),
          ),
          child: ListTile(
            leading: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const Icon(
                  Icons.map_outlined,
                  color: Colors.black,
                ),
                const Text(
                  'Address',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: const ButtonStyle(
                        splashFactory: NoSplash.splashFactory),
                    onLongPress: () {
                      copyHandler(myUsername);
                    },
                    onPressed: () {
                      MapScreenArgs args = MapScreenArgs(
                          address: widget.additionalAddress,
                          addressName: widget.additionalAddressName);
                      Navigator.pushNamed(context, RouteGenerator.fullMapScreen,
                          arguments: args);
                    },
                    child: OptimisedText(
                      minWidth: _deviceWidth * 0.01,
                      minHeight: _deviceHeight * 0.04,
                      maxHeight: _deviceHeight * 0.04,
                      maxWidth: _deviceWidth * 0.55,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (widget.additionalAddressName != '')
                            ? '${widget.additionalAddressName}'
                            : theAddress,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: _accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

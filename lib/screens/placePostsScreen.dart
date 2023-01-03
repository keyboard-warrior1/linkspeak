import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/placesScreenProvider.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/places/placePosts.dart';
import '../widgets/share/shareWidget.dart';

class PlacePostsScreen extends StatefulWidget {
  final dynamic placeID;
  final dynamic locationName;
  final dynamic location;
  const PlacePostsScreen(
      {required this.locationName,
      required this.location,
      required this.placeID});
  static bool shareSheetOpen = false;
  static late PersistentBottomSheetController? _shareController;
  static void sharePost(
      BuildContext context, String postID, String clubName, bool isClubPost) {
    _shareController = showBottomSheet(
      context: context,
      builder: (context) {
        return ShareWidget(
            isInFeed: false,
            bottomSheetController: _shareController,
            postID: postID,
            clubName: clubName,
            isClubPost: isClubPost,
            isFlare: false,
            flarePoster: '',
            collectionID: '',
            flareID: '');
      },
      backgroundColor: Colors.transparent,
    );
    PlacePostsScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      PlacePostsScreen.shareSheetOpen = false;
    });
  }

  @override
  _PlacePostsScreenState createState() => _PlacePostsScreenState();
}

class _PlacePostsScreenState extends State<PlacePostsScreen> {
  static const String apiKey = 'AIzaSyDXnNHNEwi0EnMoqa6736wkj99FQadBzvg';
  final helper = PlacesScreenProvider();
  dynamic stateAddress;
  dynamic stateAddressName;
  late GooglePlace googlePlace;
  Future<void>? _getPlace;
  Future<void> getPlace() async {
    late DetailsResult detailsResult;
    var result = await this.googlePlace.details.get(
          widget.placeID,
          fields: 'geometry/location',
        );
    if (result != null && result.result != null && mounted) {
      setState(() {
        detailsResult = result.result!;
      });
      final geo = detailsResult.geometry;
      final latitude = geo!.location!.lat;
      final longitude = geo.location!.lng;
      final point = GeoPoint(latitude!, longitude!);
      stateAddress = point;
    }
  }

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(apiKey);
    stateAddress = widget.location;
    stateAddressName = widget.locationName;
    if (widget.placeID != null) {
      _getPlace = getPlace();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    String _displayName = stateAddressName;
    if (stateAddressName.length > 25) {
      _displayName = '${stateAddressName.substring(0, 25).trim()}..';
    }
    return Scaffold(
        floatingActionButton: null,
        appBar: null,
        backgroundColor: Colors.white,
        body: SafeArea(
            child: ChangeNotifierProvider<PlacesScreenProvider>.value(
                value: helper,
                child: FutureBuilder(
                    future: (widget.placeID != null) ? _getPlace : null,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return SizedBox(
                            height: _deviceHeight,
                            width: _deviceWidth,
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SettingsBar(_displayName),
                                  const Spacer(),
                                  const SizedBox(
                                      height: 30.0,
                                      width: 30.0,
                                      child: const Center(
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 1.50))),
                                  const Spacer()
                                ]));

                      if (snapshot.hasError)
                        return SizedBox(
                            height: _deviceHeight,
                            width: _deviceWidth,
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SettingsBar(_displayName),
                                  const Spacer(),
                                  Center(
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                        Text(lang.clubs_adminScreen2,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(width: 15.0),
                                        TextButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<Color?>(
                                                        _primaryColor),
                                                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                                    const EdgeInsets.all(0.0)),
                                                shape: MaterialStateProperty.all<OutlinedBorder?>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.0)))),
                                            onPressed: () {
                                              setState(() {
                                                _getPlace = getPlace();
                                              });
                                            },
                                            child: Center(
                                                child: Text(lang.clubs_adminScreen3,
                                                    style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))
                                      ])),
                                  const Spacer()
                                ]));

                      return Builder(builder: (context) {
                        Provider.of<PlacesScreenProvider>(context,
                                listen: false)
                            .setLocationName(stateAddressName);
                        Provider.of<PlacesScreenProvider>(context,
                                listen: false)
                            .setLocation(stateAddress);
                        return const PlacePosts();
                      });
                    }))));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../providers/addPostScreenState.dart';

class PickAddressScreen extends StatefulWidget {
  final dynamic isInPost;
  final dynamic somethingChanged;
  final dynamic changeAddress;
  final dynamic changeAddressName;
  final dynamic changeStateAddressName;
  final dynamic changePoint;
  const PickAddressScreen({
    required this.isInPost,
    required this.somethingChanged,
    required this.changeAddress,
    required this.changeAddressName,
    required this.changeStateAddressName,
    required this.changePoint,
  });

  @override
  _PickAddressScreenState createState() => _PickAddressScreenState();
}

class _PickAddressScreenState extends State<PickAddressScreen> {
  bool isLoading = false;
  static const String apiKey = 'AIzaSyDXnNHNEwi0EnMoqa6736wkj99FQadBzvg';
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    googlePlace = GooglePlace(apiKey);
    super.initState();
  }

  Future<void> pickLocation(
    String placeId,
    String shownName,
    void Function(dynamic) changePostAddress,
    void Function(String) changePostAddressName,
  ) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading', dismissOnTap: true);
      late DetailsResult detailsResult;
      var result = await this.googlePlace.details.get(placeId);
      if (result != null && result.result != null && mounted) {
        setState(() {
          detailsResult = result.result!;
        });
        final geo = detailsResult.geometry;
        final latitude = geo!.location!.lat;
        final longitude = geo.location!.lng;
        final point = GeoPoint(latitude!, longitude!);
        if (widget.isInPost) {
          changePostAddress(point);
          changePostAddressName(shownName);
          widget.changePoint(point);
        } else {
          widget.changeAddress(point);
          widget.changeAddressName(shownName);
          widget.somethingChanged();
        }
        widget.changeStateAddressName(shownName);
        EasyLoading.dismiss();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final void Function(dynamic) changePostAddress =
        Provider.of<NewPostHelper>(context, listen: false).changeLocation;
    final void Function(String) changePostAddressName =
        Provider.of<NewPostHelper>(context, listen: false).changeLocationName;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Search",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                    } else {
                      if (predictions.length > 0 && mounted) {
                        setState(() {
                          predictions = [];
                        });
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor,
                          child: Icon(
                            Icons.location_pin,
                            color: _accentColor,
                          ),
                        ),
                        title: Text(predictions[index].description!),
                        onTap: () {
                          if (isLoading) {
                          } else {
                            pickLocation(
                              predictions[index].placeId!,
                              predictions[index].description!,
                              changePostAddress,
                              changePostAddressName,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Image.asset("assets/images/powered_by_google.png"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}

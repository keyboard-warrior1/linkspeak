import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as geoloacation;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/miniClub.dart';
import '../models/miniProfile.dart';
import '../models/screenArguments.dart';
import '../models/topicSearch.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/clubObject.dart';
import '../widgets/common/noglow.dart';
import '../widgets/misc/searchTabBar.dart';
import '../widgets/misc/userResult.dart';
import '../widgets/topics/topicResult.dart';

class SearchTab extends StatefulWidget {
  const SearchTab();
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with SingleTickerProviderStateMixin {
  static const String apiKey = 'AIzaSyDXnNHNEwi0EnMoqa6736wkj99FQadBzvg';
  late GooglePlace googlePlace;
  final FocusNode _searchNode = FocusNode();
  bool userSearchLoading = false;
  bool topicSearchLoading = false;
  bool clubSearchLoading = false;
  bool placeSearchLoading = false;
  bool haveLocation = true;
  LatLon? userLocation;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final TabController _controller;
  final TextEditingController _textController = TextEditingController();
  Random random = Random();
  List<MiniProfile> userSearchResults = [];
  List<TopicSearchResult> topicSearchResults = [];
  List<MiniClub> clubSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> placeSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _userDocs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _topicDocs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _clubDocs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _placeDocs = [];
  List<AutocompletePrediction> predictions = [];
  bool _clearable = false;
  int index = 0;
  _handleTabSelection() {
    if (_controller.indexIsChanging) {
      setState(() {
        index = _controller.index;
      });
    }
  }

  Future<void> getAndSetLocation(String myUsername) async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final myLocations = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('My Locations')
          .doc();
      geoloacation.Location location = geoloacation.Location();
      var _locationData = await location.getLocation();
      final latitude = _locationData.latitude;
      final longitude = _locationData.longitude;
      setState(() {
        haveLocation = true;
        userLocation = LatLon(latitude!, longitude!);
      });
      final newAddress = GeoPoint(latitude!, longitude!);
      final placemark =
          await geocoder.placemarkFromCoordinates(latitude, longitude);
      final cityName = placemark[0].locality!;
      final countryName = placemark[0].country!;
      await myLocations.set({
        'location name': '$cityName, $countryName',
        'coordinates': newAddress,
        'date': DateTime.now(),
        'took in post': false,
        'took in profile': false,
        'took in chat': false,
        'took in place search': true,
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> initScreen(String myUsername) async {
    final status = await Permission.location.status;
    final isGranted = status.isGranted;
    if (isGranted) {
      final myLocations = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('My Locations')
          .doc();
      geoloacation.Location location = geoloacation.Location();
      var _locationData = await location.getLocation();
      final latitude = _locationData.latitude;
      final longitude = _locationData.longitude;
      final newAddress = GeoPoint(latitude!, longitude!);
      final placemark =
          await geocoder.placemarkFromCoordinates(latitude, longitude);
      final cityName = placemark[0].locality!;
      final countryName = placemark[0].country!;
      await myLocations.set({
        'location name': '$cityName, $countryName',
        'coordinates': newAddress,
        'date': DateTime.now(),
        'took in post': false,
        'took in profile': false,
        'took in chat': false,
        'took in place search': true,
      });
      setState(() {
        userLocation = LatLon(latitude, longitude);
      });
    } else {
      setState(() {
        haveLocation = false;
      });
    }
  }

  Future<void> getCollections() async {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final imManagement = myUsername.startsWith('Linkspeak');
    final usersCollection = await firestore.collection('Users').get();
    final topicsCollection = await firestore.collection('Topics').get();
    final placesCollection = await firestore.collection('Places').get();
    final clubsCollection = imManagement
        ? await firestore.collection('Clubs').get()
        : await firestore
            .collection('Clubs')
            .where('Visibility', isNotEqualTo: 'Hidden')
            .get();
    final usersDocs = usersCollection.docs;
    final topicsDocs = topicsCollection.docs;
    final clubsDocs = clubsCollection.docs;
    final placeDocs = placesCollection.docs;
    _userDocs = usersDocs;
    _topicDocs = topicsDocs;
    _clubDocs = clubsDocs;
    _placeDocs = placeDocs;
  }

  void getUserResults(String name) {
    final lowerCaseName = name.toLowerCase();
    _userDocs.forEach((doc) {
      if (userSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String username = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
      }
    });
  }

  void getTopicResults(String nam) {
    final lowerCaseName = nam.toLowerCase();
    _topicDocs.forEach((doc) {
      if (topicSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String name = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !topicSearchResults.any((result) => result.topicName == name)) {
          final result = TopicSearchResult(topicName: name);
          topicSearchResults.add(result);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !topicSearchResults.any((result) => result.topicName == name)) {
          final result = TopicSearchResult(topicName: name);
          topicSearchResults.add(result);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !topicSearchResults.any((result) => result.topicName == name)) {
          final result = TopicSearchResult(topicName: name);
          topicSearchResults.add(result);
          setState(() {});
        }
      }
    });
  }

  void getClubResults(String nam) {
    _clubDocs.forEach((doc) {
      if (clubSearchResults.length < 20) {
        final lowerCaseName = nam.toLowerCase();
        final String name = doc.id;
        final String id = doc.id.toString().toLowerCase();
        if (id.startsWith(lowerCaseName) &&
            !clubSearchResults.any((result) => result.clubName == name)) {
          final result = MiniClub(clubName: name);
          clubSearchResults.add(result);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !clubSearchResults.any((result) => result.clubName == name)) {
          final result = MiniClub(clubName: name);
          clubSearchResults.add(result);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !clubSearchResults.any((result) => result.clubName == name)) {
          final result = MiniClub(clubName: name);
          clubSearchResults.add(result);
          setState(() {});
        }
      }
    });
  }

  void getPlaceResults(String nam) {
    final lowerCaseName = nam.toLowerCase();
    _placeDocs.forEach((doc) {
      if (placeSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String name = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !placeSearchResults.any((result) => result.id == name)) {
          placeSearchResults.add(doc);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !placeSearchResults.any((result) => result.id == name)) {
          placeSearchResults.add(doc);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !placeSearchResults.any((result) => result.id == name)) {
          placeSearchResults.add(doc);
          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCollections();
    // final String myUsername =
    //     Provider.of<MyProfile>(context, listen: false).getUsername;
    // initScreen(myUsername);
    _controller = TabController(length: 4, vsync: this);
    googlePlace = GooglePlace(apiKey);
    _controller.addListener(_handleTabSelection);
    _textController.addListener(() {
      if (_textController.value.text.isNotEmpty) {
        if (!_clearable)
          setState(() {
            _clearable = true;
          });
      } else {}

      if (_textController.value.text.isEmpty) {
        if (_clearable)
          setState(() {
            _clearable = false;
          });
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _textController.removeListener(() {});
    _controller.dispose();
    _textController.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    // final String myUsername =
    //     Provider.of<MyProfile>(context, listen: false).getUsername;
    final Container _searchField = Container(
        color: Colors.white,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  tooltip: 'back',
                  splashColor: Colors.black38,
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
              SizedBox(
                  width: _deviceWidth * 0.75,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                          focusNode: _searchNode,
                          onChanged: (text) async {
                            if (text.isEmpty) {
                              if (userSearchResults.isNotEmpty)
                                userSearchResults.clear();
                              if (topicSearchResults.isNotEmpty)
                                topicSearchResults.clear();
                              if (clubSearchResults.isNotEmpty)
                                clubSearchResults.clear();
                              if (placeSearchResults.isNotEmpty)
                                placeSearchResults.clear();
                              if (predictions.isNotEmpty) {
                                predictions.clear();
                                setState(() {});
                              }
                              return;
                            } else {
                              if (index == 0) {
                                if (!userSearchLoading) {
                                  if (userSearchResults.isNotEmpty)
                                    userSearchResults.clear();
                                }
                                if (!userSearchLoading) {
                                  setState(() {
                                    userSearchLoading = true;
                                  });
                                }
                                getUserResults(text);

                                setState(() {
                                  userSearchLoading = false;
                                });
                              } else if (index == 1) {
                                if (!topicSearchLoading) {
                                  if (topicSearchResults.isNotEmpty)
                                    topicSearchResults.clear();
                                }
                                if (!topicSearchLoading) {
                                  setState(() {
                                    topicSearchLoading = true;
                                  });
                                }
                                getTopicResults(text);
                                setState(() {
                                  topicSearchLoading = false;
                                });
                              } else if (index == 2) {
                                if (!clubSearchLoading) {
                                  if (clubSearchResults.isNotEmpty)
                                    clubSearchResults.clear();
                                }
                                if (!clubSearchLoading) {
                                  setState(() {
                                    clubSearchLoading = true;
                                  });
                                }
                                getClubResults(text);
                                setState(() {
                                  clubSearchLoading = false;
                                });
                              } else if (index == 3) {
                                if (!placeSearchLoading) {
                                  if (placeSearchResults.isNotEmpty)
                                    placeSearchResults.clear();
                                }
                                if (!placeSearchLoading) {
                                  setState(() {
                                    placeSearchLoading = true;
                                  });
                                }
                                getPlaceResults(text);
                                setState(() {
                                  placeSearchLoading = false;
                                });
                                // if (text.isNotEmpty) {
                                //   autoCompleteSearch(text);
                                // } else {
                                //   if (predictions.length > 0 && mounted) {
                                //     setState(() {
                                //       predictions = [];
                                //     });
                                //   }
                                // }
                              }
                            }
                          },
                          controller: _textController,
                          decoration: InputDecoration(
                              prefixIcon: ((index == 0 || index == 2) && !kIsWeb)
                                  ? IconButton(
                                      onPressed: () {
                                        _searchNode.unfocus();
                                        _searchNode.canRequestFocus = false;
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          _searchNode.canRequestFocus = true;
                                        });
                                        Navigator.pushNamed(
                                          context,
                                          RouteGenerator.scannerScreen,
                                          arguments: index == 0 ? false : true,
                                        );
                                      },
                                      icon: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Icon(
                                                    Icons.qr_code_scanner,
                                                    color: Colors.black),
                                                const Text('SCAN',
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ])))
                                  : const Icon(Icons.search,
                                      color: Colors.grey),
                              suffixIcon: (_clearable)
                                  ? IconButton(
                                      splashColor: Colors.transparent,
                                      tooltip: 'Clear',
                                      onPressed: () {
                                        setState(() {
                                          _textController.clear();
                                          userSearchResults.clear();
                                          topicSearchResults.clear();
                                          clubSearchResults.clear();
                                          placeSearchResults.clear();
                                          predictions.clear();
                                          _clearable = false;
                                        });
                                      },
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey))
                                  : null,
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              hintText: 'Search Linkspeak',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none)))))
            ]));
    final Widget _searchBar = SearchTabBar(_controller);
    final Widget _searchResults = Container(
        color: Colors.white,
        child: SizedBox(
            height: _deviceHeight * 0.90,
            width: _deviceWidth,
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  Noglow(
                      child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 50.0),
                          children: <Widget>[
                        Column(children: <Widget>[
                          if (_textController.value.text.isEmpty)
                            Container(
                                child: const Center(
                                    child: const Text('Search for people',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (_textController.value.text.isNotEmpty &&
                              userSearchResults.isEmpty &&
                              !userSearchLoading)
                            Container(
                                child: const Center(
                                    child: const Text('No results found',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (userSearchResults.isNotEmpty &&
                              !userSearchLoading)
                            ...userSearchResults.take(20).map((result) {
                              final int index =
                                  userSearchResults.indexOf(result);
                              final current = userSearchResults[index];
                              final username = current.username;
                              return UserResult(username: username);
                            })
                        ])
                      ])),
                  Noglow(
                      child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 50.0),
                          children: <Widget>[
                        Column(children: <Widget>[
                          if (_textController.value.text.isEmpty)
                            Container(
                                child: const Center(
                                    child: const Text('Search for topics',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (_textController.value.text.isNotEmpty &&
                              topicSearchResults.isEmpty &&
                              !topicSearchLoading)
                            Container(
                                child: const Center(
                                    child: const Text('No results found',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (topicSearchResults.isNotEmpty &&
                              !topicSearchLoading)
                            ...topicSearchResults.take(20).map((result) {
                              final int index =
                                  topicSearchResults.indexOf(result);
                              final current = topicSearchResults[index];
                              final name = current.topicName;
                              return Container(
                                  key: ValueKey<String>(name),
                                  child: TopicResult(name));
                            }),
                          if (topicSearchLoading)
                            SizedBox(
                                height: _deviceHeight * 0.90,
                                width: _deviceWidth,
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const <Widget>[
                                      const Center(
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 1.50))
                                    ]))
                        ])
                      ])),
                  Noglow(
                      child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 50.0),
                          children: <Widget>[
                        Column(children: <Widget>[
                          if (_textController.value.text.isEmpty)
                            Container(
                                child: const Center(
                                    child: const Text('Search for clubs',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (_textController.value.text.isNotEmpty &&
                              clubSearchResults.isEmpty &&
                              !clubSearchLoading)
                            Container(
                                child: const Center(
                                    child: const Text('No results found',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (clubSearchResults.isNotEmpty &&
                              !clubSearchLoading)
                            ...clubSearchResults.take(20).map((result) {
                              final int index =
                                  clubSearchResults.indexOf(result);
                              final current = clubSearchResults[index];
                              final name = current.clubName;
                              return ClubObject(clubName: name);
                            }),
                          if (clubSearchLoading)
                            SizedBox(
                                height: _deviceHeight * 0.90,
                                width: _deviceWidth,
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const <Widget>[
                                      const Center(
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 1.50))
                                    ]))
                        ])
                      ])),
                  Noglow(
                      child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 50.0),
                          children: <Widget>[
                        Column(children: <Widget>[
                          // if (!haveLocation &&
                          //     _textController.value.text.isEmpty)
                          //   const SizedBox(height: 10.0),
                          // if (!haveLocation &&
                          //     _textController.value.text.isEmpty)
                          //   const Text('Location disabled',
                          //       style: TextStyle(
                          //           fontSize: 15.0,
                          //           color: Colors.black,
                          //           fontWeight: FontWeight.bold)),
                          // if (!haveLocation &&
                          //     _textController.value.text.isEmpty)
                          //   TextButton(
                          //       onPressed: () => getAndSetLocation(myUsername),
                          //       child: const Text('Turn on')),
                          if (_textController.value.text.isEmpty &&
                              haveLocation)
                            Container(
                                child: const Center(
                                    child: const Text('Search for places',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (_textController.value.text.isNotEmpty &&
                              placeSearchResults.isEmpty &&
                              !placeSearchLoading)
                            Container(
                                child: const Center(
                                    child: const Text('No results found',
                                        style: const TextStyle(
                                            color: Colors.grey)))),
                          if (placeSearchResults.isNotEmpty &&
                              !placeSearchLoading)
                            ...placeSearchResults.take(20).map((result) {
                              final int index =
                                  placeSearchResults.indexOf(result);
                              final current = placeSearchResults[index];
                              GeoPoint? point;
                              if (current.data().containsKey('point'))
                                point = current.get('point');
                              return ListTile(
                                  leading: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: const Icon(Icons.location_pin,
                                          color: Colors.black)),
                                  title: Text(current.id),
                                  onTap: () {
                                    PlaceScreenArgs args = PlaceScreenArgs(
                                        locationName: current.id,
                                        location: point,
                                        placeID: current.id);
                                    Navigator.pushNamed(context,
                                        RouteGenerator.placePostsScreen,
                                        arguments: args);
                                  });
                            })
                        ])
                      ]))
                ])));
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: null,
            body: SafeArea(
                child: Noglow(
                    child: SingleChildScrollView(
                        child: SizedBox(
                            height: _deviceHeight,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  _searchField,
                                  _searchBar,
                                  Expanded(child: _searchResults)
                                ])))))));
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value,
        radius: haveLocation ? 50000 : null,
        location: haveLocation ? userLocation : null);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}

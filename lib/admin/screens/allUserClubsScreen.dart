import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/screenArguments.dart';
import '../../general.dart';
import '../../routes.dart';
import '../../widgets/common/settingsBar.dart';

class AllUserClubScreen extends StatefulWidget {
  final dynamic isUser;
  const AllUserClubScreen(this.isUser);

  @override
  State<AllUserClubScreen> createState() => _AllUserClubScreenState();
}

class _AllUserClubScreenState extends State<AllUserClubScreen> {
  final firestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();
  late Future<void> getItems;
  List<DocumentSnapshot> products = [];
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> _getItems() async {
    final collection = widget.isUser
        ? firestore
            .collection('Users')
            .orderBy('Date created', descending: true)
            .limit(50)
        : firestore
            .collection('Clubs')
            .orderBy('date created', descending: true)
            .limit(50);
    final getCollection = await collection.get();
    if (getCollection.docs.length < 50) isLastPage = true;
    products.addAll(getCollection.docs);
    if (mounted) setState(() {});
  }

  Future<void> _getMoreItems() async {
    if (!isLoading) {
      setState(() => isLoading = true);
      final collection = widget.isUser
          ? firestore.collection('Users')
          : firestore.collection('Clubs');
      final orderBy = widget.isUser ? 'Date created' : 'date created';
      if (products.isNotEmpty) {
        var lastID = products.last.id;
        final lastDoc = await collection.doc(lastID).get();
        final next50 = await collection
            .orderBy(orderBy, descending: true)
            .startAfterDocument(lastDoc)
            .limit(50)
            .get();
        products.addAll(next50.docs);
        if (next50.docs.length < 50) isLastPage = true;
        setState(() => isLoading = false);
      } else {
        final next50 =
            await collection.orderBy(orderBy, descending: true).limit(50).get();
        products.addAll(next50.docs);
        if (next50.docs.length < 50) isLastPage = true;
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pullRefresh() async {
    products.clear();
    setState(() {
      isLastPage = false;
      getItems = _getItems();
    });
  }

  @override
  void initState() {
    super.initState();
    getItems = _getItems();
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            _getMoreItems();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {});
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    var _primarySwatch = colorScheme.primary;
    var _accentColor = colorScheme.secondary;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                child: SizedBox(
                    height: height,
                    width: width,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SettingsBar(widget.isUser
                              ? General.language(context).admin_alluserclubs1
                              : General.language(context).admin_alluserclubs2),
                          Expanded(
                              child: FutureBuilder(
                            future: getItems,
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return const Center(child: SizedBox());

                              return Container(
                                  color: Colors.white,
                                  child: RefreshIndicator(
                                    backgroundColor: _primarySwatch,
                                    displacement: 2.0,
                                    color: _accentColor,
                                    onRefresh: () => _pullRefresh(),
                                    child: ListView.builder(
                                        itemCount: products.length,
                                        controller: scrollController,
                                        itemBuilder: (_, index) {
                                          final current = products[index];
                                          final id = current.id;
                                          return TextButton(
                                              key: ValueKey<String>(id),
                                              onPressed: () {
                                                if (widget.isUser) {
                                                  var args =
                                                      OtherProfileScreenArguments(
                                                          otherProfileId: id);
                                                  Navigator.pushNamed(
                                                      context,
                                                      RouteGenerator
                                                          .posterProfileScreen,
                                                      arguments: args);
                                                } else {
                                                  var args = ClubScreenArgs(id);
                                                  Navigator.pushNamed(context,
                                                      RouteGenerator.clubScreen,
                                                      arguments: args);
                                                }
                                              },
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(id)
                                                  ]));
                                        }),
                                  ));
                            },
                          ))
                        ])))));
  }
}

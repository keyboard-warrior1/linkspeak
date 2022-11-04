import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/common/settingsBar.dart';
import '../widgets/Archives/archiveFindButton.dart';
import '../widgets/Archives/archiveWidget.dart';

class ArchiveItemsScreen extends StatefulWidget {
  final dynamic deletedPosts;
  final dynamic deletedComments;
  final dynamic deletedReplies;
  final dynamic deletedFlares;
  final dynamic deletedUsers;
  final dynamic deletedFlareProfiles;
  final dynamic unbannedUsers;
  final dynamic unprohibitedClubs;
  final dynamic disabledClubs;
  final dynamic showFinder;
  final dynamic findMode;
  const ArchiveItemsScreen(
      {required this.deletedPosts,
      required this.deletedComments,
      required this.deletedReplies,
      required this.deletedUsers,
      required this.deletedFlareProfiles,
      required this.deletedFlares,
      required this.unbannedUsers,
      required this.unprohibitedClubs,
      required this.disabledClubs,
      required this.showFinder,
      required this.findMode});

  @override
  State<ArchiveItemsScreen> createState() => _ArchiveItemsScreenState();
}

class _ArchiveItemsScreenState extends State<ArchiveItemsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();
  List<DocumentSnapshot> products = [];
  bool isLoading = false;
  bool exists = false;
  bool hasMore = true;
  int documentLimit = 30;
  DocumentSnapshot? firstDocument;
  DocumentSnapshot? lastDocument;
  StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get _streamController => _controller.stream;

  String buildBarTitle() {
    if (widget.deletedPosts) return 'Deleted Posts';
    if (widget.deletedComments) return 'Deleted Comments';
    if (widget.deletedReplies) return 'Deleted Replies';
    if (widget.deletedFlares) return 'Deleted Flares';
    if (widget.deletedUsers) return 'Deleted Users';
    if (widget.deletedFlareProfiles) return 'Deleted Flare Profiles';
    if (widget.unbannedUsers) return 'Unbanned Users';
    if (widget.unprohibitedClubs) return 'Unprohibited Clubs';
    if (widget.disabledClubs) return 'Disabled Clubs';
    return '';
  }

  String buildCollectionAddress() {
    if (widget.deletedPosts) return 'Deleted Posts';
    if (widget.deletedComments) return 'Deleted Comments';
    if (widget.deletedReplies) return 'Deleted Replies';
    if (widget.deletedFlares) return 'Deleted Flares';
    if (widget.deletedUsers) return 'Deleted Users';
    if (widget.deletedFlareProfiles) return 'Deleted Flare Profiles';
    if (widget.unbannedUsers) return 'Banned';
    if (widget.unprohibitedClubs) return 'Prohibited Clubs';
    if (widget.disabledClubs) return 'Disabled Clubs';
    return '';
  }

  String? buildWhere() {
    if (widget.unbannedUsers) {
      return 'isBanned';
    } else if (widget.unprohibitedClubs) {
      return 'isBanned';
    } else {
      return null;
    }
  }

  bool? buildWhereIs() {
    if (widget.unbannedUsers) {
      return false;
    } else if (widget.unprohibitedClubs) {
      return false;
    } else {
      return null;
    }
  }

  String buildOrderBy() {
    if (widget.deletedPosts) return 'date deleted';
    if (widget.deletedComments) return 'date deleted';
    if (widget.deletedReplies) return 'date deleted';
    if (widget.deletedFlares) return 'date deleted';
    if (widget.deletedUsers) return 'Date deleted';
    if (widget.deletedFlareProfiles) return 'date deleted';
    if (widget.unbannedUsers) return 'ban date';
    if (widget.unprohibitedClubs) return 'ban date';
    if (widget.disabledClubs) return 'date';
    return '';
  }

  Future<void> getProducts() async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    final String collectionAddress = buildCollectionAddress();
    final String? where = buildWhere();
    final bool? whereIs = buildWhereIs();
    final String orderBy = buildOrderBy();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = where == null
          ? await firestore
              .collection(collectionAddress)
              .orderBy(orderBy, descending: true)
              .limit(documentLimit)
              .get()
          : await firestore
              .collection(collectionAddress)
              .where(where, isEqualTo: whereIs!)
              .orderBy(orderBy, descending: true)
              .limit(documentLimit)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        firstDocument = querySnapshot.docs[0];
        querySnapshot.docs.forEach((element) {
          if (!products.any((element2) => element2.id == element.id))
            products.add(element);
        });
      }
    } else {
      querySnapshot = where == null
          ? await firestore
              .collection(collectionAddress)
              .orderBy(orderBy, descending: true)
              .startAfterDocument(lastDocument!)
              .limit(documentLimit)
              .get()
          : await firestore
              .collection(collectionAddress)
              .where(where, isEqualTo: whereIs!)
              .orderBy(orderBy, descending: true)
              .startAfterDocument(lastDocument!)
              .limit(documentLimit)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        products.addAll(querySnapshot.docs);
      }
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      _controller.sink.add(products);
    }
    setState(() {
      isLoading = false;
    });
  }

  void onChangeData(List<DocumentChange> documentChanges) {
    documentChanges.forEach((productChange) {
      if (productChange.type == DocumentChangeType.removed) {
        products.removeWhere((product) {
          return productChange.doc.id == product.id;
        });
      } else {
        if (productChange.type == DocumentChangeType.modified) {
          int indexWhere = products.indexWhere((product) {
            return productChange.doc.id == product.id;
          });

          if (indexWhere >= 0) {
            products[indexWhere] = productChange.doc;
          }
        }
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final String collectionAddress = buildCollectionAddress();
    final String? where = buildWhere();
    final bool? whereIs = buildWhereIs();
    final String orderBy = buildOrderBy();
    final theQuery = where == null
        ? firestore
            .collection(collectionAddress)
            .orderBy(orderBy, descending: true)
        : firestore
            .collection(collectionAddress)
            .where(where, isEqualTo: whereIs!)
            .orderBy(orderBy, descending: true);
    firestore.collection(collectionAddress).get().then((value) {
      if (value.docs.isNotEmpty) {
        exists = true;
        getProducts().then((value) {
          if (firstDocument != null) {
            theQuery
                .endBeforeDocument(firstDocument!)
                .snapshots()
                .listen((event) {
              if (event.docs.isNotEmpty) {
                if (!products.any((element) => element.id == event.docs[0].id))
                  products.insert(0, event.docs[0]);
                setState(() {});
              }
            });
          }
        });
        theQuery.snapshots().listen((event) {
          onChangeData(event.docChanges);
        });
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            if (!hasMore) {
            } else {
              if (!isLoading) {
                getProducts();
              }
            }
          }
        });
      } else {
        firestore
            .collection(collectionAddress)
            .limit(1)
            .snapshots()
            .listen((event) {
          if (event.docs.isNotEmpty && firstDocument == null && !exists) {
            exists = true;
            firstDocument = event.docs[0];
            if (!products.any((element) => element.id == event.docs[0].id))
              products.insert(0, event.docs[0]);
            setState(() {});
            firestore.collection(collectionAddress).get().then((value) {
              if (value.docs.isNotEmpty) {
                exists = true;
                getProducts().then((value) {
                  if (firstDocument != null) {
                    theQuery
                        .endBeforeDocument(firstDocument!)
                        .snapshots()
                        .listen((event) {
                      if (event.docs.isNotEmpty) {
                        if (!products
                            .any((element) => element.id == event.docs[0].id))
                          products.insert(0, event.docs[0]);
                        setState(() {});
                      }
                    });
                  }
                });
              }
            });
          }
        });
        theQuery.snapshots().listen((event) {
          onChangeData(event.docChanges);
        });
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
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton:
            widget.showFinder ? ArchiveFindFab(widget.findMode) : null,
        floatingActionButtonLocation:
            widget.showFinder ? FloatingActionButtonLocation.endFloat : null,
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
                          SettingsBar(buildBarTitle()),
                          Expanded(
                              child: StreamBuilder<
                                      List<DocumentSnapshot<Object?>>>(
                                  stream: exists ? _streamController : null,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      return const Center(
                                          child: const SizedBox());
                                    return Container(
                                        color: Colors.white,
                                        child: ListView.builder(
                                            itemCount: products.length,
                                            controller: scrollController,
                                            itemBuilder: (_, index) {
                                              final current = products[index];
                                              final id = current.id;
                                              final docAddress =
                                                  '${buildCollectionAddress()}/$id';
                                              return ArchiveWidget(
                                                  collectionName:
                                                      buildCollectionAddress(),
                                                  docAddress: docAddress,
                                                  id: id,
                                                  doc: current);
                                            }));
                                  })),
                        ])))));
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/common/settingsBar.dart';
import '../widgets/Profanity/profanityWidget.dart';

class ProfanityItemsScreen extends StatefulWidget {
  final dynamic isProfileBio;
  final dynamic isClubAbout;
  final dynamic isFlareProfileBio;
  final dynamic isPostDescription;
  final dynamic isPostComments;
  final dynamic isPostCommentReplies;
  final dynamic isFlareComments;
  final dynamic isFlareCommentReplies;
  const ProfanityItemsScreen(
      {required this.isProfileBio,
      required this.isClubAbout,
      required this.isFlareProfileBio,
      required this.isPostDescription,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlareComments,
      required this.isFlareCommentReplies});

  @override
  State<ProfanityItemsScreen> createState() => _ProfanityItemsScreenState();
}

class _ProfanityItemsScreenState extends State<ProfanityItemsScreen> {
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
  String buildCollectionAddress() {
    //order by'date'
    if (widget.isProfileBio) return 'Profanity/Profiles/Profiles';
    if (widget.isClubAbout) return 'Profanity/Clubs/Clubs';
    if (widget.isFlareProfileBio) return 'Profanity/Flare Profiles/Profiles';
    if (widget.isPostDescription) return 'Profanity/Posts/Posts';
    if (widget.isPostComments) return 'Profanity/Comments/Comments';
    if (widget.isPostCommentReplies) return 'Profanity/Replies/Replies';
    if (widget.isFlareComments) return 'Profanity/Flare Comments/Comments';
    if (widget.isFlareCommentReplies) return 'Profanity/Flare Replies/Replies';
    return 'Profanity/Flares/Flares';
  }

  String buildBarTitle() {
    if (widget.isProfileBio) return 'Profile Bios';
    if (widget.isClubAbout) return 'Club Descriptions';
    if (widget.isFlareProfileBio) return 'Flare Profile Bios';
    if (widget.isPostDescription) return 'Post Descriptions';
    if (widget.isPostComments) return 'Post Comments';
    if (widget.isPostCommentReplies) return 'Post Comment Replies';
    if (widget.isFlareComments) return 'Flare Comments';
    if (widget.isFlareCommentReplies) return 'Flare Comment Replies';
    return 'Flare Collection Titles';
  }

  Future<void> getProducts() async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection(buildCollectionAddress())
          .orderBy('date', descending: true)
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
      querySnapshot = await firestore
          .collection(buildCollectionAddress())
          .orderBy('date', descending: true)
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
    final theQuery = firestore
        .collection(buildCollectionAddress())
        .orderBy('date', descending: true);
    firestore.collection(buildCollectionAddress()).get().then((value) {
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
            .collection(buildCollectionAddress())
            .limit(1)
            .snapshots()
            .listen((event) {
          if (event.docs.isNotEmpty && firstDocument == null && !exists) {
            exists = true;
            firstDocument = event.docs[0];
            if (!products.any((element) => element.id == event.docs[0].id))
              products.insert(0, event.docs[0]);
            setState(() {});
            firestore.collection(buildCollectionAddress()).get().then((value) {
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
                                              return ProfanityWidget(
                                                  collectionName:
                                                      buildCollectionAddress(),
                                                  docAddress: docAddress,
                                                  id: id,
                                                  doc: current,
                                                  isProfileBio:
                                                      widget.isProfileBio,
                                                  isClubAbout:
                                                      widget.isClubAbout,
                                                  isFlareProfileBio:
                                                      widget.isFlareProfileBio,
                                                  isPostDescription:
                                                      widget.isPostDescription,
                                                  isPostComments:
                                                      widget.isPostComments,
                                                  isPostCommentReplies: widget
                                                      .isPostCommentReplies,
                                                  isFlareComments:
                                                      widget.isFlareComments,
                                                  isFlareCommentReplies: widget
                                                      .isFlareCommentReplies);
                                            }));
                                  }))
                        ])))));
  }
}

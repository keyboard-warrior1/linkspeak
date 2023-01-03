import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'generalWidget.dart';

class GeneralTab extends StatefulWidget {
  final String collectionAddress;
  final dynamic where;
  final dynamic whereIS;
  final String orderBy;
  final bool isProfiles;
  final bool isClubs;
  final bool isPosts;
  final bool isPostComments;
  final bool isPostCommentReplies;
  final bool isFlares;
  final bool isFlareComments;
  final bool isFlareCommentReplies;
  final bool inReports;
  final bool inWatchlist;
  final bool inProhibited;
  final bool inBanned;
  final bool inReview;
  const GeneralTab(
      {required this.collectionAddress,
      required this.where,
      required this.whereIS,
      required this.orderBy,
      required this.isProfiles,
      required this.isClubs,
      required this.isPosts,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlares,
      required this.isFlareComments,
      required this.isFlareCommentReplies,
      required this.inReports,
      required this.inWatchlist,
      required this.inProhibited,
      required this.inBanned,
      required this.inReview});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab>
    with AutomaticKeepAliveClientMixin {
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
      querySnapshot = (widget.where == null)
          ? await firestore
              .collection(widget.collectionAddress)
              .orderBy(widget.orderBy, descending: true)
              .limit(documentLimit)
              .get()
          : await firestore
              .collection(widget.collectionAddress)
              .where(widget.where, isEqualTo: widget.whereIS)
              .orderBy(widget.orderBy, descending: true)
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
      querySnapshot = (widget.where == null)
          ? await firestore
              .collection(widget.collectionAddress)
              .orderBy(widget.orderBy, descending: true)
              .startAfterDocument(lastDocument!)
              .limit(documentLimit)
              .get()
          : await firestore
              .collection(widget.collectionAddress)
              .where(widget.where, isEqualTo: widget.whereIS)
              .orderBy(widget.orderBy, descending: true)
              .orderBy(widget.orderBy, descending: true)
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
    final theQuery = widget.where == null
        ? firestore
            .collection(widget.collectionAddress)
            .orderBy(widget.orderBy, descending: true)
        : firestore
            .collection(widget.collectionAddress)
            .where(widget.where, isEqualTo: widget.whereIS)
            .orderBy(widget.orderBy, descending: true);
    firestore.collection(widget.collectionAddress).get().then((value) {
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
            .collection(widget.collectionAddress)
            .limit(1)
            .snapshots()
            .listen((event) {
          if (event.docs.isNotEmpty && firstDocument == null && !exists) {
            exists = true;
            firstDocument = event.docs[0];
            if (!products.any((element) => element.id == event.docs[0].id))
              products.insert(0, event.docs[0]);
            setState(() {});
            firestore.collection(widget.collectionAddress).get().then((value) {
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
    super.build(context);
    return StreamBuilder<List<DocumentSnapshot<Object?>>>(
        stream: exists ? _streamController : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: const SizedBox());
          return Container(
              color: Colors.white,
              child: ListView.builder(
                  itemCount: products.length,
                  controller: scrollController,
                  itemBuilder: (_, index) {
                    final current = products[index];
                    final id = current.id;
                    return GeneralWidget(
                        collectionName: widget.collectionAddress,
                        docAddress: '${widget.collectionAddress}/$id',
                        id: id,
                        doc: current,
                        isProfiles: widget.isProfiles,
                        isClubs: widget.isClubs,
                        isPosts: widget.isPosts,
                        isPostComments: widget.isPostComments,
                        isPostCommentReplies: widget.isPostCommentReplies,
                        isFlares: widget.isFlares,
                        isFlareComments: widget.isFlareComments,
                        isFlareCommentReplies: widget.isFlareCommentReplies,
                        inReports: widget.inReports,
                        inWatchlist: widget.inWatchlist,
                        inProhibited: widget.inProhibited,
                        inBanned: widget.inBanned,
                        inReview: widget.inReview);
                  }));
        });
  }

  @override
  bool get wantKeepAlive => true;
}

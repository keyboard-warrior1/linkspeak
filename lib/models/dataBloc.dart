import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class DataBloc<T> {
  DataBloc(
      {required this.query,
      required this.documentSnapshotToT,
      this.numberToLoadAtATime = 30,
      this.numberToLoadFromNextTime = 30}) {
    objectsList = [];
    blocController = BehaviorSubject<List<T>>();
    showIndicatorController = BehaviorSubject<bool>();
  }
  Query query;
  int numberToLoadAtATime;
  int numberToLoadFromNextTime;
  Function documentSnapshotToT;
  bool showIndicator = false;
  late T dataType;
  late List<T> objectsList;
  late BehaviorSubject<List<T>> blocController;
  late BehaviorSubject<bool> showIndicatorController;
  late DocumentSnapshot firstSnapshot;
  late DocumentSnapshot lastFetchedSnapshot;

  Stream get getShowIndicatorStream => showIndicatorController.stream;
  Stream<List<T>> get dataStream => blocController.stream;
  StreamSubscription listenUp() {
    return query.endAtDocument(firstSnapshot).snapshots().listen((event) {
      if (event.docs.isNotEmpty) {
        for (var item in event.docs) {
          objectsList.add(documentSnapshotToT(item));
          blocController.sink.add(objectsList);
        }
      }
    });
  }

  Future fetchInitialData() async {
    try {
      List<DocumentSnapshot> documents =
          (await query.limit(numberToLoadAtATime).get()).docs;
      try {
        if (documents.length == 0) {
          blocController.sink.addError("No Data Available");
        } else {
          lastFetchedSnapshot = documents[documents.length - 1];
          firstSnapshot = documents[0];
        }
      } catch (_) {}
      //Convert documentSnapshots to custom object
      documents.forEach((documentSnapshot) {
        objectsList.add(documentSnapshotToT(documentSnapshot));
        blocController.sink.add(objectsList);
      });
    } catch (e) {
      blocController.sink.addError(e);
    }
  }

  Future<void> fetchNextSetOfData() async {
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList = (await query
              .startAfterDocument(lastFetchedSnapshot)
              .limit(numberToLoadFromNextTime)
              .get())
          .docs;
      if (newDocumentList.length != 0) {
        lastFetchedSnapshot = newDocumentList[newDocumentList.length - 1];
        newDocumentList.forEach((documentSnapshot) {
          objectsList.add(documentSnapshotToT(documentSnapshot));
        });
        blocController.sink.add(objectsList);
      }
    } catch (e) {
      blocController.sink.addError(e);
    }
  }

  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    blocController.close();
    showIndicatorController.close();
  }
}

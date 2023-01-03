import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import 'widgets/Misc/docDetailsDialog.dart';

class GeneralAdmin {
  static void displayDocDetails(
      {required BuildContext context,
      required DocumentSnapshot<Map<String, dynamic>> doc,
      required String actionLabel,
      required dynamic actionHandler,
      required String docAddress,
      required String resolvedCollection,
      required String resolveDocID,
      required bool showActionButton,
      required bool showCopyButton,
      required bool showDeleteButton}) async {
    final details = General.getDocData(doc);
    final docMap = doc.data();
    showDialog(
        context: context,
        builder: (_) => DocDetailDialog(
            details: details,
            docData: docMap!,
            actionLabel: actionLabel,
            actionHandler: actionHandler,
            docAddress: docAddress,
            resolvedCollection: resolvedCollection,
            resolveDocID: resolveDocID,
            showActionButton: showActionButton,
            showCopyButton: showCopyButton,
            showDeleteButton: showDeleteButton));
  }

  static Future<void> handleDocDeletion({
    required String myUsername,
    required String docAddress,
    required String resolvedCollection,
    required String resolveDocID,
    required Map<String, dynamic> resolveDocDetails,
  }) async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    var theDoc = firestore.doc(docAddress);
    var resolvedDoc = firestore
        .doc('Moderators/$myUsername/$resolvedCollection/$resolveDocID');
    batch.delete(theDoc);
    Map<String, dynamic> res = {'date resolved': DateTime.now()};
    resolveDocDetails.addAll(res);
    batch.set(resolvedDoc, resolveDocDetails, SetOptions(merge: true));
    return batch.commit();
  }
}

import 'package:flutter/material.dart';

import '../../widgets/common/settingsBar.dart';
import '../generalAdmin.dart';

class UserDailyCollectionDocsScreen extends StatefulWidget {
  final dynamic dayID;
  final dynamic userID;
  final dynamic collectionID;
  final dynamic docs;
  const UserDailyCollectionDocsScreen(
      this.dayID, this.userID, this.collectionID, this.docs);

  @override
  State<UserDailyCollectionDocsScreen> createState() =>
      _UserDailyCollectionDocsScreenState();
}

class _UserDailyCollectionDocsScreenState
    extends State<UserDailyCollectionDocsScreen> {
  Widget buildTextButton(dynamic doc) => TextButton(
      key: ValueKey<String>(doc.id),
      onPressed: () {
        GeneralAdmin.displayDocDetails(
            context: context,
            doc: doc,
            actionLabel: '',
            actionHandler: () {},
            docAddress:
                'Control/Days/${widget.dayID}/Details/Logins/${widget.userID}/${widget.collectionID}/${doc.id}',
            resolvedCollection: '',
            resolveDocID: doc.id,
            showActionButton: false,
            showCopyButton: true,
            showDeleteButton: false);
      },
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Text(doc.id)]));
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: height,
                width: width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SettingsBar('${widget.collectionID}'),
                      Expanded(
                          child: ListView.builder(
                              itemCount: widget.docs.length,
                              itemBuilder: (ctx, index) {
                                var current = widget.docs[index];
                                return buildTextButton(current);
                              }))
                    ]))));
  }
}

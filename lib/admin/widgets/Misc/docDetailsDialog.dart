import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';

import '../../../general.dart';
import '../../../providers/myProfileProvider.dart';
import '../../generalAdmin.dart';

class DocDetailDialog extends StatelessWidget {
  final String details;
  final Map<String, dynamic> docData;
  final String actionLabel;
  final dynamic actionHandler;
  final String docAddress;
  final String resolvedCollection;
  final String resolveDocID;
  final bool showActionButton;
  final bool showCopyButton;
  final bool showDeleteButton;
  const DocDetailDialog(
      {required this.details,
      required this.docData,
      required this.actionLabel,
      required this.actionHandler,
      required this.docAddress,
      required this.resolvedCollection,
      required this.resolveDocID,
      required this.showActionButton,
      required this.showCopyButton,
      required this.showDeleteButton});

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    String displayText = resolveDocID;
    if (resolveDocID.length > 20)
      displayText = '${resolveDocID.substring(0, 20)}..';
    const div = const Divider();
    return Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
                height: _deviceHeight * 0.90,
                width: _deviceWidth * 0.90,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.arrow_back)),
                            Text(displayText)
                          ]),
                      Expanded(
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: SelectableLinkify(
                                  text: details,
                                  linkifiers: [],
                                  onOpen: (_) {},
                                  onTap: () {},
                                  onSelectionChanged: (_, __) {},
                                  options:
                                      const LinkifyOptions(humanize: false),
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.black)))),
                      if (showActionButton) div,
                      if (showActionButton)
                        TextButton(
                            onPressed: () {
                              actionHandler();
                            },
                            style: ButtonStyle(
                                elevation:
                                    MaterialStateProperty.all<double?>(0.0),
                                splashFactory: NoSplash.splashFactory,
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                        Colors.transparent)),
                            child: Text('$actionLabel',
                                style: TextStyle(color: _primaryColor))),
                      if (showCopyButton) div,
                      if (showCopyButton)
                        TextButton(
                            onPressed: () {
                              General.copyDetails(details);
                            },
                            style: ButtonStyle(
                                elevation:
                                    MaterialStateProperty.all<double?>(0.0),
                                splashFactory: NoSplash.splashFactory,
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                        Colors.transparent)),
                            child: Text('COPY',
                                style: TextStyle(color: _primaryColor))),
                      if (showDeleteButton) div,
                      if (showDeleteButton)
                        TextButton(
                            onPressed: () {
                              GeneralAdmin.handleDocDeletion(
                                  myUsername: myUsername,
                                  docAddress: docAddress,
                                  resolvedCollection: resolvedCollection,
                                  resolveDocID: resolveDocID,
                                  resolveDocDetails: docData);
                            },
                            style: ButtonStyle(
                                elevation:
                                    MaterialStateProperty.all<double?>(0.0),
                                splashFactory: NoSplash.splashFactory,
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                        Colors.transparent)),
                            child: Text('DELETE',
                                style: TextStyle(color: _primaryColor)))
                    ]))));
  }
}

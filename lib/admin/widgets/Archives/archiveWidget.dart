import 'package:flutter/material.dart';

import '../../../general.dart';
import '../../generalAdmin.dart';

class ArchiveWidget extends StatelessWidget {
  final String collectionName;
  final String docAddress;
  final String id;
  final dynamic doc;
  const ArchiveWidget(
      {required this.collectionName,
      required this.docAddress,
      required this.id,
      required this.doc});

  @override
  Widget build(BuildContext context) => TextButton(
      key: UniqueKey(),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Text(id)]),
      onPressed: () => GeneralAdmin.displayDocDetails(
          context: context,
          doc: doc,
          actionLabel: General.language(context).admin_widgets_archiveWidget,
          actionHandler: () {},
          docAddress: docAddress,
          resolvedCollection: collectionName,
          resolveDocID: id,
          showActionButton: false,
          showCopyButton: true,
          showDeleteButton: false));
}

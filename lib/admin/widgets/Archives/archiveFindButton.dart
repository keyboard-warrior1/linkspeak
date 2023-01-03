import 'package:flutter/material.dart';

import '../../../models/screenArguments.dart';
import '../../../routes.dart';

class ArchiveFindFab extends StatelessWidget {
  final dynamic findMode;
  const ArchiveFindFab(this.findMode);

  @override
  Widget build(BuildContext context) => FloatingActionButton(
      key: UniqueKey(),
      highlightElevation: 0.0,
      elevation: 0.0,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          child: Icon(Icons.search,
              color: Theme.of(context).colorScheme.secondary, size: 35.0)),
      onPressed: () {
        var args = ArchiveFindScreenArgs(findMode);
        Navigator.pushNamed(context, RouteGenerator.archiveFind,
            arguments: args);
      },
      backgroundColor: Theme.of(context).colorScheme.primary);
}

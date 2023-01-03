import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import '../../general.dart';
import '../../widgets/common/settingsBar.dart';

class ControlDailyDetailsScreen extends StatelessWidget {
  final dynamic details;
  final dynamic dayID;
  const ControlDailyDetailsScreen(this.details, this.dayID);

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
                      SettingsBar(
                          '${General.language(context).admin_controlDailyDetails} $dayID'),
                      Expanded(
                          child: ListView(
                              padding: const EdgeInsets.all(8),
                              children: <Widget>[
                            SelectableLinkify(
                                text: details,
                                linkifiers: [],
                                onOpen: (_) {},
                                onTap: () {},
                                onSelectionChanged: (_, __) {},
                                options: const LinkifyOptions(humanize: false),
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black))
                          ]))
                    ]))));
  }
}

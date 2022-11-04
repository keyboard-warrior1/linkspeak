import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import '../../general.dart';
import '../../widgets/common/settingsBar.dart';

class GeneralControlScreen extends StatefulWidget {
  const GeneralControlScreen();

  @override
  State<GeneralControlScreen> createState() => _GeneralControlScreenState();
}

class _GeneralControlScreenState extends State<GeneralControlScreen> {
  final firestore = FirebaseFirestore.instance;
  late Future<void> getGeneralControl;
  String details = '';
  Future<void> _getGeneralControl() async {
    var controlDoc = await firestore.doc('Control/Details').get();
    details = General.getDocData(controlDoc);
  }

  @override
  void initState() {
    super.initState();
    getGeneralControl = _getGeneralControl();
  }

  Future<void> _pullRefresh() async {
    setState(() {
      getGeneralControl = _getGeneralControl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: General.widthQuery(context),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SettingsBar('General Control'),
                      Expanded(
                          child: FutureBuilder(
                              future: getGeneralControl,
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return const Center(child: SizedBox());

                                return Container(
                                    child: RefreshIndicator(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        displacement: 2.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        onRefresh: () => _pullRefresh(),
                                        child: SingleChildScrollView(
                                            padding: const EdgeInsets.all(8),
                                            child: SelectableLinkify(
                                                text: details,
                                                linkifiers: [],
                                                onOpen: (_) {},
                                                onTap: () {},
                                                onSelectionChanged: (_, __) {},
                                                options: const LinkifyOptions(
                                                    humanize: false),
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black)))));
                              }))
                    ]))));
  }
}

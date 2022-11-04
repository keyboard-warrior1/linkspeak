import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../general.dart';
import '../../widgets/common/settingsBar.dart';
import '../generalAdmin.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen();

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController controller = ScrollController();
  late Future<void> getFeedbacks;
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> feedbacks = [];
  Future<void> _getFeedbacks() async {
    final theFeedbacks = await firestore
        .collection('Feedback')
        .orderBy('date', descending: true)
        .limit(100)
        .get();
    final docs = theFeedbacks.docs;
    feedbacks.addAll(docs);
    if (docs.length < 100) isLastPage = true;
    if (mounted) setState(() {});
  }

  Future<void> _getMoreFeedBacks() async {
    if (!isLoading) {
      setState(() => isLoading = true);
      final last = feedbacks.last.id;
      final getLast = await firestore.doc('Feedback/$last').get();
      final next100 = await firestore
          .collection('Feedback')
          .orderBy('date', descending: true)
          .startAfterDocument(getLast)
          .limit(100)
          .get();
      final docs = next100.docs;
      feedbacks.addAll(docs);
      if (docs.length < 100) isLastPage = true;
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getFeedbacks = _getFeedbacks();
    controller.addListener(() {
      if (mounted) {
        if (controller.position.pixels == controller.position.maxScrollExtent) {
          if (!isLoading && !isLastPage) {
            _getMoreFeedBacks();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(() {});
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _height = _size.height;
    final double _width = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _height,
                width: _width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SettingsBar('Feedbacks'),
                      Expanded(
                          child: FutureBuilder(
                              future: getFeedbacks,
                              builder: (ctx, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) return SizedBox();
                                if (snapshot.hasError) return SizedBox();
                                return Container(
                                    color: Colors.white,
                                    child: ListView.builder(
                                        itemCount: feedbacks.length,
                                        controller: controller,
                                        itemBuilder: (_, index) {
                                          final current = feedbacks[index];
                                          final id = current.id;
                                          return TextButton(
                                              key: UniqueKey(),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[Text(id)]),
                                              onPressed: () => GeneralAdmin
                                                  .displayDocDetails(
                                                      context: context,
                                                      doc: current,
                                                      actionLabel: '',
                                                      actionHandler: () {},
                                                      docAddress:
                                                          'Feedback/$id',
                                                      resolveDocID: id,
                                                      resolvedCollection: '',
                                                      showActionButton: false,
                                                      showCopyButton: true,
                                                      showDeleteButton: false));
                                        }));
                              }))
                    ]))));
  }
}

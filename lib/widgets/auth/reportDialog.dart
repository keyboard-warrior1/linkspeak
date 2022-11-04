import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../common/noglow.dart';
import '../snackbar/reportSnack.dart';
import 'registrationDialog.dart';

enum Category { hate, violence, crime, sex, repulsive, spam, minor }

class MyButton extends StatelessWidget {
  final String title;
  final dynamic val;
  final dynamic selected;
  final void Function(dynamic)? onChanged;
  const MyButton(
      {required this.title,
      required this.val,
      required this.onChanged,
      required this.selected});

  @override
  Widget build(BuildContext context) => CheckboxListTile(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      value: val,
      onChanged: onChanged,
      activeColor: Colors.red.shade700,
      selected: selected);
}

class ReportDialog extends StatefulWidget {
  final String postID;
  final String id;
  final String commentID;
  final bool isInPost;
  final bool isInProfile;
  final bool isInComment;
  final bool isInReply;
  final bool isClubPost;
  final bool isInClubScreen;
  final String clubName;
  final bool isInSpotlight;
  final bool isInFlareProfile;
  final String flareProfileID;
  final String flarePoster;
  final String collectionID;
  final String spotlightID;
  const ReportDialog(
      {required this.id,
      required this.postID,
      required this.isInPost,
      required this.isInProfile,
      required this.isInComment,
      required this.isInReply,
      required this.commentID,
      required this.isClubPost,
      required this.clubName,
      required this.isInClubScreen,
      required this.isInFlareProfile,
      required this.flareProfileID,
      required this.isInSpotlight,
      required this.flarePoster,
      required this.collectionID,
      required this.spotlightID});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  List<Category> chosenCategories = [];
  bool isLoading = false;
  bool isSent = false;
  void _showDialog(IconData icon, Color iconColor, String title, String rule) =>
      showDialog(
          context: context,
          builder: (_) => RegistrationDialog(
              icon: icon, iconColor: iconColor, title: title, rules: rule));

  Future<void> report(
      String id, List<String> categories, String _myUsername) async {
    setState(() => isLoading = true);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final postReports = firestore.collection('Post reports');
    final profileReports = firestore.collection('Profile reports');
    final commentReports = firestore.collection('Comment reports');
    final replyReports = firestore.collection('Reply reports');
    final clubReports = firestore.collection('Club reports');
    final spotlightReports = firestore.collection('Flare reports');
    void _showSnack() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.lightGreenAccent.shade400,
        content: const ReportSnack('Report sent!')));

    Future<void> _sendReport(
        CollectionReference<Map<String, dynamic>> reference,
        String myUsername,
        String fieldName) {
      var batch = firestore.batch();
      var profilePath = 'Users/$id';
      var flareProfilePath = 'Flares/${widget.flareProfileID}';
      var clubPath = 'Clubs/${widget.clubName}';
      var postPath = 'Posts/${widget.postID}';
      var postCommentPath = '$postPath/comments/${widget.commentID}';
      var postReplyPath = '$postCommentPath/replies/$id';
      var flarePath =
          'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.spotlightID}';
      var flareCommentPath = '$flarePath/comments/${widget.commentID}';
      var flareReplyPath = '$flareCommentPath/replies/$id';
      String givePath() {
        if (widget.isInProfile) return profilePath;
        if (widget.isInFlareProfile) return flareProfilePath;
        if (widget.isInClubScreen) return clubPath;
        if (widget.isInPost) return postPath;
        if (widget.isInComment && !widget.isInSpotlight) return postCommentPath;
        if (widget.isInReply && !widget.isInSpotlight) return postReplyPath;
        if (widget.isInSpotlight && !widget.isInComment && !widget.isInReply)
          return flarePath;
        if (widget.isInSpotlight && widget.isInComment) return flareCommentPath;
        if (widget.isInSpotlight && widget.isInReply) return flareReplyPath;
        return '';
      }

      Map<String, dynamic> docFields = {
        if (widget.isInPost || widget.isInComment || widget.isInReply)
          'post': widget.postID,
        if (widget.isInComment || widget.isInReply) 'comment': widget.commentID,
        if (widget.isInReply) 'reply': id,
        if (!widget.isInComment && !widget.isInReply && !widget.isInPost)
          'user': id,
        'isFlareProfile': widget.isInFlareProfile,
        'categories': categories,
        'reported by': '$myUsername',
        'date': DateTime.now(),
        'isClubPost': widget.isClubPost,
        'clubName': widget.clubName,
        if (widget.isInSpotlight) 'flare': widget.spotlightID,
        if (widget.isInSpotlight) 'collection': widget.collectionID,
        if (widget.isInSpotlight) 'flarePoster': widget.flarePoster,
      };
      Future<void> handleModification() async {
        var __batch = firestore.batch();
        String path = givePath();
        final checkExists = await General.checkExists(path);
        if (checkExists) {
          var theDoc = firestore.doc(path);
          var myReport = firestore.doc('$path/Reported by/$myUsername');
          var myProfileReport =
              firestore.collection('Users/$myUsername/Reports').doc();
          var myProfile = firestore.doc('Users/$myUsername');
          var options = SetOptions(merge: true);
          __batch.set(theDoc, {'reports': FieldValue.increment(1)}, options);
          __batch.set(myProfile, {'reports': FieldValue.increment(1)}, options);
          __batch.set(myReport,
              {'times': FieldValue.increment(1), 'date': DateTime.now()});
          __batch.set(myProfileReport, docFields, options);
          __batch.commit();
        }
      }

      batch.set(reference.doc(), docFields);
      String giveDocId() {
        if (widget.isInSpotlight) return widget.spotlightID;
        if (!widget.isInComment && !widget.isInReply && !widget.isInPost)
          return id;
        if (widget.isInReply) return id;
        if (widget.isInPost) return widget.postID;
        return '${DateTime.now().toString()}';
      }

      Map<String, dynamic> fields = {'$fieldName': FieldValue.increment(1)};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: '$fieldName',
          docID: giveDocId(),
          docFields: docFields);
      return batch.commit().then((value) {
        handleModification();
        // BUG IN FLARE COMMENTS AND FLARE COMMENT REPLY WHERE IT POPS THE BOTTOMSHEET OR
        // FLARE COMMENT REPLY SCREEN
        // Navigator.pop(context);
        chosenCategories.clear();
        setState(() {
          isLoading = false;
          isSent = true;
        });
        Future.delayed(const Duration(milliseconds: 100), () => _showSnack());
      }).catchError((onError) {
        _showDialog(Icons.cancel, Colors.red, 'Error', 'An error has occured');
        setState(() => isLoading = false);
      });
    }

    if (widget.isInPost) _sendReport(postReports, _myUsername, 'post reports');
    if (widget.isInProfile || widget.isInFlareProfile)
      _sendReport(profileReports, _myUsername, 'profile reports');
    if (widget.isInComment)
      _sendReport(commentReports, _myUsername, 'comment reports');
    if (widget.isInReply)
      _sendReport(replyReports, _myUsername, 'reply reports');
    if (widget.isInClubScreen)
      _sendReport(clubReports, _myUsername, 'club reports');
    if (widget.isInSpotlight)
      _sendReport(spotlightReports, _myUsername, 'spotlight reports');
  }

  @override
  Widget build(BuildContext context) {
    final Color? _myColor = Colors.red.shade700;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    bool groupValue(Category cat) => chosenCategories.contains(cat);
    void addCategory(Category cat) =>
        setState(() => (chosenCategories.contains(cat))
            ? chosenCategories.remove(cat)
            : chosenCategories.add(cat));

    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(51.0)),
        child: SizedBox(
            width: _deviceWidth * 0.85,
            height: _deviceHeight * 0.50,
            child: Column(children: <Widget>[
              Container(
                  width: double.infinity,
                  height: _deviceHeight * 0.07,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(51.0),
                          topRight: const Radius.circular(51.0)),
                      color: _myColor),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                                customIcons.MyFlutterApp.curve_arrow,
                                color: Colors.white)),
                        const SizedBox(width: 15.0),
                        const Text('Report',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 35.0)),
                        const Spacer(),
                      ])),
              Expanded(
                  child: Noglow(
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                    MyButton(
                        title: 'Hate speech or racism',
                        val: groupValue(Category.hate),
                        selected: groupValue(Category.hate),
                        onChanged: (_) => addCategory(Category.hate)),
                    MyButton(
                        title: 'Violence or abuse',
                        val: groupValue(Category.violence),
                        onChanged: (_) => addCategory(Category.violence),
                        selected: groupValue(Category.violence)),
                    MyButton(
                        title: 'Glorifying crime',
                        val: groupValue(Category.crime),
                        onChanged: (_) => addCategory(Category.crime),
                        selected: groupValue(Category.crime)),
                    MyButton(
                        title: 'Sexual content',
                        val: groupValue(Category.sex),
                        onChanged: (_) => addCategory(Category.sex),
                        selected: groupValue(Category.sex)),
                    MyButton(
                        title: 'Repulsive content',
                        val: groupValue(Category.repulsive),
                        onChanged: (_) => addCategory(Category.repulsive),
                        selected: groupValue(Category.repulsive)),
                    MyButton(
                        title: 'Spam and misinformation',
                        val: groupValue(Category.spam),
                        onChanged: (_) => addCategory(Category.spam),
                        selected: groupValue(Category.spam)),
                    MyButton(
                        title: 'Involves a minor',
                        val: groupValue(Category.minor),
                        onChanged: (_) => addCategory(Category.minor),
                        selected: groupValue(Category.minor))
                  ])))),
              Container(
                  width: double.infinity,
                  height: _deviceHeight * 0.07,
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(_myColor),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: const Radius.circular(51.0),
                                      bottomRight:
                                          const Radius.circular(51.0))))),
                      onPressed: () {
                        if (isLoading) {
                        } else {
                          if (!isSent) if (chosenCategories.isNotEmpty) {
                            final _catNames = chosenCategories.map((category) {
                              var fullName = category.toString();
                              var optimisedName = fullName.substring(9);
                              return optimisedName;
                            });
                            final List<String> _names = _catNames.toList();
                            report(widget.id, _names, myUsername);
                          } else {}
                        }
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: (isLoading)
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 1.50)
                                        : const Text('Submit',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 105.0,
                                                color: Colors.white))))
                          ])))
            ])));
  }
}

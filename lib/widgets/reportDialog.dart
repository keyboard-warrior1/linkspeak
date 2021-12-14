import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/myProfileProvider.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../widgets/registrationDialog.dart';
import '../widgets/reportSnack.dart';

enum Category { hate, violence, crime, sex, repulsive, spam }

class MyButton extends StatelessWidget {
  final String title;
  final dynamic val;
  final dynamic selected;
  final void Function(dynamic)? onChanged;
  const MyButton({
    required this.title,
    required this.val,
    required this.onChanged,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      value: val,
      onChanged: onChanged,
      activeColor: Colors.red.shade700,
      selected: selected,
    );
  }
}

class ReportDialog extends StatefulWidget {
  final String postID;
  final String id;
  final String commentID;
  final bool isInPost;
  final bool isInProfile;
  final bool isInComment;
  final bool isInReply;
  const ReportDialog({
    required this.id,
    required this.postID,
    required this.isInPost,
    required this.isInProfile,
    required this.isInComment,
    required this.isInReply,
    required this.commentID,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  List<Category> chosenCategories = [];
  bool isLoading = false;
  void _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
      context: context,
      builder: (_) => RegistrationDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        rules: rule,
      ),
    );
  }

  Future<void> report(
      String id, List<String> categories, String _myUsername) async {
    setState(() {
      isLoading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final postReports = firestore.collection('Post reports');
    final profileReports = firestore.collection('Profile reports');
    final commentReports = firestore.collection('Comment reports');
    final replyReports = firestore.collection('Reply reports');
    void _showSnack() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(
            seconds: 2,
          ),
          backgroundColor: Colors.lightGreenAccent.shade400,
          content: const ReportSnack('Report sent!'),
        ),
      );
    }

    Future<void> _sendReport(
        CollectionReference<Map<String, dynamic>> reference,
        String myUsername) {
      return reference.add({
        (widget.isInComment)
            ? 'POST:${widget.postID} COMMENT:$id'
            : (widget.isInReply)
                ? 'POST:${widget.postID} COMMENT:${widget.commentID} REPLY:$id'
                : '$id': categories,
        'reported by': '$myUsername',
      }).then((value) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () => _showSnack());
      }).catchError((onError) {
        _showDialog(Icons.cancel, Colors.red, 'Error', 'An error has occured');
        setState(() {
          isLoading = false;
        });
      });
    }

    if (widget.isInPost) {
      _sendReport(postReports, _myUsername);
    }
    if (widget.isInProfile) {
      _sendReport(profileReports, _myUsername);
    }
    if (widget.isInComment) {
      _sendReport(commentReports, _myUsername);
    }
    if (widget.isInReply) {
      _sendReport(replyReports, _myUsername);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color? _myColor = Colors.red.shade700;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    bool groupValue(Category cat) {
      return chosenCategories.contains(cat);
    }

    void addCategory(Category cat) {
      setState(() {
        if (chosenCategories.contains(cat)) {
          chosenCategories.remove(cat);
        } else {
          chosenCategories.add(cat);
        }
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          51.0,
        ),
      ),
      child: SizedBox(
        width: _deviceWidth * 0.85,
        height: _deviceHeight * 0.50,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: _deviceHeight * 0.07,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(
                    51.0,
                  ),
                  topRight: const Radius.circular(
                    51.0,
                  ),
                ),
                color: _myColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      customIcons.MyFlutterApp.curve_arrow,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  const Text(
                    'Report',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 35.0,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyButton(
                      title: 'Hate speech or racism',
                      val: groupValue(Category.hate),
                      selected: groupValue(Category.hate),
                      onChanged: (_) => addCategory(Category.hate),
                    ),
                    MyButton(
                      title: 'Violence or abuse',
                      val: groupValue(Category.violence),
                      onChanged: (_) => addCategory(Category.violence),
                      selected: groupValue(Category.violence),
                    ),
                    MyButton(
                      title: 'Glorifying crime',
                      val: groupValue(Category.crime),
                      onChanged: (_) => addCategory(Category.crime),
                      selected: groupValue(Category.crime),
                    ),
                    MyButton(
                      title: 'Sexual content',
                      val: groupValue(Category.sex),
                      onChanged: (_) => addCategory(Category.sex),
                      selected: groupValue(Category.sex),
                    ),
                    MyButton(
                      title: 'Repulsive content',
                      val: groupValue(Category.repulsive),
                      onChanged: (_) => addCategory(Category.repulsive),
                      selected: groupValue(Category.repulsive),
                    ),
                    MyButton(
                      title: 'Spam and misinformation',
                      val: groupValue(Category.spam),
                      onChanged: (_) => addCategory(Category.spam),
                      selected: groupValue(Category.spam),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: _deviceHeight * 0.07,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color?>(_myColor),
                  shape: MaterialStateProperty.all<OutlinedBorder?>(
                    RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: const Radius.circular(51.0),
                          bottomRight: const Radius.circular(51.0)),
                    ),
                  ),
                ),
                onPressed: () {
                  if (isLoading) {
                  } else {
                    if (chosenCategories.isNotEmpty) {
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
                                color: Colors.white)
                            : const Text(
                                'Submit',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 105.0,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

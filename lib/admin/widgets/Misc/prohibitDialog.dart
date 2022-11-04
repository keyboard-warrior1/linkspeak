import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../general.dart';
import '../../../my_flutter_app_icons.dart' as customIcons;
import '../../../providers/myProfileProvider.dart';

class ProhibitDialog extends StatefulWidget {
  final String id;
  final void Function(bool) prohibitClub;
  const ProhibitDialog(this.prohibitClub, this.id);

  @override
  _ProhibitDialogState createState() => _ProhibitDialogState();
}

class _ProhibitDialogState extends State<ProhibitDialog> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  bool isLoading = false;
  bool permaban = false;
  @override
  void dispose() {
    super.dispose();
    reasonController.dispose();
    durationController.dispose();
  }

  String? durationValidation(String? value) {
    final RegExp _expression = RegExp(r'^[0-9]{1}');
    if (value!.isEmpty || value.replaceAll(' ', '') == '' || value.trim() == '')
      return '* Duration is required';
    if (!_expression.hasMatch(value)) return '* Invalid duration';
    if (_expression.hasMatch(value) &&
        (int.tryParse(value)! < 1 || int.tryParse(value)! > 7))
      return '* Duration must be between 1-7 days';
    if (_expression.hasMatch(value) &&
        int.tryParse(value)! >= 1 &&
        int.tryParse(value)! <= 7) return null;
    return null;
  }

  String? reasonValidation(String? value) {
    if (value!.isEmpty || value.replaceAll(' ', '') == '' || value.trim() == '')
      return '* Reason is required';
    if (value.length < 20 || value.length > 300)
      return '* Reason must be between 20-300 letters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Color? _myColor = Colors.red.shade700;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);

    Future<void> banUser(String myUsername, void Function(bool) prohibit,
        String reason, int duration) async {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        var batch = firestore.batch();
        final usersCollection = firestore.collection('Clubs');
        final bannedCollection = firestore.collection('Prohibited Clubs');
        final controlDoc = firestore.collection('Control').doc('Details');
        final thisUser = usersCollection.doc(widget.id);
        final thisBannedUser = bannedCollection.doc(widget.id);
        batch.update(controlDoc, {'prohibited clubs': FieldValue.increment(1)});
        batch.update(thisUser, {'isProhibited': true});
        batch.set(
            thisBannedUser,
            {
              'isBanned': true,
              'ban date': DateTime.now(),
              'banned by': myUsername,
              'reason': reason,
              'duration': duration,
              'permaban': permaban,
            },
            SetOptions(merge: true));
        return batch.commit().then((value) {
          Future.delayed(const Duration(milliseconds: 10), () {
            prohibit(true);
          });
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    }

    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(51.0)),
        child: Form(
            key: formkey,
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
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
                                const Text('Prohibit',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 35.0)),
                                const Spacer(),
                              ])),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: reasonController,
                                    decoration: const InputDecoration(
                                        hintText: 'Reason',
                                        border: const OutlineInputBorder(),
                                        labelText: 'Reason',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always),
                                    maxLength: 300,
                                    minLines: 2,
                                    maxLines: 10,
                                    validator: reasonValidation)),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: durationController,
                                    decoration: const InputDecoration(
                                        hintText: 'Duration in days',
                                        border: const OutlineInputBorder(),
                                        labelText: 'Duration in days',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always),
                                    maxLength: 1,
                                    keyboardType: TextInputType.phone,
                                    validator: durationValidation)),
                            CheckboxListTile(
                                value: permaban,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                title: const Text('Permanent ban',
                                    style:
                                        const TextStyle(color: Colors.black)),
                                onChanged: (value) {
                                  setState(() {
                                    permaban = value!;
                                  });
                                })
                          ]))),
                      Container(
                          width: double.infinity,
                          height: _deviceHeight * 0.07,
                          child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                          _myColor),
                                  shape: MaterialStateProperty.all<
                                          OutlinedBorder?>(
                                      RoundedRectangleBorder(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft:
                                                  const Radius.circular(51.0),
                                              bottomRight:
                                                  const Radius.circular(
                                                      51.0))))),
                              onPressed: () {
                                if (isLoading) {
                                } else {
                                  if (formkey.currentState!.validate()) {
                                    final String reason =
                                        reasonController.value.text;
                                    final int duration = int.parse(
                                        durationController.value.text);
                                    banUser(_myUsername, widget.prohibitClub,
                                        reason, duration);
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
                                                : const Text('Prohibit',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 105.0,
                                                        color: Colors.white))))
                                  ])))
                    ])))));
  }
}

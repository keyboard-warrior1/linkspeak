import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../general.dart';
import '../../../my_flutter_app_icons.dart' as customIcons;
import '../../../providers/myProfileProvider.dart';

class BanDialog extends StatefulWidget {
  final String id;
  final void Function() banUser;
  const BanDialog(this.banUser, this.id);

  @override
  _BanDialogState createState() => _BanDialogState();
}

class _BanDialogState extends State<BanDialog> {
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

  @override
  Widget build(BuildContext context) {
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Color? _myColor = Colors.red.shade700;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final lang = General.language(context);
    String? durationValidation(String? value) {
      final RegExp _expression = RegExp(r'^[0-9]{1}');
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return '* ${lang.admin_bandDialog6}';
      if (!_expression.hasMatch(value)) return '* ${lang.admin_bandDialog7}';
      if (_expression.hasMatch(value) &&
          (int.tryParse(value)! < 1 || int.tryParse(value)! > 7))
        return '* ${lang.admin_bandDialog8}';
      if (_expression.hasMatch(value) &&
          int.tryParse(value)! >= 1 &&
          int.tryParse(value)! <= 7) return null;
      return null;
    }

    String? reasonValidation(String? value) {
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return '* ${lang.admin_bandDialog9}';
      if (value.length < 20 || value.length > 300)
        return '* ${lang.admin_bandDialog10}';
      return null;
    }

    Future<void> banUser(String myUsername, void Function() ban, String reason,
        int duration) async {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        var batch = firestore.batch();
        final _now = DateTime.now();
        final usersCollection = firestore.collection('Users');
        final bannedCollection = firestore.collection('Banned');
        final thisUser = usersCollection.doc(widget.id);
        final thisBannedUser = bannedCollection.doc(widget.id);
        Map<String, dynamic> fields = {'banned users': FieldValue.increment(1)};
        Map<String, dynamic> docFields = {
          'date': _now,
          'reason': reason,
          'duration': duration,
          'permaban': permaban
        };
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'banned users',
            docID: widget.id,
            docFields: docFields);
        batch.update(thisUser, {'Status': 'Banned'});
        batch.set(
            thisBannedUser,
            {
              'isBanned': true,
              'ban date': _now,
              'banned by': myUsername,
              'reason': reason,
              'duration': duration,
              'permaban': permaban,
            },
            SetOptions(merge: true));
        return batch.commit().then((value) {
          Future.delayed(const Duration(milliseconds: 10), () {
            ban();
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
                                Text(lang.admin_bandDialog1,
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
                                    decoration: InputDecoration(
                                        hintText: lang.admin_bandDialog2,
                                        border: const OutlineInputBorder(),
                                        labelText: lang.admin_bandDialog2,
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
                                    decoration: InputDecoration(
                                      hintText: lang.admin_bandDialog3,
                                      border: const OutlineInputBorder(),
                                      labelText: lang.admin_bandDialog3,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                    maxLength: 1,
                                    keyboardType: TextInputType.phone,
                                    validator: durationValidation)),
                            CheckboxListTile(
                                value: permaban,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                title: Text(lang.admin_bandDialog4,
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
                                    banUser(_myUsername, widget.banUser, reason,
                                        duration);
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
                                                : Text(lang.admin_bandDialog5,
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

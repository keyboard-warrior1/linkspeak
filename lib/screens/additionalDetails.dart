import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/additionalAddressButton.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/profile/profileMap.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen();

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static dynamic stateAddress = '';
  static String stateAddressName = '';
  final _formKey = GlobalKey<FormState>();
  late TextEditingController telephoneController;
  late TextEditingController emailController;
  late TextEditingController websiteController;
  bool somethingChanged = false;
  bool isLoading = false;
  void somethingChangedHandler() {
    setState(() {
      somethingChanged = true;
    });
  }

  void changeAddress(dynamic newAddress) {
    stateAddress = newAddress;
  }

  void changeAddressName(String newAddressName) {
    stateAddressName = newAddressName;
  }

  Widget textfields(
          String label,
          String description,
          TextEditingController controller,
          IconData icon,
          String? Function(String?)? validator,
          bool isPhone) =>
      ListTile(
          horizontalTitleGap: 15.0,
          leading: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.black,
                  size: 20.0,
                ),
                Text(description,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold))
              ]),
          title: TextFormField(
              enableInteractiveSelection: (isPhone) ? false : true,
              keyboardType: (isPhone) ? TextInputType.phone : null,
              onChanged: (_) {
                if (!somethingChanged)
                  setState(() {
                    somethingChanged = true;
                  });
              },
              validator: validator,
              controller: controller,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlueAccent)),
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent)),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                  hintText: label)));

  Future<void> submit(
      {required String myUsername,
      required String xAdditionalWebsite,
      required xAdditionalEmail,
      required xAdditionalNumber,
      required String previousAddressName,
      required dynamic previousLocation,
      required void Function(String) setAdditionalWebsite,
      required void Function(String) setAdditionalEmail,
      required void Function(String) setAdditionalNumber,
      required void Function(dynamic) setAdditionalAddress,
      required void Function(String) setAdditionalAddressName}) async {
    final lang = General.language(context);
    final myDoc = firestore.collection('Users').doc(myUsername);
    var batch = firestore.batch();
    final _now = DateTime.now();
    final modificationID = _now.toString();
    if (previousAddressName != '') {
      final thePlaceDoc =
          firestore.collection('Places').doc(previousAddressName);
      final current =
          thePlaceDoc.collection('current profiles').doc(myUsername);
      final removed =
          thePlaceDoc.collection('removed profiles').doc(myUsername);
      final removedPoints = removed.collection('points').doc(_now.toString());
      batch.set(
          thePlaceDoc,
          {
            'profiles current': FieldValue.increment(-1),
            'profiles removed': FieldValue.increment(1)
          },
          SetOptions(merge: true));
      batch.delete(current);
      batch.set(removed, {'date': _now, 'times': FieldValue.increment(1)},
          SetOptions(merge: true));
      batch.set(
          removedPoints,
          {
            'date': _now,
            'point': previousLocation,
            'name': previousAddressName
          },
          SetOptions(merge: true));
    }
    if (stateAddressName != '') {
      final thePlaceDoc = firestore.collection('Places').doc(stateAddressName);
      final current =
          thePlaceDoc.collection('current profiles').doc(myUsername);
      final total = thePlaceDoc
          .collection('profiles')
          .doc(myUsername)
          .collection('points');
      batch.set(
          thePlaceDoc,
          {
            'profiles current': FieldValue.increment(1),
            'profiles total': FieldValue.increment(1)
          },
          SetOptions(merge: true));
      batch.set(
          current,
          {
            'date': _now,
            'point': stateAddress,
            'name': stateAddressName,
          },
          SetOptions(merge: true));
      batch.set(
          thePlaceDoc.collection('profiles').doc(myUsername),
          {'date': _now, 'times': FieldValue.increment(1)},
          SetOptions(merge: true));
      batch.set(
          total.doc(_now.toString()),
          {
            'date': _now,
            'point': previousLocation,
            'name': previousAddressName
          },
          SetOptions(merge: true));
    }
    batch.set(
        myDoc,
        {
          'additionalWebsite': websiteController.value.text.trim(),
          'additionalEmail': emailController.value.text.trim(),
          'additionalNumber': telephoneController.value.text.trim(),
          'additionalAddress': stateAddress,
          'additionalAddressName': stateAddressName,
          'last modified': _now,
          'additional Modifications': FieldValue.increment(1),
        },
        SetOptions(merge: true));
    batch.set(
        myDoc.collection('Additional Modifications').doc(modificationID),
        {
          'xAdditionalWebsite': xAdditionalWebsite,
          'xAdditionalEmail': xAdditionalEmail,
          'xAdditionalNumber': xAdditionalNumber,
          'xAdditionalAddress': previousLocation,
          'xAdditionalAddressName': previousAddressName,
          'additionalWebsite': websiteController.value.text.trim(),
          'additionalEmail': emailController.value.text.trim(),
          'additionalNumber': telephoneController.value.text.trim(),
          'additionalAddress': stateAddress,
          'additionalAddressName': stateAddressName,
          'date': _now
        },
        SetOptions(merge: true));
    Map<String, dynamic> fields = {
      'modifications additional': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {'id': modificationID, 'date': _now};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'modifications additional',
        docID: modificationID,
        docFields: docFields);
    return await batch.commit().then((value) {
      setAdditionalWebsite(websiteController.value.text.trim());
      setAdditionalEmail(emailController.value.text.trim());
      setAdditionalNumber(telephoneController.value.text.trim());
      setAdditionalAddress(stateAddress);
      setAdditionalAddressName(stateAddressName);
      EasyLoading.showSuccess(lang.screens_additional3,
          dismissOnTap: true, duration: const Duration(seconds: 1));
      setState(() {
        isLoading = false;
        somethingChanged = false;
      });
    }).catchError((_) {
      EasyLoading.showError(lang.screens_additional4,
          dismissOnTap: true, duration: const Duration(seconds: 2));
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    final String additionalWebsite =
        Provider.of<MyProfile>(context, listen: false).getAdditionalWebsite;
    final String additionalEmail =
        Provider.of<MyProfile>(context, listen: false).getAdditionalEmail;
    final String additionalNumber =
        Provider.of<MyProfile>(context, listen: false).getAdditionalNumber;
    final dynamic additionalAddress =
        Provider.of<MyProfile>(context, listen: false).getAdditionalAddress;
    final String additionalAddressName =
        Provider.of<MyProfile>(context, listen: false).getAdditionalAddressName;
    websiteController = TextEditingController(
        text: (additionalWebsite != '') ? additionalWebsite : null);
    emailController = TextEditingController(
        text: (additionalEmail != '') ? additionalEmail : null);
    telephoneController = TextEditingController(
        text: (additionalNumber != '') ? additionalNumber : null);
    stateAddress = additionalAddress;
    stateAddressName = additionalAddressName;
  }

  @override
  void dispose() {
    super.dispose();
    telephoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final emailValidator = MultiValidator([
      EmailValidator(errorText: lang.screens_additional5),
      MaxLengthValidator(100, errorText: lang.screens_additional6)
    ]);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final helper = Provider.of<MyProfile>(context);
    final helperNo = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = helper.getUsername;
    final String previousAddressName = helper.getAdditionalAddressName;
    final dynamic previousAddress = helper.getAdditionalAddress;
    final xAdditionalWebsite = helper.getAdditionalWebsite;
    final xAdditionalEmail = helper.getAdditionalEmail;
    final xAdditionalNumber = helper.getAdditionalNumber;
    void Function(String) setAdditionalWebsite =
        helperNo.setMyAdditionalWebsite;
    void Function(String) setAdditionalEmail = helperNo.setMyAdditionalEmail;
    void Function(String) setAdditionalNumber = helperNo.setMyAdditionalNumber;
    void Function(dynamic) setAdditionalAddress =
        helperNo.setMyAdditionalAddress;
    void Function(String) setAdditionalAddressName =
        helperNo.setMyAdditionalAddressName;
    String? websiteValidator(String? value) {
      if (!isURL(value,
              requireProtocol: true, requireTld: true, allowUnderscore: true) &&
          value!.isNotEmpty) {
        return lang.screens_additional1;
      }
      // } else if (value!.length > 63) {
      //   return 'Please enter a valid URL';
      // }
      // else if(!value.startsWith('http://') && !value.startsWith('https://')){
      //   return "links shoud start with 'http://' or 'https://'";
      // }
      else {
        return null;
      }
    }

    String? numberValidator(String? value) {
      if (value!.isNotEmpty && value.length > 20) {
        return lang.screens_additional2;
      } else {
        return null;
      }
    }

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Form(
                    key: _formKey,
                    child: SizedBox(
                        height: _deviceHeight,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SettingsBar(lang.screens_additional7),
                              Expanded(
                                  child: Noglow(
                                      child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(8.0),
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                textfields(
                                                    lang.screens_additional8,
                                                    lang.screens_additional8,
                                                    websiteController,
                                                    Icons.public_outlined,
                                                    websiteValidator,
                                                    false),
                                                textfields(
                                                    lang.screens_additional9,
                                                    lang.screens_additional10,
                                                    emailController,
                                                    Icons.mail_outline,
                                                    emailValidator,
                                                    false),
                                                textfields(
                                                    lang.screens_additional11,
                                                    lang.screens_additional12,
                                                    telephoneController,
                                                    Icons.phone_outlined,
                                                    numberValidator,
                                                    true),
                                                if (!kIsWeb ||
                                                    kIsWeb &&
                                                        stateAddress != '')
                                                  AdditionalAddressButton(
                                                      isInPostScreen: false,
                                                      isInPost: false,
                                                      somethingChanged:
                                                          somethingChangedHandler,
                                                      changeAddress:
                                                          changeAddress,
                                                      changeAddressName:
                                                          changeAddressName,
                                                      postLocation: null,
                                                      postLocationName: null),
                                                if (stateAddress != '')
                                                  ProfileMap(stateAddress,
                                                      stateAddressName, true),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                          lang
                                                              .screens_additional13,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      15.0))
                                                    ])
                                              ])))),
                              Opacity(
                                  opacity: (somethingChanged) ? 1.0 : .65,
                                  child: TextButton(
                                      style: ButtonStyle(
                                          enableFeedback: false,
                                          elevation:
                                              MaterialStateProperty.all<double?>(
                                                  0.0),
                                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                      topRight: const Radius.circular(
                                                          15.0),
                                                      topLeft: const Radius.circular(
                                                          15.0)))),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color?>(
                                                  _primaryColor)),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        bool _isValid =
                                            _formKey.currentState!.validate();
                                        if (_isValid && somethingChanged) {
                                          if (isLoading) {
                                          } else {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            submit(
                                                myUsername: myUsername,
                                                xAdditionalWebsite:
                                                    xAdditionalWebsite,
                                                xAdditionalEmail:
                                                    xAdditionalEmail,
                                                xAdditionalNumber:
                                                    xAdditionalNumber,
                                                previousAddressName:
                                                    previousAddressName,
                                                previousLocation:
                                                    previousAddress,
                                                setAdditionalWebsite:
                                                    setAdditionalWebsite,
                                                setAdditionalEmail:
                                                    setAdditionalEmail,
                                                setAdditionalNumber:
                                                    setAdditionalNumber,
                                                setAdditionalAddress:
                                                    setAdditionalAddress,
                                                setAdditionalAddressName:
                                                    setAdditionalAddressName);
                                          }
                                        } else {}
                                      },
                                      child: (isLoading)
                                          ? CircularProgressIndicator(color: _accentColor, strokeWidth: 1.50)
                                          : Text(lang.screens_additional14, style: TextStyle(fontSize: 35.0, color: _accentColor))))
                            ]))))));
  }
}

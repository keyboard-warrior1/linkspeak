import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:validators/validators.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/settingsBar.dart';
import '../widgets/additionalAddressButton.dart';
import '../widgets/profileMap.dart';

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

  final emailValidator = MultiValidator([
    EmailValidator(errorText: 'Invalid email address'),
    MaxLengthValidator(100,
        errorText: 'Email address cannot be more than 100 characters long')
  ]);
  String? websiteValidator(String? value) {
    if (!isURL(value) && value!.isNotEmpty) {
      return 'Please enter a valid URL';
    } else if (value!.length > 63) {
      return 'Please enter a valid URL';
    } else {
      return null;
    }
  }

  String? numberValidator(String? value) {
    if (value!.isNotEmpty && value.length > 20) {
      return 'Please enter a valid phone number';
    } else {
      return null;
    }
  }

  Widget textfields(
    String label,
    String description,
    TextEditingController controller,
    IconData icon,
    String? Function(String?)? validator,
    bool isPhone,
  ) {
    return ListTile(
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
          Text(
            description,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
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
            borderSide: BorderSide(color: Colors.lightBlueAccent),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
          hintText: label,
        ),
      ),
    );
  }

  Future<void> submit(
    String myUsername,
    void Function(String) setAdditionalWebsite,
    void Function(String) setAdditionalEmail,
    void Function(String) setAdditionalNumber,
    void Function(dynamic) setAdditionalAddress,
    void Function(String) setAdditionalAddressName,
  ) async {
    final myDoc = firestore.collection('Users').doc(myUsername);
    return await myDoc.set({
      'additionalWebsite': websiteController.value.text.trim(),
      'additionalEmail': emailController.value.text.trim(),
      'additionalNumber': telephoneController.value.text.trim(),
      'additionalAddress': stateAddress,
      'additionalAddressName': stateAddressName,
    }, SetOptions(merge: true)).then((value) {
      setAdditionalWebsite(websiteController.value.text.trim());
      setAdditionalEmail(emailController.value.text.trim());
      setAdditionalNumber(telephoneController.value.text.trim());
      setAdditionalAddress(stateAddress);
      setAdditionalAddressName(stateAddressName);
      EasyLoading.showSuccess(
        'Saved',
        dismissOnTap: true,
        duration: const Duration(seconds: 2),
      );
      setState(() {
        isLoading = false;
        somethingChanged = false;
      });
    }).catchError((_) {
      EasyLoading.showError(
        'Failed',
        dismissOnTap: true,
        duration: const Duration(seconds: 2),
      );
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
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final helper = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = helper.getUsername;
    void Function(String) setAdditionalWebsite = helper.setMyAdditionalWebsite;
    void Function(String) setAdditionalEmail = helper.setMyAdditionalEmail;
    void Function(String) setAdditionalNumber = helper.setMyAdditionalNumber;
    void Function(dynamic) setAdditionalAddress = helper.setMyAdditionalAddress;
    void Function(String) setAdditionalAddressName =
        helper.setMyAdditionalAddressName;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: _deviceHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SettingsBar('Additional details'),
                  Expanded(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowGlow();
                        return false;
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            textfields('Link', 'Link', websiteController,
                                Icons.web, websiteValidator, false),
                            textfields(
                                'Email address',
                                'Email',
                                emailController,
                                Icons.mail_outline,
                                emailValidator,
                                false),
                            textfields(
                                'Phone number',
                                'Phone',
                                telephoneController,
                                Icons.phone_outlined,
                                numberValidator,
                                true),
                            AdditionalAddressButton(
                              isInPostScreen: false,
                              isInPost: false,
                              somethingChanged: somethingChangedHandler,
                              changeAddress: changeAddress,
                              changeAddressName: changeAddressName,
                            ),
                            if (stateAddress != '')
                              ProfileMap(
                                stateAddress,
                                stateAddressName,
                                true,
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  'These details will appear behind your profile',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15.0),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: (somethingChanged) ? 1.0 : .65,
                    child: TextButton(
                      style: ButtonStyle(
                        enableFeedback: false,
                        elevation: MaterialStateProperty.all<double?>(0.0),
                        shape: MaterialStateProperty.all<OutlinedBorder?>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(15.0),
                              topLeft: const Radius.circular(15.0),
                            ),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(_primaryColor),
                      ),
                      onPressed: () {
                        bool _isValid = _formKey.currentState!.validate();
                        if (_isValid && somethingChanged) {
                          if (isLoading) {
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            submit(
                                myUsername,
                                setAdditionalWebsite,
                                setAdditionalEmail,
                                setAdditionalNumber,
                                setAdditionalAddress,
                                setAdditionalAddressName);
                          }
                        } else {}
                      },
                      child: (isLoading)
                          ? CircularProgressIndicator(color: _accentColor)
                          : Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 35.0,
                                color: _accentColor,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

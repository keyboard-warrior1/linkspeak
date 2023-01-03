import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../widgets/common/adaptiveText.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';
import '../../general.dart';
import '../generalAdmin.dart';
import '../widgets/Finders/findField.dart';

enum ArchiveFindMode {
  deletedPost,
  deletedComment,
  deletedReply,
  deletedFlare,
  deletedUser,
  deletedFlareProfile
}

class ArchiveFindScreen extends StatefulWidget {
  final dynamic searchMode;
  const ArchiveFindScreen(this.searchMode);

  @override
  State<ArchiveFindScreen> createState() => _ArchiveFindScreenState();
}

class _ArchiveFindScreenState extends State<ArchiveFindScreen> {
  ArchiveFindMode mode = ArchiveFindMode.deletedPost;
  final TextEditingController fieldController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  Future<void> getAndShowDetailDialog() async {
    if (!isLoading && fieldController.value.text.isNotEmpty) {
      setState(() => isLoading = true);
      var id = fieldController.text;
      final String collection = buildCollectionAddress();
      final theDoc = await firestore.doc('$collection/$id').get();
      if (theDoc.exists) {
        setState(() => isLoading = false);
        GeneralAdmin.displayDocDetails(
            context: context,
            doc: theDoc,
            actionLabel: '',
            actionHandler: () {},
            docAddress: '$collection/$id',
            resolvedCollection: '',
            resolveDocID: theDoc.id,
            showActionButton: false,
            showCopyButton: true,
            showDeleteButton: false);
      } else {
        setState(() => isLoading = false);
        EasyLoading.showError('Doc does not exist',
            dismissOnTap: true, duration: const Duration(seconds: 2));
      }
    }
  }

  String buildCollectionAddress() {
    switch (mode) {
      case ArchiveFindMode.deletedPost:
        return 'Deleted Posts';
      case ArchiveFindMode.deletedComment:
        return 'Deleted Comments';
      case ArchiveFindMode.deletedReply:
        return 'Deleted Replies';
      case ArchiveFindMode.deletedFlare:
        return 'Deleted Flares';
      case ArchiveFindMode.deletedUser:
        return 'Deleted Users';
      case ArchiveFindMode.deletedFlareProfile:
        return 'Deleted Flare Profiles';
      default:
        return '';
    }
  }

  String buildFieldHint() {
    final lang = General.language(context);
    switch (mode) {
      case ArchiveFindMode.deletedPost:
        return lang.admin_archiveFind_field1;
      case ArchiveFindMode.deletedComment:
        return lang.admin_archiveFind_field2;
      case ArchiveFindMode.deletedReply:
        return lang.admin_archiveFind_field3;
      case ArchiveFindMode.deletedFlare:
        return lang.admin_archiveFind_field4;
      case ArchiveFindMode.deletedUser:
        return lang.admin_archiveFind_field5;
      case ArchiveFindMode.deletedFlareProfile:
        return lang.admin_archiveFind_field6;
      default:
        return '';
    }
  }

  void handleFindButton() {
    getAndShowDetailDialog();
  }

  @override
  void initState() {
    super.initState();
    mode = widget.searchMode;
  }

  @override
  void dispose() {
    super.dispose();
    fieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {});
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SettingsBar(
                              General.language(context).admin_archiveFind1,
                              null),
                          Expanded(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                Expanded(
                                    child: Noglow(
                                        child: ListView(children: <Widget>[
                                  Field(
                                      validator: null,
                                      maxLength: 1000,
                                      label: buildFieldHint(),
                                      controller: fieldController,
                                      icon: Icons.verified,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      showSuffix: false,
                                      obscureText: false,
                                      handler: null,
                                      focusNode: null)
                                ]))),
                                TextButton(
                                    style: ButtonStyle(
                                        enableFeedback: false,
                                        elevation: MaterialStateProperty.all<double?>(
                                            0.0),
                                        backgroundColor: MaterialStateProperty.all<Color?>(
                                            _primaryColor),
                                        shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight:
                                                    const Radius.circular(15.0),
                                                topLeft: const Radius.circular(
                                                    15.0))))),
                                    onPressed: handleFindButton,
                                    child: OptimisedText(
                                        minWidth: _deviceWidth * 0.5,
                                        maxWidth: _deviceWidth * 0.5,
                                        minHeight: _deviceHeight * 0.038,
                                        maxHeight: _deviceHeight * 0.038,
                                        fit: BoxFit.scaleDown,
                                        child: !isLoading
                                            ? Text(General.language(context).admin_archiveFind2, style: TextStyle(fontSize: 35.0, color: _accentColor))
                                            : SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 1.5, color: _accentColor))))
                              ]))
                        ])))));
  }
}

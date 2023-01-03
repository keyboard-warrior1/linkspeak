import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';

class LanguagePicker extends StatefulWidget {
  final bool isInTheme;
  const LanguagePicker(this.isInTheme);

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  final firestore = FirebaseFirestore.instance;
  Widget buildListTile(String langSymbol, String langCode, String langname) {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final changeLang =
        Provider.of<ThemeModel>(context, listen: false).setLanguage;
    return ListTile(
        horizontalTitleGap: 5.0,
        leading: Text(langSymbol,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold)),
        title: Text(langname, style: TextStyle(color: Colors.black)),
        onTap: () {
          if (widget.isInTheme)
            firestore
                .doc('Users/$myUsername')
                .set({'language': langCode}, SetOptions(merge: true));
          changeLang(langCode);
          Navigator.pop(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    final String langSymbol = Provider.of<ThemeModel>(context).langCode;
    String displayName = '';
    final lang = General.language(context);
    if (langSymbol == 'en') {
      displayName = 'English';
    } else if (langSymbol == 'ع') {
      displayName = 'العربية';
    } else if (langSymbol == 'TR') {
      displayName = 'Türkçe';
    } else {
      displayName = 'English';
    }

    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(31.0)),
              backgroundColor: Colors.white,
              builder: (_) {
                final Column _choices = Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                          title: Text(lang.widgets_auth65,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17)),
                          trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              })),
                      const Divider(),
                      buildListTile('EN', 'en', 'English'),
                      buildListTile('TR', 'tr', 'Türkçe'),
                      buildListTile('ع', 'ar', 'العربية')
                    ]);
                final SizedBox _box = SizedBox(child: _choices);
                return _box;
              });
        },
        child: Container(
            height: 25.0,
            width: widget.isInTheme ? 80 : 25.0,
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.transparent,
                border: Border.all(
                    color: widget.isInTheme ? Colors.black : Colors.white)),
            child: Center(
              child: Text(widget.isInTheme ? displayName : langSymbol,
                  style: TextStyle(
                      color: widget.isInTheme ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins')),
            )));
  }
}

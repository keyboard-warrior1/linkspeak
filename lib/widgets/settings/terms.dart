import 'package:flutter/material.dart';
import '../../general.dart';

class Terms extends StatelessWidget {
  const Terms();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final terms = lang.terms;
    return Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: SingleChildScrollView(
            child: Text(terms,
                softWrap: true,
                maxLines: 10000,
                style: const TextStyle(color: Colors.black))));
  }
}

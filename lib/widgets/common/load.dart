import 'package:flutter/material.dart';
import '../../general.dart';

class Load extends StatelessWidget {
  final bool? isDeleteProfile;
  const Load({this.isDeleteProfile});

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    return Center(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0), color: Colors.black),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 1.50)),
                  if (isDeleteProfile != null)
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(lang.widgets_common5,
                            softWrap: false,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17))),
                  if (isDeleteProfile != null)
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(lang.widgets_common6,
                            softWrap: true,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14))),
                ])));
  }
}

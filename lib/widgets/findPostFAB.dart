import 'package:flutter/material.dart';
import '../routes.dart';

class FindPostFAB extends StatelessWidget {
  const FindPostFAB();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 45.0),
      child: FloatingActionButton(
        key: UniqueKey(),
        highlightElevation: 0.0,
        elevation: 0.0,
        child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 100,
            ),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: 35.0,
            )),
        onPressed: () =>
            Navigator.pushNamed(context, RouteGenerator.findPostScreen),
        backgroundColor: Colors.red,
      ),
    );
  }
}

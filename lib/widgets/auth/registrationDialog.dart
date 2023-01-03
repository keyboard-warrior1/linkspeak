import 'package:flutter/material.dart';
import '../../general.dart';

class RegistrationDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String rules;
  final Future<void> Function()? sendEmailVerification;
  const RegistrationDialog(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.rules,
      this.sendEmailVerification});
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    return Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
                height: _deviceHeight * 0.4,
                width: _deviceWidth * 0.65,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Spacer(),
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 35.0, right: 35.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(title,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold))
                              ])),
                      SizedBox(height: _deviceHeight * 0.03),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Icon(icon, color: iconColor, size: 55.0)]),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35.0, vertical: 15.0),
                          child: Text(rules,
                              softWrap: true,
                              style: const TextStyle(color: Colors.grey))),
                      const Spacer(),
                      const Divider(),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: ButtonStyle(
                              elevation:
                                  MaterialStateProperty.all<double?>(0.0),
                              splashFactory: NoSplash.splashFactory,
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      Colors.transparent)),
                          child: Text(lang.widgets_auth3,
                              style: TextStyle(color: _primaryColor))),
                      if (sendEmailVerification != null) const Divider(),
                      if (sendEmailVerification != null)
                        TextButton(
                            onPressed: () {
                              Future.delayed(const Duration(milliseconds: 50),
                                  () {
                                return sendEmailVerification!();
                              });
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                                elevation:
                                    MaterialStateProperty.all<double?>(0.0),
                                splashFactory: NoSplash.splashFactory,
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                        Colors.transparent)),
                            child: Text(lang.widgets_auth54,
                                style: TextStyle(color: _primaryColor)))
                    ]))));
  }
}

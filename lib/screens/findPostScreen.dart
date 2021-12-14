import 'package:flutter/material.dart';
import '../models/screenArguments.dart';
import '../screens/postScreen.dart';
import '../widgets/settingsBar.dart';
import '../widgets/adaptiveText.dart';
import '../routes.dart';

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int? maxLength;
  final IconData icon;
  final TextInputType keyboardType;
  final bool showSuffix;
  final bool obscureText;
  final dynamic handler;
  final FocusNode? focusNode;
  const Field({
    required this.controller,
    required this.label,
    required this.validator,
    required this.maxLength,
    required this.icon,
    required this.keyboardType,
    required this.showSuffix,
    required this.obscureText,
    required this.handler,
    required this.focusNode,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextFormField(
        keyboardType: keyboardType,
        focusNode: (focusNode != null) ? focusNode : null,
        maxLength: maxLength,
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreenAccent.shade400),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
          filled: true,
          fillColor: Colors.grey.shade200,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          hintText: label,
          suffixIcon: (showSuffix)
              ? IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(icon),
                  onPressed: handler,
                )
              : null,
        ),
      ),
    );
  }
}

class FindPostScreen extends StatefulWidget {
  const FindPostScreen();

  @override
  State<FindPostScreen> createState() => _FindPostScreenState();
}

class _FindPostScreenState extends State<FindPostScreen> {
  final controller = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _goToPost(final BuildContext context, final ViewMode view,
      dynamic previewSetstate, String postID) {
    final PostScreenArguments args = PostScreenArguments(
        instance: null,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: true,
        postID: postID);

    Navigator.pushNamed(
      context,
      RouteGenerator.postScreen,
      arguments: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _primaryColor = Theme.of(context).primaryColor;
    final _accentColor = Theme.of(context).accentColor;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {});
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SettingsBar('Find post', null),
                const SizedBox(height: 25.0),
                Field(
                  validator: null,
                  maxLength: 1000,
                  label: 'Post ID',
                  controller: controller,
                  icon: Icons.verified,
                  keyboardType: TextInputType.visiblePassword,
                  showSuffix: false,
                  obscureText: false,
                  handler: null,
                  focusNode: null,
                ),
                const Spacer(),
                TextButton(
                  style: ButtonStyle(
                    enableFeedback: false,
                    elevation: MaterialStateProperty.all<double?>(0.0),
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(_primaryColor),
                    shape: MaterialStateProperty.all<OutlinedBorder?>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(15.0),
                          topLeft: const Radius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _goToPost(
                        context, ViewMode.post, () {}, controller.value.text);
                  },
                  child: OptimisedText(
                    minWidth: _deviceWidth * 0.5,
                    maxWidth: _deviceWidth * 0.5,
                    minHeight: _deviceHeight * 0.038,
                    maxHeight: _deviceHeight * 0.038,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Find',
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
    );
  }
}

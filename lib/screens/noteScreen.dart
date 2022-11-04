import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../general.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/settingsBar.dart';

class NoteScreen extends StatefulWidget {
  final dynamic handler;
  final dynamic preexistingText;
  final dynamic editHandler;
  final dynamic isBranch;
  const NoteScreen(
      {required this.handler,
      required this.preexistingText,
      required this.editHandler,
      required this.isBranch});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController controller;
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  String? _validateDescription(String? value) {
    if ((value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '')) return 'Notes cannot be empty';
    if (value.length > 200 && !widget.isBranch)
      return 'Notes can be between 1-200 characters';
    if (value.length > 1000 && widget.isBranch)
      return 'Text can be between 1-1000 characters';
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.preexistingText != null) {
      controller = TextEditingController(text: widget.preexistingText);
    } else {
      controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    final theme = Theme.of(context).colorScheme;
    final _primarySwatch = theme.primary;
    final _accentColor = theme.secondary;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _height,
                width: _width,
                child: Form(
                    key: key,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SettingsBar(widget.isBranch ? 'Text' : 'Note'),
                          Expanded(
                              child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            TextFormField(
                                                controller: controller,
                                                minLines: 10,
                                                maxLines:
                                                    widget.isBranch ? 50 : 10,
                                                validator: _validateDescription,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: widget.isBranch
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                                    fontSize: widget.isBranch
                                                        ? 17
                                                        : 20),
                                                maxLength: widget.isBranch
                                                    ? 1000
                                                    : 200,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                cursorColor: Colors.black,
                                                cursorHeight:
                                                    widget.isBranch ? 10 : 20,
                                                showCursor: true,
                                                decoration: InputDecoration(
                                                    counterText: '',
                                                    filled: true,
                                                    fillColor:
                                                        Colors.transparent,
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade200,
                                                            width: 1)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade200,
                                                            width: 1)),
                                                    errorBorder:
                                                        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1))))
                                          ])),
                                  const SizedBox(height: 10),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(8),
                                            width: 100.0,
                                            child: ElevatedButton(
                                                style: ButtonStyle(
                                                    padding: MaterialStateProperty.all<
                                                            EdgeInsetsGeometry?>(
                                                        const EdgeInsets.symmetric(
                                                            vertical: 1.0,
                                                            horizontal: 5.0)),
                                                    shape: MaterialStateProperty.all<
                                                            OutlinedBorder?>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10.0),
                                                            side:
                                                                BorderSide(color: _accentColor))),
                                                    elevation: MaterialStateProperty.all<double?>(0.0),
                                                    enableFeedback: false,
                                                    backgroundColor: MaterialStateProperty.all<Color?>(_accentColor)),
                                                onPressed: () {
                                                  if (key.currentState!
                                                      .validate()) {
                                                    String desc = controller
                                                        .value.text
                                                        .trim();
                                                    var replaced = desc.replaceAll(
                                                        RegExp(
                                                            r'(?:[\t]*(?:\r?\n|\r))+'),
                                                        ' ');
                                                    if (widget
                                                            .preexistingText !=
                                                        null) {
                                                      widget.editHandler(
                                                          replaced);
                                                    } else {
                                                      widget.handler(replaced);
                                                    }
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: OptimisedText(minWidth: 75.0, maxWidth: 100.0, minHeight: 25.0, maxHeight: 25.0, fit: BoxFit.scaleDown, child: Text('Done', style: TextStyle(fontSize: 15.0, color: _primarySwatch)))))
                                      ])
                                ]),
                          ))
                        ])))));
  }
}

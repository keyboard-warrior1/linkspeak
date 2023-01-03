import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:provider/provider.dart';

import '../providers/flareCollectionHelper.dart';
import '../widgets/common/noglow.dart';
import 'flareWidget.dart';

class CollectionFlareTab extends StatefulWidget {
  final PageController controller;
  const CollectionFlareTab(this.controller);

  @override
  State<CollectionFlareTab> createState() => _CollectionFlareTabState();
}

class _CollectionFlareTabState extends State<CollectionFlareTab> {
  bool isCollapsed = false;
  void collapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final helper = Provider.of<FlareCollectionHelper>(context, listen: false);
    final flares = helper.flares;
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: collapse,
                        icon: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                const BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 5),
                                    blurRadius: 20,
                                    spreadRadius: 0.5),
                              ],
                            ),
                            child: isCollapsed
                                ? Icon(Icons.keyboard_arrow_up,
                                    color: Colors.white, size: 35)
                                : const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white, size: 35)))
                  ]),
              AnimatedContainer(
                  duration: isCollapsed
                      ? const Duration(milliseconds: 300)
                      : const Duration(milliseconds: 200),
                  height: isCollapsed ? 0 : 200,
                  padding: const EdgeInsets.symmetric(vertical: 5.50),
                  child: AnimatedScale(
                      scale: isCollapsed ? 0 : 1,
                      duration: isCollapsed
                          ? const Duration(milliseconds: 300)
                          : const Duration(milliseconds: 200),
                      child: Noglow(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(10),
                              itemCount: flares.length,
                              itemBuilder: (ctx, index) {
                                final instance = flares[index].instance;
                                return ChangeNotifierProvider.value(
                                    value: instance,
                                    child: Builder(builder: (context) {
                                      return Bounce(
                                          onPressed: () {
                                            final currentPage =
                                                widget.controller.page;
                                            if (currentPage != index)
                                              widget.controller
                                                  .jumpToPage(index);
                                          },
                                          duration:
                                              const Duration(milliseconds: 100),
                                          child: const FlareWidget());
                                    }));
                              }))))
            ])));
  }
}

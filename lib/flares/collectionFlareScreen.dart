import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/flareCollectionHelper.dart';
import 'collectionFlareWidget.dart';

class CollectionFlareScreen extends StatefulWidget {
  final dynamic collections;
  final dynamic currentIndex;
  final dynamic comeFromProfile;
  const CollectionFlareScreen(
      this.collections, this.currentIndex, this.comeFromProfile);
  @override
  State<CollectionFlareScreen> createState() => _CollectionFlareScreenState();
}

class _CollectionFlareScreenState extends State<CollectionFlareScreen> {
  int stateIndex = 0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    stateIndex = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController =
        widget.collections[0].instance.currentController;
    void scrollDown() {
      final currentPosition = scrollController.position.pixels;
      final nextPosition = currentPosition + 410.5;
      scrollController.jumpTo(nextPosition);
    }

    void scrollUp() {
      final currentPosition = scrollController.position.pixels;
      final previousPosition = currentPosition - 410.5;
      scrollController.jumpTo(previousPosition);
    }

    return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
            child: PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  if (index > stateIndex) {
                    scrollDown();
                    stateIndex = index;
                  } else {
                    scrollUp();
                    stateIndex = index;
                  }
                },
                itemCount: widget.collections.length,
                itemBuilder: (ctx, index) {
                  final currentInstance = widget.collections[index].instance;
                  return ChangeNotifierProvider<FlareCollectionHelper>.value(
                      value: currentInstance,
                      child: const CollectionFlareWidget());
                })));
  }
}

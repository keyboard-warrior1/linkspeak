import 'package:flutter/material.dart';

import 'flareSkeleton.dart';

class FlareGridSkeleton extends StatelessWidget {
  const FlareGridSkeleton();

  @override
  Widget build(BuildContext context) => Expanded(
      child: GridView(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 110,
              mainAxisExtent: 150,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),
          children: [for (var i = 0; i < 50; i++) const FlareSkeleton()]));
}

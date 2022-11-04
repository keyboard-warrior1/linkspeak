import 'package:flutter/material.dart';

import 'suggestedSkeleton.dart';

class SuggestedsLoading extends StatelessWidget {
  const SuggestedsLoading();

  @override
  Widget build(BuildContext context) => ListView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [for (var i = 0; i < 3; i++) const SuggestedSkeleton()]);
}

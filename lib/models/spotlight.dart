import 'clip.dart';

class Spotlight {
  final String posterID;
  final List<Clip> clips;
  final bool isMySpotlight;
  const Spotlight({
    required this.posterID,
    required this.clips,
    required this.isMySpotlight,
  });
}

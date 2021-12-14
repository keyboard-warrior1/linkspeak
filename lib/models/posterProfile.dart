import 'profile.dart';

class PosterProfile {
  final String getUsername;
  final String getProfileImage;
  final String getBio;
  final int getNumberOflinks;
  final int getNumberOfLinkedTos;
  final TheVisibility getVisibility;
  const PosterProfile({
    required this.getUsername,
    required this.getProfileImage,
    required this.getBio,
    required this.getNumberOflinks,
    required this.getNumberOfLinkedTos,
    required this.getVisibility,
  });
}

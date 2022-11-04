class BoardPostItem {
  final bool isText;
  final bool mediaIsAsset;
  final bool isInEdit;
  final String description;
  final String mediaURL;
  final String assetPath;
  const BoardPostItem(
      {required this.isText,
      required this.mediaIsAsset,
      required this.isInEdit,
      required this.description,
      required this.mediaURL,
      required this.assetPath});
}

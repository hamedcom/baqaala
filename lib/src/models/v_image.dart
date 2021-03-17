class VImage {
  String url;
  String filename;
  String thumb;
  String blurhash;

  VImage({
    this.url,
    this.filename,
    this.thumb,
    this.blurhash,
  });

  VImage.fromJson(Map<String, dynamic> data) {
    url = data['url'];
    filename = data['filename'];
    thumb = data['thumb'];
    blurhash = data['blurhash'];
  }

  Map<String, dynamic> toJSON() => {
        'url': url,
        'filename': filename,
        'thumb': thumb,
        'blurhash': blurhash,
      };
}

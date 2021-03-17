class Videos {
  static String getVideoLink(String content) {
    if (_getYoutubeLink(content) != null) {
      return _getYoutubeLink(content);
    } else if (_getFacebookLink(content) != null) {
      return _getFacebookLink(content);
    } else {
      return _getVimeoLink(content);
    }
  }

  static String _getYoutubeLink(String content) {
    final regExp = RegExp(
        "https://www.youtube.com/((v|embed))\/?[a-zA-Z0-9_-]+",
        multiLine: true,
        caseSensitive: false);

    String youtubeUrl;

    try {
      if (content?.isNotEmpty ?? false) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          youtubeUrl = matches?.first?.group(0) ?? '';
        }
      }
    } catch (error) {
//      printLog('[_getYoutubeLink] ${error.toString()}');
    }
    return youtubeUrl;
  }

  static String _getFacebookLink(String content) {
    final regExp = RegExp(
        "https://www.facebook.com\/[a-zA-Z0-9\.]+\/videos\/(?:[a-zA-Z0-9\.]+\/)?([0-9]+)",
        multiLine: true,
        caseSensitive: false);

    String facebookVideoId;
    String facebookUrl;
    try {
      if (content?.isNotEmpty ?? false) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          facebookVideoId = matches.first.group(1);
          if (facebookVideoId != null) {
            facebookUrl =
                'https://www.facebook.com/video/embed?video_id=$facebookVideoId';
          }
        }
      }
    } catch (error) {
      print(error);
    }
    return facebookUrl;
  }

  static String _getVimeoLink(String content) {
    final regExp = RegExp("https://player.vimeo.com/((v|video))\/?[0-9]+",
        multiLine: true, caseSensitive: false);

    String vimeoUrl;

    try {
      if (content?.isNotEmpty ?? false) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          vimeoUrl = matches.first.group(0);
        }
      }
    } catch (error) {
      print(error);
    }
    return vimeoUrl;
  }
}

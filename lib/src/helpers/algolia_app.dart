import 'package:algolia/algolia.dart';
import 'package:baqaala/src/common/config/general.dart';

class AlgoliaApp {
  static final Algolia algolia = Algolia.init(
      applicationId: kAlgoliaConfig["appId"],
      apiKey: kAlgoliaConfig["adminApiKey"]);
}

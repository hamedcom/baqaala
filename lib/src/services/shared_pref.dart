import 'package:baqaala/src/models/country.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPrefs instance = SharedPrefs();

  SharedPrefs();

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    print('Setting Language Code $langCode');
    if (langCode == null) {
      langCode = 'en';
    }

    await prefs.setString('language', langCode);
  }

  // From EasyLocalizations
  Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String locale = prefs.getString('locale');
    if (locale != null)
      return locale;
    else
      return 'en';
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString('language');
    print('Getting Language Code $lang');
    if (lang == null) {
      lang = 'en';
    }
    return lang;
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    // print('token stored');
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getBool('isDarkMode');
    return theme;
  }

  Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isDarkMode');
  }

  Future<void> setFirstRun(bool firstrun, String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstRun_$version', firstrun);
  }

  Future<bool> isFirstRun(String version) async {
    final prefs = await SharedPreferences.getInstance();
    final firstRun = prefs.getBool('firstRun_$version');
    return firstRun;
  }

  Future<void> setOnboardingSeen(bool firstrun, String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen_$version', firstrun);
  }

  Future<bool> isOnboardingSeen(String version) async {
    final prefs = await SharedPreferences.getInstance();
    final firstRun = prefs.getBool('onboardingSeen_$version');
    return firstRun;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // print('token retreived : ${token}');
    return token;
  }

  Future<void> setCountry(Country country) async {
    final prefs = await SharedPreferences.getInstance();
    if (country != null)
      await prefs.setStringList('country', [
        country.name,
        country.isoCode,
        country.countryCode.toString(),
        country.currency,
        country.defaultLanguage,
        country.regex ?? ''
      ]);
  }

  Future<Country> getCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final cntry = prefs.getStringList('country');
    if (cntry != null)
      return Country(
        name: cntry[0],
        isoCode: cntry[1],
        countryCode: int.parse(cntry[2]),
        currency: cntry[3],
        defaultLanguage: cntry[4],
        regex: cntry[5] ?? '',
      );
    else
      return null;
  }

  Future<void> deleteCountry() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('country');
  }

  Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('language');
  }
}

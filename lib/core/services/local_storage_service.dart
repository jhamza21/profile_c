import 'package:profilecenter/models/search_suggestion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<String> getAppLanguage() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString("language_code");
  }

  Future<void> setAppLanguage(String languageCode) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString("language_code", languageCode);
  }

  Future<bool> saveOffer(
      int idUser,
      String title,
      List<String> skills,
      String distance,
      String mobility,
      String language,
      String offerType) async {
    var prefs = await SharedPreferences.getInstance();
    List<SearchSuggestion> _savedSearchs = [];
    final String savedSuggestionsString =
        prefs.getString('saved_offers_$idUser');
    if (savedSuggestionsString != null)
      _savedSearchs = SearchSuggestion.decode(savedSuggestionsString);

    //test if search exists (same title) => replace it
    _savedSearchs.removeWhere((element) => element.title == title);
    //save only 100 old search
    if (_savedSearchs.length > 100) _savedSearchs.removeAt(0);
    //save new search
    _savedSearchs.add(SearchSuggestion(
        title: title,
        skills: skills,
        role: null,
        experience: null,
        salary: null,
        distance: distance,
        mobility: mobility,
        offerType: offerType,
        language: language));
    final String encodedData = SearchSuggestion.encode(_savedSearchs);
    await prefs.setString('saved_offers_$idUser', encodedData);
    return true;
  }

  Future<List<SearchSuggestion>> readOffers(int idUser, String text) async {
    var prefs = await SharedPreferences.getInstance();
    final String savedSuggestionsString =
        prefs.getString('saved_offers_$idUser');
    if (savedSuggestionsString == null) return [];

    List<SearchSuggestion> _searchSuggestions =
        SearchSuggestion.decode(savedSuggestionsString);
    List<SearchSuggestion> _res = [];
    if (text != null && text != '')
      _searchSuggestions.forEach((element) {
        if (element.title.contains(text)) _res.add(element);
      });
    else {
      if (_searchSuggestions.length > 10)
        _res = _searchSuggestions.sublist(_searchSuggestions.length - 10);
      else
        _res = _searchSuggestions;
    }
    return _res;
  }

  Future<bool> saveTalent(
      int idUser,
      String title,
      List<String> skills,
      String role,
      String distance,
      String salary,
      String experience,
      String mobility) async {
    var prefs = await SharedPreferences.getInstance();

    List<SearchSuggestion> _savedSearchs = [];
    final String savedSuggestionsString =
        prefs.getString('saved_talents_$idUser');
    if (savedSuggestionsString != null)
      _savedSearchs = SearchSuggestion.decode(savedSuggestionsString);

    //test if search exists (same title) => replace it
    _savedSearchs.removeWhere((element) => element.title == title);
    //save only 100 old search
    if (_savedSearchs.length > 100) _savedSearchs.removeAt(0);
    //save new search
    _savedSearchs.add(SearchSuggestion(
        title: title,
        skills: skills,
        role: role,
        experience: experience,
        salary: salary,
        distance: distance,
        mobility: mobility,
        offerType: null,
        language: null));
    final String encodedData = SearchSuggestion.encode(_savedSearchs);
    await prefs.setString('saved_talents_$idUser', encodedData);
    return true;
  }

  Future<List<SearchSuggestion>> readTalents(int idUser, String text) async {
    var prefs = await SharedPreferences.getInstance();
    final String savedSuggestionsString =
        prefs.getString('saved_talents_$idUser');
    if (savedSuggestionsString == null) return [];

    List<SearchSuggestion> _searchSuggestions =
        SearchSuggestion.decode(savedSuggestionsString);
    List<SearchSuggestion> _res = [];
    if (text != null && text != '')
      _searchSuggestions.forEach((element) {
        if (element.title.contains(text)) _res.add(element);
      });
    else {
      if (_searchSuggestions.length > 4)
        _res = _searchSuggestions.sublist(_searchSuggestions.length - 4);
      else
        _res = _searchSuggestions;
    }
    return _res;
  }
}

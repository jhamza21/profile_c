import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/platform_skills_provider.dart';
import 'package:profilecenter/providers/supported_countries_provider.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/models/search_suggestion.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/matching_service.dart';
import 'package:profilecenter/core/services/local_storage_service.dart';
import 'package:profilecenter/modules/companyOffers/language_model.dart';
import 'package:profilecenter/modules/offers/map.dart';
import 'package:profilecenter/modules/offers/offer_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:profilecenter/widgets/search_skill_card.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/distance_filter.dart';
import 'package:profilecenter/widgets/language_filter.dart';
import 'package:profilecenter/widgets/mobility_filter.dart';
import 'package:profilecenter/widgets/offer_type_filter.dart';
import 'package:provider/provider.dart';

class SearchOffers extends StatefulWidget {
  @override
  _SearchOffersState createState() => _SearchOffersState();
}

class _SearchOffersState extends State<SearchOffers> {
  final FocusNode _textFocusNode = FocusNode();
  TextEditingController _typeAheadController = TextEditingController();
  final _tagsFieldController = TextEditingController();
  bool _isSearching = false;
  bool _showMap = false;

  List<Offer> _offers = [];
  List<Offer> _filtredOffers = [];

  List<String> _filtredAvailableSkillsInPlatform = [];

  List<String> _skills = [];

  int _selectedDistance;
  int _selectedMobility;
  int _selectedOfferType;
  int _selectedLanguage;

  @override
  void initState() {
    super.initState();
    searchAvailableSkillsInPlatform();
    searchSuggestions();
    fetchSupportedCountries();
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _typeAheadController.dispose();
    super.dispose();
  }

  // This function is executed when the clear button is pressed
  void _clearTextField() {
    // Clear everything in the text field
    _typeAheadController.clear();
    // Call setState to update the UI
    setState(() {
      _tagsFieldController.removeListener(() {});
      _textFocusNode.removeListener(() {});
      _typeAheadController.removeListener(() {});
    });
    searchAvailableSkillsInPlatform();
    searchSuggestions();
    fetchSupportedCountries();
  }

  void searchAvailableSkillsInPlatform() async {
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: false);
    platformSkillsProvider.fetchSkills(context);
  }

  void fetchSupportedCountries() {
    SupportedCountriesProvider supportedCountriesProvider =
        Provider.of<SupportedCountriesProvider>(context, listen: false);
    supportedCountriesProvider.fetchCountries(context);
  }

  void filterOffers() {
    setState(() {
      _isSearching = true;
    });
    _filtredOffers = [];

    //saving search
    String _searchText = _typeAheadController.text;
    //if (_searchText != '') saveSearch(_searchText);

    //filter offers
    for (int i = 0; i < _offers.length; i++) {
      //filter by offer type
      if (_selectedOfferType != null) {
        if (_offers[i].offerType != OFFER_TYPES_FILTER[_selectedOfferType])
          continue;
      }
      //filter by distance
      if (_selectedDistance != null) {
        if (_offers[i].distance == null ||
            _offers[i].distance >
                double.parse(DISTANCES_FILTER[_selectedDistance])) continue;
      }

      //filter by mobility
      if (_selectedMobility != null && _offers[i].mobility != "") {
        if (_offers[i].mobility != MOBILITIES_FILTER[_selectedMobility])
          continue;
      }
      //filter by offer required languages
      if (_selectedLanguage != null) {
        if (!containsLanguage(
            LANGUAGES_FILTER[_selectedLanguage], _offers[i].languages))
          continue;
      }
      //filter by text
      if (_searchText != '') {
        Offer _offer = _offers[i];
        if (!(_offer.title.toLowerCase().contains(_searchText.toLowerCase()) ||
            _offer.description.contains(_searchText.toLowerCase()) ||
            _offer.company.name.contains(_searchText.toLowerCase()))) continue;
      }
      _filtredOffers.add(_offers[i]);
    }
    setState(() {
      _isSearching = false;
    });
  }

  void sortOffers() {
    _offers.sort((a, b) {
      return (b.note - a.note).toInt();
    });
  }

  void saveSearch(String title) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    try {
      if (title != '' || title != null) {
        await LocalStorageService().saveOffer(
          userProvider.user.id,
          title,
          _skills,
          _selectedDistance != null
              ? DISTANCES_FILTER[_selectedDistance]
              : null,
          _selectedMobility != null
              ? MOBILITIES_FILTER[_selectedMobility]
              : null,
          _selectedLanguage != null
              ? LANGUAGES_FILTER[_selectedLanguage]
              : null,
          _selectedOfferType != null
              ? OFFER_TYPES_FILTER[_selectedOfferType]
              : null,
        );
      }
    } catch (e) {}
  }

  bool containsLanguage(String languageToSearch, List<Language> languages) {
    for (int i = 0; i < languages.length; i++) {
      if (languages[i].title == languageToSearch) return true;
    }
    return false;
  }

  void searchSuggestions() async {
    try {
      setState(() {
        _isSearching = true;
      });
      _offers = [];
      var res = await MatchingService().getOffersSuggestions(
          [JOB_OFFER, PROJECT_OFFER, INTERSHIP_OFFER], _skills);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _offers = Offer.listFromJson(jsonData["data"]);
      sortOffers();
      filterOffers();
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  Widget searchByText(UserProvider userProvider) {
    return TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          autofocus: false,
          focusNode: _textFocusNode,
          onEditingComplete: () => filterOffers(),
          controller: _typeAheadController,
          style: TextStyle(color: Colors.white),
          decoration: inputTextDecoration(
              10.0,
              Icon(Icons.search, color: RED_LIGHT),
              getTranslate(context, "SEARCH_HERE"),
              null,
              IconButton(
                  icon: Icon(Icons.clear_rounded),
                  onPressed: _clearTextField,
                  color: RED_LIGHT)),
        ),
        suggestionsCallback: (text) =>
            LocalStorageService().readOffers(userProvider.user.id, text),
        hideSuggestionsOnKeyboardHide: true,
        hideOnLoading: false,
        hideOnEmpty: false,
        keepSuggestionsOnLoading: false,
        keepSuggestionsOnSuggestionSelected: false,
        debounceDuration: Duration(milliseconds: 500),
        noItemsFoundBuilder: (value) {
          return Container(
            color: BLUE_DARK_LIGHT,
            height: 50,
            child: Center(
              child: Text(
                getTranslate(context, "NO_DATA"),
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        itemBuilder: (context, SearchSuggestion searchSuggestion) {
          return null;
          // ListTile(
          // title: Text(
          //  searchSuggestion.title,
          // style: TextStyle(color: BLUE_DARK),
          // ),
          // );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return null;
          //suggestionsBox;
        },
        onSuggestionSelected: (SearchSuggestion searchSuggestion) {
          _typeAheadController.text = searchSuggestion.title;
          _skills = searchSuggestion.skills;

          if (searchSuggestion.distance != null)
            _selectedDistance =
                DISTANCES_FILTER.indexOf(searchSuggestion.distance);
          else
            _selectedDistance = null;

          if (searchSuggestion.mobility != null)
            _selectedMobility =
                MOBILITIES_FILTER.indexOf(searchSuggestion.mobility);
          else
            _selectedMobility = null;

          if (searchSuggestion.language != null)
            _selectedLanguage =
                LANGUAGES_FILTER.indexOf(searchSuggestion.language);
          else
            _selectedLanguage = null;

          if (searchSuggestion.offerType != null)
            _selectedOfferType =
                OFFER_TYPES_FILTER.indexOf(searchSuggestion.offerType);
          else
            _selectedOfferType = null;

          searchSuggestions();
        });
  }

  void deleteSkill(String title) {
    setState(() {
      _skills.remove(title);
    });
    searchSuggestions();
  }

  Widget searchBySkillsTags(PlatformSkillsProvider platformSkillsProvider) {
    List<Widget> _widgets =
        _skills.map<Widget>((e) => SearchSkillCard(e, deleteSkill)).toList();
    _widgets.add(GestureDetector(
      onTap: () async {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return WillPopScope(
                onWillPop: () => Future.value(false),
                child: addSkillsDialog(platformSkillsProvider),
              );
            });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: RED_BURGUNDY),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Row(
          children: [
            Icon(
              Icons.add_circle,
              color: RED_LIGHT,
              size: 18,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              getTranslate(context, "ADD_SKILL"),
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
    ));
    return Container(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _widgets,
      ),
    );
  }

  void filterAvailableSkillsInPlatform(
      set, String text, PlatformSkillsProvider platformSkillsProvider) {
    set(() {
      _filtredAvailableSkillsInPlatform = [];
      if (text == '' || text == null) {
        _filtredAvailableSkillsInPlatform = platformSkillsProvider.subSkills;
        return;
      }
      platformSkillsProvider.subSkills.forEach((element) {
        if (element.toLowerCase().contains(text.toLowerCase()))
          _filtredAvailableSkillsInPlatform.add(element);
      });
    });
  }

  Widget addSkillsDialog(PlatformSkillsProvider platformSkillsProvider) {
    _filtredAvailableSkillsInPlatform = platformSkillsProvider.subSkills;
    return StatefulBuilder(builder: (context, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: BLUE_DARK_LIGHT,
              height: 40.0,
              child: Center(
                  child: Text(
                getTranslate(context, "ADD_SKILL"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: _tagsFieldController,
                    decoration: inputTextDecoration(10.0, null,
                        getTranslate(context, "SEARCH_HERE"), null, null),
                    onChanged: (value) => filterAvailableSkillsInPlatform(
                        set, value, platformSkillsProvider),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 260,
                    width: 300,
                    child: Scrollbar(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: [
                          ..._filtredAvailableSkillsInPlatform.map(
                            (e) => InkWell(
                              onTap: () {
                                if (!_skills.contains(e)) {
                                  set(() {
                                    _tagsFieldController.text = e;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: _skills.contains(e)
                                          ? RED_LIGHT
                                          : BLUE_DARK_LIGHT),
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        color: _skills.contains(e)
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                      onPressed: _tagsFieldController.text == null ||
                              _tagsFieldController.text == '' ||
                              _skills.contains(_tagsFieldController.text)
                          ? null
                          : () {
                              _skills.add(_tagsFieldController.text);
                              _tagsFieldController.text = '';
                              Navigator.of(context).pop();
                              searchSuggestions();
                            },
                      child: Text(
                        getTranslate(context, "ADD"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _tagsFieldController.text = '';
                      },
                      child: Text(
                        getTranslate(context, "CLOSE"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget searchByPredefinedButtons(UserProvider userProvider) {
    return Container(
      height: 30,
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_left, color: GREY_LIGHt),
          Expanded(
            child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  OfferTypeFilter(_selectedOfferType, (int newOfferTypeIndex) {
                    _selectedOfferType = newOfferTypeIndex;
                    filterOffers();
                  }),
                  SizedBox(width: 10),
                  DistanceFilter(_selectedDistance, (int newDistanceIndex) {
                    _selectedDistance = newDistanceIndex;
                    filterOffers();
                  }),
                  SizedBox(width: 10),
                  MobilityFilter(_selectedMobility, (int newMobilityIndex) {
                    _selectedMobility = newMobilityIndex;
                    filterOffers();
                  }),
                  SizedBox(width: 10),
                  LanguageFilter(_selectedLanguage, (int newLanguageIndex) {
                    _selectedLanguage = newLanguageIndex;
                    filterOffers();
                  }),
                ]),
          ),
          Icon(Icons.keyboard_arrow_right, color: GREY_LIGHt),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    SupportedCountriesProvider supportedCountriesProvider =
        Provider.of<SupportedCountriesProvider>(context, listen: true);
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "OFFERS")),
        leading: SizedBox.shrink(),
      ),
      body: platformSkillsProvider.isLoading ||
              supportedCountriesProvider.isLoading
          ? Center(child: circularProgress)
          : platformSkillsProvider.isError || supportedCountriesProvider.isError
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchByText(userProvider),
                        SizedBox(height: 15),
                        searchByPredefinedButtons(userProvider),
                        Divider(color: GREY_LIGHt),
                        searchBySkillsTags(platformSkillsProvider),
                        Divider(color: GREY_LIGHt),
                        _isSearching || supportedCountriesProvider.isLoading
                            ? Padding(
                                padding: const EdgeInsets.only(top: 50.0),
                                child: Center(
                                  child: circularProgress,
                                ),
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${_filtredOffers.length} ${getTranslate(context, "FOUND_OFFERS")}"),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showMap = !_showMap;
                                            });
                                          },
                                          icon: Image.asset(_showMap
                                              ? MAP_ICON_SELECTED
                                              : MAP_ICON))
                                    ],
                                  ),
                                  _showMap
                                      ? Map(
                                          userProvider.user.address,
                                          _selectedDistance != null
                                              ? int.parse(DISTANCES_FILTER[
                                                  _selectedDistance])
                                              : null,
                                          _filtredOffers)
                                      : SizedBox.shrink(),
                                  ..._filtredOffers
                                      .map((offer) => OfferCard(offer, () {
                                            setState(() {});
                                          })),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

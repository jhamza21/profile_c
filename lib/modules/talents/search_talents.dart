import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/providers/platform_skills_provider.dart';
import 'package:profilecenter/utils/helpers/get_days_between_dates.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/models/search_suggestion.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/providers/compare_provider.dart';
import 'package:profilecenter/providers/favorite_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/matching_service.dart';
import 'package:profilecenter/core/services/local_storage_service.dart';
import 'package:profilecenter/modules/compareCenter/compare_screen.dart';
import 'package:profilecenter/modules/talents/candidat_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:profilecenter/widgets/search_skill_card.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/modules/talents/map.dart';
import 'package:profilecenter/widgets/distance_filter.dart';
import 'package:profilecenter/widgets/experience_filter.dart';
import 'package:profilecenter/widgets/mobility_filter.dart';
import 'package:profilecenter/widgets/role_filter.dart';
import 'package:profilecenter/widgets/salary_filter.dart';
import 'package:provider/provider.dart';

class SearchTalents extends StatefulWidget {
  @override
  _SearchTalentsState createState() => _SearchTalentsState();
}

class _SearchTalentsState extends State<SearchTalents> {
  TextEditingController _typeAheadController = TextEditingController();
  final _tagsFieldController = TextEditingController();
  bool _isSearching = false;
  bool _showMap = false;

  List<User> _talents = [];
  List<User> _filtredTalents = [];

  List<String> _filtredAvailableSkillsInPlatform = [];

  List<String> _skills = [];

  int _selectedRole;
  int _selectedDistance;
  int _selectedSalary;
  int _selectedExperience;
  int _selectedMobility;

  @override
  void initState() {
    super.initState();
    searchAvailableSkillsInPlatform();
    fetchFavorite();
    searchSuggestions();
  }

  // This function is triggered when the clear buttion is pressed
  void _clearTextField() {
    // Clear everything in the text field
    _typeAheadController.clear();
    // _typeAheadController.text = '';
    // Call setState to update the UI
    setState(() {
      _typeAheadController.removeListener(() {});
    });
    searchAvailableSkillsInPlatform();
    fetchFavorite();
    searchSuggestions();
  }

  void searchAvailableSkillsInPlatform() {
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: false);
    platformSkillsProvider.fetchSkills(context);
  }

  void fetchFavorite() async {
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.fetchFavorite(context);
  }

  void filterTalents() {
    setState(() {
      _isSearching = true;
    });
    _filtredTalents = [];

    //saving search
    String _searchText = _typeAheadController.text;
    //if (_searchText != '') saveSearch(_searchText);

    //filter talents
    for (int i = 0; i < _talents.length; i++) {
      //filter by role
      if (_selectedRole != null) {
        if (_talents[i].role.toUpperCase() != ROLES_FILTER[_selectedRole])
          continue;
      }
      //filter by distance
      if (_selectedDistance != null) {
        if (_talents[i].distance == null ||
            _talents[i].distance >
                double.parse(DISTANCES_FILTER[_selectedDistance])) continue;
      }
      //filter by salaire
      if (_selectedSalary != null) {
        if (_talents[i].salary == 0.0 ||
            _talents[i].salary == null ||
            _talents[i].salary > double.parse(SALARIES_FILTER[_selectedSalary]))
          continue;
      }

      //filter by experience
      int _experiencesDays = 0;
      if (_selectedExperience != null) {
        _talents[i].experiences.forEach((element) {
          _experiencesDays += getDays(element.startDate, element.endDate);
        });
        //3ans
        if (EXPERIENCES_FILTER[_selectedExperience] == "<3" &&
            _experiencesDays > 3 * 365) continue;
        //[3,8] ans
        if (EXPERIENCES_FILTER[_selectedExperience] == "[3,8]" &&
            (_experiencesDays < 3 * 365 || _experiencesDays > 8 * 365))
          continue;
        //8ans
        if (EXPERIENCES_FILTER[_selectedExperience] == ">8" &&
            _experiencesDays < 8 * 365) continue;
      }

      //filter by mobility
      if (_selectedMobility != null && _talents[i].mobility != "") {
        if (_talents[i].mobility != MOBILITIES_FILTER[_selectedMobility])
          continue;
      }

      //filter by text
      if (_searchText != '') {
        User _talent = _talents[i];
        if (!(_talent.firstName
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            _talent.lastName
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            containsExperience(_searchText.toLowerCase(), _talent.experiences)))
          continue;
      }
      _filtredTalents.add(_talents[i]);
    }
    setState(() {
      _isSearching = false;
    });
  }

  void sortTalents() {
    _talents.sort((a, b) {
      return (b.note - a.note).toInt();
    });
  }

  void saveSearch(String title) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    try {
      if (title != '' || title != null) {
        await LocalStorageService().saveTalent(
          userProvider.user.id,
          title,
          _skills,
          _selectedRole != null ? ROLES_FILTER[_selectedRole] : null,
          _selectedDistance != null
              ? DISTANCES_FILTER[_selectedDistance]
              : null,
          _selectedSalary != null ? SALARIES_FILTER[_selectedSalary] : null,
          _selectedExperience != null
              ? EXPERIENCES_FILTER[_selectedExperience]
              : null,
          _selectedMobility != null
              ? MOBILITIES_FILTER[_selectedMobility]
              : null,
        );
      }
    } catch (e) {}
  }

  bool containsExperience(
      String experienceToSearch, List<Experience> experiences) {
    for (int i = 0; i < experiences.length; i++) {
      if (experiences[i].title == experienceToSearch) return true;
    }
    return false;
  }

  void searchSuggestions() async {
    try {
      setState(() {
        _isSearching = true;
      });
      CompareProvider compareProvider =
          Provider.of<CompareProvider>(context, listen: false);
      compareProvider.intialize(_skills, []);
      _talents = [];
      var res = await MatchingService().getCandidatSuggestions(
          [FREELANCE_ROLE, STAGIAIRE_ROLE, APPRENTI_ROLE, SALARIEE_ROLE],
          _skills);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _talents = User.listFromJson(jsonData["data"]);
      sortTalents();
      filterTalents();
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
          onEditingComplete: () => filterTalents(),
          controller: _typeAheadController,
          style: TextStyle(color: Colors.white60),
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
            LocalStorageService().readTalents(userProvider.user.id, text),
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
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
        itemBuilder: (context, SearchSuggestion searchSuggestion) {
          return null;
          //ListTile(
          // title: Text(
          //   searchSuggestion.title,
          //  style: TextStyle(color: BLUE_DARK),
          //  ),
          // );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return null;
          //suggestionsBox;
        },
        onSuggestionSelected: (SearchSuggestion searchSuggestion) {
          _typeAheadController.text = searchSuggestion.title;
          _skills = searchSuggestion.skills;
          if (searchSuggestion.role != null)
            _selectedRole = ROLES_FILTER.indexOf(searchSuggestion.role);
          else
            _selectedRole = null;

          if (searchSuggestion.distance != null)
            _selectedDistance =
                DISTANCES_FILTER.indexOf(searchSuggestion.distance);
          else
            _selectedDistance = null;

          if (searchSuggestion.salary != null)
            _selectedSalary = SALARIES_FILTER.indexOf(searchSuggestion.salary);
          else
            _selectedSalary = null;

          if (searchSuggestion.experience != null)
            _selectedExperience =
                EXPERIENCES_FILTER.indexOf(searchSuggestion.experience);
          else
            _selectedExperience = null;

          if (searchSuggestion.mobility != null)
            _selectedMobility =
                MOBILITIES_FILTER.indexOf(searchSuggestion.mobility);
          else
            _selectedMobility = null;

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
            child: ListView(scrollDirection: Axis.horizontal, children: [
              RoleFilter(_selectedRole, (int newRoleIndex) {
                _selectedRole = newRoleIndex;
                filterTalents();
              }),
              SizedBox(width: 10),
              DistanceFilter(_selectedDistance, (int newDistanceIndex) {
                _selectedDistance = newDistanceIndex;
                filterTalents();
              }),
              SizedBox(width: 10),
              SalaryFilter(_selectedSalary, (int newSalaryIndex) {
                _selectedSalary = newSalaryIndex;
                filterTalents();
              }),
              SizedBox(width: 10),
              ExperienceFilter(_selectedExperience, (int newExperienceIndex) {
                _selectedExperience = newExperienceIndex;
                filterTalents();
              }),
              SizedBox(width: 10),
              MobilityFilter(_selectedMobility, (int newMobilityIndex) {
                _selectedMobility = newMobilityIndex;
                filterTalents();
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
    CompareProvider compareProvider =
        Provider.of<CompareProvider>(context, listen: true);
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: true);
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "TALENTS")),
        leading: SizedBox.shrink(),
      ),
      floatingActionButton: compareProvider.usersToCompare.length != 0
          ? FloatingActionButton(
              mini: true,
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(CompareScreen.routeName, arguments: _skills);
                  },
                  icon: Image.asset(COMPARE_ICON)),
              onPressed: () {},
            )
          : SizedBox.shrink(),
      body: platformSkillsProvider.isLoading || favoriteProvider.isLoading
          ? Center(child: circularProgress)
          : platformSkillsProvider.isError || favoriteProvider.isError
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
                        _isSearching
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
                                          "${_filtredTalents.length} ${getTranslate(context, "FIND_TALENTS")}"),
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
                                          _filtredTalents)
                                      : SizedBox.shrink(),
                                  ..._filtredTalents
                                      .map((talent) => CandidatCard(talent)),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

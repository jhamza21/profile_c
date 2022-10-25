import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/providers/intership_offers_provider.dart';
import 'package:profilecenter/providers/job_offers_provider.dart';
import 'package:profilecenter/providers/platform_languages_provider.dart';
import 'package:profilecenter/providers/platform_skills_provider.dart';
import 'package:profilecenter/providers/platform_tools_provider.dart';
import 'package:profilecenter/providers/project_offers_provider.dart';
import 'package:profilecenter/modules/companyOffers/language_model.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class AddUpdateOffer extends StatefulWidget {
  static const routeName = '/addUpdateOffer';
  final AddUpdateOfferArguments arguments;
  AddUpdateOffer(this.arguments);

  @override
  _AddUpdateOfferState createState() => _AddUpdateOfferState();
}

class _AddUpdateOfferState extends State<AddUpdateOffer> {
  final _formKey = new GlobalKey<FormState>();
  bool _isSaving = false;

  String _title, _description;

  List<Skill> _selectedSkills = [];

  List<Skill> _selectedTools = [];

  List<Language> _selectedLanguages = [];

  String _selectedMobility = "presentiel";

  @override
  void initState() {
    super.initState();
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: false);
    platformSkillsProvider.fetchSkills(context);
    PlatformToolsProvider platformToolsProvider =
        Provider.of<PlatformToolsProvider>(context, listen: false);
    platformToolsProvider.fetchTools(context);
    PlatformLanguagesProvider platformLanguagesProvider =
        Provider.of<PlatformLanguagesProvider>(context, listen: false);
    platformLanguagesProvider.fetchLanguages(context);
    initializeData();
  }

  void initializeData() {
    if (widget.arguments.offer != null) {
      Offer offer = widget.arguments.offer;
      _title = offer.title;
      _description = offer.description;
      _selectedMobility = offer.mobility;
      _selectedSkills = offer.skills;
      _selectedTools = offer.tools;
      _selectedLanguages = offer.languages;
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          getTranslate(context, "OFFER_TITLE"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          initialValue: _title,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          decoration: inputTextDecoration(
              10.0, null, getTranslate(context, "OFFER_TITLE"), null, null),
          keyboardType: TextInputType.text,
          onSaved: (value) => _title = value.trim(),
        ),
      ],
    );
  }

  Widget buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          getTranslate(context, "OFFER_DESCRIPTION"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        TextFormField(
          style: TextStyle(color: Colors.white),
          maxLength: 100,
          initialValue: _description,
          validator: (value) =>
              value.isEmpty ? getTranslate(context, "FILL_IN_FIELD") : null,
          keyboardType: TextInputType.text,
          onSaved: (value) => _description = value.trim(),
          maxLines: 4,
          decoration: inputTextDecoration(10.0, null,
              getTranslate(context, "OFFER_DESCRIPTION"), null, null),
        ),
      ],
    );
  }

  Widget _addSkillDialog(dialogContext, context) {
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: false);
    Skill _selectedSkill;
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(dialogContext).size.width,
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Center(
                  child: Text(
                getTranslate(context, "ADD_SKILL"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FormField<String>(builder: (FormFieldState<String> state) {
                return InputDecorator(
                  decoration: inputTextDecoration(10.0, null,
                      getTranslate(context, "REQUIRED_SKILLS"), null, null),
                  isEmpty: _selectedSkill == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Skill>(
                      value: _selectedSkill,
                      dropdownColor: BLUE_LIGHT,
                      icon: Icon(
                        Icons.arrow_drop_down_sharp,
                        color: Colors.white,
                      ),
                      isDense: true,
                      onChanged: (Skill newValue) {
                        set(() {
                          _selectedSkill = newValue;
                          state.didChange(newValue.title);
                        });
                      },
                      items: platformSkillsProvider.skills.map((Skill value) {
                        return DropdownMenuItem<Skill>(
                          value: value,
                          child: Text(
                            value.title,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 10.0),
            if (_selectedSkill != null)
              Container(
                height: 260,
                width: 300,
                child: Scrollbar(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      ..._selectedSkill.subSkills.map((e) => ListTile(
                          onTap: () {
                            if (!_selectedSkills.contains(e))
                              setState(() {
                                _selectedSkills.add(e);
                              });
                          },
                          contentPadding: EdgeInsets.only(left: 8.0),
                          leading: Icon(
                            Icons.add_circle_rounded,
                            color: RED_DARK,
                            size: 20,
                          ),
                          title: Text(
                            e.title,
                            style: TextStyle(color: Colors.white),
                          ))),
                    ],
                  ),
                ),
              ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(getTranslate(context, "CANCEL"))),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget selectedSkillsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${getTranslate(context, "REQUIRED_SKILLS")} :",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return _addSkillDialog(dialogContext, context);
                      });
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                ))
          ],
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: GREY_LIGHt, width: 1.5),
              color: BLUE_DARK,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedSkills.length == 0)
                Text(getTranslate(context, "NO_DATA")),
              ..._selectedSkills.map((e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "• " + e.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedSkills.remove(e);
                            });
                          },
                          icon: SizedBox(
                            height: 18.0,
                            width: 18.0,
                            child: Image.asset(TRASH_ICON, color: GREY_LIGHt),
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addToolDialog(dialogContext, context) {
    PlatformToolsProvider platformToolsProvider =
        Provider.of<PlatformToolsProvider>(context, listen: false);
    Skill _selectedTool;
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(dialogContext).size.width,
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Center(
                  child: Text(
                getTranslate(context, "ADD_TOOL"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FormField<String>(builder: (FormFieldState<String> state) {
                return InputDecorator(
                  decoration: inputTextDecoration(10.0, null,
                      getTranslate(context, "REQUIRED_TOOLS"), null, null),
                  isEmpty: _selectedTool == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Skill>(
                      value: _selectedTool,
                      dropdownColor: BLUE_LIGHT,
                      icon: Icon(
                        Icons.arrow_drop_down_sharp,
                        color: Colors.white,
                      ),
                      isDense: true,
                      onChanged: (Skill newValue) {
                        set(() {
                          _selectedTool = newValue;
                          state.didChange(newValue.title);
                        });
                      },
                      items: platformToolsProvider.tools.map((Skill value) {
                        return DropdownMenuItem<Skill>(
                          value: value,
                          child: Text(
                            value.title,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 10.0),
            if (_selectedTool != null)
              Container(
                height: 260,
                width: 300,
                child: Scrollbar(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      ..._selectedTool.subSkills.map((e) => ListTile(
                          onTap: () {
                            if (!_selectedTools.contains(e))
                              setState(() {
                                _selectedTools.add(e);
                              });
                          },
                          contentPadding: EdgeInsets.only(left: 8.0),
                          leading: Icon(
                            Icons.add_circle_rounded,
                            color: RED_DARK,
                            size: 20,
                          ),
                          title: Text(
                            e.title,
                            style: TextStyle(color: Colors.white),
                          ))),
                    ],
                  ),
                ),
              ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(getTranslate(context, "CANCEL"))),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget selectedToolsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${getTranslate(context, "REQUIRED_TOOLS")} :",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return _addToolDialog(dialogContext, context);
                      });
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                ))
          ],
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: GREY_LIGHt, width: 1.5),
              color: BLUE_DARK,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedTools.length == 0)
                Text(getTranslate(context, "NO_DATA")),
              ..._selectedTools.map((e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "• " + e.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedTools.remove(e);
                            });
                          },
                          icon: SizedBox(
                            height: 18.0,
                            width: 18.0,
                            child: Image.asset(TRASH_ICON, color: GREY_LIGHt),
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addLanguageDialog(dialogContext, context) {
    PlatformLanguagesProvider platformLanguagesProvider =
        Provider.of<PlatformLanguagesProvider>(context, listen: false);
    Language _selectedLanguage;
    return StatefulBuilder(builder: (dialogContext, set) {
      return AlertDialog(
        backgroundColor: BLUE_LIGHT,
        contentPadding: EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(dialogContext).size.width,
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Center(
                  child: Text(
                getTranslate(context, "ADD_LANGUAGE"),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FormField<String>(builder: (FormFieldState<String> state) {
                return InputDecorator(
                  decoration: inputTextDecoration(10.0, null,
                      getTranslate(context, "REQUIRED_LANGUAGES"), null, null),
                  isEmpty: _selectedLanguage == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Language>(
                      value: _selectedLanguage,
                      dropdownColor: BLUE_LIGHT,
                      icon: Icon(
                        Icons.arrow_drop_down_sharp,
                        color: Colors.white,
                      ),
                      isDense: true,
                      onChanged: (Language newValue) {
                        set(() {
                          _selectedLanguage = newValue;
                          state.didChange(newValue.title);
                        });
                      },
                      items: platformLanguagesProvider.languages
                          .map((Language value) {
                        return DropdownMenuItem<Language>(
                          value: value,
                          child: Text(
                            value.title,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 10.0),
            if (_selectedLanguage != null)
              Container(
                height: 260,
                width: 300,
                child: Scrollbar(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      ..._selectedLanguage.levels.map((e) => ListTile(
                          onTap: () {
                            int _exist = _selectedLanguages.indexWhere(
                                (element) =>
                                    element.id == _selectedLanguage.id);
                            if (_exist == -1)
                              setState(() {
                                _selectedLanguage.selectedLevel = e.title;
                                _selectedLanguages.add(_selectedLanguage);
                              });
                          },
                          contentPadding: EdgeInsets.only(left: 8.0),
                          leading: Icon(
                            Icons.add_circle_rounded,
                            color: RED_DARK,
                            size: 20,
                          ),
                          title: Text(
                            e.title,
                            style: TextStyle(color: Colors.white),
                          ))),
                    ],
                  ),
                ),
              ),
            Container(
              height: 40.0,
              decoration: BoxDecoration(color: BLUE_DARK_LIGHT),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(BLUE_DARK_LIGHT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(getTranslate(context, "CANCEL"))),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget selectedLanguageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${getTranslate(context, "REQUIRED_LANGUAGES")} :",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return _addLanguageDialog(dialogContext, context);
                      });
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                ))
          ],
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: GREY_LIGHt, width: 1.5),
              color: BLUE_DARK,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedLanguages.length == 0)
                Text(getTranslate(context, "NO_DATA")),
              ..._selectedLanguages.map((e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "• ${e.title} (${e.selectedLevel})",
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedLanguages.remove(e);
                            });
                          },
                          icon: SizedBox(
                            height: 18.0,
                            width: 18.0,
                            child: Image.asset(TRASH_ICON, color: GREY_LIGHt),
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMobilityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(getTranslate(context, "MOBILITY"),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.0),
        FormField<String>(builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: inputTextDecoration(
                10.0, null, getTranslate(context, "MOBILITY"), null, null),
            isEmpty: _selectedMobility == null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMobility,
                dropdownColor: BLUE_LIGHT,
                icon: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                isDense: true,
                onChanged: (String newValue) {
                  setState(() {
                    _selectedMobility = newValue;
                    state.didChange(newValue);
                  });
                },
                items:
                    ["remote", "presentiel", "indifferent"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      getTranslate(context, value),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildSaveBtn() {
    return TextButton.icon(
      icon: _isSaving ? circularProgress : SizedBox(),
      label: Text(
        getTranslate(context, 'SAVE'),
      ),
      onPressed: _isSaving
          ? null
          : () async {
              if (validateAndSave()) {
                try {
                  setState(() {
                    _isSaving = true;
                  });
                  final res = widget.arguments.offer == null
                      ? await OfferService().addOffer(
                          widget.arguments.type,
                          _title,
                          _description,
                          _selectedSkills,
                          _selectedTools,
                          _selectedLanguages,
                          _selectedMobility)
                      : await OfferService().updateOffer(
                          widget.arguments.type,
                          widget.arguments.offer.id,
                          _title,
                          _description,
                          widget.arguments.offer.status,
                          _selectedSkills,
                          _selectedTools,
                          _selectedLanguages,
                          _selectedMobility);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  final jsonData = json.decode(res.body);
                  if (widget.arguments.type == JOB_OFFER) {
                    JobOffersProvider jobOffersProvider =
                        Provider.of<JobOffersProvider>(context, listen: false);
                    jobOffersProvider
                        .addJobOffer(Offer.fromJson(jsonData["data"]));
                  } else if (widget.arguments.type == PROJECT_OFFER) {
                    ProjectOffersProvider projectOffersProvider =
                        Provider.of<ProjectOffersProvider>(context,
                            listen: false);
                    projectOffersProvider
                        .addProjectOffer(Offer.fromJson(jsonData["data"]));
                  } else {
                    IntershipOffersProvider intershipOffersProvider =
                        Provider.of<IntershipOffersProvider>(context,
                            listen: false);
                    intershipOffersProvider
                        .addIntershipOffer(Offer.fromJson(jsonData["data"]));
                  }
                  showSnackbar(
                      context,
                      widget.arguments.offer == null
                          ? getTranslate(context, "ADD_SUCCESS")
                          : getTranslate(context, "MODIFY_SUCCESS"));
                  Navigator.of(context).pop();
                } catch (e) {
                  setState(() {
                    _isSaving = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                }
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    PlatformSkillsProvider platformSkillsProvider =
        Provider.of<PlatformSkillsProvider>(context, listen: true);
    PlatformToolsProvider platformToolsProvider =
        Provider.of<PlatformToolsProvider>(context, listen: true);
    PlatformLanguagesProvider platformLanguagesProvider =
        Provider.of<PlatformLanguagesProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, widget.arguments.type)),
      ),
      body: platformSkillsProvider.isLoading ||
              platformToolsProvider.isLoading ||
              platformLanguagesProvider.isLoading
          ? Center(
              child: circularProgress,
            )
          : platformSkillsProvider.isError ||
                  platformToolsProvider.isError ||
                  platformLanguagesProvider.isError
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildTitleInput(),
                          SizedBox(height: 20.0),
                          buildDescriptionInput(),
                          SizedBox(height: 10.0),
                          selectedSkillsList(),
                          SizedBox(height: 10.0),
                          selectedToolsList(),
                          SizedBox(height: 10.0),
                          selectedLanguageList(),
                          SizedBox(height: 20.0),
                          buildMobilityInput(),
                          SizedBox(height: 20),
                          buildSaveBtn()
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class AddUpdateOfferArguments {
  final Offer offer;
  final String type;
  AddUpdateOfferArguments(this.offer, this.type);
}

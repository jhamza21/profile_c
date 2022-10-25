import 'package:flutter/material.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/providers/cover_letter_provider.dart';
import 'package:profilecenter/providers/cv_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class PostulateToJobIntershipOffer extends StatefulWidget {
  static const routeName = '/postulateToJobIntershipOffer';

  final PostulateToJobIntershipOfferArguments arguments;
  PostulateToJobIntershipOffer(this.arguments);
  @override
  _PostulateToJobIntershipOfferState createState() =>
      _PostulateToJobIntershipOfferState();
}

class _PostulateToJobIntershipOfferState
    extends State<PostulateToJobIntershipOffer> {
  bool _isLoading = false;
  Document _selectedCv;
  Document _selectedCoverLetter;

  @override
  void initState() {
    super.initState();
    fetchCvs();
    fetchCoverLetters();
  }

  void fetchCoverLetters() async {
    CoverLetterProvider coverLetterProvider =
        Provider.of<CoverLetterProvider>(context, listen: false);
    coverLetterProvider.fetchDocuments(context);
  }

  void fetchCvs() async {
    CvProvider cvProvider = Provider.of<CvProvider>(context, listen: false);
    cvProvider.fetchDocuments(context);
  }

  Widget _showTitle(text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _showCvSelect(CvProvider cvProvider) {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: inputTextDecoration(
            10.0, null, getTranslate(context, "SELECT_CV"), null, null),
        isEmpty: _selectedCv == null,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Document>(
            value: _selectedCv,
            dropdownColor: BLUE_LIGHT,
            icon: Icon(
              Icons.arrow_drop_down_sharp,
              color: Colors.white,
            ),
            isExpanded: true,
            onChanged: (Document newValue) {
              setState(() {
                _selectedCv = newValue;
                state.didChange(newValue.title);
              });
            },
            items: cvProvider.documents.map((Document value) {
              return DropdownMenuItem<Document>(
                value: value,
                child: Text(
                  "${value.title}\n(${value.date.substring(0, 16).replaceAll("T", " ")})",
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _showCoverLetterSelect(CoverLetterProvider coverLetterProvider) {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: inputTextDecoration(10.0, null,
            getTranslate(context, "SELECT_COVER_LETTER"), null, null),
        isEmpty: _selectedCoverLetter == null,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Document>(
            value: _selectedCoverLetter,
            dropdownColor: BLUE_LIGHT,
            icon: Icon(
              Icons.arrow_drop_down_sharp,
              color: Colors.white,
            ),
            isExpanded: true,
            onChanged: (Document newValue) {
              setState(() {
                _selectedCoverLetter = newValue;
                state.didChange(newValue.title);
              });
            },
            items: coverLetterProvider.documents.map((Document value) {
              return DropdownMenuItem<Document>(
                value: value,
                child: Text(
                  "${value.title}\n(${value.date.substring(0, 16).replaceAll("T", " ")})",
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void sendCandidature() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<Document> _docs = [];
      _docs.add(_selectedCv);
      if (_selectedCoverLetter != null) _docs.add(_selectedCoverLetter);
      final res = await OfferService().postulate(
          widget.arguments.offer, widget.arguments.offer.companyRh.id, _docs);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      Navigator.of(context).pop();
      showSnackbar(context, getTranslate(context, "APPLICATION_SENT"));
      widget.arguments.onCallback();
      widget.arguments.offer.isAvailable = false;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  void sendCandidature1() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<Document> _docs = [];
      _docs.add(_selectedCv);
      if (_selectedCoverLetter != null) _docs.add(_selectedCoverLetter);
      final res = await OfferService().postulate1(
          widget.arguments.offer, widget.arguments.offer.companyRh.id, _docs);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      Navigator.of(context).pop();
      showSnackbar(context, getTranslate(context, "APPLICATION_SENT1"));
      widget.arguments.onCallback();
      widget.arguments.offer.isAvailable = false;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  _showPopupNoticeNoCoverLetter() {
    showBottomModal(
        context,
        null,
        getTranslate(context, "APPLICATION_WITHOUT_COVER_LETTER"),
        getTranslate(context, "YES"),
        () async {
          Navigator.of(context).pop();
          widget.arguments.offer.offerType == JOB_OFFER &&
                  widget.arguments.offer.typeOffre == true
              ? sendCandidature1()
              : sendCandidature();
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  Widget _showPostulateBtn() {
    return TextButton.icon(
        icon: _isLoading ? circularProgress : SizedBox.shrink(),
        label: Text(
          getTranslate(context, "APPLY"),
        ),
        onPressed: _selectedCv == null || _isLoading
            ? null
            : () {
                if (_selectedCoverLetter == null)
                  _showPopupNoticeNoCoverLetter();
                else
                  widget.arguments.offer.offerType == OFFRE_EXTERNE
                      ? sendCandidature1()
                      : sendCandidature();
              });
  }

  @override
  Widget build(BuildContext context) {
    CoverLetterProvider coverLetterProvider =
        Provider.of<CoverLetterProvider>(context, listen: true);
    CvProvider cvProvider = Provider.of<CvProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "APPLICATION")),
      ),
      body: coverLetterProvider.isLoading || cvProvider.isLoading
          ? Center(child: circularProgress)
          : coverLetterProvider.isError || cvProvider.isError
              ? ErrorScreen()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                              color: BLUE_SKY,
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            leading: widget.arguments.offer.offerType ==
                                    OFFRE_EXTERNE
                                ? CircleAvatar(
                                    backgroundColor: RED_LIGHT,
                                    child: Text(
                                      widget.arguments.offer.title[0]
                                          .toUpperCase(),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    minRadius: 20,
                                    maxRadius: 25,
                                  )
                                : getCompanyAvatar(
                                    null,
                                    widget.arguments.offer.company,
                                    BLUE_LIGHT,
                                    25),
                            title: Text(widget.arguments.offer.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text(
                              widget.arguments.offer.company.name,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        _showTitle("${getTranslate(context, "CV")} :"),
                        SizedBox(height: 5),
                        _showCvSelect(cvProvider),
                        SizedBox(height: 15),
                        _showTitle(
                            "${getTranslate(context, "COVER_LETTER")} :"),
                        SizedBox(height: 5),
                        _showCoverLetterSelect(coverLetterProvider),
                        SizedBox(height: 30),
                        _showPostulateBtn()
                      ],
                    ),
                  ),
                ),
    );
  }
}

class PostulateToJobIntershipOfferArguments {
  final Offer offer;
  final Function() onCallback;

  PostulateToJobIntershipOfferArguments(this.offer, this.onCallback);
}

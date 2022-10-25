import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/providers/intership_offers_provider.dart';
import 'package:profilecenter/providers/job_offers_provider.dart';
import 'package:profilecenter/providers/project_offers_provider.dart';
import 'package:profilecenter/core/services/offer_service.dart';
import 'package:profilecenter/modules/companyOffers/add_update_offer.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class OfferCard extends StatefulWidget {
  final Offer offer;
  final String type;
  OfferCard(this.offer, this.type);
  @override
  _OfferCardState createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool _isDeleting = false;
  bool _isChangingStatus = false;

  void _showDeleteDialog(Offer offer) {
    showBottomModal(
      context,
      null,
      getTranslate(context, "DELETE_OFFER_ALERT"),
      getTranslate(context, "YES"),
      () async {
        Navigator.of(context).pop();
        try {
          setState(() {
            _isDeleting = true;
          });
          var res = await OfferService().deleteJobOffre(widget.type, offer.id);
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          if (widget.type == JOB_OFFER) {
            JobOffersProvider jobOffersProvider =
                Provider.of<JobOffersProvider>(context, listen: false);
            jobOffersProvider.remove(offer);
          } else if (widget.type == PROJECT_OFFER) {
            ProjectOffersProvider projectOffersProvider =
                Provider.of<ProjectOffersProvider>(context, listen: false);
            projectOffersProvider.remove(offer);
          } else {
            IntershipOffersProvider intershipOffersProvider =
                Provider.of<IntershipOffersProvider>(context, listen: false);
            intershipOffersProvider.remove(offer);
          }
          setState(() {
            _isDeleting = false;
          });
          showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
        } catch (e) {
          setState(() {
            _isDeleting = false;
          });
          showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
        }
      },
      getTranslate(context, "NO"),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  void _toggleOfferStatus(Offer offer) async {
    try {
      setState(() {
        _isChangingStatus = true;
      });
      var res = await OfferService()
          .toggleOfferStatus(widget.type, offer.id, !offer.status);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      offer.status = !offer.status;
      setState(() {
        _isChangingStatus = false;
      });
      showSnackbar(context, getTranslate(context, "MODIFY_SUCCESS"));
    } catch (e) {
      setState(() {
        _isChangingStatus = false;
      });
      showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        tileColor: BLUE_LIGHT,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          widget.offer.title,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AddUpdateOffer.routeName,
                      arguments:
                          AddUpdateOfferArguments(widget.offer, widget.type));
                },
                icon: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: Image.asset(EDIT_ICON, color: GREY_LIGHt),
                )),
            IconButton(
                onPressed: () {
                  _showDeleteDialog(widget.offer);
                },
                icon: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: _isDeleting
                      ? circularProgress
                      : Image.asset(TRASH_ICON, color: RED_DARK),
                )),
            IconButton(
                onPressed: () {
                  _toggleOfferStatus(widget.offer);
                },
                icon: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: _isChangingStatus
                      ? circularProgress
                      : Image.asset(
                          widget.offer.status == false ? PLAY_ICON : PAUSE_ICON,
                          color: GREY_LIGHt),
                ))
          ],
        ),
      ),
    );
  }
}

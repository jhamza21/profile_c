import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/certificat.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/certificat_provider.dart';
import 'package:profilecenter/core/services/certificat_service.dart';
import 'package:profilecenter/modules/certificats/add_update_certificat.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class CertificationCard extends StatefulWidget {
  final Certificat certificat;
  final bool readOnly;
  CertificationCard({this.certificat, this.readOnly});
  @override
  _CertificationCardState createState() => _CertificationCardState();
}

class _CertificationCardState extends State<CertificationCard> {
  bool _isDeleting = false;

  void _showDeleteDialog() {
    showBottomModal(
      context,
      null,
      getTranslate(context, "DELETE_CERTIFICAT_ALERT"),
      getTranslate(context, "DELETE"),
      () async {
        try {
          Navigator.of(context).pop();
          setState(() {
            _isDeleting = true;
          });
          final res =
              await CertificatService().deleteCertificat(widget.certificat.id);
          if (res.statusCode == 401) return sessionExpired(context);
          if (res.statusCode != 200) throw "ERROR_SERVER";
          setState(() {
            _isDeleting = false;
          });
          CertificatProvider certificatProvider =
              Provider.of<CertificatProvider>(context, listen: false);
          certificatProvider.remove(widget.certificat);
          showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
        } catch (e) {
          setState(() {
            _isDeleting = false;
          });
          showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
        }
      },
      getTranslate(context, "CANCEL"),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  String getCertificatValidity(String validity) {
    String res;
    if (validity == null)
      res = getTranslate(context, "ALWAYS");
    else
      res = "$validity ${getTranslate(context, "YEAR")}";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ListTile(
          contentPadding:
              EdgeInsets.fromLTRB(8, 0, !widget.readOnly ? 0 : 8, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          tileColor: BLUE_LIGHT,
          leading: getCompanyAvatar(widget.certificat.companyName,
              widget.certificat.company, BLUE_LIGHT, 22),
          title: Text(
            widget.certificat.title,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Text(
            getTranslate(context, "DELIVERED_AT") + widget.certificat.delivered,
            style: TextStyle(color: GREY_LIGHt, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isDeleting
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: circularProgress,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslate(context, "VALIDITY") + " :",
                          style: TextStyle(
                              color: GREY_LIGHt,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          getCertificatValidity(widget.certificat.validity),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
              if (!widget.readOnly && !_isDeleting)
                Icon(
                  Icons.arrow_left,
                  color: RED_LIGHT,
                )
            ],
          ),
        ),
        secondaryActions: widget.readOnly || _isDeleting
            ? null
            : <Widget>[
                IconSlideAction(
                  caption: getTranslate(context, "UPDATE"),
                  color: BLUE_SKY,
                  icon: Icons.edit,
                  onTap: () => Navigator.of(context).pushNamed(
                      AddUpdateCertificat.routeName,
                      arguments: widget.certificat),
                ),
                IconSlideAction(
                  caption: getTranslate(context, "DELETE"),
                  color: RED_LIGHT,
                  icon: Icons.delete,
                  onTap: () => _showDeleteDialog(),
                ),
              ],
      ),
    );
  }
}

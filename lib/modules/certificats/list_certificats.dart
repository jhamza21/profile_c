import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/certificat_provider.dart';
import 'package:profilecenter/modules/certificats/add_update_certificat.dart';
import 'package:profilecenter/modules/certificats/certification_card.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:provider/provider.dart';

class ListCertificats extends StatefulWidget {
  @override
  _ListCertificatsState createState() => _ListCertificatsState();
}

class _ListCertificatsState extends State<ListCertificats> {
  @override
  Widget build(BuildContext context) {
    CertificatProvider certificatProvider =
        Provider.of<CertificatProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslate(context, "CERTIFICATS"),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AddUpdateCertificat.routeName),
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: RED_DARK,
                  size: 20,
                )),
          ],
        ),
        certificatProvider.certificats.length != 0
            ? ListView.builder(
                itemCount: certificatProvider.certificats.length,
                reverse: true,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return CertificationCard(
                    certificat: certificatProvider.certificats[index],
                    readOnly: false,
                  );
                })
            : EmptyDataCard(getTranslate(context, "NO_DATA")),
      ],
    );
  }
}

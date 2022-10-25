import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class AddListDevis extends StatefulWidget {
  static const routeName = '/addListDevis';

  @override
  State<AddListDevis> createState() => _AddListDevisState();
}

class _AddListDevisState extends State<AddListDevis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslate(context, 'LIST_FACTURE'),
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.normal,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {},
              tileColor: BLUE_LIGHT,
              title: Text(
                "Devis N : 120009",
                style: TextStyle(fontSize: 15, color: BLUE_SKY),
              ),
              subtitle: Row(
                children: [
                  Text('Pour l offre : ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                  Text('Project CIOK',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                ],
              ),
              trailing: Icon(
                Icons.file_download,
                color: Colors.white70,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {},
              tileColor: BLUE_LIGHT,
              title: Text(
                "Devis N : 120010",
                style: TextStyle(fontSize: 15, color: BLUE_SKY),
              ),
              subtitle: Row(
                children: [
                  Text('Pour l offre  : ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                  Text('Project fsms',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                ],
              ),
              trailing: Icon(
                 Icons.file_download,
                color: Colors.white70,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {},
              tileColor: BLUE_LIGHT,
              title: Text(
                "Devis N : 120011",
                style: TextStyle(fontSize: 15, color: BLUE_SKY),
              ),
              subtitle: Row(
                children: [
                  Text('Pour l offre  : ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                  Text('Project CIOK',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                ],
              ),
              trailing: Icon(
                 Icons.file_download,
                color: Colors.white70,
              ),
            ),
          ]),
        )));
  }
}

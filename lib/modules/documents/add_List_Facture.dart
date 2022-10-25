import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';

class AddListFacture extends StatefulWidget {
  static const routeName = '/addListFacture';

  @override
  State<AddListFacture> createState() => _AddListFactureState();
}

class _AddListFactureState extends State<AddListFacture> {
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
                "Facture N : 2345-6000011",
                style: TextStyle(fontSize: 15, color: BLUE_SKY),
              ),
              subtitle: Row(
                children: [
                  Text('Pour le Projet : ',
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
                "Facture N : 2345-6000012",
                style: TextStyle(fontSize: 15, color: BLUE_SKY),
              ),
              subtitle: Row(
                children: [
                  Text('Pour le Projet : ',
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
                "Facture N : 2345-6000013",
                style: TextStyle(fontSize: 15, color: BLUE_SKY),
              ),
              subtitle: Row(
                children: [
                  Text('Pour le Projet : ',
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

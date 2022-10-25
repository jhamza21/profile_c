import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_company_avatar.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';

class CompanyeProfile extends StatefulWidget {
  static const routeName = '/companyProfile';

  final int companyId;
  CompanyeProfile(this.companyId);
  @override
  _CompanyeProfileState createState() => _CompanyeProfileState();
}

class _CompanyeProfileState extends State<CompanyeProfile> {
  CameraPosition initialPosition;
  bool _isLoading = true;
  User _user;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    try {
      final res = await UserService().getCompanyProfile(widget.companyId);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      _user = User.fromJson(jsonData["user"]);
      initialPosition = CameraPosition(
          target: LatLng(_user.address.lat, _user.address.lon), zoom: 11.5);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _showTitle(text) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget companyLocationOnMap() {
    return Container(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialPosition,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          markers: {
            Marker(
              markerId: MarkerId("1"),
              position: LatLng(_user.address.lat, _user.address.lon),
              infoWindow: InfoWindow(title: _user.address.description),
            )
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "COMPANY_PROFILE")),
      ),
      body: _isLoading
          ? Center(child: circularProgress)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    getCompanyAvatar(null, _user.company, BLUE_DARK_LIGHT, 50),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "COMPANY_NAME")} :"),
                          SizedBox(height: 5),
                          Text(_user.company.name),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle("${getTranslate(context, "COUNTRY")} :"),
                          SizedBox(height: 5),
                          Text(_user.address.country),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "COMPANY_ADDRESS")} :"),
                          SizedBox(height: 5),
                          Text(_user.address.description),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "RH_RESPONSABLE")} :"),
                          SizedBox(height: 5),
                          Text('${_user.firstName} ${_user.lastName}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: BLUE_LIGHT,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _showTitle(
                              "${getTranslate(context, "COMPANY_LOCATION")} :"),
                          SizedBox(height: 10),
                          companyLocationOnMap()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/utils/ui/ui_utils.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/models/address.dart';
import 'package:profilecenter/models/place.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/core/services/google_maps_services.dart';
import 'package:profilecenter/core/services/user_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:provider/provider.dart';

class AddUpdateAddress extends StatefulWidget {
  static const routeName = '/addUpdateAddress';
  final Address address;
  AddUpdateAddress(this.address);
  @override
  _AddUpdateAddressState createState() => _AddUpdateAddressState();
}

class _AddUpdateAddressState extends State<AddUpdateAddress> {
  CameraPosition initialPosition =
      CameraPosition(target: LatLng(48.8785, 2.3642), zoom: 11.5);
  GoogleMapController _mapController;
  Address _selectedAddress;
  TextEditingController _typeAheadController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      initialPosition = CameraPosition(
          target: LatLng(widget.address.lat, widget.address.lon), zoom: 14);
      _typeAheadController.text = widget.address.description;
      _selectedAddress = widget.address;
    }
    getPermissions();
  }

  _getLocationDescription(LatLng latLng) async {
    try {
      final res = await GoogleMapsServices()
          .reverseGeocoding(latLng.latitude, latLng.longitude);
      Address address = Address.fromJsonGoogle(json.decode(res.body));
      address.lat = latLng.latitude;
      address.lon = latLng.longitude;
      setAddress(address);
    } catch (e) {}
  }

  void getPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void locateMyPosition() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Position _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng latLng =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      var res = await GoogleMapsServices()
          .reverseGeocoding(latLng.latitude, latLng.longitude);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      Address address = Address.fromJsonGoogle(jsonData["results"][0]);
      address.lat = latLng.latitude;
      address.lon = latLng.longitude;
      setAddress(address);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void setAddress(Address address) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(address.lat, address.lon), zoom: 14)));
    _typeAheadController.text = address.description;
    setState(() {
      _selectedAddress = address;
      _isLoading = false;
    });
  }

  Widget searchLocationBar() {
    return TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
            controller: _typeAheadController,
            style: TextStyle(color: Colors.white),
            decoration: inputTextDecoration(
              10.0,
              Icon(Icons.search),
              getTranslate(context, "SEARCH_HERE"),
              null,
              GestureDetector(
                child: Icon(Icons.cancel),
                onTap: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _selectedAddress = null;
                        });
                        _typeAheadController.text = '';
                      },
              ),
            )),
        suggestionsCallback: GoogleMapsServices().getSuggetions,
        debounceDuration: Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: true,
        noItemsFoundBuilder: (value) {
          return Container(
            height: 50,
            child: Center(
              child: Text(
                getTranslate(context, "NO_DATA"),
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        },
        itemBuilder: (context, Place place) {
          return ListTile(
            title: Text(
              place.description,
            ),
          );
        },
        onSuggestionSelected: (Place place) async {
          try {
            setState(() {
              _isLoading = true;
            });
            var res = await GoogleMapsServices().getPlaceDetails(place.placeId);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            final jsonData = json.decode(res.body);
            setAddress(Address.fromJsonGoogle(jsonData["result"]));
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  Widget map() {
    return Stack(
      children: [
        Container(
          height: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: initialPosition,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              markers: _selectedAddress != null
                  ? {
                      Marker(
                        markerId: MarkerId("1"),
                        position:
                            LatLng(_selectedAddress.lat, _selectedAddress.lon),
                        infoWindow:
                            InfoWindow(title: _selectedAddress.description),
                      )
                    }
                  : {},
              onTap: _getLocationDescription,
              onMapCreated: (GoogleMapController _controller) {
                _mapController = _controller;
                if (widget.address == null) locateMyPosition();
              },
            ),
          ),
        ),
        _isLoading
            ? Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(child: circularProgress),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget buildSaveBtn(UserProvider userProvider) {
    return TextButton.icon(
        icon: _isSaving ? circularProgress : SizedBox(),
        label: Text(
          getTranslate(context, 'SAVE'),
        ),
        onPressed: _isSaving || _selectedAddress == null
            ? null
            : () async {
                try {
                  setState(() {
                    _isSaving = true;
                  });
                  var res;
                  if (widget.address != null)
                    res = await UserService()
                        .updateUserAddress(widget.address.id, _selectedAddress);
                  else
                    res = await UserService().addUserAddress(_selectedAddress);
                  if (res.statusCode == 401) return sessionExpired(context);
                  if (res.statusCode != 200) throw "ERROR_SERVER";
                  final jsonData = json.decode(res.body);
                  userProvider.setAddress(Address.fromJson(jsonData["data"]));
                  Navigator.of(context).pop();
                  showSnackbar(
                      context, getTranslate(context, "PROFILE_UPDATE_SUCCESS"));
                } catch (e) {
                  setState(() {
                    _isSaving = false;
                  });
                  showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
                }
              });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslate(context, "ADDRESS"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              searchLocationBar(),
              SizedBox(height: 30.0),
              map(),
              SizedBox(height: 60.0),
              buildSaveBtn(userProvider),
            ],
          ),
        ),
      ),
    );
  }
}

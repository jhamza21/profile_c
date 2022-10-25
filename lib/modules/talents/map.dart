import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/address.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/modules/profile/candidat_profile.dart';

class Map extends StatefulWidget {
  final Address address;
  final int diameterForSearch;
  final List<User> talents;
  Map(this.address, this.diameterForSearch, this.talents);
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  CameraPosition initialPosition;
  GoogleMapController mapController;
  BitmapDescriptor offerMarker;
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};

  void initializeData() {
    _circles = {};
    _markers = {};
    if (widget.address != null) {
      //center on user address
      initialPosition = CameraPosition(
          target: LatLng(widget.address.lat, widget.address.lon), zoom: 10);
    } else if (widget.talents.length != 0 &&
        widget.talents[0].address != null) {
      //center on first talent
      initialPosition = CameraPosition(
          target: LatLng(
              widget.talents[0].address.lat, widget.talents[0].address.lon),
          zoom: 10);
    } else {
      //center on ariana
      initialPosition =
          CameraPosition(target: LatLng(36.862499, 10.195556), zoom: 10);
    }

    //add marker to user address
    if (widget.address != null)
      _markers.add(Marker(
          markerId: MarkerId("myPosition"),
          infoWindow: InfoWindow(
            title: "MOI",
          ),
          position: LatLng(widget.address.lat, widget.address.lon)));
    //add circle with diameter choosen by user to filter offers
    if (widget.diameterForSearch != null) {
      _circles.add(Circle(
          circleId: CircleId("0"),
          center: LatLng(widget.address.lat, widget.address.lon),
          radius: 1000 * widget.diameterForSearch.toDouble(),
          strokeColor: RED_DARK,
          fillColor: Color(0x80ffdcd8),
          strokeWidth: 1));
    }
    //add talents positions to map
    for (int i = 0; i < widget.talents.length; i++) {
      User _talent = widget.talents[i];
      if (_talent.address != null)
        _markers.add(Marker(
            markerId: MarkerId("$i"),
            position: LatLng(_talent.address.lat, _talent.address.lon),
            infoWindow: InfoWindow(
              title: _talent.firstName + " " + _talent.lastName,
              snippet: _talent.experiences.length != 0
                  ? _talent.experiences.last.title
                  : null,
              onTap: () => Navigator.of(context)
                  .pushNamed(CandidatProfile.routeName, arguments: _talent.id),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)));
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    initializeData();
  }

  // void setCustomMarker() async {
  //   offerMarker = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(size: Size(10, 10)),
  //       USER_MARKER_ICON);
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GoogleMap(
              gestureRecognizers: Set()
                ..add(Factory<PanGestureRecognizer>(
                    () => PanGestureRecognizer())),
              onMapCreated: (GoogleMapController _controller) {
                mapController = _controller;
              },
              mapType: MapType.normal,
              initialCameraPosition: initialPosition,
              circles: _circles,
              markers: _markers,
            ),
          ),
        ),
      ],
    );
  }
}

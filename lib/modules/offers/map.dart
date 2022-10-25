import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/address.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/modules/offers/offer_details.dart';

class Map extends StatefulWidget {
  final Address address;
  final int diameterForSearch;
  final List<Offer> offers;
  Map(this.address, this.diameterForSearch, this.offers);
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
    } else if (widget.offers.length != 0 &&
        widget.offers[0].companyRh.address != null) {
      //center on first offer
      initialPosition = CameraPosition(
          target: LatLng(widget.offers[0].companyRh.address.lat,
              widget.offers[0].companyRh.address.lon),
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
    //add offers positions to map
    for (int i = 0; i < widget.offers.length; i++) {
      Offer _offer = widget.offers[i];
      if (_offer.companyRh.address != null)
        _markers.add(Marker(
            markerId: MarkerId("$i"),
            position: LatLng(
                _offer.companyRh.address.lat, _offer.companyRh.address.lon),
            infoWindow: InfoWindow(
                title: _offer.title,
                snippet: _offer.company.name,
                onTap: () =>
                    Navigator.pushNamed(context, OfferDetails.routeName,
                        arguments: OfferDetailsArguments(_offer, () {
                          setState(() {
                            _offer.isAvailable = false;
                          });
                        }))),
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

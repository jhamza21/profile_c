import 'dart:convert';

import 'package:profilecenter/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:profilecenter/models/place.dart';

class GoogleMapsServices {
  Future<List<Place>> getSuggetions(String text) async {
    try {
      var url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" +
              text +
              "&key=" +
              GOOGLE_MAPS_API_KEY;
      //&components=country:us
      var res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw "ERROR_SERVER";
      return Place.listFromJson(json.decode(res.body)["predictions"]);
    } catch (e) {
      return [];
    }
  }

  Future<http.Response> getPlaceDetails(String placeId) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=" +
            placeId +
            "&key=" +
            GOOGLE_MAPS_API_KEY;
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> reverseGeocoding(double lat, double lon) async {
    var url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=" +
            GOOGLE_MAPS_API_KEY;
    return await http.get(Uri.parse(url));
  }
}

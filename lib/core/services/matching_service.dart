import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class MatchingService {
  Future<http.Response> getOffersSuggestions(
      List<String> offerTypes, List<String> tags) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/calculate/entreprise";
    bool _isStart = true;
    offerTypes.forEach((type) {
      _isStart
          ? url += "?offers_types[]=$type"
          : url += "&offers_types[]=$type";
      if (_isStart) _isStart = !_isStart;
    });
    tags.forEach((tag) {
      url += "&tags[]=$tag";
    });
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> getCandidatSuggestions(
      List<String> roles, List<String> tags) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/calculate/candidat";
    bool _isStart = true;
    roles.forEach((role) {
      _isStart ? url += "?roles[]=$role" : url += "&roles[]=$role";
      if (_isStart) _isStart = !_isStart;
    });
    tags.forEach((tag) {
      url += "&tags[]=$tag";
    });
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class ActivityService {
  Future<http.Response> getActivity() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/activity";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> getCandidatStatistic() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/stat";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> getCompanyStatistic(int companyId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/entreprise/stat?entreprise_id=$companyId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> getUserCompanyStatistic(int companyId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/entreprise/stat?entreprise_id=$companyId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> addComparaison(int userid) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/comparaison/add/$userid";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }
}

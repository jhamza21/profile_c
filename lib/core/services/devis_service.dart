import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class DevisService {
  //get platform available devise
  Future<http.Response> getDevis() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/devis";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }
}

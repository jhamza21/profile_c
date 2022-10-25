import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'dart:convert';
import 'package:profilecenter/models/address.dart';
import 'package:profilecenter/models/user.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class UserService {
//add user address
  Future<http.Response> addUserAddress(Address address) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/adress/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "region": address.region,
          "country": address.country,
          "description": address.description,
          "latitude": address.lat,
          "longtitude": address.lon
        }));
  }

//update user address
  Future<http.Response> updateUserAddress(int id, Address address) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/adress/edit";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "adress_id": id,
          "region": address.region,
          "country": address.country,
          "description": address.description,
          "latitude": address.lat,
          "longtitude": address.lon
        }));
  }

//update user account password
  Future<http.Response> updatePassword(
      int id, String oldPassword, String newPassword) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "old_password": oldPassword,
          "password": newPassword,
          "password_confirmation": newPassword,
        }));
  }

  //update user email
  Future<http.Response> updateEmail(int id, String email) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"email": email}));
  }

//update user first name and last name
  Future<http.Response> updateUserName(
      int id, String firstName, String lastName) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"first_name": firstName, "last_name": lastName}));
  }

  Future<http.Response> updateSalary(int id, double salary) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"salary": salary}));
  }

  Future<http.Response> updateDisponibility(int id, int dispo) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"disponibilite": dispo}));
  }

  Future<http.Response> updateMobility(int id, String mobility) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"mobilite": mobility}));
  }

//update user birthday
  Future<http.Response> updateBirthday(int id, String birthday) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"birth_date": birthday}));
  }

  //update user residency permit
  Future<http.Response> updateResidencyPermit(
      int id, String residencyPermit) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"permis": residencyPermit}));
  }

  //update user return to job date
  Future<http.Response> updateReturntoJobDate(int id, String returnDate) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"date_retour": returnDate}));
  }

  //update user is diponible
  Future<http.Response> updateUserIsDisponible(
      int id, bool isDisponible) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"is_dispo": isDisponible ? 1 : 0}));
  }

  //update user stripe id
  Future<http.Response> setUserStripeId(int id, String stripeId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"stripe_id": stripeId}));
  }

  //update user mobile
  Future<http.Response> updateMobile(int id, String mobile) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"phone_number": mobile}));
  }

//update user image
  Future<http.StreamedResponse> updatePhoto(int id, File img) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath('pro_picture', img.path));

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
    return request.send();
  }

  Future<List<User>> getSuggetions(String text) async {
    try {
      String token = await SecureStorageService.readToken();
      if (text != "") {
        var url = URL_BACKEND + "api/user/suggestion?text=" + text;
        var res = await http.get(
          Uri.parse(url),
          headers: {
            "content-type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        if (res.statusCode != 200) throw "ERROR_SERVER";
        return User.listFromJson(json.decode(res.body)["users"]);
      } else
        return [];
    } catch (e) {
      return [];
    }
  }

  //toggle notif
  Future<http.Response> toggleNotif() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/notification";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get candidat profile
  Future<http.Response> getCandidatProfile(int userId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/candidat/profile/$userId";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get company profile
  Future<http.Response> getCompanyProfile(int companyId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/entreprise/profile/$companyId";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get favorite candidat
  Future<http.Response> getFavoriteCandidat() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/favorite";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get user note
  Future<http.Response> getUserNote(int userId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/note/$userId";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get user turnover
  Future<http.Response> getUserTurnover() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/chiffreAffaire";
    return await http.get(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //add or delete candidat to favorite
  Future<http.Response> addDeleteCandidatToFavorite(int userId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/user/favorite/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"user_id": userId}));
  }

  //set user firebase token
  Future<http.Response> setFirebaseToken(int id, String fcmToken) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/edit/profile/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "fcm_token": fcmToken,
        }));
  }
//post mail help
/*  Future <http.Response> sendMail(String email, String subject , String message , File file) async {
  var url = URL_BACKEND + "api/mail/send";
   return await http.post (Uri.parse(url), 
      headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "email": email,
          "subject": subject,
          "message": message,
          "file": file,

        }));
 } */

  //otp

}

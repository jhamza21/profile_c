import 'package:profilecenter/models/address.dart';
import 'package:profilecenter/models/certificat.dart';
import 'package:profilecenter/models/company.dart';
import 'package:profilecenter/models/devise.dart';
import 'package:profilecenter/models/experience.dart';
import 'package:profilecenter/models/pack.dart';
import 'package:profilecenter/models/qcm_certification.dart';
import 'package:profilecenter/models/skill.dart';

class User {
  final int id;
  String firstName;
  String lastName;
  String civility;
  String email;
  String role;
  String code;

  Address address;
  String mobile;
  String birthday;
  String image;
  bool notification;
  List<QcmCertification> qcmCertifications;
  Company company;
  double salary;
  String mobility;
  int disponibility;
  bool isDisponible;
  String returnToJobDate;
  String residencyPermit;
  //note=> note matching
  final double note;
  final double distance;
  final String createdAt;
  Devise devise;
  Pack pack;
  String stripeId;
  //stars given to freelancer by companies
  int stars;
  List<Skill> skills;
  List<Experience> experiences;
  List<Certificat> certificats;
  String fcmToken;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['first_name'] ?? '',
        lastName = json['last_name'] ?? '',
        civility = json['civility'] ?? '',
        email = json['email'] ?? '',
        code = json['code'] ?? '',
        role = json['roles'] != null ? json['roles'][0]['name'] : '',
        address = json['adress'] != null && json['adress'].length != 0
            ? Address.fromJson(json['adress'][0])
            : null,
        mobile = json['phone_number'] ?? '',
        birthday = json['birth_date'] ?? '',
        notification = json['notification'] == 1 ? true : false,
        qcmCertifications =
            QcmCertification.listFromJson(json['certifications']),
        company = json['entreprise'] != null
            ? Company.fromJson(json['entreprise'])
            : null,
        salary = json['salary'] != null ? json['salary'].toDouble() : null,
        mobility = json['mobilite'] ?? "indifferent",
        disponibility = json['disponibilite'] ?? 5,
        isDisponible = json['is_dispo'] == 1 ? true : false,
        returnToJobDate = json['date_retour'] != null
            ? json['date_retour'].substring(0, 10)
            : null,
        residencyPermit = json['permis'] ?? null,
        certificats = Certificat.listFromJson(json["normal_certification"]),
        experiences = Experience.listFromJson(json["experiences"]),
        skills = Skill.listFromJson(json["skills"]),
        distance = json['eloignement'] ?? null,
        note = json['sum'] != null ? json['sum'].toDouble() : null,
        createdAt = json['created_at'] ?? null,
        devise =
            json['devise'] != null ? Devise.fromJson(json['devise']) : null,
        pack = json['package'] != null
            ? Pack.fromJson(json['package'], json['created_at'] ?? null)
            : null,
        stripeId = json['stripe_id'] ?? null,
        image = json['pro_picture'] ?? '',
        fcmToken = json['fcm_token'] ?? null;

  static List<User> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => User.fromJson(value)).toList();
  }
}

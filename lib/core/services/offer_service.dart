import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/devis.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/models/invoice.dart';
import 'package:profilecenter/models/offer.dart';
import 'package:profilecenter/models/skill.dart';
import 'package:profilecenter/modules/companyOffers/language_model.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';

class OfferService {
  //get job offers
  Future<http.Response> getJobOffers() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/offre";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get intership offers
  Future<http.Response> getIntershipOffers() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/stage";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get project offers
  Future<http.Response> getProjectOffers() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/project";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> getExterneOffers() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/offre_externe";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get languages
  Future<http.Response> getLanguages() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/language";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get tools
  Future<http.Response> getTools() async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/outil";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

//add offer
  Future<http.Response> addOffer(
    String type,
    String title,
    String description,
    List<Skill> skills,
    List<Skill> tools,
    List<Language> languages,
    String mobility,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND;
    if (type == JOB_OFFER)
      url += "api/offre/create";
    else if (type == PROJECT_OFFER)
      url += "api/project/create";
    else
      url += "api/stage/create";

    List<int> competenceId = [];
    skills.forEach((element) {
      competenceId.add(element.id);
    });

    tools.forEach((element) {
      competenceId.add(element.id);
    });

    List<int> languageId = [];
    List<String> languageLevelNames = [];
    languages.forEach((element) {
      languageId.add(element.id);
      languageLevelNames.add(element.selectedLevel);
    });

    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": title,
          "description": description,
          "mobilite": mobility,
          "competence_id": competenceId,
          "language_id": languageId,
          "level_name": languageLevelNames
        }));
  }

  //update offer
  Future<http.Response> updateOffer(
    String type,
    int id,
    String title,
    String description,
    bool status,
    List<Skill> skills,
    List<Skill> tools,
    List<Language> languages,
    String mobility,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND;
    if (type == JOB_OFFER)
      url += "api/offre/edit/$id";
    else if (type == PROJECT_OFFER)
      url += "api/project/edit/$id";
    else
      url += "stage/edit/$id";
    List<int> competenceId = [];
    skills.forEach((element) {
      competenceId.add(element.id);
    });

    tools.forEach((element) {
      competenceId.add(element.id);
    });

    List<int> languageId = [];
    List<String> languageLevelNames = [];
    languages.forEach((element) {
      languageId.add(element.id);
      languageLevelNames.add(element.selectedLevel);
    });

    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "title": title,
          "description": description,
          "mobilite": mobility,
          "status": status ? 1 : 0,
          "competence_id": competenceId,
          "language_id": languageId,
          "level_name": languageLevelNames
        }));
  }

  //change offer status
  Future<http.Response> toggleOfferStatus(
      String type, int id, bool value) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND;
    if (type == JOB_OFFER)
      url += "api/offre/edit/$id";
    else if (type == PROJECT_OFFER)
      url += "api/project/edit/$id";
    else
      url += "api/stage/edit/$id";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"status": value ? 1 : 0}));
  }

//delete offer
  Future<http.Response> deleteJobOffre(String type, int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND;
    if (type == JOB_OFFER)
      url += "api/offre/delete/$id";
    else if (type == PROJECT_OFFER)
      url += "api/project/delete/$id";
    else
      url += "api/stage/delete/$id";
    return await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.Response> postulate(
      Offer offer, int receiverId, List<Document> documents) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/postulate";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "offre_id": offer.offerType == JOB_OFFER ? offer.id : null,
          "stage_id": offer.offerType == INTERSHIP_OFFER ? offer.id : null,
          "receiver_id": receiverId,
          "types": documents.map((e) => e.type).toList(),
          "documents": documents.map((e) => e.id).toList()
        }));
  }

//offre externe
  Future<http.Response> postulate1(
      Offer offer, int receiverId, List<Document> documents) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/offre_externe/send";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "offre_id": offer.offerType == OFFRE_EXTERNE ? offer.id : null,
          "receiver_id": receiverId,
          "types": documents.map((e) => e.type).toList(),
          "documents": documents.map((e) => e.id).toList(),
        }));
  }

  Future<http.Response> sendProjectProposal(int offerId, int receiverId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/project/proposal";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "project_id": offerId,
          "receiver_id": receiverId,
        }));
  }

  Future<http.Response> refuseProjectProposal(int proposalId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/project/proposal/$proposalId/refuse";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.Response> acceptProjectProposal(int proposalId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/project/proposal/$proposalId/accept";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //get devis data
  Future<http.Response> getDevisData(int projectId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/devisNumber?project_id=$projectId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  Future<http.StreamedResponse> sendDevis(
      String devisNumber,
      List<int> devisDocBytes,
      int offerId,
      double tva,
      String jobDescription,
      String emissionDate,
      String startDate,
      String endDate,
      double tjm,
      double commisionPc,
      int projectPeriod,
      int meetingDays,
      int teleworkDays,
      int workDaysPerMonth,
      bool forfaitType,
      int propositionId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/project_proposal/$propositionId/accept";

    var request = new http.MultipartRequest("POST", Uri.parse(url));

    request.files.add(http.MultipartFile.fromBytes('devis_doc', devisDocBytes,
        filename: "Devis-$devisNumber.pdf"));
    request.fields["project_id"] = offerId.toString();
    request.fields["devis_number"] = devisNumber;

    request.fields["description"] = jobDescription;
    request.fields["date_emission"] = emissionDate;
    request.fields["debut_mission"] = startDate;
    request.fields["fin_mission"] = endDate;
    request.fields["tjm"] = tjm.toString();
    request.fields["tva"] = tva.toString();
    request.fields["commission_pc"] = commisionPc.toString();
    request.fields["project_period"] = projectPeriod.toString();
    request.fields["reunion_hebdomadaire"] = meetingDays.toString();
    request.fields["nbre_jrs_teletravail"] = teleworkDays.toString();
    request.fields["nb_jrs_travail"] = workDaysPerMonth.toString();
    request.fields["mission_forfait"] = forfaitType ? "1" : "0";
    // all devis are generated with euro => id=1
    request.fields["devise_id"] = "1";

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    });
    return await request.send();
  }

//get devis
  Future<http.Response> getDevis(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/devis/$id";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //refuse proposition
  Future<http.Response> refuseDevis(
    int devisRequestId,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/devis_request/$devisRequestId/refuse";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //accept proposition
  Future<http.StreamedResponse> acceptDevis(
    Devis devis,
    int devisRequestId,
    List<int> devisDocBytes,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/devis_request/$devisRequestId/accept";
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('devis_doc', devisDocBytes,
        filename: "Devis-${devis.devisNumber}.pdf"));

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    });
    return await request.send();
  }

  //negociate proposition
  Future<http.Response> negociateDevis(int devisRequestId, String msg) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/devis_request/$devisRequestId/negocier";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"msg": msg}));
  }

  //get supplies(approvisionnements)
  Future<http.Response> getSupplies(int devisId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/approvisionnement?devis_id=$devisId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //create supply
  Future<http.Response> addSupply(
    int devisId,
    double amount,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/approvisionnement/create";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "devis_id": devisId,
          "amount": amount,
        }));
  }

  Future<http.Response> refusePayProposal(int proposalId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/pay/proposal/$proposalId/refuse";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.StreamedResponse> acceptPayProposal(
      int proposalId,
      String invoiceNumber,
      String emissionDate,
      int nbDays,
      List<int> invoiceDocData) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/pay/proposal/$proposalId/accept";
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes(
        'invoice_doc', invoiceDocData,
        filename: "Facture-$invoiceNumber.pdf"));
    request.fields["invoice_number"] = invoiceNumber;
    request.fields["invoice_number"] = invoiceNumber;
    request.fields["nb_jours"] = nbDays.toString();
    request.fields["date_emission"] = emissionDate;
    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    });
    return await request.send();
  }

  //get invoice data
  Future<http.Response> getInvoiceData(int devisId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/invoiceNumber?devis_id=$devisId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //get devis
  Future<http.Response> getInvoice(int id) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/invoice/$id";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //refuse proposition
  Future<http.Response> refusePayRequest(
    int payRequestId,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/pay_request/$payRequestId/refuse";
    return await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  //accept proposition
  Future<http.StreamedResponse> acceptPayRequest(
    Invoice invoice,
    int payRequestId,
    List<int> devisDocBytes,
  ) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/pay_request/$payRequestId/accept";
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes('invoice_doc', devisDocBytes,
        filename: "Facture-${invoice.invoiceNumber}.pdf"));

    request.headers.addAll({
      "content-type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    });
    return await request.send();
  }

  //negociate proposition
  Future<http.Response> negociatePayRequest(
      int payRequestId, String msg) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/pay_request/$payRequestId/negocier";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"msg": msg}));
  }

  //get already payments of freelancer
  Future<http.Response> getPayments(int devisId) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/payment?devis_id=$devisId";
    return await http.get(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });
  }

  //negociate proposition
  Future<http.Response> cloturerProject(
      int requestId, int note, String comment) async {
    String token = await SecureStorageService.readToken();
    var url = URL_BACKEND + "api/chat/raiting_request/$requestId";
    return await http.post(Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"comment": comment, "note": note}));
  }
}

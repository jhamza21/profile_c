class InvoiceInfo {
  final String userImage;
  final String userFullName;
  final String userAddress;
  final String userEmail;
  final String companyName;
  final String companyAddress;
  final String invoiceNumber;
  final String projectName;
  final String projectDescription;
  final double tjm;
  final String capital;
  final String sas;
  final String siret;
  final String rcs;
  final String naf;
  final String numberTva;
  final double tva;
  final double commissionPc;

  InvoiceInfo.fromJson(Map<String, dynamic> jsonData)
      : userImage = jsonData["user_image"] ?? null,
        userFullName = jsonData["user_full_name"],
        userAddress = jsonData["user_adress"],
        userEmail = jsonData["user_email"],
        companyName = jsonData["company_name"],
        companyAddress = jsonData["company_adress"],
        invoiceNumber = jsonData["devis_number"].toString(),
        projectName = jsonData["project_name"],
        projectDescription = jsonData["project_description"],
        tjm = jsonData["tjm"] != null ? jsonData["tjm"].toDouble() : null,
        capital = jsonData["mention_legale_data"]["capital"].toString(),
        sas = jsonData["entreprise_data"]["sas"],
        siret = jsonData["mention_legale_data"]["siret"].toString(),
        rcs = jsonData["mention_legale_data"]["rcs"],
        naf = jsonData["mention_legale_data"]["naf"],
        numberTva = jsonData["mention_legale_data"]["numero_tva"],
        tva = jsonData["mention_legale_data"] != null
            ? jsonData["mention_legale_data"]["taxe"].toDouble()
            : null,
        commissionPc = jsonData["comission_pc"] != null
            ? jsonData["comission_pc"].toDouble()
            : null;
}

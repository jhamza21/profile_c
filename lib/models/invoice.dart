import 'package:flutter/material.dart';

class Invoice {
  final int id;
  final String invoiceNumber;
  final int nbDays;
  final int invoiceDocId;
  final int devisId;
  bool status;

  Invoice({
    @required this.id,
    @required this.invoiceNumber,
    @required this.nbDays,
    @required this.invoiceDocId,
    @required this.devisId,
    @required this.status,
  });

  Invoice.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        invoiceNumber = json['invoice_number'] ?? '',
        nbDays = json['nb_jours'] ?? null,
        invoiceDocId = json['doc_id'] ?? null,
        devisId = json['devis_id'] ?? null,
        status = json['status'] == 0 ? false : true;

  static List<Invoice> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Invoice.fromJson(value)).toList();
  }
}

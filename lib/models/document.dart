import 'dart:io';

class Document {
  int id;
  String title;
  File file;
  double size;
  final String date;
  String type;
  bool isPrimary;

  Document(
      this.id, this.title, this.file, this.date, this.isPrimary, this.type);

  Document.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['file'],
        size = json['size'].toDouble(),
        date = json['created_at'],
        type = json['type'],
        isPrimary = json['primary'] == 0 ? false : true,
        file = null;
  static List<Document> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Document.fromJson(value)).toList();
  }
}

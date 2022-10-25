import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/invoiceInfo.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<List<int>> generateDevis(
      ByteData imageSignature,
      InvoiceInfo invoiceinfo,
      String emissionDate,
      String jobDescription,
      double tjm,
      int projectPeriod,
      int nbWorkDaysPerMonth,
      int nbMeetingPerDay,
      int nbDaysTelework,
      String startDate) async {
    double prixMission = nbWorkDaysPerMonth * projectPeriod * tjm;
    double prixTva = (prixMission / 100) * invoiceinfo.tva;
    double prixCommisionPc = (prixMission / 100) * invoiceinfo.commissionPc;

    final document = PdfDocument();
    final page = document.pages.add();
    final pageSize = page.getClientSize();
    final graphics = page.graphics;
    //Read font data.
    final fontData = await rootBundle.load("assets/fonts/abhaya.ttf");
//Create a PDF true type font object.
    final PdfFont font = PdfTrueTypeFont(fontData.buffer.asUint8List(), 10);
    final PdfFont fontSmall = PdfTrueTypeFont(fontData.buffer.asUint8List(), 6);

    //draw freelance name
    graphics.drawString(
        '''${invoiceinfo.userFullName}\n${invoiceinfo.userAddress}\n @:${invoiceinfo.userEmail}''',
        font,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds: Rect.fromLTWH(0, 85, 100, 0));
    graphics.drawString(
        '''A l'attention de :\n${invoiceinfo.companyName}\n${invoiceinfo.companyAddress}''',
        font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(pageSize.width - 110, 30, 110, 0));

    //draw devis number
    graphics.drawString('''Devis N : ${invoiceinfo.invoiceNumber}''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 200, 0, 0));
    //draw project name
    graphics.drawString('''${invoiceinfo.projectName}''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 210, 0, 0));
    //draw date émission
    graphics.drawString('''Date d'émission : $emissionDate''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 220, 0, 0));
    //draw validity
    graphics.drawString(
        '''Période de validité : ${projectPeriod * nbWorkDaysPerMonth} jours''',
        font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 230, 0, 0));

    //draw grid
    final grid = PdfGrid();
    grid.style.font = font;
    grid.columns.add(count: 5);
    grid.columns[0].width = 220;
    final headerRow = grid.headers.add(1)[0];
    headerRow.style.backgroundBrush = PdfBrushes.violet;
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = "Désignation";
    headerRow.cells[1].value = "Quantité";
    headerRow.cells[2].value = "Prix unitaire";
    headerRow.cells[3].value = "TVA";
    headerRow.cells[4].value = "Montant HT";
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    for (int i = 0; i < headerRow.cells.count; i++)
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    final row = grid.rows.add();
    row.cells[0].value = "$jobDescription";
    row.cells[1].value = "${nbWorkDaysPerMonth * projectPeriod}";
    row.cells[2].value = "$tjm€";
    row.cells[3].value = "${invoiceinfo.tva}%";
    row.cells[4].value = "$prixMission€";

    final row2 = grid.rows.add();
    row2.cells[0].value = "Durée de projet (en mois) : $projectPeriod mois";
    final row3 = grid.rows.add();
    row3.cells[0].value = "Jours de travail :  $nbWorkDaysPerMonth jours/mois";
    final row4 = grid.rows.add();
    row4.cells[0].value =
        "Réunion hebdomadaires: $nbMeetingPerDay fois/semaine";
    final row5 = grid.rows.add();
    row5.cells[0].value =
        "Nombre de jours totals : ${projectPeriod * nbWorkDaysPerMonth} jours";
    final row6 = grid.rows.add();
    row6.cells[0].value = "Télétravail : $nbDaysTelework jours/semaine";
    final row7 = grid.rows.add();
    row7.cells[0].value = "Démarrage de la mission le : $startDate";

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable1LightAccent3);

    grid.draw(page: page, bounds: Rect.fromLTWH(0, 270, 0, 0));

    //draw total
    graphics.drawString('''Total HT''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 500, 0, 0));
    //draw total
    graphics.drawString('''$prixMission€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 500, 0, 0));
    //draw total
    graphics.drawString('''Commission PC ${invoiceinfo.commissionPc}%''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 510, 0, 0));
    //draw total
    graphics.drawString('''$prixCommisionPc€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 510, 0, 0));
    graphics.drawString('''TVA ${invoiceinfo.tva}%''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 520, 0, 0));
    graphics.drawString('''$prixTva€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 520, 0, 0));
    graphics.drawString('''Total TTC''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 530, 0, 0));
    graphics.drawString('''${prixMission + prixTva + prixCommisionPc}€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 530, 0, 0));

    //draw notice
    graphics.drawString(
        '''Pour être accepté, le devis doit être daté, signé et suivi de la mention manuscrite "bon pour accord"''',
        font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 570, 0, 0));

//draw signature
    graphics.drawString(
        '''Signature''', PdfStandardFont(PdfFontFamily.helvetica, 8),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds: Rect.fromLTWH(pageSize.width - 120, 620, 0, 0));

    final PdfBitmap image = PdfBitmap(imageSignature.buffer.asUint8List());
    graphics.drawImage(
        image, Rect.fromLTWH(pageSize.width - 180, 640, 100, 40));
    //draw footer
    graphics.drawString(
        '''${invoiceinfo.sas} au capital de ${invoiceinfo.capital}\nSIRET ${invoiceinfo.siret} - RCS ${invoiceinfo.rcs} - NAF ${invoiceinfo.naf}\n TVA intracommunautaire : ${invoiceinfo.numberTva}\nPage 1/1''',
        fontSmall,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds:
            Rect.fromLTWH(pageSize.width - 250, pageSize.height - 20, 0, 0));

// //Create signature field.
//     final certificat = await rootBundle.load("assets/key/certificat.pfx");
// //Create a PDF true type font object.
//     PdfSignatureField signatureField = PdfSignatureField(page, 'Signature',
//         highlightMode: PdfHighlightMode.outline,
//         bounds: Rect.fromLTWH(20, 0, 50, 50),
//         signature: PdfSignature(
//             certificate:
//                 PdfCertificate(certificat.buffer.asUint8List(), 'Hamza1**')));
// //Add the signature field to the document.
//     document.form.fields.add(signatureField);

    //draw freelance image
    if (invoiceinfo.userImage != null) {
      graphics.setClip(
          path: PdfPath()..addEllipse(Rect.fromLTWH(10, 0, 80, 80)));
      final res =
          await http.get(Uri.parse(URL_BACKEND + invoiceinfo.userImage));
      final PdfBitmap logoCompany = PdfBitmap(res.bodyBytes);
      graphics.drawImage(logoCompany, Rect.fromLTWH(10, 0, 80, 80));
    }
    //Restore the graphics.
    graphics.restore();
    //save document
    final docData = document.save();
    //close document
    document.dispose();
    return docData;
  }

  static Future<List<int>> generateFacture(ByteData imageSignature,
      InvoiceInfo invoiceinfo, int nbDays, String emissionDate) async {
    double prixMission = nbDays * invoiceinfo.tjm;
    double prixTva = (prixMission / 100) * invoiceinfo.tva;
    double prixCommisionPc = (prixMission / 100) * invoiceinfo.commissionPc;

    final document = PdfDocument();
    final page = document.pages.add();
    final pageSize = page.getClientSize();
    final graphics = page.graphics;
    //Read font data.
    final fontData = await rootBundle.load("assets/fonts/abhaya.ttf");
//Create a PDF true type font object.
    final PdfFont font = PdfTrueTypeFont(fontData.buffer.asUint8List(), 10);
    final PdfFont fontSmall = PdfTrueTypeFont(fontData.buffer.asUint8List(), 6);

    //draw freelance name
    graphics.drawString(
        '''${invoiceinfo.userFullName}\n${invoiceinfo.userAddress}\n @:${invoiceinfo.userEmail}''',
        font,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds: Rect.fromLTWH(0, 85, 100, 0));
    graphics.drawString(
        '''A l'attention de :\n${invoiceinfo.companyName}\n${invoiceinfo.companyAddress}''',
        font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(pageSize.width - 110, 30, 110, 0));

    //draw devis number
    graphics.drawString('''Devis N : ${invoiceinfo.invoiceNumber}''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 200, 0, 0));

    //draw project name
    graphics.drawString('''${invoiceinfo.projectName}''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 210, 0, 0));
    //draw date émission
    graphics.drawString('''Date d'émission : $emissionDate''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        bounds: Rect.fromLTWH(0, 220, 0, 0));

    //draw grid
    final grid = PdfGrid();
    grid.style.font = font;
    grid.columns.add(count: 5);
    grid.columns[0].width = 220;
    final headerRow = grid.headers.add(1)[0];
    headerRow.style.backgroundBrush = PdfBrushes.violet;
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = "Désignation";
    headerRow.cells[1].value = "Quantité";
    headerRow.cells[2].value = "Prix unitaire";
    headerRow.cells[3].value = "TVA";
    headerRow.cells[4].value = "Montant HT";
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    for (int i = 0; i < headerRow.cells.count; i++)
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    final row = grid.rows.add();
    row.cells[0].value = "${invoiceinfo.projectDescription}";
    row.cells[1].value = "$nbDays";
    row.cells[2].value = "${invoiceinfo.tjm}";
    row.cells[3].value = "${invoiceinfo.tva}%";
    row.cells[4].value = "$prixMission€";

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable1LightAccent3);

    grid.draw(page: page, bounds: Rect.fromLTWH(0, 270, 0, 0));

    //draw total
    graphics.drawString('''Total HT''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 500, 0, 0));
    //draw total
    graphics.drawString('''$prixMission€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 500, 0, 0));
    //draw total
    graphics.drawString('''Commission PC ${invoiceinfo.commissionPc}%''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 510, 0, 0));
    //draw total
    graphics.drawString('''$prixCommisionPc€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 510, 0, 0));
    graphics.drawString('''TVA ${invoiceinfo.tva}%''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 520, 0, 0));
    graphics.drawString('''$prixTva€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 520, 0, 0));
    graphics.drawString('''Total TTC''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(300, 530, 0, 0));
    graphics.drawString('''${prixMission + prixTva + prixCommisionPc}€''', font,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        brush: PdfBrushes.violet,
        bounds: Rect.fromLTWH(410, 530, 0, 0));

//draw signature
    graphics.drawString(
        '''Signature''', PdfStandardFont(PdfFontFamily.helvetica, 8),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds: Rect.fromLTWH(pageSize.width - 120, 620, 0, 0));

    final PdfBitmap image = PdfBitmap(imageSignature.buffer.asUint8List());
    graphics.drawImage(
        image, Rect.fromLTWH(pageSize.width - 180, 640, 100, 40));
    //draw footer
    graphics.drawString(
        '''${invoiceinfo.sas} au capital de ${invoiceinfo.capital}\nSIRET ${invoiceinfo.siret} - RCS ${invoiceinfo.rcs} - NAF ${invoiceinfo.naf}\n TVA intracommunautaire : ${invoiceinfo.numberTva}\nPage 1/1''',
        fontSmall,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds:
            Rect.fromLTWH(pageSize.width - 250, pageSize.height - 20, 0, 0));
    //draw freelance image
    if (invoiceinfo.userImage != null) {
      graphics.setClip(
          path: PdfPath()..addEllipse(Rect.fromLTWH(10, 0, 80, 80)));
      final res =
          await http.get(Uri.parse(URL_BACKEND + invoiceinfo.userImage));
      final PdfBitmap logoCompany = PdfBitmap(res.bodyBytes);
      graphics.drawImage(logoCompany, Rect.fromLTWH(10, 0, 80, 80));
    }
    //Restore the graphics.
    graphics.restore();
    //save document
    final docData = document.save();
    //close document
    document.dispose();
    return docData;
  }

  static Future<List<int>> addCompanySignature(
      List<int> docBytes, ByteData imageSignature) async {
    final PdfDocument document = PdfDocument(inputBytes: docBytes);
    final page = document.pages[0];
    final graphics = page.graphics;

    //draw signature
    graphics.drawString(
        '''Signature entreprise''', PdfStandardFont(PdfFontFamily.helvetica, 8),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        bounds: Rect.fromLTWH(130, 660, 0, 0));

    final PdfBitmap image = PdfBitmap(imageSignature.buffer.asUint8List());
    graphics.drawImage(image, Rect.fromLTWH(90, 680, 100, 40));
    final docData = document.save();
    //close document
    document.dispose();
    return docData;
  }
}

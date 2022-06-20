import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/models/invoice.dart';

class PrintingBuilder {
  final Invoice invoice;

  double get _totalfacture => double.parse(invoice.facture.factureMontant);

  PrintingBuilder({this.invoice});

  final image = imageFromAssetBundle('assets/icons/applogo.png');

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          await PdfGoogleFonts.robotoRegular(),
          await PdfGoogleFonts.robotoBold(),
          await PdfGoogleFonts.robotoItalic(),
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Facture N° ${invoice.facture.factureId}",
              style: pw.TextStyle(
                color: PdfColors.black,
                fontWeight: pw.FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.0,
              ),
            ),
          ),
          pw.SizedBox(height: 10.0),
          _contentTable(context),
          pw.SizedBox(height: 8),
          _contentFooter(context),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 5.0),
          margin: const pw.EdgeInsets.only(bottom: 5.0),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey600, width: .5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.SizedBox(),
              pw.Text(
                "DATE : ${formatDate(DateTime.now())} ",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 9.0,
                  fontWeight: pw.FontWeight.normal,
                ),
              )
            ],
          ),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.only(left: 20),
                  child: pw.Text(
                    'Zando',
                    style: pw.TextStyle(
                      color: PdfColors.pink,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 30.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4.0),
                pw.Container(
                  padding: const pw.EdgeInsets.only(left: 20),
                  child: pw.Text(
                    'PRINT GRAPHIC',
                    style: pw.TextStyle(
                      color: PdfColors.pink,
                      fontWeight: pw.FontWeight.normal,
                      fontSize: 10.0,
                      fontStyle: pw.FontStyle.italic,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      "CLIENT",
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12.0,
                      ),
                    ),
                    pw.SizedBox(width: 10.0),
                    pw.Text(
                      invoice.facture.client.clientNom,
                    ),
                  ],
                ),
                pw.Text(
                  "Tél : ${invoice.facture.client.clientTel}",
                  style: const pw.TextStyle(fontSize: 12.0),
                ),
                pw.Text(
                  "Adresse : ${invoice.facture.client.clientAdresse}",
                  style: const pw.TextStyle(fontSize: 12.0),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey600, width: .5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Flexible(
            child: pw.Text(
              "RCCM : CD/KNG/RCCM/21-A-02337\nID.NAT. :01-C1700-N84832W",
              style: const pw.TextStyle(
                fontSize: 8,
                lineSpacing: 5,
                color: PdfColors.black,
              ),
            ),
          ),
          pw.Flexible(
            child: pw.Text(
              "TEL : +243 81 84 85 879 \nLocal 05, Nouvelle Gallerie, C/Gombe",
              textAlign: pw.TextAlign.justify,
              style: const pw.TextStyle(
                fontSize: 6,
                lineSpacing: 2,
                color: PdfColors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.black,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('HT : '),
                    pw.Text(formatCurrency(_totalfacture),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(color: PdfColors.black, thickness: .5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('HT en CDF : '),
                    pw.Text("${convertDollarsToCdf(_totalfacture)} CDF",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(color: PdfColors.black, thickness: .5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tva : '),
                    pw.Text('0 %'),
                  ],
                ),
                pw.Divider(color: PdfColors.black, thickness: .5),
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Net à payer : '),
                      pw.Text(formatCurrency(_totalfacture)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = ['Désignation', 'P.U', 'Quantité', 'Total'];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey800,
      ),
      headerHeight: 25,
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight
      },
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: PdfColors.black,
        fontSize: 10,
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: .5,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col].toUpperCase(),
      ),
      data: List<List<String>>.generate(
        invoice.factureDetails.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => invoice.factureDetails[row].getIndex(col),
        ),
      ),
    );
  }
}

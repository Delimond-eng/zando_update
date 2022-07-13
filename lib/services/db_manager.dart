import 'dart:convert';
import 'package:zando/models/invoice.dart';

import 'sqlite_db_helper.dart';

class DataManager {
  static Future<Invoice> getFactureInvoice({int factureId}) async {
    var db = await DbHelper.initDb();
    var jsonResponse;
    try {
      var facture = await db.rawQuery(
          "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_id = '$factureId'");
      if (facture != null) {
        var details = await db.query(
          "facture_details",
          where: "facture_id=?",
          whereArgs: [factureId],
        );

        if (details != null) {
          jsonResponse = jsonEncode(
              {"facture": facture.first, "facture_details": details});
        }
      }
    } catch (ex) {
      print("error from $ex");
    }

    if (jsonResponse != null) {
      var invoice = Invoice.fromMap(jsonDecode(jsonResponse));
      return invoice;
    } else {
      return null;
    }
  }
}

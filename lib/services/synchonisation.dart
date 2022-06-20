import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as Api;
import 'package:zando/models/sync_model.dart';

import 'sqlite_db_helper.dart';

class Synchroniser {
  static const String baseURL = "http://z-database.rtgroup-rdc.com";
  static Future inPutData() async {
    var db = await DbHelper.initDb();
    var users = await db.query("users");
    if (users.isNotEmpty) {
      send({"users": users});
    }
    try {
      await db
          .rawDelete("DELETE FROM clients WHERE client_state=?", ['deleted']);
    } catch (err) {}
    var clients = await db.query("clients");
    if (clients.isNotEmpty) {
      send({"clients": clients});
    }

    try {
      await db.rawDelete(
          "DELETE factures FROM factures WHERE facture_state=?", ['deleted']);
    } catch (err) {}
    var factures = await db.query("factures");
    if (factures.isNotEmpty) {
      send({"factures": factures});
    }
    try {
      await db.rawDelete(
          "DELETE FROM facture_details WHERE facture_detail_state =?",
          ['deleted']);
    } catch (err) {}
    var factureDetails = await db.query("facture_details");
    if (factureDetails.isNotEmpty) {
      send({"facture_details": factureDetails});
    }

    try {
      await db
          .rawQuery("SELECT FROM comptes WHERE compte_state=?", ['deleted']);
    } catch (e) {}

    var comptes = await db.query("comptes");
    if (comptes.isNotEmpty) {
      send({"comptes": comptes});
    }
    try {
      await db
          .rawDelete("DELETE FROM articles WHERE article_state=?", ['deleted']);
    } catch (e) {}

    var articles = await db.query("articles");
    if (articles.isNotEmpty) {
      send({"articles": articles});
    }

    try {
      await db.rawDelete("DELETE FROM stocks WHERE stock_state=?", ['deleted']);
    } catch (err) {}

    var stocks = await db.query("stocks");
    if (stocks.isNotEmpty) {
      send({"stocks": stocks});
    }

    try {
      await db
          .rawDelete("DELETE FROM mouvements WHERE mouvt_state=?", ['deleted']);
    } catch (err) {}

    var mouvements = await db.query("mouvements");
    if (mouvements.isNotEmpty) {
      send({"mouvements": mouvements});
    }

    try {
      await db.rawDelete(
          "DELETE FROM operations WHERE operation_state=?", ['deleted']);
    } catch (err) {}

    var operations = await db.query("operations");
    if (operations.isNotEmpty) {
      send({"operations": operations});
    }
  }

  static Future<SyncModel> outPutData() async {
    Api.Client client = Api.Client();
    Api.Response response;
    try {
      response = await client.get(Uri.parse("$baseURL/datas/sync/out"));
    } catch (err) {
      print("error from output data $err");
    }
    if (response.statusCode != null && response.statusCode == 200) {
      return SyncModel.fromMap(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<void> send(Map<String, dynamic> map) async {
    String json = jsonEncode(map);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String filename = "file.json";
    File file = File(tempPath + "/" + filename);
    file.createSync();
    file.writeAsStringSync(json);
    try {
      var request =
          Api.MultipartRequest('POST', Uri.parse("$baseURL/datas/sync/in"));

      request.files.add(
        Api.MultipartFile.fromBytes(
          'fichier',
          file.readAsBytesSync(),
          filename: filename.split("/").last,
        ),
      );
      request
          .send()
          .then((result) async {
            Api.Response.fromStream(result).then((response) {
              if (response.statusCode == 200) {
                print(response.body);
              }
            });
          })
          .catchError((err) => print('error : ' + err.toString()))
          .whenComplete(() {});
    } catch (err) {
      print("error from $err");
    }
  }
}

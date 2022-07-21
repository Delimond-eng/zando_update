import 'package:get/get.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/models/client.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/models/currency.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/user.dart';
import 'package:zando/services/native_db_helper.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
//import 'package:zando/services/synchonisation.dart';

class DataController extends GetxController {
  static DataController instance = Get.find();
  var users = <User>[].obs;
  var factures = <Facture>[].obs;
  var clients = <Client>[].obs;
  var clientFactures = <Client>[].obs;
  var comptes = <Compte>[].obs;
  var currency = Currency().obs;
  var isSyncWaiting = false.obs;

  @override
  void onInit() {
    super.onInit();
    editCurrency();
    refreshDatas();
  }

  Future<void> refreshDatas() async {
    var db = await DbHelper.initDb();
    var userData = await db.query("users");
    if (userData != null) {
      users.clear();
      userData.forEach((e) {
        users.add(User.fromMap(e));
      });
    }
    refreshCurrency();
    loadClients();
    loadFacturesEnAttente();
    loadAccount();
    loadClientFactures();
  }

  refreshCurrency() async {
    var db = await DbHelper.initDb();
    var taux = await db.query("currency");
    if (taux != null && taux.isNotEmpty) {
      currency.value = Currency.fromMap(taux.first);
    }
  }

  loadFacturesEnAttente() async {
    var allFactures = await NativeDbHelper.rawQuery(
        "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_statut = 'en attente' AND NOT factures.facture_state='deleted' ORDER BY facture_client_id DESC");
    if (allFactures != null) {
      factures.clear();
      allFactures.forEach((e) {
        factures.add(Facture.fromMap(e));
      });
    }
  }

  loadClients() async {
    var allClients = await NativeDbHelper.rawQuery(
        "SELECT * FROM clients WHERE NOT client_state='deleted' ORDER BY client_id DESC");
    if (allClients != null) {
      clients.clear();
      allClients.forEach((e) {
        clients.add(Client.fromMap(e));
      });
    }
  }

  loadClientFactures() async {
    var allClients = await NativeDbHelper.rawQuery(
        "SELECT * FROM clients INNER JOIN factures ON clients.client_id = factures.facture_client_id  WHERE factures.facture_statut = 'en attente' AND NOT clients.client_state='deleted' AND factures.facture_montant > 0 GROUP BY clients.client_id ORDER BY clients.client_id DESC");
    if (allClients != null) {
      clientFactures.clear();
      allClients.forEach((e) {
        clientFactures.add(Client.fromMap(e));
      });
    }
  }

  loadAccount() async {
    var allAccounts = await NativeDbHelper.rawQuery(
        "SELECT * FROM comptes WHERE compte_status='actif' AND NOT compte_state='deleted'");

    if (allAccounts != null) {
      comptes.clear();
      allAccounts.forEach((e) {
        comptes.add(Compte.formMap(e));
      });
    }
  }

  editCurrency({String value}) async {
    var db = await DbHelper.initDb();
    var data = Currency(currencyValue: value);
    var checked = await db.query("currency");
    if (checked.isEmpty && value == null) {
      var data = Currency(currencyValue: "1990");
      await db.insert("currency", data.toMap());
    }
    if (value != null) {
      var lastUpdatedId = await db.update(
        "currency",
        data.toMap(),
        where: "currency_id=?",
        whereArgs: [1],
      );
      if (lastUpdatedId != null) {
        refreshCurrency();
      }
    }
  }

  deleteUnavailableData() async {
    var db = await DbHelper.initDb();
    try {
      await db.transaction((txn) async {
        await txn
            .rawDelete("DELETE FROM clients WHERE client_state=?", ['deleted']);
        await txn
            .rawDelete("DELETE FROM comptes WHERE compte_state=?", ['deleted']);
        await txn.rawDelete(
            "DELETE FROM factures WHERE facture_state=?", ['deleted']);
        await txn.rawDelete(
            "DELETE FROM facture_details WHERE facture_detail_state=?",
            ['deleted']);
        await txn.rawDelete(
            "DELETE FROM operations WHERE operation_state=?", ['deleted']);
        await txn
            .rawDelete("DELETE FROM stocks WHERE stocks_state=?", ['deleted']);
        await txn.rawDelete(
            "DELETE FROM mouvements WHERE mouvt_state=?", ['deleted']);
        await txn.rawDelete(
            "DELETE FROM articles WHERE article_state=?", ['deleted']);
        print("unvailable data deleted !");
      });
    } catch (err) {}
  }

  syncData() async {
    var db = await DbHelper.initDb();
    await deleteUnavailableData();
    var syncDatas = await Synchroniser.outPutData();
    try {
      if (syncDatas.users.isNotEmpty) {
        print("users: ${syncDatas.users.length}");
        for (var user in syncDatas.users) {
          var check = await db.rawQuery(
            "SELECT * FROM users WHERE user_id = ?",
            [user.userId],
          );
          if (check.isEmpty) {
            await db.insert("users", user.toMap());
          } else {
            await db.update(
              "users",
              user.toMap(),
              where: "user_id=?",
              whereArgs: [user.userId],
            );
          }
        }
      }
      if (syncDatas.clients.isNotEmpty) {
        print("clients : ${syncDatas.clients.length}");
        try {
          for (var client in syncDatas.clients) {
            if (client.clientState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM clients WHERE client_id = ?",
                [client.clientId],
              );
              if (check.isEmpty) {
                await db.insert("clients", client.toMap());
              }
            } else {
              await db.delete("clients",
                  where: "client_id = ?", whereArgs: [client.clientId]);
            }
          }
        } catch (err) {}
      }
      if (syncDatas.factures.isNotEmpty) {
        print("factures : ${syncDatas.factures.length}");
        try {
          for (var facture in syncDatas.factures) {
            if (facture.factureState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM factures WHERE facture_id = ?",
                [facture.factureId],
              );
              if (check.isEmpty) {
                await db.insert("factures", facture.toMap());
              }
            } else {
              await db.delete("factures",
                  where: "facture_id = ?", whereArgs: [facture.factureId]);
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.factureDetails.isNotEmpty) {
        print("details : ${syncDatas.factureDetails.length}");
        try {
          for (var detail in syncDatas.factureDetails) {
            if (detail.factureDetailState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM facture_details WHERE facture_detail_id = ?",
                [detail.factureDetailId],
              );
              if (check.isEmpty) {
                await db.insert("facture_details", detail.toMap());
              } else {
                Get.back();
              }
            } else {
              await db.delete("facture_details",
                  where: "facture_detail_id = ?",
                  whereArgs: [detail.factureDetailId]);
            }
          }
        } catch (e) {}
      }
      if (syncDatas.operations.isNotEmpty) {
        print("operations : ${syncDatas.operations.length}");
        try {
          for (var operation in syncDatas.operations) {
            if (operation.operationState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM operations WHERE operation_id = ?",
                [operation.operationId],
              );
              if (check.isEmpty) {
                await db.insert("operations", operation.toMap());
              }
            } else {
              await db.delete("operations",
                  where: "operation_id = ?",
                  whereArgs: [operation.operationId]);
            }
          }
        } catch (e) {}
      }
      if (syncDatas.comptes.isNotEmpty) {
        print("comptes : ${syncDatas.comptes.length}");
        try {
          for (var compte in syncDatas.comptes) {
            if (compte.compteState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM comptes WHERE compte_id = ? ",
                [compte.compteId],
              );
              if (check.isEmpty) {
                await db.insert("comptes", compte.toMap());
              } else {
                await db.update(
                  "comptes",
                  compte.toMap(),
                  where: "compte_id=?",
                  whereArgs: [compte.compteId],
                );
              }
            } else {
              await db.delete("comptes",
                  where: "compte_id = ?", whereArgs: [compte.compteId]);
            }
          }
        } catch (e) {}
      }
      if (syncDatas.stocks.isNotEmpty) {
        print("stocks : ${syncDatas.stocks.length}");
        try {
          for (var stock in syncDatas.stocks) {
            if (stock.stockState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM stocks WHERE stock_id = ?",
                [stock.stockId],
              );
              if (check.isEmpty) {
                await db.insert("stocks", stock.toMap());
              } else {
                if (stock.stockState != "deleted") {
                  await db.update(
                    "stocks",
                    stock.toMap(),
                    where: "stock_id = ?",
                    whereArgs: [stock.stockId],
                  );
                }
              }
            } else {
              await db.delete("stocks",
                  where: "stock_id = ?", whereArgs: [stock.stockId]);
            }
          }
        } catch (e) {}
      }
      if (syncDatas.mouvements.isNotEmpty) {
        print("mouvements : ${syncDatas.mouvements.length}");
        try {
          for (var mouvt in syncDatas.mouvements) {
            if (mouvt.mouvtState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM mouvements WHERE mouvt_id = ?",
                [mouvt.mouvtId],
              );
              if (check.isEmpty) {
                await db.insert("mouvements", mouvt.toMap());
              } else {
                if (mouvt.mouvtState != "deleted") {
                  await db.update(
                    "mouvements",
                    mouvt.toMap(),
                    where: "mouvt_id=?",
                    whereArgs: [mouvt.mouvtId],
                  );
                }
              }
            } else {
              await db.delete("mouvements",
                  where: "mouvt_id = ?", whereArgs: [mouvt.mouvtId]);
            }
          }
        } catch (e) {}
      }
      if (syncDatas.articles.isNotEmpty) {
        print("articles : ${syncDatas.articles.length}");
        try {
          for (var article in syncDatas.articles) {
            if (article.articleState == "allowed") {
              var check = await db.rawQuery(
                "SELECT * FROM articles WHERE article_id = ?",
                [article.articleId],
              );
              if (check.isEmpty && article.articleState != "deleted") {
                await db.insert("articles", article.toMap());
              }
            } else {
              await db.delete(
                "articles",
                where: "article_id = ?",
                whereArgs: [article.articleId],
              );
            }
          }
        } catch (e) {}
      }
      await refreshDatas();
    } catch (err) {
      Xloading.dismiss();
      print(err);
    }
  }
}

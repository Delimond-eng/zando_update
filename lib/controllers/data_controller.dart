import 'package:get/get.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/models/client.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/models/currency.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/user.dart';
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
    var db = await DbHelper.initDb();
    var allFactures = await db.rawQuery(
        "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE factures.facture_statut = 'en attente' AND NOT factures.facture_state='deleted'");
    if (allFactures != null) {
      factures.clear();
      allFactures.forEach((e) {
        factures.add(Facture.fromMap(e));
      });
    }
  }

  loadClients() async {
    var db = await DbHelper.initDb();
    var allClients = await db.rawQuery(
        "SELECT * FROM clients WHERE NOT client_state='deleted' ORDER BY client_id DESC");
    if (allClients != null) {
      clients.clear();
      allClients.forEach((e) {
        clients.add(Client.fromMap(e));
      });
    }
  }

  loadClientFactures() async {
    var db = await DbHelper.initDb();
    var allClients = await db.rawQuery(
        "SELECT * FROM clients INNER JOIN factures ON clients.client_id = factures.facture_client_id  WHERE factures.facture_statut = 'en attente' AND NOT clients.client_state='deleted' AND factures.facture_montant > 0 GROUP BY clients.client_id");
    if (allClients != null) {
      clientFactures.clear();
      allClients.forEach((e) {
        clientFactures.add(Client.fromMap(e));
      });
    }
  }

  loadAccount() async {
    var db = await DbHelper.initDb();
    var allAccounts = await db.rawQuery(
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

  syncData() async {
    var db = await DbHelper.initDb();
    var syncDatas = await Synchroniser.outPutData();
    try {
      isSyncWaiting.value = true;
      if (syncDatas.users.isNotEmpty) {
        try {
          for (var user in syncDatas.users) {
            var check = await db.rawQuery(
                "SELECT * FROM users WHERE user_id = ?", [user.userId]);
            if (check.isNotEmpty) {
              var id = await db.update(
                "users",
                user.toMap(),
                where: "user_id=?",
                whereArgs: [user.userId],
              );
              print("user update id : $id");
            } else {
              var id = await db.insert(
                "users",
                user.toMap(),
              );
              print("user inserted id : $id");
            }
          }
        } catch (err) {
          print(err);
        }
      }
      if (syncDatas.clients.isNotEmpty) {
        try {
          for (var client in syncDatas.clients) {
            var check = await db.rawQuery(
                "SELECT * FROM clients WHERE client_id=?", [client.clientId]);
            if (check.isEmpty) {
              var id = await db.insert(
                "clients",
                client.toMap(),
              );
              print("client inserted id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.factures.isNotEmpty) {
        try {
          for (var facture in syncDatas.factures) {
            var check = await db.rawQuery(
                "SELECT * FROM factures WHERE facture_id = ?",
                [facture.factureId]);
            if (check.isNotEmpty) {
              print("exist");
            } else {
              var id = await db.insert(
                "factures",
                facture.toMap(),
              );
              print("facture inserted id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }

      if (syncDatas.factureDetails.isNotEmpty) {
        try {
          for (var detail in syncDatas.factureDetails) {
            var check = await db.rawQuery(
                "SELECT * FROM facture_details WHERE facture_detail_id = ?",
                [detail.factureDetailId]);
            if (check.isNotEmpty) {
              print("exist !");
            } else {
              var id = await db.insert(
                "facture_details",
                detail.toMap(),
              );
              print("details inserted id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.operations.isNotEmpty) {
        try {
          for (var operation in syncDatas.operations) {
            var check = await db.rawQuery(
                "SELECT * FROM operations WHERE operation_id = ?",
                [operation.operationId]);
            if (check.isNotEmpty) {
              print("exit");
            } else {
              var id = await db.insert(
                "operations",
                operation.toMap(),
              );
              print("operation inserted id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.comptes.isNotEmpty) {
        try {
          for (var compte in syncDatas.comptes) {
            var check = await db.rawQuery(
                "SELECT * FROM comptes WHERE compte_id = ?", [compte.compteId]);
            if (check.isNotEmpty) {
              var id = await db.update(
                "comptes",
                compte.toMap(),
                where: "compte_id=?",
                whereArgs: [int.parse(compte.compteId)],
              );
              print("compte inserted id : $id");
            } else if (check.isEmpty) {
              var id = await db.insert(
                "comptes",
                compte.toMap(),
              );
              print("compte update id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.stocks.isNotEmpty) {
        try {
          for (var stock in syncDatas.stocks) {
            var check = await db.rawQuery(
                "SELECT * FROM stocks WHERE stock_id = ?", [stock.stockId]);
            if (check.isNotEmpty) {
              var id = await db.update(
                "stocks",
                stock.toMap(),
                where: "stock_id=?",
                whereArgs: [int.parse(stock.stockId.toString())],
              );
              print("stock inserted id : $id");
            } else {
              var id = await db.insert(
                "stocks",
                stock.toMap(),
              );
              print("stock updated id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.mouvements.isNotEmpty) {
        try {
          for (var mouvt in syncDatas.mouvements) {
            var check = await db.rawQuery(
                "SELECT * FROM mouvements WHERE mouvt_id = ?", [mouvt.mouvtId]);
            if (check.isNotEmpty) {
              var id = await db.update(
                "mouvements",
                mouvt.toMap(),
                where: "mouvt_id=?",
                whereArgs: [mouvt.mouvtId],
              );
              print("mvt inserted id : $id");
            } else {
              var id = await db.insert(
                "mouvements",
                mouvt.toMap(),
              );
              print("mvt inserted id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.articles.isNotEmpty) {
        try {
          for (var article in syncDatas.articles) {
            var check = await db.rawQuery(
                "SELECT * FROM articles WHERE article_id =?",
                [article.articleId]);
            if (check.isEmpty) {
              var id = await db.insert(
                "articles",
                article.toMap(),
              );
              print("stock inserted id : $id");
            }
          }
        } catch (e) {
          print(e);
        }
      }
      await refreshDatas();
    } catch (err) {
      Xloading.dismiss();
      print(err);
    }
  }
}

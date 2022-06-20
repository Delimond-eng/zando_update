import 'package:get/get.dart';
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
        for (var user in syncDatas.users) {
          var check = await db
              .rawQuery("SELECT * FROM users WHERE user_id = ?", [user.userId]);
          if (check.isNotEmpty) {
            await db.update(
              "users",
              user.toMap(),
              where: "user_id=?",
              whereArgs: [user.userId],
            );
          } else {
            await db.insert(
              "users",
              user.toMap(),
            );
          }
        }
      }
      if (syncDatas.clients.isNotEmpty) {
        for (var client in syncDatas.clients) {
          var check = await db.rawQuery(
              "SELECT * FROM clients WHERE client_id='${client.clientId}' AND NOT client_state='deleted'");
          if (check.isEmpty) {
            await db.insert(
              "clients",
              client.toMap(),
            );
          }
        }
      }
      if (syncDatas.factures.isNotEmpty) {
        for (var facture in syncDatas.factures) {
          var check = await db.rawQuery(
              "SELECT * FROM factures WHERE facture_id = '${facture.factureId}' AND NOT facture_state='deleted'");
          if (check.isEmpty) {
            await db.insert(
              "factures",
              facture.toMap(),
            );
          }
        }
      }

      if (syncDatas.factureDetails.isNotEmpty) {
        for (var detail in syncDatas.factureDetails) {
          var check = await db.rawQuery(
              "SELECT * FROM facture_details WHERE facture_detail_id = '${detail.factureDetailId}' AND NOT facture_detail_state='deleted'");
          if (check.isEmpty) {
            await db.insert(
              "facture_details",
              detail.toMap(),
            );
          }
        }
      }
      if (syncDatas.operations.isNotEmpty) {
        for (var operation in syncDatas.operations) {
          var check = await db.rawQuery(
              "SELECT * FROM operations WHERE operation_id = '${operation.operationId}' AND NOT operation_state='deleted'");
          if (check.isEmpty) {
            await db.insert(
              "operations",
              operation.toMap(),
            );
          }
        }
      }
      if (syncDatas.comptes.isNotEmpty) {
        for (var compte in syncDatas.comptes) {
          var check = await db.rawQuery(
              "SELECT * FROM comptes WHERE compte_id = '${compte.compteId}' AND NOT compte_state='deleted'");
          if (check.isNotEmpty) {
            await db.update(
              "comptes",
              compte.toMap(),
              where: "compte_id=?",
              whereArgs: [int.parse(compte.compteId)],
            );
          } else if (check.isEmpty) {
            await db.insert(
              "comptes",
              compte.toMap(),
            );
          }
        }
      }
      if (syncDatas.stocks.isNotEmpty) {
        for (var stock in syncDatas.stocks) {
          var check = await db.rawQuery(
              "SELECT * FROM stocks WHERE stock_id = '${stock.stockId}' AND NOT stock_state='deleted'");
          if (check.isNotEmpty) {
            await db.update(
              "stocks",
              stock.toMap(),
              where: "stock_id=?",
              whereArgs: [int.parse(stock.stockId.toString())],
            );
          } else if (check.isEmpty) {
            await db.insert(
              "stocks",
              stock.toMap(),
            );
          }
        }
      }
      if (syncDatas.mouvements.isNotEmpty) {
        for (var mouvt in syncDatas.mouvements) {
          var check = await db.rawQuery(
              "SELECT * FROM mouvements WHERE mouvt_id = '${mouvt.mouvtId}' AND NOT mouvt_state='deleted'");
          if (check.isNotEmpty) {
            await db.update(
              "mouvements",
              mouvt.toMap(),
              where: "mouvt_id=?",
              whereArgs: [mouvt.mouvtId],
            );
          } else if (check.isEmpty) {
            await db.insert(
              "mouvements",
              mouvt.toMap(),
            );
          }
        }
      }
      if (syncDatas.articles.isNotEmpty) {
        for (var article in syncDatas.articles) {
          var check = await db.rawQuery(
              "SELECT * FROM articles WHERE article_id = '${article.articleId}' AND NOT article_state='deleted'");
          if (check.isEmpty) {
            await db.insert(
              "articles",
              article.toMap(),
            );
          }
        }
      }
      await refreshDatas();
    } catch (err) {
      print(err);
    }
  }
}

import 'package:get/get.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/models/client.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/models/currency.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/user.dart';
import 'package:zando/services/db_manager.dart';
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
        "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_statut = 'en attente' AND NOT factures.facture_state='deleted' ORDER BY facture_client_id DESC");
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
    var syncDatas = await Synchroniser.outPutData();
    try {
      if (syncDatas.users.isNotEmpty) {
        for (var user in syncDatas.users) {
          await DataManager.checkAndSyncData(
            "users",
            user.toMap(),
            checkField: "user_id",
            checkValue: user.userId,
            updated: true,
          );
        }
      }
      if (syncDatas.clients.isNotEmpty) {
        for (var client in syncDatas.clients) {
          await DataManager.checkAndSyncData(
            "clients",
            client.toMap(),
            checkField: "client_id",
            notDeletedFields: "client_state",
            checkValue: client.userId,
            updated: false,
          );
        }
      }
      if (syncDatas.factures.isNotEmpty) {
        try {
          for (var facture in syncDatas.factures) {
            await DataManager.checkAndSyncData(
              "factures",
              facture.toMap(),
              checkField: "facture_id",
              notDeletedFields: "facture_state",
              checkValue: facture.factureId,
              updated: false,
            );
          }
        } catch (e) {
          print(e);
        }
      }
      if (syncDatas.factureDetails.isNotEmpty) {
        for (var detail in syncDatas.factureDetails) {
          await DataManager.checkAndSyncData(
            "facture_details",
            detail.toMap(),
            checkField: "facture_detail_id",
            checkValue: detail.factureDetailId,
            notDeletedFields: "facture_detail_state",
            updated: false,
          );
        }
      }
      if (syncDatas.operations.isNotEmpty) {
        for (var operation in syncDatas.operations) {
          await DataManager.checkAndSyncData(
            "operations",
            operation.toMap(),
            checkField: "operation_id",
            checkValue: operation.operationId,
            notDeletedFields: "operation_state",
            updated: false,
          );
        }
      }
      if (syncDatas.comptes.isNotEmpty) {
        for (var compte in syncDatas.comptes) {
          await DataManager.checkAndSyncData(
            "comptes",
            compte.toMap(),
            checkField: "compte_id",
            checkValue: compte.compteId,
            notDeletedFields: "compte_state",
            updated: true,
          );
        }
      }
      if (syncDatas.stocks.isNotEmpty) {
        for (var stock in syncDatas.stocks) {
          await DataManager.checkAndSyncData(
            "stocks",
            stock.toMap(),
            checkField: "stock_id",
            notDeletedFields: "stock_state",
            checkValue: stock.stockId,
            updated: true,
          );
        }
      }
      if (syncDatas.mouvements.isNotEmpty) {
        for (var mouvt in syncDatas.mouvements) {
          await DataManager.checkAndSyncData(
            "mouvements",
            mouvt.toMap(),
            checkField: "mouvt_id",
            notDeletedFields: "mouvt_state",
            checkValue: mouvt.mouvtId,
            updated: true,
          );
        }
      }
      if (syncDatas.articles.isNotEmpty) {
        for (var article in syncDatas.articles) {
          await DataManager.checkAndSyncData(
            "articles",
            article.toMap(),
            checkField: "article_id",
            checkValue: article.articleId,
            updated: false,
          );
        }
      }
      await refreshDatas();
    } catch (err) {
      Xloading.dismiss();
      print(err);
    }
  }
}

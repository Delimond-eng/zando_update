import 'package:zando/global/utils.dart';

import 'article.dart';

class Stock {
  dynamic stockId;
  dynamic stockQte;
  dynamic stockPrixAchat;
  String stockPrixAchatDevise;
  dynamic stockArticleId;
  dynamic stockCreatAt;
  String stockDate;
  String stockStatus;
  String stockState;
  Article article;

  Stock({
    this.stockId,
    this.stockQte,
    this.stockPrixAchat,
    this.stockPrixAchatDevise,
    this.stockArticleId,
    this.stockStatus,
    this.stockCreatAt,
    this.stockState,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};

    if (stockId != null) {
      data["stock_id"] = int.parse(stockId.toString());
    }

    if (stockQte != null) {
      data["stock_qte"] = int.parse(stockQte.toString());
    }
    if (stockPrixAchat != null) {
      data["stock_prix_achat"] = double.parse(stockPrixAchat.toString());
    }
    if (stockPrixAchatDevise != null) {
      data["stock_prix_achat_devise"] = stockPrixAchatDevise;
    }
    if (stockStatus != null) {
      data["stock_status"] = stockStatus;
    } else {
      data["stock_status "] = "actif";
    }
    if (stockArticleId != null) {
      data["stock_article_id"] = int.parse(stockArticleId.toString());
    }
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (stockCreatAt == null) {
      data["stock_create_At"] = convertToTimestamp(now);
    } else {
      data["stock_create_At"] = int.parse(stockCreatAt.toString());
    }
    if (stockState == null) {
      data["stock_state"] = "allowed";
    } else {
      data["stock_state"] = stockState;
    }
    return data;
  }

  Stock.fromMap(Map<String, dynamic> data) {
    stockId = data["stock_id"];
    stockQte = data["stock_qte"];
    stockPrixAchat = data["stock_prix_achat"];
    stockPrixAchatDevise = data["stock_prix_achat_devise"];
    stockArticleId = data["stock_article_id"];
    stockStatus = data["stock_status"];
    stockCreatAt = data["stock_create_At"];
    stockState = data["stock_state"];
    if (data["article_id"] != null) {
      article = Article.fromMap(data);
    }
    try {
      stockDate = dateToString(parseTimestampToDate(data["stock_create_At"]));
    } catch (err) {}
  }
}

import 'package:zando/global/utils.dart';

import 'stock.dart';

class MouvementStock {
  dynamic mouvtId;
  dynamic mouvtQte;
  dynamic mouvtStockId;
  dynamic mouvtTimestamp;
  String mouvtDate;
  String mouvtState;
  Stock stock;

  MouvementStock(
      {this.mouvtId,
      this.mouvtQte,
      this.mouvtStockId,
      this.mouvtTimestamp,
      this.mouvtState});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (mouvtId != null) {
      data["mouvt_id"] = int.parse(mouvtId.toString());
    }
    if (mouvtQte != null) {
      data["mouvt_qte"] = int.parse(mouvtQte.toString());
    }
    if (mouvtStockId != null) {
      data["mouvt_stock_id"] = int.parse(mouvtStockId.toString());
    }
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (mouvtTimestamp == null) {
      data["mouvt_create_At"] = convertToTimestamp(now);
    } else {
      data["mouvt_create_At"] = int.parse(mouvtTimestamp);
    }
    data["mouvt_state"] = mouvtState ?? "allowed";
    return data;
  }

  MouvementStock.fromMap(Map<String, dynamic> data) {
    mouvtId = data["mouvt_id"];
    mouvtQte = data["mouvt_qte"];
    mouvtStockId = data["mouvt_stock_id"];
    mouvtTimestamp = data["mouvt_create_At"];
    mouvtState = data["mouvt_state"];

    if (data["stock_id"] != null) {
      stock = Stock.fromMap(data);
    }
    try {
      mouvtDate = dateToString(parseTimestampToDate(data["mouvt_create_At"]));
    } catch (err) {}
  }
}

import 'package:zando/global/utils.dart';

class FactureDetail {
  dynamic factureDetailId;
  String factureDetailLibelle;
  dynamic factureDetailQte;
  String factureDetailPu;
  String factureDetailDevise;
  dynamic factureId;
  dynamic factureDetailTimestamp;
  String factureDetailState;
  double get total => double.parse(factureDetailPu) * factureDetailQte;
  FactureDetail({
    this.factureDetailId,
    this.factureDetailLibelle,
    this.factureDetailQte,
    this.factureDetailPu,
    this.factureDetailDevise,
    this.factureId,
    this.factureDetailTimestamp,
    this.factureDetailState,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (factureDetailId != null) {
      data["facture_detail_id"] = int.parse(factureDetailId.toString());
    }

    if (factureDetailLibelle != null) {
      data["facture_detail_libelle"] = factureDetailLibelle;
    }
    if (factureDetailQte != null) {
      data["facture_detail_qte"] = int.parse(factureDetailQte.toString());
    }
    if (factureDetailPu != null) {
      if (factureDetailPu.contains(",")) {
        data["facture_detail_pu"] =
            double.parse(factureDetailPu.replaceAll(",", "."));
      } else {
        data["facture_detail_pu"] = double.parse(factureDetailPu);
      }
    }
    if (factureDetailDevise != null) {
      data["facture_detail_devise"] = factureDetailDevise;
    }
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (factureDetailTimestamp == null) {
      data["facture_detail_create_At"] = convertToTimestamp(now);
    } else {
      data["facture_detail_create_At"] =
          int.parse(factureDetailTimestamp.toString());
    }
    if (factureId != null) {
      data["facture_id"] = int.parse(factureId.toString());
    }
    if (factureDetailState == null) {
      data["facture_detail_state"] = "allowed";
    } else {
      data["facture_detail_state"] = factureDetailState;
    }
    return data;
  }

  FactureDetail.fromMap(Map<String, dynamic> data) {
    factureDetailId = data["facture_detail_id"];
    factureDetailLibelle = data["facture_detail_libelle"];
    factureDetailQte = data["facture_detail_qte"];
    factureDetailPu = data["facture_detail_pu"].toString();
    factureDetailDevise = data["facture_detail_devise"];
    factureDetailTimestamp = data["facture_detail_create_At"];
    factureDetailState = data["facture_detail_state"];
    factureId = data["facture_id"];
  }

  String getIndex(int index) {
    switch (index) {
      case 0:
        return factureDetailLibelle;
      case 1:
        return "$factureDetailPu  $factureDetailDevise";
      case 2:
        return "$factureDetailQte";
      case 3:
        return "$total  $factureDetailDevise";
    }
    return '';
  }
}

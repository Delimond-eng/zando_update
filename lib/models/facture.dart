import 'package:zando/global/utils.dart' as DateUtils;
import 'package:zando/index.dart';

import 'client.dart';
import 'user.dart';

class Facture {
  dynamic factureId;
  String factureMontant;
  String factureDevise;
  dynamic factureCreateAt;
  String factureDateCreate;
  String factureStatut;
  String factureState;
  dynamic factureClientId;
  dynamic factureTimestamp;

  Client client;
  User user;

  Facture({
    this.factureId,
    this.factureMontant,
    this.factureDevise,
    this.factureClientId,
    this.factureCreateAt,
    this.factureStatut,
    this.factureTimestamp,
    this.factureState,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (factureId != null) {
      data["facture_id"] = int.parse(factureId.toString());
    }

    if (factureMontant != null) {
      data["facture_montant"] = double.parse(
          double.parse(factureMontant.toString()).toStringAsFixed(2));
    }
    if (factureDevise != null) {
      data["facture_devise"] = factureDevise;
    }
    if (factureClientId != null) {
      data["facture_client_id"] = int.parse(factureClientId.toString());
    }

    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (factureTimestamp == null) {
      data["facture_create_At"] =
          factureCreateAt ?? DateUtils.convertToTimestamp(now);
    } else {
      data["facture_create_At"] = int.parse(factureTimestamp.toString());
    }
    if (factureStatut != null) {
      data["facture_statut"] = factureStatut;
    }
    data["user_id"] = authController.loggedUser.value.userId ??
        int.parse(user.userId.toString());
    data["facture_state"] = factureState ?? "allowed";
    return data;
  }

  Facture.fromMap(Map<String, dynamic> data) {
    factureId = data["facture_id"];
    factureMontant = data["facture_montant"].toString();
    factureDevise = data["facture_devise"];
    factureClientId = data["facture_client_id"];
    factureStatut = data["facture_statut"];
    factureTimestamp = data["facture_create_At"];
    factureState = data["facture_state"];
    if (data["client_id"] != null) {
      client = Client.fromMap(data);
    }
    if (data["user_id"] != null) {
      user = User.fromMap(data);
    }
    try {
      factureDateCreate = DateUtils.dateToString(
          DateUtils.parseTimestampToDate(data["facture_create_At"]));
    } catch (err) {}
  }
}

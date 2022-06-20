import 'package:zando/global/utils.dart';

import 'client.dart';
import 'compte.dart';
import 'facture.dart';
import 'user.dart';

class Operations {
  dynamic operationId;
  String operationLibelle;
  String operationType;
  String operationMode;
  String operationDate;
  dynamic operationTimestamp;
  dynamic operationMontant;
  String operationDevise;
  String operationState;
  dynamic operationCompteId;
  dynamic operationFactureId;
  dynamic operationUserId;

  Facture facture;
  Client client;
  User user;
  Compte compte;

  Operations({
    this.operationId,
    this.operationLibelle,
    this.operationType,
    this.operationMontant,
    this.operationMode,
    this.operationDevise,
    this.operationCompteId,
    this.operationFactureId,
    this.operationUserId,
    this.operationState,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};

    if (operationId != null) {
      data["operation_id"] = int.parse(operationId.toString());
    }

    if (operationLibelle != null) {
      data["operation_libelle"] = operationLibelle;
    }
    if (operationType != null) {
      data["operation_type"] = operationType;
    }
    if (operationMontant != null) {
      if (operationMontant.toString().contains(',')) {
        data["operation_montant"] =
            double.parse(operationMontant.toString().replaceAll(",", "."));
      } else {
        data["operation_montant"] = double.parse(operationMontant.toString());
      }
    }
    data["operation_devise"] = operationDevise;
    data["operation_compte_id"] = int.parse(operationCompteId.toString());
    if (operationFactureId != null) {
      data["operation_facture_id"] = int.parse(operationFactureId.toString());
    } else {
      data["operation_facture_id"] = 0;
    }
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (operationTimestamp == null) {
      data["operation_create_At"] = now.microsecondsSinceEpoch;
    } else {
      data["operation_create_At"] = int.parse(operationTimestamp.toString());
    }
    if (operationMode != null) {
      data["operation_mode"] = operationMode;
    } else {
      data["operation_mode"] = "";
    }
    data["operation_user_id"] = int.parse(operationUserId.toString());
    data["operation_state"] = operationState ?? "allowed";
    return data;
  }

  Operations.fromMap(Map<String, dynamic> data) {
    operationId = data["operation_id"];
    operationLibelle = data["operation_libelle"];
    operationDevise = data["operation_devise"];
    operationTimestamp = data["operation_create_At"];
    operationType = data["operation_type"];
    operationCompteId = data["operation_compte_id"];
    operationFactureId = data["operation_facture_id"];
    operationUserId = data["operation_user_id"];
    operationMontant = data["operation_montant"];
    operationState = data["operation_state"];
    if (data["operation_mode"] == null) {
      operationMode = "";
    } else {
      operationMode = data["operation_mode"];
    }
    if (data['facture_id'] != null) {
      facture = Facture.fromMap(data);
    }
    if (data["operation_user_id"] != null && data["client_id"] != null) {
      client = Client.fromMap(data);
    }
    if (data["compte_id"] != null) {
      compte = Compte.formMap(data);
    }
    try {
      operationDate =
          dateToString(parseTimestampToDate(data["operation_create_At"]));
    } catch (err) {}
  }
}

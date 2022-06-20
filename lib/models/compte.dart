import 'package:zando/global/utils.dart';

class Compte {
  dynamic compteId;
  dynamic compteTimestamp;
  String compteLibelle;
  String compteDevise;
  String compteStatus;
  String compteState;

  bool isSelected = false;
  Compte({
    this.compteId,
    this.compteLibelle,
    this.compteDevise,
    this.compteStatus,
    this.compteState,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};

    if (compteId != null) {
      data["compte_id"] = int.parse(compteId.toString());
    }

    if (compteLibelle != null) {
      data["compte_libelle"] = compteLibelle;
    }
    if (compteDevise != null) {
      data["compte_devise"] = compteDevise;
    }
    if (compteStatus != null) {
      data["compte_status"] = compteStatus;
    } else {
      data["compte_status"] = "actif";
    }
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (compteTimestamp == null) {
      data["compte_create_At"] = convertToTimestamp(now);
    } else {
      data["compte_create_At"] = int.parse(compteTimestamp.toString());
    }

    if (compteState == null) {
      data["compte_state"] = "allowed";
    } else {
      data["compte_state"] = compteState;
    }

    return data;
  }

  Compte.formMap(Map<String, dynamic> data) {
    compteId = data["compte_id"];
    compteLibelle = data["compte_libelle"];
    compteDevise = data["compte_devise"];
    compteStatus = data["compte_status"];
    compteTimestamp = data["compte_create_At"];
    compteState = data["compte_state"];
  }
}

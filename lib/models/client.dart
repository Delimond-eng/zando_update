import 'package:zando/global/utils.dart' as DateUtils;
import 'package:zando/index.dart';

class Client {
  dynamic clientId;
  dynamic userId;
  String clientNom;
  String clientTel;
  String clientAdresse;
  String clientCreatAt;
  String clientState;
  dynamic clientTimestamp;

  bool isSelected = false;
  Client({
    this.clientId,
    this.userId,
    this.clientNom,
    this.clientTel,
    this.clientAdresse,
    this.clientCreatAt,
    this.clientTimestamp,
    this.clientState,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (clientId != null) {
      data["client_id"] = int.parse(clientId.toString());
    }
    if (clientNom != null) {
      data["client_nom"] = clientNom;
    }
    if (clientTel != null) {
      data["client_tel"] = clientTel;
    }
    if (clientAdresse != null) {
      data["client_adresse"] = clientAdresse;
    }
    if (userId == null) {
      data["user_id"] = authController.loggedUser.value.userId;
    } else {
      data["user_id"] = int.parse(userId.toString());
    }
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (clientTimestamp == null) {
      data["client_create_At"] = DateUtils.convertToTimestamp(now);
    } else {
      data["client_create_At"] = int.parse(clientTimestamp.toString());
    }
    data["client_state"] = clientState ?? "allowed";
    return data;
  }

  Client.fromMap(Map<String, dynamic> data) {
    clientId = data["client_id"];
    clientNom = data["client_nom"];
    clientTel = data["client_tel"];
    clientAdresse = data["client_adresse"];
    clientState = data["client_state"];
    userId = data["user_id"];
    if (data["client_create_At"] != null) {
      try {
        clientTimestamp = data["client_create_At"];
        DateTime date =
            DateUtils.parseTimestampToDate(data["client_create_At"]);
        clientCreatAt = DateUtils.dateToString(date);
      } catch (err) {}
    }
  }
}

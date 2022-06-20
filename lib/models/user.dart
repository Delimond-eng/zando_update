import 'package:zando/global/data_crypt.dart';

class User {
  dynamic userId;
  String userName;
  String userRole;
  String userPass;
  String userAccess;

  bool hasPassVisibility = false;
  User({
    this.userId,
    this.userName,
    this.userRole,
    this.userPass,
    this.userAccess,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (userId != null) {
      data["user_id"] = userId;
    }
    if (userName != null) {
      data["user_name"] = userName;
    }
    if (userRole != null) {
      data["user_role"] = userRole;
    }
    if (userPass != null) {
      data["user_pass"] = Cryptage.encrypt(userPass);
    }
    if (userAccess != null) {
      data["user_access"] = userAccess;
    } else {
      data["user_access"] = "allowed";
    }
    return data;
  }

  User.fromMap(Map<String, dynamic> map) {
    userId = map["user_id"];
    userName = map["user_name"];
    userRole = map["user_role"];
    if (map['user_pass'] != null) {
      userPass = Cryptage.decrypt(map["user_pass"]);
    }
    userAccess = map["user_access"];
  }
}

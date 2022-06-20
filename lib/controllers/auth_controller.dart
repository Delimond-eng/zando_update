import 'package:get/get.dart';
import 'package:zando/models/user.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  var loggedUser = User().obs;
}

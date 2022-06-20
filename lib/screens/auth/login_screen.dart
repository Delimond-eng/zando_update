// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/global/data_crypt.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/index.dart';
import 'package:zando/models/user.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/widgets/auth_input.dart';

import '../home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _textUsername = TextEditingController();
  final _textPassword = TextEditingController();
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      DesktopWindow.setFullScreen(true);
    }
    initData();
  }

  initData() async {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Xloading.showCircularProgress(key.currentContext,
          title: "Patientez !\nsynchronisation en cours... !");
      await dataController.syncData();
      Xloading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage("assets/images/background3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: primaryColor.withOpacity(.2)),
          child: Obx(() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      width: 500.0,
                      height: 300.0,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 10.0,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AuthInput(
                              hintText: "Entrez nom utilisateur.",
                              icon: CupertinoIcons.person,
                              controller: _textUsername,
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            AuthInput(
                              hintText: "Entrez mot de passe.",
                              isPassWord: true,
                              controller: _textPassword,
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              height: 60.0,
                              width: size.width,
                              color: Colors.transparent,
                              child: RaisedButton(
                                color: Colors.pink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                splashColor: Colors.pink[200],
                                elevation: 10.0,
                                onPressed: () => loggedIn(context),
                                child: const Text(
                                  "CONNECTER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        color: Colors.pink.withOpacity(.8),
                        height: 40.0,
                      ),
                      top: 0,
                      right: 0,
                      left: 0,
                    )
                  ],
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> loggedIn(BuildContext context) async {
    var db = await DbHelper.initDb();
    if (_textUsername.text.isEmpty) {
      XDialog.showErrorMessage(context,
          message:
              "le nom d'utilisateur est requis pour se connecter ! ex. gaston");
      return;
    }

    if (_textPassword.text.isEmpty) {
      XDialog.showErrorMessage(context,
          message: "le mot de passe est requis pour se connecter !");
      return;
    }

    try {
      String userName = _textUsername.text;
      String userPass = Cryptage.encrypt(_textPassword.text);
      var checkedUser = await db.rawQuery(
          "SELECT * FROM users WHERE user_name=? AND user_pass=?",
          [userName, userPass]);
      if (checkedUser != null && checkedUser.isNotEmpty) {
        User connected = User.fromMap(checkedUser[0]);
        if (connected.userAccess == "allowed") {
          authController.loggedUser.value = connected;
          Xloading.showLottieLoading(context);
          Future.delayed(const Duration(seconds: 2), () {
            Xloading.dismiss();
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: const HomePage(),
                  type: PageTransitionType.leftToRightWithFade),
              (route) => false,
            );
          });
        } else {
          XDialog.showErrorMessage(context,
              message:
                  "l'accès à ce compte est restreint, l'administrateur doit activer le compte pour vous connecter !");
          return;
        }
      } else {
        XDialog.showErrorMessage(context,
            message: "Mot de passe ou nom utilisateur invalide !");
        return;
      }
    } catch (err) {
      print("error from connect user statment: $err");
    }
  }
}

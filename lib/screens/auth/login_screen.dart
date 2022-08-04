// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/global/data_crypt.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/index.dart';
import 'package:zando/models/user.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/widgets/app_logo.dart';
import 'package:zando/widgets/auth_field.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  StreamSubscription<ConnectivityResult> subscription;
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      DesktopWindow.setFullScreen(true);
    }
    initData();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  initData() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          Xloading.showCircularProgress(
            key.currentContext,
            title: "Patientez !\nsynchronisation en cours... !",
            dismissable: true,
          );
          await dataController.syncData();
          Xloading.dismiss();
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          XDialog.showErrorMessage(
            context,
            duration: const Duration(seconds: 4),
            message:
                "Veuillez vous connecter à un réseau wifi pour synchroniser les données !",
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: key,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppLogo(
                size: 30.0,
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(15.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.black26,
                ),
                height: 200.0,
                width: 420.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AuthField(
                        hintText: "Entrez le nom d'utilisateur...",
                        icon: CupertinoIcons.person,
                        controller: _textUsername,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Flexible(
                      child: AuthField(
                        hintText: "Entrez le mot de passe...",
                        icon: CupertinoIcons.lock,
                        isPassWord: true,
                        controller: _textPassword,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Flexible(
                      child: Container(
                        height: 50.0,
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          splashColor: Colors.pink[200],
                          elevation: 10.0,
                          onPressed: () => loggedIn(context),
                          child: Text(
                            "Connecter".toUpperCase(),
                            style: GoogleFonts.didactGothic(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
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
          await dataController.refreshDatas();
          await dataController.editCurrency();
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

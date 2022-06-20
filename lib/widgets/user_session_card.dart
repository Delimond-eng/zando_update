import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/index.dart';
import 'package:zando/screens/auth/login_screen.dart';

class UserSessionCard extends StatelessWidget {
  const UserSessionCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        color: Colors.green,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 20, 5),
          child: Row(
            children: [
              Container(
                height: 90.0,
                width: 50.0,
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.green,
                    ],
                  ),
                ),
                child: SvgPicture.asset(
                  "assets/icons/menu_profile.svg",
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    authController.loggedUser.value.userRole,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    authController.loggedUser.value.userName
                        .replaceAll("@", "")
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                    ),
                  )
                ],
              ),
              const SizedBox(
                width: 10.0,
              ),
              const Icon(
                Icons.arrow_drop_down_sharp,
                color: Colors.black,
                size: 20.0,
              )
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: primaryColor.withOpacity(.8),
      onSelected: (value) {
        switch (value) {
          case 1:
            XDialog.show(
              icon: Icons.logout,
              context: context,
              content:
                  "Etes-vous sûr de vouloir vous déconnecter de votre compte ?",
              title: "Déconnexion",
              onValidate: () {
                authController.loggedUser.value = null;
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      child: const LoginScreen(),
                      type: PageTransitionType.bottomToTop),
                  (route) => false,
                );
              },
            );
            break;
          case 2:
            XDialog.show(
              icon: Icons.clear,
              context: context,
              content: "Etes-vous sûr de vouloir fermer l'application ?",
              title: "Fermeture",
              onValidate: () {
                authController.loggedUser.value = null;
                exit(0);
              },
            );
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(
                  Icons.exit_to_app,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
              Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              )
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              Text(
                "Fermer",
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              )
            ],
          ),
        ),
      ],
    );
  }
}

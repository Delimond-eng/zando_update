import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zando/global/controllers.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/models/user.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/input_text.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/page_header.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({Key key}) : super(key: key);

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        children: [
          const PageHeader(
            leadingIcon: "assets/icons/menu_profile.svg",
            title: "Gestion utilisateurs",
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _createUser(context),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: _viewUser(context),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final ScrollController _clientScroller = ScrollController();

  Widget _viewUser(BuildContext context) {
    return Container(
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Obx(
            () {
              return dataController.users.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun utilisateur enregistré !",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.pink,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 8.0,
                            ),
                            child: CustomTableHeader(
                              haveActionsButton: true,
                              items: [
                                "Nom d'utilisateur",
                                "Mot de passe",
                                "Utilisateur Rôle",
                              ],
                            ),
                          ),
                        ),
                        _userListContent(context)
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _userListContent(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: _clientScroller,
        radius: const Radius.circular(10.0),
        isAlwaysShown: true,
        thickness: 10.0,
        child: SingleChildScrollView(
          controller: _clientScroller,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
          child: Column(
            children: [
              for (int i = 0; i < dataController.users.length; i++) ...[
                Container(
                  height: 60.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: i.isEven ? Colors.pink : primaryColor,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.3),
                        blurRadius: 5.0,
                        offset: Offset.zero,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.person_circle_fill,
                                color: primaryColor.withOpacity(.3),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                dataController.users[i].userName,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: dataController.users[i].userAccess ==
                                          "allowed"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dataController.users[i].hasPassVisibility
                                    ? dataController.users[i].userPass
                                    : dataController.users[i].userPass
                                        .replaceAll(RegExp(r"."), "*"),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              IconButton(
                                icon: Icon(
                                  dataController.users[i].hasPassVisibility
                                      ? CupertinoIcons.eye_slash_fill
                                      : CupertinoIcons.eye_solid,
                                  size: 15.0,
                                ),
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    dataController.users[i].hasPassVisibility =
                                        !dataController
                                            .users[i].hasPassVisibility;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  dataController.users[i].userRole,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dataController.users[i].userAccess ==
                                  "allowed") ...[
                                FlatButton(
                                  padding: const EdgeInsets.all(18.0),
                                  child: const Text(
                                    "Restreindre accès",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: Colors.red,
                                  onPressed: () =>
                                      manageAccess(dataController.users[i]),
                                ),
                              ] else ...[
                                FlatButton(
                                  padding: const EdgeInsets.all(18.0),
                                  child: const Text(
                                    "Activé accès",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: Colors.green,
                                  onPressed: () =>
                                      manageAccess(dataController.users[i]),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  final textUserName = TextEditingController();
  final textUserPass = TextEditingController();
  final textUserConfirm = TextEditingController();
  Widget _createUser(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.white,
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputText(
                        errorText: "Nom d'utilisateur requis !",
                        hintText: "Entrez nom d'utilisateur...",
                        icon: CupertinoIcons.person_circle_fill,
                        title: "Nom d'utilisateur",
                        controller: textUserName,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      InputText(
                        errorText: "Mot de passe requis !",
                        hintText: "Entrez mot de passe...",
                        icon: CupertinoIcons.lock_fill,
                        title: "Mot de passe",
                        isPassword: true,
                        controller: textUserPass,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      InputText(
                        errorText: "Confirmation mot de passe requise !",
                        hintText: "Entrez la confirmation du mot de passe...",
                        icon: CupertinoIcons.lock_circle_fill,
                        title: "Confirmation Mot de passe",
                        isPassword: true,
                        controller: textUserConfirm,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        children: [
                          Flexible(child: _userRoleDropdown()),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Flexible(
                            child: CostumBtn(
                              icon: CupertinoIcons.add_circled_solid,
                              label: "Créer utilisateur",
                              color: Colors.green,
                              onPressed: () => createUser(context),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String userRole;
  Widget _userRoleDropdown() {
    return Row(
      children: [
        Flexible(
          child: Container(
            width: double.infinity,
            height: 55.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: primaryColor,
              ),
              borderRadius: BorderRadius.circular(
                4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButton(
                menuMaxHeight: 300,
                dropdownColor: Colors.white,
                alignment: Alignment.centerRight,
                borderRadius: BorderRadius.zero,
                style: const TextStyle(
                  color: Colors.black,
                ),
                value: userRole,
                underline: const SizedBox(),
                hint: const Text(
                  "Rôle d'utilisateur",
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 16.0,
                  ),
                ),
                isExpanded: true,
                items: ["Administrateur", "Utilisateur", "Gestionnaire stock"]
                    .map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.supervised_user_circle_rounded,
                          size: 15.0,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          e,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    userRole = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  _emptyRole({String value}) {
    setState(() {
      userRole = value;
      textUserConfirm.text = "";
      textUserName.text = "";
      textUserPass.text = "";
    });
  }

  Future<void> createUser(context) async {
    var db = await DbHelper.initDb();
    if (_formKey.currentState.validate()) {
      if (textUserPass.text != textUserConfirm.text) {
        print("confirm pass failed !");
        return;
      }
      if (userRole != null) {
        var user = User(
          userName: textUserName.text,
          userPass: textUserPass.text,
          userRole: userRole,
        );
        var result = await db.insert(
          "users",
          user.toMap(),
        );
        if (result != null) {
          _emptyRole();
          await dataController.refreshDatas();
          await Synchroniser.inPutData();
          XDialog.showSuccessAnimation(context);
        }
      }
    }
  }

  Future<void> manageAccess(User u) async {
    var db = await DbHelper.initDb();
    var user = User(userAccess: u.userAccess == "allowed" ? "denied" : null);
    var update = await db.update("users", user.toMap(),
        where: "user_id=?", whereArgs: [u.userId]);
    if (update != null) {
      await dataController.refreshDatas();
      await Synchroniser.inPutData();
    }
  }
}

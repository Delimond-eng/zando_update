import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/index.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/input_text.dart';

class CreateAccountTab extends StatefulWidget {
  const CreateAccountTab({Key key}) : super(key: key);

  @override
  State<CreateAccountTab> createState() => _CreateAccountTabState();
}

class _CreateAccountTabState extends State<CreateAccountTab> {
  final _formKey = GlobalKey<FormState>();
  final _textLibelle = TextEditingController();
  final ScrollController scroller = ScrollController();
  List<Compte> comptes = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    var db = await DbHelper.initDb();
    var allAccounts = await db.query(
      "comptes",
    );
    if (allAccounts != null) {
      comptes.clear();
      setState(() {
        allAccounts.forEach((e) {
          comptes.add(Compte.formMap(e));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 300.0,
          width: MediaQuery.of(context).size.width,
          child: Card(
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputText(
                      errorText: "Libellé du compte requise !",
                      hintText: "Entrez le libellé du compte...",
                      icon: CupertinoIcons.pencil,
                      title: "Libellé du compte",
                      controller: _textLibelle,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Devise du compte",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _deviseViewer(),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            width: 200,
                            child: CostumBtn(
                              color: Colors.green,
                              icon: CupertinoIcons.add_circled_solid,
                              label: "Créer",
                              onPressed: () => _createAccount(context),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Flexible(
                          child: Container(
                            width: 200,
                            child: CostumBtn(
                              color: Colors.grey[500],
                              icon: Icons.change_circle_sharp,
                              label: "Annuler",
                              onPressed: () async {
                                setState(() {
                                  _textLibelle.text = "";
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Card(
              color: Colors.white,
              elevation: 3,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                              "N° ",
                              "Compte Libellé",
                              "Compte Devise",
                              "Compte Status"
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          controller: scroller,
                          radius: const Radius.circular(10.0),
                          thickness: 10.0,
                          isAlwaysShown: true,
                          child: SingleChildScrollView(
                            controller: scroller,
                            child: Column(
                              children: comptes.map((e) {
                                return ItemCompteCard(
                                  data: e,
                                  onDeleted: () async {
                                    var db = await DbHelper.initDb();
                                    var compte = Compte(compteStatus: "fermé");
                                    var lastUpdated = await db.update(
                                        "comptes", compte.toMap(),
                                        where: "compte_id=?",
                                        whereArgs: [e.compteId]);
                                    if (lastUpdated != null) {
                                      initData();
                                      dataController.loadAccount();
                                      await Synchroniser.inPutData();
                                    }
                                  },
                                  onValidated: () async {
                                    var db = await DbHelper.initDb();
                                    var compte = Compte(compteStatus: "actif");
                                    var lastUpdated = await db.update(
                                        "comptes", compte.toMap(),
                                        where: "compte_id=?",
                                        whereArgs: [e.compteId]);
                                    if (lastUpdated != null) {
                                      dataController.loadAccount();
                                      await Synchroniser.inPutData();
                                      initData();
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }

  String selectedDevise = "CDF";
  Widget _deviseViewer() {
    return Container(
      width: 415.0,
      height: 55.0,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: DropdownButton(
        menuMaxHeight: 300,
        dropdownColor: Colors.white,
        alignment: Alignment.centerRight,
        borderRadius: BorderRadius.zero,
        style: const TextStyle(
          color: Colors.black,
        ),
        value: selectedDevise,
        underline: const SizedBox(),
        hint: Text(
          "Devise",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16.0,
          ),
        ),
        isExpanded: true,
        items: ["USD", "CDF"].map((e) {
          return DropdownMenuItem<String>(
            value: e,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                e,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDevise = value;
          });
        },
      ),
    );
  }

  Future<void> _createAccount(BuildContext context) async {
    var db = await DbHelper.initDb();
    if (_formKey.currentState.validate()) {
      var compte = Compte(
        compteDevise: selectedDevise,
        compteLibelle: _textLibelle.text,
      );
      var lastInsertAccount = await db.insert("comptes", compte.toMap());
      if (lastInsertAccount != null) {
        XDialog.showSuccessAnimation(context);
        setState(() {
          _textLibelle.text = "";
        });
        dataController.loadAccount();
        await Synchroniser.inPutData();
        initData();
      }
    }
  }
}

class ItemCompteCard extends StatelessWidget {
  const ItemCompteCard({
    Key key,
    this.data,
    this.onDeleted,
    this.onValidated,
  }) : super(key: key);

  final Compte data;
  final Function onDeleted;
  final Function onValidated;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      margin: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: data.compteId.isEven ? Colors.blue : Colors.pink,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.3),
            blurRadius: 12.0,
            offset: Offset.zero,
          )
        ],
      ),
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
                Text(
                  "${data.compteId}",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
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
                    data.compteLibelle,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                Text(
                  data.compteDevise,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
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
                Text(
                  data.compteStatus,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: (data.compteStatus.trim() == "actif".trim())
                        ? Colors.green[800]
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          if (data.compteStatus == "actif") ...[
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlatButton(
                    padding: const EdgeInsets.all(15.0),
                    onPressed: onDeleted,
                    color: Colors.orange,
                    child: const Text(
                      "Fermer compte",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ] else ...[
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlatButton(
                    padding: const EdgeInsets.all(15.0),
                    onPressed: onValidated,
                    color: Colors.green,
                    child: const Text(
                      "Activer compte",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

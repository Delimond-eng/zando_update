import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/index.dart';
import 'package:zando/models/client.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_input.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/input_text.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/rounded_btn.dart';
import 'package:zando/widgets/sync_btn.dart';
import 'package:zando/widgets/user_session_card.dart';

class CreateCostumer extends StatefulWidget {
  const CreateCostumer({Key key}) : super(key: key);

  @override
  State<CreateCostumer> createState() => _CreateCostumerState();
}

class _CreateCostumerState extends State<CreateCostumer> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  //fields
  final _textNom = TextEditingController();
  final _textPhone = TextEditingController();
  final _textAdresse = TextEditingController();
  int _selectedClientId;

  cleanFields() {
    setState(() {
      _textNom.text = "";
      _textPhone.text = "";
      _textAdresse.text = "";
      _selectedClientId = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    dataController.refreshDatas();
  }

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 8,
                    child: Container(
                      width: double.infinity,
                      child: Card(
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 31.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: InputText(
                                        icon: CupertinoIcons.person_fill,
                                        hintText: "Entrez le nom du client...",
                                        title: "Nom client",
                                        errorText:
                                            "le nom du client est requis !",
                                        controller: _textNom),
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Flexible(
                                    child: InputText(
                                      icon: CupertinoIcons.phone,
                                      hintText:
                                          "Entrez le n° de téléphone du client...",
                                      title: "Téléphone",
                                      errorText: "téléphone du client requis !",
                                      controller: _textPhone,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              InputText(
                                icon: CupertinoIcons.location_solid,
                                hintText: "Entrez adresse du client..",
                                title: "Adresse",
                                errorText: "adresse du client requis !",
                                controller: _textAdresse,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      child: Card(
                        elevation: 3.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: CostumBtn(
                                    label: _selectedClientId == null
                                        ? "Enregistrer"
                                        : "Modifier",
                                    icon: _selectedClientId == null
                                        ? Icons.add
                                        : Icons.edit,
                                    color: _selectedClientId == null
                                        ? Colors.green[700]
                                        : Colors.blue,
                                    onPressed: () {
                                      if (_selectedClientId == null) {
                                        createClient(context);
                                      } else {
                                        updateClient(context);
                                      }
                                    }),
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                              Flexible(
                                child: CostumBtn(
                                  label: "Annuler",
                                  icon: Icons.cancel,
                                  color: Colors.grey[800],
                                  onPressed: () => cleanFields(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              width: double.infinity,
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CostumInput(
                          hintText: "Recherchez client par nom...",
                          icon: CupertinoIcons.search,
                          onTextChanged: (value) async {
                            var db = await DbHelper.initDb();
                            if (value != null && value.isNotEmpty) {
                              List<Client> searchedClient = [];
                              var clients = await db.rawQuery(
                                  "SELECT * FROM clients WHERE client_nom LIKE '%$value%'");
                              dataController.clients.clear();
                              searchedClient.clear();
                              clients.forEach((e) {
                                searchedClient.add(Client.fromMap(e));
                              });
                              dataController.clients.addAll(searchedClient);
                            } else {
                              dataController.loadClients();
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Obx(() {
                          return Expanded(
                            child: dataController.clients.isEmpty
                                ? Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 150, vertical: 40.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.red,
                                            ),
                                          ),
                                          child: const Text(
                                            "Aucun client répertorié !",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        height: 60.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                                              "N° Ordre",
                                              "Nom",
                                              "Téléphone",
                                              "Adresse",
                                            ],
                                          ),
                                        ),
                                      ),
                                      _tableContent(context)
                                    ],
                                  ),
                          );
                        }),
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _tableContent(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        radius: const Radius.circular(10.0),
        isAlwaysShown: true,
        thickness: 10.0,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              for (int i = 0; i < dataController.clients.length; i++) ...[
                Container(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : Colors.pink[50],
                    border: Border(
                      bottom: BorderSide(
                        color: i.isEven ? Colors.blue : Colors.pink,
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
                              "${i + 1}",
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
                              dataController.clients[i].clientNom,
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
                              dataController.clients[i].clientTel,
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
                              dataController.clients[i].clientAdresse,
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
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
                            RoundedBtn(
                              icon: CupertinoIcons.pencil,
                              onPressed: () {
                                var data = dataController.clients[i];
                                setState(() {
                                  _textNom.text = data.clientNom;
                                  _textPhone.text = data.clientTel;
                                  _textAdresse.text = data.clientAdresse;
                                  _selectedClientId = data.clientId;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            RoundedBtn(
                              icon: CupertinoIcons.trash,
                              color: Colors.grey[900],
                              onPressed: authController
                                          .loggedUser.value.userRole ==
                                      "Administrateur"
                                  ? () => deleteClient(context,
                                      clientId:
                                          dataController.clients[i].clientId)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 90.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40.0,
                width: 60.0,
                child: Material(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/back-svgrepo-com.svg",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              SvgPicture.asset(
                "assets/icons/add-user-social-svgrepo-com.svg",
                height: 30.0,
                width: 30.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                "Création client",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          Row(
            children: const [
              SyncBtn(),
              SizedBox(
                width: 10.0,
              ),
              UserSessionCard(),
            ],
          )
        ],
      ),
    );
  }

  Future<void> createClient(BuildContext context) async {
    var db = await DbHelper.initDb();
    if (_formKey.currentState.validate()) {
      Client client = Client(
          clientNom: _textNom.text,
          clientAdresse: _textAdresse.text,
          clientTel: _textPhone.text);
      var lastInserdId = await db.insert("clients", client.toMap());
      if (lastInserdId != null) {
        XDialog.showSuccessAnimation(context);
        await cleanFields();
        await dataController.loadClients();
        await Synchroniser.inPutData();
      }
    }
  }

  Future<void> updateClient(BuildContext context) async {
    var db = await DbHelper.initDb();
    if (_selectedClientId != null) {
      if (_formKey.currentState.validate()) {
        XDialog.show(
            context: context,
            icon: Icons.help,
            content: "Etes-vous sûr de vouloir modifier ce client ?",
            title: "Modification client",
            onValidate: () async {
              Client client = Client(
                clientNom: _textNom.text,
                clientAdresse: _textAdresse.text,
                clientTel: _textPhone.text,
              );
              var lastUpdatedId = await db.update(
                "clients",
                client.toMap(),
                where: "client_id=?",
                whereArgs: [_selectedClientId],
              );
              if (lastUpdatedId != null) {
                XDialog.showSuccessAnimation(context);
                await cleanFields();
                await dataController.loadClients();
                await Synchroniser.inPutData();
              }
            });
      }
    } else {
      XDialog.showErrorMessage(context,
          message: "Veuillez afficher le client à modifier !");
    }
  }

  Future<void> deleteClient(BuildContext ctx, {int clientId}) async {
    var db = await DbHelper.initDb();
    XDialog.show(
        context: ctx,
        icon: Icons.help,
        content:
            "Cette action est irréversible!\nEtes-vous sûr de vouloir supprimer définitivement ce client ?",
        title: "Suppression client",
        onValidate: () async {
          int lastDeletedId = await db
              .delete("clients", where: "client_id=?", whereArgs: [clientId]);
          if (lastDeletedId != null) {
            await dataController.loadClients();
            await Synchroniser.inPutData();
            cleanFields();
          }
        });
  }
}

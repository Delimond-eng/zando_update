import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/global/data.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/index.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/facture_detail.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/widgets/currency_card.dart';
import 'package:zando/widgets/custom_input.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/dashboard_card.dart';
import 'package:zando/widgets/date_picker.dart';
import 'package:zando/widgets/facture_table_content.dart';
import 'package:zando/widgets/navigation_button.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/sync_btn.dart';
import 'package:zando/widgets/user_session_card.dart';

import 'pages/admin/admin_user_page.dart';
import 'pages/create_costumer_page.dart';
import 'pages/documents/create_facture_page.dart';
import 'pages/documents/facture_pay_page.dart';
import 'pages/documents/factures_view.dart';
import 'pages/stockage/stockage_manage_page.dart';
import 'pages/tresorie/tresorie_manage_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int nowTimestamp;
  int selectedDate;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    setState(() {
      nowTimestamp = now.microsecondsSinceEpoch;
    });
  }

  Future<int> count({String from}) async {
    var db = await DbHelper.initDb();
    var res = await db.rawQuery("SELECT COUNT(*) as counter FROM $from");
    return res[0]["counter"];
  }

  Future<double> countDayOperation() async {
    var db = await DbHelper.initDb();
    var query = await db.rawQuery(
        "SELECT SUM(operation_montant) AS daysum FROM operations WHERE operation_libelle = 'Paiement facture' AND operation_create_At='$nowTimestamp' AND NOT operation_state='deleted'");

    if (query.isNotEmpty) {
      if (query.first["daysum"] != null) {
        return double.parse(
            double.parse(query.first["daysum"].toString()).toStringAsFixed(2));
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<double> countModePayment(String mode) async {
    var db = await DbHelper.initDb();
    var query = await db.rawQuery(
        "SELECT SUM(operation_montant) AS mode_sum FROM operations WHERE operation_mode = '$mode' AND operation_create_At='$nowTimestamp' AND NOT operation_state='deleted'");

    if (query.isNotEmpty) {
      if (query.first["mode_sum"] != null) {
        return double.parse(double.parse(query.first["mode_sum"].toString())
            .toStringAsFixed(2));
      }
      return 0;
    } else {
      return 0;
    }
  }

  Widget _buildDashBoard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          const TitleCard(
            icon: "assets/icons/menu_dashbord.svg",
            title: "TABLEAU DE BORD",
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            children: [
              DashBoardCard(
                future: count(from: "clients"),
                icon: "assets/icons/group-svgrepo-com.svg",
                title: "Clients",
                onPressed: () async {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const CreateCostumer(),
                      fullscreenDialog: true,
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              DashBoardCard(
                icon: "assets/icons/document-svgrepo-com(1).svg",
                title: "Factures journalières",
                future: count(
                    from:
                        "factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE factures.facture_create_At LIKE '%$nowTimestamp%' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'"),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const FacturesView(
                        title: "Factures journalières",
                        filterKey: "today",
                      ),
                      fullscreenDialog: true,
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              DashBoardCard(
                icon: "assets/icons/loaddoc.svg",
                future: count(
                    from:
                        "factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE factures.facture_statut='en attente' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'"),
                title: "Factures en cours",
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const FacturesView(
                        title: "Factures en cours",
                        filterKey: "en attente",
                      ),
                      fullscreenDialog: true,
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              DashBoardCard(
                icon: "assets/icons/document-svgrepo-com(2).svg",
                title: "Factures réglées",
                future: count(
                    from:
                        "factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE factures.facture_statut='paie' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'"),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const FacturesView(
                        title: "Factures reglées",
                        filterKey: "paie",
                      ),
                      fullscreenDialog: true,
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              DashBoardCard(
                icon: "assets/icons/document-svgrepo-com(2).svg",
                title: "Toutes les factures",
                future: count(
                    from:
                        "factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'"),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const FacturesView(
                        title: "Toutes les factures",
                      ),
                      fullscreenDialog: true,
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
              ),
            ],
          )
        ],
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
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Bienvenu  sur votre application",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  "Zando",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              if (authController.loggedUser.value.userRole ==
                      "Administrateur" ||
                  authController.loggedUser.value.userRole ==
                      "Utilisateur") ...[
                FutureBuilder<double>(
                  future: countDayOperation(),
                  builder: (context, snapshot) {
                    return Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      color: Colors.blue[800],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total des paiements journaliers",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '${snapshot.data} ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: " \$",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Container(
                              height: 80.0,
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.3),
                                    blurRadius: 10.0,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Modal.show(
                                      context,
                                      height: 370.0,
                                      width: MediaQuery.of(context).size.width *
                                          .5,
                                      color: Colors.blue[800],
                                      modalContent: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Détails sur les paiements journaliers",
                                            style: TextStyle(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          Expanded(
                                            child: GridView(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 3.0,
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 15.0,
                                                mainAxisSpacing: 15.0,
                                              ),
                                              children: [
                                                DetailPayCard(
                                                  title: "Paiements par Cash",
                                                  future:
                                                      countModePayment("Cash"),
                                                ),
                                                DetailPayCard(
                                                  title:
                                                      "Paiements par Virement",
                                                  future: countModePayment(
                                                      "Virement"),
                                                ),
                                                DetailPayCard(
                                                  title: "Paiements par Chèque",
                                                  future: countModePayment(
                                                      "Chèque"),
                                                ),
                                                DetailPayCard(
                                                  title: "Paiements Mobile",
                                                  future: countModePayment(
                                                      "Paiement mobile"),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.dashboard_customize,
                                          size: 15.0,
                                          color: primaryColor,
                                        ),
                                        Text(
                                          "Voir détails",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
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
                    );
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
              const SyncBtn(),
              const SizedBox(
                width: 10.0,
              ),
              const UserSessionCard(),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return PageComponent(
      child: Obx(() {
        return Column(
          children: [
            _buildHeader(context),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleCard(
                    title: "MENU",
                    icon: "assets/icons/menu_tran.svg",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (authController.loggedUser.value.userRole ==
                                  "Administrateur" ||
                              authController.loggedUser.value.userRole ==
                                  "Utilisateur") ...[
                            NavBtn(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const CreateCostumer(),
                                    fullscreenDialog: true,
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                              icon:
                                  "assets/icons/add-user-social-svgrepo-com.svg",
                              title: "Création clients",
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            NavBtn(
                              icon: "assets/icons/add_doc.svg",
                              title: "Création Factures",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const CreateFacturePage(),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            NavBtn(
                              icon: "assets/icons/payment-svgrepo-com.svg",
                              title: "Paiement factures",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const FacturePayPage(),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                          ],
                          if (authController.loggedUser.value.userRole ==
                              "Administrateur") ...[
                            NavBtn(
                              icon:
                                  "assets/icons/bank-safe-box-svgrepo-com.svg",
                              title: "Gestion trésories",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const TresorieManagePage(),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            NavBtn(
                              icon: "assets/icons/menu_profile.svg",
                              title: "Gestion utilisateurs",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const AdminUserPage(),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                          ],
                          if (authController.loggedUser.value.userRole ==
                                  "Administrateur" ||
                              authController.loggedUser.value.userRole
                                  .contains("Gestionnaire stock")) ...[
                            NavBtn(
                              icon: "assets/icons/drop_box.svg",
                              title: "Gestion stock",
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const StockageManagePage(),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                            ),
                          ]

                          //AdminUserPage
                        ],
                      ),
                      if (authController.loggedUser.value.userRole ==
                              "Administrateur" ||
                          authController.loggedUser.value.userRole ==
                              "Utilisateur") ...[const CurrencyCard()]
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            if (authController.loggedUser.value.userRole == "Administrateur" ||
                authController.loggedUser.value.userRole == "Utilisateur") ...[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDashBoard(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TitleCard(
                              title: "FACTURE EN ATTENTE",
                              icon: "assets/icons/loaddoc.svg",
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    child: CostumInput(
                                      hintText:
                                          "Recherchez la facture de client...",
                                      icon: CupertinoIcons.search,
                                      onTextChanged: (value) async {
                                        var db = await DbHelper.initDb();
                                        if (value != null && value.isNotEmpty) {
                                          List<Facture> searchedFactures = [];
                                          var founded = await db.rawQuery(
                                              "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE factures.facture_statut = 'en attente' AND clients.client_nom LIKE '%$value%'");
                                          dataController.factures.clear();
                                          searchedFactures.clear();
                                          founded.forEach((e) {
                                            searchedFactures
                                                .add(Facture.fromMap(e));
                                          });
                                          dataController.factures
                                              .addAll(searchedFactures);
                                        } else {
                                          dataController
                                              .loadFacturesEnAttente();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                CustomDatePicker(
                                  date: selectedDate != null
                                      ? strDateLongFr(dateToString(
                                          parseTimestampToDate(selectedDate)))
                                      : null,
                                  onCleared: () {
                                    setState(() {
                                      selectedDate = null;
                                    });
                                    dataController.refreshDatas();
                                  },
                                  onShownDatePicker: () async {
                                    int date = await showDatePicked(context);
                                    var db = await DbHelper.initDb();
                                    if (date != null) {
                                      setState(() {
                                        selectedDate = date;
                                      });

                                      List<Facture> searchedFactures = [];
                                      var founded = await db.rawQuery(
                                          "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id INNER JOIN users ON factures.user_id = users.user_id WHERE factures.facture_statut = 'en attente' AND factures.facture_create_At = '$date' ");
                                      dataController.factures.clear();
                                      searchedFactures.clear();
                                      founded.forEach((e) {
                                        searchedFactures
                                            .add(Facture.fromMap(e));
                                      });
                                      dataController.factures
                                          .addAll(searchedFactures);
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: dataController.factures.isEmpty
                            ? Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(40.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: Colors.red,
                                        ),
                                      ),
                                      child: const Text(
                                        "Aucune facture en attente répertoriée !",
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
                            : Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 15.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 60.0,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
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
                                            "Date",
                                            "N° facture",
                                            "Montant facture",
                                            "Client Concerné",
                                            "status",
                                            "",
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Scrollbar(
                                        controller: _scrollController,
                                        radius: const Radius.circular(10.0),
                                        isAlwaysShown: true,
                                        thickness: 10.0,
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Column(
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      dataController
                                                          .factures.length;
                                                  i++) ...[
                                                TableContentCard(
                                                  numOrder: i,
                                                  data: dataController
                                                      .factures[i],
                                                  onViewed: () async {
                                                    var db =
                                                        await DbHelper.initDb();
                                                    var allDetails =
                                                        await db.query(
                                                      "facture_details",
                                                      where: "facture_id=?",
                                                      whereArgs: [
                                                        dataController
                                                            .factures[i]
                                                            .factureId
                                                      ],
                                                    );
                                                    if (allDetails != null) {
                                                      List<FactureDetail>
                                                          details = [];
                                                      allDetails.forEach((e) {
                                                        details.add(
                                                            FactureDetail
                                                                .fromMap(e));
                                                      });
                                                      viewFactureDetail(
                                                        context,
                                                        details: details,
                                                        facture: dataController
                                                            .factures[i],
                                                      );
                                                    }
                                                  },
                                                  onDeleted: () {
                                                    XDialog.show(
                                                      context: context,
                                                      content:
                                                          "Etes-vous sûr de vouloir supprimer cette facture en cours ?",
                                                      icon: Icons.help,
                                                      title:
                                                          "Suppression facture en cours !",
                                                      onValidate: () async {
                                                        var db = await DbHelper
                                                            .initDb();
                                                        var facture =
                                                            dataController
                                                                .factures[i];
                                                        facture.factureState =
                                                            "deleted";
                                                        var lastDeletedId =
                                                            await db.update(
                                                                "factures",
                                                                facture.toMap(),
                                                                where:
                                                                    "facture_id=?",
                                                                whereArgs: [
                                                              dataController
                                                                  .factures[i]
                                                                  .factureId
                                                            ]);
                                                        if (lastDeletedId !=
                                                            null) {
                                                          print(lastDeletedId);
                                                          dataController
                                                              .loadFacturesEnAttente();
                                                          var details =
                                                              FactureDetail(
                                                                  factureDetailState:
                                                                      "deleted");
                                                          await db.update(
                                                              "facture_details",
                                                              details.toMap(),
                                                              where:
                                                                  "facture_id=?",
                                                              whereArgs: [
                                                                lastDeletedId
                                                              ]);
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ]
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              )
            ]
          ],
        );
      }),
    );
  }
}

class DetailPayCard extends StatelessWidget {
  const DetailPayCard({
    Key key,
    this.title,
    this.future,
  }) : super(key: key);

  final Future future;
  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: future,
      builder: (context, snapshot) {
        return Card(
          elevation: 5.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.pink,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    text: "${snapshot.data} ",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
                      TextSpan(
                        text: " USD",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15.0,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard({
    Key key,
    this.icon,
    this.title,
  }) : super(key: key);

  final String icon, title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            color: Theme.of(context).primaryColor,
            width: 20.0,
            height: 20.0,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

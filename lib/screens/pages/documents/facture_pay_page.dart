import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/index.dart';
import 'package:zando/models/client.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/operation.dart';
import 'package:zando/services/native_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_input.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker.dart';
import 'package:zando/widgets/expanded_client_card.dart';
import 'package:zando/widgets/input_text.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/page_header.dart';
import 'package:zando/widgets/rounded_btn.dart';

class FacturePayPage extends StatefulWidget {
  const FacturePayPage({Key key}) : super(key: key);

  @override
  State<FacturePayPage> createState() => _FacturePayPageState();
}

class _FacturePayPageState extends State<FacturePayPage> {
  final _clientScroller = ScrollController();
  String selectedMode = "Cash";

  Facture selectedFacture;
  Compte selectedCompte;
  Operations selectedPaieInfos;

  final _formKey = GlobalKey<FormState>();
  final _textMontantPaie = TextEditingController();

  List<Operations> operations = [];
  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    dataController.refreshDatas();
    super.dispose();
  }

  initData() async {
    var allDatas = await NativeDbHelper.rawQuery(
        "SELECT * FROM factures INNER JOIN operations ON factures.facture_id = operations.operation_facture_id INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE NOT factures.facture_state='deleted' AND NOT operations.operation_state='deleted' AND NOT clients.client_state='deleted' ORDER BY operations.operation_id DESC");
    if (allDatas != null) {
      Future.delayed(const Duration(milliseconds: 500));
      operations.clear();
      setState(() {
        allDatas.forEach((e) {
          operations.add(Operations.fromMap(e));
        });
      });
    }
  }

  int selectedDate;

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        children: [
          const PageHeader(
            leadingIcon: "assets/icons/payment-svgrepo-com.svg",
            title: "Paiement Facture",
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5.0),
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _factureClients(context),
                    Expanded(
                      flex: 9,
                      child: Container(
                        child: Card(
                          elevation: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedFacture != null) ...[
                                Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration:
                                      BoxDecoration(color: primaryColor),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "Facture infos & paiement !",
                                        style: GoogleFonts.didactGothic(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (selectedFacture != null) ...[
                                      _factureDetails(context),
                                    ],
                                    _factureInputPaieFields(context)
                                  ],
                                ),
                              ],
                              const SizedBox(
                                height: 10.0,
                              ),
                              _filterBox(context),
                              const SizedBox(
                                height: 5.0,
                              ),
                              if (operations.isNotEmpty) ...[
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  height: 60.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 8.0,
                                    ),
                                    child: CustomTableHeader(
                                      haveActionsButton: (authController
                                                  .loggedUser.value.userRole ==
                                              "Administrateur")
                                          ? true
                                          : false,
                                      items: const [
                                        "Date",
                                        "code facture",
                                        "Montant facture",
                                        "Montant payé",
                                        "Montant restant",
                                        "Mode Paiement",
                                        "Client",
                                      ],
                                    ),
                                  ),
                                )
                              ],
                              Expanded(
                                child: operations.isEmpty
                                    ? Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.pink,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Aucun paiement des factures répertorié !",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Scrollbar(
                                        controller: _clientScroller,
                                        radius: const Radius.circular(10.0),
                                        isAlwaysShown: true,
                                        thickness: 10.0,
                                        child: SingleChildScrollView(
                                          controller: _clientScroller,
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 10, 8, 0),
                                          child: _operationDataTable(context),
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _operationDataTable(BuildContext context) {
    return Column(
      children: operations
          .map(
            (e) => PaieDetailsCard(
                data: e,
                onCleared: () async {
                  XDialog.show(
                      context: context,
                      content:
                          "Etes-vous sûr de vouloir supprimer ce paiement ?",
                      icon: Icons.help,
                      title: "Suppression Paiement",
                      onValidate: () async {
                        var lastDeletedId = await NativeDbHelper.update(
                          "operations",
                          {'operation_state': 'deleted'},
                          where: "operation_id",
                          whereArgs: [e.operationId],
                        );
                        if (lastDeletedId != null) {
                          initData();
                          await NativeDbHelper.update(
                            "factures",
                            {'facture_statut': 'en attente'},
                            where: "facture_id",
                            whereArgs: [e.operationFactureId],
                          );
                          Future.delayed(const Duration(microseconds: 500), () {
                            Synchroniser.inPutData();
                            dataController.deleteUnavailableData();
                          });
                          setState(() {
                            selectedFacture = null;
                          });
                        }
                      });
                }),
          )
          .toList(),
    );
  }

  _filterBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Flexible(
            child: Container(
              child: CostumInput(
                color: Colors.blue,
                hintText: "Recherchez le paiement par client...",
                icon: CupertinoIcons.search,
                onTextChanged: (value) async {
                  if (value.isNotEmpty) {
                    List<Operations> searchedOperations = [];
                    var founded = await NativeDbHelper.rawQuery(
                        "SELECT * FROM factures INNER JOIN operations ON factures.facture_id = operations.operation_facture_id INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE clients.client_nom LIKE '%$value%' AND NOT factures.facture_state='deleted' AND NOT operations.operation_state='deleted' AND NOT clients.client_state='deleted' GROUP BY operations.operation_id ");
                    operations.clear();
                    searchedOperations.clear();
                    setState(() {
                      founded.forEach((e) {
                        searchedOperations.add(Operations.fromMap(e));
                      });
                      operations.addAll(searchedOperations);
                    });
                  } else {
                    initData();
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
          CustomDatePicker(
            color: Colors.blue,
            date: selectedDate != null
                ? strDateLongFr(
                    dateToString(parseTimestampToDate(selectedDate)))
                : null,
            onCleared: () {
              setState(() {
                selectedDate = null;
              });
              initData();
            },
            onShownDatePicker: () async {
              int date = await showDatePicked(context);

              if (date != null) {
                setState(() {
                  selectedDate = date;
                });

                List<Operations> searchedOperations = [];
                var founded = await NativeDbHelper.rawQuery(
                    "SELECT * FROM factures INNER JOIN operations ON factures.facture_id = operations.operation_facture_id INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE operations.operation_create_At = '$selectedDate' AND factures.facture_state='deleted' AND NOT operations.operation_state='deleted' AND NOT clients.client_state='deleted' ORDER BY operations.operation_id ");
                operations.clear();
                searchedOperations.clear();
                setState(() {
                  founded.forEach((e) {
                    searchedOperations.add(Operations.fromMap(e));
                  });
                  operations.addAll(searchedOperations);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _factureClients(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        child: Card(
          elevation: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50.0,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Sélectionnez la facture concerné !",
                      style: GoogleFonts.didactGothic(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CostumInput(
                  hintText: "Recherchez client...",
                  icon: CupertinoIcons.search,
                  onTextChanged: (value) => _filterCostumer(value),
                ),
              ),
              Expanded(
                child: dataController.clientFactures.isEmpty
                    ? Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red,
                                ),
                              ),
                              child: const Text(
                                "Aucun client trouvé !",
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
                    : Scrollbar(
                        isAlwaysShown: true,
                        radius: const Radius.circular(10.0),
                        thickness: 10.0,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: dataController.clientFactures.map((data) {
                              return ExpandedClientCard(
                                data: data,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10.0),
                                  child: FutureBuilder(
                                    future: _showFactureOfClient(data.clientId),
                                    builder: (context,
                                        AsyncSnapshot<List<Facture>> snapshot) {
                                      if (snapshot.data != null) {
                                        return Column(
                                          children: snapshot.data
                                              .map(
                                                (e) => DetailFactureCard(
                                                  data: e,
                                                  onPressed: () async {
                                                    setState(() {
                                                      selectedFacture = null;
                                                    });
                                                    Xloading.showLottieLoading(
                                                        context);
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 1000),
                                                        () {
                                                      setState(() {
                                                        Xloading.dismiss();
                                                        selectedFacture = e;
                                                      });
                                                      _cleanFields();
                                                    });
                                                  },
                                                ),
                                              )
                                              .toList(),
                                        );
                                      } else {
                                        return const Center(
                                          child: Text(
                                            "Chargement...",
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _factureInputPaieFields(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputText(
                title: "Montant paiement",
                hintText: "Entrez le montant de paiement...",
                errorText: "Montant paiement requis !",
                controller: _textMontantPaie,
                icon: CupertinoIcons.pencil,
                suffixChild: _deviseViewer(),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mode de paiement *",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        _modePayDropdown(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Compte *",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        _compteDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Flexible(
                    child: CostumBtn(
                      color: Colors.green,
                      icon: CupertinoIcons.checkmark_alt,
                      label: "Valider le paiement",
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          createPaiements(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: CostumBtn(
                      color: Colors.grey[800],
                      icon: Icons.cached_rounded,
                      label: "Annuler",
                      onPressed: () async {
                        setState(() {
                          selectedFacture = null;
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _factureDetails(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _customerInfos(),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      FieldInfo(
                          title: "N° Facture",
                          value: "${selectedFacture.factureId}"),
                      const SizedBox(
                        height: 10.0,
                      ),
                      FieldInfo(
                        title: "Montant à payer",
                        value:
                            "${selectedFacture.factureMontant ?? '0'} ${selectedFacture.factureDevise ?? ''}",
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: FutureBuilder<double>(
                    initialData: 0.0,
                    future: countPayAmount(selectedFacture.factureId),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          FieldInfo(
                            title: "Montant payé",
                            value:
                                "${snapshot.data} ${selectedFacture.factureDevise}",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          FieldInfo(
                            title: "Montant restant",
                            value:
                                "${(double.parse(selectedFacture.factureMontant) - snapshot.data).toStringAsFixed(2)} ${selectedFacture.factureDevise}",
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modePayDropdown() {
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
              padding: const EdgeInsets.all(10),
              child: DropdownButton(
                menuMaxHeight: 300,
                dropdownColor: Colors.white,
                alignment: Alignment.centerRight,
                borderRadius: BorderRadius.zero,
                style: const TextStyle(
                  color: Colors.black,
                ),
                value: selectedMode,
                underline: const SizedBox(),
                hint: Text(
                  "Mode de paiement",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                  ),
                ),
                isExpanded: true,
                items:
                    ["Cash", "Virement", "Chèque", "Paiement mobile"].map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
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
                    selectedMode = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  _cleanFields({Compte value}) {
    setState(() {
      _textMontantPaie.text = "";
      selectedCompte = value;
    });
  }

  Widget _compteDropdown() {
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
              padding: const EdgeInsets.all(10),
              child: DropdownButton<Compte>(
                menuMaxHeight: 300,
                dropdownColor: Colors.white,
                alignment: Alignment.centerRight,
                borderRadius: BorderRadius.zero,
                style: const TextStyle(
                  color: Colors.black,
                ),
                value: selectedCompte,
                underline: const SizedBox(),
                hint: Text(
                  "Sélectionnez un compte",
                  style: GoogleFonts.didactGothic(
                      color: Colors.grey[600],
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600),
                ),
                isExpanded: true,
                items: dataController.comptes.map((e) {
                  return DropdownMenuItem<Compte>(
                    value: e,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          size: 15.0,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          e.compteLibelle,
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
                    selectedCompte = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  String selectedDevise = "USD";
  Widget _deviseViewer() {
    return Stack(
      children: [
        Container(
          width: 100.0,
          height: 20.0,
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
                child: Text(
                  e,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
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
        )
      ],
    );
  }

  Widget _customerInfos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 70,
                      width: 70.0,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          70.0,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.person_solid,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedFacture.client.clientNom ?? "",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Adresse :  ",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18.0,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    selectedFacture.client.clientAdresse ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.0,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<double> countPayAmount(int id) async {
    var paieInfos = await NativeDbHelper.rawQuery(
        "SELECT * FROM operations INNER JOIN factures ON operations.operation_facture_id = factures.facture_id WHERE operations.operation_facture_id = '$id'");
    List<Operations> operations = [];
    if (paieInfos.isNotEmpty) {
      paieInfos.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      if (operations.isNotEmpty) {
        double amountsPaymnt = 0;
        for (var data in operations) {
          amountsPaymnt += data.operationMontant;
        }
        return double.parse(amountsPaymnt.toStringAsFixed(2));
      }
    } else {
      return 0;
    }
    return 0;
  }

  Future<List<Facture>> _showFactureOfClient(int clientId) async {
    List<Facture> facturesList = [];
    var allFactures = await NativeDbHelper.rawQuery(
        "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE clients.client_id = $clientId AND factures.facture_statut = 'en attente' ORDER BY factures.facture_id DESC");
    if (allFactures != null) {
      allFactures.forEach((e) {
        facturesList.add(Facture.fromMap(e));
      });
    }
    return facturesList;
  }

  Future<void> createPaiements(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      try {
        int currentUserId = authController.loggedUser.value.userId;
        double _lastMontantPaie =
            await countPayAmount(selectedFacture.factureId);
        double inputAmount = 0;
        if (selectedDevise.trim() == "CDF".trim()) {
          inputAmount = convertCdfToDollars(
              double.parse(_textMontantPaie.text.replaceAll(",", ".")));
          selectedDevise = "USD";
        } else {
          inputAmount =
              double.parse(_textMontantPaie.text.replaceAll(",", "."));
        }
        if (selectedCompte != null) {
          if (_lastMontantPaie == 0) {
            double checkedAmount =
                double.parse(selectedFacture.factureMontant) - inputAmount;
            if (checkedAmount.isNegative) {
              XDialog.showErrorMessage(
                context,
                message:
                    "Le montant de paiement saisi dépasse le frais de la facture sélectionné !",
              );
              return;
            }
            var paiement = Operations(
              operationCompteId: selectedCompte.compteId,
              operationDevise: selectedDevise,
              operationFactureId: selectedFacture.factureId,
              operationLibelle: "Paiement facture",
              operationMontant: inputAmount,
              operationType: "Entrée",
              operationUserId: currentUserId,
              operationMode: selectedMode,
            );
            var lastInsertedOperationId =
                await NativeDbHelper.insert("operations", paiement.toMap());
            if (lastInsertedOperationId != null) {
              if (checkedAmount == 0) {
                await NativeDbHelper.update(
                  "factures",
                  {'facture_statut': 'paie'},
                  where: "facture_id",
                  whereArgs: [selectedFacture.factureId],
                );
              }
              setState(() {
                selectedFacture = null;
                selectedPaieInfos = null;
                _textMontantPaie.text = "";
                XDialog.showSuccessAnimation(context);
                _cleanFields();
                initData();
              });
            }
          } else {
            double _factureMontant =
                double.parse(selectedFacture.factureMontant);
            double _restToPaie = _factureMontant - _lastMontantPaie;
            double _checkedAmount = _restToPaie - inputAmount;
            if (_checkedAmount.isNegative) {
              XDialog.showErrorMessage(
                context,
                message:
                    "Le montant de paiement saisi dépasse le frais restant de la facture sélectionnée !",
              );
              return;
            }

            var paiement = Operations(
              operationCompteId: selectedCompte.compteId,
              operationDevise: selectedDevise,
              operationFactureId: selectedFacture.factureId,
              operationLibelle: "Paiement facture",
              operationMontant: inputAmount,
              operationType: "Entrée",
              operationUserId: currentUserId,
              operationMode: selectedMode,
            );
            var lastInsertedOperationId =
                await NativeDbHelper.insert("operations", paiement.toMap());
            if (lastInsertedOperationId != null) {
              if (_checkedAmount == 0) {
                await NativeDbHelper.update(
                  "factures",
                  {'facture_statut': 'paie'},
                  where: "facture_id",
                  whereArgs: [selectedFacture.factureId],
                );
              }
              setState(() {
                selectedFacture = null;
                selectedPaieInfos = null;
                XDialog.showSuccessAnimation(context);
              });
              _cleanFields();
              initData();
            }
          }
        } else {
          XDialog.showErrorMessage(
            context,
            message:
                "Vous devez sélectionner le compte dans lequel le paiement sera versé !",
          );
          return;
        }
      } catch (err) {
        XDialog.showErrorMessage(
          context,
          message: "Une erreur a été détectée, veuillez réessayer SVP !",
        );
      }
    }
  }

  void _filterCostumer(String value) async {
    if (value != null && value.isNotEmpty) {
      List<Client> searchedClients = [];
      var founded = await NativeDbHelper.rawQuery(
          "SELECT * FROM clients INNER JOIN factures ON clients.client_id = factures.facture_client_id  WHERE factures.facture_statut = 'en attente'  AND NOT clients.client_state='deleted' AND factures.facture_montant > 0 AND clients.client_nom LIKE '%$value%'");
      dataController.clientFactures.clear();
      searchedClients.clear();
      founded.forEach((e) {
        searchedClients.add(Client.fromMap(e));
      });
      dataController.clientFactures.addAll(searchedClients);
    } else {
      dataController.loadClientFactures();
    }
  }
}

class PaieDetailsCard extends StatelessWidget {
  final Operations data;
  final Function onCleared;
  const PaieDetailsCard({Key key, this.data, this.onCleared}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: data.operationId.isEven ? Colors.pink : Colors.blue,
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
                  data.operationDate,
                  style: GoogleFonts.didactGothic(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data.operationFactureId}",
                  style: GoogleFonts.didactGothic(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data.facture.factureMontant} ${data.facture.factureDevise}",
                  style: GoogleFonts.didactGothic(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
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
                  "${data.operationMontant} ${data.operationDevise}",
                  style: GoogleFonts.didactGothic(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<double>(
            future: countRest(data.operationMontant, data.operationFactureId),
            initialData: 0.0,
            builder: (context, snapshot) {
              return Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${snapshot.data} ${data.facture.factureDevise}",
                      style: GoogleFonts.didactGothic(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.operationMode,
                  style: GoogleFonts.didactGothic(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
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
                    data.client.clientNom,
                    style: GoogleFonts.didactGothic(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (authController.loggedUser.value.userRole == "Administrateur") ...[
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedBtn(
                    icon: CupertinoIcons.trash,
                    color: Colors.red,
                    onPressed: onCleared,
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<double> countRest(double amount, int id) async {
    var paieInfos = await NativeDbHelper.rawQuery(
        "SELECT * FROM operations INNER JOIN factures ON operations.operation_facture_id = factures.facture_id WHERE operations.operation_facture_id = '$id' AND NOT operations.operation_state='deleted' AND NOT factures.facture_state='deleted'");
    List<Operations> operations = [];
    if (paieInfos != null) {
      paieInfos.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      if (operations.isNotEmpty) {
        double amountsPaymnt = 0;
        for (var data in operations) {
          amountsPaymnt += data.operationMontant;
        }
        double restToPay =
            double.parse(operations.first.facture.factureMontant) -
                amountsPaymnt;
        return double.parse(restToPay.toStringAsFixed(2));
      } else {
        double restToPay =
            double.parse(operations.last.facture.factureMontant) - amount;
        return double.parse(restToPay.toStringAsFixed(2));
      }
    } else {
      return 0;
    }
  }
}

class DetailFactureCard extends StatelessWidget {
  final Facture data;
  final Function onPressed;
  const DetailFactureCard({
    Key key,
    this.data,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200],
                    width: .5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 5.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.money_dollar_circle_fill,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Facture N° ${data.factureId}",
                          style: GoogleFonts.didactGothic(
                            color: primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      color: Colors.pink[200],
                      onPressed: onPressed,
                      child: const Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.black,
                        size: 16.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FieldInfo extends StatelessWidget {
  final String value, title;
  const FieldInfo({
    Key key,
    this.value,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.0,
                  color: Colors.grey.withOpacity(.3),
                  offset: Offset.zero,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "$title  | ",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "$value ",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

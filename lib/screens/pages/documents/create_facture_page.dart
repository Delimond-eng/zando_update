import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/index.dart';
import 'package:zando/models/client.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/facture_detail.dart';
import 'package:zando/services/db_manager.dart';
import 'package:zando/services/native_db_helper.dart';
import 'package:zando/services/print_service.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/client_card.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_input.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker_component.dart';
import 'package:zando/widgets/input_text.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/page_header.dart';
import 'package:zando/widgets/rounded_btn.dart';

import '../printing_viewer.dart';
import 'package:pdf/pdf.dart';

class CreateFacturePage extends StatefulWidget {
  const CreateFacturePage({Key key}) : super(key: key);

  @override
  State<CreateFacturePage> createState() => _CreateFacturePageState();
}

class _CreateFacturePageState extends State<CreateFacturePage> {
  final ScrollController _clientScroller = ScrollController();
  String selectedDate;

  List<FactureDetail> factureDetails = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
    dataController.refreshDatas();
  }

  initData() async {
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    setState(() {
      selectedDate = dateToString(now);

      for (var e in dataController.clients) {
        if (e.isSelected) {
          e.isSelected = false;
        }
      }
    });
  }

  //field
  final _textLibelle = TextEditingController();
  final _textQuantite = TextEditingController();
  final _textPrix = TextEditingController();
  int dateTimestamp;

  int _selectedClientId;
  int _selectedFactureId;

  double _factureTotal = 0.0;

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: "Création Facture",
            leadingIcon: "assets/icons/add_doc.svg",
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFactureCreating(context),
                        _buildFactureDetails(context)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFactureCreating(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 70.0,
              width: double.infinity,
              child: Card(
                elevation: 2,
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Client concerné & date de création".toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            DatePickerComponent(
              date: selectedDate,
              onSelectedDate: () async {
                int date = await showDatePicked(context);
                DateTime parsedDate = parseTimestampToDate(date);
                setState(() {
                  selectedDate = dateToString(parsedDate);
                  dateTimestamp = date;
                });
              },
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Card(
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(5.0),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Sélectionnez le client concerné par la facture !",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: CostumInput(
                          hintText: "Filtrez client...",
                          onTextChanged: (value) async {
                            if (value != null && value.isNotEmpty) {
                              List<Client> searchedClient = [];
                              var clients = await NativeDbHelper.rawQuery(
                                  "SELECT * FROM clients WHERE client_nom LIKE '%$value%' AND NOT client_state='deleted'");
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
                          icon: CupertinoIcons.search,
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          return dataController.clients.isEmpty
                              ? Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(40.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.red,
                                          ),
                                        ),
                                        child: const Text(
                                          "Aucune facture en attente paiement trouvée !",
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
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Scrollbar(
                                    controller: _clientScroller,
                                    isAlwaysShown: true,
                                    radius: const Radius.circular(10.0),
                                    thickness: 10.0,
                                    child: SingleChildScrollView(
                                      controller: _clientScroller,
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          for (int i = 0;
                                              i < dataController.clients.length;
                                              i++) ...[
                                            ClientCard(
                                              data: dataController.clients[i],
                                              onSelected: () {
                                                if (_selectedFactureId !=
                                                    null) {
                                                  XDialog.showErrorMessage(
                                                    context,
                                                    message:
                                                        "Désolé! vous avez déjà une facture en cours...",
                                                  );
                                                  return;
                                                } else {
                                                  var data =
                                                      dataController.clients[i];
                                                  for (var e in dataController
                                                      .clients) {
                                                    if (e.isSelected) {
                                                      e.isSelected = false;
                                                    }
                                                  }
                                                  setState(() {
                                                    data.isSelected = true;
                                                    _selectedClientId =
                                                        data.clientId;
                                                  });
                                                }
                                              },
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                        }),
                      ),
                      if (_selectedClientId != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: CostumBtn(
                            color: Colors.green[700],
                            icon: Icons.add,
                            label: "Créer",
                            onPressed: () async {
                              Facture facture = Facture(
                                factureCreateAt: dateTimestamp,
                                factureClientId: _selectedClientId,
                                factureDevise: "USD",
                                factureStatut: "en attente",
                                factureMontant: "0",
                              );

                              int lastInsertedFacture =
                                  await NativeDbHelper.insert(
                                "factures",
                                facture.toMap(),
                              );

                              if (lastInsertedFacture != null) {
                                await NativeDbHelper.delete(
                                  "operations",
                                  where: "operation_facture_id = ?",
                                  whereArgs: [lastInsertedFacture],
                                );
                                setState(() {
                                  _selectedFactureId = lastInsertedFacture;
                                  _selectedClientId = null;
                                });
                                for (var e in dataController.clients) {
                                  if (e.isSelected) {
                                    e.isSelected = false;
                                  }
                                }
                              }
                            },
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String selectedDevise = "USD";
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  Widget _buildFactureDetails(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70.0,
              width: double.infinity,
              child: Card(
                color: primaryColor,
                elevation: 2,
                child: Center(
                  child: Text(
                    "Détails facture".toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            if (_selectedFactureId != null)
              Container(
                child: Card(
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InputText(
                                        hintText: "Entrez la désignation...",
                                        title: "Désignation",
                                        errorText: "Désignation requise !",
                                        controller: _textLibelle,
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              children: [
                                                InputText(
                                                  hintText:
                                                      "Entrez la quantité. ex: 1",
                                                  title: "Quantité",
                                                  errorText:
                                                      "Quantité requise !",
                                                  controller: _textQuantite,
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                InputText(
                                                  hintText:
                                                      "Entrez le prix unitaire...",
                                                  title: "Prix unitaire",
                                                  errorText:
                                                      "Prix unitaire requis !",
                                                  controller: _textPrix,
                                                  suffixChild: _deviseViewer(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          TileIconBtn(
                                            icon: Icons.add,
                                            color: Colors.blue,
                                            iconSize: 20.0,
                                            onPressed: () =>
                                                addItemToFacture(context),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Flexible(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 20.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: "Facture N° :  ",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "$_selectedFactureId",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 30.0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      FacDetailField(
                                        title: "TOTAL CUMULE : ",
                                        value: "$_factureTotal ",
                                        currency: "USD",
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      FacDetailField(
                                        title: "EQUIVALENT EN CDF : ",
                                        value:
                                            "${convertDollarsToCdf(_factureTotal)}",
                                        currency: "CDF",
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: CostumBtn(
                                              icon: CupertinoIcons.printer,
                                              color: Colors.green,
                                              label: "Imprimer",
                                              onPressed: () =>
                                                  _loadPrinting(context),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            Expanded(
              flex: 8,
              child: _selectedFactureId == null
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(60.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                            ),
                            child: const Text(
                              "Veuillez créer une facture pour ajouter des détails !",
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
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: Card(
                        elevation: 2.0,
                        child: factureDetails.isEmpty
                            ? const Center(
                                child: Text(
                                  "Veuillez ajouter des détails à cette facture !",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 18.0),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60.0,
                                    width: double.infinity,
                                    margin: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 0),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 8.0,
                                      ),
                                      child: CustomTableHeader(
                                        haveActionsButton: true,
                                        items: [
                                          "N°",
                                          "Désignation",
                                          "Quantité",
                                          "P.U",
                                          "Devise",
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
                                        padding: const EdgeInsets.all(15.0),
                                        physics: const BouncingScrollPhysics(),
                                        child: _customDataTable(context),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _customDataTable(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < factureDetails.length; i++) ...[
          ItemCard(
            numOrder: i + 1,
            label: factureDetails[i].factureDetailLibelle,
            price: factureDetails[i].factureDetailPu,
            qty: "${factureDetails[i].factureDetailQte}",
            currency: factureDetails[i].factureDetailDevise,
            onDeleted: () async {
              XDialog.show(
                  context: context,
                  icon: Icons.help,
                  title: "Suppression détails facture",
                  content:
                      "Etes-vous sûr de vouloir supprimer ce détail de la facture ?",
                  onValidate: () async {
                    var db = await DbHelper.initDb();
                    int lastDeletedDetail = await db.rawUpdate(
                        "UPDATE facture_details SET facture_detail_state= ? WHERE facture_detail_id= ?",
                        ["deleted", factureDetails[i].factureDetailId]);
                    await Synchroniser.inPutData();
                    if (lastDeletedDetail != null) {
                      viewDetails();
                      await dataController.deleteUnavailableData();
                    }
                  });
            },
          ),
        ]
      ],
    );
  }

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

  Future<void> addItemToFacture(BuildContext ctx) async {
    var db = await DbHelper.initDb();
    if (_formKey.currentState.validate()) {
      if (_selectedFactureId != null) {
        try {
          FactureDetail details = FactureDetail(
            factureDetailLibelle: _textLibelle.text,
            factureDetailPu: _textPrix.text,
            factureDetailQte: int.parse(_textQuantite.text),
            factureDetailDevise: selectedDevise,
            factureId: _selectedFactureId,
          );
          int lastDetailId = await db.insert(
            "facture_details",
            details.toMap(),
          );
          //print(lastDetailId);
          if (lastDetailId != null) {
            await viewDetails();
            await cleanFields();
          }
        } catch (e) {
          XDialog.showErrorMessage(ctx,
              message:
                  "Une erreur est survenue lors de l'envoi de données, veuillez réessayer svp !");
        }
      }
    }
  }

  viewDetails() async {
    var db = await DbHelper.initDb();
    var allDetails = await db.rawQuery(
        "SELECT * FROM facture_details WHERE facture_id='$_selectedFactureId' AND NOT facture_detail_state='deleted' ORDER BY facture_detail_id DESC");
    if (allDetails != null) {
      factureDetails.clear();
      double total = 0;
      setState(() {
        allDetails.forEach((e) {
          factureDetails.add(FactureDetail.fromMap(e));
        });
        for (var e in factureDetails) {
          if (e.factureDetailDevise.trim() == "CDF".trim()) {
            total += e.factureDetailQte *
                convertCdfToDollars(double.parse(e.factureDetailPu));
          } else {
            total += e.factureDetailQte * double.parse(e.factureDetailPu);
          }
        }
        _factureTotal = total;
      });
      await updateFactureAmount();
    }
  }

  updateFactureAmount() async {
    var db = await DbHelper.initDb();
    Facture facture = Facture(
      factureMontant: _factureTotal.toString(),
    );
    var lastUpdatedId = await db.update(
      "factures",
      facture.toMap(),
      where: "facture_id=?",
      whereArgs: [_selectedFactureId],
    );
    if (lastUpdatedId != null) {
      await dataController.loadFacturesEnAttente();
    }
  }

  cleanFields() {
    setState(() {
      _textLibelle.text = "";
      _textPrix.text = "";
      _textQuantite.text = "";
      selectedDevise = "USD";
    });
  }

  _loadPrinting(BuildContext context) async {
    Xloading.showLottieLoading(context);
    var invoice =
        await DataManager.getFactureInvoice(factureId: _selectedFactureId);
    if (invoice != null) {
      PdfPageFormat pageFormat = PdfPageFormat.standard;
      PrintingBuilder printPdf = PrintingBuilder(invoice: invoice);
      var bytesPdf = await printPdf.buildPdf(pageFormat);
      Xloading.dismiss();
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: PrintingViewer(
            bytes: bytesPdf,
          ),
        ),
      );
      await Synchroniser.inPutData();
      setState(() {
        _selectedClientId = null;
        _selectedFactureId = null;
      });
    }
  }
}

class FacDetailField extends StatelessWidget {
  final String title;
  final String value;
  final String currency;
  const FacDetailField({
    Key key,
    this.title,
    this.value,
    this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              )
            ],
          ),
        ),
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 30.0,
                      ),
                    ),
                    TextSpan(
                      text: currency,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    Key key,
    this.numOrder,
    this.label,
    this.qty,
    this.price,
    this.currency,
    this.onDeleted,
  }) : super(key: key);

  final String label, qty, price, currency;
  final int numOrder;
  final Function onDeleted;

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
            color: numOrder.isEven ? Colors.blue : Colors.pink,
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
                  "$numOrder",
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
                    label,
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
                  qty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w400,
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
                  price,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
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
                  currency,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.pink,
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
                  icon: CupertinoIcons.clear,
                  color: Colors.pink[200],
                  onPressed: onDeleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TileIconBtn extends StatelessWidget {
  const TileIconBtn({
    Key key,
    this.onPressed,
    this.icon,
    this.color,
    this.iconSize,
  }) : super(key: key);
  final Function onPressed;
  final IconData icon;
  final Color color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      width: 120.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color ?? Colors.green, color ?? Colors.lightGreen],
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Colors.black.withOpacity(.3),
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize ?? 40.0,
          ),
        ),
      ),
    );
  }
}

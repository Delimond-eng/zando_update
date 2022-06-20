import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/facture_detail.dart';
import 'package:zando/models/operation.dart';
import 'package:zando/screens/pages/documents/create_facture_page.dart';
import 'package:zando/screens/pages/printing_viewer.dart';
import 'package:zando/services/db_manager.dart';
import 'package:zando/services/print_service.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:pdf/pdf.dart';

import 'modal.dart';
import 'style.dart';
import 'utils.dart';

viewFactureDetail(BuildContext ctx,
    {Facture facture, List<FactureDetail> details}) async {
  final ScrollController _modalScrollController = ScrollController();
  var db = await DbHelper.initDb();

  var paieInfos = await db.rawQuery(
      "SELECT * FROM operations INNER JOIN factures ON operations.operation_facture_id = factures.facture_id WHERE operations.operation_facture_id = '${facture.factureId}'");
  List<Operations> operations = [];
  double amountsPaymnt = 0;
  if (paieInfos != null) {
    paieInfos.forEach((e) {
      operations.add(Operations.fromMap(e));
    });
    if (operations.isNotEmpty) {
      for (var data in operations) {
        amountsPaymnt += data.operationMontant;
      }
    }
  }
  Modal.show(
    ctx,
    height: MediaQuery.of(ctx).size.height * .7,
    width: MediaQuery.of(ctx).size.width * .8,
    modalContent: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                height: 163.0,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(
                                  5.0,
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
                                  facture.client.clientNom,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blue,
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
                                        text: facture.client.clientAdresse,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.0,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "Téléphone :  ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.0,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: facture.client.clientTel,
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
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Flexible(
              child: Container(
                child: Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                text: facture.factureClientId.toString(),
                                style: TextStyle(
                                  color: Theme.of(ctx).primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30.0,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        FacDetailField(
                          title: "TOTAL CUMULE : ",
                          value: facture.factureMontant,
                          currency: facture.factureDevise,
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        FacDetailField(
                          title: "EQUIVALENT EN CDF : ",
                          value: convertDollarsToCdf(
                                  double.parse(facture.factureMontant))
                              .toString(),
                          currency: "CDF",
                        ),
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
              child: Container(
                width: double.infinity,
                child: Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Paiement facture informations",
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        FacDetailField(
                          title: "Montant payé : ",
                          value: "$amountsPaymnt ",
                          currency: "  ${facture.factureDevise}",
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        FacDetailField(
                          title: "Restes à payér : ",
                          value:
                              "${double.parse(facture.factureMontant) - amountsPaymnt}",
                          currency: "  ${facture.factureDevise}",
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 60.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: CustomTableHeader(
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
                  isAlwaysShown: true,
                  radius: const Radius.circular(10.0),
                  thickness: 10.0,
                  controller: _modalScrollController,
                  child: SingleChildScrollView(
                    controller: _modalScrollController,
                    child: Column(
                      children: [
                        for (int i = 0; i < details.length; i++) ...[
                          ModalItemCard(
                            label: details[i].factureDetailLibelle,
                            numOrder: i + 1,
                            price: details[i].factureDetailPu,
                            qty: details[i].factureDetailQte.toString(),
                            currency: details[i].factureDetailDevise,
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
        const SizedBox(
          height: 5.0,
        ),
        Row(
          children: [
            Container(
              width: 200,
              child: CostumBtn(
                icon: CupertinoIcons.printer,
                color: Colors.green,
                label: "Imprimer",
                onPressed: () async {
                  Xloading.showLottieLoading(ctx);
                  var invoice = await DataManager.getFactureInvoice(
                      factureId: facture.factureId);
                  if (invoice != null) {
                    PdfPageFormat pageFormat = PdfPageFormat.standard;
                    PrintingBuilder printPdf =
                        PrintingBuilder(invoice: invoice);
                    var bytesPdf = await printPdf.buildPdf(pageFormat);
                    Xloading.dismiss();
                    Navigator.push(
                      ctx,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: PrintingViewer(
                          bytes: bytesPdf,
                        ),
                      ),
                    );
                    await Synchroniser.inPutData();
                  }
                },
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Container(
              width: 200,
              child: CostumBtn(
                icon: CupertinoIcons.clear_circled_solid,
                color: Colors.grey,
                label: "Fermer",
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        )
      ],
    ),
  );
}

class ModalItemCard extends StatelessWidget {
  const ModalItemCard({
    Key key,
    this.numOrder,
    this.label,
    this.qty,
    this.price,
    this.currency,
  }) : super(key: key);

  final String label, qty, price, currency;
  final int numOrder;

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
        ],
      ),
    );
  }
}

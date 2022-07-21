import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zando/global/controllers.dart';
import 'package:zando/global/data.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/models/facture.dart';
import 'package:zando/models/facture_detail.dart';
import 'package:zando/services/native_db_helper.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_input.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker.dart';
import 'package:zando/widgets/facture_table_content.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/user_session_card.dart';

class FacturesView extends StatefulWidget {
  const FacturesView({Key key, this.title, this.filterKey = ""})
      : super(key: key);
  final String title;
  final String filterKey;

  @override
  State<FacturesView> createState() => _FacturesViewState();
}

class _FacturesViewState extends State<FacturesView> {
  final ScrollController _scrollController = ScrollController();

  List<Facture> factureList = [];
  int selectedDate;
  int dateNow;

  @override
  void initState() {
    super.initState();
    initData();
    refreshData();
  }

  initData() {
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    setState(() {
      dateNow = now.microsecondsSinceEpoch;
    });
  }

  bool isLoading = false;
  refreshData() async {
    setState(() {
      isLoading = !isLoading;
    });

    try {
      Future.delayed(const Duration(milliseconds: 500), () async {
        var jsonData;
        switch (widget.filterKey) {
          case "today":
            jsonData = await NativeDbHelper.rawQuery(
                "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_create_At = '$dateNow' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted' ORDER BY factures.facture_id DESC");
            break;
          case "en attente":
            jsonData = await NativeDbHelper.rawQuery(
                "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_statut = 'en attente' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted' ORDER BY factures.facture_id DESC");
            break;
          case "paie":
            jsonData = await NativeDbHelper.rawQuery(
                "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_statut = 'paie' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted' ORDER BY factures.facture_id DESC");
            break;
          default:
            jsonData = await NativeDbHelper.rawQuery(
                "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted' ORDER BY factures.facture_id DESC");
        }

        if (jsonData != null) {
          factureList.clear();
          setState(() {
            isLoading = !isLoading;
            jsonData.forEach((e) {
              factureList.add(Facture.fromMap(e));
            });
          });
        }
      });
    } catch (e) {
      print("error from $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    child: CostumInput(
                      hintText: "Recherchez la facture de client...",
                      icon: CupertinoIcons.search,
                      onTextChanged: (value) async {
                        if (value != null && value.isNotEmpty) {
                          List<Facture> searchedFactures = [];
                          var founded;
                          switch (widget.filterKey) {
                            case "today":
                              founded = await NativeDbHelper.rawQuery(
                                  "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_create_At = '$dateNow' AND clients.client_nom LIKE '%$value%' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'");
                              break;
                            case "en attente":
                              founded = await NativeDbHelper.rawQuery(
                                  "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_statut = 'en attente' AND clients.client_nom LIKE '%$value%' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'");
                              break;
                            case "paie":
                              founded = await NativeDbHelper.rawQuery(
                                  "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_statut = 'paie' AND clients.client_nom LIKE '%$value%' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'");
                              break;
                            default:
                              founded = await NativeDbHelper.rawQuery(
                                  "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE clients.client_nom LIKE '%$value%' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted'");
                          }

                          if (founded != null) {
                            factureList.clear();
                            setState(() {
                              searchedFactures.clear();
                              founded.forEach((e) {
                                searchedFactures.add(Facture.fromMap(e));
                              });
                              factureList.addAll(searchedFactures);
                            });
                          }
                        } else {
                          refreshData();
                        }
                      },
                    ),
                  ),
                ),
                if (widget.filterKey.isEmpty) ...[
                  const SizedBox(
                    width: 20.0,
                  ),
                  CustomDatePicker(
                    date: selectedDate != null
                        ? strDateLongFr(
                            dateToString(parseTimestampToDate(selectedDate)))
                        : null,
                    onCleared: () {
                      setState(() {
                        selectedDate = null;
                      });
                      refreshData();
                    },
                    onShownDatePicker: () async {
                      int date = await showDatePicked(context);

                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });

                        List<Facture> searchedFactures = [];
                        var founded = await NativeDbHelper.rawQuery(
                            "SELECT * FROM factures INNER JOIN clients ON factures.facture_client_id = clients.client_id WHERE factures.facture_create_At = '$date' AND NOT factures.facture_state='deleted' AND NOT clients.client_state='deleted' ORDER BY factures.facture_id DESC");

                        factureList.clear();
                        setState(() {
                          searchedFactures.clear();
                          founded.forEach((e) {
                            searchedFactures.add(Facture.fromMap(e));
                          });
                          factureList.addAll(searchedFactures);
                        });
                      }
                    },
                  )
                ]
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15.0,
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
                                "Date",
                                "N° facture",
                                "Montant facture",
                                "Client Concerné",
                                "status",
                                ""
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: factureList.isEmpty
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
                                          "Aucune information répertoriée !",
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
                                  controller: _scrollController,
                                  radius: const Radius.circular(10.0),
                                  isAlwaysShown: true,
                                  thickness: 10.0,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: _factureTable(context),
                                  ),
                                ),
                        )
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _factureTable(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < factureList.length; i++) ...[
          TableContentCard(
            numOrder: i,
            data: factureList[i],
            onViewed: () async {
              var allDetails = await NativeDbHelper.query(
                "facture_details",
                where: "facture_id",
                whereArgs: [factureList[i].factureId],
              );
              if (allDetails != null) {
                List<FactureDetail> details = [];
                allDetails.forEach((e) {
                  details.add(FactureDetail.fromMap(e));
                });
                viewFactureDetail(
                  context,
                  details: details,
                  facture: factureList[i],
                );
              }
            },
            onDeleted: () {
              XDialog.show(
                context: context,
                content:
                    "Etes-vous sûr de vouloir supprimer cette facture en cours ?",
                icon: Icons.help,
                title: "Suppression facture en cours !",
                onValidate: () async {
                  var db = await DbHelper.initDb();
                  var facture = factureList[i];
                  var lastDeletedId = await db.rawUpdate(
                      "UPDATE factures SET facture_state = ? WHERE facture_id = ?",
                      ["deleted", facture.factureId]);
                  if (lastDeletedId != null) {
                    await db.rawUpdate(
                      "UPDATE facture_details SET facture_detail_state= ? WHERE facture_id= ?",
                      ["deleted", facture.factureId],
                    );
                    await Synchroniser.inPutData();
                    await dataController.deleteUnavailableData();
                    refreshData();
                  }
                },
              );
            },
          ),
        ]
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 90.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 10.0,
      ),
      margin: const EdgeInsets.only(bottom: 20.0),
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
                "assets/icons/Documents.svg",
                height: 30.0,
                width: 30.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                widget.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const UserSessionCard()
        ],
      ),
    );
  }
}

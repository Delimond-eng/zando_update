// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/models/operation.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/page_header.dart';

class DetailsOperationPage extends StatefulWidget {
  const DetailsOperationPage({Key key}) : super(key: key);

  @override
  State<DetailsOperationPage> createState() => _DetailsOperationPageState();
}

class _DetailsOperationPageState extends State<DetailsOperationPage> {
  final _scrollController = ScrollController();
  int _startDate;
  int _endDate;

  List<Operations> operations = [];
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    var db = await DbHelper.initDb();
    var allDatas = await db.rawQuery(
        "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE NOT operations.operation_state='deleted' AND NOT comptes.compte_state='deleted' ORDER BY operations.operation_id DESC ");
    if (allDatas != null) {
      operations.clear();
      setState(() {
        allDatas.forEach((e) {
          operations.add(Operations.fromMap(e));
        });
      });
    }
  }

  Future<void> _filterByDate(BuildContext context) async {
    var db = await DbHelper.initDb();
    if (_startDate == null && _endDate == null) {
      XDialog.showErrorMessage(
        context,
        message:
            "Veuillez entrer au moins une date pour filtrer les opérations !",
      );
      return;
    }

    var allDatas;
    if (_startDate != null && _endDate == null) {
      allDatas = await db.rawQuery(
          "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE  operations.operation_create_At = '$_startDate' AND NOT operations.operation_state='deleted' AND NOT comptes.compte_state='deleted' ORDER BY operations.operation_id DESC ");
    } else if (_endDate != null && _startDate == null) {
      allDatas = await db.rawQuery(
          "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE operations.operation_create_At = '$_endDate' AND NOT operations.operation_state='deleted' AND NOT comptes.compte_state='deleted' ORDER BY operations.operation_id DESC ");
    } else {
      if (_startDate > _endDate) {
        XDialog.showErrorMessage(
          context,
          message: "Les dates sont mal ordonnées !",
        );
        return;
      }
      allDatas = await db.rawQuery(
          "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE operations.operation_create_At BETWEEN '$_startDate' AND '$_endDate' AND NOT operations.operation_state='deleted' AND NOT comptes.compte_state='deleted' ORDER BY operations.operation_id DESC ");
    }
    if (allDatas != null) {
      /*var filters = operations.where(
        (data) =>
            data.operationDate
                .contains(dateToString(parseTimestampToDate(_endDate))) ||
            data.operationDate
                .contains(dateToString(parseTimestampToDate(_startDate))),
      );
      
      //todo: this
      filters.forEach((e) {
        operations.add(e);
      });
      */
      operations.clear();
      allDatas.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        children: [
          const PageHeader(
            bottomPadding: 0.0,
            leadingIcon: "assets/icons/subscription.svg",
            title: "Plus d'opérations sur les comptes",
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  child: Row(
                    children: [
                      CustomDatePicker(
                        date: _startDate != null
                            ? strDateLongFr(
                                dateToString(parseTimestampToDate(_startDate)))
                            : null,
                        onShownDatePicker: () async {
                          var date = await showDatePicked(context);
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                        onCleared: () {
                          setState(() {
                            _startDate = null;
                          });
                          initData();
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        height: 2,
                        width: 5,
                        color: primaryColor,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomDatePicker(
                        date: _endDate != null
                            ? strDateLongFr(
                                dateToString(parseTimestampToDate(_endDate)))
                            : null,
                        onShownDatePicker: () async {
                          var date = await showDatePicked(context);
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                        onCleared: () {
                          setState(() {
                            _endDate = null;
                          });
                          initData();
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      RaisedButton.icon(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        color: Colors.orange[800],
                        icon: const Icon(Icons.filter_alt_rounded,
                            color: Colors.white),
                        label: Text(
                          "Filter".toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _filterByDate(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: CustomTableHeader(
                      items: [
                        "Date",
                        "Type opération",
                        "Motif opération",
                        "Montant opération",
                        "Compte",
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
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: Column(
                          children: operations.map((data) {
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
                                color: (data.operationType.trim() ==
                                        "Entrée".trim())
                                    ? Colors.green
                                    : Colors.red,
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
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: (data.operationType.trim() ==
                                                "Entrée".trim())
                                            ? Colors.green[800]
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.operationType,
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color: (data.operationType.trim() ==
                                                  "Entrée".trim())
                                              ? Colors.green[800]
                                              : Colors.red),
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
                                      data.operationLibelle,
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color: (data.operationType.trim() ==
                                                  "Entrée".trim())
                                              ? Colors.green[800]
                                              : Colors.red),
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
                                    Row(
                                      children: [
                                        Icon(
                                          (data.operationType.trim() ==
                                                  "Entrée".trim())
                                              ? Icons.arrow_upward_outlined
                                              : Icons.arrow_downward_outlined,
                                          color: (data.operationType.trim() ==
                                                  "Entrée".trim())
                                              ? Colors.green[800]
                                              : Colors.red,
                                        ),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          "${data.operationMontant}  ${data.operationDevise}",
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  (data.operationType.trim() ==
                                                          "Entrée".trim())
                                                      ? Colors.green[800]
                                                      : Colors.red),
                                        ),
                                      ],
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
                                      data.compte.compteLibelle,
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

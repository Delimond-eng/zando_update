// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/index.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/models/operation.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker.dart';

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({Key key}) : super(key: key);

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  int _startDate;
  int _endDate;
  final _scrollController = ScrollController();
  final _scrollComptesController = ScrollController();

  List<Operations> operations = [];
  Compte _selectedCompte;
  double _compteSommeEntree = 0;
  double _compteSommeSortie = 0;
  double get _solde => _compteSommeEntree - _compteSommeSortie;

  @override
  void initState() {
    super.initState();
  }

  _showDetails() async {
    var db = await DbHelper.initDb();
    var datas = await db.rawQuery(
        "SELECT * FROM operations WHERE operation_compte_id = '${_selectedCompte.compteId}' GROUP BY operation_create_At");
    if (datas != null) {
      operations.clear();
      datas.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      setState(() {});
    }
  }

  _filterByDate(BuildContext context) async {
    var db = await DbHelper.initDb();
    var datas;
    if (_startDate != null && _endDate == null) {
      datas = await db.rawQuery(
          "SELECT * FROM operations WHERE operation_compte_id = '${_selectedCompte.compteId}' AND operation_create_At ='$_startDate' GROUP BY operation_create_At");
      _compteSommeEntree = await countSum("Entrée",
          compteId: _selectedCompte.compteId, between: [_startDate]);
      _compteSommeSortie = await countSum("Sortie",
          compteId: _selectedCompte.compteId, between: [_startDate]);
    }
    if (_endDate != null && _startDate == null) {
      datas = await db.rawQuery(
          "SELECT * FROM operations WHERE operation_compte_id = '${_selectedCompte.compteId}' AND operation_create_At ='$_endDate' GROUP BY operation_create_At");
      _compteSommeEntree = await countSum("Entrée",
          compteId: _selectedCompte.compteId, between: [_endDate]);
      _compteSommeSortie = await countSum("Sortie",
          compteId: _selectedCompte.compteId, between: [_endDate]);
    }
    if (_startDate != null && _endDate != null) {
      datas = await db.rawQuery(
          "SELECT * FROM operations WHERE operation_compte_id = '${_selectedCompte.compteId}' AND operation_create_At BETWEEN '$_startDate' AND '$_endDate' GROUP BY operation_create_At");
      _compteSommeEntree = await countSum("Entrée",
          compteId: _selectedCompte.compteId, between: [_startDate, _endDate]);
      _compteSommeSortie = await countSum("Sortie",
          compteId: _selectedCompte.compteId, between: [_startDate, _endDate]);
    }
    if (datas != null) {
      Xloading.showLottieLoading(context);
      Future.delayed(const Duration(milliseconds: 1000));
      Xloading.dismiss();
      operations.clear();
      datas.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Veuillez sélectionner un compte !",
            style: TextStyle(
              color: Colors.red,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Scrollbar(
            controller: _scrollComptesController,
            child: SingleChildScrollView(
              controller: _scrollComptesController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: dataController.comptes.map((data) {
                  return CompteStatCard(
                    data: data,
                    onSelected: () async {
                      for (var e in dataController.comptes) {
                        if (e.isSelected) {
                          e.isSelected = false;
                        }
                      }
                      data.isSelected = !data.isSelected;

                      Xloading.showLottieLoading(context);
                      Future.delayed(const Duration(milliseconds: 1000),
                          () async {
                        _selectedCompte = data;
                        var _sumE = await countSum("Entrée",
                            compteId: _selectedCompte.compteId);
                        var _sumS = await countSum("Sortie",
                            compteId: _selectedCompte.compteId);
                        setState(() {
                          _compteSommeEntree = _sumE;
                          _compteSommeSortie = _sumS;
                        });
                        await _showDetails();
                        Xloading.dismiss();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          if (_selectedCompte != null) ...[
            if (operations.isNotEmpty) ...[
              _detailSection(context)
            ] else ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/lotties/70780-no-result-found.json",
                          width: 200.0,
                          height: 200.0,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Text(
                          "Aucune operation répertoriée pour ce compte  !",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]
          ] else ...[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                  ),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.red,
                          ),
                        ),
                        child: const Text(
                          "Veuillez sélectionner un compte  !",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]
        ],
      );
    });
  }

  Widget _detailSection(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    color: Colors.blue,
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(
                            "Tot. des entrées".toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          if (_selectedCompte.compteDevise == "USD") ...[
                            Text(
                              "$_compteSommeEntree  USD",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 25.0,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "${convertDollarsToCdf(_compteSommeEntree)}  CDF",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 25.0,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    color: Colors.pink,
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(
                            "Tot. des sorties".toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          if (_selectedCompte.compteDevise == "USD") ...[
                            Text(
                              "$_compteSommeSortie  USD",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 25.0,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "${convertDollarsToCdf(_compteSommeSortie)}  CDF",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 25.0,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5.0,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(
                            "Solde".toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          if (_selectedCompte.compteDevise == "USD") ...[
                            Text(
                              "$_solde  USD",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 25.0,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "${convertDollarsToCdf(_solde)}  CDF",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 25.0,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: _filterSection(context),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Container(
                  height: 60.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.green,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: CustomTableHeader(
                      haveActionsButton: true,
                      items: [
                        "Date".toUpperCase(),
                        "Montant Entrée".toUpperCase(),
                        "Montant Sortie".toUpperCase(),
                        "Solde".toUpperCase(),
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
                        top: 10.0,
                      ),
                      child: Column(
                        children: operations.map((data) {
                          return Container(
                            height: 70.0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                            ),
                            margin: const EdgeInsets.only(bottom: 10.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryColor,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.operationDate,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FutureBuilder<double>(
                                  future: countSumForDate(
                                      "Entrée", data.operationTimestamp),
                                  builder: (context, snapshot) {
                                    return Flexible(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.arrow_drop_up_sharp,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          if (_selectedCompte.compteDevise ==
                                              "CDF") ...[
                                            Text(
                                              "${convertDollarsToCdf(snapshot.data)} CDF",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ] else ...[
                                            Text(
                                              "${snapshot.data} USD",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                FutureBuilder<double>(
                                  future: countSumForDate(
                                      "Sortie", data.operationTimestamp),
                                  builder: (context, snapshot) {
                                    return Flexible(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.arrow_drop_down_sharp,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          if (_selectedCompte.compteDevise ==
                                              "CDF") ...[
                                            Text(
                                              "${convertDollarsToCdf(snapshot.data)} CDF",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ] else ...[
                                            Text(
                                              "${snapshot.data} USD",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                FutureBuilder<double>(
                                  future: countSoldeForDate(
                                      data.operationTimestamp),
                                  builder: (context, snapshot) {
                                    return Flexible(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_selectedCompte.compteDevise ==
                                              "CDF") ...[
                                            Text(
                                              "${convertDollarsToCdf(snapshot.data)} CDF",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ] else ...[
                                            Text(
                                              "${snapshot.data} USD",
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FlatButton(
                                        color: Colors.blue,
                                        padding: const EdgeInsets.all(18.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        onPressed: () => _showDetailsOperations(
                                            context,
                                            selectedDate:
                                                data.operationTimestamp),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.arrow_right_alt_outlined,
                                                color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Voir détails",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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

  Widget _filterSection(BuildContext context) {
    return Row(
      children: [
        CustomDatePicker(
          date: _startDate != null
              ? strDateLongFr(dateToString(parseTimestampToDate(_startDate)))
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
              _endDate = null;
            });
            _showDetails();
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
              ? strDateLongFr(dateToString(parseTimestampToDate(_endDate)))
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
              _startDate = null;
            });
            _showDetails();
          },
        ),
        const SizedBox(
          width: 15.0,
        ),
        Container(
          width: 200.0,
          child: RaisedButton.icon(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.all(20.0),
            color: Colors.orange[800],
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
            label: Text(
              "Filter".toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () => _filterByDate(context),
          ),
        ),
      ],
    );
  }

  Future<double> countSum(String type,
      {int compteId, List<int> between}) async {
    var db = await DbHelper.initDb();
    if (compteId == null && between == null) {
      var countDatas = await db.rawQuery(
          "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND NOT operations.operation_state='deleted'");

      if (countDatas.isNotEmpty) {
        if (countDatas.first['count'] == null) {
          return 0;
        }
        double sum = countDatas.first['count'];
        return double.parse(sum.toStringAsFixed(2));
      } else {
        return 0;
      }
    }
    if (compteId != null && between == null) {
      {
        var countDatas = await db.rawQuery(
            "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_compte_id='$compteId' AND NOT operations.operation_state='deleted'");

        if (countDatas.isNotEmpty) {
          if (countDatas.first['count'] == null) {
            return 0;
          }
          double sum = countDatas.first['count'];
          return sum;
        } else {
          return 0;
        }
      }
    }
    if (between != null && compteId != null) {
      if (between.length > 1) {
        var countDatas = await db.rawQuery(
            "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_compte_id='$compteId' AND operation_create_At BETWEEN '${between.first}' AND '${between.last}' AND NOT operations.operation_state='deleted'");

        if (countDatas.isNotEmpty) {
          if (countDatas.first['count'] == null) {
            return 0;
          }
          double sum = countDatas.first['count'];
          return sum;
        } else {
          return 0;
        }
      } else {
        var countDatas = await db.rawQuery(
            "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_compte_id='$compteId' AND operation_create_At ='${between.first}' AND NOT operations.operation_state='deleted'");

        if (countDatas.isNotEmpty) {
          if (countDatas.first['count'] == null) {
            return 0;
          }
          double sum = countDatas.first['count'];
          return sum;
        } else {
          return 0;
        }
      }
    }
  }

  Future<double> countSumForDate(String type, int date) async {
    var db = await DbHelper.initDb();
    var countDatas = await db.rawQuery(
        "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_create_At='$date' AND NOT operations.operation_state='deleted'");

    if (countDatas.isNotEmpty) {
      if (countDatas.first['count'] == null) {
        return 0;
      }
      double sum = countDatas.first['count'];
      return sum;
    } else {
      return 0;
    }
  }

  Future<double> countSoldeForDate(int date) async {
    var db = await DbHelper.initDb();
    var countEntree = await db.rawQuery(
        "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = 'Entrée' AND operation_create_At='$date' AND NOT operations.operation_state='deleted'");
    var countSortie = await db.rawQuery(
        "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = 'Sortie' AND operation_create_At='$date' AND NOT operations.operation_state='deleted'");
    double _entree = 0;
    double _sortie = 0;
    if (countEntree != null && countSortie != null) {
      _entree = countEntree.first['count'] ?? 0;
      _sortie = countSortie.first['count'] ?? 0;
      return _entree - _sortie;
    } else {
      return 0;
    }
  }

  _showDetailsOperations(BuildContext context, {int selectedDate}) async {
    var db = await DbHelper.initDb();
    final scroller = ScrollController();
    List<Operations> datas = [];

    var allDatas = await db.rawQuery(
        "SELECT * FROM operations WHERE operation_create_At='$selectedDate' AND NOT operations.operation_state='deleted'");
    if (allDatas != null) {
      datas.clear();
      allDatas.forEach((e) {
        datas.add(Operations.fromMap(e));
      });
    }

    Modal.show(context,
        height: MediaQuery.of(context).size.height - 120,
        width: MediaQuery.of(context).size.width * .9,
        color: Colors.pink, modalContent: StatefulBuilder(
      builder: (context, setter) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.green,
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
                            items: [
                              "Date",
                              "Libellé / Motif",
                              "Type opération",
                              "Montant",
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: datas.isEmpty
                            ? Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        "Aucune sortie à cette date !",
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
                                controller: scroller,
                                child: SingleChildScrollView(
                                  controller: scroller,
                                  child: Column(
                                    children: datas.map((e) {
                                      return Container(
                                        height: 60.0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        margin:
                                            const EdgeInsets.only(bottom: 10.0),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: e.operationType == "Entrée"
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(.3),
                                              blurRadius: 12.0,
                                              offset: Offset.zero,
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.operationDate,
                                                    style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.operationLibelle,
                                                    style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        e.operationType ==
                                                                "Entrée"
                                                            ? Icons
                                                                .arrow_drop_up
                                                            : Icons
                                                                .arrow_drop_down,
                                                        color:
                                                            e.operationType ==
                                                                    "Entrée"
                                                                ? Colors.green
                                                                : Colors.red,
                                                      ),
                                                      Text(
                                                        e.operationType,
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              e.operationType ==
                                                                      "Entrée"
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${e.operationMontant} ${e.operationDevise}",
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: e.operationType ==
                                                              "Entrée"
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    ));
  }
}

class CompteStatCard extends StatelessWidget {
  final Compte data;
  final Function onSelected;
  const CompteStatCard({
    Key key,
    this.data,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 15.0),
      color: data.isSelected ? Colors.blue : Colors.white,
      elevation: 3.0,
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.compteLibelle,
                  style: TextStyle(
                    color: data.isSelected ? Colors.white : Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

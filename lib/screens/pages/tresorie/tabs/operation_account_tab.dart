// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/index.dart';
import 'package:zando/models/compte.dart';
import 'package:zando/models/operation.dart';
import 'package:zando/screens/pages/tresorie/pages/details_operations_page.dart';
import 'package:zando/services/native_db_helper.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker.dart';
import 'package:zando/widgets/input_text.dart';

class AccountOperationTab extends StatefulWidget {
  const AccountOperationTab({Key key}) : super(key: key);

  @override
  State<AccountOperationTab> createState() => _AccountOperationTabState();
}

class _AccountOperationTabState extends State<AccountOperationTab> {
  String _selectType;
  Compte _selectedCompte;
  final _scrollController = ScrollController();
  int _startDate;
  int _endDate;
  double _totEntree = 0;
  double _totSortie = 0;
  double get _solde => _totEntree - _totSortie;

  //inputs
  final _textMotif = TextEditingController();
  final _textMontantOperation = TextEditingController();

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
    var db = await DbHelper.initDb();
    _totEntree = await countSum('Entrée');
    _totSortie = await countSum('Sortie');
    var allDatas = await db.rawQuery(
        "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id ORDER BY operations.operation_id DESC ");
    if (allDatas != null) {
      operations.clear();
      allDatas.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      setState(() {});
    }
  }

  Future<double> countSum(String type, {int compteId, List<int> dates}) async {
    if (compteId == null && dates == null) {
      var countDatas = await NativeDbHelper.rawQuery(
          "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND NOT operation_state='deleted'");

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

    if (compteId != null && type != null) {
      var countDatas = await NativeDbHelper.rawQuery(
          "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_compte_id='$compteId' AND NOT operation_state='deleted'");

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
    if (dates != null) {
      if (dates.length > 1) {
        var countDatas = await NativeDbHelper.rawQuery(
            "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_create_At BETWEEN '${dates.first}' AND ${dates.last} AND NOT operation_state='deleted'");

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
        var countDatas = await NativeDbHelper.rawQuery(
            "SELECT SUM(operation_montant) as count FROM operations WHERE operation_type = '$type' AND operation_create_At='${dates.first}' AND NOT operation_state='deleted' ");

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _inputSection(context),
            const SizedBox(
              width: 10.0,
            ),
            _counterSection()
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        _listSection(context)
      ],
    );
  }

  Widget _listSection(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomDatePicker(
                          date: _startDate != null
                              ? strDateLongFr(dateToString(
                                  parseTimestampToDate(_startDate)))
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
                              _endDate = null;
                              _startDate = null;
                            });
                            initData();
                          },
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Container(
                          height: 2,
                          width: 5,
                          color: primaryColor,
                        ),
                        const SizedBox(
                          width: 20.0,
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
                              _startDate = null;
                            });
                            initData();
                          },
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        RaisedButton.icon(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 20.0),
                          color: Colors.orange[800],
                          icon: const Icon(
                            Icons.filter_alt_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Filter".toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () => _filterByDate(context),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Colors.blue,
                      iconSize: 40.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: const DetailsOperationPage(),
                          ),
                        );
                      },
                    )
                  ],
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
                      padding: const EdgeInsets.only(top: 10.0),
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
                                      data.operationLibelle,
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
                                          "${double.parse(data.operationMontant.toString()).toStringAsFixed(2)}  ${data.operationDevise}",
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
          ),
        ),
      ),
    );
  }

  Widget _counterSection() {
    return Flexible(
      flex: 4,
      child: Column(
        children: [
          Card(
            elevation: 3.0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 40.0),
              child: Center(
                child: Text(
                  "Situation globale des comptes !".toUpperCase(),
                  style: TextStyle(
                    color: Colors.orange[900],
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5.0,
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Tot. des entrées".toUpperCase(),
                              style: TextStyle(color: Colors.grey[100])),
                          const SizedBox(
                            height: 10.0,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "$_totEntree  ",
                                  style: TextStyle(
                                    color: Colors.grey[100],
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: "USD",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5.0,
                    color: Colors.pink,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Tot. des sorties".toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "$_totSortie  ",
                                  style: TextStyle(
                                    color: Colors.grey[100],
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: " USD",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5.0,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Solde".toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "$_solde  ",
                                  style: TextStyle(
                                    color: Colors.grey[100],
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: "USD",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _inputSection(BuildContext context) {
    return Flexible(
      flex: 8,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.white,
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          height: 55.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons
                                      .arrow_right_arrow_left_square_fill,
                                  color: primaryColor,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Flexible(
                                  child: DropdownButton(
                                    menuMaxHeight: 300,
                                    dropdownColor: Colors.white,
                                    alignment: Alignment.centerRight,
                                    borderRadius: BorderRadius.zero,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    value: _selectType,
                                    underline: const SizedBox(),
                                    hint: const Text(
                                      "Type d'opération",
                                      style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    isExpanded: true,
                                    items: ["Entrée", "Sortie"].map((e) {
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
                                        _selectType = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Flexible(
                        child: Container(
                          height: 55.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.money_dollar_circle_fill,
                                  color: primaryColor,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Obx(
                                  () => Flexible(
                                    child: DropdownButton<Compte>(
                                      menuMaxHeight: 300,
                                      dropdownColor: Colors.white,
                                      alignment: Alignment.centerRight,
                                      borderRadius: BorderRadius.zero,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      value: _selectedCompte,
                                      underline: const SizedBox(),
                                      hint: const Text(
                                        "Compte concerné",
                                        style: TextStyle(
                                          color: Colors.pink,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      isExpanded: true,
                                      items: dataController.comptes.map((e) {
                                        return DropdownMenuItem<Compte>(
                                          value: e,
                                          child: Text(
                                            e.compteLibelle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCompte = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InputText(
                    errorText: "Motif de l'opération requis !",
                    hintText: "Entrez le motif pour cette opération...",
                    icon: CupertinoIcons.pencil,
                    title: "Motif opération",
                    controller: _textMotif,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InputText(
                    errorText: "montant opération requis !",
                    hintText: "Entrez le montant opération du compte. ex. 0",
                    icon: CupertinoIcons.money_dollar,
                    title: "Montant opération",
                    controller: _textMontantOperation,
                    suffixChild: _deviseViewer(),
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
                            icon: CupertinoIcons.checkmark_alt,
                            label: "Valider",
                            onPressed: () => _createOperations(context),
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
                              cleanFields();
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
    );
  }

  cleanFields({String type, Compte c}) {
    _selectType = type;
    _selectedCompte = c;
    setState(() {
      _textMotif.text = "";
      _textMontantOperation.text = "";
    });
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
            onChanged: (value) {},
          ),
        )
      ],
    );
  }

  Future<void> _createOperations(BuildContext context) async {
    var db = await DbHelper.initDb();
    if (_selectType == null) {
      XDialog.showErrorMessage(
        context,
        message:
            "Veuillez sélectionner le type d'opération que vous voulez effectuer(Entrée/Sortie) !",
      );
      return;
    }

    if (_selectedCompte == null) {
      XDialog.showErrorMessage(
        context,
        message: "Veuillez sélectionner un compte !",
      );
      return;
    }

    if (_formKey.currentState.validate()) {
      double operationMontant = 0;
      if (selectedDevise.trim() == "CDF".trim()) {
        operationMontant = convertCdfToDollars(double.parse(
            double.parse(_textMontantOperation.text).toStringAsFixed(2)));
      } else {
        operationMontant = double.parse(_textMontantOperation.text);
      }

      if (_selectType.trim() == "Sortie".trim()) {
        var compteSum =
            await countSum("Entrée", compteId: _selectedCompte.compteId);

        if (operationMontant > compteSum) {
          XDialog.showErrorMessage(
            context,
            message:
                "Le montant entrée est supérieur à la somme du compte sélectionné !",
          );
          return;
        }
      }
      var operation = Operations(
        operationCompteId: _selectedCompte.compteId,
        operationDevise: "USD",
        operationLibelle: _textMotif.text,
        operationMontant: operationMontant,
        operationType: _selectType,
        operationUserId: authController.loggedUser.value.userId,
      );

      var lastInsertedId = await db.insert("operations", operation.toMap());
      if (lastInsertedId != null) {
        initData();
        XDialog.showSuccessAnimation(context);
        await Synchroniser.inPutData();
        cleanFields();
      }
    }
  }

  Future<void> _filterByDate(BuildContext context) async {
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
      allDatas = await NativeDbHelper.rawQuery(
          "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE operations.operation_create_At = '$_startDate' AND NOT operation_state='deleted' AND NOT comptes.compte_state='deleted' ORDER BY operations.operation_id DESC ");
      _totEntree = await countSum('Entrée', dates: [_startDate]);
      _totSortie = await countSum('Sortie', dates: [_startDate]);
    } else if (_endDate != null && _startDate == null) {
      allDatas = await NativeDbHelper.rawQuery(
          "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE operations.operation_create_At = '$_endDate' AND NOT operation_state='deleted' ORDER BY operations.operation_id DESC ");
      _totEntree = await countSum('Entrée', dates: [_endDate]);
      _totSortie = await countSum('Sortie', dates: [_endDate]);
    } else {
      if (_startDate > _endDate) {
        XDialog.showErrorMessage(
          context,
          message: "Les dates sont mal ordonnées !",
        );
        return;
      }
      allDatas = await NativeDbHelper.rawQuery(
          "SELECT * FROM operations INNER JOIN comptes ON operations.operation_compte_id = comptes.compte_id WHERE operations.operation_create_At BETWEEN '$_startDate' AND '$_endDate' AND NOT operation_state='deleted' ORDER BY operations.operation_id DESC ");
      _totEntree = await countSum('Entrée', dates: [_startDate, _endDate]);
      _totSortie = await countSum('Sortie', dates: [_startDate, _endDate]);
    }
    if (allDatas != null) {
      operations.clear();
      allDatas.forEach((e) {
        operations.add(Operations.fromMap(e));
      });
      setState(() {});
    }
  }
}

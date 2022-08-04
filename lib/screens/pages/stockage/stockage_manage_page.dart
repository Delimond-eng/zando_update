import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/global/style.dart';
import 'package:zando/global/utils.dart';
import 'package:zando/index.dart';
import 'package:zando/models/stoks/article.dart';
import 'package:zando/models/stoks/mouvement.dart';
import 'package:zando/models/stoks/stock.dart';
import 'package:zando/services/native_db_helper.dart';
import 'package:zando/services/sqlite_db_helper.dart';
import 'package:zando/services/synchonisation.dart';
import 'package:zando/widgets/custom_button.dart';
import 'package:zando/widgets/custom_input.dart';
import 'package:zando/widgets/custom_table_head.dart';
import 'package:zando/widgets/date_picker.dart';
import 'package:zando/widgets/input_text.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/page_header.dart';
import 'package:zando/widgets/rounded_btn.dart';

class StockageManagePage extends StatefulWidget {
  const StockageManagePage({Key key}) : super(key: key);

  @override
  State<StockageManagePage> createState() => _StockageManagePageState();
}

class _StockageManagePageState extends State<StockageManagePage> {
  @override
  void initState() {
    super.initState();
    dataController.refreshStock();
  }

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Obx(() => Column(
            children: [
              const PageHeader(
                title: "Gestion stock",
                leadingIcon: "assets/icons/drop_box.svg",
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      width: double.infinity,
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: dataController.stocks.isEmpty
                                    ? Text(
                                        "Veuillez créer un nouveau stock de vos articles!",
                                        style: GoogleFonts.didactGothic(
                                          color: primaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ))
                                    : CostumInput(
                                        height: 60.0,
                                        hintText: "Recherche stock article...",
                                        icon: CupertinoIcons.search,
                                        onTextChanged: (value) async {
                                          var allData =
                                              await NativeDbHelper.rawQuery(
                                                  "SELECT * FROM stocks INNER JOIN articles ON stocks.stock_article_id = articles.article_id  WHERE articles.article_libelle LIKE '%$value%' AND NOT stocks.stock_state='deleted' AND NOT articles.article_state='deleted'");
                                          if (allData != null) {
                                            dataController.stocks.clear();
                                            setState(() {
                                              allData.forEach((e) {
                                                dataController.stocks
                                                    .add(Stock.fromMap(e));
                                              });
                                            });
                                          }
                                        },
                                      ),
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                              Container(
                                width: 200.0,
                                child: CostumBtn(
                                  color: Colors.blue,
                                  icon: CupertinoIcons.add,
                                  label: "Création stock",
                                  onPressed: () =>
                                      showCreateStockModal(context),
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
              _stockAddWidget(context),
            ],
          )),
    );
  }

  final ScrollController _scrollController = ScrollController();

  Widget _stockAddWidget(BuildContext context) {
    return Expanded(
      child: Obx(() => Container(
            margin: const EdgeInsets.all(10.0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: dataController.stocks.isEmpty
                    ? Center(
                        child: Text(
                          "Aucun article repertorié dans le stock !",
                          style: GoogleFonts.didactGothic(
                            color: Colors.red,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
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
                                  color: Theme.of(context).primaryColor,
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
                                haveActionsButton: ((authController
                                            .loggedUser.value.userRole ==
                                        "Administrateur"))
                                    ? true
                                    : false,
                                items: const [
                                  "Stock Identifiant",
                                  "Date",
                                  "Libellé article",
                                  "Stock Prix d'achat",
                                  "Stock Quantité",
                                  "Stock status",
                                  "actions"
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
                                  children: dataController.stocks.map((e) {
                                    return StockTableCard(
                                      data: e,
                                      onUsingStock: () {
                                        if (e.stockQte == 0) {
                                          XDialog.showErrorMessage(context,
                                              message:
                                                  "Ce stock est inactif pour l'instant, vous ne devez pas effectuer une sortie !");
                                          return;
                                        } else {
                                          showSortieModal(context, data: e);
                                        }
                                      },
                                      onAddingStock: () =>
                                          showAddStockModal(context, data: e),
                                      onDeleted: () {
                                        XDialog.show(
                                          context: context,
                                          content:
                                              "Etes-vous sûr de vouloir supprimer ce stock ?",
                                          icon: Icons.help,
                                          title:
                                              "Attention, action irréversible !",
                                          onValidate: () async {
                                            var db = await DbHelper.initDb();
                                            var lastDeletedId = await db.rawUpdate(
                                                "UPDATE stocks SET stock_state=? WHERE stock_id=?",
                                                ["deleted", e.stockId]);
                                            if (lastDeletedId != null) {
                                              dataController.refreshStock();
                                            }
                                          },
                                        );
                                      },
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
          )),
    );
  }

  showCreateStockModal(BuildContext context) {
    String selectedDevise = "CDF";
    final _textQte = TextEditingController();
    final _textArticleLibelle = TextEditingController();
    final _textArticlePrixAchat = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final scroller = ScrollController();
    Modal.show(
      context,
      height: MediaQuery.of(context).size.height * .55,
      width: MediaQuery.of(context).size.width * .7,
      color: Colors.blue,
      modalContent: Form(
        key: _formKey,
        child: Scrollbar(
          radius: const Radius.circular(10.0),
          controller: scroller,
          isAlwaysShown: true,
          hoverThickness: 10.0,
          child: SingleChildScrollView(
            controller: scroller,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Création stock".toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      InputText(
                        icon: Icons.label_important_rounded,
                        errorText: "libellé article requis !",
                        hintText: "Entrez libellé article...",
                        title: "Libellé article",
                        controller: _textArticleLibelle,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      InputText(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        errorText: "prix d'achat article requis !",
                        hintText: "Entrez prix d'achat produit...",
                        title: "Prix d'achat article",
                        controller: _textArticlePrixAchat,
                        suffixChild: Stack(
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
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      InputText(
                        icon: CupertinoIcons.archivebox_fill,
                        errorText: "quantité stock requise !",
                        hintText: "Entrez la quantité stock...",
                        title: "Quantité stock initial",
                        controller: _textQte,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: CostumBtn(
                              color: Colors.blue,
                              icon: CupertinoIcons.add_circled_solid,
                              label: "Créer",
                              onPressed: () async {
                                var db = await DbHelper.initDb();
                                if (_formKey.currentState.validate()) {
                                  try {
                                    var article = Article(
                                      articleLibelle: _textArticleLibelle.text,
                                    );
                                    var lastInsertedArticleId = await db.insert(
                                      "articles",
                                      article.toMap(),
                                    );
                                    if (lastInsertedArticleId != null) {
                                      var data = Stock(
                                        stockArticleId: lastInsertedArticleId,
                                        stockPrixAchat: double.parse(
                                            _textArticlePrixAchat.text),
                                        stockPrixAchatDevise: selectedDevise,
                                        stockQte: int.parse(_textQte.text),
                                      );
                                      var latestInsertedMouvt = await db.insert(
                                        "stocks",
                                        data.toMap(),
                                      );
                                      if (latestInsertedMouvt != null) {
                                        Get.back();
                                        XDialog.showSuccessAnimation(context);
                                        dataController.refreshStock();
                                        setState(() {
                                          _textArticleLibelle.text = "";
                                          _textArticlePrixAchat.text = "";
                                          _textQte.text = "";
                                        });
                                      }
                                    }
                                  } catch (err) {
                                    XDialog.showErrorMessage(
                                      context,
                                      message:
                                          "Une erreur est survenue lors du traitement !",
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: CostumBtn(
                              color: Colors.grey,
                              icon: CupertinoIcons.clear_circled_solid,
                              label: "Annuler",
                              onPressed: () {
                                setState(() {
                                  _textArticleLibelle.text = "";
                                  _textArticlePrixAchat.text = "";
                                  "";
                                  _textQte.text = "";
                                });
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showSortieModal(BuildContext context, {Stock data}) async {
    print(data.stockQte);
    final _textQteSortie = TextEditingController();
    final _keyValidator = GlobalKey<FormState>();
    final scroller = ScrollController();
    String selectedDate;
    List<MouvementStock> sorties = [];

    var allSorties = await NativeDbHelper.rawQuery(
        "SELECT * FROM stocks INNER JOIN mouvements ON stocks.stock_id = mouvements.mouvt_stock_id INNER JOIN articles ON stocks.stock_article_id = articles.article_id WHERE NOT stocks.stock_state ='deleted' AND NOT mouvements.mouvt_state='deleted' ORDER BY mouvements.mouvt_id DESC");
    if (allSorties != null) {
      sorties.clear();
      allSorties.forEach((e) {
        sorties.add(MouvementStock.fromMap(e));
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
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.pink),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.minus_circle_fill,
                            color: Colors.pink),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Sortie stock".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "article :  ",
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: primaryColor,
                            ),
                            children: [
                              TextSpan(
                                text: data.article.articleLibelle,
                                style: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Stock actuel :  ",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: primaryColor),
                            children: [
                              TextSpan(
                                text: "${data.stockQte}",
                                style: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Card(
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Form(
                        key: _keyValidator,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Veuillez entrer la quantité que vous voulez sortir du stock sélectionné !",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: InputText(
                                    errorText: "quantité à sortir requise !",
                                    hintText: "Entrez la quantité à sortir",
                                    icon: CupertinoIcons.archivebox,
                                    title: "Quantité à sortir",
                                    controller: _textQteSortie,
                                  ),
                                ),
                                const SizedBox(
                                  width: 15.0,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 180.0,
                                      height: 55,
                                      child: CostumBtn(
                                        color: Colors.pink,
                                        icon: CupertinoIcons.checkmark_alt,
                                        label: "Valider",
                                        onPressed: () async {
                                          if (_keyValidator.currentState
                                              .validate()) {
                                            try {
                                              var mouvement = MouvementStock(
                                                mouvtQte: int.parse(
                                                    _textQteSortie.text),
                                                mouvtStockId: data.stockId,
                                              );
                                              int lastQte = data.stockQte;
                                              int newQte = lastQte -
                                                  int.parse(
                                                      _textQteSortie.text);
                                              print(
                                                  "updated quantity : $newQte");
                                              if (newQte.isNegative) {
                                                XDialog.showErrorMessage(
                                                  context,
                                                  message:
                                                      "La quantité de sortie dépasse le stock actuel !",
                                                );
                                                return;
                                              }
                                              var lastInsertedMouvtId =
                                                  await NativeDbHelper.insert(
                                                "mouvements",
                                                mouvement.toMap(),
                                              );
                                              print(
                                                  'mouvementId :  $lastInsertedMouvtId');
                                              if (lastInsertedMouvtId != null) {
                                                var lastUpatedId =
                                                    await NativeDbHelper.update(
                                                        "stocks",
                                                        {'stock_qte': newQte},
                                                        where: "stock_id",
                                                        whereArgs: [
                                                          data.stockId
                                                        ]);
                                                if (lastUpatedId != null) {
                                                  if (newQte == 0) {
                                                    var stock = Stock(
                                                      stockStatus: "vide",
                                                    );
                                                    await NativeDbHelper.update(
                                                      "stocks",
                                                      stock.toMap(),
                                                      where: "stock_id",
                                                      whereArgs: [data.stockId],
                                                    );
                                                  }
                                                  XDialog.showSuccessAnimation(
                                                      context);
                                                  await dataController
                                                      .refreshStock();
                                                  await Synchroniser
                                                      .inPutData();
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 5), () {
                                                    Get.back();
                                                  });
                                                }
                                              }
                                            } catch (err) {
                                              print(err);
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15.0,
                                    ),
                                    Container(
                                      width: 180.0,
                                      height: 55,
                                      child: CostumBtn(
                                        color: Colors.grey,
                                        icon:
                                            CupertinoIcons.clear_circled_solid,
                                        label: "Annuler",
                                        onPressed: () {
                                          setState(() {
                                            _textQteSortie.text = "";
                                          });
                                          Get.back();
                                          dataController.refreshStock();
                                        },
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
              ],
            ),
            Expanded(
              child: Card(
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDatePicker(
                        color: Colors.pink,
                        date: selectedDate,
                        onCleared: () async {
                          setter(() {
                            selectedDate = null;
                          });

                          var allSorties = await NativeDbHelper.rawQuery(
                              "SELECT * FROM stocks INNER JOIN mouvements ON stocks.stock_id = mouvements.mouvt_stock_id INNER JOIN articles ON stocks.stock_article_id = articles.article_id  WHERE NOT stocks.stock_state='deleted' AND NOT mouvements.mouvt_state='deleted' AND articles.article_state='deleted' ORDER BY mouvements.mouvt_id DESC");
                          if (allSorties != null) {
                            sorties.clear();
                            allSorties.forEach((e) {
                              sorties.add(MouvementStock.fromMap(e));
                            });
                          }
                        },
                        onShownDatePicker: () async {
                          int date = await showDatePicked(context);
                          if (date != null) {
                            setter(() {
                              selectedDate = strDateLongFr(
                                  dateToString(parseTimestampToDate(date)));
                            });
                            var allSorties = await NativeDbHelper.rawQuery(
                                "SELECT * FROM stocks INNER JOIN mouvements ON stocks.stock_id = mouvements.mouvt_stock_id INNER JOIN articles ON stocks.stock_article_id = articles.article_id WHERE mouvements.mouvt_create_At = '$date'  WHERE NOT stocks.stock_state='deleted' AND NOT mouvements.mouvt_state='deleted' AND articles.article_state='deleted' ORDER BY mouvements.mouvt_id DESC");
                            if (allSorties != null) {
                              sorties.clear();
                              allSorties.forEach((e) {
                                sorties.add(MouvementStock.fromMap(e));
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          border: Border(
                            bottom: BorderSide(
                              color: primaryColor,
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
                              "Libellé article",
                              "Quantité sortie",
                              "Stock status",
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: sorties.isEmpty
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
                                  child: _sortieTableData(sorties, context),
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

  Widget _sortieTableData(List<MouvementStock> sorties, BuildContext context) {
    return Column(
      children: sorties.map((e) {
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
                color: e.mouvtId.isEven ? primaryColor : Colors.pink,
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
                      e.mouvtDate,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: e.stock.stockStatus.trim() == "actif".trim()
                            ? Colors.black87
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
                    Flexible(
                      child: Text(
                        e.stock.article.articleLibelle,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: e.stock.stockStatus.trim() == "actif".trim()
                              ? Colors.black87
                              : Colors.red,
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
                      "${e.mouvtQte}",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: e.stock.stockStatus.trim() == "actif".trim()
                            ? Colors.black87
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
                      e.stock.stockStatus,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: e.stock.stockStatus.trim() == "actif".trim()
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              if ((authController.loggedUser.value.userRole ==
                  "Administrateur")) ...[
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoundedBtn(
                        icon: CupertinoIcons.trash,
                        color: Colors.grey[900],
                        onPressed: () {
                          XDialog.show(
                            context: context,
                            content:
                                "Etes-vous sûr de vouloir supprimer cette sortie du stock ?",
                            icon: Icons.help,
                            title: "Suppression sortie stock !",
                            onValidate: () async {
                              var db = await DbHelper.initDb();
                              var stock = e.stock;
                              var lastDeletedId = await db.rawUpdate(
                                  "UPDATE stocks SET stock_state=? WHERE stock_id= ?",
                                  ["deleted", stock.stockId]);
                              await Synchroniser.inPutData();
                              await dataController.deleteUnavailableData();
                              if (lastDeletedId != null) {
                                Get.back();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

  showAddStockModal(BuildContext context, {Stock data}) {
    final _textQteEntree = TextEditingController();
    final _textArticlePrixAchat = TextEditingController();
    String selectedDevise = "CDF";
    final scroller = ScrollController();

    final _keyValidator = GlobalKey<FormState>();
    Modal.show(
      context,
      height: 350.0,
      width: MediaQuery.of(context).size.width * .6,
      color: Colors.blue,
      modalContent: Scrollbar(
        controller: scroller,
        isAlwaysShown: true,
        radius: const Radius.circular(10.0),
        thickness: 10.0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          controller: scroller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.add_circled_solid,
                            color: Colors.blue),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Ajout stock".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "article :  ",
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: primaryColor,
                            ),
                            children: [
                              TextSpan(
                                text: data.article.articleLibelle,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Stock actuel :  ",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: primaryColor),
                            children: [
                              TextSpan(
                                text: "${data.stockQte}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Form(
                key: _keyValidator,
                child: Column(
                  children: [
                    InputText(
                      errorText: "quantité requise !",
                      hintText: "Entrez la quantité...",
                      icon: CupertinoIcons.archivebox,
                      title: "Quantité stock",
                      controller: _textQteEntree,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    InputText(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      errorText: "prix d'achat article requis !",
                      hintText: "Entrez prix d'achat produit...",
                      title: "Prix d'achat article",
                      controller: _textArticlePrixAchat,
                      suffixChild: Stack(
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
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: CostumBtn(
                            color: Colors.blue,
                            icon: CupertinoIcons.checkmark_alt,
                            label: "Valider",
                            onPressed: () async {
                              var db = await DbHelper.initDb();
                              if (_keyValidator.currentState.validate()) {
                                int lastQte = data.stockQte;
                                int newQte =
                                    lastQte + int.parse(_textQteEntree.text);
                                var stock = Stock(
                                  stockArticleId: data.stockArticleId,
                                  stockPrixAchat:
                                      double.parse(_textArticlePrixAchat.text),
                                  stockPrixAchatDevise: selectedDevise,
                                  stockQte: newQte,
                                );
                                var latestUpdatedMouvt = await db.update(
                                  "stocks",
                                  stock.toMap(),
                                  where: "stock_id=?",
                                  whereArgs: [data.stockId],
                                );
                                if (latestUpdatedMouvt != null) {
                                  Get.back();
                                  XDialog.showSuccessAnimation(context);
                                  dataController.refreshStock();
                                  setState(() {
                                    _textArticlePrixAchat.text = "";
                                    _textQteEntree.text = "";
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Flexible(
                          child: CostumBtn(
                            color: Colors.grey,
                            icon: CupertinoIcons.checkmark_alt,
                            label: "Annuler",
                            onPressed: () {
                              setState(() {
                                _textQteEntree.text = "";
                                _textArticlePrixAchat.text = "";
                              });
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StockTableCard extends StatelessWidget {
  final Function onUsingStock;
  final Function onAddingStock;
  final Function onDeleted;
  final Stock data;
  const StockTableCard({
    Key key,
    this.data,
    this.onUsingStock,
    this.onAddingStock,
    this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            color: data.stockId.isEven ? primaryColor : Colors.pink,
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
                  "0${data.stockId}",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: data.stockStatus.trim() == "actif".trim()
                        ? Colors.black87
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
                  data.stockDate,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: data.stockStatus.trim() == "actif".trim()
                        ? Colors.black87
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
                Flexible(
                  child: Text(
                    data.article.articleLibelle,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: data.stockStatus.trim() == "actif".trim()
                          ? Colors.black87
                          : Colors.red,
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
                  "${data.stockPrixAchat} ${data.stockPrixAchatDevise}",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: data.stockStatus.trim() == "actif".trim()
                        ? Colors.black87
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
                  "${data.stockQte} ",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: data.stockStatus.trim() == "actif".trim()
                        ? Colors.black87
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
                  "${data.stockStatus} ",
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: (data.stockStatus.trim() == "actif".trim())
                          ? Colors.green
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
                FlatButton(
                  padding: const EdgeInsets.all(15.0),
                  onPressed: onAddingStock,
                  color: Colors.blue,
                  child: Row(
                    children: const [
                      Icon(
                        CupertinoIcons.add_circled_solid,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                FlatButton(
                  padding: const EdgeInsets.all(15.0),
                  onPressed: onUsingStock,
                  color: Colors.red,
                  child: Row(
                    children: const [
                      Icon(
                        CupertinoIcons.minus_circle_fill,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if ((authController.loggedUser.value.userRole == "Administrateur"))
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlatButton(
                    padding: const EdgeInsets.all(15.0),
                    onPressed: onDeleted,
                    color: Colors.grey[900],
                    child: Row(
                      children: const [
                        Icon(
                          CupertinoIcons.trash,
                          color: Colors.white,
                        ),
                      ],
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zando/index.dart';

import 'custom_input.dart';

class CurrencyCard extends StatefulWidget {
  const CurrencyCard({
    Key key,
  }) : super(key: key);

  @override
  State<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5.0,
          child: Stack(
            children: [
              Container(
                height: 100.0,
                width: 300.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Taux du jour",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                      ),
                    ),
                    Obx(() => RichText(
                          text: TextSpan(
                            text:
                                "${dataController.currency.value.currencyValue} ",
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 2.0,
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                            ),
                            children: [
                              TextSpan(
                                text: "CDF",
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  letterSpacing: 2.0,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          bottom: -30,
          right: 8.0,
          left: 8.0,
          child: Container(
            height: 60,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: CostumInput(
                        hintText: "saisir taux du jour",
                        icon: CupertinoIcons.money_dollar,
                        controller: controller,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5.0),
                          onTap: () async {
                            await dataController.editCurrency(
                              value: controller.text,
                            );
                            setState(() {
                              controller.text = "";
                            });
                          },
                          child: const Center(
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

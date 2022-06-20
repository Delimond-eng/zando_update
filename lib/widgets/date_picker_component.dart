import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/global/style.dart';

class DatePickerComponent extends StatelessWidget {
  final String date;
  final Function onSelectedDate;
  const DatePickerComponent({
    Key key,
    this.date,
    this.onSelectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Date de la création facture",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50.0,
                decoration: BoxDecoration(
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(5.0)),
                child: Material(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSelectedDate,
                    borderRadius: BorderRadius.circular(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.grey),
                                const SizedBox(
                                  width: 15.0,
                                ),
                                Text(
                                  date ?? "Sélectionnez une date",
                                  style: TextStyle(
                                    fontSize: date != null ? 18.0 : 12.0,
                                    fontWeight: FontWeight.w700,
                                    color: date != null
                                        ? primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 50.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(3.5),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.calendar_badge_plus,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
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
}

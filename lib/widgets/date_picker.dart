import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/global/style.dart';

class CustomDatePicker extends StatelessWidget {
  final String date;
  final Function onCleared;
  final Function onShownDatePicker;
  final Color color;
  const CustomDatePicker({
    Key key,
    this.date,
    this.onShownDatePicker,
    this.onCleared,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 400.0,
      decoration: BoxDecoration(
        border: Border.all(color: color ?? primaryColor),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: onShownDatePicker,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.calendar_today,
                          color: color ?? primaryColor,
                          size: 15.0,
                        ),
                      ),
                    ),
                  ),
                  if (date != null) ...[
                    Text(
                      date,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    )
                  ] else ...[
                    const Text(
                      "DD/MM/YYYY",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    )
                  ]
                ],
              ),
              Row(
                children: [
                  if (date != null) ...[
                    IconButton(
                      onPressed: onCleared,
                      icon: const Icon(
                        CupertinoIcons.clear_circled_solid,
                        color: Colors.red,
                        size: 20.0,
                      ),
                    ),
                  ],
                  Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color ?? primaryColor,
                          color ?? primaryColor,
                        ],
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(4.0),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.search,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

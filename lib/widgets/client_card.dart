import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/global/style.dart';
import 'package:zando/models/client.dart';

class ClientCard extends StatefulWidget {
  final Function onSelected;
  final Client data;
  const ClientCard({
    Key key,
    this.onSelected,
    this.data,
  }) : super(key: key);

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {
  bool isHover = false;
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      height: 50.0,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors
                .primaries[Random().nextInt(Colors.primaries.length)].shade900,
          ),
        ),
        color: widget.data.isSelected ? Colors.green[50] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.3),
            blurRadius: 3.0,
            offset: Offset.zero,
          )
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: widget.onSelected,
          onHover: (value) {
            setState(() {
              isHover = value;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: BoxDecoration(
                    color: widget.data.isSelected
                        ? Colors.green[400]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: (isHover || widget.data.isSelected)
                      ? const Center(
                          child: Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(
                  width: 15.0,
                ),
                Flexible(
                  child: Text(
                    widget.data.clientNom,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: primaryColor,
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
}

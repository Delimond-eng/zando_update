import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zando/global/style.dart';

class DashBoardCard extends StatefulWidget {
  const DashBoardCard({
    Key key,
    this.title,
    this.icon,
    this.onPressed,
    this.future,
  }) : super(key: key);
  final String title, icon;
  final Function onPressed;
  final Future future;

  @override
  State<DashBoardCard> createState() => _DashBoardCardState();
}

class _DashBoardCardState extends State<DashBoardCard> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FutureBuilder(
        future: widget.future,
        initialData: 0,
        builder: (context, snapshot) {
          return Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: isHover
                    ? Colors.white
                    : Colors
                        .primaries[Random().nextInt(Colors.primaries.length)]
                        .shade900,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.0),
                  onTap: widget.onPressed,
                  onHover: (value) {
                    setState(() {
                      isHover = value;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 80.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                            color: isHover
                                ? Colors.pink
                                : Colors.white.withOpacity(.5),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SvgPicture.asset(
                              widget.icon,
                              color: Colors.white,
                              height: 30.0,
                              width: 30.0,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: isHover ? primaryColor : Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 15.0,
                              ),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              "${snapshot.data}".padLeft(2, "0"),
                              style: TextStyle(
                                color: isHover ? primaryColor : Colors.white,
                                letterSpacing: 2.0,
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

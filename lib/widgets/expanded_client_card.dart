import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:zando/global/style.dart';
import 'package:zando/models/client.dart';

class ExpandedClientCard extends StatelessWidget {
  final Widget child;
  final Client data;
  const ExpandedClientCard({
    Key key,
    this.child,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: Column(
          children: <Widget>[
            ExpandablePanel(
              theme: const ExpandableThemeData(
                fadeCurve: Curves.bounceIn,
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToExpand: true,
                tapBodyToCollapse: false,
                hasIcon: false,
                useInkWell: true,
              ),
              header: Container(
                height: 60.0,
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: primaryColor,
                    ),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10.0,
                      color: Colors.grey.withOpacity(.3),
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: primaryColor,
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.person_solid,
                                color: Colors.white,
                                size: 15.0,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              data.clientNom,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w400,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Center(
                        child: ExpandableIcon(
                          theme: ExpandableThemeData(
                            expandIcon: CupertinoIcons.chevron_down,
                            collapseIcon: CupertinoIcons.chevron_up,
                            iconColor: primaryColor,
                            iconSize: 16.0,
                            iconRotationAngle: math.pi / 2,
                            hasIcon: false,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              collapsed: Container(),
              expanded: child,
            ),
          ],
        ),
      ),
    ); /*;*/
  }
}

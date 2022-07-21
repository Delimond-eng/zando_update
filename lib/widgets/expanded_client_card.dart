import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                height: 50.0,
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            height: 25.0,
                            width: 25.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.grey[400],
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.person_solid,
                                color: Colors.white,
                                size: 10.0,
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
                              style: GoogleFonts.didactGothic(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
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
                            expandIcon: CupertinoIcons.add_circled,
                            collapseIcon: CupertinoIcons.minus_circle,
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

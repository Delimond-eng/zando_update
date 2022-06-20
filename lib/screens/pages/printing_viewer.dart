import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:printing/printing.dart';
import 'package:zando/global/style.dart';
import 'package:zando/widgets/user_session_card.dart';

class PrintingViewer extends StatefulWidget {
  final Uint8List bytes;
  const PrintingViewer({Key key, this.bytes}) : super(key: key);

  @override
  State<PrintingViewer> createState() => _PrintingViewerState();
}

class _PrintingViewerState extends State<PrintingViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 90.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 10.0,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40.0,
                      width: 60.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.0),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icons/back-svgrepo-com.svg",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    const Icon(
                      CupertinoIcons.printer_fill,
                      color: Colors.white,
                      size: 25.0,
                    )
                  ],
                ),
                const UserSessionCard()
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              maxPageWidth: 1000,
              build: (format) => widget.bytes,
              canChangePageFormat: true,
              allowPrinting: true,
            ),
          ),
        ],
      ),
    );
  }
}

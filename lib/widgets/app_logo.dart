import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zando/global/style.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color color;
  const AppLogo({
    Key key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Zando ",
                style: GoogleFonts.bungeeInline(
                  color: Colors.pink,
                  fontWeight: FontWeight.w900,
                  fontSize: size != null ? size - 5 : 35.0,
                ),
              ),
              TextSpan(
                text: " GRAPHIC PRINT",
                style: GoogleFonts.bungeeInline(
                  color: color ?? primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: size != null ? size - 5 : 35.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

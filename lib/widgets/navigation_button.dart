import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zando/global/style.dart';

class NavBtn extends StatefulWidget {
  const NavBtn({
    Key key,
    this.onPressed,
    this.icon,
    this.title,
  }) : super(key: key);

  final Function onPressed;
  final String icon, title;

  @override
  State<NavBtn> createState() => _NavBtnState();
}

class _NavBtnState extends State<NavBtn> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: isHover ? Colors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: InkWell(
            splashColor: primaryColor.withOpacity(.4),
            borderRadius: BorderRadius.circular(5.0),
            onTap: widget.onPressed,
            onHover: (val) {
              setState(() {
                isHover = val;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    height: 30.0,
                    width: 30.0,
                    color: isHover ? Colors.white : primaryColor,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    widget.title.toUpperCase(),
                    style: GoogleFonts.didactGothic(
                      color: isHover ? Colors.white : primaryColor,
                      fontSize: 12.0,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

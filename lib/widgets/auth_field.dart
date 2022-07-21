import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassWord;

  const AuthField({
    Key key,
    this.controller,
    this.hintText,
    this.icon,
    this.isPassWord = false,
  }) : super(key: key);

  @override
  _AuthFieldState createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white.withOpacity(.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Colors.black.withOpacity(.1),
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: Colors.pink,
              size: 18.0,
            ),
            if (widget.isPassWord == false) ...[
              Flexible(
                child: TextField(
                  controller: widget.controller,
                  style: GoogleFonts.didactGothic(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.didactGothic(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              )
            ] else ...[
              Flexible(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _isObscure,
                  style: GoogleFonts.didactGothic(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    contentPadding: const EdgeInsets.all(8.0),
                    hintStyle: GoogleFonts.didactGothic(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w400,
                      fontSize: 15.0,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              )
            ],
            if (widget.isPassWord) ...[
              IconButton(
                iconSize: 14,
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                color: Colors.grey[800],
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassWord;
  final TextInputType keyType;

  const AuthInput({
    Key key,
    this.controller,
    this.hintText,
    this.icon,
    this.isPassWord = false,
    this.keyType,
  }) : super(key: key);

  @override
  _AuthInputState createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[100],
          width: .5,
        ),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.transparent,
      ),
      child: widget.isPassWord == false
          ? TextField(
              controller: widget.controller,
              style: const TextStyle(fontSize: 15.0, color: Colors.white),
              keyboardType: (widget.keyType == null)
                  ? TextInputType.text
                  : widget.keyType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
                icon: Container(
                  width: 80.0,
                  height: 55.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.grey[100],
                    size: 20.0,
                  ),
                ),
                border: InputBorder.none,
                counterText: '',
              ),
            )
          : TextField(
              controller: widget.controller,
              keyboardType: (widget.keyType == null)
                  ? TextInputType.text
                  : widget.keyType,
              obscureText: _isObscure,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  fontSize: 15.0,
                ),
                icon: Container(
                  height: 50.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    CupertinoIcons.lock,
                    size: 20.0,
                    color: Colors.grey[100],
                  ),
                ),
                border: InputBorder.none,
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 15,
                  ),
                  color: Colors.grey[100],
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zando/global/date_formater.dart';
import 'package:zando/global/style.dart';

class InputText extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyType;
  final String title;
  final bool isPassword;
  final String errorText;
  final Widget suffixChild;

  const InputText({
    Key key,
    this.controller,
    this.hintText,
    this.icon,
    this.keyType,
    this.title,
    this.isPassword = false,
    this.errorText,
    this.suffixChild,
  }) : super(key: key);

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return (widget.keyType != TextInputType.datetime) && (!widget.isPassword)
        ? TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.errorText;
              } else {
                return null;
              }
            },
            controller: widget.controller,
            keyboardType: widget.keyType ?? TextInputType.text,
            decoration: InputDecoration(
              labelStyle: TextStyle(
                color: primaryColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
              labelText: widget.title,
              hintText: "${widget.hintText}...",
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 14.0,
              ),
              counterText: '',
              hintStyle: TextStyle(
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(
                widget.icon,
                color: Colors.black,
                size: 20.0,
              ),
              suffix: widget.suffixChild,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                  color: primaryColor,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue[900],
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          )
        : (widget.isPassword)
            ? TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.errorText;
                  } else {
                    return null;
                  }
                },
                controller: widget.controller,
                keyboardType: TextInputType.text,
                obscureText: _isObscure,
                style: const TextStyle(fontSize: 15.0),
                decoration: InputDecoration(
                  labelText: widget.title,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  labelStyle: TextStyle(
                    color: primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    widget.icon,
                    color: Colors.black,
                    size: 20.0,
                  ),
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue[900],
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    color: Colors.black54,
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              )
            : TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.errorText;
                  } else {
                    return null;
                  }
                },
                // maxLength: 10,
                keyboardType: TextInputType.datetime,
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: widget.title,
                  labelStyle: TextStyle(
                    color: primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'JJ / MM / AAAA',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: Icon(
                    widget.icon,
                    color: Colors.black87,
                    size: 20,
                  ),
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue[900],
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  counterText: '',
                ),
                inputFormatters: [
                  // ignore: deprecated_member_use
                  WhitelistingTextInputFormatter(RegExp("[0-9/]")),
                  LengthLimitingTextInputFormatter(10),
                  DateFormatter(),
                ],
              );
  }
}

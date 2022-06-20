import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/global/style.dart';

class CostumInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassWord;
  final TextInputType keyType;
  final double height;
  final Color color;
  final Function(String value) onTextChanged;

  const CostumInput({
    Key key,
    this.controller,
    this.hintText,
    this.icon,
    this.isPassWord = false,
    this.keyType,
    this.onTextChanged,
    this.height,
    this.color,
  }) : super(key: key);

  @override
  _CostumInputState createState() => _CostumInputState();
}

class _CostumInputState extends State<CostumInput> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.color ?? primaryColor,
        ),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.transparent,
      ),
      child: widget.isPassWord == false
          ? TextField(
              onChanged: widget.onTextChanged,
              controller: widget.controller,
              style: const TextStyle(fontSize: 18.0, color: Colors.black87),
              keyboardType: (widget.keyType == null)
                  ? TextInputType.text
                  : widget.keyType,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                    top: widget.height != null ? 20 : 10, bottom: 15),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    widget.icon,
                    color: Theme.of(context).primaryColor,
                    size: 15.0,
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
                color: Colors.black87,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                hintStyle: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  fontSize: 15.0,
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.lock,
                    size: 20.0,
                    color: Theme.of(context).primaryColor,
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
                  color: Theme.of(context).primaryColor,
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

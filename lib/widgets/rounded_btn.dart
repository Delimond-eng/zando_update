import 'package:flutter/material.dart';

class RoundedBtn extends StatelessWidget {
  final IconData icon;
  final Function onPressed;
  final Color color;
  const RoundedBtn({
    Key key,
    this.icon,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
        color: color ?? Colors.blue,
        borderRadius: BorderRadius.circular(50.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 5.0,
            offset: Offset.zero,
          )
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(50.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50.0),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 15.0,
            ),
          ),
        ),
      ),
    );
  }
}

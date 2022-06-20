import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuBtn extends StatefulWidget {
  final Function onPressed;
  final String title;
  final IconData icon;
  final Color color;

  MenuBtn({Key key, this.onPressed, this.title, this.icon, this.color})
      : super(key: key);

  @override
  _MenuBtnState createState() => _MenuBtnState();
}

class _MenuBtnState extends State<MenuBtn> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.purple[100],
      borderRadius: BorderRadius.circular(10.0),
      onTap: widget.onPressed,
      onHover: (val) {
        setState(() {
          isHover = val;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isHover ? widget.color : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              blurRadius: isHover ? 15.0 : 10,
              color: isHover
                  ? Colors.grey.withOpacity(.8)
                  : Colors.grey.withOpacity(.4),
              offset: isHover ? const Offset(0, 5) : const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100.0,
              width: 5.0,
              decoration: BoxDecoration(
                  color: isHover ? Colors.white : widget.color,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0))),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isHover ? Colors.grey[100] : widget.color.withOpacity(.6),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: isHover ? widget.color : Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Flexible(
              child: Text(
                widget.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 18.0,
                  letterSpacing: 1.0,
                  color: isHover ? Colors.white : Colors.black54,
                  fontWeight: isHover ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

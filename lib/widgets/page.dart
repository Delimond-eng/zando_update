import 'package:flutter/material.dart';
import 'package:zando/global/style.dart';

class PageComponent extends StatelessWidget {
  const PageComponent({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: child,
        ),
      ),
    );
  }
}

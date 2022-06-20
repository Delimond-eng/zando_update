import 'package:flutter/material.dart';

class CustomTableHeader extends StatelessWidget {
  const CustomTableHeader({Key key, this.items, this.haveActionsButton = false})
      : super(key: key);

  final List<String> items;
  final bool haveActionsButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var item in items) ...[
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (haveActionsButton) ...[
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown(
      {Key key, this.items, this.onChanged, this.selectedValue, this.hintText})
      : super(key: key);
  final List<dynamic> items;
  final dynamic selectedValue;
  final Function(dynamic value) onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<dynamic>(
      menuMaxHeight: 300,
      dropdownColor: Colors.white,
      alignment: Alignment.centerRight,
      borderRadius: BorderRadius.circular(5.0),
      style: const TextStyle(color: Colors.black),
      value: selectedValue,
      underline: SizedBox(),
      hint: Text(
        " $hintText",
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16.0,
        ),
      ),
      isExpanded: true,
      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(
            "$e",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

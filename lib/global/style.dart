import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

Color primaryColor = const Color(0xff000033);

ClipRRect imageFromBase64String(String base64String, {double radius}) {
  try {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 5.0),
      child: Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        height: 150.0,
        width: 150.0,
      ),
    );
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return null;
  }
}

String dateFromString(DateTime date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  String formatted = formatter.format(date);
  return formatted;
}

DateTime strTodate(String date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  DateTime d = formatter.parse(date);
  return d;
}

ObjectId convertToObjectId(String objectId) {
  return ObjectId.fromHexString(objectId);
}

String formatCurrency(double amount) {
  return '${amount.toStringAsFixed(2)} USD';
}

String formatDate(DateTime date) {
  final format = DateFormat.yMMMd('fr_FR');
  return format.format(date);
}

showDateBox(context) async {
  return await showDatePicker(
    locale: const Locale("fr", "FR"),
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2025),
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          primaryColor: Colors.blue[900],
          accentColor: Colors.blue[900],
        ),
        child: child,
      );
    },
  );
}

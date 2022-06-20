import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zando/index.dart';

int convertToTimestamp(DateTime date) {
  return date.microsecondsSinceEpoch;
}

DateTime parseTimestampToDate(dynamic timestamp) {
  var date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
  return date;
}

DateTime strTodate(String date) {
  final DateFormat formatter = (date.contains("-"))
      ? DateFormat('dd-MM-yyyy')
      : DateFormat('dd/MM/yyyy');
  DateTime d = formatter.parse(date);
  return d;
}

String strDateLong(String value) {
  var date = strTodate(value);
  String converted = DateFormat.yMMMd().format(date);
  return converted;
}

String strDateLongFr(String value) {
  var date = strTodate(value);
  String converted = DateFormat.yMMMd("fr_FR").format(date);
  return converted;
}

String dateToString(DateTime date) {
  String converted = DateFormat("dd/MM/yyyy").format(date);
  return converted;
}

showDatePicked(context) async {
  var date = await showDatePicker(
    locale: const Locale("fr", "FR"),
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1950),
    lastDate: DateTime(2050),
  );
  if (date != null) {
    DateTime dateConverted = DateTime(date.year, date.month, date.day);
    return dateConverted.microsecondsSinceEpoch;
  }
}

double convertCdfToDollars(double Amount) {
  double tauxCDF = double.parse(dataController.currency.value.currencyValue);
  double dollars = Amount / tauxCDF;
  return dollars;
}

double convertDollarsToCdf(double dollars) {
  double tauxCDF = double.parse(dataController.currency.value.currencyValue);
  double cdf = dollars * tauxCDF;
  return cdf;
}

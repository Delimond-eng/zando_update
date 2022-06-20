class Currency {
  dynamic currencyId;
  String currencyValue;

  Currency({this.currencyId, this.currencyValue});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (currencyId != null) {
      data["currency_id"] = currencyId;
    }
    data["currency_value"] = currencyValue;
    return data;
  }

  Currency.fromMap(Map<String, dynamic> data) {
    currencyId = data["currency_id"];
    currencyValue = data["currency_value"];
  }
}

import 'facture.dart';
import 'facture_detail.dart';

class Invoice {
  Facture facture;
  List<FactureDetail> factureDetails;

  Invoice({this.facture, this.factureDetails});

  Invoice.fromMap(Map<String, dynamic> json) {
    if (json['facture'] != null) {
      facture = Facture();
      facture = Facture.fromMap(json['facture']);
    }
    if (json['facture_details'] != null) {
      factureDetails = <FactureDetail>[];
      json['facture_details'].forEach((v) {
        factureDetails.add(FactureDetail.fromMap(v));
      });
    }
  }
}

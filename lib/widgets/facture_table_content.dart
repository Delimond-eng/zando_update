import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/index.dart';
import 'package:zando/models/facture.dart';

class TableContentCard extends StatelessWidget {
  const TableContentCard({
    Key key,
    this.numOrder,
    this.data,
    this.onViewed,
    this.onDeleted,
  }) : super(key: key);

  final int numOrder;
  final Facture data;
  final Function onViewed;
  final Function onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
      ),
      margin: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: numOrder.isEven ? Colors.blue : Colors.pink,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.3),
            blurRadius: 12.0,
            offset: Offset.zero,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.factureDateCreate,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "0${data.factureId}",
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${data.factureMontant} ${data.factureDevise}",
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    data.client.clientNom,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.factureStatut == "paie" ? "payée" : data.factureStatut,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: data.factureStatut.trim() == "en attente".trim()
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: deprecated_member_use
                if ((authController.loggedUser.value.userRole ==
                    "Administrateur")) ...[
                  // ignore: deprecated_member_use
                  FlatButton(
                    color: Colors.pink,
                    padding: const EdgeInsets.all(18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed: onDeleted,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.trash_fill, color: Colors.white),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container()
                ]
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  color: Colors.blue,
                  padding: const EdgeInsets.all(18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  onPressed: onViewed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_right_alt_outlined, color: Colors.white),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Voir détails",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

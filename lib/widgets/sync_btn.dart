import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zando/global/modal.dart';
import 'package:zando/index.dart';
import 'package:zando/services/synchonisation.dart';

class SyncBtn extends StatelessWidget {
  const SyncBtn({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      color: Colors.pink,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: () async {
            try {
              if (authController.loggedUser.value.userRole ==
                  "Administrateur") {
                Xloading.showLottieLoading(context);
                await Synchroniser.inPutData();
                await dataController.syncData();
                await dataController.refreshStock();
                Xloading.dismiss();
              } else {
                Xloading.showLottieLoading(context);
                await Synchroniser.inPutData();
                Xloading.dismiss();
              }
            } catch (err) {
              Xloading.dismiss();
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 20, 5),
            child: Row(
              children: [
                Container(
                    height: 90.0,
                    width: 50.0,
                    padding: const EdgeInsets.all(10.0),
                    child: const Icon(CupertinoIcons.cloud_download)),
                const SizedBox(
                  width: 10.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      "Synchroniser les données",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

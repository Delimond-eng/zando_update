import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zando/global/style.dart';

class Xloading {
  static dismiss() {
    Get.back();
  }

  static showLottieLoading(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        barrierColor: Colors.black26,
        context: context,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return Center(
            child: SingleChildScrollView(
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: Lottie.asset(
                    "assets/lotties/90464-loading.json",
                    height: 350.0,
                    width: 350.0,
                  ),
                ),
              ),
            ),
          );
        });
  }

  static showCircularProgress(context, {String title}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black12,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ignore: prefer_const_constructors
                CircularProgressIndicator(
                  color: Colors.pink,
                  strokeWidth: 3,
                ),
                if (title.isNotEmpty)
                  const SizedBox(
                    width: 10,
                  ),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//attribution_sharp

class XDialog {
  static show(
      {BuildContext context,
      title,
      content,
      Function onValidate,
      Function onCancel,
      IconData icon}) {
    // set up the buttons
    // ignore: deprecated_member_use, sized_box_for_whitespace
    Widget cancelButton = Container(
      height: 40.0,
      width: 60.0,
      // ignore: deprecated_member_use
      child: FlatButton(
        color: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Icon(
          CupertinoIcons.clear,
          color: Colors.red[800],
          size: 14.0,
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
    // ignore: deprecated_member_use, sized_box_for_whitespace
    Widget continueButton = Container(
      width: 60.0,
      height: 40.0,
      // ignore: deprecated_member_use
      child: FlatButton(
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        color: Colors.green,
        child: const Center(
          child: Icon(
            CupertinoIcons.checkmark_alt,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          Get.back();
          Future.delayed(const Duration(microseconds: 500));
          onValidate();
        },
      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      backgroundColor: primaryColor,
      elevation: 10.0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pink),
          // ignore: prefer_const_constructors
          SizedBox(
            width: 5,
          ),
          Text(
            "$title",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Text(
        "$content",
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierColor: Colors.white12,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showSuccessMessage(context, {title, message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white12,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[400],
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check,
                color: Colors.white,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                "$title",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  color: Colors.white),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 4), () {
      Get.back();
    });
  }

  static showSuccessAnimation(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white12,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white38,
          elevation: 0,
          contentPadding: const EdgeInsets.all(8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Container(
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.center,
            color: Colors.transparent,
            width: 200.0,
            height: 200.0,
            child: Lottie.asset(
              "assets/lotties/84741-success.json",
              alignment: Alignment.center,
              animate: true,
              repeat: false,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      Get.back();
    });
  }

  static showErrorMessage(context, {message}) {
    showDialog(
      context: context,
      barrierColor: Colors.white10,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 10.0,
          // ignore: sized_box_for_whitespace
          content: Container(
            width: 250.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.red,
                    size: 40.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 4), () {
      Get.back();
    });
  }
}

class Modal {
  static void show(context,
      {Widget modalContent,
      double height,
      double width,
      double radius,
      Color color}) {
    showDialog(
        barrierColor: Colors.white10,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 5),
            ), //this right here
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(15.0),
                  width: width,
                  height: height,
                  child: modalContent,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: color ?? primaryColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius ?? 5),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}

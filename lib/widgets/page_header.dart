import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zando/global/style.dart';
import 'package:zando/widgets/sync_btn.dart';

import 'user_session_card.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({Key key, this.title, this.leadingIcon, this.bottomPadding})
      : super(key: key);
  final String title;
  final String leadingIcon;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 10.0,
      ),
      margin: EdgeInsets.only(bottom: bottomPadding ?? 10.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40.0,
                width: 60.0,
                child: Material(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/back-svgrepo-com.svg",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              SvgPicture.asset(
                leadingIcon,
                height: 30.0,
                width: 30.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          Row(
            children: const [
              SyncBtn(),
              SizedBox(
                width: 10.0,
              ),
              UserSessionCard(),
            ],
          )
        ],
      ),
    );
  }
}

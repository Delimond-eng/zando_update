import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zando/global/style.dart';
import 'package:zando/widgets/page.dart';
import 'package:zando/widgets/page_header.dart';

import 'tabs/create_account_tab.dart';
import 'tabs/operation_account_tab.dart';
import 'tabs/statistics_tab.dart';

class TresorieManagePage extends StatefulWidget {
  const TresorieManagePage({Key key}) : super(key: key);

  @override
  State<TresorieManagePage> createState() => _TresorieManagePageState();
}

class _TresorieManagePageState extends State<TresorieManagePage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageComponent(
      child: Column(
        children: [
          const PageHeader(
            bottomPadding: 0.0,
            leadingIcon: "assets/icons/bank-safe-box-svgrepo-com.svg",
            title: "Gestion de trésories",
          ),
          _tabHeader(),
          _tabBody(context),
        ],
      ),
    );
  }

  Widget _tabBody(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        width: double.infinity,
        child: TabBarView(
          physics: const BouncingScrollPhysics(),
          controller: controller,
          children: const [
            CreateAccountTab(),
            AccountOperationTab(),
            StatisticsTab()
          ],
        ),
      ),
    );
  }

  Widget _tabHeader() {
    return Container(
      width: double.infinity,
      height: 90.0,
      margin: const EdgeInsets.only(
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        automaticIndicatorColorAdjustment: true,
        padding: EdgeInsets.zero,
        isScrollable: true,
        indicator: BubbleTabIndicator(
          indicatorHeight: 90.0,
          indicatorColor: primaryColor,
          tabBarIndicatorSize: TabBarIndicatorSize.tab,
          indicatorRadius: 0,
          padding: EdgeInsets.zero,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        tabs: [
          Tab(
            icon: SvgPicture.asset(
              "assets/icons/add-button-svgrepo-com.svg",
              height: 25.0,
              width: 25.0,
              color: Colors.pink,
            ),
            text: "Creation compte".toUpperCase(),
          ),
          Tab(
            icon: SvgPicture.asset(
              "assets/icons/transaction-svgrepo-com.svg",
              height: 25.0,
              width: 25.0,
              color: Colors.pink,
            ),
            text: "Opérations sur les comptes".toUpperCase(),
          ),
          //
          Tab(
            icon: SvgPicture.asset(
              "assets/icons/statistics-svgrepo-com.svg",
              height: 25.0,
              width: 25.0,
              color: Colors.pink,
            ),
            text: "Statistiques sur les comptes".toUpperCase(),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/splash/Onboarding1.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void _checkPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      Timer(
        const Duration(seconds: 2),
        () => Navigator.of(context).pushAndRemoveUntil(
            PageTransition(
                type: PageTransitionType.bottomToTop,
                duration: Duration(milliseconds: 500),
                alignment: Alignment.center,
                child: Home()),
            (Route<dynamic> route) => false),
      );
    } else {
      Timer(
        const Duration(seconds: 2),
        () => Navigator.of(context).pushAndRemoveUntil(
            PageTransition(
                type: PageTransitionType.bottomToTop,
                duration: Duration(milliseconds: 500),
                alignment: Alignment.center,
                child: Onboarding1()),
            (Route<dynamic> route) => false),
      );
    }
  }

  @override
  void initState() {
    _checkPermission();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsInt.colorPrimary1,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo1.png",
              width: 250,
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}

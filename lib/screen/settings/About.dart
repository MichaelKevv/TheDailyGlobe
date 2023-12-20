import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/auth.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _SettingsState();
}

class _SettingsState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsInt.colorWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorsInt.colorWhite,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: ColorsInt.colorBlack,
          ),
        ),
      ),
      body: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              "assets/images/logo_black.png",
            ),
            SizedBox(
              height: 16,
            ),
            Text('Version 1.0')
          ],
        ),
      ),
    );
  }
}

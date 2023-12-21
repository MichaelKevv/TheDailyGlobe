import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thedailyglobe/screen/article/AddArticle.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/settings/About.dart';
import 'package:thedailyglobe/screen/settings/Terms.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/auth.dart';
import 'package:thedailyglobe/services/firestore.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingsState();
}

class _SettingsState extends State<Setting> {
  final FirestoreService firestoreService = FirestoreService();
  final User? user = Auth().currentUser;
  late String? role = "0";
  bool isSwitched = false;
  getUserRole() async {
    String? temp = await firestoreService.getUserRoleByEmail(user?.email ?? "");
    setState(() {
      role = temp.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
    getUserRole();
  }

  checkPermission() async {
    final PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      setState(() {
        isSwitched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsInt.colorWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorsInt.colorWhite,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.center,
                    child: const Home()),
                (Route<dynamic> route) => false);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: ColorsInt.colorBlack,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              if (user != null)
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Info',
                        style: TextStyle(
                            color: ColorsInt.colorBlack, fontSize: 28),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          user?.email ?? "",
                          style: const TextStyle(
                              color: ColorsInt.colorBlack, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 20, left: 24, right: 24),
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Auth().signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  duration: const Duration(milliseconds: 300),
                                  alignment: Alignment.center,
                                  child: const Home()),
                              (Route<dynamic> route) => false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text("Logout"),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsInt.colorPrimary2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 46, vertical: 18),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 50,
                      thickness: 1,
                    ),
                  ],
                ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text(
                        "Notifications",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        isSwitched == false ? "Off" : "On",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8999999761581421),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(() {
                            isSwitched = value;
                          });
                        },
                        activeTrackColor: ColorsInt.colorPrimary2,
                        activeColor: ColorsInt.colorPrimary2,
                      ),
                    ],
                  ),
                ],
              ),
              if (role == "1") ...[
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.leftToRight,
                        duration: const Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        child: AddArticle(),
                      ),
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_box_outlined,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          "Add Article",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              ],
              const Divider(
                color: Colors.grey,
                height: 50,
                thickness: 1,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Legal',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTop,
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.center,
                      child: const Terms(),
                    ),
                  );
                },
                child: Container(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.gpp_maybe,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text(
                        "Terms of Use & Privacy Policy",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTop,
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.center,
                      child: const About(),
                    ),
                  );
                },
                child: Container(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text(
                        "About",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:thedailyglobe/screen/article/AddArticle.dart';
import 'package:thedailyglobe/screen/article/Article.dart';
import 'package:thedailyglobe/screen/login/Login.dart';
import 'package:thedailyglobe/screen/search/Search.dart';
import 'package:thedailyglobe/screen/settings/Setting.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/auth.dart';
import 'package:thedailyglobe/services/firestore.dart';
import 'package:thedailyglobe/utils/WidgetTree.dart';
import 'package:thedailyglobe/utils/formatDate.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  late String _selectedCategory;
  late String? role = "0";
  final List<String> _categories = [
    'TOP STORIES',
    'TECHNOLOGY',
    'SPORTS',
    'BUSSINESS',
    'ENTERTAIMENT'
  ];
  final User? user = Auth().currentUser;
  String? headerText = 'All News';
  late List newsList;
  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  void initState() {
    _tabController = TabController(length: _categories.length, vsync: this);
    _selectedCategory = _categories.first;
    super.initState();
    getUserRole();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> _handleRefresh() async {
    firestoreService.getNewsStream(_selectedCategory).first;
    await Future.delayed(Duration(seconds: 2));
  }

  getUserRole() async {
    String? temp = await firestoreService.getUserRoleByEmail(user?.email ?? "");
    setState(() {
      role = temp.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: drawerLogin(context, role.toString()),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorsInt.colorWhite,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Image.asset(
              "assets/images/menu.png",
              width: 25,
              height: 25,
            ),
          ),
          title: Image.asset(
            "assets/images/logo_black.png",
            width: 150,
            height: 30,
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: TabBar(
                isScrollable: true,
                unselectedLabelColor: ColorsInt.colorBlack,
                labelColor: ColorsInt.colorBlue,
                indicatorColor: ColorsInt.colorBlue,
                controller: _tabController,
                tabs:
                    _categories.map((category) => Tab(text: category)).toList(),
                onTap: (index) {
                  setState(() {
                    _selectedCategory = _categories[index];
                  });
                },
              )),
          actions: [
            user == null
                ? Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return LoginBottomSheet();
                          },
                        );
                      },
                      child: Image.asset(
                        "assets/images/login.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                duration: Duration(milliseconds: 300),
                                alignment: Alignment.center,
                                child: Setting()),
                            (Route<dynamic> route) => false);
                      },
                      child: Image.asset(
                        "assets/images/user.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: _categories.map((category) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getNewsStream(category),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    newsList = snapshot.data!.docs;
                    if (category == 'TOP STORIES') {
                      headerText = "Breaking News";
                    } else {
                      headerText =
                          "Latest ${category.toString().toLowerCase()} News";
                    }
                    return ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 32, right: 32, top: 20, bottom: 20),
                          child: Text(
                            headerText.toString(),
                            style: TextStyle(
                                color: ColorsInt.colorBlack,
                                fontWeight: FontWeight.w500,
                                fontSize: 28),
                          ),
                        ),
                        for (var i = 0; i < newsList.length; i++)
                          buildNewsColumn(i)
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('Tidak ada data!'),
                    );
                  }
                }),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildNewsColumn(int index) {
    DocumentSnapshot document = newsList[index];
    String docID = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemBerita(data, docID),
      ],
    );
  }

  Widget LoginBottomSheet() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Text(
              'Log In',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            trailing: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Text(
              'Log in to access articles and save your\npreferences. ',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(
                  color: ColorsInt.colorPrimary2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: EdgeInsets.symmetric(horizontal: 46, vertical: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    duration: Duration(milliseconds: 300),
                    alignment: Alignment.center,
                    child: WidgetTree(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email,
                    color: ColorsInt.colorPrimary2,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Continue with Email',
                    style: TextStyle(color: ColorsInt.colorPrimary2),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget itemBerita(Map<String, dynamic>? data, String docID) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 200),
            alignment: Alignment.center,
            child: Article(id: docID),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: FittedBox(
              child: Image.network(
                data?['image'],
                width: 350,
                height: 200,
              ),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              data?['category'],
              style: TextStyle(
                color: Color(0xFF963F6E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.50,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              data?['title'],
              style: TextStyle(
                color: Colors.black.withOpacity(0.8999999761581421),
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 32, right: 32, top: 20, bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${data?['createdBy']} • ${formatDate(data?['date'])}'),
                Container(
                  width: 15,
                  height: 15,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ShareBottomSheet();
                        },
                      );
                    },
                    child: Icon(Icons.share),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ShareBottomSheet() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Text(
              'Share',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            trailing: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close),
            ),
          ),
          ListTile(
            leading: Icon(Icons.link),
            title: Text('Copy Link'),
            onTap: () {
              // Tindakan ketika opsi "Copy Link" dipilih
              Navigator.pop(context); // Tutup bottom sheet
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share on Social Media'),
            onTap: () {
              // Tindakan ketika opsi "Share on Social Media" dipilih
              Navigator.pop(context); // Tutup bottom sheet
            },
          ),
          // Tambahkan opsi lain sesuai kebutuhan
        ],
      ),
    );
  }
}

drawerLogin(BuildContext context, String role) {
  return Drawer(
    backgroundColor: ColorsInt.colorPrimary1,
    child: Container(
        margin: EdgeInsets.only(left: 16),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/logo1.png",
                  width: 200,
                  height: 100,
                ),
                Divider(
                  color: Colors.grey,
                  height: 0,
                  thickness: 1,
                  endIndent: 32,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'SECTIONS',
                  style: TextStyle(
                    color: Color(0xFFB1EBFF),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.10,
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            duration: Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            child: Home()),
                        (Route<dynamic> route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: ColorsInt.colorWhite,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9900000095367432),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            duration: Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            child: Search()),
                        (Route<dynamic> route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: ColorsInt.colorWhite,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9900000095367432),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            duration: Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            child: Setting()),
                        (Route<dynamic> route) => false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: ColorsInt.colorWhite,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9900000095367432),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (role == "1")
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: InkWell(
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
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_box_outlined,
                            color: ColorsInt.colorWhite,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Add Article',
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.9900000095367432),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(),
              ],
            ),
          ],
        )),
  );
}

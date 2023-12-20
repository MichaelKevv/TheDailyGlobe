import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:thedailyglobe/screen/article/AddArticle.dart';
import 'package:thedailyglobe/screen/article/Article.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/login/Login.dart';
import 'package:thedailyglobe/screen/search/Search.dart';
import 'package:thedailyglobe/screen/settings/Setting.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/auth.dart';
import 'package:thedailyglobe/services/firestore.dart';
import 'package:thedailyglobe/utils/WidgetTree.dart';
import 'package:thedailyglobe/utils/formatDate.dart';
import 'package:intl/intl.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {
  List _allResults = [];
  List _listResults = [];
  getAllNews() async {
    var newsStream = await FirebaseFirestore.instance
        .collection('news')
        .orderBy('date', descending: true)
        .get();
    setState(() {
      _allResults = newsStream.docs;
    });
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    if (_searchController != "") {
      for (var newsSnapshot in _allResults) {
        var title = newsSnapshot['title'].toString().toLowerCase();
        if (title.contains(_searchController.text.toLowerCase())) {
          showResults.add(newsSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _listResults = showResults;
    });
  }

  final TextEditingController _searchController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  late String _selectedCategory;
  String? search;
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
    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    searchResultList();
  }

  @override
  void didChangeDependencies() {
    getAllNews();
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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
    return Scaffold(
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
        body: Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: ListView(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by keyword',
                  prefixIcon: Icon(Icons.search_outlined),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              for (int i = 0; i < _listResults.length; i++) buildNewsColumn(i),
            ],
          ),
        ));
  }

  Widget buildNewsColumn(int index) {
    DocumentSnapshot document = _listResults[index];
    String docID = document.id;
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
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListTile(
          leading: Image.network(
            _listResults[index]['image'],
            width: 80,
            height: 80,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _listResults[index]['title'],
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8999999761581421),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '${formatDate(_listResults[index]['date'])}',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6000000238418579),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.40,
                ),
              )
            ],
          ),
        ),
      ),
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
                  child: Icon(Icons.share),
                ),
              ],
            ),
          ),
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
                            duration: Duration(milliseconds: 500),
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
                            duration: Duration(milliseconds: 500),
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
                            duration: Duration(milliseconds: 500),
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
                        Navigator.of(context).pushAndRemoveUntil(
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                duration: Duration(milliseconds: 300),
                                alignment: Alignment.center,
                                child: AddArticle()),
                            (Route<dynamic> route) => false);
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

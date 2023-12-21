import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:thedailyglobe/screen/article/EditArticle.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/auth.dart';
import 'package:thedailyglobe/services/firestore.dart';
import 'package:thedailyglobe/utils/formatDate.dart';

class Article extends StatefulWidget {
  final String id;
  const Article({required this.id});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  final FirestoreService firestoreService = FirestoreService();
  late String? role = "0";
  final User? user = Auth().currentUser;
  getUserRole() async {
    String? temp = await firestoreService.getUserRoleByEmail(user?.email ?? "");
    setState(() {
      role = temp.toString();
    });
    print(role);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorsInt.colorWhite,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: ColorsInt.colorBlack,
          onPressed: () {
            // Navigasi kembali ke halaman sebelumnya
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getNewsStreamID(widget.id),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Dokumen tidak ditemukan');
          }
          var newsData = snapshot.data!.data() as Map<String, dynamic>;
          return ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(newsData['image']),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      newsData['category'],
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
                      newsData['title'],
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
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            '${newsData['createdBy']} • ${formatDate(newsData['date'])}'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                    thickness: 1,
                    indent: 32,
                    endIndent: 32,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 32, right: 32, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (role == "1") ...[
                          InkWell(
                            onTap: () {
                              firestoreService.deleteNews(widget.id);
                              final snackBar = SnackBar(
                                duration: const Duration(seconds: 3),
                                content: Text("Successfully Delete Article!"),
                                backgroundColor: Colors.green,
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              Navigator.of(context).pushAndRemoveUntil(
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      duration: Duration(milliseconds: 300),
                                      alignment: Alignment.center,
                                      child: Home()),
                                  (Route<dynamic> route) => false);
                            },
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  duration: Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  child: EditArticle(id: widget.id),
                                ),
                              );
                            },
                            child: Icon(Icons.edit_outlined),
                          ),
                        ],
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return ShareBottomSheet();
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Share'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 50,
                    thickness: 1,
                    indent: 32,
                    endIndent: 32,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      newsData['content'],
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8999999761581421),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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

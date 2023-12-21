import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/firestore.dart';
import 'package:thedailyglobe/utils/formatDate.dart';
import 'package:http/http.dart' as http;

class EditArticle extends StatefulWidget {
  final String id;
  const EditArticle({required this.id});

  @override
  State<EditArticle> createState() => _EdtArticleState();
}

class _EdtArticleState extends State<EditArticle> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  Uint8List? _image;
  late Map<String, dynamic> newsData;
  String? _valCategory;
  final List<String> _listCategory = [
    'TOP STORIES',
    'TECHNOLOGY',
    'SPORTS',
    'BUSSINESS',
    'ENTERTAIMENT'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  Future<Uint8List> loadImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  void getData() async {
    try {
      DocumentSnapshot newsSnapshot = await FirebaseFirestore.instance
          .collection('news')
          .doc(widget.id)
          .get();

      if (newsSnapshot.exists) {
        newsData = newsSnapshot.data() as Map<String, dynamic>;
        Uint8List imageBytes = await loadImageFromUrl(newsData['image']);
        setState(() {
          _titleController.text = newsData['title'];
          _contentController.text = newsData['content'];
          _valCategory = newsData['category'];
          _image = imageBytes;
        });
      } else {
        print('Dokumen tidak ditemukan');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void saveNews() async {
    String res = await FirestoreService().updateNews(
        widget.id,
        _titleController.text,
        _contentController.text,
        _valCategory.toString(),
        _image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsInt.colorWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorsInt.colorWhite,
        centerTitle: true,
        title: Text(
          'Edit Article',
          style: TextStyle(color: ColorsInt.colorBlack),
        ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 8,
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Content',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.maxFinite,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Category',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    items: _listCategory
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: _valCategory,
                    onChanged: (value) {
                      setState(() {
                        _valCategory = value.toString();
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      width: 160,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.arrow_forward_ios_outlined,
                      ),
                      iconSize: 14,
                      iconEnabledColor: Colors.black,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              (_image != null)
                  ? Stack(
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorsInt.colorBlack),
                            image: DecorationImage(
                                image: MemoryImage(_image!), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: ColorsInt.colorPrimary2,
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: ColorsInt.colorWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: selectImage,
                      child: Container(
                        width: double.maxFinite,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorsInt.colorBlack),
                        ),
                      ),
                    ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsInt.colorPrimary2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 46, vertical: 18),
                  ),
                  onPressed: () async {
                    saveNews();
                    final snackBar = SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text("Successfully Update Article!"),
                      backgroundColor: Colors.green,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    await Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: Duration(milliseconds: 300),
                            alignment: Alignment.center,
                            child: Home()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text('Update Article'),
                ),
              ),
            ],
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

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class AddArticle extends StatefulWidget {
  @override
  State<AddArticle> createState() => _ArticleState();
}

class _ArticleState extends State<AddArticle> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void saveNews() async {
    String res = await FirestoreService().addNews(
        _titleController.text,
        _contentController.text,
        _categoryController.text.toUpperCase(),
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
          'Add Article',
          style: TextStyle(color: ColorsInt.colorBlack),
        ),
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
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  hintText: 'Category',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
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
                              icon: Icon(Icons.close),
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
                  onPressed: () {
                    saveNews();
                  },
                  child: Text('Add Article'),
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

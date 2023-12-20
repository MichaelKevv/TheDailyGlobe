import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/auth.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _SettingsState();
}

class _SettingsState extends State<Terms> {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Terms of Use &\nPrivacy Policy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
              "Curabitur vel volutpat eros, in interdum eros. Pellentesque lorem magna, facilisis vel diam nec, sagittis fermentum purus. Maecenas placerat urna ullamcorper ultrices elementum.\n\nQuisque maximus lectus ac posuere posuere. Fusce eu molestie libero. Nulla fringilla enim et elit facilisis blandit. Etiam tincidunt porta vulputate.\n\nMaecenas congue convallis odio sit amet pharetra. Phasellus sagittis dapibus erat non sagittis. Praesent imperdiet lectus urna, a sagittis sapien pulvinar vel. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eget neque turpis.Quisque a lectus feugiat, sollicitudin massa ac, ultricies tellus. Proin rutrum neque nec vehicula ultrices. Suspendisse venenatis odio mi.\n\nSed dictum congue nisi id finibus. Morbi malesuada lorem est, id efficitur mauris ultrices sit amet. Phasellus eget mi risus. Nulla facilisi. Aliquam fermentum malesuada metus, nec pretium odio efficitur in. In condimentum semper ipsum quis cursus. Aenean in ex at leo porta ultrices.\n\nCurabitur vel volutpat eros, in interdum eros. Pellentesque lorem magna, facilisis vel diam nec, sagittis fermentum purus. Maecenas placerat urna ullamcorper ultrices elementum. Quisque maximus lectus ac posuere posuere. Fusce eu molestie libero. Nulla fringilla enim et elit facilisis blandit. Etiam tincidunt porta vulputate. Maecenas congue convallis odio sit amet pharetra. Phasellus sagittis dapibus erat non sagittis. Praesent imperdiet lectus urna, a sagittis sapien pulvinar vel. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eget neque turpis.Quisque a lectus feugiat, sollicitudin massa ac, ultricies tellus. Proin rutrum neque nec vehicula ultrices. Suspendisse venenatis odio mi. Sed dictum congue nisi id finibus. Morbi malesuada lorem est, id efficitur mauris ultrices sit amet. Phasellus eget mi risus. Nulla facilisi. Aliquam fermentum malesuada metus, nec pretium odio efficitur in. In condimentum semper ipsum quis cursus. Aenean in ex at leo porta ultrices.")
        ],
      ),
    );
  }
}

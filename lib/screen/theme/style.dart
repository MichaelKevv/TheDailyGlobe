import 'package:flutter/material.dart';
import '../theme/Color.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: ColorsInt.colorPrimary1,
    primaryColorDark: ColorsInt.colorPrimary1,
    scaffoldBackgroundColor: ColorsInt.colorBG,
    canvasColor: ColorsInt.colorWhite,
    fontFamily: 'Inter',
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: ColorsInt.colorPrimary1),
  );
}

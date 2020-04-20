import 'package:flutter/material.dart';
import 'hymns_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    //GestureDetector to allow focus to change on tap.
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Simple Hymnal',
        theme: ThemeData.light(),
        home: HymnsPage(),
      ),
    );
  }
}

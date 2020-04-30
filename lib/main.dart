import 'package:flutter/material.dart';
import 'hymns_page.dart';

ThemeData themeData = ThemeData.light()
    .copyWith(cursorColor: Colors.white, accentColor: Colors.grey);
bool isDarkMode = false;
void main() => runApp(MyAppState());

class MyAppState extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppState> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          FocusScope.of(context).requestFocus(new FocusNode());
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simple Hymnal',
        theme: themeData,
        home: HymnsPage(callback: (data) {
          setState(() {
            themeData = data;
          });
        }),
      ),
    );
  }
}

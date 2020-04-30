import 'package:flutter/material.dart';
import 'package:simplehymnal/new_hymns_database.dart';
import 'new_hymns_database.dart';

final NewHymnsDatabase database = NewHymnsDatabase();
List<NewHymns> newHymnsList;

class AddHymnsPage extends StatefulWidget {
  @override
  _AddHymnsPage createState() => _AddHymnsPage();
}

class _AddHymnsPage extends State<AddHymnsPage> {
  @override
  void initState() {
    initializeDatabase();
    super.initState();
  }

  void initializeDatabase() async {
    await database.createDatabase();
  }

  void addFavorite(NewHymns newHymns) async {
    newHymnsList.add(newHymns);
    newHymnsList.sort();
    await database.insertNewHymns(newHymns);
  }

  void removeFavorite(NewHymns newHymns) async {
    newHymnsList.remove(newHymns);
    await database.insertNewHymns(newHymns);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD NEW HYMN'),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Enter Hymn Title...'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Enter Hymn Title...'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

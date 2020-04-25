import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:io' show Platform;

import 'constants.dart';
import 'hymns_list.dart';
import 'drawer_header.dart';
import 'favorites_database.dart';

final FavoritesDatabase database = FavoritesDatabase();
final GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
final TextEditingController controller = TextEditingController();

String currentText = "";
String selectedHymn = hymns.keys.first;
List<String> hymnsTitles = hymns.keys.toList();
List<String> hymnsAllTitles = hymns.keys.toList();
List<String> favoritesList = [];
Color starColor = Colors.blueGrey;
bool isFilterSwitched = false;
bool isTitleFavorite = false;

class HymnsPage extends StatefulWidget {
  @override
  _HymnsPage createState() => _HymnsPage();
}

class _HymnsPage extends State<HymnsPage> {
  SimpleAutoCompleteTextField get textField => SimpleAutoCompleteTextField(
        onFocusChanged: (bool isFocused) {
          if (!isFocused) {
            controller.clear();
          }
        },
        style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.visiblePassword,
        suggestionsAmount: 10,
        key: key,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(15),
            enabledBorder: kOutlineInputBorder,
            disabledBorder: kOutlineInputBorder,
            focusedBorder: kOutlineInputBorder,
            border: null),
        controller: controller,
        suggestions: hymnsAllTitles,
        textChanged: (text) {
          currentText = text;
        },
        clearOnSubmit: true,
        textSubmitted: (String submittedHymn) {
          if (hymnsTitles.contains(submittedHymn)) {
            setTitle(submittedHymn);
            setStarColor(favoritesList);
          }
        },
      );

  @override
  void initState() {
    initializeDatabase();
    hymnsAllTitles.sort();

    super.initState();
  }

  void initializeDatabase() async {
    await database.createDatabase();
    favoritesList = await database.favorites();
    setStarColor(favoritesList);
  }

  void setStarColor(List favoritesList) {
    setState(() {
      favoritesList.contains(selectedHymn)
          ? starColor = Colors.yellow
          : starColor = Colors.blueGrey;
    });
  }

  void addFavorite(String name) async {
    favoritesList.add(name);
    favoritesList.sort();
    await database.insertFavorite(name);
  }

  void removeFavorite(String name) async {
    favoritesList.remove(name);
    await database.deleteFavorite(name);
  }

  void favoritesButtonActivity() {
    setState(() {
      if (isTitleFavorite) {
        removeFavorite(selectedHymn);
        isTitleFavorite = false;
        starColor = Colors.blueGrey;
      } else {
        addFavorite(selectedHymn);
        isTitleFavorite = true;
        starColor = Colors.yellow;
      }
    });
  }

  void drawerFavoritesButtonActivity(String title) {
    setState(() {
      if (favoritesList.contains(title)) {
        removeFavorite(title);
        if (selectedHymn == title) {
          starColor = Colors.blueGrey;
        }
      } else {
        addFavorite(title);
        if (selectedHymn == title) {
          starColor = Colors.yellow;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    hymnsTitles.sort();
    favoritesList.contains(selectedHymn)
        ? isTitleFavorite = true
        : isTitleFavorite = false;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 0),
            child: IconButton(
              icon: Icon(
                Icons.star,
                color: starColor,
              ),
              onPressed: () {
                favoritesButtonActivity();
              },
            ),
          ),
        ],
        title: textField,
        //actions: ,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: SafeArea(
          child: ListView.builder(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            itemCount: hymnsTitles.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getListOfHymns(context),
                );
              }
              return ListTile(
                dense: true,
                title: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: IconButton(
                        icon: Icon(
                          Icons.star,
                          color: favoritesList.contains(hymnsTitles[index - 1])
                              ? Colors.yellow
                              : Colors.grey[200],
                        ),
                        onPressed: () {
                          drawerFavoritesButtonActivity(hymnsTitles[index - 1]);
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hymnsTitles[index - 1],
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setTitle(hymnsTitles[index - 1]);
                  setStarColor(favoritesList);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                selectedHymn,
                style: kTitleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                hymns[selectedHymn],
                style: kVerseStyle,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getListOfHymns(BuildContext context) {
    List<Widget> listOfTiles = [
      DrawerHeaderWidget(
        text: 'LIST OF HYMNS',
        color: Colors.white,
        fontSize: 32.0,
        fontFamily: 'Raleway-ExtraBold',
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
              child: Text(
                'Favorites Only',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontFamily: 'Raleway-ExtraBold',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
              child: Container(child: getPlatformSpecificSwitch()),
            ),
          ],
        ),
      ),
    ];

    return listOfTiles;
  }

  Widget getPlatformSpecificSwitch() {
    try {
      if (Platform.isIOS) {
        return CupertinoSwitch(
          value: isFilterSwitched,
          onChanged: (value) {
            setState(() {
              isFilterSwitched = value;
              if (isFilterSwitched) {
                setHymnsTitleFavorites();
              } else {
                hymnsTitles = hymns.keys.toList();
              }
            });
          },
          trackColor: Colors.lightGreenAccent,
          activeColor: Colors.green,
        );
      } else {
        return Switch(
          value: isFilterSwitched,
          onChanged: (value) {
            setState(() {
              isFilterSwitched = value;
              if (isFilterSwitched) {
                setHymnsTitleFavorites();
              } else {
                hymnsTitles = hymns.keys.toList();
              }
            });
          },
          activeTrackColor: Colors.lightGreenAccent,
          activeColor: Colors.green,
        );
      }
    } catch (e) {
      return Switch(
        value: isFilterSwitched,
        onChanged: (value) {
          setState(() {
            isFilterSwitched = value;
            if (isFilterSwitched) {
              setHymnsTitleFavorites();
            } else {
              hymnsTitles = hymns.keys.toList();
            }
          });
        },
        activeTrackColor: Colors.lightGreenAccent,
        activeColor: Colors.green,
      );
    }
  }

  void setHymnsTitleFavorites() {
    hymnsTitles = favoritesList;
  }

  void setTitle(String title) {
    setState(() {
      selectedHymn = title;
    });
  }
}

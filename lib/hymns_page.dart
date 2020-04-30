import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:io' show Platform;

import 'constants.dart';
import 'hymns_list.dart';
import 'favorites_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FavoritesDatabase database = FavoritesDatabase();
final GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
final TextEditingController controller = TextEditingController();

String currentText = "";
String selectedHymn = hymns.keys.first;
List<String> hymnsTitles = hymns.keys.toList();
List<String> hymnsAllTitles = hymns.keys.toList();
List<String> favoritesList = [];
Color starColor = Colors.grey[500];
IconData starIcon = Icons.star_border;
bool isFilterSwitched = false;
bool isTitleFavorite = false;
double fontContainerHeight = 50;
bool fontIconPressed = false;
Widget optionMenu = Row();
int fontSize = 15;
bool isNightModeOn = false;

class HymnsPage extends StatefulWidget {
  @override
  _HymnsPage createState() => _HymnsPage();
  void Function(ThemeData) callback;
  HymnsPage({this.callback});
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
    setThemeData();
    setFontSize();
    super.initState();
  }

  void addBoolToSF(bool input) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', input);
  }

  void addIntToSF(int input) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('font', input);
  }

  void setThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool boolValue = prefs.getBool('isDark');
    if (boolValue) {
      widget.callback(ThemeData.dark()
          .copyWith(cursorColor: Colors.white, accentColor: Colors.grey));
      isNightModeOn = true;
    }
  }

  void setFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    int intValue = await prefs.getInt('font') ?? 0;
    if (intValue != 0) {
      fontSize = intValue;
    }
  }

  void initializeDatabase() async {
    await database.createDatabase();
    favoritesList = await database.favorites();
    setStarColor(favoritesList);
    setStarIcon(favoritesList);
  }

  void setStarColor(List favoritesList) {
    setState(() {
      favoritesList.contains(selectedHymn)
          ? starColor = Colors.yellow
          : starColor = Colors.grey[500];
    });
  }

  void setStarIcon(List favoritesList) {
    setState(() {
      favoritesList.contains(selectedHymn)
          ? starIcon = Icons.star
          : starIcon = Icons.star_border;
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
        starColor = Colors.grey[500];
        starIcon = Icons.star_border;
      } else {
        addFavorite(selectedHymn);
        isTitleFavorite = true;
        starColor = Colors.yellow;
        starIcon = Icons.star;
      }
    });
  }

  void drawerFavoritesButtonActivity(String title) {
    setState(() {
      if (favoritesList.contains(title)) {
        removeFavorite(title);
        if (selectedHymn == title) {
          starColor = Colors.grey[500];
          starIcon = Icons.star_border;
        }
      } else {
        addFavorite(title);
        if (selectedHymn == title) {
          starColor = Colors.yellow;
          starIcon = Icons.star;
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
                starIcon,
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
                          favoritesList.contains(hymnsTitles[index - 1])
                              ? Icons.star
                              : Icons.star_border,
                          color: favoritesList.contains(hymnsTitles[index - 1])
                              ? Colors.yellow
                              : Colors.grey[500],
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
                  setStarIcon(favoritesList);
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
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: fontSize.toDouble(),
                ),
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
      Material(
        elevation: 3,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isNightModeOn
                    ? Theme.of(context).bottomAppBarColor
                    : Colors.lightBlue,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                child: Text(
                  'LIST OF HYMNS',
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontFamily: 'Raleway-ExtraBold'),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
//          boxShadow: [
//            BoxShadow(
//              color: Colors.black54,
//              blurRadius: 5.0,
//              offset: Offset(0, 0.75),
//            )
//          ],
                  color: isNightModeOn
                      ? Theme.of(context).bottomAppBarColor
                      : Colors.lightBlue),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Column(
                  children: getOptionMenu(),
                ),
              ),
            ),
          ],
        ),
      )
    ];

    return listOfTiles;
  }

  List<Widget> getOptionMenu() {
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    'Favorites Only',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontFamily: 'Raleway-ExtraBold',
                    ),
                  ),
                  SizedBox(
                      width: 60,
                      height: 25,
                      child: getPlatformSpecificSwitch()),
                ],
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Font',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontFamily: 'Raleway-ExtraBold',
                    ),
                  ),
                  SizedBox(
                    height: 25,
                    width: 75,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: IconButton(
                              padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                              icon: Icon(
                                Icons.arrow_left,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (fontSize > 8) {
                                    fontSize--;
                                    addIntToSF(fontSize);
                                  }
                                });
                              }),
                        ),
                        SizedBox(
                            height: 25,
                            width: 25,
                            child: Text(
                              fontSize.toString(),
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 17.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: IconButton(
                              padding: EdgeInsets.fromLTRB(0, 0, 3, 0),
                              icon: Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (fontSize < 28) {
                                    fontSize++;
                                    addIntToSF(fontSize);
                                  }
                                });
                              }),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    isNightModeOn ? 'Light Mode' : 'Dark Mode',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontFamily: 'Raleway-ExtraBold',
                    ),
                  ),
                  SizedBox(
                      width: 60,
                      height: 25,
                      child: IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Transform.rotate(
                            angle: -5.7,
                            child: Container(
                              child: Icon(
                                isNightModeOn
                                    ? Icons.wb_sunny
                                    : Icons.brightness_3,
                                size: 22,
                                color: isNightModeOn
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isNightModeOn) {
                                widget.callback(ThemeData.light()
                                    .copyWith(cursorColor: Colors.white));
                                isNightModeOn = false;
                                addBoolToSF(false);
                              } else {
                                widget.callback(ThemeData.dark().copyWith(
                                    cursorColor: Colors.white,
                                    accentColor: Colors.grey));
                                isNightModeOn = true;
                                addBoolToSF(true);
                              }
                            });
                          })),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget getPlatformSpecificSwitch() {
    try {
      if (Platform.isIOS) {
        return Transform.scale(
          scale: .68,
          child: CupertinoSwitch(
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
            trackColor: isNightModeOn ? Colors.blue : Colors.green,
            activeColor: isNightModeOn
                ? Colors.lightBlueAccent
                : Colors.lightGreenAccent,
          ),
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
          activeTrackColor:
              isNightModeOn ? Colors.lightBlueAccent : Colors.lightGreenAccent,
          activeColor: isNightModeOn ? Colors.blue : Colors.green,
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

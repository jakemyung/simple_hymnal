import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NewHymnsDatabase {
  NewHymnsDatabase();

  var database;
  Future<void> createDatabase() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'new_hymns_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE newHymns(title TEXT PRIMARY KEY, verse TEXT)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertNewHymns(NewHymns newHymns) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'newHymns',
      newHymns.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NewHymns>> newHymns() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, String>> maps = await db.query('favorites');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return NewHymns(
        title: maps[i]['title'],
        verse: maps[i]['verse'],
      );
    });
  }

  Future<void> deleteNewHymns(String title) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    try {
      await db.delete(
        'newHymns',
        // Use a `where` clause to delete a specific dog.
        where: "title = '$title'",
        // Pass the Dog's id as a whereArg to prevent SQL injection.
      );
    } catch (e) {
      print(e);
    }
  }
}

class NewHymns {
  final String title;
  final String verse;

  NewHymns({this.title, this.verse});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'verse': verse,
    };
  }
}

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesDatabase {
  FavoritesDatabase();

  var database;
  Future<void> createDatabase() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'favorites_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE favorites(name TEXT PRIMARY KEY)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertFavorite(String name) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'favorites',
      {
        'name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> favorites() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return maps[i]['name'];
    });
  }

  Future<void> deleteFavorite(String name) async {
    // Get a reference to the database.
    final db = await database;
    // Remove the Dog from the database.
    try {
      await db.delete(
        'favorites',
        // Use a `where` clause to delete a specific dog.
        where: "name = '$name'",
        // Pass the Dog's id as a whereArg to prevent SQL injection.
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> isFavoritedInDatabase(String name) async {
    List list = await favorites();

    return list.contains(name);
  }
}

class Favorite {
  final String name;

  Favorite({this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Favorite{name: $name}';
  }
}

import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database database;
void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(join(await getDatabasesPath(), 'doggie_database.db'), onCreate:(db, version) {
    return db.execute("CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)");
  },
  version: 1);

  Future<void> insertDog(Dog dog) async {
    final db = await database;
    await db.insert('dogs', dog.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Dog>> dogs() async {
    final db = await database;
    
    final List<Map<String,dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (index) {
      return Dog(
        id: maps[index]['id'],
        name: maps[index]['name'],
        age: maps[index]['age']
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await database;
    await db.update('dogs', dog.toMap(), where: 'id = ?', whereArgs: [dog.id]);
  }

  var fido = Dog(id: 0, name: "Fido", age: 35);
  await insertDog(fido);
  await insertDog(Dog(id: 1, name:'Mina', age: 2));
  await insertDog(Dog(id: 2, name:"Lili", age: 3));
  await insertDog(Dog(id: 3, name:"Lewis", age: 1));
  print(await dogs());

  fido.age += 50;
  await updateDog(fido);
  print(await dogs());
  
}

class Dog {
  final int id;
  final String name;
  int age;

  Dog({
    required this.id,
    required this.name,
    this.age = 0
  });

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name':name,
      'age':age
    };
  }

  @override
  String toString() {
    return "Dog{id: $id, name: $name, age: $age}";
  }
}
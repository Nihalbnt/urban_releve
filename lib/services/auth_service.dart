import 'db_helper.dart';
import '../models/user.dart';
import 'package:sqflite/sqflite.dart';

class AuthService {
  Future<int> register(User user) async {
    final db = await DBHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> login(String username, String password) async {
    final db = await DBHelper.database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }
}

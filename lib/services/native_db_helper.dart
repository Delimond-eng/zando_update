import 'dart:convert';
import 'dart:io';
import 'dart:ffi';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

class NativeDbHelper {
  static Database _db;

  static Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  static DynamicLibrary _openLibrary() {
    final scriptDir = File(Platform.script.toFilePath()).parent;
    if (Platform.isWindows) {
      final libraryNextToScript = File('${scriptDir.path}/sqlite3.dll');
      return DynamicLibrary.open(libraryNextToScript.path);
    }
  }

  static initDb() async {
    if (Platform.isWindows || Platform.isMacOS) {
      open.overrideForAll(_openLibrary);
    }
    Database database;
    try {
      if (Platform.isWindows) {
        final scriptDir = File(Platform.script.toFilePath()).parent;
        database = sqlite3.open('${scriptDir.path}/zandodb.dll');
      }
    } catch (err) {
      print("error from init database $err");
    }
    return database;
  }

  ///
  ///sql query represent SELECT QUERY
  ///[@param=> table] : table name
  ///[@param=> distinct] : clause distinct
  ///[@param=> columns] : list of columns
  ///[@param=> where] : where clause
  ///
  static Future query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    if (groupBy == null && having != null) {
      throw ArgumentError(
          'HAVING clauses are only permitted when using a groupBy clause');
    }
    final query = StringBuffer();
    query.write('SELECT ');
    if (distinct == true) {
      query.write('DISTINCT ');
    }
    if (columns != null && columns.isNotEmpty) {
      writeColumns(query, columns);
    } else {
      query.write('* ');
    }
    query.write('FROM ');
    query.write(table);
    if (where != null) {
      writeClause(query, ' WHERE ', where);
    }

    if (whereArgs != null) {
      whereArgs.forEach((arg) {
        query.write(" = '$arg'");
      });
    }
    writeClause(query, ' GROUP BY ', groupBy);
    writeClause(query, ' HAVING ', having);
    writeClause(query, ' ORDER BY ', orderBy);
    if (limit != null) {
      writeClause(query, ' LIMIT ', limit.toString());
    }
    if (offset != null) {
      writeClause(query, ' OFFSET ', offset.toString());
    }
    String sql = query.toString();
    var result;
    try {
      Database db = await initDb();
      final ResultSet resultSet = db.select(sql);
      result = jsonEncode(resultSet.toList());
      db.dispose();
    } catch (err) {
      print("error from builder query $err");
    }

    if (result != null) {
      return jsonDecode(result);
    } else {
      return null;
    }
  }

  ///
  ///simple SELECT QUERY return JSON data
  ///[@param=> String sql] : table name
  ///
  static Future rawQuery(String sql) async {
    var result;
    try {
      Database db = await initDb();
      final ResultSet resultSet = db.select(sql);
      result = jsonEncode(resultSet.toList());
      db.dispose();
    } catch (err) {
      print("error from rawQuery: $err");
    }
    if (result != null) {
      return jsonDecode(result);
    } else {
      return null;
    }
  }

  ///
  ///sql insert statment
  ///[@param=> tableName] : table name
  ///[@param=> values] : Map<String, dynamic> values
  ///
  static Future insert(String tableName, Map<String, dynamic> values) async {
    final insert = StringBuffer();
    insert.write('INSERT');

    insert.write(' INTO ');
    insert.write(' $tableName');
    insert.write('(');

    final size = (values != null) ? values.length : 0;

    if (size > 0) {
      final sbValues = StringBuffer(') VALUES(');

      var i = 0;
      values.forEach((String colName, dynamic value) {
        if (i++ > 0) {
          insert.write(',');
          sbValues.write(',');
        }
        insert.write(' $colName');
        sbValues.write("'$value'");
      });
      insert.write(sbValues);
    } else {
      throw ArgumentError('column required when inserting data');
    }
    insert.write(')');
    String sql = insert.toString();
    int lastInsertId;

    try {
      Database database = await initDb();
      final stmt = database.prepare(sql);
      stmt.execute();
      stmt.dispose();
      final ResultSet resultSet = database.select("SELECT * FROM $tableName");
      var lastRow = resultSet.last.values;
      lastInsertId = lastRow.first;
      database.dispose();
    } catch (err) {
      print("error from insert statment: $err");
    }
    if (lastInsertId != null) {
      return lastInsertId;
    } else {
      return null;
    }
  }

  static Future rawInsert(String sql, {String table}) async {
    var lastRow;

    try {
      Database database = await initDb();
      final stmt = database.prepare(sql);
      stmt.execute();
      stmt.dispose();
      final ResultSet resultSet = database.select("SELECT * FROM $table");
      lastRow = jsonEncode(resultSet.last.values.toList());

      database.dispose();
    } catch (err) {
      print("error from insert statment: $err");
    }
    if (lastRow != null) {
      return lastRow;
    } else {
      return null;
    }
  }

  ///
  ///sql query represent UPDATE Statment
  ///[@param=> tableName] : table name
  ///[@param=> values] : Map<String, dynamic> values
  ///[@param=> where] : where clause,
  ///[@param=> whereArgs] : where arguments
  ///
  static Future update(
    String tableName,
    Map<String, dynamic> values, {
    String where,
    List<dynamic> whereArgs,
  }) async {
    if (values == null || values.isEmpty) {
      throw ArgumentError('Empty values');
    }

    final update = StringBuffer();
    update.write('UPDATE');

    update.write(' $tableName');
    update.write(' SET ');
    var i = 0;

    values.keys.forEach((String colName) {
      update.write((i++ > 0) ? ', ' : '');
      update.write(colName);
      final dynamic value = values[colName];
      if (value != null) {
        update.write(" = '$value'");
      } else {
        update.write(' = NULL');
      }
    });

    writeClause(update, ' WHERE ', where);
    whereArgs.forEach((arg) {
      update.write(' = $arg');
    });
    int lastUpdateId;

    try {
      String sql = update.toString();
      Database database = await initDb();
      final stmt = database.prepare(sql);

      stmt.execute();
      stmt.dispose();
      final ResultSet resultSet = database
          .select("SELECT * FROM $tableName WHERE $where = ${whereArgs[0]}");
      var lastRow = resultSet.last.values;
      lastUpdateId = lastRow.first;
      database.dispose();
    } catch (err) {
      print("error from update statment: $err");
    }
    if (lastUpdateId != null) {
      return lastUpdateId;
    } else {
      return null;
    }
  }

  ///
  ///Delete statment
  ///[@param=> table] : table name
  ///[@param=> where] : where clause
  ///[@param=> whereArgs] : where arguments
  ///
  static Future delete(
    String tableName, {
    String where,
    List<dynamic> whereArgs,
  }) async {
    final delete = StringBuffer();
    delete.write('DELETE FROM ');
    delete.write(tableName);
    if (where != null) {
      writeClause(delete, ' WHERE ', where);
    }
    if (whereArgs != null) {
      whereArgs.forEach((arg) {
        delete.write(' = $arg');
      });
    }

    int lastDeletedId;
    try {
      String sql = delete.toString();
      Database database = await initDb();
      final ResultSet resultSet = database
          .select("SELECT * FROM $tableName WHERE $where ='${whereArgs[0]}'");
      var lastRow = resultSet.last.values;
      lastDeletedId = lastRow.first;
      //delete statment
      final stmt = database.prepare(sql);
      stmt.execute();
      stmt.dispose();
      database.dispose();
    } catch (err) {
      print("error from SQL delete statment $err");
    }
    if (lastDeletedId != null) {
      return lastDeletedId;
    } else {
      return null;
    }
  }

  static Future rawDelete({String sql}) async {
    try {
      String sql = delete.toString();
      Database database = await initDb();
      final stmt = database.prepare(sql);
      stmt.execute();
      stmt.dispose();
      database.dispose();
    } catch (err) {}
  }

  static void writeClause(StringBuffer s, String name, String clause) {
    if (clause != null) {
      s.write(name);
      s.write(clause);
    }
  }

  static void writeColumns(StringBuffer s, List<String> columns) {
    final n = columns.length;

    for (var i = 0; i < n; i++) {
      final column = columns[i];

      if (column != null) {
        if (i > 0) {
          s.write(', ');
        }
        s.write(column);
      }
    }
    s.write(' ');
  }
}

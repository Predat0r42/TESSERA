import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'module_storage.g.dart';

class ModuleStorageEntries extends Table {
  TextColumn get moduleId => text()();
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {moduleId, key};
}

@DriftDatabase(tables: [ModuleStorageEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Returns parsed JSON value if possible, otherwise raw string.
  Future<dynamic> getValue(String moduleId, String key) async {
    final q = select(moduleStorageEntries)
      ..where((t) => t.moduleId.equals(moduleId) & t.key.equals(key));
    final row = await q.getSingleOrNull();
    if (row == null || row.value == null) return null;
    try {
      return json.decode(row.value!);
    } catch (_) {
      return row.value;
    }
  }

  Future<void> setValue(String moduleId, String key, dynamic value) async {
    final encoded = json.encode(value);
    await into(moduleStorageEntries).insertOnConflictUpdate(
      ModuleStorageEntriesCompanion(
        moduleId: Value(moduleId),
        key: Value(key),
        value: Value(encoded),
      ),
    );
  }

  Future<void> deleteValue(String moduleId, String key) async {
    await (delete(moduleStorageEntries)
          ..where((t) => t.moduleId.equals(moduleId) & t.key.equals(key)))
        .go();
  }

  /// Load all entries for a given module as a map key->value (decoded JSON).
  Future<Map<String, dynamic>> getAllForModule(String moduleId) async {
    final rows = await (select(moduleStorageEntries)
          ..where((t) => t.moduleId.equals(moduleId)))
        .get();
    final out = <String, dynamic>{};
    for (final r in rows) {
      if (r.value == null) {
        out[r.key] = null;
        continue;
      }
      try {
        out[r.key] = json.decode(r.value!);
      } catch (_) {
        out[r.key] = r.value;
      }
    }
    return out;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = '${docs.path}/tessera.db';
    // Print DB path for diagnostics so we can inspect the file externally.
    try {
      // ignore: avoid_print
      print('[db-debug] AppDatabase path: $dbPath');
    } catch (_) {}
    final file = File(dbPath);
    return NativeDatabase(file);
  });
}

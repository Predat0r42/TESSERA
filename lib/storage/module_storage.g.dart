// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_storage.dart';

// ignore_for_file: type=lint
class $ModuleStorageEntriesTable extends ModuleStorageEntries
    with TableInfo<$ModuleStorageEntriesTable, ModuleStorageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleStorageEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
      'module_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [moduleId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_storage_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ModuleStorageEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId, key};
  @override
  ModuleStorageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleStorageEntry(
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module_id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
    );
  }

  @override
  $ModuleStorageEntriesTable createAlias(String alias) {
    return $ModuleStorageEntriesTable(attachedDatabase, alias);
  }
}

class ModuleStorageEntry extends DataClass
    implements Insertable<ModuleStorageEntry> {
  final String moduleId;
  final String key;
  final String? value;
  const ModuleStorageEntry(
      {required this.moduleId, required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  ModuleStorageEntriesCompanion toCompanion(bool nullToAbsent) {
    return ModuleStorageEntriesCompanion(
      moduleId: Value(moduleId),
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory ModuleStorageEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleStorageEntry(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  ModuleStorageEntry copyWith(
          {String? moduleId,
          String? key,
          Value<String?> value = const Value.absent()}) =>
      ModuleStorageEntry(
        moduleId: moduleId ?? this.moduleId,
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
      );
  ModuleStorageEntry copyWithCompanion(ModuleStorageEntriesCompanion data) {
    return ModuleStorageEntry(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleStorageEntry(')
          ..write('moduleId: $moduleId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(moduleId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleStorageEntry &&
          other.moduleId == this.moduleId &&
          other.key == this.key &&
          other.value == this.value);
}

class ModuleStorageEntriesCompanion
    extends UpdateCompanion<ModuleStorageEntry> {
  final Value<String> moduleId;
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const ModuleStorageEntriesCompanion({
    this.moduleId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModuleStorageEntriesCompanion.insert({
    required String moduleId,
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : moduleId = Value(moduleId),
        key = Value(key);
  static Insertable<ModuleStorageEntry> custom({
    Expression<String>? moduleId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModuleStorageEntriesCompanion copyWith(
      {Value<String>? moduleId,
      Value<String>? key,
      Value<String?>? value,
      Value<int>? rowid}) {
    return ModuleStorageEntriesCompanion(
      moduleId: moduleId ?? this.moduleId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleStorageEntriesCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ModuleStorageEntriesTable moduleStorageEntries =
      $ModuleStorageEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [moduleStorageEntries];
}

typedef $$ModuleStorageEntriesTableCreateCompanionBuilder
    = ModuleStorageEntriesCompanion Function({
  required String moduleId,
  required String key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $$ModuleStorageEntriesTableUpdateCompanionBuilder
    = ModuleStorageEntriesCompanion Function({
  Value<String> moduleId,
  Value<String> key,
  Value<String?> value,
  Value<int> rowid,
});

class $$ModuleStorageEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ModuleStorageEntriesTable> {
  $$ModuleStorageEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$ModuleStorageEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ModuleStorageEntriesTable> {
  $$ModuleStorageEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$ModuleStorageEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModuleStorageEntriesTable> {
  $$ModuleStorageEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ModuleStorageEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModuleStorageEntriesTable,
    ModuleStorageEntry,
    $$ModuleStorageEntriesTableFilterComposer,
    $$ModuleStorageEntriesTableOrderingComposer,
    $$ModuleStorageEntriesTableAnnotationComposer,
    $$ModuleStorageEntriesTableCreateCompanionBuilder,
    $$ModuleStorageEntriesTableUpdateCompanionBuilder,
    (
      ModuleStorageEntry,
      BaseReferences<_$AppDatabase, $ModuleStorageEntriesTable,
          ModuleStorageEntry>
    ),
    ModuleStorageEntry,
    PrefetchHooks Function()> {
  $$ModuleStorageEntriesTableTableManager(
      _$AppDatabase db, $ModuleStorageEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleStorageEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModuleStorageEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModuleStorageEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> moduleId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModuleStorageEntriesCompanion(
            moduleId: moduleId,
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String moduleId,
            required String key,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModuleStorageEntriesCompanion.insert(
            moduleId: moduleId,
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModuleStorageEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ModuleStorageEntriesTable,
        ModuleStorageEntry,
        $$ModuleStorageEntriesTableFilterComposer,
        $$ModuleStorageEntriesTableOrderingComposer,
        $$ModuleStorageEntriesTableAnnotationComposer,
        $$ModuleStorageEntriesTableCreateCompanionBuilder,
        $$ModuleStorageEntriesTableUpdateCompanionBuilder,
        (
          ModuleStorageEntry,
          BaseReferences<_$AppDatabase, $ModuleStorageEntriesTable,
              ModuleStorageEntry>
        ),
        ModuleStorageEntry,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ModuleStorageEntriesTableTableManager get moduleStorageEntries =>
      $$ModuleStorageEntriesTableTableManager(_db, _db.moduleStorageEntries);
}

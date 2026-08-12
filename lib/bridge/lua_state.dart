import 'package:lua_dardo/lua.dart' as dardo;
import 'package:flutter/foundation.dart';

// Enable verbose Lua debug output only when debugging and this flag is true.
const bool kVerboseLuaDebug = false;

/// Обёртка над конкретной Lua-реализацией.
///
/// ВАЖНО: это единственный файл, который должен измениться, если мы
/// поменяем lua_dardo на FFI (или наоборот). Всё остальное приложение
/// работает через этот интерфейс и не знает, что там внутри на самом деле.
abstract class LuaState {
  /// Создаёт новый независимый интерпретатор (один на модуль).
  factory LuaState.create() => DardoLuaState();

  /// Выполняет Lua-код (загрузка модуля целиком).
  void doString(String source);

  /// Регистрирует Dart-функцию как функцию внутри namespace, например
  /// time.now или ui.text.
  void registerFunction(
    String namespace,
    String name,
    dynamic Function(List<dynamic> args) fn,
  );

  /// Достаёт глобальную переменную/таблицу по имени (например, "module").
  dynamic getGlobal(String name);

  /// Вызывает функцию Lua по ссылке (обычно — таблица module, поле fnName).
  dynamic callField(dynamic table, String fieldName, [List<dynamic> args = const []]);

  /// Освобождает интерпретатор при выгрузке модуля.
  void dispose();
}

class DardoLuaState implements LuaState {
  final dardo.LuaState _ls;
  final Map<int, LuaFunctionHandle> _functions = {};
  int _nextFunctionId = 1;

  DardoLuaState() : _ls = dardo.LuaState.newState() {
    _ls.openLibs();
    _ensureCallbackTable();
  }

  @override
  void doString(String source) {
    _ls.doString(source);
  }

  @override
  void registerFunction(String namespace, String name,
      dynamic Function(List<dynamic> args) fn) {
    _ls.getGlobal(namespace);
    if (!_ls.isTable(-1)) {
      _ls.pop(1);
      _ls.newTable();
    }

    _ls.pushDartFunction((lua) {
      final argCount = lua.getTop();
      final args = <dynamic>[];
      for (var i = 1; i <= argCount; i++) {
        args.add(_convertLuaArg(lua, i));
      }

      final result = fn(args);
      if (result == null) {
        return 0;
      }

      if (result is List) {
        for (final item in result.reversed) {
          _pushValueToLua(lua, item);
        }
        return result.length;
      }

      _pushValueToLua(lua, result);
      return 1;
    });

    _ls.setField(-2, name);
    _ls.setGlobal(namespace);
  }

  @override
  dynamic getGlobal(String name) {
    _ls.getGlobal(name);
    if (_ls.isNil(-1)) {
      _ls.pop(1);
      return null;
    }

    if (name == 'module') {
      _ls.pop(1);
      return LuaGlobalRef(name);
    }

    final value = _convertLuaValue(_ls, -1);
    _ls.pop(1);
    return value;
  }

  @override
  dynamic callField(dynamic table, String fieldName, [List<dynamic> args = const []]) {
    if (table is LuaGlobalRef) {
      _ls.getGlobal(table.name);
    } else if (table is LuaFunctionHandle) {
      if (table.owner != this) {
        return table.owner.callField(table, fieldName, args);
      }
      return _invokeFunctionHandle(table, args);
    } else if (table is Map && table['__callback_id'] is int) {
      return _invokeFunctionHandle(LuaFunctionHandle(table['__callback_id'] as int, this), args);
    } else {
      throw StateError('Unsupported Lua table reference: $table');
    }

    if (fieldName.isNotEmpty) {
      _ls.getField(-1, fieldName);
    }

    final result = _invokeLuaValueAtTop(args);
    if (_ls.getTop() > 0) {
      _ls.pop(1);
    }
    return result;
  }

  @override
  void dispose() {}

  void _ensureCallbackTable() {
    _ls.getGlobal('__callbacks');
    if (!_ls.isTable(-1)) {
      _ls.pop(1);
      _ls.newTable();
      _ls.setGlobal('__callbacks');
    } else {
      _ls.pop(1);
    }
  }

  LuaFunctionHandle _registerLuaFunction(dardo.LuaState ls, int index) {
    _ensureCallbackTable();
    final id = _nextFunctionId++;

    ls.getGlobal('__callbacks');
    ls.pushValue(index);
    ls.setField(-2, id.toString());
    ls.pop(1);

    final handle = LuaFunctionHandle(id, this);
    _functions[id] = handle;
    return handle;
  }

  dynamic _invokeFunctionHandle(LuaFunctionHandle handle, List<dynamic> args) {
    _ensureCallbackTable();
    _ls.getGlobal('__callbacks');
    _ls.getField(-1, handle.id.toString());
    final result = _invokeLuaValueAtTop(args);
    if (_ls.getTop() > 0) {
      _ls.pop(1);
    }
    return result;
  }

  dynamic _invokeLuaValueAtTop(List<dynamic> args) {
    for (final arg in args) {
      _pushValueToLua(_ls, arg);
    }
    _ls.call(args.length, 1);
    final result = _convertLuaValue(_ls, -1);
    _ls.pop(1);
    return result;
  }

  dynamic _convertLuaArg(dardo.LuaState ls, int index) {
    final absIndex = ls.absIndex(index);
    if (ls.isNil(absIndex)) {
      return null;
    }
    if (ls.isBoolean(absIndex)) {
      return ls.toBoolean(absIndex);
    }
    if (ls.isInteger(absIndex)) {
      return ls.toInteger(absIndex);
    }
    if (ls.isNumber(absIndex)) {
      return ls.toNumber(absIndex);
    }
    if (ls.isString(absIndex)) {
      return ls.toStr(absIndex);
    }
    if (ls.isFunction(absIndex)) {
      return _registerLuaFunction(ls, absIndex);
    }
    if (ls.isTable(absIndex)) {
      return _tableToDart(ls, absIndex);
    }
    return null;
  }

  dynamic _convertLuaValue(dardo.LuaState ls, int index, [Set<Object?>? seen]) {
    final absIndex = ls.absIndex(index);
    if (ls.isNil(absIndex)) {
      return null;
    }
    if (ls.isBoolean(absIndex)) {
      return ls.toBoolean(absIndex);
    }
    if (ls.isInteger(absIndex)) {
      return ls.toInteger(absIndex);
    }
    if (ls.isNumber(absIndex)) {
      return ls.toNumber(absIndex);
    }
    if (ls.isString(absIndex)) {
      return ls.toStr(absIndex);
    }
    if (ls.isFunction(absIndex)) {
      return _registerLuaFunction(ls, absIndex);
    }
    if (ls.isTable(absIndex)) {
      return _tableToDart(ls, absIndex, seen);
    }
    return null;
  }

  void _pushValueToLua(dardo.LuaState ls, dynamic value) {
    if (value is int) {
      ls.pushInteger(value);
    } else if (value is double) {
      ls.pushNumber(value);
    } else if (value is String) {
      ls.pushString(value);
    } else if (value is bool) {
      ls.pushBoolean(value);
    } else if (value is List) {
      ls.newTable();
      for (var i = 0; i < value.length; i++) {
        _pushValueToLua(ls, value[i]);
        ls.setI(-2, i + 1);
      }
    } else if (value is Map) {
      if (value.containsKey('__callback_id') && value['__callback_id'] is int) {
        final callbackId = value['__callback_id'] as int;
        ls.getGlobal('__callbacks');
        ls.getField(-1, callbackId.toString());
        ls.remove(-2);
        return;
      }
      ls.newTable();
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is String) {
          _pushValueToLua(ls, entry.value);
          ls.setField(-2, key);
        }
      }
    } else if (value is LuaFunctionHandle) {
      ls.getGlobal('__callbacks');
      ls.getField(-1, value.id.toString());
      ls.remove(-2);
    } else if (value == null) {
      ls.pushNil();
    } else {
      ls.pushString(value.toString());
    }
  }

  /// Convert a Lua table to Dart. If the table is array-like (integer keys
  /// starting at 1 and contiguous) it returns a `List<dynamic>`, otherwise a
  /// `Map<String, dynamic>` (string keys). Mixed tables keep string keys in
  /// the map and numeric keys are added under their stringified keys.
  dynamic _tableToDart(dardo.LuaState ls, int index, [Set<Object?>? seen]) {
    seen ??= <Object?>{};
    final absIndex = ls.absIndex(index);
    final top = ls.getTop();

    // Use pointer identity to detect cycles.
    final ptr = ls.toPointer(absIndex);
    if (ptr != null) {
      if (seen.contains(ptr)) {
        // Cycle detected — return null to break recursion.
        return null;
      }
      seen.add(ptr);
    }

    final Map<String, dynamic> map = {};
    final Map<int, dynamic> intMap = {};
    var maxIndex = 0;

    ls.pushNil();
    int depthCounter = seen.length + 1;
    while (ls.next(absIndex)) {
      // key is at -2, value at -1
      if (ls.isInteger(-2)) {
        final k = ls.toInteger(-2);
        final v = _convertLuaValue(ls, -1, seen);
        intMap[k] = v;
        if (k > maxIndex) maxIndex = k;
      } else {
        final key = ls.toStr(-2);
        final value = _convertLuaValue(ls, -1, seen);
        if (key != null) map[key] = value;
      }
      // Debug trace: if recursion depth gets large, print a marker.
      if (depthCounter % 1000 == 0) {
        // ignore: avoid leaving heavy logging in production; temporary for debug
        final p = ls.toPointer(absIndex);
        if (kDebugMode && kVerboseLuaDebug) {
          // ignore: avoid_print
          print('[lua-debug] table depth=$depthCounter ptr=${p?.hashCode} key=${ls.toStr(-2)}');
        }
      }
      ls.pop(1);
      depthCounter++;
    }

    ls.setTop(top);

    // Decide whether to return a List or a Map. Return a List only if there
    // are no string keys (map.isEmpty) and integer keys are contiguous from
    // 1..maxIndex (i.e. maxIndex == number of integer entries). Otherwise
    // return a Map so named fields like 'type'/'label' are preserved.
    final isContiguousArray = intMap.isNotEmpty && map.isEmpty && maxIndex == intMap.length;

    // Debug: if this table appears to be a UI element (has 'type' key) or
    // decision is ambiguous, log the keys to help diagnose conversion issues.
    final shouldLog = map.containsKey('type') || (!isContiguousArray && (map.isNotEmpty || intMap.isNotEmpty));
    if (shouldLog) {
      try {
        if (kDebugMode && kVerboseLuaDebug) {
          // ignore: avoid_print
          print('[lua-debug] table keys stringKeys=${map.keys.toList()} intKeys=${intMap.keys.toList()} maxIndex=$maxIndex isContiguousArray=$isContiguousArray');
        }
      } catch (_) {}
    }

    if (map['type'] == 'button') {
      try {
        if (kDebugMode && kVerboseLuaDebug) {
          // ignore: avoid_print
          print('[lua-debug] ui.button table onTap=${map['onTap']} keys=${map.keys.toList()} intKeys=${intMap.keys.toList()}');
        }
      } catch (_) {}
    }

    if (isContiguousArray) {
      final list = List<dynamic>.filled(maxIndex, null, growable: false);
      for (final e in intMap.entries) {
        if (e.key >= 1 && e.key <= maxIndex) list[e.key - 1] = e.value;
      }
      return list;
    }

    // Mixed or string-keyed table: merge numeric keys as string keys.
    for (final e in intMap.entries) {
      map[e.key.toString()] = e.value;
    }

    return map;
  }
}

class LuaGlobalRef {
  final String name;

  const LuaGlobalRef(this.name);
}

class LuaFunctionHandle {
  final int id;
  final LuaState owner;

  const LuaFunctionHandle(this.id, this.owner);
}

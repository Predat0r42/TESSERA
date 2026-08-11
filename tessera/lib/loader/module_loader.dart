import 'package:flutter/services.dart' show rootBundle;

import '../bridge/bridge_functions.dart';
import '../bridge/lua_state.dart';
import '../models/module_instance.dart';

/// Единая точка загрузки модулей. Встроенные (assets/modules/*.lua) и
/// пользовательские (файл, импортированный через file_picker) проходят
/// РОВНО один и тот же путь. Разница только в источнике текста файла.
///
/// Если пользовательский модуль имеет тот же [id], что и встроенный,
/// он замещает его в реестре (см. ModuleRegistry.register).
class ModuleLoader {
  Future<ModuleInstance> loadBuiltin(String id) async {
    final source =
        await rootBundle.loadString('assets/modules/$id.lua');
    return _load(id, source);
  }

  Future<ModuleInstance> loadFromSource(String id, String source) async {
    return _load(id, source);
  }

  Future<ModuleInstance> _load(String id, String source) async {
    final lua = LuaState.create();
    registerBridge(lua, id);

    lua.doString(source);

    final moduleTable = lua.getGlobal('module');
    // Соглашение: файл обязан положить свою таблицу в глобальную `module`
    // (в примере ниже — `return M` плюс `module = M` в конце файла,
    // либо мы сами делаем `module = (...)` при загрузке — уточняется
    // при первой реальной интеграции с выбранным Lua-биндингом).

    final instance = ModuleInstance(id: id, lua: lua, moduleTable: moduleTable);

    // init(), если модуль его определяет.
    try {
      lua.callField(moduleTable, 'init');
    } catch (_) {
      // init необязателен — модуль вроде "Часов" может обойтись без него.
    }

    return instance;
  }
}

/// Реестр загруженных модулей по id — сюда попадают и встроенные,
/// и пользовательские, без разделения на "типы".
class ModuleRegistry {
  final Map<String, ModuleInstance> _modules = {};

  void register(ModuleInstance instance) {
    // Пользовательский модуль с тем же id молча замещает встроенный —
    // это и есть требуемая унификация.
    _modules[instance.id]?.dispose();
    _modules[instance.id] = instance;
  }

  ModuleInstance? get(String id) => _modules[id];

  List<ModuleInstance> get all => _modules.values.toList();
}

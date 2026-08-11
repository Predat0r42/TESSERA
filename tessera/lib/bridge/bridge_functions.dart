import '../event/event_bus.dart';
import 'lua_state.dart';

/// Регистрирует минимальный набор функций, нужный первым модулям
/// (Часы, Секундомер). Остальные (notify.*, storage.*, ui.input и т.д.)
/// добавляются по мере того, как в них появляется реальная потребность
/// у следующих модулей — не раньше.
///
/// [moduleId] нужен, чтобы storage.* (когда появится) писало данные
/// в изолированное пространство именно этого модуля.
void registerBridge(LuaState lua, String moduleId) {
  // --- time.* ---
  lua.registerFunction('time', 'now', (_) {
    return DateTime.now().millisecondsSinceEpoch;
  });

  lua.registerFunction('time', 'format', (args) {
    final ts = args[0] as int;
    final pattern = args.length > 1 ? args[1] as String : 'HH:mm:ss';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    // Заглушка простого форматтера — на реальный intl-based позже.
    String two(int n) => n.toString().padLeft(2, '0');
    return pattern
        .replaceAll('HH', two(dt.hour))
        .replaceAll('mm', two(dt.minute))
        .replaceAll('ss', two(dt.second));
  });

  // --- event.* --- (шина событий приложения, видимая из Lua)
  lua.registerFunction('event', 'on', (args) {
    final name = args[0] as String;
    final luaCallback = args[1]; // ссылка на Lua-функцию
    EventBus.instance.on(name, (data) {
      lua.callField(luaCallback, '', [data]);
    });
  });

  lua.registerFunction('event', 'emit', (args) {
    final name = args[0] as String;
    final data = args.length > 1 ? args[1] : null;
    EventBus.instance.emit(name, data);
  });

  // --- ui.* --- (только то, что нужно "Часам": текст и колонка)
  lua.registerFunction('ui', 'text', (args) {
    final content = args[0] as String;
    return {'type': 'text', 'content': content};
  });

  lua.registerFunction('ui', 'column', (args) {
    final children = args[0] as List;
    return {'type': 'column', 'children': children};
  });

  lua.registerFunction('ui', 'row', (args) {
    final children = args[0] as List;
    return {'type': 'row', 'children': children};
  });

  lua.registerFunction('ui', 'button', (args) {
    final label = args[0] as String;
    final onTap = args[1]; // ссылка на Lua-функцию
    return {'type': 'button', 'label': label, 'onTap': onTap};
  });

  // type: 'number' | 'text' | 'time' | 'date' — Renderer выбирает виджет
  // по этому полю (число дальше пригодится Будильнику/Календарю).
  lua.registerFunction('ui', 'input', (args) {
    final type = args[0] as String;
    final value = args.length > 1 ? args[1] : null;
    final onChanged = args.length > 2 ? args[2] : null;
    return {'type': 'input', 'inputType': type, 'value': value, 'onChanged': onChanged};
  });

  // --- notify.* ---
  lua.registerFunction('notify', 'show', (args) {
    final title = args[0] as String;
    final body = args.length > 1 ? args[1] as String : '';
    // TODO: реальный вызов flutter_local_notifications.
    // Пока просто пробрасываем событие в шину — HomeScreen может
    // показать SnackBar, пока нет настоящих push-уведомлений.
    EventBus.instance.emit('notify.show', {'title': title, 'body': body});
  });

  // --- storage.* --- (заглушка в памяти; на SQLite/drift — когда
  // появится реальная схема, см. TODO в README)
  lua.registerFunction('storage', 'get', (args) {
    final key = args[0] as String;
    return _memoryStorage['$moduleId:$key'];
  });

  lua.registerFunction('storage', 'set', (args) {
    final key = args[0] as String;
    final value = args[1];
    _memoryStorage['$moduleId:$key'] = value;
  });

  lua.registerFunction('storage', 'delete', (args) {
    final key = args[0] as String;
    _memoryStorage.remove('$moduleId:$key');
  });

  // TODO: schedule.after / schedule.at, http.* —
  // добавлять по одному, когда за ними приходит конкретный модуль.
}

/// Временное in-memory хранилище — заглушка до подключения drift.
/// Ключ уже включает moduleId, так что при переносе на SQLite
/// достаточно поменять реализацию этих трёх функций, вызовы из Lua
/// не изменятся.
final Map<String, dynamic> _memoryStorage = {};

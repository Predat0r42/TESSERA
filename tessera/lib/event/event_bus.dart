/// Внутренняя шина событий приложения.
/// Lua-функции event.on/event.emit из bridge_functions.dart — это тонкая
/// обёртка поверх этого класса.
class EventBus {
  EventBus._();
  static final EventBus instance = EventBus._();

  final Map<String, List<void Function(dynamic data)>> _listeners = {};

  void on(String eventName, void Function(dynamic data) handler) {
    _listeners.putIfAbsent(eventName, () => []).add(handler);
  }

  void off(String eventName, void Function(dynamic data) handler) {
    _listeners[eventName]?.remove(handler);
  }

  void emit(String eventName, [dynamic data]) {
    final handlers = _listeners[eventName];
    if (handlers == null) return;
    // Копия списка — обработчик может сам отписаться во время вызова.
    for (final h in List.of(handlers)) {
      h(data);
    }
  }
}

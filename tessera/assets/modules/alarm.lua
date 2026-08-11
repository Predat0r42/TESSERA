-- modules/alarm.lua
-- TESSERA · встроенный модуль (ЧЕРНОВИК, не запускать as-is)
--
-- Упрощённая версия без пакета rrule — проверяет день недели вручную
-- через os.date, а не через полноценный RRULE. Годится как первая
-- итерация (план: неделя 6), но не думайте, что это финальная логика
-- повторяемости для Календаря — там понадобится настоящий rrule.
--
-- ⚠️ Как и timer.lua, использует event.on("time.tick") — значит
-- звонить будет, только пока приложение открыто. Реальный будильник
-- обязан использовать schedule.at(...) с системным уведомлением
-- (см. docs/FUTURE.md).

local M = {}

-- days: 1=Вс, 2=Пн, ... 7=Сб (совпадает с os.date("*t").wday в Lua)
function M.init()
    local saved = storage.get("alarm") or {
        hour = 7, minute = 0,
        days = { [2] = true, [3] = true, [4] = true, [5] = true, [6] = true }, -- пн-пт
        enabled = true,
    }
    M.hour = saved.hour
    M.minute = saved.minute
    M.days = saved.days
    M.enabled = saved.enabled
    M.already_fired_today = false

    event.on("time.tick", M.onTick)
end

function M.save()
    storage.set("alarm", {
        hour = M.hour, minute = M.minute,
        days = M.days, enabled = M.enabled,
    })
end

function M.onTick()
    if not M.enabled then return end

    local now = os.date("*t")
    local today_matches = M.days[now.wday] == true

    if today_matches and now.hour == M.hour and now.min == M.minute then
        if not M.already_fired_today then
            notify.show("Будильник", "Подъём")
            M.already_fired_today = true
        end
    else
        -- сбрасываем флаг, как только минута прошла, чтобы
        -- на следующий день будильник снова смог сработать
        M.already_fired_today = false
    end
end

function M.onToggleEnabled()
    M.enabled = not M.enabled
    M.save()
end

function M.onHourChange(val)
    if val ~= nil then M.hour = val; M.save() end
end

function M.onMinuteChange(val)
    if val ~= nil then M.minute = val; M.save() end
end

function M.ui()
    local time_str = string.format("%02d:%02d", M.hour, M.minute)
    return ui.column({
        ui.text(time_str),
        ui.row({
            ui.input("number", M.hour, M.onHourChange),
            ui.input("number", M.minute, M.onMinuteChange),
        }),
        ui.button(M.enabled and "Выключить" or "Включить", M.onToggleEnabled)
        -- TODO: блоки выбора дней недели (пн-вс) как отдельные
        -- переключатели — нужен ui.switch, которого пока нет
        -- в Bridge (см. MODULE_API.md).
    })
end

module = M
return M

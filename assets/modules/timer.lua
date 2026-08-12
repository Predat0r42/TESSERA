-- modules/timer.lua
-- TESSERA · встроенный модуль
-- Таймер: пользователь задаёт минуты, идёт обратный отсчёт по
-- системному тику. Уведомление показывается через notify.show.
--
-- ВАЖНО (см. README): это версия на основе event.on("time.tick", ...),
-- то есть отсчёт идёт, пока приложение открыто. Настоящая надёжная
-- версия (переживающая сворачивание приложения) должна использовать
-- schedule.after(...) с системным отложенным уведомлением — это
-- Bridge-функция, которой ещё нет (см. TODO в bridge_functions.dart).
-- Меняется только реализация onStart ниже, остальное не тронется.

local M = {}

function M.init()
    M.input_minutes = 5
    M.remaining_seconds = 0
    M.running = false
end

function M.format(total_seconds)
    local m = math.floor(total_seconds / 60)
    local s = total_seconds % 60
    local s_str = tostring(s)
    if s < 10 then s_str = "0" .. s_str end
    return tostring(m) .. ":" .. s_str
end

function M.onTick()
    if not M.running then return end
    M.remaining_seconds = M.remaining_seconds - 1
    if M.remaining_seconds <= 0 then
        M.running = false
        event.off("time.tick", M.onTick)
        notify.show("Таймер", "Время вышло")
    end
end

function M.onStart()
    if M.running then return end
    M.remaining_seconds = M.input_minutes * 60
    M.running = true
    event.on("time.tick", M.onTick)
end

function M.onStop()
    M.running = false
    event.off("time.tick", M.onTick)
end

function M.onInputChange(val)
    if val ~= nil then
        M.input_minutes = val
    end
end

function M.ui()
    return ui.column({
        ui.text(M.running and M.format(M.remaining_seconds)
            or (tostring(M.input_minutes) .. " мин")),
        ui.input("number", M.input_minutes, M.onInputChange),
        ui.row({
            ui.button(M.running and "Стоп" or "Старт",
                M.running and M.onStop or M.onStart)
        })
    })
end

module = M
return M

-- modules/stopwatch.lua
-- TESSERA · встроенный модуль
-- Секундомер: старт / стоп / сброс. Состояние живёт только в памяти
-- (не пишется в storage) — если модуль перезагрузить, счёт обнулится.
-- Это осознанное упрощение первой версии, не баг.

local M = {}

function M.init()
    M.seconds = 0
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
    if M.running then
        M.seconds = M.seconds + 1
    end
end

function M.onStart()
    if M.running then return end
    M.running = true
    -- Подписываемся на тик только на время работы — не копим лишние
    -- подписки, если пользователь много раз жмёт старт/стоп.
    event.on("time.tick", M.onTick)
end

function M.onStop()
    M.running = false
    event.off("time.tick", M.onTick)
end

function M.onReset()
    M.seconds = 0
end

function M.ui()
    return ui.column({
        ui.text(M.format(M.seconds)),
        ui.row({
            ui.button(M.running and "Стоп" or "Старт",
                M.running and M.onStop or M.onStart),
            ui.button("Сброс", M.onReset)
        })
    })
end

module = M
return M

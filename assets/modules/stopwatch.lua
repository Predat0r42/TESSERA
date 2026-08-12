
-- modules/stopwatch.lua
-- TESSERA · встроенный модуль
-- Секундомер: старт / стоп / сброс. (Ранее состояние хранилось только в памяти;
-- теперь модуль сохраняет текущее значение в `storage`.)

local M = {}

function M.init()
    -- Restore persisted seconds (if any) so the stopwatch survives reloads.
    if storage and storage.get then
        local saved = storage.get('seconds')
        if saved ~= nil then
            M.seconds = saved
        else
            M.seconds = 0
        end
    else
        M.seconds = 0
    end
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
        if storage and storage.set then
            storage.set('seconds', M.seconds)
        end
    end
end

function M.onStart()
    if M.running then return end
    M.running = true
    -- Подписываемся на тик только на время работы — не копим лишние
    -- подписки, если пользователь много раз жмёт старт/стоп.
    event.on("time.tick", M.onTick)
    -- Для тестирования: сохраняем время старта в storage, чтобы
    -- проверить, что фоновые записи в SQLite действительно выполняются.
    if storage and storage.set then
        storage.set('last_started', time.now())
    end
end

function M.onStop()
    M.running = false
    event.off("time.tick", M.onTick)
end

function M.onReset()
    M.seconds = 0
    if storage and storage.set then
        storage.set('seconds', 0)
    end
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

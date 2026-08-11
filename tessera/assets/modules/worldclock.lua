-- modules/worldclock.lua
-- TESSERA · встроенный модуль (ЧЕРНОВИК, не запускать as-is)
--
-- ⚠️ Использует time.offset_hours(city), которой пока нет в Bridge
-- (см. docs/MODULE_API.md — раздел time.*). Нужно добавить на
-- Dart-стороне обёртку над пакетом `timezone` (план: неделя 4,
-- день 16), прежде чем этот модуль реально заработает.
--
-- Логика ниже написана заранее, чтобы явно зафиксировать, какая
-- именно Bridge-функция понадобится и в каком виде.

local M = {}

function M.init()
    -- Список городов хранится как таблица имён; timezone.offset_hours
    -- вернёт смещение в часах от UTC.
    M.cities = storage.get("cities") or { "Moscow", "London", "Tokyo" }
    M.new_city_input = ""
end

function M.format_city_time(city)
    local offset = time.offset_hours(city) -- TODO: Bridge-функция
    local ts = time.now() + (offset * 3600 * 1000)
    return city .. ": " .. time.format(ts, "HH:mm")
end

function M.onAddCity()
    if M.new_city_input == "" then return end
    table.insert(M.cities, M.new_city_input)
    storage.set("cities", M.cities)
    M.new_city_input = ""
end

function M.onRemoveCity(city)
    for i, c in ipairs(M.cities) do
        if c == city then
            table.remove(M.cities, i)
            break
        end
    end
    storage.set("cities", M.cities)
end

function M.onInputChange(val)
    M.new_city_input = val
end

function M.ui()
    local rows = {}
    for _, city in ipairs(M.cities) do
        table.insert(rows, ui.text(M.format_city_time(city)))
    end
    table.insert(rows, ui.input("text", M.new_city_input, M.onInputChange))
    table.insert(rows, ui.button("Добавить город", M.onAddCity))
    return ui.column(rows)
end

module = M
return M

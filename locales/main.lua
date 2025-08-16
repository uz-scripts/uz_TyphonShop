Locale = Locales[Customize.Locale or "en"]
exports("locale", function() return Locale end)

-- Dil çeviri fonksiyonu ekleniyor
function _U(str, ...)
    local translation
    local locale = Locales[Customize.Locale]
    
    if locale then
        -- Nested key desteği (örn: 'debug.vehicleCreated')
        if string.find(str, "%.") then
            local keys = {}
            for key in string.gmatch(str, "[^%.]+") do
                table.insert(keys, key)
            end
            
            translation = locale
            for _, key in ipairs(keys) do
                if type(translation) == "table" and translation[key] then
                    translation = translation[key]
                else
                    translation = str -- Anahtar bulunamazsa orijinal string'i kullan
                    break
                end
            end
        else
            -- Basit anahtar arama
            translation = locale[str] or str
        end
    else
        translation = str
    end
    
    -- Eğer ek parametreler varsa string.format kullan
    local args = {...}
    if #args > 0 then
        -- Translation'ın string olduğundan emin ol
        if type(translation) == "string" then
            local success, result = pcall(string.format, translation, table.unpack(args))
            if success then
                return result
            else
                -- Format hatası durumunda orijinal translation'ı döndür
                return translation
            end
        else
            return tostring(translation)
        end
    else
        return type(translation) == "string" and translation or tostring(translation)
    end
end
function SendMessage(action, data) SendNUIMessage({ action = action, data = data }) end

-- Start operations
Citizen.CreateThread(function()
    for locationName, coords in pairs(locationsConfig) do
        for index = 1, #coords do
            Services:Interact(locationName, coords[index])
        end
    end
end) 

-- ═══════════════════════════════════════════════════════════════════════════════════
-- BLIP 
-- ═══════════════════════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    for typeName, shop in pairs(config) do
        for locationName, coords in pairs(locationsConfig) do
            if locationName == typeName then
                if not shop?.blip?.hide then
                    local blip = AddBlipForCoord(locationName[coords])
                    SetBlipSprite(blip, shop.blip.id or 225)
                    SetBlipDisplay(blip, 4)
                    SetBlipScale(blip, shop.blip.scale or 0.8)
                    SetBlipColour(blip, shop.blip.color or 0)
                    SetBlipAsShortRange(blip, true)
                    
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(shop.label)
                    EndTextCommandSetBlipName(blip)
                    TriggerEvent('radialmenu:registerToggleableBlip', blip, 'shops')
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════════
-- PED 
-- ═══════════════════════════════════════════════════════════════════════════════════
ShopPed = {}

Citizen.CreateThread(function()
    for index, data in pairs(config) do
        if data?.npc?.showped then
            for locationName, coords in pairs(locationsConfig) do
                if data.type == locationName then
                    for i, coords in ipairs(coords) do 
                        local current = type(data?.npc?.ped) == 'number' and data?.npc?.ped or joaat(data?.npc?.ped)
                        RequestModel(current)
                        while not HasModelLoaded(current) do Wait(0) end
                        ShopPed[coords] = CreatePed(0, current, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
                        TaskStartScenarioInPlace(ShopPed[coords], data?.npc?.scenario, 0, true)
                        FreezeEntityPosition(ShopPed[coords], true)
                        SetEntityInvincible(ShopPed[coords], true)
                        SetBlockingOfNonTemporaryEvents(ShopPed[coords], true)
                    end
                end
            end
        end
    end
end)


local function deletePeds()
    for coords, v in pairs(ShopPed) do if DoesEntityExist(v) then DeletePed(v) end end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deletePeds()
end)


-- ═══════════════════════════════════════════════════════════════════════════════════
-- PRODUCT IMAGE PROCESSING
-- ═══════════════════════════════════════════════════════════════════════════════════

local function detectInventoryImagePath()
    local imagePaths = {
        ["ox_inventory"] = "nui://ox_inventory/web/images/",
    }

    -- Check for each inventory resource
    for inventoryName, path in pairs(imagePaths) do
        if GetResourceState(inventoryName) == "started" then
            Customize.ImagePath = path
            return true
        end
    end
    
    print("^1Warning: No compatible inventory detected, using default image path^0")
    return false
end

local function processProductImage(product, categoryType)
    if Customize.ImagePath == nil then
        detectInventoryImagePath()
    end

    if Customize.ImagePathEnabled and Customize.ImagePath then
        return Customize.ImagePath .. product.name .. '.png'
    end
    return "../img/" .. product.name
end

local function processCategory(category, categoryType)
    category.type = categoryType
    for _, product in pairs(category.products) do
        product.type = categoryType
        product.image = processProductImage(product, categoryType)
    end
end

-- Process all categories and their products
for categoryType, category in pairs(categoriesConfig) do
    processCategory(category, categoryType)
end
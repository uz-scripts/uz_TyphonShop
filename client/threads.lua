function SendMessage(action, data) SendNUIMessage({ action = action, data = data }) end

-- Start operations
Citizen.CreateThread(function()
    for _, shop in pairs(Customize.Locations) do
        if shop.interactType == 'target' then
            Services:Interact(shop)
        end
    end
end) 

-- ═══════════════════════════════════════════════════════════════════════════════════
-- MAIN MARKER AND INTERACTION THREAD
-- ═══════════════════════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        local Sleep = 2000
        
        if not IsNuiFocused() then
            local PlayerPed = PlayerPedId()
            local PlayerCoord = GetEntityCoords(PlayerPed)
            
            for _, shop in pairs(Customize.Locations) do
                local markerCoords = shop.coords
                local distance = #(PlayerCoord - vector3(markerCoords.x, markerCoords.y, markerCoords.z))
                
                if distance < 7.0 then
                    Sleep = 4
                    
                    -- For non-target interactions
                    if shop.interactType ~= 'target' then
                        Services:Interact(shop)
                    end
                    
                    -- Interaction distance check
                    if distance < 1.5 and shop.interactType ~= 'target' then
                        -- Display information on screen
                        Services:Drawtext(shop)
                        
                        -- Press E
                        if IsControlJustReleased(0, 38) then
                            Shop:Open(shop)
                        end
                    end
                end
            end
        else
            Sleep = 1000
        end
        
        Citizen.Wait(Sleep)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════════
-- BLIP 
-- ═══════════════════════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    for _, shop in pairs(Customize.Locations) do
        if not shop?.blip?.hide then
            local blip = AddBlipForCoord(shop.coords)
            SetBlipSprite(blip, shop.blip.id or 225)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, shop.blip.scale or 0.8)
            SetBlipColour(blip, shop.blip.color or 0)
            SetBlipAsShortRange(blip, true)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════════
-- PED 
-- ═══════════════════════════════════════════════════════════════════════════════════
ShopPed = {}

Citizen.CreateThread(function()
    for index, data in pairs(Customize.Locations) do
        if data?.npc?.showped then
            local current = type(data?.npc?.ped) == 'number' and data?.npc?.ped or joaat(data?.npc?.ped)
            RequestModel(current)
            while not HasModelLoaded(current) do Wait(0) end
            ShopPed[data.coords] = CreatePed(0, current, data.coords.x, data.coords.y, data.coords.z - 1, data.coords.w, false, false)
            TaskStartScenarioInPlace(ShopPed[data.coords], data?.npc?.scenario, 0, true)
            FreezeEntityPosition(ShopPed[data.coords], true)
            SetEntityInvincible(ShopPed[data.coords], true)
            SetBlockingOfNonTemporaryEvents(ShopPed[data.coords], true)
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
        ["qb-inventory"] = "nui://qb-inventory/html/images/",
        ["ox_inventory"] = "nui://ox_inventory/web/images/",
    }

    -- Check for each inventory resource
    for inventoryName, path in pairs(imagePaths) do
        if GetResourceState(inventoryName) == "started" then
            Customize.ImagePath = path
            print("^2Inventory detected: " .. inventoryName .. ", image path set to: " .. path .. "^0")
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
for categoryType, category in pairs(Customize.Category) do
    processCategory(category, categoryType)
end
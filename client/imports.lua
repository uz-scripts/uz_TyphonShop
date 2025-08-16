local interactionHandlers = {
    interact = function(shop, coords)
        return exports.interact:AddInteraction({
            coords = vec3(coords.x, coords.y, coords.z),
            distance = 8.0,
            interactDst = 1.0,
            id = 'shop_' .. shop .. '_' .. tostring(coords),
            options = {
                {
                    label = _U('target_open_shop'),
                    action = function()
                        Shop:Open(shop)
                    end,
                },
            }
        })
    end,
    
    target = function(shop, coords)
        return exports.ox_target:addBoxZone({
            coords = vec3(coords.x, coords.y, coords.z),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 0,
            options = {
                {
                    name = 'uz_TyphonShop',
                    icon = 'fas fa-cart-shopping',
                    label = _U('target_open_shop'),
                    onSelect = function()
                        Shop:Open(shop)
                    end
                }
            }
        })
    end
}

local cachedInteractHandler = interactionHandlers[Customize.Interaction]

if not cachedInteractHandler then
    lib.print.error(('could not find %s handler, Resource State: %s'):format(Customize.Interaction, GetResourceState(Customize.Interaction)))
end

function Services:Interact(shop, coords)
    if cachedInteractHandler then
        return cachedInteractHandler(shop, coords)
    end
end
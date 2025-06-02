function Services:Interact(self)
    if self.interactType == 'default' then
        if self.npc?.showped then
            local pedCoords = GetEntityCoords(ShopPed[self.coords])
            if pedCoords then
                -- Place the marker in front of the ped and a bit above
                local forward = GetEntityForwardVector(ShopPed[self.coords])
                local offset = vector3(
                    forward.x * 0.5, -- 0.5 units in the direction the ped is facing
                    forward.y * 0.5,
                    0.2 -- A bit above the ground
                )
                local markerCoords = pedCoords + offset
                self.setMarker(markerCoords)
            else
                -- If the ped is not found, use the default location
                self.setMarker(self.coords)
            end
        else
            self.setMarker(self.coords)
        end
    elseif self.interactType == 'target' then

        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:addBoxZone({
                coords = self.coords,
                size = vector3(2.0, 2.0, 2.0),
                rotation = 0,
                options = {
                    {
                        name = 'uz_TyphonShop',
                        icon = 'fas fa-cart-shopping',
                        label = _U('target_open_shop'),
                        onSelect = function()
                            Shop:Open(self)
                        end
                    }
                }
            })
        elseif GetResourceState('qb-target') == 'started'  then
            exports['qb-target']:AddBoxZone('uz_TyphonShop' .. math.random(1000), self.coords, 2.0, 2.0, {
                name = 'uz_TyphonShop',
                heading = 0,
                minZ = self.coords.z - 1.0,
                maxZ = self.coords.z + 1.0,
            }, {
                options = {
                    {
                        type = 'client',
                        icon = 'fas fa-cart-shopping',
                        label = _U('target_open_shop'),
                        action = function()
                            Shop:Open(self)
                        end
                    },
                },
                distance = 3.0
            })
        end
    end
end

function Services:Drawtext(self)
    if self.drawtextType == 'default' then
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(_U('press_to_open_shop'))
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
end
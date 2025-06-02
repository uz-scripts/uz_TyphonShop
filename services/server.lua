function Services:AddItem(source, item, amount, ...)
    print('Services:AddItem', source, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:AddItem(source, item, amount)
    elseif GetResourceState('qb-inventory') == 'started' then
        exports['qb-inventory']:AddItem(source, item, amount, false, nil, 'uz-shop')
    elseif GetResourceState('esx_inventory') == 'started' then
        exports.esx_inventory:AddItem(source, item, amount)
    end
end
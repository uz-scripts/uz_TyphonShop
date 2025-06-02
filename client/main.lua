Shop, Services = {}, {}

function Shop:getItemsFormatted(shop)
    local formattedData = {
        categories = {},
        products = {}
    }
    
    -- For each category
    for _, categoryName in pairs(shop.products) do
        local category = Customize.Category[categoryName]
        if category then
            -- Add category information
            table.insert(formattedData.categories, {
                name = category.name,
                type = categoryName,
                image = category.image
            })
            
            -- Add products from this category
            for _, product in pairs(category.products) do
                -- Set product image
                local imageUrl = Customize.ImagePathEnabled and Customize.ImagePath 
                    and (Customize.ImagePath .. product.name .. '.png')
                    or ("../img/" .. product.name)
                
                -- Add product information
                table.insert(formattedData.products, {
                    name = product.name,
                    label = product.label,
                    price = product.price,
                    image = imageUrl,
                    category = categoryName
                })
            end
        end
    end
    
    return formattedData
end

function Shop:Open(shop)
    self.currentShop = shop
    local formattedData = self:getItemsFormatted(shop)

    local paymentAccounts = lib.callback.await('uz_TyphonShop:server:getPaymentAccounts', false)
    
    SetNuiFocus(true, true)
    SendMessage('setOpen', {
        isVisible = true,
        categories = formattedData.categories,
        products = formattedData.products,
        producerSupport = shop.producerSupport,
        locale = Locales[Customize.Locale].ui,
        paymentAccounts = paymentAccounts
    })
end

function Shop:Close()
    SetNuiFocus(false, false)
    SendMessage('setOpen', { isVisible = false })

    self.currentShop = nil
end

RegisterNUICallback('close', function(data) Shop:Close() end)

RegisterNUICallback('purchaseItem', function(data, cb)
    local success = lib.callback.await('uz_TyphonShop:server:purchaseItem', false, data)
    cb(success)
end)
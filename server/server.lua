
lib.callback.register('uz_TyphonShop:server:getPaymentAccounts', function(source)
  local playerID = tonumber(source)
  if not playerID then
    return { success = false, message = "Invalid player ID" }
  end
    
  local playerData = Compatibility.Server.GetPlayer(playerID)
  if not playerData then
    return { success = false, message = "Player not found" }
  end
    
  local playerCash = Compatibility.Server.GetPlayerBalance(playerID, "cash") or 0
  local playerBank = Compatibility.Server.GetPlayerBalance(playerID, "bank") or 0

  return {
    cash = playerCash,
    bank = playerBank
  }
end)



lib.callback.register('uz_TyphonShop:server:purchaseItem', function(source, data)
  local playerID = tonumber(source)
  if not playerID then
    return { success = false, message = "Invalid player ID" }
  end

  local playerData = Compatibility.Server.GetPlayer(playerID)
  if not playerData then
    return { success = false, message = "Player not found" }
  end

  local playerBalance = Compatibility.Server.GetPlayerBalance(playerID, data.type)
  if playerBalance < data.total then
    return { success = false, message = "Insufficient balance - required: " .. data.total .. ", balance: " .. playerBalance }
  end
  
  if not Compatibility.Server.RemoveMoney(playerID, data.type, data.total) then
    return { success = false, message = "Payment failed" }
  end

  for _, item in ipairs(data.items) do
    -- local itemData = Compatibility.Server.GetItemData(itemName)
    -- if not itemData then
    --   return { success = false, message = "Item not found" }
    -- end

    -- local playerInventory = Compatibility.Server.GetPlayerInventory(playerID)
    -- if not playerInventory then
    --   return { success = false, message = "Player inventory not found" }
    -- end

    Services:AddItem(playerID, item?.name, item?.amount)
  end

  local playerCash = Compatibility.Server.GetPlayerBalance(playerID, "cash") or 0
  local playerBank = Compatibility.Server.GetPlayerBalance(playerID, "bank") or 0

  return {
    success = true,
    message = "Payment successful",
    paymentAccounts = {
      cash = playerCash,
      bank = playerBank
  }}
end)
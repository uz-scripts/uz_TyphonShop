QBCore, ESX, Services = nil, nil, {}
Compatibility = {
  Client = {},
  Server = {}
}

if (Customize.Framework == nil and GetResourceState("qbx_core") == "started") or Customize.Framework == "Qbox" then
  Customize.Framework = "Qbox"
elseif (Customize.Framework == nil and GetResourceState("qb-core") == "started") or Customize.Framework == "QBCore" then
  QBCore = exports['qb-core']:GetCoreObject()
  Customize.Framework = "QBCore"
elseif (Customize.Framework == nil and GetResourceState("es_extended") == "started") or Customize.Framework == "ESX" then
  ESX = exports["es_extended"]:getSharedObject()
  Customize.Framework = "ESX"
else
  error("^1ERROR:^7 You must set the Customize.Framework value to \"QBCore\", \"ESX\" or \"Qbox\"!")
end


-- Compatibility Functions

function Compatibility.Server.GetPlayer(src)
  if not src then return nil end
    
  if Customize.Framework == "QBCore" then
    return QBCore.Functions.GetPlayer(src)
  elseif Customize.Framework == "Qbox" then
    return exports.qbx_core:GetPlayer(src)
  elseif Customize.Framework == "ESX" then
    return ESX.GetPlayerFromId(src)
  end
    
  return nil
end
  

function Compatibility.Server.GetPlayerBalance(src, type)
  if not src or not type then return 0 end
    
  local player = Compatibility.Server.GetPlayer(src)
  if not player then return 0 end
  
  if type == "custom" then
    return 0
  elseif Customize.Framework == "QBCore" or Customize.Framework == "Qbox" then
    return player.PlayerData.money[type] or 0
  elseif Customize.Framework == "ESX" then
    if type == "cash" then type = "money" end
    for _, data in pairs(player.getAccounts()) do
      if data.name == type then
        return data.money
      end
    end
  end
  
  return 0
end
  
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end


function Compatibility.Server.RemoveMoney(src, account, amount)
  if not src or not account or not amount or amount <= 0 then
    return false
  end
  
  local player = Compatibility.Server.GetPlayer(src)
  if not player then 
    return false 
  end
  
  amount = round(amount, 0)
  
  local balance = Compatibility.Server.GetPlayerBalance(src, account)
  if balance < amount then
    return false
  end
  
  local success = false
  
  if account == "custom" then
    return false
  elseif Customize.Framework == "QBCore" or Customize.Framework == "Qbox" then
    success = player.Functions.RemoveMoney(account, amount)
  elseif Customize.Framework == "ESX" then
    if account == "cash" then account = "money" end
    success = player.removeAccountMoney(account, amount)
  end
  
  return success
end
Compatibility = {
  Client = {},
  Server = {}
}

-- Compatibility Functions

function Compatibility.Server.GetPlayer(src)
  if not src then return nil end
  return exports.qbx_core:GetPlayer(src)
end
  

function Compatibility.Server.GetPlayerBalance(src, type)
  if not src or not type then return 0 end
    
  local player = Compatibility.Server.GetPlayer(src)
  if not player then return 0 end
  
  return player.PlayerData.money[type] or 0
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
  
  success = player.Functions.RemoveMoney(account, amount)
  
  return success
end
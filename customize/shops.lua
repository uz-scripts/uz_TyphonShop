Customize.Locations = {
    {
        label = 'UZ Script 24/7 Supermarket',
        coords = vector4(32.6, -1347.8, 29.5, 91.34),
        products = { 'normal', 'water' },
        npc = { showped = true, ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_MOBILE', radius = 1.5 },
        blip = { hide = false, id = 477, color = 2, scale = 0.6 },
        interactType = 'target', -- default: marker, target: qb-target, ox_target
        drawtextType = 'default', -- default: fivem
        setMarker = function(coords) -- DrawMarker: https://docs.fivem.net/natives/?_0x28477EC23D892089
            DrawMarker(21, coords.x, coords.y, coords.z + (math.sin(GetGameTimer() / 1000 * 3) * 0.1 + 0.1), 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 120, false, true, 2, nil, nil, false)
        end,
    },
}
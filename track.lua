-- ====================================================================
-- SCRIPT: BloxKid_EventMonitor.lua (CHỈ DÙNG ĐỂ DÒ BOSS & EVENT)
-- ====================================================================
repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService('HttpService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Hàm tìm quái nhanh trong Workspace/Storage
local findMob = function(mobName)
    return workspace.Enemies:FindFirstChild(mobName) or ReplicatedStorage:FindFirstChild(mobName)
end

-- Hàm quét quái Pirate Raid (Castle Sea 3)
function GetPirateRaidMob(x)
    local Mob
    local castlePos = Vector3.new(-5545.9873046875, 314.0802307128906, -2964.34912109375)
    local targetFolder = x and workspace.Enemies or ReplicatedStorage
    
    for _, v in ipairs(targetFolder:GetChildren()) do
        if v:IsA('Model') and v:FindFirstChild("HumanoidRootPart") then
            if (v.HumanoidRootPart.Position - castlePos).magnitude <= 1000 and not v:GetAttribute('IsBoss') then
                Mob = v
                break
            end
        end
    end
    return Mob
end

-- Kiểm tra Mặt Trăng cho Sea 3
function checkSea3()
    return tonumber(workspace:GetAttribute("MAP"):match("%d+")) == 3
end

local getMoon = function()
    if not checkSea3() then return "nil" end
    local lighting = game.Lighting
    local sky = lighting:FindFirstChild("Sky") or lighting:FindFirstChild("Space_Skybox")
    local tex = sky and sky.MoonTextureId or ""
    tex = tex:gsub("rbxassetid://", "http://www.roblox.com/asset/?id=")

    return ({
        ["http://www.roblox.com/asset/?id=15493317929"] = "Blue Moon",
        ["http://www.roblox.com/asset/?id=9709149431"] = "8/8",
        ["http://www.roblox.com/asset/?id=9709149052"] = "7/8",
        ["http://www.roblox.com/asset/?id=9709143733"] = "6/8"
    })[tex] or "nil"
end

local getMoonPhase = function()
    local moonphase = game.Lighting:GetAttribute("MoonPhase")
    if not moonphase then return "Unknown" end
    if moonphase == 5 and not getgenv().isfmended then return "Full Moon" end
    return "Normal Moon"
end

-- HÀM THU THẬP VÀ ĐẨY EVENT LÊN FILE XỬ LÝ RIÊNG
local scanAndPostEvents = function()
    local bodyData = {}
    local playerMax = `{#game.Players:GetPlayers()}/{game.Players.MaxPlayers}`
    
    -- Danh sách Boss Elite
    local EliteList = {'Diablo', 'Urban', 'Deandre'}
    
    -- Danh sách Boss Hiếm & Boss Farm mục tiêu (Đã thêm Darkbeard và dàn Boss Sea 3 chuẩn game)
    local RareBossList = {
        'rip_indra True Form', 'Dough King', 'Cake Prince', 'Soul Reaper', 'Cursed Captain',
        'Darkbeard', 'Stone', 'Island Empress', 'Beautiful Pirate', 'Kilo Admiral', 'Captain Elephant'
    }

    -- 1. Quét Boss Elite
    for _, name in pairs(EliteList) do
        if findMob(name) then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Elite', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Elite'] = name})
        end
    end

    -- 2. Quét Boss Hiếm & Boss Farm
    for _, name in pairs(RareBossList) do
        if findMob(name) then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Rare Boss', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Rare Boss'] = name})
        end
    end

    -- 3. Quét Pirate Raid (Castle)
    if GetPirateRaidMob(rawget(getgenv(), "scanStorage") or false) or GetPirateRaidMob(true) then
        table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Castle', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
    end

    -- 4. Quét Đảo Bí Ẩn (Mirage Island)
    if workspace.Map:FindFirstChild('MysticIsland') then
        table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Mirage', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
    end

    -- 5. Quét Trăng Tròn (Full Moon)
    if getMoon() == "8/8" and getMoonPhase() == "Full Moon" then
        table.insert(bodyData, {
            ['Players'] = playerMax, ['Type'] = 'Moon', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId,
            ['ClockTime'] = game.Lighting.ClockTime, ['MoonPhase'] = "Full Moon up"
        })
    end

    -- Nếu phát hiện bất kỳ sự kiện nào thì tiến hành POST lên file handle_event.php
    if #bodyData > 0 then
        request({
            Url = "http://113.165.150.162:8000/api/handle_event.php", -- URL tới cổng 8080 cục bộ của bạn
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(bodyData)
        })
    end
end

-- Vòng lặp quét độc lập 10 giây/lần
task.spawn(function()
    local plr = game.Players.LocalPlayer
    repeat task.wait() until plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("Main (minimal)")
    
    while true do
        pcall(scanAndPostEvents)
        task.wait(10) -- Tần suất cập nhật phòng chứa boss nhanh chóng
    end
end)

print("[Blox Kid Event Monitor]: Hệ thống truyền tải sự kiện độc lập đã bật!")

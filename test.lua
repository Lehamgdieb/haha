-- =====================================================================
-- FILE 1: KAITUN & FARM MODULES (TÍCH HỢP AUTO KICK KHI HOÀN THÀNH MÓN ĐỒ)
-- =====================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService('HttpService')

-- URL lấy Key hệ thống Night Hub
local KeyUrl = "http://14.233.28.141:8000/api.php" 

-- Hàm quét nhanh vật phẩm trong người và hòm đồ ẩn
local function hasItem(itemName)
    if not plr then return false end
    local inventory = plr:FindFirstChild("Backpack") 
    local character = plr.Character
    local inventoryData = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    
    if inventory and inventory:FindFirstChild(itemName) then return true end
    if character and character:FindFirstChild(itemName) then return true end
    
    local success, invTable = pcall(function() 
        return inventoryData:InvokeServer("getInventory") 
    end)
    if success and type(invTable) == "table" then
        for _, item in pairs(invTable) do
            if item.Name == itemName then return true end
        end
    end
    return false
end

-- =====================================================================
-- CHỨC NĂNG KIỂM TRA ĐIỀU KIỆN RẼ NHÁNH SCRIPT
-- =====================================================================
local function CheckItemsAndGetScriptRoute()
    if not plr then return "banana" end
    
    local levelData = plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level")
    local currentLevel = levelData and levelData.Value or 0
    
    -- Chỉ xử lý điều kiện khi đạt cấp tối đa 2700
    if currentLevel >= 2700 then
        local hasTushita = hasItem("Tushita")
        local hasValkyrie = hasItem("Valkyrie Helm")
        local hasMirror = hasItem("Mirror Fractal")

        -- NẾU THIẾU ÍT NHẤT 1 TRONG 3 MÓN -> ÉP CHẠY NIGHT HUB
        if not hasTushita or not hasValkyrie or not hasMirror then
            local folderName = "Night Hub Hop Rewrite"
            local fileName = string.format("%s/%s-Gay.json", folderName, plr.Name)
            
            if makefolder and not isfolder(folderName) then
                makefolder(folderName)
            end

            local configData = {}
            if not hasTushita then
                configData = {
                    ["Select Boss"] = "",
                    ["Auto Tushita [HOP]"] = true,
                    ["Auto Tushita"] = true,
                    ["Select Tool"] = "Melee"
                }
                print("[Hệ Thống] Thiếu Tushita -> Cấu hình file săn Tushita.")
            elseif not hasValkyrie then
                configData = {
                    ["Select Tool"] = "Melee",
                    ["Auto Kill Boss"] = true,
                    ["Auto Execute Script"] = true,
                    ["Auto Kill Boss [HOP]"] = true,
                    ["Select Boss"] = "rip_indra"
                }
                print("[Hệ Thống] Thiếu Valkyrie Helm -> Cấu hình file săn rip_indra.")
            elseif not hasMirror then
                configData = {
                    ["Select Tool"] = "Melee",
                    ["Auto Kill Boss"] = true,
                    ["Auto Execute Script"] = true,
                    ["Auto Kill Boss [HOP]"] = true,
                    ["Select Boss"] = "Dough King"
                }
                print("[Hệ Thống] Thiếu Mirror Fractal -> Cấu hình file săn Dough King.")
            end

            if writefile and next(configData) ~= nil then
                writefile(fileName, HttpService:JSONEncode(configData))
                print("[Hệ Thống] Đã ghi file đa tab: " .. fileName)
            end
            
            -- KÍCH HOẠT LUỒNG GIÁM SÁT ĐỂ KICK KHI NHẶT ĐƯỢC ĐỒ (Tránh đứng im sau khi hoàn thành)
            task.spawn(function()
                print("[Hệ Thống] Đang kích hoạt luồng giám sát hoàn thành mục tiêu...")
                while task.wait(5) do -- Kiểm tra mỗi 5 giây
                    if not hasTushita and hasItem("Tushita") then
                        plr:Kick("🎉 [NightHub] ĐÃ LẤY THÀNH CÔNG TUSHITA! Đang Rejoin để chuyển cấu hình...")
                        break
                    elseif hasTushita and not hasValkyrie and hasItem("Valkyrie Helm") then
                        plr:Kick("🎉 [NightHub] ĐÃ LẤY THÀNH CÔNG VALKYRIE HELM! Đang Rejoin để chuyển cấu hình...")
                        break
                    elseif hasTushita and hasValkyrie and not hasMirror and hasItem("Mirror Fractal") then
                        plr:Kick("🎉 [NightHub] ĐÃ LẤY THÀNH CÔNG MIRROR FRACTAL! Hệ thống hoàn thành 3 món!")
                        break
                    end
                end
            end)
            
            return "nighthub"
        end
    end
    
    return "banana"
end

-- =====================================================================
-- HÀM KHỞI CHẠY CÁC MODULE BANANA KAITUN & MONITOR (KHÔNG THAY ĐỔI)
-- =====================================================================
local function LaunchBananaFarmModules()
    print("[Kích Hoạt] Chạy hệ thống Banana Kaitun & Event Monitor...")

    task.spawn(function()
        while task.wait(1) do
            if plr and not plr.Team then
                pcall(function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates") end)
            elseif plr and plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("ChooseTeam") then
                plr.PlayerGui.ChooseTeam.Enabled = false
            end
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then break end
        end
    end)

    repeat task.wait(0.5) until plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
    end)

    local function GetPlayerLevel()
        return (plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level")) and plr.Data.Level.Value or 0
    end

    local function IsInForbiddenDimension()
        local map = workspace:FindFirstChild("Map")
        if map then
            local hell = map:FindFirstChild("HellDimension")
            local heav = map:FindFirstChild("HeavenlyDimension")
            if hell or heav then
                local pos = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.Position
                if pos then
                    if hell and hell:IsA("Model") and (hell:GetPivot().Position - pos).Magnitude <= 3000 then return true end
                    if heav and heav:IsA("Model") and (heav:GetPivot().Position - pos).Magnitude <= 3000 then return true end
                end
            end
        end
        return false
    end

    local Net
    pcall(function() Net = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("Net", 5)) end)
    local RegisterAttack = Net and Net:RemoteEvent("RegisterAttack", true)
    local RegisterHit = Net and Net:RemoteEvent("RegisterHit", true)

    task.spawn(function()
        while true do
            if GetPlayerLevel() >= 700 and RegisterAttack and RegisterHit then
                pcall(function()
                    local targets = {}
                    local pos = plr.Character.HumanoidRootPart.Position
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - pos).Magnitude <= 85 then
                            table.insert(targets, v)
                        end
                    end
                    if #targets > 0 then
                        local data = {[1] = targets[1]:FindFirstChild("Head") or targets[1].HumanoidRootPart, [2] = {}}
                        for _, t in pairs(targets) do
                            RegisterAttack:FireServer(0)
                            table.insert(data[2], {t, t.HumanoidRootPart})
                        end
                        RegisterHit:FireServer(unpack(data))
                    end
                end)
            end
            task.wait(0.006)
        end
    end)

    _G.SmartBringMobToggle = true
    task.spawn(function()
        while task.wait(0.05) do
            if _G.SmartBringMobToggle and GetPlayerLevel() >= 700 and not IsInForbiddenDimension() and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.Velocity.Magnitude < 15 then
                pcall(function()
                    local targetName, targetCF = nil, nil
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob.Humanoid.Health < mob.Humanoid.MaxHealth and mob:FindFirstChild("HumanoidRootPart") then
                            if (mob.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 500 then
                                targetName = mob.Name; targetCF = mob.HumanoidRootPart.CFrame; break
                            end
                        end
                    end
                    if targetName and targetCF then
                        for _, mob in pairs(workspace.Enemies:GetChildren()) do
                            if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                if (mob.HumanoidRootPart.Position - targetCF.Position).Magnitude > 5 then
                                    mob.HumanoidRootPart.CFrame = targetCF
                                    mob.HumanoidRootPart.CanCollide = false
                                    mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    mob.Humanoid:ChangeState(11)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    local findMob = function(mobName)
        return workspace.Enemies:FindFirstChild(mobName) or ReplicatedStorage:FindFirstChild(mobName)
    end

    local function GetPirateRaidMob(x)
        local Mob
        local castlePos = Vector3.new(-5545.9873046875, 314.0802307128906, -2964.34912109375)
        local targetFolder = x and workspace.Enemies or ReplicatedStorage
        for _, v in ipairs(targetFolder:GetChildren()) do
            if v:IsA('Model') and v:FindFirstChild("HumanoidRootPart") then
                if (v.HumanoidRootPart.Position - castlePos).magnitude <= 1000 and not v:GetAttribute('IsBoss') then
                    Mob = v; break
                end
            end
        end
        return Mob
    end

    local function checkSea3()
        local mapAttr = workspace:GetAttribute("MAP")
        if not mapAttr then return false end
        return tonumber(mapAttr:match("%d+")) == 3
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

    local scanAndPostEvents = function()
        local bodyData = {}
        local playerMax = `{#game.Players:GetPlayers()}/{game.Players.MaxPlayers}`
        local EliteList = {'Diablo', 'Urban', 'Deandre'}
        local RareBossList = {
            'rip_indra True Form', 'Dough King', 'Cake Prince', 'Soul Reaper', 'Cursed Captain',
            'Darkbeard', 'Stone', 'Island Empress', 'Beautiful Pirate', 'Kilo Admiral', 'Captain Elephant'
        }

        for _, name in pairs(EliteList) do
            if findMob(name) then table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Elite', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Elite'] = name}) end
        end
        for _, name in pairs(RareBossList) do
            if findMob(name) then table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Rare Boss', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Rare Boss'] = name}) end
        end
        if GetPirateRaidMob(rawget(getgenv(), "scanStorage") or false) or GetPirateRaidMob(true) then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Castle', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
        end
        if workspace.Map:FindFirstChild('MysticIsland') then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Mirage', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
        end
        if getMoon() == "8/8" and getMoonPhase() == "Full Moon" then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Moon', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['ClockTime'] = game.Lighting.ClockTime, ['MoonPhase'] = "Full Moon up"})
        end

        if #bodyData > 0 then
            local reqFunction = request or http_request or (syn and syn.request)
            if reqFunction then
                reqFunction({
                    Url = "http://14.233.28.141:8000/handle_event.php",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode(bodyData)
                })
            end
        end
    end

    task.spawn(function()
        repeat task.wait() until plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("Main (minimal)")
        print("[Blox Kid Event Monitor]: Hệ thống truyền tải dữ liệu độc lập đã bật đồng bộ thành công!")
        while true do
            pcall(scanAndPostEvents)
            task.wait(10)
        end
    end)
end

-- =====================================================================
-- HÀM XỬ LÝ KHỞI CHẠY CHÍNH (MAIN ROUTER)
-- =====================================================================
local function ExecuteSystem()
    local route = "banana"
    pcall(function() route = CheckItemsAndGetScriptRoute() end)
    
    if route == "nighthub" then
        print("[Kích Hoạt] Đủ Cấp 2700 & Thiếu Vật Phẩm -> Chỉ chạy Night Hub Hop Rewrite...")
        getgenv().Team = "Pirates"
        
        local hopScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/WhiteX1208/Scripts/heads/main/HopScript.luau"))()
        
        task.spawn(function()
            task.wait(7)
            print("🔄 Đang dịch chuyển lên Sea 3 qua Zou...")
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
        end)
    else
        LaunchBananaFarmModules()
    end
end

-- TIẾN HÀNH XÁC THỰC VÀ CHẠY LUỒNG CHÍNH
local http_request = request or http_request or (syn and syn.request)
if not http_request then
    warn("[-] Executor không hỗ trợ request hệ thống! Chạy bypass khẩn cấp...")
    ExecuteSystem()
else
    local success, response = pcall(function()
        return http_request({ Url = KeyUrl, Method = "GET" })
    end)

    if success and response and response.Body then
        local data_success, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
        if data_success and data and data.key_value then
            print("[NightHub] Xác thực Key hệ thống thành công: " .. data.key_value)
            writefile("NightHubKey.bin", data.key_value)
            ExecuteSystem()
        else
            warn("[NightHub] Phân tích Key thất bại. Chạy mặc định...")
            ExecuteSystem()
        end
    else
        warn("[NightHub] Không kết nối được API Key. Chạy bypass...")
        ExecuteSystem()
    end
end

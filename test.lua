-- =====================================================================
-- FILE 1: KAITUN & FARM MODULES (BẢN FIX DỨT ĐIỂM 100% CÁC LỖI CRASH NIL)
-- =====================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Đợi dữ liệu nhân vật sẵn sàng hoàn toàn để tránh lỗi nil đầu game
if plr then
    pcall(function()
        repeat task.wait(0.5) until plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level")
    end)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService('HttpService')

-- URL lấy Key hệ thống Night Hub
local KeyUrl = "http://14.233.28.141:8000/api.php" 

-- Hàm quét nhanh vật phẩm trong người và hòm đồ ẩn (An toàn tuyệt đối)
local function hasItem(itemName)
    local result = false
    pcall(function()
        if not plr then return end
        local inventory = plr:FindFirstChild("Backpack") 
        local character = plr.Character
        local inventoryData = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        
        if inventory and inventory:FindFirstChild(itemName) then result = true return end
        if character and character:FindFirstChild(itemName) then result = true return end
        
        if inventoryData then
            local success, invTable = pcall(function() return inventoryData:InvokeServer("getInventory") end)
            if success and type(invTable) == "table" then
                for _, item in pairs(invTable) do
                    if type(item) == "table" and item.Name == itemName then 
                        result = true 
                        break
                    end
                end
            end
        end
    end)
    return result
end

-- =====================================================================
-- CHỨC NĂNG KIỂM TRA ĐIỀU KIỆN RẼ NHÁNH SCRIPT
-- =====================================================================
local function CheckItemsAndGetScriptRoute()
    local route = "banana"
    pcall(function()
        if not plr then return end
        
        local levelData = plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level")
        local currentLevel = levelData and levelData.Value or 0
        
        if currentLevel >= 2700 then
            local hasTushita = hasItem("Tushita")
            local hasValkyrie = hasItem("Valkyrie Helm")
            local hasMirror = hasItem("Mirror Fractal")

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
                
                -- LUỒNG GIÁM SÁT ĐỂ KICK KHI NHẶT ĐƯỢC ĐỒ (Bọc an toàn)
                task.spawn(function()
                    print("[Hệ Thống] Đang kích hoạt luồng giám sát hoàn thành mục tiêu...")
                    while task.wait(5) do
                        local success, finish = pcall(function()
                            if not hasTushita and hasItem("Tushita") then
                                plr:Kick("🎉 [NightHub] ĐÃ LẤY THÀNH CÔNG TUSHITA! Đang Rejoin...")
                                return true
                            elseif hasTushita and not hasValkyrie and hasItem("Valkyrie Helm") then
                                plr:Kick("🎉 [NightHub] ĐÃ LẤY THÀNH CÔNG VALKYRIE HELM! Đang Rejoin...")
                                return true
                            elseif hasTushita and hasValkyrie and not hasMirror and hasItem("Mirror Fractal") then
                                plr:Kick("🎉 [NightHub] ĐÃ LẤY THÀNH CÔNG MIRROR FRACTAL! Hoàn thành 3 món!")
                                return true
                            end
                        end)
                        if success and finish then break end
                    end
                end)
                
                route = "nighthub"
            end
        end
    end)
    return route
end

-- =====================================================================
-- HÀM KHỞI CHẠY CÁC MODULE BANANA KAITUN & MONITOR
-- =====================================================================
local function LaunchBananaFarmModules()
    print("[Kích Hoạt] Chạy hệ thống Banana Kaitun & Event Monitor...")

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if plr and not plr.Team then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
                elseif plr and plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("ChooseTeam") then
                    plr.PlayerGui.ChooseTeam.Enabled = false
                end
            end)
            if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then break end
        end
    end)

    pcall(function()
        repeat task.wait(0.5) until plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    end)

    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
        end)
    end)

    local function GetPlayerLevel()
        local lv = 0
        pcall(function() lv = plr.Data.Level.Value end)
        return lv
    end

    local function IsInForbiddenDimension()
        local isForbidden = false
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            if map then
                local hell = map:FindFirstChild("HellDimension")
                local heav = map:FindFirstChild("HeavenlyDimension")
                local pos = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.Position
                if pos then
                    if hell and hell:IsA("Model") and (hell:GetPivot().Position - pos).Magnitude <= 3000 then isForbidden = true end
                    if heav and heav:IsA("Model") and (heav:GetPivot().Position - pos).Magnitude <= 3000 then isForbidden = true end
                end
            end
        end)
        return isForbidden
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
                    local enemiesFolder = workspace:FindFirstChild("Enemies")
                    
                    if enemiesFolder then
                        for _, v in pairs(enemiesFolder:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - pos).Magnitude <= 85 then
                                table.insert(targets, v)
                            end
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
                    local enemiesFolder = workspace:FindFirstChild("Enemies")
                    
                    if enemiesFolder then
                        for _, mob in pairs(enemiesFolder:GetChildren()) do
                            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob.Humanoid.Health < mob.Humanoid.MaxHealth and mob:FindFirstChild("HumanoidRootPart") then
                                if (mob.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 500 then
                                    targetName = mob.Name; targetCF = mob.HumanoidRootPart.CFrame; break
                                end
                            end
                        end
                        if targetName and targetCF then
                            for _, mob in pairs(enemiesFolder:GetChildren()) do
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
                    end
                end)
            end
        end
    end)

    local findMob = function(mobName)
        local mobObj = nil
        pcall(function()
            local enemiesFolder = workspace:FindFirstChild("Enemies")
            local storageFolder = ReplicatedStorage
            mobObj = (enemiesFolder and enemiesFolder:FindFirstChild(mobName)) or (storageFolder and storageFolder:FindFirstChild(mobName))
        end)
        return mobObj
    end

    local function GetPirateRaidMob(x)
        local Mob = nil
        pcall(function()
            local castlePos = Vector3.new(-5545.9873046875, 314.0802307128906, -2964.34912109375)
            local enemiesFolder = workspace:FindFirstChild("Enemies")
            local targetFolder = x and enemiesFolder or ReplicatedStorage
            
            if targetFolder and targetFolder.GetChildren then
                local children = targetFolder:GetChildren()
                if children then
                    for _, v in ipairs(children) do
                        if v and v:IsA('Model') and v:FindFirstChild("HumanoidRootPart") then
                            if (v.HumanoidRootPart.Position - castlePos).magnitude <= 1000 and not v:GetAttribute('IsBoss') then
                                Mob = v
                                break
                            end
                        end
                    end
                end
            end
        end)
        return Mob
    end

    local function checkSea3()
        local isSea3 = false
        pcall(function()
            local mapAttr = workspace:GetAttribute("MAP")
            if mapAttr and tonumber(mapAttr:match("%d+")) == 3 then isSea3 = true end
        end)
        return isSea3
    end

    local getMoon = function()
        local res = "nil"
        pcall(function()
            if not checkSea3() then return end
            local lighting = game.Lighting
            local sky = lighting:FindFirstChild("Sky") or lighting:FindFirstChild("Space_Skybox")
            local tex = sky and sky.MoonTextureId or ""
            tex = tex:gsub("rbxassetid://", "http://www.roblox.com/asset/?id=")
            res = ({
                ["http://www.roblox.com/asset/?id=15493317929"] = "Blue Moon",
                ["http://www.roblox.com/asset/?id=9709149431"] = "8/8",
                ["http://www.roblox.com/asset/?id=9709149052"] = "7/8",
                ["http://www.roblox.com/asset/?id=9709143733"] = "6/8"
            })[tex] or "nil"
        end)
        return res
    end

    local function getMoonPhase()
        local phase = "Unknown"
        pcall(function()
            local moonphase = game.Lighting:GetAttribute("MoonPhase")
            if moonphase then
                if moonphase == 5 and not getgenv().isfmended then phase = "Full Moon" else phase = "Normal Moon" end
            end
        end)
        return phase
    end

    local scanAndPostEvents = function()
        local bodyData = {}
        
        local playerCount = 1
        local maxPlayers = 12
        pcall(function()
            local playersTable = game.Players:GetPlayers()
            if type(playersTable) == "table" then playerCount = #playersTable end
            if game.Players.MaxPlayers then maxPlayers = game.Players.MaxPlayers end
        end)
        local playerMax = string.format("%d/%d", playerCount, maxPlayers)
        
        local EliteList = {'Diablo', 'Urban', 'Deandre'}
        local RareBossList = {
            'rip_indra True Form', 'Dough King', 'Cake Prince', 'Soul Reaper', 'Cursed Captain',
            'Darkbeard', 'Stone', 'Island Empress', 'Beautiful Pirate', 'Kilo Admiral', 'Captain Elephant'
        }

        pcall(function()
            for _, name in pairs(EliteList) do
                if findMob(name) then table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Elite', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Elite'] = name}) end
            end
            for _, name in pairs(RareBossList) do
                if findMob(name) then table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Rare Boss', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Rare Boss'] = name}) end
            end
            if GetPirateRaidMob(rawget(getgenv(), "scanStorage") or false) or GetPirateRaidMob(true) then
                table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Castle', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
            end
            if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild('MysticIsland') then
                table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Mirage', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
            end
            if getMoon() == "8/8" and getMoonPhase() == "Full Moon" then
                table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Moon', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['ClockTime'] = game.Lighting.ClockTime, ['MoonPhase'] = "Full Moon up"})
            end
        end)

        if #bodyData > 0 then
            local reqFunction = request or http_request or (syn and syn.request)
            if reqFunction then
                pcall(function()
                    reqFunction({
                        Url = "http://14.233.28.141:8000/handle_event.php",
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = HttpService:JSONEncode(bodyData)
                    })
                end)
            end
        end
    end

    task.spawn(function()
        pcall(function()
            repeat task.wait() until plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("Main (minimal)")
        end)
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
        
        local success, err = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/WhiteX1208/Scripts/heads/main/HopScript.luau"))()
        end)
        if not success then warn("Lỗi tải HopScript: " .. tostring(err)) end
        
        task.spawn(function()
            task.wait(7)
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
            end)
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
            pcall(function() writefile("NightHubKey.bin", data.key_value) end)
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

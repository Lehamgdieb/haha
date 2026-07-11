-- =====================================================================
-- FILE 1: MAIN ROUTER (ĐÃ TÁCH BIỆT LUỒNG TRACK.LUA CỦA BẠN - LOAD SAU)
-- =====================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- HÀNG RÀO CHẶN: Đợi dữ liệu nhân vật sẵn sàng hoàn toàn để tránh lỗi nil value
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
                
                -- LUỒNG GIÁM SÁT ĐỂ KICK KHI NHẶT ĐƯỢC ĐỒ
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
-- HÀM KHỞI CHẠY CÁC MODULE BANANA KAITUN & KÍCH HOẠT TRACKING
-- =====================================================================
local function LaunchBananaFarmModules()
    print("[Kích Hoạt] Khởi tạo luồng chạy Banana Kaitun...")

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

    -- 1. KÍCH HOẠT BANANA CAT KAITUN
    task.spawn(function()
        pcall(function()
            getgenv().Key = ""
            getgenv().SettingFarm = {
                ["Hide UI"] = false,
                ["Reset Teleport"] = {
                    ["Enabled"] = false,
                    ["Delay Reset"] = 3,
                    ["Item Dont Reset"] = {
                        ["Fruit"] = {
                            ["Enabled"] = true,
                            ["All Fruit"] = true, 
                            ["Select Fruit"] = {
                                ["Enabled"] = false,
                                ["Fruit"] = {},
                            },
                        },
                    },
                },
                ["White Screen"] = false,
                ["Lock Fps"] = {
                    ["Enabled"] = false,
                    ["FPS"] = 20,
                },
                ["Get Items"] = {
                    ["Saber"] = true,
                    ["Godhuman"] =  true,
                    ["Skull Guitar"] = true,
                    ["Mirror Fractal"] = false,
                    ["Cursed Dual Katana"] = true,
                    ["Upgrade Race V2-V3"] = true,
                    ["Auto Pull Lever"] = true,
                    ["Shark Anchor"] = true,
                },
                ["Get Rare Items"] = {
                    ["Rengoku"] = false,
                    ["Dragon Trident"] = false, 
                    ["Pole (1st Form)"] = false,
                    ["Gravity Blade"]  = false,
                },
                ["Farm Fragments"] = {
                    ["Enabled"]  = false,
                    ["Fragment"] = 50000,
                },
                ["Auto Chat"] = {
                    ["Enabled"] = false,
                    ["Text"] = "",
                },
                ["Auto Summon Rip Indra"] = false,
                ["Select Hop"] = {
                    ["Hop Server If Have Player Near"] = false, 
                    ["Hop Find Rip Indra Get Valkyrie Helm or Get Tushita"] = false,
                    ["Hop Find Dough King Get Mirror Fractal"] = false,
                    ["Hop Find Raids Castle [CDK]"] = true,
                    ["Hop Find Cake Queen [CDK]"] = true,
                    ["Hop Find Soul Reaper [CDK]"] = true,
                    ["Hop Find Darkbeard [SG]"] = true,
                    ["Hop Find Mirage [ Pull Lever ]"] = false,
                },
                ["Farm Mastery"] = {
                    ["Melee"] = false,
                    ["Sword"] = false,
                },
                ["Buy Haki"] = {
                    ["Enhancement"] = true,
                    ["Skyjump"] = true,
                    ["Flash Step"] = true,
                    ["Observation"] = true,
                },
                ["Sniper Fruit Shop"] = {
                    ["Enabled"] = true,
                    ["Fruit"] = {"Leopard-Leopard","Kitsune-Kitsune","Dragon-Dragon","Yeti-Yeti","Gas-Gas"},
                },
                ["Lock Fruit"] = {},
                ["Webhook"] = {
                    ["Enabled"] = false,
                    ["WebhookUrl"] = "",
                }
            }

            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
        end)
    end)

    -- 2. ĐÃ THAY THẾ: Gọi API gửi database từ link GitHub track.lua của bạn khi nhân vật sẵn sàng
    task.spawn(function()
        pcall(function()
            print("[Hệ Thống] Nhân vật tải xong ổn định -> Đang nạp API Monitor từ track.lua...")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Lehamgdieb/Configvippro/refs/heads/main/track.lua"))()
        end)
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
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/WhiteX1208/Scripts/refs/heads/main/HopScript.luau"))()
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

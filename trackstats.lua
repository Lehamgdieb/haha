-- ====================================================================
-- SCRIPT: BloxKid_Tracker.lua (BẢN TÍCH HỢP UI MINIMAL TOP-CENTER)
-- ====================================================================

-- 1. TẠO GIAO DIỆN UI ĐƠN GIẢN Ở GIỮA TRÊN CÙNG MÀN HÌNH
local CoreGui = game:GetService("CoreGui")
local oldUi = CoreGui:FindFirstChild("BloxKidTrackerUI")
if oldUi then oldUi:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxKidTrackerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 26)
MainFrame.Position = UDim2.new(0.5, -120, 0, 5) -- Căn giữa (0.5) và dịch lên sát mép trên (5px)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(35, 35, 45)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- Mặc định màu đỏ (Chưa kết nối)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -30, 1, 0)
StatusLabel.Position = UDim2.new(0, 26, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(150, 160, 175)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Text = "TRACKER: CONNECTING..."
StatusLabel.Parent = MainFrame

-- Hàm cập nhật trạng thái UI nhanh
local function updateUI(status, isSuccess)
    if isSuccess then
        StatusDot.BackgroundColor3 = Color3.fromRGB(16, 185, 129) -- Xanh lá khi OK
        StatusLabel.Text = "TRACKER: " .. tostring(status)
        StatusLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    else
        StatusDot.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- Đỏ khi lỗi/chờ
        StatusLabel.Text = "TRACKER: " .. tostring(status)
        StatusLabel.TextColor3 = Color3.fromRGB(180, 100, 100)
    end
end

-- 2. TIẾN TRÌNH KHỞI CHẠY KHÓA AN TOÀN CHO AUTOEXEC
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer = game:GetService('Players').LocalPlayer
repeat task.wait(1) until LocalPlayer and LocalPlayer:FindFirstChild('DataLoaded')

local HttpService = game:GetService('HttpService')
local CommF_ = game:GetService('ReplicatedStorage'):WaitForChild('Remotes'):WaitForChild('CommF_')

local lastStatsPayload = ""
local lastPostedTime = 0

function GetSea()
    local pId = game.PlaceId
    if pId == 85211729168715 or pId == 2753915549 then return 1
    elseif pId == 79091703265657 or pId == 4442272183 then return 2
    elseif pId == 100117331123089 or pId == 7449423635 then return 3 end
    return 1
end

-- LUỒNG 1: BẮN DATA CƠ BẢN LẬP TỨC (Không dùng InvokeServer để sáng đèn web ngay)
task.spawn(function()
    pcall(function()
        local basicData = {
            ['username'] = tostring(LocalPlayer.Name),
            ['sea'] = GetSea(),
            ['level'] = tonumber(LocalPlayer.Data.Level.Value) or 0,
            ['beli'] = tonumber(LocalPlayer.Data.Beli.Value) or 0,
            ['fragments'] = tonumber(LocalPlayer.Data.Fragments.Value) or 0,
            ['bounty'] = tonumber(LocalPlayer.leaderstats['Bounty/Honor'].Value) or 0,
            ['race'] = tostring(LocalPlayer.Data.Race.Value) .. '-V1',
            ['df'] = tostring(LocalPlayer.Data.DevilFruit.Value) or 'None',
            ['df_mastery'] = 0, ['gear'] = 0, ['pull'] = false,
            ['melees'] = {}, ['swords'] = {['mythical']={},['legendary']={}}, ['fruits'] = {['mythical']={},['legendary']={}}
        }
        local success, res = pcall(function()
            return request({
                Url = "http://14.233.28.141:8000/api/save_stats.php",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(basicData)
            })
        end)
        if success then
            updateUI("ONLINE (BASIC OK)", true)
        else
            updateUI("HTTP ERR", false)
        end
    end)
end)

-- HOÃN CHẠY CÁC HÀM NẶNG ĐỂ TRÁNH LỖI PHẢN HỒI TỪ GAME
task.wait(15) 

function CheckPullLever() 
    local success, res = pcall(function() return CommF_:InvokeServer('CheckTempleDoor') end)
    return success and res or false
end

function CheckGear()
    local success, res = pcall(function()
        local raceC = LocalPlayer.Data.Race:FindFirstChild('C')
        if raceC and (raceC.Value or 0) > 0 then return raceC.Value end
        local r1, r2, r3 = CommF_:InvokeServer('UpgradeRace','Check')
        if r2 then return r2 end
        return 0
    end)
    return success and res or 0
end

function GetRace()
    local success, lvl = pcall(function() return CommF_:InvokeServer('getRaceLevel') end)
    local v = (success and tonumber(lvl)) or 1
    return LocalPlayer.Data.Race.Value .. '-V' .. tostring(math.clamp(v, 1, 4))
end

function GetFruitMastery()
    local df = LocalPlayer['Data']['DevilFruit'].Value
    local bpack = LocalPlayer.Backpack:FindFirstChild(df)
    local char = LocalPlayer.Character:FindFirstChild(df)
    if bpack then return bpack['Level'].Value elseif char then return char['Level'].Value end
    return 0
end

function GetMelees()
    local purchased = {}
    local meleeList = {'Godhuman','Death Step','Sharkman Karate','Superhuman','Dragon Talon','Electric Claw','Sanguine Art'}
    for _, v in pairs(meleeList) do
        local success, owned = pcall(function() return CommF_:InvokeServer('Buy'..string.gsub(v, ' ', ''), true) end)
        if success and owned == 1 then table.insert(purchased, v) end
    end
    return purchased
end

function GetStats()
    local success, inventory = pcall(function() return CommF_:InvokeServer('getInventory') end)
    if not success or not inventory then return '' end

    local jsonData = {
        ['username'] = tostring(LocalPlayer.Name),
        ['sea'] = GetSea(),
        ['df_mastery'] = GetFruitMastery(),
        ['beli'] = tonumber(LocalPlayer.Data.Beli.Value),
        ['swords'] = { ['mythical'] = {}, ['legendary'] = {} },
        ['fruits'] = { ['mythical'] = {}, ['legendary'] = {} },
        ['melees'] = GetMelees(),
        ['level'] = tonumber(LocalPlayer.Data.Level.Value),
        ['fragments'] = tonumber(LocalPlayer.Data.Fragments.Value),
        ['df'] = tostring(LocalPlayer.Data.DevilFruit.Value),
        ['bounty'] = tonumber(LocalPlayer.leaderstats['Bounty/Honor'].Value),
        ['race'] = GetRace(),
        ['gear'] = CheckGear(),
        ['pull'] = CheckPullLever(),
    }

    for _, v in pairs(inventory) do
        if v['Type'] == 'Sword' or v['Type'] == 'Gun' then
            if v['Rarity'] == 4 then table.insert(jsonData['swords']['mythical'], v['Name'])
            elseif v['Rarity'] == 3 then table.insert(jsonData['swords']['legendary'], v['Name']) end
        elseif v['Type'] == 'Blox Fruit' or v['Type'] == 'Mutated Fruit' then
            if v['Rarity'] == 4 then table.insert(jsonData['fruits']['mythical'], v['Name'])
            elseif v['Rarity'] == 3 then table.insert(jsonData['fruits']['legendary'], v['Name']) end
        end
    end
    return HttpService:JSONEncode(jsonData)
end

-- LUỒNG 2: VÒNG LẶP ĐỒNG BỘ ĐẦY ĐỦ THÔNG SỐ (30S/LẦN)
task.spawn(function()
    while true do
        pcall(function()
            local payload = GetStats()
            if payload and payload ~= '' then
                local currentTime = os.time()
                
                if payload == lastStatsPayload and (currentTime - lastPostedTime) < 180 then
                    updateUI("CONNECTED (IDLE)", true)
                    return
                end
                
                local success, res = pcall(function()
                    return request({
                        Url = "http://14.233.28.141:8000/api/save_stats.php",
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = payload
                    })
                end)
                
                if success then
                    lastStatsPayload = payload
                    lastPostedTime = currentTime
                    updateUI("CONNECTED (UPDATED)", true)
                else
                    updateUI("HTTP REQ ERR", false)
                end
            end
        end)
        task.wait(30)
    end
end)

print("[Blox Kid Tracker VIP]: Đã nhúng UI giám sát ngầm đỉnh cao!")

-- ====================================================================
-- SCRIPT: BloxKid_Tracker.lua (CHỈ CHẠY CHO ACC CLONE CỦA BẠN)
-- ====================================================================
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer:FindFirstChild('DataLoaded')

local HttpService = game:GetService('HttpService')
local LocalPlayer = game:GetService('Players').LocalPlayer
local CommF_ = game:GetService('ReplicatedStorage'):WaitForChild('Remotes'):WaitForChild('CommF_')

-- Hàm kiểm tra trạng thái gạt cần Temple of Time
function CheckPullLever() 
    local success, res = pcall(function()
        return CommF_:InvokeServer('CheckTempleDoor')
    end)
    return success and res or false
end

-- Hàm kiểm tra cấp độ Gear V4 hiện tại
function CheckGear()
	local raceC = LocalPlayer.Data.Race:FindFirstChild('C')
	if raceC and (raceC.Value or 0) > 0 then return raceC.Value end
	local character = LocalPlayer.Character
	if character and character:FindFirstChild('RaceTransformed') then
		local r1, r2, r3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer('UpgradeRace','Check')
		if r2 then return r2 end
	end
	return 0
end

-- Hàm lấy Chủng tộc (Race) và Cấp độ V1 -> V4
function GetRace()
	local ok, lvl = pcall(function() return CommF_:InvokeServer('getRaceLevel') end)
	local v = (ok and tonumber(lvl)) or 1
	return LocalPlayer.Data.Race.Value .. '-V' .. tostring(math.clamp(v, 1, 4))
end

-- Hàm lấy cấp độ thông thạo Trái ác quỷ đang ăn
function GetFruitMastery()
	local df = LocalPlayer['Data']['DevilFruit'].Value
	local bpack = LocalPlayer.Backpack:FindFirstChild(df)
	local char = LocalPlayer.Character:FindFirstChild(df)
	if bpack then return bpack['Level'].Value elseif char then return char['Level'].Value end
	return 0
end

-- Hàm quét danh sách Võ Học (Melee) đã sở hữu
function GetMelees()
	local purchased = {}
	local meleeList = {'Godhuman','Death Step','Sharkman Karate','Superhuman','Dragon Talon','Electric Claw','Sanguine Art'}
	for _, v in pairs(meleeList) do
		local success, owned = pcall(function()
			return CommF_:InvokeServer('Buy'..string.gsub(v, ' ', ''), true)
		end)
		if success and owned == 1 then 
			table.insert(purchased, v) 
		end
	end
	return purchased
end

-- Hàm xác định Sea hiện tại dựa trên ID Bản đồ
function GetSea()
    local pId = game.PlaceId
    if pId == 85211729168715 or pId == 2753915549 then return 1
    elseif pId == 79091703265657 or pId == 4442272183 then return 2
    elseif pId == 100117331123089 or pId == 7449423635 then return 3 end
    return 1
end

-- HÀM TỔNG HỢP DATA CHUẨN ĐỂ ĐẨY LÊN WEB TRACK
function GetStats()
	local success, inventory = pcall(function()
		return CommF_:InvokeServer('getInventory')
	end)
	
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

	-- Phân loại độ hiếm Kiếm và Trái cây trong túi đồ để đồng bộ với Web UI
	for _, v in pairs(inventory) do
		if v['Type'] == 'Sword' then
			if v['Rarity'] == 4 then 
				table.insert(jsonData['swords']['mythical'], v['Name'])
			elseif v['Rarity'] == 3 then 
				table.insert(jsonData['swords']['legendary'], v['Name']) 
			end
		elseif v['Type'] == 'Blox Fruit' or v['Type'] == 'Mutated Fruit' then
			if v['Rarity'] == 4 then 
				table.insert(jsonData['fruits']['mythical'], v['Name'])
			elseif v['Rarity'] == 3 then 
				table.insert(jsonData['fruits']['legendary'], v['Name']) 
			end
		end
	end
	
	return HttpService:JSONEncode(jsonData)
end

-- VÒNG LẶP GỬI REQUEST LÊN SERVER XAMPP CỦA BẠN
task.spawn(function()
    while true do
        pcall(function()
            local payload = GetStats()
            if payload and payload ~= '' then
                request({
                    Url = "http://113.165.150.162:8000/api/save_stats.php", -- Giữ nguyên localhost nếu chạy cùng máy, hoặc thay bằng IP VPS của bạn
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payload
                })
            end
        end)
        task.wait(20) -- 20 giây cập nhật thông số lên Dashboard một lần (vừa đủ để hiển thị "a few seconds ago")
    end
end)

print("[Blox Kid Tracker]: Hệ thống giám sát đã được kích hoạt trên tài khoản này!")

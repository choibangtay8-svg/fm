-- Fishing Master direct runner
-- Generated from 191512c73b4e072e4ed4ccec_deobf.luau.
-- The protected loader prefix, expiry branch, and in-UI key gate are omitted.
local str="191512c73b4e072e4ed4ccec"
local v=type; local v2=tostring; local v3=tonumber; local v4=pcall; local v5=task
local spawn=v5 and v5.spawn or function(f,...) return coroutine.resume(coroutine.create(f),...) end
local wait_=v5 and v5.wait or wait; local fn=tick or function() return os and os.time and os.time() or 0 end
local clock=os and os.clock or fn; local freeze=table and table.freeze or function(x) return x end
local tbl2={}; local huneConsole={}; local flag5=true; local v14=game and game.PlaceId or 0; local v15=""
local v17=nil; local v18={success=true,valid=true}; local v19=nil; local n4=0; local n5=0; local v20=fn(); local v21=999999999; local flag2=true
local v29={ScriptId=str,PlaceId=v14,GameName=v15,Console=huneConsole,Crypto=tbl2}

	local v30, v31 = v4(function()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		local genv
		genv = getgenv and getgenv() or _G
		local MainSection, MiscSection, SettingsSection
		local AboutTab, FarmTab, SellTab, TeleTab, QuestTab, BossTab
		local GachaTab, ShopTab, RewardTab, MiscTab, SettingsTab, LanguageTab
		local FarmToggle

		if type(genv.FishFilterQuickTest) == "table" and type(genv.FishFilterQuickTest.Stop) == "function" then
			pcall(genv.FishFilterQuickTest.Stop)
		end

		if type(genv.HuneHubFishingMaster) == "table" and type(genv.HuneHubFishingMaster.Unload) == "function" then
			pcall(genv.HuneHubFishingMaster.Unload)
		end

		local ReplicatedStorage, PathfindingService, HttpService2, TeleportService, CollectionService, VirtualInputManager, localPlayer
		local Players = game:GetService("Players")
		ReplicatedStorage = game:GetService("ReplicatedStorage")
		PathfindingService = game:GetService("PathfindingService")
		game:GetService("UserInputService")
		HttpService2 = game:GetService("HttpService")
		TeleportService = game:GetService("TeleportService")
		game:GetService("GuiService")
		CollectionService = game:GetService("CollectionService")
		VirtualInputManager = game:GetService("VirtualInputManager")
		localPlayer = Players.LocalPlayer
		local playerGui
		playerGui = localPlayer:WaitForChild("PlayerGui")
		local tbl3

		tbl3 = {
			path = "Hune Hub/" .. localPlayer.Name:lower():gsub("[^%w_%-]", "_") .. ".json",
			read = function()
				local ok, result = pcall(function()
					if type(readfile) ~= "function" then
						return nil
					end

					if type(isfile) ~= "function" or isfile(tbl3.path) then
						return HttpService2:JSONDecode(readfile(tbl3.path))
					end

					if isfile("Hune Hub/Language.json") then
						local data = HttpService2:JSONDecode(readfile("Hune Hub/Language.json"))
						if type(data) == "table" then
							return { language = { mode = data.mode } }
						end
					end

					return nil
				end)

				return ok and type(result) == "table" and result or {}
			end,
			update = function(arg)
				local ok, result = pcall(function()
					if type(writefile) ~= "function" or type(readfile) ~= "function" then
						error("file access unavailable")
					end

					local v30 = tbl3.read()

					if type(isfile) == "function" and isfile(tbl3.path) then
						local ok, result = pcall(function()
							return HttpService2:JSONDecode(readfile(tbl3.path))
						end)

						if not ok or type(result) ~= "table" then
							error("existing config JSON is invalid")
							v30 = result
						else
							v30 = result
						end
					end

					v30.version = 1
					arg(v30)

					if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("Hune Hub") then
						makefolder("Hune Hub")
					end

					local json = HttpService2:JSONEncode(v30)
					writefile(tbl3.path, json)

					if readfile(tbl3.path) ~= json then
						error("config save verification failed")
					end

					return true
				end)

				return ok and result == true
			end,
			profiles = function(arg)
				local v30 = tbl3.read()[arg]
				return type(v30) == "table" and type(v30.profiles) == "table" and v30.profiles or {}
			end,
			saveProfile = function(arg, arg2, arg3, arg4)
				local tbl4 = {}
				local v30 = pairs
				local pendingFlags = arg3.PendingFlags or {}

				for k, pendingFlag in v30(pendingFlags) do
					local parser = arg4 and arg4.Parser and arg4.Parser[pendingFlag.__type]

					if parser and parser.Save then
						local ok, result = pcall(parser.Save, pendingFlag)

						if ok and result ~= nil then
							tbl4[k] = result
						end
					end
				end

				if next(tbl4) == nil then
					error("no config controls available")
				end

				if not tbl3.update(function(arg5)
					arg5[arg] = type(arg5[arg]) == "table" and arg5[arg] or {}
					arg5[arg].profiles = type(arg5[arg].profiles) == "table" and arg5[arg].profiles or {}
					arg5[arg].profiles[arg2] = { flags = tbl4 }
				end) then
					error("could not save profile")
				end
			end,
			loadProfile = function(arg, arg2, arg3, arg4)
				local v30 = tbl3.profiles(arg)[arg2]

				if type(v30) ~= "table" or type(v30.flags) ~= "table" then
					error("profile not found")
				end

				local n7 = 0

				for k, flag10 in pairs(v30.flags) do
					local pendingFlags = arg3.PendingFlags and arg3.PendingFlags[k]
					local parser = pendingFlags and arg4 and arg4.Parser and arg4.Parser[pendingFlags.__type]

					if parser and parser.Load then
						if pcall(parser.Load, pendingFlags, flag10) then
							n7 += 1
						end
					end
				end

				if n7 == 0 and next(v30.flags) then
					error("profile has no compatible controls")
				end
			end,
			migrateLegacyProfiles = function(arg, arg2)
				if not arg2 or type(arg2.Path) ~= "string" then
					return
				end
				local v30 = tbl3.read()[arg]
				if type(v30) == "table" and v30.migratedLegacy then
					return
				end
				local tbl4 = {}

				pcall(function()
					for _, v31 in ipairs(arg2:AllConfigs()) do
						local str10 = arg2.Path .. v31 .. ".json"

						if isfile(str10) then
							local data = HttpService2:JSONDecode(readfile(str10))
							local elements = type(data) == "table" and (data.__elements or data)

							if type(elements) == "table" then
								tbl4[v31] = { flags = elements }
							end
						end
					end
				end)

				tbl3.update(function(arg3)
					arg3[arg] = type(arg3[arg]) == "table" and arg3[arg] or {}
					arg3[arg].profiles = type(arg3[arg].profiles) == "table" and arg3[arg].profiles or {}

					for k, v31 in pairs(tbl4) do
						if arg3[arg].profiles[k] == nil then
							arg3[arg].profiles[k] = v31
						end
					end

					if arg == "fishingMaster" and arg3[arg].autoload == nil then
						pcall(function()
							if isfile("Hune Hub/FishingMaster_Autoload.txt") then
								arg3[arg].autoload = tostring(readfile("Hune Hub/FishingMaster_Autoload.txt")):match("^%s*(.-)%s*$")
							end
						end)
					end

					arg3[arg].migratedLegacy = true
				end)
			end,
		}

		local tbl4

		tbl4 = {
			mode = "auto",
			code = "en",
			vi = {
				Main = "Chính",
				["Misc & Player"] = "Khác & Nhân Vật",
				Settings = "Cài Đặt",
				Info = "Thông Tin",
				["Auto Farm"] = "Tự Động Câu",
				["Auto Sell"] = "Tự Động Bán",
				Island = "Đảo",
				Quest = "Nhiệm Vụ",
				Boss = "Boss",
				Shop = "Cửa Hàng",
				Rewards = "Phần Thưởng",
				["Local Player"] = "Nhân Vật",
				Config = "Cấu Hình",
				Information = "Thông Tin",
				["Discord Community"] = "Cộng Đồng Discord",
				["Join Discord"] = "Vào Discord",
				Owner = "Chủ Sở Hữu",
				["Copy Owner ID"] = "Sao Chép ID Chủ Sở Hữu",
				["Server: "] = "Máy Chủ: ",
				Unknown = "Không Rõ",
				["Main Features"] = "Tính Năng Chính",
				["Auto Skill + Low HP"] = "Tự Dùng Kỹ Năng + Máu Thấp",
				["Fish Rarity Filter"] = "Lọc Độ Hiếm Cá",
				["Skill Combo (Z,X,C,V)"] = "Thứ Tự Combo Skill (Z,X,C,V)",
				["Enter Skills In Order, Separated By Commas. Omit A Key To Skip It."] = "Nhập Thứ Tự Skill, Ngăn Cách Bằng Dấu Phẩy. Bỏ Phím Để Không Dùng.",
				["Target Rarities"] = "Độ Hiếm Mục Tiêu",
				["Filter Fish by Rarity"] = "Lọc Cá Theo Độ Hiếm",
				["Speed Settings"] = "Cài Đặt Tốc Độ",
				["Farm Delay (Seconds)"] = "Độ Trễ Câu (Giây)",
				["Position Settings"] = "Cài Đặt Vị Trí",
				["Stop Farm If Moved"] = "Dừng Câu Khi Di Chuyển",
				["Save Fishing Position"] = "Lưu Vị Trí Câu",
				["Return To Fishing Position"] = "Trở Về Vị Trí Câu",
				["Automatic Fish Selling"] = "Bán Cá Tự Động",
				["Sell Travel Method"] = "Cách Di Chuyển Đi Bán",
				["Sell Tween Speed (Studs/Second)"] = "Tốc Độ Tween Đi Bán (Stud/Giây)",
				["Auto Lock Fish by Rarity"] = "Tự Khóa Cá Theo Độ Hiếm",
				["Rarities to Lock"] = "Độ Hiếm Cần Khóa",
				["Auto Lock Fish"] = "Tự Khóa Cá",
				["Auto Sell When Bag Full"] = "Tự Bán Khi Túi Đầy",
				["Auto Sell On Timer"] = "Tự Bán Theo Giờ",
				["Sell Interval (Seconds)"] = "Chu Kỳ Bán (Giây)",
				["Sell All Fish Now"] = "Bán Tất Cả Cá Ngay",
				["Island Travel Warning"] = "Cảnh Báo Di Chuyển Giữa Các Đảo",
				["Using Island Travel May Get You Kicked From The Game. We Are Not Responsible For Any Resulting Kick."] = "Di Chuyển Giữa Các Đảo Có Thể Khiến Bạn Bị Kick Khỏi Game. Chúng Tôi Không Chịu Trách Nhiệm Nếu Điều Đó Xảy Ra.",
				["Island Unlock"] = "Mở Khóa Đảo",
				["Select Island"] = "Chọn Đảo",
				["Unlock Requirements"] = "Điều Kiện Mở Khóa",
				["Start Island Unlock Quest"] = "Bắt Đầu Nhiệm Vụ Mở Đảo",
				["Unlock Selected Island"] = "Mở Khóa Đảo Đã Chọn",
				["Island Travel"] = "Di Chuyển Giữa Các Đảo",
				["Travel Speed (Studs/s)"] = "Tốc Độ Di Chuyển (Stud/Giây)",
				["Travel To Island"] = "Đi Đến Đảo",
				["Stop Island Travel"] = "Dừng Di Chuyển",
				["Select Quest"] = "Chọn Nhiệm Vụ",
				["Travel To Quest Island"] = "Đi Đến Đảo Nhiệm Vụ",
				["Boss Alerts"] = "Thông Báo Boss",
				["Notify Boss"] = "Báo Khi Có Boss",
				["ESP Boss"] = "Hiện Vị Trí Boss",
				["Auto Boss"] = "Tự Động Săn Boss",
				Cost = "Chi Phí",
				["Auto Spin "] = "Tự Quay ",
				[" Gacha"] = " Gacha",
				[" Stop At Or Above Rarity"] = " Dừng Ở Độ Hiếm Tối Thiểu",
				[" Maximum Spins"] = " Số Lần Quay Tối Đa",
				[" Gems Per Spin"] = " Gem Mỗi Lần Quay",
				[" Coins Per Spin"] = " Xu Mỗi Lần Quay",
				[" Per Spin"] = " Mỗi Lần Quay",
				["Coin Price Is Quoted Before Every Spin"] = "Giá Bằng Xu Được Báo Trước Mỗi Lần Quay",
				["Buy Fishing Rods"] = "Mua Cần Câu",
				["Select Rod To Buy"] = "Chọn Cần Câu Cần Mua",
				["Buy Selected Rod"] = "Mua Cần Câu Đã Chọn",
				["Daily Login"] = "Đăng Nhập Hằng Ngày",
				["Claim Daily Reward"] = "Nhận Thưởng Hằng Ngày",
				["Auto Claim Daily Reward"] = "Tự Nhận Thưởng Hằng Ngày",
				["Group & Gift Inbox"] = "Nhóm & Hộp Quà",
				["Claim Group Reward"] = "Nhận Thưởng Nhóm",
				["Claim All Gift Inbox Items"] = "Nhận Tất Cả Quà",
				["Redeem Code"] = "Đổi Mã",
				Code = "Mã",
				["Enter game code"] = "Nhập mã game",
				["Session Statistics"] = "Thống Kê Phiên",
				["Fish Caught: 0 | Coins Earned: 0 | Time: 0m 00s"] = "Cá Đã Câu: 0 | Xu Kiếm Được: 0 | Thời Gian: 0p 00s",
				Movement = "Di Chuyển",
				["Anti-AFK"] = "Chống AFK",
				["Freeze Character"] = "Đóng Băng Nhân Vật",
				["System Utilities"] = "Tiện Ích Hệ Thống",
				["Fix Lag Pro (Boost FPS)"] = "Giảm Lag Pro (Tăng FPS)",
				["Rejoin Server"] = "Vào Lại Máy Chủ",
				["Unload Hub"] = "Tắt Hub",
				["Interface Settings"] = "Cài Đặt Giao Diện",
				Theme = "Giao Diện",
				["Profile Management System"] = "Quản Lý Cấu Hình",
				["New Config Name"] = "Tên Cấu Hình Mới",
				["e.g. AutoFarm"] = "Ví dụ: AutoFarm",
				["Save Config"] = "Lưu Cấu Hình",
				["Select Config To Load/Delete"] = "Chọn Cấu Hình Để Tải/Xóa",
				["Load Config"] = "Tải Cấu Hình",
				["Delete Config"] = "Xóa Cấu Hình",
				["Select Auto Load Config"] = "Chọn Cấu Hình Tự Tải",
				["Set Auto Load Config"] = "Đặt Cấu Hình Tự Tải",
				Language = "Ngôn Ngữ",
				["Select Language"] = "Chọn Ngôn Ngữ",
				["Language updated and saved."] = "Đã Đổi Và Lưu Ngôn Ngữ.",
				["Language updated for this session, but could not be saved."] = "Đã Đổi Ngôn Ngữ Cho Phiên Này Nhưng Không Thể Lưu Vào File.",
				["Checking Key..."] = "Đang Kiểm Tra Key...",
				["No Key"] = "Không Có Key",
				["Key Unavailable"] = "Không Kiểm Tra Được Key",
				["Invalid Key"] = "Key Không Hợp Lệ",
				Lifetime = "Vĩnh Viễn",
				Expired = "Đã Hết Hạn",
				["Fish Sold"] = "Đã Bán Cá",
				["Returning To Fishing Spot"] = "Đang Về Vị Trí Câu",
				["Return To Fishing Spot Pending"] = "Đang Chờ Về Vị Trí Câu",
				["No Fish To Sell"] = "Không Có Cá Để Bán",
				["Merchant Out Of Range"] = "Ở Quá Xa Người Bán Cá",
				["Sell Request Busy"] = "Đang Xử Lý Bán Cá",
				["Fish Merchant Not Found"] = "Không Tìm Thấy Người Bán Cá",
				["No Walking Route"] = "Không Có Đường Đi Bộ",
				["Movement Busy"] = "Đang Di Chuyển",
				["Return Pending"] = "Đang Chờ Quay Lại",
				["Fish Filter"] = "Lọc Cá",
				["Sell Request Failed"] = "Bán Cá Thất Bại",
				["Fishing Area Left"] = "Đã Rời Khu Vực Câu",
				["Fishing Position Restored"] = "Đã Về Vị Trí Câu",
				["Bag Full"] = "Túi Đã Đầy",
				["Auto Farm Enabled"] = "Đã Bật Tự Động Câu",
				["Auto Farm Disabled"] = "Đã Tắt Tự Động Câu",
				["Fishing Area Saved"] = "Đã Lưu Khu Vực Câu",
				["Position Not Saved"] = "Chưa Lưu Vị Trí",
				["Position Saved"] = "Đã Lưu Vị Trí",
				["Position Reached"] = "Đã Đến Vị Trí",
				["Safe Route Unavailable"] = "Không Có Đường An Toàn",
				["No Saved Position"] = "Chưa Có Vị Trí Đã Lưu",
				["Sell In Progress"] = "Đang Bán Cá",
				["Island Unlocked"] = "Đã Mở Khóa Đảo",
				["Previous Island Locked"] = "Đảo Trước Chưa Mở Khóa",
				["Quest Active"] = "Nhiệm Vụ Đang Hoạt Động",
				["Another Quest Active"] = "Đang Có Nhiệm Vụ Khác",
				["Unlock Quest Started"] = "Đã Bắt Đầu Nhiệm Vụ Mở Đảo",
				["Unlock Quest Failed"] = "Không Thể Bắt Đầu Mở Đảo",
				["Unlock Requirements Missing"] = "Thiếu Điều Kiện Mở Đảo",
				["Quest Required"] = "Cần Làm Nhiệm Vụ",
				["Travel Complete"] = "Đã Đến Đảo",
				["Travel Stopped"] = "Đã Dừng Di Chuyển",
				["Destination Not Loaded"] = "Đảo Đích Chưa Tải",
				["Already At Destination"] = "Đã Ở Đảo Đích",
				["Travel Failed"] = "Di Chuyển Thất Bại",
				["Auto Quest Complete"] = "Đã Hoàn Thành Nhiệm Vụ",
				["Quest Started"] = "Đã Bắt Đầu Nhiệm Vụ",
				["Quest Completed"] = "Đã Hoàn Thành Nhiệm Vụ",
				["Boss Spotted: "] = "Phát Hiện Boss: ",
				["Rod Shop"] = "Cửa Hàng Cần Câu",
				["Daily Reward"] = "Thưởng Hằng Ngày",
				["Group Reward"] = "Thưởng Nhóm",
				["Gift Inbox"] = "Hộp Quà",
				["Fix Lag"] = "Giảm Lag",
				["Fix Lag Pro"] = "Giảm Lag Pro",
				["Hune Hub Ready"] = "Hune Hub Sẵn Sàng",
				["Fishing Master is ready. Enable Auto Farm to begin."] = "Fishing Master Đã Sẵn Sàng. Bật Tự Động Câu Để Bắt Đầu.",
				["Join Discord For More Update New!!!"] = "Vào Discord Để Nhận Thông Tin Cập Nhật Mới!",
				["The complete fishing cycle has stopped."] = "Chu Kỳ Câu Cá Đã Dừng.",
				["The current fishing position has been saved."] = "Đã Lưu Vị Trí Câu Hiện Tại.",
				["Character position is not ready yet."] = "Vị Trí Nhân Vật Chưa Sẵn Sàng.",
				["Save a fishing position first."] = "Hãy Lưu Vị Trí Câu Trước.",
				["The current merchant sale is still running."] = "Lượt Bán Cá Hiện Tại Vẫn Đang Chạy.",
				["Returned to the saved fishing spot."] = "Đã Trở Về Vị Trí Câu Đã Lưu.",
				["All fish are locked; unlock fish to make room."] = "Tất Cả Cá Đã Bị Khóa; Hãy Mở Khóa Một Số Cá Để Có Chỗ Trống.",
				["Please enter config name first!"] = "Hãy Nhập Tên Cấu Hình Trước!",
				["Discord invite copied!"] = "Đã Sao Chép Lời Mời Discord!",
				["Clipboard is not supported by this executor."] = "Executor Này Không Hỗ Trợ Clipboard.",
				["Auto Quest"] = "Tự Động Làm Nhiệm Vụ",
				Gacha = "Gacha",
				["Gacha "] = "Gacha ",
				["Refresh Unlock Status"] = "Làm Mới Trạng Thái Mở Khóa",
				["No unlocked fish are available."] = "Không Có Cá Chưa Khóa Để Bán.",
				["Staying at the merchant until the next sell attempt."] = "Đang Ở Chỗ Người Bán Cá Để Thử Bán Lại.",
				["Please try again in a moment."] = "Vui Lòng Thử Lại Sau Chốc Lát.",
				["Wait for the island NPC to load, then try again."] = "Hãy Đợi NPC Trên Đảo Tải Xong Rồi Thử Lại.",
				["The character stopped outside the merchant's sell radius."] = "Nhân Vật Đã Dừng Ngoài Phạm Vi Bán Của NPC.",
				["Move closer to a Fish Merchant or select Tween in Auto Sell."] = "Hãy Đến Gần Người Bán Cá Hoặc Chọn Tween Trong Tab Tự Động Bán.",
				["Wait for the current travel action to finish."] = "Hãy Đợi Lượt Di Chuyển Hiện Tại Kết Thúc.",
				["Wait for the current movement to finish."] = "Hãy Đợi Nhân Vật Di Chuyển Xong.",
				["The saved fishing position has not been reached. Auto Farm remains paused."] = "Chưa Về Tới Vị Trí Câu Đã Lưu. Tự Động Câu Vẫn Tạm Dừng.",
				["Could not confirm protected fish are locked. Sale postponed."] = "Chưa Xác Nhận Cá Cần Giữ Đã Được Khóa. Đã Hoãn Bán.",
				["Sale was not confirmed, so the character will not return yet."] = "Chưa Xác Nhận Bán Thành Công Nên Nhân Vật Chưa Quay Lại.",
				["Auto Farm stopped because the character moved away from the saved position."] = "Đã Dừng Tự Động Câu Vì Nhân Vật Rời Vị Trí Đã Lưu.",
				["Returned to the saved spot. Auto Farm can resume."] = "Đã Về Vị Trí Câu Đã Lưu. Có Thể Tiếp Tục Tự Động Câu.",
				["The fishing position will be saved when movement finishes."] = "Vị Trí Câu Sẽ Được Lưu Khi Di Chuyển Xong.",
				["The current fishing position and facing direction were saved."] = "Đã Lưu Vị Trí Và Hướng Đứng Khi Câu.",
				["Auto Farm will stop if you move more than 8 studs away."] = "Tự Động Câu Sẽ Dừng Nếu Bạn Rời Xa Hơn 8 Stud.",
				["Walked to the saved fishing position."] = "Đã Đi Đến Vị Trí Câu Đã Lưu.",
				["Player Data Is Not Ready."] = "Dữ Liệu Người Chơi Chưa Sẵn Sàng.",
				["Player data is not ready."] = "Dữ Liệu Người Chơi Chưa Sẵn Sàng.",
				["Select An Island."] = "Hãy Chọn Một Đảo.",
				[" Is Unlocked."] = " Đã Được Mở Khóa.",
				["Quest Not Started"] = "Nhiệm Vụ Chưa Bắt Đầu",
				["Level "] = "Cấp ",
				["; Cost: "] = "; Giá: ",
				[" Coins"] = " Xu",
				[". Status: "] = ". Trạng Thái: ",
				[" Is Already Unlocked."] = " Đã Được Mở Khóa.",
				["Unlock "] = "Mở Khóa ",
				[" First."] = " Trước.",
				[" Unlock Quest Is Already Active."] = " Đang Có Nhiệm Vụ Mở Khóa.",
				["Complete Or Cancel "] = "Hoàn Thành Hoặc Hủy ",
				["Collect The Requirements For "] = "Thu Thập Đủ Điều Kiện Cho ",
				["Requirements Not Met."] = "Chưa Đủ Điều Kiện.",
				["Start The "] = "Hãy Bắt Đầu Nhiệm Vụ ",
				[" Unlock Quest First."] = " Để Mở Đảo Trước.",
				["Check The Quest Requirements."] = "Hãy Kiểm Tra Điều Kiện Nhiệm Vụ.",
				[" Is Now Unlocked."] = " Đã Được Mở Khóa.",
				["Tweening to "] = "Đang Tween Đến ",
				[" at "] = " Với Tốc Độ ",
				[" studs per second."] = " Stud Mỗi Giây.",
				["Arrived at "] = "Đã Đến ",
				["Island tween was cancelled."] = "Đã Hủy Tween Giữa Các Đảo.",
				["The destination island has no loaded landing point yet."] = "Đảo Đích Chưa Tải Điểm Đến.",
				["You are already on the selected island."] = "Bạn Đã Ở Trên Đảo Đã Chọn.",
				["The island did not confirm arrival."] = "Game Chưa Xác Nhận Đã Đến Đảo.",
				["Start A Quest In Game Or Select One In This Tab."] = "Hãy Nhận Nhiệm Vụ Trong Game Hoặc Chọn Một Nhiệm Vụ Ở Tab Này.",
				["Finish Or Cancel "] = "Hoàn Thành Hoặc Hủy ",
				["Tween to "] = "Tween Đến ",
				[" failed: "] = " Thất Bại: ",
				["Quest Island Not Found."] = "Không Tìm Thấy Đảo Của Nhiệm Vụ.",
				["Fishing For "] = "Đang Câu Cho Nhiệm Vụ ",
				["Requirements Ready; Claiming Quest."] = "Đã Đủ Điều Kiện; Đang Nhận Thưởng Nhiệm Vụ.",
				["Requirements Not Ready."] = "Chưa Đủ Điều Kiện.",
				["Distance unavailable"] = "Không Đo Được Khoảng Cách",
				[" studs away"] = " Stud Cách Xa",
				["Unknown Island"] = "Đảo Không Rõ",
				["Bought "] = "Đã Mua ",
				["Purchase failed; check balance and requirements."] = "Mua Thất Bại; Hãy Kiểm Tra Số Dư Và Điều Kiện.",
				["You already own this rod."] = "Bạn Đã Sở Hữu Cần Câu Này.",
				["Unlock the rod's island first."] = "Hãy Mở Khóa Đảo Của Cần Câu Trước.",
				["Not enough "] = "Không Đủ ",
				["Next claim in "] = "Có Thể Nhận Tiếp Sau ",
				["Claimed day "] = "Đã Nhận Thưởng Ngày ",
				["Claim rejected by game."] = "Game Đã Từ Chối Nhận Thưởng.",
				["Group reward is unavailable."] = "Thưởng Nhóm Hiện Không Khả Dụng.",
				["Already claimed."] = "Đã Nhận Rồi.",
				["Join the game's group, then claim again."] = "Hãy Vào Nhóm Của Game Rồi Nhận Lại.",
				["Claimed group reward."] = "Đã Nhận Thưởng Nhóm.",
				["Claim failed."] = "Nhận Thưởng Thất Bại.",
				["Claim request sent. Check your gift inbox."] = "Đã Gửi Yêu Cầu Nhận Quà. Hãy Kiểm Tra Hộp Quà.",
				["Claim request failed."] = "Yêu Cầu Nhận Quà Thất Bại.",
				["Code redeemed."] = "Đã Đổi Mã Thành Công.",
				["Invalid code."] = "Mã Không Hợp Lệ.",
				["Code expired."] = "Mã Đã Hết Hạn.",
				["Code already redeemed."] = "Mã Đã Được Dùng.",
				["Requirements not met."] = "Chưa Đủ Điều Kiện.",
				["Save failed; retry later."] = "Lưu Thất Bại; Hãy Thử Lại Sau.",
				["Redemption is busy."] = "Hệ Thống Đổi Mã Đang Bận.",
				["Migrated game passes added."] = "Đã Thêm Game Pass Được Chuyển Đổi.",
				["Unknown response."] = "Phản Hồi Không Rõ.",
				["Request failed."] = "Yêu Cầu Thất Bại.",
				["Pro Mode Applied To The Map And VFX."] = "Đã Áp Dụng Giảm Lag Pro Cho Bản Đồ Và VFX.",
				["Textures And VFX Have Been Reduced."] = "Đã Giảm Texture Và VFX.",
				["Pro Mode Is Already Active."] = "Giảm Lag Pro Đã Được Bật.",
				["Saved: "] = "Đã Lưu: ",
				["Save config failed: "] = "Lưu Cấu Hình Thất Bại: ",
				["Loaded: "] = "Đã Tải: ",
				["Load config failed: "] = "Tải Cấu Hình Thất Bại: ",
				["Deleted: "] = "Đã Xóa: ",
				["Delete config failed: "] = "Xóa Cấu Hình Thất Bại: ",
				["Auto load set to: "] = "Đã Đặt Tự Tải: ",
				["Auto Loaded Config ("] = "Đã Tự Tải Cấu Hình (",
				["The saved position is being retried ("] = "Đang Thử Trở Về Vị Trí Đã Lưu (",
				["Auto Detect Quest"] = "Tự Tìm Nhiệm Vụ",
				["Auto (Roblox)"] = "Tự Động (Roblox)",
				["Fish Caught: %d | Coins Earned: %s | Time: %s"] = "Cá Đã Câu: %d | Xu Kiếm Được: %s | Thời Gian: %s",
				["BOSS: "] = "BOSS: ",
				[" studs"] = " Stud",
				["+%s Coins (%d Fish) • %s"] = "+%s Xu (%d Cá) • %s",
				["Bring 3 Legendary Fish From Desert Island"] = "Mang 3 Cá Legendary Từ Đảo Sa Mạc",
				["Bring Frozen Crown Dragonfish, Frosttusk Seal, And Frostmaw Monster From Snow Island"] = "Mang Frozen Crown Dragonfish, Frosttusk Seal Và Frostmaw Monster Từ Đảo Tuyết",
				["Bring Ancient Trihorn Fish (1,200 Kg), Stormblade Shark (2,000 Kg), And Lavascale Dragonfish (2,500 Kg) From Volcanic Island"] = "Mang Ancient Trihorn Fish (1.200 Kg), Stormblade Shark (2.000 Kg) Và Lavascale Dragonfish (2.500 Kg) Từ Đảo Núi Lửa",
			},
		}

		local flag10 = false

		pcall(function()
			local language = tbl3.read().language

			if type(language) == "table" then
				local mode = language.mode

				if mode == "auto" or mode == "vi" or mode == "en" then
					tbl4.mode = mode
					flag10 = true
				end
			end
		end)

		if not flag10 then
			local huneHubFishingLanguageMode = genv.HuneHubFishingLanguageMode

			if huneHubFishingLanguageMode == "auto" or huneHubFishingLanguageMode == "vi" or huneHubFishingLanguageMode == "en" then
				tbl4.mode = huneHubFishingLanguageMode
			end
		end

		tbl4.detect = function()
			local localeId

			pcall(function()
				localeId = localPlayer.LocaleId
			end)

			if type(localeId) ~= "string" or localeId == "" then
				pcall(function()
					localeId = game:GetService("LocalizationService").RobloxLocaleId
				end)
			end

			return (type(localeId) == "string" and localeId:lower():match("^[a-z][a-z]") or nil) == "vi" and "vi" or "en"
		end

		tbl4.code = tbl4.mode == "auto" and tbl4.detect() or tbl4.mode

		tbl4.text = function(arg)
			if tbl4.code ~= "vi" or type(arg) ~= "string" then
				return arg
			end

			if tbl4.vi[arg] then
				return tbl4.vi[arg]
			end

			for k, v30 in pairs(tbl4.vi) do
				if k:sub(-1) == " " and arg:sub(1, #k) == k then
					return v30 .. arg:sub(#k + 1)
				end
			end

			return arg
		end

		tbl4.save = function(arg)
			if arg ~= "auto" and arg ~= "vi" and arg ~= "en" then
				return false
			end

			return tbl3.update(function(arg2)
				arg2.language = { mode = arg }
			end)
		end

		tbl4.toEnglish = function(arg)
			if type(arg) ~= "string" then
				return arg
			end

			if not tbl4.reverse then
				local reverse = {}

				for k, v30 in pairs(tbl4.vi) do
					reverse[v30] = reverse[v30] or k
				end

				reverse["Thông Tin"] = "Info"
				tbl4.reverse = reverse
			end

			if tbl4.reverse[arg] then
				return tbl4.reverse[arg]
			end

			for k, v30 in pairs(tbl4.reverse) do
				if k:sub(-1) == " " and arg:sub(1, #k) == k then
					return v30 .. arg:sub(#k + 1)
				end
			end

			return arg
		end

		tbl4.refreshGui = function(arg)
			tbl4.originalText = tbl4.originalText or setmetatable({}, { __mode = "k" })

			for _, v30 in pairs({ arg.ScreenGui, arg.NotificationGui, arg.DropdownGui, arg.TooltipGui }) do
				if typeof(v30) == "Instance" then
					local function fn47(arg2)
						pcall(function()
							if arg2:IsA("TextLabel") or arg2:IsA("TextButton") then
								local v31 = tbl4.originalText[arg2]
								local flag11 = not v31

								if not flag11 then
									flag11 = arg2.Text ~= v31

									if flag11 then
										flag11 = arg2.Text ~= (tbl4.vi[v31] or v31)
									end
								end

								if flag11 then
									v31 = tbl4.toEnglish(arg2.Text)
									tbl4.originalText[arg2] = v31
								end

								local v32 = tbl4.text(v31)

								if v32 ~= arg2.Text then
									arg2.Text = v32
								end
							elseif arg2:IsA("TextBox") then
								local v31 = tbl4.originalText[arg2]
								local flag11 = not v31

								if not flag11 then
									flag11 = arg2.PlaceholderText ~= v31

									if flag11 then
										flag11 = arg2.PlaceholderText ~= (tbl4.vi[v31] or v31)
									end
								end

								if flag11 then
									v31 = tbl4.toEnglish(arg2.PlaceholderText)
									tbl4.originalText[arg2] = v31
								end

								local v32 = tbl4.text(v31)

								if v32 ~= arg2.PlaceholderText then
									arg2.PlaceholderText = v32
								end
							end
						end)
					end

					fn47(v30)

					pcall(function()
						for _, descendant in ipairs(v30:GetDescendants()) do
							fn47(descendant)
						end
					end)
				end
			end
		end

		local text
		text = tbl4.text
		local lib
		lib = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

		do
			local ok, result = pcall(function()
				lib:SetParent(playerGui)
			end)

			if not ok then
				warn("[Hune Hub] WindUI PlayerGui parent failed: " .. tostring(result))
			end
		end

		lib:AddTheme({
			Name = "Mocha",
			Accent = "#89b4fa",
			Background = "#1e1e2e",
			Outline = "#313244",
			Text = "#cdd6f4",
			PlaceholderText = "#a6adc8",
		})

		lib:AddTheme({
			Name = "Latte",
			Accent = "#1e66f5",
			Background = "#eff1f5",
			Outline = "#bcc0cc",
			Text = "#4c4f69",
			PlaceholderText = "#6c6f85",
		})

		lib:AddTheme({
			Name = "Aqua",
			Accent = "#06b6d4",
			Background = "#0f172a",
			Outline = "#1e293b",
			Text = "#f8fafc",
			PlaceholderText = "#94a3b8",
		})

		lib:AddTheme({
			Name = "Amethyst",
			Accent = "#a855f7",
			Background = "#1a1025",
			Outline = "#3b0764",
			Text = "#f3e8ff",
			PlaceholderText = "#d8b4fe",
		})

		lib:AddTheme({
			Name = "Transparent",
			Accent = "#888888",
			Background = "#444444",
			Outline = "#666666",
			Text = "#ffffff",
			PlaceholderText = "#bbbbbb",
		})

		local notify = lib.Notify

		lib.Notify = function(arg, arg2)
			if type(arg2) == "table" then
				pcall(function()
					arg2.Title = text(arg2.Title)
					arg2.Content = text(arg2.Content)
				end)
			end

			pcall(notify, arg, arg2)
		end

		local client, packet
		local Stardust = require(ReplicatedStorage:WaitForChild("Stardust"))
		client = Stardust.Client
		packet = Stardust.Packet
		local data
		data = ReplicatedStorage:WaitForChild("Data")
		local FishingPackets
		FishingPackets = require(data:WaitForChild("Packets"):WaitForChild("FishingPackets"))
		local FishingConfig
		FishingConfig = require(data:WaitForChild("Config"):WaitForChild("FishingConfig"))
		local FishingEnums
		FishingEnums = require(data:WaitForChild("Enums"):WaitForChild("FishingEnums"))
		local PullBarMath
		PullBarMath = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Lib"):WaitForChild("PullBarMath"))
		local SellEnums
		SellEnums = require(data:WaitForChild("Enums"):WaitForChild("SellEnums"))
		local FishStorageRules
		FishStorageRules = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Lib"):WaitForChild("FishStorageRules"))
		local AuraGachaConfig
		AuraGachaConfig = require(data:WaitForChild("Config"):WaitForChild("AuraGachaConfig"))
		local SkillGachaConfig
		SkillGachaConfig = require(data:WaitForChild("Config"):WaitForChild("SkillGachaConfig"))
		local CrateConfig
		CrateConfig = require(data:WaitForChild("Config"):WaitForChild("CrateConfig"))
		local RodShopConfig
		RodShopConfig = require(data:WaitForChild("Config"):WaitForChild("RodShopConfig"))
		local IslandConfig
		IslandConfig = require(data:WaitForChild("Config"):WaitForChild("IslandConfig"))
		local RarityEnums
		RarityEnums = require(data:WaitForChild("Enums"):WaitForChild("RarityEnums"))
		local Catalog
		Catalog = require(data:WaitForChild("Catalog"))
		local PlayerDataV2Controller
		PlayerDataV2Controller = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("PlayerDataV2Controller"))
		local FishingController
		FishingController = nil
		local RodController
		RodController = nil
		local LootController
		LootController = nil

		pcall(function()
			FishingController = client.GetController("FishingController")
			RodController = client.GetController("RodController")
			LootController = client.GetController("LootController")
		end)

		local v30
		v30 = packet("SellAll"):Response(packet.NumberU8, packet.NumberF64, packet.NumberU16)
		local v31

		v31 = packet("AuraGacha/Pull", packet.NumberU8):Response({
			ok = packet.Boolean8,
			reason = packet.String,
			seed = packet.NumberU32,
			pity_hit = packet.Boolean8,
			pity_after = { Legendary = packet.NumberU16, Mythical = packet.NumberU16, Divine = packet.NumberU16 },
			gem_spent = packet.NumberU32,
			credits_used = packet.NumberU16,
			results = { { aura_id = packet.String, rarity = packet.String, is_new = packet.Boolean8 } },
		})

		local v32

		v32 = packet("SkillGacha/GetQuote", packet.NumberU8):Response({
			ok = packet.Boolean8,
			reason = packet.String,
			count = packet.NumberU8,
			coin_cost = packet.NumberF64,
			credits_available = packet.NumberU16,
			credits_used = packet.NumberU16,
			reset_at = packet.NumberF64,
			storage_cap = packet.NumberU8,
		})

		local v33

		v33 = packet("SkillGacha/Pull", packet.String, packet.NumberU8):Response({
			ok = packet.Boolean8,
			reason = packet.String,
			seed = packet.NumberU32,
			pity_hit = packet.Boolean8,
			pity_after = { Legendary = packet.NumberU16, Mythical = packet.NumberU16 },
			coin_spent = packet.NumberF64,
			credits_used = packet.NumberU16,
			refund_coin = packet.NumberF64,
			reset_at = packet.NumberF64,
			storage_cap = packet.NumberU8,
			results = {
				{
					skill_id = packet.String,
					rarity = packet.String,
					is_new = packet.Boolean8,
					quantity_after = packet.NumberU8,
					overflow = packet.Boolean8,
					refund_coin = packet.NumberF64,
				},
			},
		})

		local v34

		v34 = packet("CrateService/Open", packet.String, packet.NumberU8):Response({
			ok = packet.Boolean8,
			reason = packet.String,
			results = {
				{
					rod_skin_id = packet.String,
					rarity = packet.String,
					is_new = packet.Boolean8,
					is_duplicate = packet.Boolean8,
				},
			},
			pity_hit = packet.Boolean8,
			pity_after = packet.NumberU16,
		})

		local v35
		v35 = packet("PurchaseRod", packet.String):Response(packet.Boolean8)
		local v36
		v36 = packet("DailyReward/Claim"):Response(packet.Boolean8)
		local ClaimAll
		ClaimAll = packet("GiftService/ClaimAll")
		local BossSpawnSound, tbl5, tbl6, flag11, resumeSoldFish, flag12, flag13, flag14, flag15, flag16
		local n7, n8, n9, flag17, n10, n11, finisherPct, n12, n13, n14
		local flag18, n15, tbl7, flag19, flag20, flag21, flag22, flag23, n16, flag24
		local n17, n18, flag25, v37, flag26, tbl8, flag27, flag28, flag29, flag30
		local cFrame, cFrame2, flag31, now3, n19, n20, flag32, n21, flag33, n22
		local n23, flag34, n24, flag35, idling, v38, now4, n25, tbl9, fn47
		local fn48, tbl10

		do
			local v39 = packet("SellToggleLock", packet.String):Response(packet.NumberU8, packet.Boolean8)
			BossSpawnSound = packet("BossSpawnSound")
			tbl5 = {}
			tbl6 = {}

			local function fn49()
				local tbl11 = {}

				pcall(function()
					for _, v40 in pairs(Catalog.Island.GetAll()) do
						local id = v40.id or v40.Id
						local name = v40.name or v40.Name

						if type(id) == "string" and type(name) == "string" then
							table.insert(tbl11, {
								id = id,
								name = name,
								order = tonumber(v40.order or v40.Order) or 999,
								defaultUnlocked = v40.defaultUnlocked == true,
							})
						end
					end
				end)

				if #tbl11 == 0 then
					tbl11 = {}
					local v40 = tbl11
					v40[1] = { id = "island_starter", name = "Starter Island", order = 1, defaultUnlocked = true }
					v40[2] = { id = "island_jungle", name = "Jungle Island", order = 2, defaultUnlocked = false }
					v40[3] = { id = "island_desert", name = "Desert Island", order = 3, defaultUnlocked = false }
					v40[4] = { id = "island_snow", name = "Snow Island", order = 4, defaultUnlocked = false }
					v40[5] = { id = "island_volcano", name = "Volcanic Island", order = 5, defaultUnlocked = false }
					v40[6] = { id = "island_fossil", name = "Fossil Island", order = 6, defaultUnlocked = false }
				end

				table.sort(tbl11, function(arg, arg2)
					if arg.order == arg2.order then
						return arg.name < arg2.name
					end
					return arg.order < arg2.order
				end)

				for _, v40 in ipairs(tbl11) do
					tbl5[v40.name] = v40
					table.insert(tbl6, v40.name)
				end
			end

			fn49()
			flag11 = true
			resumeSoldFish = false
			flag12 = false
			flag13 = false
			flag14 = false
			flag15 = false
			flag16 = false
			n7 = 0.35
			n8 = 1 / math.max(FishingConfig.GetClickCps and FishingConfig.GetClickCps("Manual") or FishingConfig.Click and FishingConfig.Click.ManualCps or 6, 1)
			n9 = math.max((FishingConfig.Latency and FishingConfig.Latency.QteReactionFloor or 0.1) + 0.12, (FishingConfig.Counter and FishingConfig.Counter.StrictInputSettleTime or 0.08) + 0.1)
			flag17 = false
			n10 = 0
			n11 = 0
			finisherPct = FishingConfig.Fight and FishingConfig.Fight.FinisherPct or 0.075
			n12 = 0
			n13 = 0
			n14 = 0
			flag18 = false
			n15 = 0

			tbl7 = {
				nextIndex = 1,
				order = { "Slot1", "Slot2", "Slot3", "Slot4" },
				setOrder = function(arg)
					local order = {}
					local tbl11 = {}
					local tbl12 = { Z = "Slot1", X = "Slot2", C = "Slot3", V = "Slot4" }
					local str10 = tostring(arg or "")

					if str10:match("^%s*$") then
						str10 = "Z,X,C,V"
					end

					for match in str10:upper():gmatch("[^,%s>]+") do
						local v40 = tbl12[match]
						if not v40 then
							return false
						end

						if not tbl11[v40] then
							table.insert(order, v40)
							tbl11[v40] = true
						end
					end

					if #order == 0 then
						return false
					end
					tbl7.order = order
					tbl7.nextIndex = 1
					return true
				end,
			}

			local fishingMaster = tbl3.read().fishingMaster
			local skillComboOrder = type(fishingMaster) == "table" and fishingMaster.skillComboOrder
			tbl7.defaultOrder = type(skillComboOrder) == "string" and skillComboOrder or "Z,X,C,V"

			if not tbl7.setOrder(tbl7.defaultOrder) then
				tbl7.defaultOrder = "Z,X,C,V"
				tbl7.setOrder(tbl7.defaultOrder)
			end

			tbl7.saveOrderSoon = function(skillComboOrder2)
				tbl7.saveRevision = (tbl7.saveRevision or 0) + 1
				local saveRevision = tbl7.saveRevision

				task.delay(0.7, function()
					if saveRevision ~= tbl7.saveRevision then
						return
					end

					tbl3.update(function(arg)
						arg.fishingMaster = type(arg.fishingMaster) == "table" and arg.fishingMaster or {}
						arg.fishingMaster.skillComboOrder = skillComboOrder2
					end)
				end)
			end

			flag19 = false
			flag20 = false
			flag21 = false
			flag22 = false
			flag23 = false
			n16 = 0
			flag24 = false
			n17 = 60
			n18 = 0
			flag25 = false
			v37 = nil
			flag26 = false

			tbl8 = {
				pending = false,
				attempts = 0,
				retryAt = 0,
				method = "Tween",
				tweenSpeed = 30,
				farmSpotPending = false,
				lastReturnReason = nil,
				lastFailureKey = nil,
				lastFailureAt = 0,
				saleAttempts = 0,
				saleRetryAt = 0,
				lastSaleReason = nil,
				resumeFarm = false,
				resumeStage = 0,
				resumeAt = 0,
				resumeCancelAt = 0,
				rodId = nil,
				bagRefreshAfter = 0,
				saleHadFish = false,
				resumeSoldFish = false,
			}

			flag27 = false
			flag28 = true
			flag29 = false
			flag30 = false
			cFrame = nil
			cFrame2 = nil
			flag31 = false
			genv.HuneHubTravelSpeed = 70
			now3 = tick()
			n19 = 0
			n20 = 0
			flag32 = false
			n21 = 0
			flag33 = false
			n22 = 0
			n23 = 0
			flag34 = false
			n24 = 0
			flag35 = false
			idling = FishingEnums.State.Idling
			v38 = nil
			now4 = os.clock()
			n25 = 0
			tbl9 = {}
			fn47 = nil

			fn48 = function(arg)
				table.insert(tbl9, arg)
				return arg
			end

			tbl10 = {
				farmEnabled = false,
				farmRarities = { Legendary = true, Mythical = true, Divine = true },
				skipPending = false,
				skipAt = 0,
				lastCancelAt = -math.huge,
				currentFishId = nil,
				sellEnabled = false,
				sellRarities = { Legendary = true, Mythical = true, Divine = true },
				locking = false,
				lockQueued = false,
				lockAgain = false,
				lastLockAttempt = {},
				verifiedLocked = {},
				observedLocked = {},
				setSelected = function(arg, arg2, arg3)
					table.clear(arg2)

					if type(arg3) == "string" then
						arg2[arg3] = true
					elseif type(arg3) == "table" then
						for k, v40 in pairs(arg3) do
							local flag36 = type(k) == "number" and v40 or v40 == true and k or nil

							if type(flag36) == "string" then
								arg2[flag36] = true
							end
						end
					end
				end,
				matches = function(arg, arg2, arg3)
					local flag36 = type(arg2) == "string" and Catalog.Fish.GetById(arg2)
					return flag36 and arg3[flag36.rarity] == true or false
				end,
				shouldSkip = function(arg, arg2)
					if genv.HuneHubBossCastTarget and type(arg2) == "string" then
						local v40 = Catalog.Fish.GetById(arg2)
						if v40 and v40.kind == "Boss" then
							return false
						end
					end

					return resumeSoldFish and arg.farmEnabled and type(arg2) == "string" and arg2 ~= "" and not arg:matches(arg2, arg.farmRarities)
				end,
				skipCurrent = function(arg)
					if not arg.skipPending then
						arg.skipPending = true
						arg.skipAt = os.clock()
						n23 += 1
						flag34 = false
						n14 += 1
						flag18 = false
						flag32 = false
						n22 += 1
						flag33 = false
						n10 += 1
						flag17 = false
						n25 = os.clock() + math.max(n7, 0.3)
					end

					local lastCancelAt = arg.lastCancelAt

					if os.clock() - lastCancelAt >= 0.3 then
						arg.lastCancelAt = os.clock()

						pcall(function()
							FishingPackets.FishCancel:Fire()
						end)
					end
				end,
				allowsCurrent = function(arg)
					if arg.skipPending then
						return false
					end

					if not (resumeSoldFish and arg.farmEnabled) then
						return true
					end
					local currentFishId = arg.currentFishId

					if not currentFishId and FishingController then
						pcall(function()
							currentFishId = FishingController:GetFishInfo()
						end)

						arg.currentFishId = currentFishId
					end

					if type(currentFishId) ~= "string" or currentFishId == "" then
						return false
					end

					if arg:shouldSkip(currentFishId) then
						arg:skipCurrent()
						return false
					end
					return true
				end,
				applyLocks = function(arg)
					if not arg.sellEnabled then
						return true
					end

					if not next(arg.sellRarities) then
						return true
					end
					local v40 = PlayerDataV2Controller:Fetch(localPlayer)
					local fishes = v40 and v40.Inventory and v40.Inventory.Fishes
					if type(fishes) ~= "table" then
						return false
					end
					local flag36 = true

					for k, fishe in pairs(fishes) do
						if not (not flag11 or not arg.sellEnabled) then
							if type(fishe) == "table" then
								local uid = fishe.uid or k

								if fishe.locked == true then
									arg.verifiedLocked[uid] = true
									arg.observedLocked[uid] = true
								elseif arg.observedLocked[uid] then
									arg.verifiedLocked[uid] = nil
									arg.observedLocked[uid] = false
								end

								if fishe.locked ~= true and not arg.verifiedLocked[uid] and arg:matches(fishe.fishId, arg.sellRarities) then
									if type(uid) == "string" then
										local now5 = os.clock()

										if now5 - (arg.lastLockAttempt[uid] or -math.huge) >= 2 then
											arg.lastLockAttempt[uid] = now5

											local ok, result, result2 = pcall(function()
												return v39:Fire(uid)
											end)

											if not ok or result ~= SellEnums.Status.Ok or result2 ~= true then
												flag36 = false
											else
												arg.verifiedLocked[uid] = true
											end

											task.wait(0.08)
										else
											flag36 = false
										end
									else
										flag36 = false
									end
								end
							end

							continue
						end

						break
					end

					return flag36
				end,
				queueLocks = function(arg)
					if not arg.sellEnabled or not flag11 then
						return
					end

					if not next(arg.sellRarities) then
						return
					end

					if arg.locking then
						arg.lockAgain = true
						return
					end

					if arg.lockQueued then
						return
					end
					arg.lockQueued = true

					task.delay(0.2, function()
						arg.lockQueued = false
						if not flag11 or not arg.sellEnabled then
							return
						end

						if arg.locking then
							arg.lockAgain = true
							return
						end
						arg.locking = true

						pcall(function()
							arg:applyLocks()
						end)

						arg.locking = false

						if arg.lockAgain then
							arg.lockAgain = false
							arg:queueLocks()
						end
					end)
				end,
			}
		end

		fn48(PlayerDataV2Controller:Listen(localPlayer, function()
			tbl10:queueLocks()
		end))

		local fn49

		do
			local displayName = "Hune Hub"
			local displayName2 = localPlayer.DisplayName
			local v39 = nil
			local text2 = nil
			local richText = nil
			local v40 = nil
			local tbl11 = { "#FF4D4D", "#FF9F1C", "#FFE66D", "#4ADE80", "#22D3EE", "#60A5FA", "#C084FC" }

			local tbl12 = {
				"天",
				"地",
				"人",
				"火",
				"水",
				"木",
				"金",
				"土",
				"龍",
				"虎",
				"風",
				"雷",
				"光",
				"闇",
				"刀",
				"剣",
				"魂",
				"力",
				"鬼",
				"神",
				"夢",
				"空",
				"心",
				"道",
				"月",
				"星",
				"影",
				"炎",
				"氷",
				"雪",
				"海",
				"山",
			}

			local function fn50()
				return tbl12[math.random(1, #tbl12)]
			end

			local function fn51(arg, arg2, arg3, arg4)
				if not flag11 or not arg.Parent then
					return false
				end
				local tbl13 = {}
				local v41 = tbl11

				if arg4 then
					v41 = table.clone(tbl11)

					for i = #v41, 2, -1 do
						local n26 = math.random(1, i)
						local v42 = v41[i]
						v41[i] = v41[n26]
						v41[n26] = v42
					end
				end

				local n26 = 0

				for i, v42 in ipairs(arg2) do
					if v42 == " " then
						tbl13[i] = " "
					else
						n26 += 1
						tbl13[i] = string.format("<font color=\"%s\">%s</font>", v41[(n26 - 1 + arg3) % #v41 + 1], v42)
					end
				end

				local text3 = table.concat(tbl13)
				arg.RichText = true
				arg.Text = text3
				v40 = text3
				return true
			end

			local function fn52(arg)
				local tbl13 = {}
				local tbl14 = {}

				for i = 1, #displayName do
					local str10 = ("Hune Hub"):sub(i, i)
					tbl13[i] = str10
					tbl14[i] = str10 == " " and " " or fn50()
				end

				local n26 = 0

				local function fn53()
					n26 = (n26 + 1) % #tbl11
					return fn51(arg, tbl14, n26)
				end

				if not fn53() then
					return
				end
				task.wait(0.3)

				for i, v41 in ipairs(tbl13) do
					if v41 ~= " " then
						for i2 = 1, math.random(4, 7) do
							tbl14[i] = fn50()
							if not fn53() then
								return
							end
							task.wait(0.055)
						end
					end

					tbl14[i] = v41
					if not fn53() then
						return
					end
					task.wait(0.1)
				end

				if not fn51(arg, tbl13, 0) then
					return
				end

				while flag11 and arg.Parent and v39 == arg do
					task.wait(0.25)
					fn51(arg, tbl13, 0, true)
				end
			end

			local function fn53()
				local nametags = workspace:WaitForChild("Nametags", 30)
				if not flag11 or not nametags then
					return
				end
				local v41 = nametags:WaitForChild(localPlayer.Name, 30)
				if not flag11 or not v41 then
					return
				end
				local plrName = v41:WaitForChild("PlrName", 30)
				if not flag11 or not plrName then
					return
				end
				local surface = plrName:WaitForChild("Surface", 30)
				if not flag11 or not surface then
					return
				end
				local label = surface:WaitForChild("Label", 30)
				if not flag11 or not label or not label:IsA("TextLabel") then
					return
				end
				local str10 = "@" .. localPlayer.Name
				local v42 = nil

				local function fn54()
					if not flag11 or not label.Parent then
						v42:Disconnect()
						return
					end

					if label.Text ~= str10 then
						return
					end
					v42:Disconnect()
					text2 = label.Text
					richText = label.RichText
					v40 = text2
					v39 = label
					task.spawn(fn52, label)
				end

				v42 = fn48(label:GetPropertyChangedSignal("Text"):Connect(fn54))
				fn54()
			end

			local function fn54(arg)
				local humanoid = arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid", 5)
				if not flag11 or not humanoid then
					return
				end
				humanoid.DisplayName = displayName
			end

			if localPlayer.Character then
				task.spawn(fn54, localPlayer.Character)
			end

			fn48(localPlayer.CharacterAdded:Connect(function(character)
				task.spawn(fn54, character)
			end))

			task.spawn(fn53)

			fn49 = function()
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.DisplayName == displayName then
					humanoid.DisplayName = displayName2
				end

				if v39 and v39.Parent and v39.Text == v40 then
					v39.RichText = richText
					v39.Text = text2
				end
			end
		end

		local tbl11, fn50, fn51, fn52, fn53, fn54, fn55, fn56, fn57, fn58
		local fn59, fn60, fn61, fn62, v39, configManager

		do
			local tbl12 = { Up = "W", Left = "A", Right = "D", W = "W", A = "A", D = "D" }
			local tbl13 = { A = true, W = true, D = true }

			local function fn63(arg)
				local v40 = nil

				pcall(function()
					v40 = FishingConfig.Counter.DirectionToKey[arg]
				end)

				local v41 = v40 or tbl12[arg]
				return tbl13[v41] and v41 or nil
			end

			local tbl14 = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythical = 6, Divine = 7 }

			tbl11 = {
				Aura = { name = "Aura", enabled = false, running = false, amount = 10, rarity = "Legendary" },
				Skill = { name = "Skill", enabled = false, running = false, amount = 10, rarity = "Legendary" },
				Ocean = {
					name = "Ocean Chest",
					enabled = false,
					running = false,
					amount = 10,
					rarity = "Mythical",
					crateId = "crate_ocean_chest",
				},
				Dragon = {
					name = "Dragon Chest",
					enabled = false,
					running = false,
					amount = 10,
					rarity = "Mythical",
					crateId = "crate_dragon_chest",
				},
			}

			local flag36 = false

			fn50 = function(arg, arg2)
				local tbl15 = {}

				if arg2 then
					local v40 = ipairs
					local tbl16 = CrateConfig.GetPool(arg2) or {}

					for _, v41 in v40(tbl16) do
						local rarity = v41.Item and v41.Item.rarity

						if rarity then
							tbl15[rarity] = true
						end
					end
				else
					local v40 = pairs
					local tbl16 = arg or {}

					for k in v40(tbl16) do
						tbl15[k] = true
					end
				end

				local tbl16 = {}

				for _, v40 in ipairs(RarityEnums.Order) do
					if tbl15[v40] then
						table.insert(tbl16, v40)
					end
				end

				return tbl16
			end

			local function fn64(arg)
				local Coin

				if arg == "Aura" then
					Coin = v31:Fire(1)
				elseif arg == "Skill" then
					local v40 = v32:Fire(1)
					if type(v40) ~= "table" or not v40.ok then
						return nil, type(v40) == "table" and v40.reason or "QuoteUnavailable"
					end
					Coin = v33:Fire("Coin", 1)
				else
					Coin = v34:Fire(tbl11[arg].crateId, 1)
				end

				if type(Coin) ~= "table" or not Coin.ok then
					return nil, type(Coin) == "table" and Coin.reason or "NoResponse"
				end

				if type(Coin.results) ~= "table" or #Coin.results == 0 then
					return nil, "NoResults"
				end
				return Coin
			end

			local function fn65(arg, arg2)
				arg.enabled = false
				arg.running = false

				if arg.toggle then
					pcall(function()
						if arg.toggle.Set then
							arg.toggle:Set(false)
						elseif arg.toggle.SetValue then
							arg.toggle:SetValue(false)
						end
					end)
				end

				if flag11 and arg2 then
					local name = arg.name
					lib:Notify({ Title = text("Gacha ") .. name, Content = arg2, Duration = 4 })
				end
			end

			local tbl15 = {
				insufficient_gem = "Not enough Gems.",
				insufficient_coin = "Not enough Coins.",
				storage_full = "Skill storage is full.",
				busy = "The shop is busy. Try again shortly.",
				QuoteUnavailable = "Skill price is unavailable.",
				NoResponse = "The shop did not respond.",
				NoResults = "The shop returned no item.",
			}

			fn51 = function(arg)
				local v40 = tbl11[arg]
				if not v40 or v40.running or not v40.enabled then
					return
				end
				v40.running = true

				task.spawn(function()
					task.wait(0.1)
					local n26 = 0
					local exitTo = nil
					local ok, result, result2
					local latestResult

					while true do
						local enabled = flag11 and v40.enabled
						local flag37

						if enabled then
							flag37 = n26 < math.max(1, math.floor(tonumber(v40.amount) or 10))
						else
							flag37 = enabled
						end

						if flag37 then
							while flag11 and v40.enabled and flag36 do
								task.wait(0.05)
							end

							if not flag11 or not v40.enabled then
								exitTo = 1
								break
							else
								flag36 = true
								ok, result, result2 = pcall(fn64, arg)
								flag36 = false

								if not ok or not result then
									exitTo = 2
									break
									else
										n26 += 1
										local n27 = tbl14[v40.rarity] or 5
										local exitTo2 = nil
										latestResult = nil

										for _, result3 in ipairs(result.results) do
											latestResult = result3
											if n27 <= (tbl14[result3.rarity] or 0) then
											exitTo2 = 1
											break
										end
									end

									if exitTo2 ~= 1 then
										if n26 < math.max(1, math.floor(tonumber(v40.amount) or 10)) then
											task.wait(0.7)
										end

										continue
									end
								end
							end
						else
							exitTo = 1
							break
						end

						break
					end

					if exitTo == 1 then
						fn65(v40, v40.enabled and ("Reached the %d-spin limit."):format(n26) or nil)
						return
					end

					if exitTo == 2 then
						local str10 = tostring(ok and result2 or result)
						fn65(v40, "Stopped: " .. (tbl15[str10] or str10))
						return
					end

						fn65(v40, string.format("%s (%s) after %d spins", tostring(latestResult and (latestResult.aura_id or latestResult.skill_id or latestResult.rod_skin_id) or "?"), tostring(latestResult and latestResult.rarity or "?"), n26))
				end)
			end

			fn52 = function()
				return (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
			end

			fn53 = function()
				if not FishingController then
					pcall(function()
						FishingController = client.GetController("FishingController")
					end)
				end

				local state = nil

				if FishingController then
					pcall(function()
						state = FishingController:GetState()
					end)
				end

				return state
			end

			local function fn66(arg)
				if not arg or not arg:IsA("Tool") then
					return false
				end
				local v40 = nil

				pcall(function()
					v40 = Catalog.Rod.GetById(arg.Name)
				end)

				return v40 ~= nil
			end

			fn54 = function(arg)
				local character = localPlayer.Character
				if not character then
					return false
				end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then
					return false
				end

				if not RodController then
					pcall(function()
						RodController = client.GetController("RodController")
					end)
				end

				for _, child in ipairs(character:GetChildren()) do
					if fn66(child) then
						return true
					end
				end

				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				if not backpack then
					return false
				end
				local v40 = nil

				for _, child in ipairs(backpack:GetChildren()) do
					if fn66(child) then
						if child.Name == arg then
							v40 = child
							break
						else
							v40 = v40 or child
						end
					end
				end

				if v40 then
					if not pcall(function()
						humanoid:EquipTool(v40)
					end) then
						return false
					end
					local n26 = os.clock() + 0.75

					while true do
						task.wait(0.05)

						if v40.Parent == character then
							return true
						elseif n26 <= os.clock() then
							break
						end
					end
				end

				return false
			end

			local v40 = nil
			local v41 = nil

			local function fn67()
				if v40 and v41 then
					return v40, v41
				end

				if not FishingController then
					pcall(function()
						FishingController = client.GetController("FishingController")
					end)
				end

				if not FishingController or not FishingController.OnStart then
					return nil, nil
				end
				local getupvalues_ = getupvalues or debug and debug.getupvalues
				if not getupvalues_ then
					return nil, nil
				end
				local ok, result = pcall(getupvalues_, FishingController.OnStart)
				local v42 = ok and result and result[41]
				if typeof(v42) ~= "function" then
					return nil, nil
				end
				local ok2, result2 = pcall(getupvalues_, v42)
				if not ok2 or not result2 then
					return nil, nil
				end

				if typeof(result2[5]) ~= "function" or typeof(result2[6]) ~= "function" then
					return nil, nil
				end
				v40 = result2[5]
				v41 = result2[6]
				return v40, v41
			end

			local function fn68(arg)
				local v42 = fn52()
				if not v42 then
					return Vector3.zero
				end
				local cast = FishingConfig and FishingConfig.Cast or { BaitMinDist = 15, BaitMaxDist = 30 }
				local n26 = cast.BaitMinDist + (arg or 0) * (cast.BaitMaxDist - cast.BaitMinDist)
				local unit = Vector3.new(v42.CFrame.LookVector.X, 0, v42.CFrame.LookVector.Z).Unit
				local n27 = v42.Position.X + unit.X * n26
				local n28 = v42.Position.Z + unit.Z * n26
				local str10 = ""

				pcall(function()
					local IslandController = client.GetController("IslandController")

					if IslandController then
						str10 = IslandController:GetCurrentIslandId() or ""
					end
				end)

				local n29 = 3

				pcall(function()
					n29 = Catalog.Island.GetWaterY(str10)
				end)

				return Vector3.new(n27, n29, n28)
			end

			local function fn69()
				task.wait(0.08)
				if flag31 or flag25 or flag26 or tbl8.pending or genv.HuneHubBossWaiting then
					return false
				end
				local n26 = math.min(math.max((FishingConfig.LuckBar and FishingConfig.LuckBar.Threshold or 0.8) + 0.15, 0.95), 0.98)
				local huneHubBossCastTarget = genv.HuneHubBossCastTarget

				if typeof(huneHubBossCastTarget) == "Vector3" then
					local ok, result = pcall(function()
						return type(genv.HuneHubBossValidateCast) == "function" and genv.HuneHubBossValidateCast()
					end)

					if not ok or not result then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						return false
					end

					local v42 = getupvalues
					local getupvalues_

					if v42 then
						getupvalues_ = v42
					else
						getupvalues_ = debug and debug.getupvalues
					end

					local ok2, result2 = pcall(function()
						return getupvalues_ and FishingController and getupvalues_(FishingController.OnTick)
					end)

					ok2 = ok2 and type(result2) == "table"
					local tryAutoCast

					if ok2 then
						tryAutoCast = result2.TryAutoCast or result2[14]
					else
						tryAutoCast = ok2
					end

					local ok3, result3 = pcall(function()
						return type(tryAutoCast) == "function" and getupvalues_(tryAutoCast)
					end)

					local flag37 = ok3 and type(result3) == "table" and result3[4]
					local flag38 = ok3 and type(result3) == "table" and result3[5]
					local flag39 = ok3 and type(result3) == "table" and result3[7]

					if type(flag37) ~= "function" or type(flag38) ~= "function" or type(flag39) ~= "function" then
						genv.HuneHubBossCastError = "Native cast unavailable; using packet fallback"

						return (pcall(function()
							FishingPackets.FishCast:Fire(n26, huneHubBossCastTarget)
						end))
					end

					local ok4, result4 = pcall(flag37, huneHubBossCastTarget)

					if not ok4 or result4 ~= nil then
						genv.HuneHubBossCastError = tostring(result4 or "Cast position rejected")

						return (pcall(function()
							FishingPackets.FishCast:Fire(n26, huneHubBossCastTarget)
						end))
					end

					local ok5, result5 = pcall(function()
						flag38(FishingEnums.State.Throwing)
						flag39(0, huneHubBossCastTarget, n26)
					end)

					if not ok5 then
						genv.HuneHubBossCastError = tostring(result5)

						pcall(function()
							FishingPackets.FishCast:Fire(n26, huneHubBossCastTarget)
						end)
					else
						genv.HuneHubBossCastError = nil
					end

					return ok5
				end

				local v42, v43 = fn67()

				if v42 and v43 then
					if pcall(v42) then
						local now5 = os.clock()

						while flag11 and resumeSoldFish and not flag31 and os.clock() - now5 < 2 do
							local v44 = fn53()

							if v44 == FishingEnums.State.Throwing then
								local luckBarValue = nil

								pcall(function()
									luckBarValue = FishingController:GetLuckBarValue()
								end)

								if type(luckBarValue) == "number" and luckBarValue >= n26 then
									return pcall(v43)
								end
							else
								if v44 == FishingEnums.State.Idling and os.clock() - now5 > 0.3 then
									break
								end

								if v44 ~= FishingEnums.State.Idling and v44 ~= FishingEnums.State.Holding then
									break
								end
							end

							task.wait(0.02)
						end

						pcall(v43)
						return false
					end
				end

				local v44 = fn68(n26)

				return (pcall(function()
					FishingPackets.FishCast:Fire(n26, v44)
				end))
			end

			fn55 = function(arg)
				if not arg then
					return "0"
				end

				if arg >= 1e9 then
					return string.format("%.2fB", arg / 1e9)
				end

				if arg >= 1000000 then
					return string.format("%.2fM", arg / 1000000)
				end

				if arg >= 1000 then
					return string.format("%.1fK", arg / 1000)
				end
				return tostring(math.floor(arg))
			end

			fn56 = function(arg)
				local n26 = math.floor(arg / 3600)
				local n27 = math.floor(arg % 3600 / 60)
				local n28 = math.floor(arg % 60)
				if n26 > 0 then
					return string.format("%dh %02dm %02ds", n26, n27, n28)
				end
				return string.format("%dm %02ds", n27, n28)
			end

			tbl8.hasSolidGroundUnder = function(arg, arg2)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { arg2 or arg.Parent }
				raycastParams.RespectCanCollide = true
				local hit = workspace:Raycast(arg.Position + Vector3.new(0, 1, 0), Vector3.new(0, -10, 0), raycastParams)
				return hit ~= nil and hit.Material ~= Enum.Material.Water
			end

			tbl8.walkGap = function(arg, arg2)
				local n26 = arg - arg2
				return Vector3.new(n26.X, 0, n26.Z).Magnitude
			end

			tbl8.passWalkObstacle = function(arg, arg2, arg3, arg4, arg5)
				local vector = Vector3.new(arg4.X - arg2.Position.X, 0, arg4.Z - arg2.Position.Z)
				local magnitude = vector.Magnitude
				if magnitude < 1 then
					return false, "Stuck"
				end
				local unit = vector.Unit
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { arg }
				raycastParams.RespectCanCollide = true

				for i = 1, math.ceil(magnitude / 2) do
					local hit = workspace:Raycast(arg2.Position + unit * math.min(i * 2, magnitude) + Vector3.new(0, 1, 0), Vector3.new(0, -10, 0), raycastParams)
					if not hit or hit.Material == Enum.Material.Water or math.abs(hit.Position.Y - arg2.Position.Y - 3) > 5 then
						return false, "NoSafeRoute"
					end
				end

				local tbl16 = {}

				local function fn70(descendant)
					if descendant:IsA("BasePart") and tbl16[descendant] == nil then
						tbl16[descendant] = descendant.CanCollide
						descendant.CanCollide = false
					end
				end

				for _, descendant in ipairs(arg:GetDescendants()) do
					fn70(descendant)
				end

				local connection = arg.DescendantAdded:Connect(fn70)

				local connection2 = game:GetService("RunService").Stepped:Connect(function()
					for k in pairs(tbl16) do
						if k.Parent then
							k.CanCollide = false
						end
					end
				end)

				local ok, result, result2 = pcall(function()
					local min = math.min
					local v42 = magnitude
					local n26 = os.clock() + min(v42 / math.max(arg3.WalkSpeed, 8) + 1.5, 4)
					local position = arg2.Position
					arg3:MoveTo(arg4)

					while os.clock() < n26 do
						if not flag11 or localPlayer.Character ~= arg or not arg2.Parent or arg3.Health <= 0 or arg5 and not arg5() then
							return false, "Cancelled"
						end

						if tbl8.walkGap(arg2.Position, arg4) <= 3.5 and math.abs(arg2.Position.Y - arg4.Y) <= 6 then
							return true, "ObstaclePassed"
						end

						if not tbl8.hasSolidGroundUnder(arg2, arg) then
							return false, "NoSafeRoute"
						end
						task.wait(0.05)
						if (arg2.Position - position).Magnitude > 12 then
							return false, "PositionCorrected"
						end
						position = arg2.Position
					end

					return false, "Stuck"
				end)

				connection2:Disconnect()
				connection:Disconnect()

				for k, v42 in pairs(tbl16) do
					if k.Parent then
						k.CanCollide = v42
					end
				end

				if not ok then
					return false, "Stuck"
				end
				return result, result2
			end

			fn57 = function(arg, arg2)
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
					return false, "CharacterNotReady"
				end

				if humanoid.FloorMaterial == Enum.Material.Water or not tbl8.hasSolidGroundUnder(humanoidRootPart, character) then
					return false, "NoSafeRoute"
				end
				local magnitude = (humanoidRootPart.Position - arg.Position).Magnitude

				if magnitude <= 6 then
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = { character }
					raycastParams.RespectCanCollide = true
					if not workspace:Raycast(humanoidRootPart.Position, arg.Position - humanoidRootPart.Position, raycastParams) then
						return true, "AlreadyClose"
					end
				end

				if magnitude > 1500 then
					return false, "NoSafeRoute"
				end

				if arg2 and not arg2() then
					return false, "Cancelled"
				end

				local ok, result = pcall(function()
					return PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 9 })
				end)

				if not ok or not result then
					return false, "NoSafeRoute"
				end

				if not pcall(function()
					result:ComputeAsync(humanoidRootPart.Position, arg.Position)
				end) or result.Status ~= Enum.PathStatus.Success then
					result:Destroy()
					return false, "NoSafeRoute"
				end

				local waypoints = result:GetWaypoints()
				result:Destroy()
				if #waypoints == 0 then
					return false, "NoSafeRoute"
				end
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { character }
				raycastParams.RespectCanCollide = true

				for _, waypoint in ipairs(waypoints) do
					local hit = workspace:Raycast(waypoint.Position + Vector3.new(0, 5, 0), Vector3.new(0, -14, 0), raycastParams)
					if not hit or hit.Material == Enum.Material.Water then
						return false, "NoSafeRoute"
					end
				end

				local position = humanoidRootPart.Position
				local now5 = os.clock()

				for i, waypoint in ipairs(waypoints) do
					if not flag11 or localPlayer.Character ~= character or humanoid.Health <= 0 or arg2 and not arg2() then
						humanoid:MoveTo(humanoidRootPart.Position)
						return false, "Cancelled"
					end

					if humanoid.FloorMaterial == Enum.Material.Water then
						humanoid:MoveTo(humanoidRootPart.Position)
						return false, "NoSafeRoute"
					end
					local n26 = i == #waypoints and 2.5 or 4
					if tbl8.walkGap(humanoidRootPart.Position, waypoint.Position) <= n26 and math.abs(humanoidRootPart.Position.Y - waypoint.Position.Y) <= 6 then
						continue
					end

					if waypoint.Action == Enum.PathWaypointAction.Jump then
						humanoid.Jump = true
					end

					humanoid:MoveTo(waypoint.Position)
					local clamp = math.clamp
					local n27 = os.clock() + clamp(tbl8.walkGap(humanoidRootPart.Position, waypoint.Position) / math.max(humanoid.WalkSpeed, 4) * 2 + 2, 3, 8)
					local now6 = os.clock()
					local v42 = tbl8.walkGap(humanoidRootPart.Position, waypoint.Position)
					local flag37 = waypoint.Action == Enum.PathWaypointAction.Jump
					local flag38 = false

					while tbl8.walkGap(humanoidRootPart.Position, waypoint.Position) > n26 or math.abs(humanoidRootPart.Position.Y - waypoint.Position.Y) > 6 do
						if not flag11 or localPlayer.Character ~= character or humanoid.Health <= 0 or arg2 and not arg2() then
							humanoid:MoveTo(humanoidRootPart.Position)
							return false, "Cancelled"
						end
						task.wait(0.1)
						if humanoid.FloorMaterial == Enum.Material.Water then
							humanoid:MoveTo(humanoidRootPart.Position)
							return false, "NoSafeRoute"
						end
						local now7 = os.clock()
						local position2 = humanoidRootPart.Position
						local magnitude2 = (position2 - position).Magnitude
						if math.max(18, humanoid.WalkSpeed * math.max(now7 - now5, 0.01) * 3 + 8) < magnitude2 then
							humanoid:MoveTo(position2)
							return false, "PositionCorrected"
						end
						local v43 = tbl8.walkGap(position2, waypoint.Position)

						if v43 < v42 - 1 then
							v42 = v43
							now6 = now7
						end

						if now7 - now6 > 1.1 and not flag37 then
							humanoid.Jump = true

							pcall(function()
								humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end)

							humanoid:MoveTo(waypoint.Position)
							flag37 = true
							now5 = now7
							position = position2
							now6 = now7
							n27 = math.max(n27, now7 + 2.5)
							continue
						end

						if now7 - now6 > 1.1 and not flag38 then
							local v44, v45 = tbl8.passWalkObstacle(character, humanoidRootPart, humanoid, waypoint.Position, arg2)
							if not v44 then
								humanoid:MoveTo(humanoidRootPart.Position)
								return false, v45 or "Stuck"
							end
							position = humanoidRootPart.Position
							now5 = os.clock()
							v42 = tbl8.walkGap(humanoidRootPart.Position, waypoint.Position)
							local n28 = math.max(n27, now5 + 2)
							humanoid:MoveTo(waypoint.Position)
							flag38 = true
							now6 = now5
							n27 = n28
							continue
						end

						if now7 >= n27 or now7 - now6 > 3 then
							humanoid:MoveTo(position2)
							return false, "Stuck"
						end
						now5 = now7
						position = position2
					end
				end

				if (humanoidRootPart.Position - arg.Position).Magnitude <= 8 and tbl8.hasSolidGroundUnder(humanoidRootPart, character) then
					return true, "WalkFinished"
				end
				return false, "ArrivalUnconfirmed"
			end

			local function fn70(arg, arg2, arg3, arg4)
				local TweenService = game:GetService("TweenService")
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
					return false, "CharacterNotReady"
				end

				if arg2 and not arg2() then
					return false, "Cancelled"
				end
				local magnitude = (humanoidRootPart.Position - arg.Position).Magnitude
				if magnitude <= (arg4 and 0.15 or 6) then
					return true, "AlreadyClose"
				end
				local position = humanoidRootPart.Position
				local position2 = arg.Position
				local n26 = math.clamp(math.ceil(magnitude / (arg3 and 40 or 140)), 1, 150)
				local flag37 = magnitude > 160
				local tbl16 = {}

				for i = 1, n26 do
					local n27 = i / n26

					if i == n26 then
						tbl16[i] = arg
					else
						local vector = position:Lerp(position2, n27)

						if flag37 then
							vector = Vector3.new(vector.X, math.max(position.Y, position2.Y) + math.sin(n27 * 3.1415926535897931) * 25, vector.Z)
						end

						local rotation = humanoidRootPart.CFrame.Rotation
						tbl16[i] = CFrame.new(vector) * rotation
					end
				end

				local tbl17 = {}

				local function fn71(descendant)
					if descendant:IsA("BasePart") and tbl17[descendant] == nil then
						tbl17[descendant] = descendant.CanCollide
						descendant.CanCollide = false
					end
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					fn71(descendant)
				end

				local connection = character.DescendantAdded:Connect(fn71)

				local connection2 = game:GetService("RunService").Stepped:Connect(function()
					for k in pairs(tbl17) do
						if k.Parent then
							k.CanCollide = false
						end
					end
				end)

				local platformStand = humanoid.PlatformStand
				humanoid.PlatformStand = true
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "HuneHubTravelHold"
				bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bodyVelocity.Velocity = Vector3.zero
				bodyVelocity.Parent = humanoidRootPart
				local tween = nil
				local connection3 = nil

				local ok, result, result2 = pcall(function()
					for _, v42 in ipairs(tbl16) do
						if not flag11 or localPlayer.Character ~= character or not humanoidRootPart.Parent or humanoid.Health <= 0 or arg2 and not arg2() then
							return false, "Cancelled"
						end
						local magnitude2 = (humanoidRootPart.Position - v42.Position).Magnitude
						local n27 = math.clamp(tonumber(arg3) or tonumber(genv.HuneHubTravelSpeed) or 70, 20, 300)
						local n28 = math.max(magnitude2 / n27, 0.01)
						tween = TweenService:Create(humanoidRootPart, TweenInfo.new(n28, Enum.EasingStyle.Linear), { CFrame = v42 })
						local v43 = nil

						connection3 = tween.Completed:Connect(function(playbackState)
							v43 = playbackState
						end)

						tween:Play()
						local position3 = humanoidRootPart.Position
						local now5 = os.clock()
						local n29 = now5 + n28 + 3

						while not v43 do
							if not flag11 or localPlayer.Character ~= character or not humanoidRootPart.Parent or humanoid.Health <= 0 or arg2 and not arg2() then
								tween:Cancel()
								return false, "Cancelled"
							end
							task.wait(0.05)
							local now6 = os.clock()
							if n29 < now6 then
								tween:Cancel()
								return false, "TweenInterrupted"
							end
							local position4 = humanoidRootPart.Position
							if (position4 - position3).Magnitude > math.max(12, n27 * (now6 - now5) * 3 + 4) then
								tween:Cancel()
								return false, "PositionCorrected"
							end
							position3 = position4
							now5 = now6
						end

						connection3:Disconnect()
						connection3 = nil
						tween:Destroy()
						tween = nil
						if v43 ~= Enum.PlaybackState.Completed then
							return false, "TweenInterrupted"
						end

						if (humanoidRootPart.Position - v42.Position).Magnitude > 12 then
							return false, "PositionCorrected"
						end
					end

					return true, "TweenFinished"
				end)

				if tween then
					tween:Cancel()
					tween:Destroy()
				end

				if connection3 then
					connection3:Disconnect()
				end

				connection2:Disconnect()
				connection:Disconnect()
				bodyVelocity:Destroy()

				if humanoid.Parent then
					humanoid.PlatformStand = platformStand
				end

				if humanoidRootPart.Parent then
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end

				for k, v42 in pairs(tbl17) do
					if k.Parent then
						k.CanCollide = v42
					end
				end

				if not ok then
					return false, "TweenFailed"
				end

				if not result then
					return false, result2
				end
				local flag38 = not humanoidRootPart.Parent

				if not flag38 then
					flag38 = (humanoidRootPart.Position - arg.Position).Magnitude > (arg4 and 1.5 or 8)
				end

				if flag38 then
					return false, "ArrivalUnconfirmed"
				end
				return true, result2
			end

			local fn71 = nil

			fn71 = function(arg)
				if not arg then
					return nil
				end

				if arg:IsA("BasePart") then
					return arg.Position
				end

				if arg:IsA("Attachment") then
					return arg.WorldPosition
				end

				if arg:IsA("Model") then
					local ok, result = pcall(function()
						return arg:GetPivot()
					end)

					if ok and result then
						return result.Position
					end
				elseif arg:IsA("ProximityPrompt") then
					return fn71(arg.Parent)
				end

				local basePart = arg:FindFirstChildWhichIsA("BasePart", true)
				if basePart then
					return basePart.Position
				end
				local attachment = arg:FindFirstChildWhichIsA("Attachment", true)
				if attachment then
					return attachment.WorldPosition
				end
				return nil
			end

			local function fn72(arg)
				local lower = string.lower
				local str10 = tostring(arg):gsub("[^%w]", "")
				return lower(str10)
			end

			local function fn73(arg)
				local isProximityPrompt = arg:IsA("ProximityPrompt") and arg or arg:FindFirstChildWhichIsA("ProximityPrompt", true)
				return fn71(isProximityPrompt and isProximityPrompt.Parent or arg)
			end

			local function fn74(arg)
				local v42 = fn52()
				if not v42 then
					return nil, nil
				end
				local v43 = nil
				local v44 = nil
				local huge = math.huge
				local str10 = arg == "npc_fish_seller" and "fishmerchant" or fn72(arg)

				local function fn75(arg2, arg3)
					if not arg2:IsDescendantOf(workspace) then
						return
					end
					local flag37 = false

					pcall(function()
						flag37 = arg2:GetAttribute("InteractiveId") == arg
					end)

					if not flag37 and arg3 and (arg2:IsA("Model") or arg2:IsA("BasePart")) and arg2:FindFirstChildWhichIsA("ProximityPrompt", true) then
						local v45 = fn72(arg2.Name)
						local flag38 = v45 == str10

						if flag38 then
							flag37 = flag38
						else
							local flag39 = arg == "npc_fish_seller"

							if flag39 then
								flag37 = v45 == "fishseller" or v45 == "npcfishseller"
							else
								flag37 = flag39
							end
						end
					end

					if flag37 then
						local v45 = fn73(arg2)

						if v45 then
							local magnitude = (v42.Position - v45).Magnitude

							if magnitude < huge then
								v43 = arg2
								v44 = v45
								huge = magnitude
							end
						end
					end
				end

				local tbl16 = {}

				pcall(function()
					tbl16 = CollectionService:GetTagged("Interactive")
				end)

				for _, v45 in ipairs(tbl16) do
					fn75(v45, false)
				end

				if not v43 then
					for _, descendant in ipairs(workspace:GetDescendants()) do
						fn75(descendant, true)
					end
				end

				return v43, v44
			end

			local function fn75(arg, arg2)
				local v42 = fn52()
				if not v42 then
					return nil
				end
				local vector = Vector3.new(v42.Position.X - arg.X, 0, v42.Position.Z - arg.Z)
				local vector2

				if vector.Magnitude < 0.1 then
					vector2 = Vector3.new(0, 0, 1)
				else
					vector2 = vector.Unit
				end

				local n26 = arg + vector2 * (arg2 or 6) + Vector3.new(0, 2.5, 0)
				local vector3 = Vector3.new(arg.X, n26.Y, arg.Z)
				return CFrame.lookAt(n26, vector3)
			end

			fn58 = function()
				local reeling = FishingEnums.State.Reeling

				if fn53() == reeling and resumeSoldFish then
					local n26 = os.clock() + 35

					while true do
						if flag11 and os.clock() < n26 then
							local reeling2 = FishingEnums.State.Reeling
							if fn53() == reeling2 then
								task.wait(0.1)
								continue
							end
						end

						break
					end
				end

				local v42 = fn53()

				if v42 == FishingEnums.State.Caught then
					local n26 = os.clock() + 3

					while true do
						local flag37 = flag11 and os.clock() < n26

						if flag37 then
							local caught = FishingEnums.State.Caught
							flag37 = fn53() == caught
						end

						if flag37 then
							if fn47 then
								fn47()
							end

							task.wait(0.15)
							continue
						end

						break
					end
				elseif v42 ~= FishingEnums.State.Idling then
					pcall(function()
						FishingPackets.FishCancel:Fire()
					end)
				end

				local n26 = os.clock() + 2

				while true do
					local flag37 = flag11 and os.clock() < n26

					if flag37 then
						local idling2 = FishingEnums.State.Idling
						flag37 = fn53() ~= idling2
					end

					if flag37 then
						local caught = FishingEnums.State.Caught

						if fn53() == caught and fn47 then
							fn47()
						end

						task.wait(0.1)
						continue
					end

					break
				end

				flag32 = false
				n22 += 1
				flag33 = false
				n23 += 1
				flag34 = false
				n24 += 1
				flag35 = false
				n10 += 1
				flag17 = false
			end

			local function fn76(arg, arg2, arg3)
				local n26 = tonumber(arg) or 0
				local n27 = tonumber(arg2) or 0
				n20 += n26

				lib:Notify({
					Title = text("Fish Sold"),
					Content = string.format(text("+%s Coins (%d Fish) • %s"), fn55(n26), n27, arg3),
					Duration = 3,
				})

				return true, SellEnums.Status.Ok, n26, n27, arg3
			end

			tbl8.moveTo = function(arg, arg2)
				if tbl8.method == "Tween" then
					local v42, v43 = fn70(arg, nil, tbl8.tweenSpeed, arg2)
					if v42 or not arg2 then
						return v42, v43
					end
					local v44, v45 = fn57(arg)
					if v44 then
						return true, "WalkReturn"
					end
					return false, v45 or v43
				end

				return fn57(arg)
			end

			tbl8.walkToMerchant = function(arg)
				local v42 = fn52()
				if not v42 then
					return false, "CharacterNotReady"
				end
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { v42.Parent }
				raycastParams.RespectCanCollide = true
				local tbl16 = {}
				local vector = Vector3.new(v42.Position.X - arg.X, 0, v42.Position.Z - arg.Z)
				local n26 = vector.Magnitude > 0.1 and math.atan2(vector.Z, vector.X) or 0

				for _, v43 in ipairs({ 18, 14, 8 }) do
					for i = 0, 7 do
						local n27 = n26 + i * 3.1415926535897931 / 4
						local hit = workspace:Raycast(arg + Vector3.new(math.cos(n27) * v43, 0, math.sin(n27) * v43) + Vector3.new(0, 12, 0), Vector3.new(0, -30, 0), raycastParams)

						if hit and hit.Material ~= Enum.Material.Water then
							local n28 = hit.Position + Vector3.new(0, 3, 0)

							if (n28 - arg).Magnitude <= 20 then
								table.insert(tbl16, { cframe = CFrame.new(n28), distance = (v42.Position - n28).Magnitude })
							end
						end
					end
				end

				table.sort(tbl16, function(arg2, arg3)
					return arg2.distance < arg3.distance
				end)

				local str10 = "NoSafeRoute"

				for i = 1, math.min(#tbl16, 6) do
					local v43, v44 = fn57(tbl16[i].cframe)

					if v43 then
						if (v42.Position - arg).Magnitude <= 20 then
							return true, v44
						end
						str10 = "MerchantOutOfRange"
						continue
					end

					str10 = v44 or str10
					if v44 ~= "NoSafeRoute" and v44 ~= "ArrivalUnconfirmed" then
						return false, str10
					end
				end

				return false, str10
			end

			tbl8.deferReturn = function(lastReturnReason)
				tbl8.pending = true
				tbl8.lastReturnReason = lastReturnReason or "ReturnFailed"
				tbl8.attempts = tbl8.attempts + 1
				tbl8.retryAt = os.clock() + math.min(4 + tbl8.attempts * 2, 20)
				return false, tbl8.lastReturnReason
			end

			tbl8.waitForSale = function(lastSaleReason)
				flag26 = true
				tbl8.saleAttempts = tbl8.saleAttempts + 1
				tbl8.saleRetryAt = os.clock() + math.min(2 + tbl8.saleAttempts * 2, 15)
				tbl8.lastSaleReason = lastSaleReason or "SaleUnconfirmed"
				return false, tbl8.lastSaleReason, 0, 0
			end

			tbl8.atSavedSpot = function(arg, arg2, arg3)
				if localPlayer.Character ~= arg2 or not arg.Parent then
					return false
				end
				local humanoid = arg2:FindFirstChildOfClass("Humanoid")
				local n26 = arg.Position - arg3.Position
				local flag37 = humanoid and humanoid.Health > 0 and Vector3.new(n26.X, 0, n26.Z).Magnitude <= 1.5 and math.abs(n26.Y) <= 2 and math.abs(arg.AssemblyLinearVelocity.Y) <= 3

				if flag37 then
					local swimming = Enum.HumanoidStateType.Swimming
					flag37 = humanoid:GetState() ~= swimming
				end

				return flag37 and humanoid.FloorMaterial ~= Enum.Material.Water and tbl8.hasSolidGroundUnder(arg, arg2)
			end

			tbl8.restore = function()
				local v42 = v37
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not v42 or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
					return tbl8.deferReturn("ReturnPositionUnavailable")
				end
				tbl8.pending = true

				pcall(function()
					localPlayer:RequestStreamAroundAsync(v42.Position, 2)
				end)

				local ok, result, result2 = pcall(function()
					return tbl8.moveTo(v42, true)
				end)

				if not ok then
					result = false
					result2 = "ReturnFailed"
				end

				if result and (tbl8.method == "Walk" or result2 == "WalkReturn") then
					humanoid:MoveTo(v42.Position)
					local n26 = os.clock() + 4

					while flag11 and localPlayer.Character == character and humanoidRootPart.Parent and humanoid.Health > 0 and os.clock() < n26 and not tbl8.atSavedSpot(humanoidRootPart, character, v42) do
						task.wait(0.1)
					end

					if humanoidRootPart.Parent then
						humanoid:MoveTo(humanoidRootPart.Position)
					end
				end

				if result then
					local rotation = v42.Rotation
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * rotation
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					for i = 1, 5 do
						task.wait(0.2)

						if not flag11 or not tbl8.atSavedSpot(humanoidRootPart, character, v42) then
							result = false
							result2 = "ReturnPositionChanged"
							break
						end
					end
				end

				if not result then
					return tbl8.deferReturn(result2)
				end
				cFrame2 = v42

				if flag30 then
					cFrame = v42
				end

				tbl8.farmSpotPending = false
				tbl8.pending = false
				tbl8.lastReturnReason = nil
				tbl8.attempts = 0
				tbl8.retryAt = 0
				flag26 = false
				v37 = nil
				flag24 = false

				if tbl8.saleHadFish then
					flag22 = false
					tbl8.bagRefreshAfter = os.clock() + 3
					tbl8.resumeSoldFish = resumeSoldFish
					tbl8.saleHadFish = false
				end

				v38 = nil
				n25 = os.clock() + math.max(tonumber(n7) or 0.35, 0.3)
				tbl8.resumeFarm = resumeSoldFish
				tbl8.resumeStage = 0
				tbl8.resumeAt = os.clock() + 0.2
				tbl8.resumeCancelAt = 0
				return true, "Returned"
			end

			tbl8.tryRestore = function()
				local ok, result, result2 = pcall(tbl8.restore)
				if ok then
					return result, result2
				end
				return tbl8.deferReturn("ReturnFailed")
			end

			fn59 = function()
				if flag31 then
					return false, "MovementBusy", 0, 0
				end

				if tbl8.pending then
					flag31 = true
					local v42, v43 = tbl8.tryRestore()
					flag31 = false
					return v42, v42 and "ReturnCompleted" or v43, 0, 0
				end

				if tbl10.sellEnabled then
					if tbl10.locking then
						if flag26 then
							return tbl8.waitForSale("FishLockBusy")
						end
						return false, "FishLockBusy", 0, 0
					end

					tbl10.locking = true

					local ok, result = pcall(function()
						return tbl10:applyLocks()
					end)

					tbl10.locking = false

					if tbl10.lockAgain then
						tbl10.lockAgain = false
						tbl10:queueLocks()
					end

					if not ok or not result then
						if flag26 then
							return tbl8.waitForSale("FishLockFailed")
						end
						return false, "FishLockFailed", 0, 0
					end
				end

				local npcFishSeller, v42 = fn74("npc_fish_seller")

				if not v42 then
					if flag26 then
						return tbl8.waitForSale("MerchantNotFound")
					end
					return false, "MerchantNotFound", 0, 0
				end

				local v43 = fn52()

				if not v43 then
					if flag26 then
						return tbl8.waitForSale("CharacterNotReady")
					end
					return false, "CharacterNotReady", 0, 0
				end

				if not cFrame2 and not flag26 then
					cFrame2 = v43.CFrame
				end

				local cFrame3 = v37 or cFrame2 or v43.CFrame
				local str10 = nil
				local n26 = 0
				local n27 = 0
				v37 = cFrame3

				if not flag26 then
					tbl8.rodId = nil
					local character = localPlayer.Character

					if character then
						for _, child in ipairs(character:GetChildren()) do
							if fn66(child) then
								tbl8.rodId = child.Name
								break
							end
						end
					end
				end

				flag31 = true

				if not pcall(function()
					fn58()

					if (v43.Position - v42).Magnitude > 20 then
						local v44, v45

						if tbl8.method == "Walk" then
							v44, v45 = tbl8.walkToMerchant(v42)
						else
							v44 = fn75(v42, 6)
							v44 = v44 and tbl8.moveTo(v44)
							v45 = nil
						end

						if not v44 then
							str10 = v45 or "TweenFailed"
							error("Unable to reach Fish Merchant")
						end
					end

					local v44 = npcFishSeller:IsDescendantOf(workspace) and fn73(npcFishSeller) or nil

					if not v44 or not v43.Parent or (v43.Position - v44).Magnitude > 20 then
						str10 = "MerchantOutOfRange"
						error("Fish Merchant is not within sell range")
					end

					task.wait(0.5)

					if tbl10.sellEnabled then
						if tbl10.locking then
							str10 = "FishLockBusy"
							error("Fish protection is still running")
						end

						tbl10.locking = true

						local ok, result = pcall(function()
							return tbl10:applyLocks()
						end)

						tbl10.locking = false

						if tbl10.lockAgain then
							tbl10.lockAgain = false
							tbl10:queueLocks()
						end

						if not ok or not result then
							str10 = "FishLockFailed"
							error("Protected fish lock was not confirmed")
						end
					end

					for i = 1, 5 do
						local v45, v46, v47 = v30:Fire()
						str10 = v45
						n26 = v46
						n27 = v47
						if str10 == SellEnums.Status.Busy then
							task.wait(0.5)
							continue
						end
						break
					end
				end) then
					flag31 = false
					return tbl8.waitForSale(str10 or "RequestFailed")
				end

				local flag37 = str10 == SellEnums.Status.Ok
				local flag38 = str10 == SellEnums.Status.Empty
				if not flag37 and not flag38 then
					flag31 = false
					return tbl8.waitForSale(str10 or "SaleUnconfirmed")
				end
				flag26 = false
				tbl8.saleAttempts = 0
				tbl8.saleRetryAt = 0
				tbl8.lastSaleReason = nil
				local v44 = tbl8
				local saleHadFish

				if flag37 then
					saleHadFish = (tonumber(n27) or 0) > 0
				else
					saleHadFish = flag37
				end

				v44.saleHadFish = saleHadFish
				local v45, v46 = tbl8.tryRestore()
				flag31 = false

				if not v45 then
					lib:Notify({
						Title = text("Returning To Fishing Spot"),
						Content = text("The saved position is being retried (") .. tostring(v46) .. ").",
						Duration = 4,
					})
				end

				if flag37 then
					return fn76(n26, n27, "Fish Merchant")
				end

				if flag38 then
					return false, str10, tonumber(n26) or 0, tonumber(n27) or 0
				end
			end

			local function fn77()
				local ok, result = pcall(function()
					local v42 = PlayerDataV2Controller:Fetch(localPlayer)
					if type(v42) ~= "table" then
						return nil
					end
					return FishStorageRules.GetState(v42)
				end)

				if ok and type(result) == "table" then
					return result.isFull == true
				end
				return nil
			end

			fn60 = function(arg)
				if arg == "PositionCorrected" or arg == "TweenInterrupted" or arg == "TweenFailed" then
					return
				end
				local lastFailureKey = tostring(arg) .. ":" .. tostring(tbl8.pending) .. ":" .. tostring(tbl8.lastReturnReason)
				local now5 = os.clock()
				if lastFailureKey == tbl8.lastFailureKey and now5 - tbl8.lastFailureAt < 6 then
					return
				end
				tbl8.lastFailureKey = lastFailureKey
				tbl8.lastFailureAt = now5

				if tbl8.pending then
					local str10 = tbl8.method == "Walk" and tbl8.lastReturnReason == "NoSafeRoute" and "No safe walking route back to the saved fishing spot. Select Tween in Auto Sell to retry the return." or "The saved fishing spot has not been reached. Auto Farm is paused; check your position or select Tween to retry."
					lib:Notify({ Title = text("Return To Fishing Spot Pending"), Content = str10, Duration = 5 })
				elseif arg == SellEnums.Status.Empty then
					lib:Notify({
						Title = text("No Fish To Sell"),
						Content = text("No unlocked fish are available."),
						Duration = 3,
					})
				elseif arg == SellEnums.Status.OutOfRange then
					lib:Notify({
						Title = text("Merchant Out Of Range"),
						Content = text("Staying at the merchant until the next sell attempt."),
						Duration = 4,
					})
				elseif arg == SellEnums.Status.Busy then
					lib:Notify({
						Title = text("Sell Request Busy"),
						Content = text("Please try again in a moment."),
						Duration = 3,
					})
				elseif arg == "MerchantNotFound" then
					lib:Notify({
						Title = text("Fish Merchant Not Found"),
						Content = text("Wait for the island NPC to load, then try again."),
						Duration = 4,
					})
				elseif arg == "MerchantOutOfRange" then
					lib:Notify({
						Title = text("Merchant Out Of Range"),
						Content = text("The character stopped outside the merchant's sell radius."),
						Duration = 4,
					})
				elseif arg == "NoSafeRoute" then
					lib:Notify({
						Title = text("No Walking Route"),
						Content = text("Move closer to a Fish Merchant or select Tween in Auto Sell."),
						Duration = 4,
					})
				elseif arg == "MovementBusy" then
					lib:Notify({
						Title = text("Movement Busy"),
						Content = text("Wait for the current travel action to finish."),
						Duration = 3,
					})
				elseif arg == "ReturnPositionChanged" or arg == "ReturnPositionUnavailable" or arg == "ReturnFailed" then
					lib:Notify({
						Title = text("Return Pending"),
						Content = text("The saved fishing position has not been reached. Auto Farm remains paused."),
						Duration = 4,
					})
				elseif arg == "FishLockBusy" or arg == "FishLockFailed" then
					lib:Notify({
						Title = text("Fish Filter"),
						Content = text("Could not confirm protected fish are locked. Sale postponed."),
						Duration = 4,
					})
				else
					lib:Notify({
						Title = text("Sell Request Failed"),
						Content = text("Sale was not confirmed, so the character will not return yet."),
						Duration = 4,
					})
				end
			end

			fn61 = function()
				local currentIslandId

				pcall(function()
					local IslandRegionController = client.GetController("IslandRegionController")
					currentIslandId = IslandRegionController and IslandRegionController:GetCurrentIslandId()
				end)

				return currentIslandId
			end

			local function fn78(arg)
				for _, v42 in ipairs(CollectionService:GetTagged("IslandRegion")) do
					if v42:IsA("BasePart") and v42:IsDescendantOf(workspace) and v42:GetAttribute("islandId") == arg then
						return v42
					end
				end

				return nil
			end

			local function fn79(arg)
				local world = workspace:FindFirstChild("World")
				local islands = world and world:FindFirstChild("Islands")
				islands = islands and islands:FindFirstChild(arg)
				if not islands then
					return nil
				end

				for _, v42 in ipairs(CollectionService:GetTagged("Interactive")) do
					if v42:IsDescendantOf(islands) then
						local attribute = v42:GetAttribute("InteractiveId")

						if type(attribute) == "string" and attribute:match("^npc_unlock_island_%d+$") then
							local v43 = fn73(v42)
							if v43 then
								return fn75(v43, 6)
							end
						end
					end
				end

				local spawnPoint = islands:FindFirstChild("SpawnPoint")
				local v42 = fn71(spawnPoint)
				if v42 then
					return CFrame.new(v42 + Vector3.new(0, 4, 0))
				end

				for _, v43 in ipairs(CollectionService:GetTagged("Interactive")) do
					if v43:IsDescendantOf(islands) then
						if v43:GetAttribute("InteractiveId") ~= "npc_fish_seller" then
							continue
						end
						local v44 = fn73(v43)
						if v44 then
							return fn75(v44, 5)
						end
					end
				end

				for _, descendant in ipairs(islands:GetDescendants()) do
					if descendant:IsA("BasePart") then
						local v43 = fn72(descendant.Name)
						if v43 == "spawn" or v43 == "spawnpoint" or v43 == "teleportpoint" or v43 == "arrival" then
							return CFrame.new(descendant.Position + Vector3.new(0, 4, 0))
						end
					end
				end

				local v43 = fn78(arg)

				if v43 then
					local n26 = v43.Position + Vector3.new(0, v43.Size.Y * 0.5 + 80, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.RespectCanCollide = true
					local filterDescendantsInstances = { v43 }
					local zones = islands:FindFirstChild("Zones")

					if zones then
						table.insert(filterDescendantsInstances, zones)
					end

					if localPlayer.Character then
						table.insert(filterDescendantsInstances, localPlayer.Character)
					end

					raycastParams.FilterDescendantsInstances = filterDescendantsInstances
					local hit = workspace:Raycast(n26, Vector3.new(0, -v43.Size.Y - 250, 0), raycastParams)
					if hit and hit.Instance:IsDescendantOf(islands) and hit.Normal.Y > 0.5 then
						return CFrame.new(hit.Position + Vector3.new(0, 4, 0))
					end
				end

				return nil
			end

			local function fn80(arg, arg2)
				local v42 = tbl5[arg]
				if not v42 then
					return false, "IslandNotFound"
				end
				local v43 = flag31
				local v44

				if flag31 then
					v44 = v43
				else
					v44 = flag25
				end

				if v44 or tbl8.pending or flag26 then
					return false, "MovementBusy"
				end
				local id = v42.id
				if fn61() == id then
					return false, "AlreadyAtDestination"
				end

				if not fn52() then
					return false, "CharacterNotReady"
				end
				flag31 = true

				local ok, result, result2 = pcall(function()
					fn58()
					if arg2 and not arg2() then
						return false, "Cancelled"
					end
					local v45 = fn79(v42.id)
					local v46

					if not v45 then
						local v47 = fn78(v42.id)

						if v47 then
							pcall(function()
								localPlayer:RequestStreamAroundAsync(v47.Position, 2)
							end)

							v45 = fn79(v42.id)
						end

						v46 = v45
					else
						v46 = v45
					end

					if not v46 then
						return false, "DestinationNotLoaded"
					end
					local v47, v48 = fn70(v46, arg2)
					if not v47 then
						return false, v48
					end
					local n26 = os.clock() + 4

					while flag11 and os.clock() < n26 do
						if arg2 and not arg2() then
							return false, "Cancelled"
						end
						local id2 = v42.id

						if fn61() == id2 then
							cFrame = nil
							cFrame2 = nil
							v38 = nil
							n25 = os.clock() + 1
							return true, "TweenArrived"
						end

						task.wait(0.15)
					end

					return false, "ArrivalUnconfirmed"
				end)

				flag31 = false
				if not ok then
					return false, "RequestFailed"
				end
				return result, result2
			end

			local function fn81()
				n14 += 1
				n12 = 0
				n13 = 0
				flag18 = false
				n15 = 0
			end

			local function fn82()
				if not RodController then
					pcall(function()
						RodController = client.GetController("RodController")
					end)
				end

				if RodController and not flag19 and RodController.ReplicatedSkillCooldown then
					local ok, result = pcall(function()
						return RodController.ReplicatedSkillCooldown.OnClientEvent:Connect(function(arg)
							if type(arg) ~= "table" then
								return
							end

							for k, v42 in pairs(arg) do
								if type(k) == "string" and type(v42) == "table" then
									if v42.phase == "Ready" then
										tbl7[k] = nil
									elseif v42.phase == "Cooldown" and type(v42.remaining) == "number" and v42.remaining > 0 then
										local remaining = v42.remaining
										tbl7[k] = { phase = "Cooldown", remaining = v42.remaining, expiresAt = os.clock() + remaining }
									elseif v42.phase == "Casting" then
										local v43 = tbl7[k]
										local v44 = tbl7
										local tbl16 = { phase = "Casting", remaining = v42.remaining }
										local expiresAt = type(v43) == "table" and v43.expiresAt

										if not expiresAt then
											expiresAt = os.clock() + math.max(tonumber(v42.remaining) or 0, 0.5) + 10
										end

										tbl16.expiresAt = expiresAt
										v44[k] = tbl16
									else
										tbl7[k] = v42
									end
								end
							end
						end)
					end)

					if ok and result then
						flag19 = true
						fn48(result)
					end
				end

				return RodController
			end

			local function fn83()
				local v42 = nil

				pcall(function()
					v42 = PlayerDataV2Controller:Fetch(localPlayer)
				end)

				if not v42 then
					pcall(function()
						v42 = PlayerDataV2Controller:Fetch()
					end)
				end

				local rodEquip = v42 and v42.RodEquip
				local rods = rodEquip and v42.Rods and v42.Rods[rodEquip]
				rodEquip = rodEquip and Catalog.Rod.GetById(rodEquip)
				local v43 = nil

				if rods then
					pcall(function()
						v43 = require(ReplicatedStorage.Shared.Lib.getRequiredExp_Level).getLevel(rods.MasteryXp or 0)
					end)
				end

				return rods and rods.BookSlots or nil, rodEquip, v43
			end

			local function fn84()
				return n13 > 0 and n12 > 0 and n12 <= n13 * finisherPct + 0.001
			end

			local function fn85()
				if flag18 or not flag11 or not flag32 or not flag16 or not tbl10:allowsCurrent() then
					return
				end
				flag18 = true
				local v42 = n14

				task.spawn(function()
					local v43 = fn82()
					local v44, v45, v46 = fn83()

					if not v43 or type(v44) ~= "table" then
						if v42 == n14 then
							flag18 = false
						end

						return
					end

					local n26 = math.clamp(tonumber(v45 and v45.skillSlots) or 4, 1, 4)

					while true do
						if flag11 and flag32 and v42 == n14 and flag16 and tbl10:allowsCurrent() then
							if flag17 or os.clock() < n15 or localPlayer:GetAttribute("IsUsingSkill") == true then
								task.wait(math.clamp(n15 - os.clock(), 0.05, 0.15))
								continue
							else
								local v47 = nil
								local v48 = nil
								local order = tbl7.order
								local n27 = #order
								local flag37 = false
								local n28 = nil

								for i = 0, n27 - 1 do
									n28 = ((tbl7.nextIndex or 1) + i - 1) % n27 + 1
									local v49 = order[n28]
									local num = tonumber(v49:match("%d+"))
									local v50 = v44[v49]
									local v51 = tbl7[v49]
									local slotUnlockLevels = v45 and v45.slotUnlockLevels and v45.slotUnlockLevels[num]
									local flag38 = num <= n26 and (not v45 or slotUnlockLevels ~= nil and (v46 == nil or v46 >= slotUnlockLevels))
									local str10

									if type(v51) ~= "table" then
										str10 = "Ready"
									else
										local expiresAt = (v51.phase == "Cooldown" or v51.phase == "Casting") and v51.expiresAt

										if expiresAt then
											local expiresAt2 = v51.expiresAt
											expiresAt = os.clock() >= expiresAt2
										end

										if expiresAt then
											tbl7[v49] = nil
											str10 = "Ready"
										else
											str10 = v51.phase or "Ready"
										end
									end

									local cooldownActive = v43.CooldownActive and v43.CooldownActive[v49]

									if type(cooldownActive) == "table" then
										if cooldownActive.phase == "Casting" then
											str10 = "Casting"
										else
											local flag39 = cooldownActive.phase == "Cooldown"

											if flag39 then
												flag39 = not cooldownActive.endTick

												if not flag39 then
													local endTick = cooldownActive.endTick
													flag39 = tick() < endTick
												end
											end

											if flag39 then
												str10 = "Cooldown"
											end
										end
									end

									if flag38 and type(v50) == "string" and v50 ~= "" then
										if str10 == "Casting" or str10 == "Cooldown" then
											flag37 = true
											n28 = nil
										else
											v47 = v49
											v48 = v50
										end

										break
									else
										n28 = nil
									end
								end

								if not v47 then
									if flag37 then
										task.wait(0.1)
										continue
									end
								else
									local minCastTime = FishingConfig.Skill and FishingConfig.Skill.MinCastTime or 0.5
									local v49 = nil

									pcall(function()
										v49 = Catalog.Skill.GetById(v48)
									end)

									local n29 = math.max(tonumber(v49 and v49.castTime) or minCastTime, minCastTime)
									local n30 = math.max(tonumber(v49 and v49.cooldown) or 0, 0)
									tbl7[v47] = { phase = "Casting", expiresAt = os.clock() + n29 + n30 + 0.15 }

									if not pcall(function()
										v43.Moveset:Fire(v47, v48)
									end) then
										tbl7[v47] = nil
										task.wait(0.1)
									else
										tbl7.nextIndex = n28 % n27 + 1
										n15 = math.max(n15, os.clock() + n29 + 0.08)
										task.wait(0.05)
									end

									continue
								end
							end
						end

						break
					end

					if v42 == n14 then
						flag18 = false
					end
				end)
			end

			local function fn86(arg, arg2)
				n14 += 1
				n22 += 1
				tbl7.nextIndex = 1
				n12 = tonumber(arg) or 0
				n13 = tonumber(arg2) or 0
				flag18 = false
				flag33 = false
				n15 = 0
				flag32 = true
				idling = FishingEnums.State.Reeling
			end

			local function fn87()
				local flag37 = flag33 or not tbl10:allowsCurrent()
				local flag38

				if flag37 then
					flag38 = flag37
				else
					flag38 = not (flag11 and flag13 and flag32)
				end

				if flag38 then
					return
				end
				flag33 = true
				local v42 = n22

				task.spawn(function()
					while true do
						if flag11 and flag13 and flag32 and v42 == n22 and tbl10:allowsCurrent() then
							local v43 = fn53()

							if v43 and v43 ~= FishingEnums.State.Reeling then
								flag32 = false
								break
							else
								if flag16 and fn84() then
									fn85()
									task.wait(0.01)
								else
									if flag16 then
										fn85()
									end

									if flag17 or os.clock() < n15 or localPlayer:GetAttribute("IsUsingSkill") == true then
										task.wait(0.01)
									else
										n21 = (n21 + 1) % 65536

										pcall(function()
											FishingPackets.FishReelPull:Fire(n21)
										end)

										task.wait(n8)
									end
								end

								continue
							end
						end

						break
					end

					if v42 == n22 then
						flag33 = false
					end
				end)
			end

			local function fn88()
				local zones = FishingConfig.PullBar and FishingConfig.PullBar.Zones or {}
				local n26 = 0

				for _, zone in ipairs(zones) do
					if zone.multiplier == 10 then
						return n26, zone.threshold
					end
					n26 = zone.threshold or n26
				end

				return 0.8769, 1
			end

			local function fn89(arg, arg2)
				local flag37 = flag34

				if not flag34 then
					flag37 = not (flag11 and flag12)
				end

				if flag37 or not tbl10:allowsCurrent() then
					return
				end
				flag34 = true
				n23 += 1
				local v42 = n23
				idling = FishingEnums.State.FirstPull

				task.spawn(function()
					local v43, v44 = fn88()
					local n26 = v43 + 0.025
					local oscillateSpeed = FishingConfig.FirstPull and FishingConfig.FirstPull.OscillateSpeed or 2.4
					local num = tonumber(arg2)
					local timeLimit = tonumber(arg) or FishingConfig.FirstPull and FishingConfig.FirstPull.TimeLimit or 2

					if num then
						timeLimit -= workspace:GetServerTimeNow() - num
					end

					local n27 = os.clock() + math.max(timeLimit - 0.1, 0.05)
					task.wait(0.05)
					local v45 = nil

					while flag11 and flag12 and v42 == n23 and tbl10:allowsCurrent() and os.clock() < n27 do
						local v46 = fn53()

						if v46 == FishingEnums.State.FirstPull then
							local pullBarValue = nil
							local flag38

							if num then
								local n28 = workspace:GetServerTimeNow() - num
								local n29 = math.max(n28, 0) * oscillateSpeed % 2
								pullBarValue = PullBarMath.Position(n28, oscillateSpeed)
								flag38 = n29 <= 1
							else
								pcall(function()
									pullBarValue = FishingController:GetPullBarValue()
								end)

								flag38 = type(pullBarValue) == "number" and v45 and pullBarValue > v45 + 0.001
							end

							if type(pullBarValue) == "number" then
								flag38 = flag38 and pullBarValue >= n26 and pullBarValue <= v44

								if flag38 then
									pcall(function()
										FishingPackets.FishFirstPull:Fire()
									end)

									return
								end

								v45 = pullBarValue
							end
						elseif v46 and v46 ~= FishingEnums.State.Waiting then
							return
						end

						task.wait(0.015)
					end

					local flag38 = flag11 and flag12 and v42 == n23 and tbl10:allowsCurrent()

					if flag38 then
						local firstPull = FishingEnums.State.FirstPull
						flag38 = fn53() == firstPull
					end

					if flag38 then
						pcall(function()
							FishingPackets.FishFirstPull:Fire()
						end)
					end
				end)
			end

			local function fn90()
				local currentCamera = workspace.CurrentCamera
				currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
				local tbl16 = {}
				local vector2 = Vector2.new(currentCamera.X * 0.5, currentCamera.Y * 0.92)
				local vector22 = Vector2.new(currentCamera.X * 0.15, currentCamera.Y * 0.82)
				local vector23 = Vector2.new
				local n26 = currentCamera.X * 0.85
				local n27 = currentCamera.Y * 0.82
				tbl16[1] = vector2
				tbl16[2] = vector22

				do
					local values = table.pack(vector23(n26, n27))
					table.move(values, 1, values.n, 3, tbl16)
				end

				for _, v42 in ipairs(tbl16) do
					local tbl17 = {}

					pcall(function()
						tbl17 = playerGui:GetGuiObjectsAtPosition(v42.X, v42.Y)
					end)

					local flag37 = false

					for _, v43 in ipairs(tbl17) do
						while true do
							if v43 and v43 ~= playerGui then
								if v43:GetAttribute("LootItemCard") == true then
									flag37 = true
									break
								else
									v43 = v43.Parent
									continue
								end
							end

							break
						end

						if flag37 then
							break
						end
					end

					if not flag37 then
						return v42
					end
				end

				return tbl16[1]
			end

			fn47 = function()
				local v42 = fn90()

				if pcall(function()
					VirtualInputManager:SendMouseButtonEvent(v42.X, v42.Y, 0, true, game, 0)
					task.wait(0.02)
					VirtualInputManager:SendMouseButtonEvent(v42.X, v42.Y, 0, false, game, 0)
				end) then
					return true
				end

				return pcall(function()
					local VirtualUser = game:GetService("VirtualUser")
					local currentCamera = workspace.CurrentCamera
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(v42, currentCamera and currentCamera.CFrame or CFrame.new())
					task.wait(0.02)
					VirtualUser:Button1Up(v42, currentCamera and currentCamera.CFrame or CFrame.new())
				end)
			end

			local function fn91()
				local flag37 = flag35

				if not flag35 then
					flag37 = not (flag11 and flag15)
				end

				if flag37 then
					return
				end
				flag35 = true
				local v42 = n24
				local confirmReadyDelay = FishingConfig.Loot and FishingConfig.Loot.ConfirmReadyDelay or 0.75

				task.spawn(function()
					task.wait(confirmReadyDelay + 0.08)
					local n26 = 0

					while true do
						local flag38 = flag11 and flag15 and v42 == n24

						if flag38 then
							local caught = FishingEnums.State.Caught
							flag38 = fn53() == caught
						end

						if flag38 and n26 < 12 then
							if not LootController then
								pcall(function()
									LootController = client.GetController("LootController")
								end)
							end

							local flag39 = false

							if LootController then
								pcall(function()
									flag39 = LootController:IsFishingLootActive()
								end)
							end

							if flag39 then
								n26 += 1
								fn47()
							end

							task.wait(0.15)
							continue
						end

						break
					end

					if v42 == n24 then
						flag35 = false
					end
				end)
			end

			fn48(FishingPackets.FishWaitingAck.OnClientEvent:Connect(function()
				if not flag11 then
					return
				end
				tbl10.currentFishId = nil
				idling = FishingEnums.State.Waiting
			end))

			fn48(FishingPackets.FishFirstPullStart.OnClientEvent:Connect(function(currentFishId, arg, arg2, arg3, arg4)
				tbl10.currentFishId = currentFishId
				if flag11 and tbl10:shouldSkip(currentFishId) then
					tbl10:skipCurrent()
					return
				end
				fn89(arg3, arg4)
			end))

			fn48(FishingPackets.FishReelStartAck.OnClientEvent:Connect(function(currentFishId, arg, arg2)
				if not flag11 then
					return
				end
				tbl10.currentFishId = currentFishId
				if not tbl10:allowsCurrent() then
					return
				end
				fn86(arg, arg2)

				if flag16 then
					fn85()
				end

				if not flag13 then
					return
				end
				fn87()
			end))

			fn48(FishingPackets.FishReelHPUpdate.OnClientEvent:Connect(function(arg)
				if not flag11 or not tbl10:allowsCurrent() then
					return
				end
				n12 = tonumber(arg) or n12

				if fn84() then
					if flag16 then
						fn85()
					end
				end
			end))

			fn48(FishingPackets.FishReelPhaseHP.OnClientEvent:Connect(function(arg, arg2)
				if not flag11 or not tbl10:allowsCurrent() then
					return
				end
				n14 += 1
				n12 = tonumber(arg) or 0
				n13 = tonumber(arg2) or 0
				flag18 = false
				n15 = 0

				if flag16 then
					fn85()
				end
			end))

			fn48(FishingPackets.FishQTEPrompt.OnClientEvent:Connect(function(arg, arg2)
				if not (flag11 and flag14) or not tbl10:allowsCurrent() then
					return
				end
				local v42 = fn63(arg)
				if not v42 then
					return
				end
				n10 += 1
				local v43 = n10
				local n26 = math.max(tonumber(arg2) or 0.5, 0.05)
				flag17 = true
				local n27 = math.max(n26 - 0.2, 0.02)

				task.delay(math.min(n9, n27), function()
					if not (flag11 and flag14 and flag17 and n10 == v43) or not tbl10:allowsCurrent() then
						return
					end
					local state = nil

					if not FishingController then
						pcall(function()
							FishingController = client.GetController("FishingController")
						end)
					end

					if FishingController then
						pcall(function()
							state = FishingController:GetState()
						end)
					end

					local flag37 = state ~= FishingEnums.State.Reeling

					if flag37 then
						flag37 = not (state == nil and flag32)
					end

					if flag37 then
						return
					end

					if n11 == v43 then
						return
					end
					n11 = v43

					if not pcall(function()
						FishingPackets.FishQTEResponse:Fire(v42)
					end) and n10 == v43 then
						n11 = 0
					end
				end)

				task.delay(n26, function()
					if n10 == v43 then
						flag17 = false
					end
				end)
			end))

			fn48(FishingPackets.FishQTEResult.OnClientEvent:Connect(function()
				n10 += 1
				flag17 = false
			end))

			fn48(FishingPackets.FishQTECancel.OnClientEvent:Connect(function()
				n10 += 1
				flag17 = false
			end))

			fn48(FishingPackets.FishCatchResult.OnClientEvent:Connect(function(arg, arg2, arg3)
				tbl10.skipPending = false
				tbl10.currentFishId = nil
				flag32 = false
				n22 += 1
				flag33 = false
				n23 += 1
				flag34 = false
				n24 += 1
				flag35 = false
				n10 += 1
				flag17 = false
				fn81()

				if arg then
					n19 += 1
					n20 += arg3 or 0

					if flag15 then
						fn91()
					end
				end

				idling = FishingEnums.State.Caught
				n25 = os.clock() + n7
			end))

			fn48(FishingPackets.FishReset.OnClientEvent:Connect(function()
				tbl10.skipPending = false
				tbl10.currentFishId = nil
				flag32 = false
				n22 += 1
				flag33 = false
				n23 += 1
				flag34 = false
				n24 += 1
				flag35 = false
				n10 += 1
				flag17 = false
				fn81()
				idling = FishingEnums.State.Idling
				n25 = os.clock() + n7
			end))

			fn48(FishingPackets.FishSkillWindow.OnClientEvent:Connect(function(arg)
				local n26 = math.max(tonumber(arg) or 0, 0)
				n15 = math.max(n15, os.clock() + n26)
			end))

			task.spawn(function()
				local state = 1
				local autoFishing, autoFishing2, autoFishing3, pending, v42, flag37, now5, character, humanoid, flag38, flag39, farmSpotPending, flag40, humanoidRootPart, flag41, humanoidRootPart2, v43, flag42, flag43, currentFishId, n26, n27, v44, v45, flag44, flag45, flag46, now6, max, num, n28

				while true do
					if state == 1 then
						autoFishing = FishingConfig.AutoFishing

						if autoFishing then
							state = 2
						else
							state = 3
						end
					elseif state == 2 then
						autoFishing = FishingConfig.AutoFishing.RetryRate
						state = 3
					elseif state == 3 then
						if autoFishing then
							state = 5
						else
							state = 4
						end
					elseif state == 4 then
						autoFishing = 1
						state = 5
					elseif state == 5 then
						autoFishing2 = FishingConfig.AutoFishing

						if autoFishing2 then
							state = 6
						else
							state = 7
						end
					elseif state == 6 then
						autoFishing2 = FishingConfig.AutoFishing.RecastDelay
						state = 7
					elseif state == 7 then
						if autoFishing2 then
							state = 9
						else
							state = 8
						end
					elseif state == 8 then
						autoFishing2 = 1
						state = 9
					elseif state == 9 then
						autoFishing3 = FishingConfig.AutoFishing

						if autoFishing3 then
							state = 10
						else
							state = 11
						end
					elseif state == 10 then
						autoFishing3 = FishingConfig.AutoFishing.StallTimeoutSec
						state = 11
					elseif state == 11 then
						if autoFishing3 then
							state = 13
						else
							state = 12
						end
					elseif state == 12 then
						autoFishing3 = 30
						state = 13
					elseif state == 13 then
						if flag11 then
							state = 15
						else
							state = 14
						end
					elseif state == 14 then
						return
					elseif state == 15 then
						pending = flag25

						if flag25 then
							state = 17
						else
							state = 16
						end
					elseif state == 16 then
						pending = flag31
						state = 17
					elseif state == 17 then
						if pending then
							state = 19
						else
							state = 18
						end
					elseif state == 18 then
						pending = flag26
						state = 19
					elseif state == 19 then
						if pending then
							state = 21
						else
							state = 20
						end
					elseif state == 20 then
						pending = tbl8.pending
						state = 21
					elseif state == 21 then
						if pending then
							state = 23
						else
							state = 22
						end
					elseif state == 22 then
						pending = genv.HuneHubBossWaiting
						state = 23
					elseif state == 23 then
						if pending then
							state = 29
						else
							state = 24
						end
					elseif state == 24 then
						v42 = flag21

						if flag21 then
							state = 25
						else
							state = 26
						end
					elseif state == 25 then
						v42 = flag22
						state = 26
					elseif state == 26 then
						if v42 then
							state = 28
						else
							state = 27
						end
					elseif state == 27 then
						flag37 = v42
						state = 30
					elseif state == 28 then
						flag37 = not tbl8.resumeFarm
						state = 30
					elseif state == 29 then
						flag37 = pending
						state = 30
					elseif state == 30 then
						if flag37 then
							state = 133
						else
							state = 31
						end
					elseif state == 31 then
						if not resumeSoldFish then
							state = 132
						else
							state = 32
						end
					elseif state == 32 then
						now5 = os.clock()
						character = localPlayer.Character

						if character then
							state = 34
						else
							state = 33
						end
					elseif state == 33 then
						humanoid = character
						state = 35
					elseif state == 34 then
						humanoid = character:FindFirstChildOfClass("Humanoid")
						state = 35
					elseif state == 35 then
						flag38 = not character

						if flag38 then
							state = 37
						else
							state = 36
						end
					elseif state == 36 then
						flag38 = not humanoid
						state = 37
					elseif state == 37 then
						if flag38 then
							state = 39
						else
							state = 38
						end
					elseif state == 38 then
						flag39 = humanoid.Health <= 0
						state = 40
					elseif state == 39 then
						flag39 = flag38
						state = 40
					elseif state == 40 then
						if flag39 then
							state = 131
						else
							state = 41
						end
					elseif state == 41 then
						if tbl8.resumeFarm then
							state = 110
						else
							state = 42
						end
					elseif state == 42 then
						farmSpotPending = tbl8.farmSpotPending

						if farmSpotPending then
							state = 44
						else
							state = 43
						end
					elseif state == 43 then
						flag40 = not cFrame2
						state = 45
					elseif state == 44 then
						flag40 = farmSpotPending
						state = 45
					elseif state == 45 then
						if flag40 then
							state = 46
						else
							state = 50
						end
					elseif state == 46 then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart then
							state = 47
						else
							state = 50
						end
					elseif state == 47 then
						cFrame2 = humanoidRootPart.CFrame

						if flag30 then
							state = 48
						else
							state = 49
						end
					elseif state == 48 then
						cFrame = cFrame2
						state = 49
					elseif state == 49 then
						tbl8.farmSpotPending = false
						state = 50
					elseif state == 50 then
						flag41 = flag30

						if flag30 then
							state = 51
						else
							state = 52
						end
					elseif state == 51 then
						flag41 = cFrame
						state = 52
					elseif state == 52 then
						if flag41 then
							state = 53
						else
							state = 54
						end
					elseif state == 53 then
						flag41 = not flag31
						state = 54
					elseif state == 54 then
						if flag41 then
							state = 55
						else
							state = 58
						end
					elseif state == 55 then
						humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 then
							state = 56
						else
							state = 57
						end
					elseif state == 56 then
						humanoidRootPart2 = (humanoidRootPart2.Position - cFrame.Position).Magnitude > 8
						state = 57
					elseif state == 57 then
						if humanoidRootPart2 then
							state = 107
						else
							state = 58
						end
					elseif state == 58 then
						v43 = fn53()

						if v43 == v38 then
							state = 63
						else
							state = 59
						end
					elseif state == 59 then
						local v46 = v38
						v38 = v43
						now4 = now5
						flag42 = v46 == FishingEnums.State.FirstPull

						if flag42 then
							state = 60
						else
							state = 61
						end
					elseif state == 60 then
						flag42 = v43 ~= FishingEnums.State.FirstPull
						state = 61
					elseif state == 61 then
						if flag42 then
							state = 62
						else
							state = 63
						end
					elseif state == 62 then
						n23 += 1
						flag34 = false
						state = 63
					elseif state == 63 then
						if v43 == FishingEnums.State.Idling then
							state = 94
						else
							state = 64
						end
					elseif state == 64 then
						flag43 = v43 == FishingEnums.State.Holding

						if flag43 then
							state = 66
						else
							state = 65
						end
					elseif state == 65 then
						flag43 = v43 == FishingEnums.State.Throwing
						state = 66
					elseif state == 66 then
						if flag43 then
							state = 93
						else
							state = 67
						end
					elseif state == 67 then
						if v43 == FishingEnums.State.Waiting then
							state = 91
						else
							state = 68
						end
					elseif state == 68 then
						if v43 == FishingEnums.State.FirstPull then
							state = 88
						else
							state = 69
						end
					elseif state == 69 then
						if v43 == FishingEnums.State.Reeling then
							state = 77
						else
							state = 70
						end
					elseif state == 70 then
						if v43 == FishingEnums.State.Caught then
							state = 74
						else
							state = 71
						end
					elseif state == 71 then
						if v43 == FishingEnums.State.Escaped then
							state = 72
						else
							state = 106
						end
					elseif state == 72 then
						idling = v43

						if flag32 then
							state = 73
						else
							state = 106
						end
					elseif state == 73 then
						flag32 = false
						n22 += 1
						flag33 = false
						state = 106
					elseif state == 74 then
						idling = v43

						if flag32 then
							state = 75
						else
							state = 76
						end
					elseif state == 75 then
						flag32 = false
						n22 += 1
						flag33 = false
						state = 76
					elseif state == 76 then
						fn91()
						state = 106
					elseif state == 77 then
						idling = v43
						currentFishId = tbl10.currentFishId
						n26 = 0
						n27 = 0

						if FishingController then
							state = 78
						else
							state = 79
						end
					elseif state == 78 then
						pcall(function()
							local fishInfo, v46, v47 = FishingController:GetFishInfo()
							currentFishId = fishInfo or currentFishId
							n26 = v46
							n27 = v47
						end)

						state = 79
					elseif state == 79 then
						if currentFishId then
							state = 80
						else
							state = 81
						end
					elseif state == 80 then
						tbl10.currentFishId = currentFishId
						state = 81
					elseif state == 81 then
						if tbl10.skipPending then
							state = 87
						else
							state = 82
						end
					elseif state == 82 then
						if not tbl10:allowsCurrent() then
							state = 86
						else
							state = 83
						end
					elseif state == 83 then
						if not flag32 then
							state = 84
						else
							state = 85
						end
					elseif state == 84 then
						fn86(n26, n27)
						state = 85
					elseif state == 85 then
						fn87()
						state = 106
					elseif state == 86 then
						task.wait(0.05)
						state = 13
					elseif state == 87 then
						tbl10:skipCurrent()
						task.wait(0.05)
						state = 13
					elseif state == 88 then
						idling = v43

						if tbl10.skipPending then
							state = 90
						else
							state = 89
						end
					elseif state == 89 then
						fn89()
						state = 106
					elseif state == 90 then
						tbl10:skipCurrent()
						state = 106
					elseif state == 91 then
						idling = v43

						if not (autoFishing3 <= now5 - now4) then
							state = 106
						else
							state = 92
						end
					elseif state == 92 then
						pcall(function()
							FishingPackets.FishCancel:Fire()
						end)

						now4 = now5
						n25 = now5 + autoFishing2
						state = 106
					elseif state == 93 then
						idling = v43
						state = 106
					elseif state == 94 then
						idling = FishingEnums.State.Idling

						if tbl10.skipPending then
							state = 95
						else
							state = 98
						end
					elseif state == 95 then
						if now5 - tbl10.skipAt >= 0.5 then
							state = 97
						else
							state = 96
						end
					elseif state == 96 then
						task.wait(0.05)
						state = 13
					elseif state == 97 then
						tbl10.skipPending = false
						tbl10.currentFishId = nil
						state = 98
					elseif state == 98 then
						if flag32 then
							state = 99
						else
							state = 100
						end
					elseif state == 99 then
						flag32 = false
						n22 += 1
						flag33 = false
						state = 100
					elseif state == 100 then
						if not (n25 <= now5) then
							state = 106
						else
							state = 101
						end
					elseif state == 101 then
						v44 = fn54()

						if v44 then
							state = 102
						else
							state = 103
						end
					elseif state == 102 then
						v44 = fn69()
						state = 103
					elseif state == 103 then
						if v44 then
							state = 104
						else
							state = 105
						end
					elseif state == 104 then
						idling = FishingEnums.State.Throwing
						state = 105
					elseif state == 105 then
						n25 = os.clock() + math.max(autoFishing, 0.25)
						state = 106
					elseif state == 106 then
						task.wait(0.05)
						state = 13
					elseif state == 107 then
						resumeSoldFish = false

						if not pcall(function()
							FarmToggle:Set(false)
						end) then
							state = 108
						else
							state = 109
						end
					elseif state == 108 then
						pcall(function()
							FarmToggle:SetValue(false)
						end)

						state = 109
					elseif state == 109 then
						lib:Notify({
							Title = text("Fishing Area Left"),
							Content = text("Auto Farm stopped because the character moved away from the saved position."),
							Duration = 4,
						})

						task.wait(0.1)
						state = 13
					elseif state == 110 then
						if not (tbl8.resumeAt <= now5) then
							state = 130
						else
							state = 111
						end
					elseif state == 111 then
						if tbl8.resumeStage == 0 then
							state = 129
						else
							state = 112
						end
					elseif state == 112 then
						v45 = fn53()
						flag44 = v45 ~= FishingEnums.State.Idling

						if flag44 then
							state = 113
						else
							state = 114
						end
					elseif state == 113 then
						flag44 = v45 ~= nil
						state = 114
					elseif state == 114 then
						if flag44 then
							state = 116
						else
							state = 115
						end
					elseif state == 115 then
						flag45 = flag44
						state = 117
					elseif state == 116 then
						flag45 = now5 - tbl8.resumeCancelAt >= 2
						state = 117
					elseif state == 117 then
						if flag45 then
							state = 128
						else
							state = 118
						end
					elseif state == 118 then
						flag46 = fn54(tbl8.rodId)

						if flag46 then
							state = 119
						else
							state = 120
						end
					elseif state == 119 then
						local idling2 = FishingEnums.State.Idling
						flag46 = fn53() == idling2
						state = 120
					elseif state == 120 then
						if flag46 then
							state = 122
						else
							state = 121
						end
					elseif state == 121 then
						tbl8.resumeAt = os.clock() + 0.5
						state = 130
					elseif state == 122 then
						if tbl8.resumeSoldFish then
							state = 123
						else
							state = 124
						end
					elseif state == 123 then
						flag22 = false
						tbl8.bagRefreshAfter = os.clock() + 3
						tbl8.resumeSoldFish = false
						state = 124
					elseif state == 124 then
						tbl8.resumeFarm = false
						tbl8.rodId = nil
						v38 = nil
						now6 = os.clock()
						max = math.max
						num = tonumber(n7)

						if num then
							state = 126
						else
							state = 125
						end
					elseif state == 125 then
						n28 = 0.35
						state = 127
					elseif state == 126 then
						n28 = num
						state = 127
					elseif state == 127 then
						n25 = now6 + max(n28, 0.3)
						state = 130
					elseif state == 128 then
						tbl8.resumeCancelAt = now5

						pcall(function()
							FishingPackets.FishCancel:Fire()
						end)

						pcall(function()
							humanoid:UnequipTools()
						end)

						tbl8.resumeAt = os.clock() + 0.35
						state = 130
					elseif state == 129 then
						pcall(function()
							humanoid:UnequipTools()
						end)

						tbl8.resumeStage = 1
						tbl8.resumeAt = os.clock() + 0.25
						v38 = nil
						state = 130
					elseif state == 130 then
						task.wait(0.1)
						state = 13
					elseif state == 131 then
						task.wait(0.2)
						state = 13
					elseif state == 132 then
						v38 = nil
						task.wait(0.1)
						state = 13
					elseif state == 133 then
						v38 = nil
						task.wait(0.1)
						state = 13
					end
				end
			end)

			task.spawn(function()
				while flag11 do
					task.wait(1)
					local flag37 = flag21

					if flag21 then
						local bagRefreshAfter = tbl8.bagRefreshAfter
						flag37 = os.clock() >= bagRefreshAfter
					end

					if flag37 then
						local v42 = fn77()

						if v42 ~= nil then
							flag22 = v42

							if not v42 then
								flag23 = false
							end
						end
					end

					if tbl8.pending then
						local flag38 = flag11 and not flag25 and not flag31

						if flag38 then
							local retryAt = tbl8.retryAt
							flag38 = os.clock() >= retryAt
						end

						if flag38 then
							flag25 = true
							flag31 = true

							task.spawn(function()
								local v42 = tbl8.tryRestore()
								flag31 = false
								flag25 = false

								if v42 then
									lib:Notify({
										Title = text("Fishing Position Restored"),
										Content = text("Returned to the saved spot. Auto Farm can resume."),
										Duration = 3,
									})
								end
							end)
						end
					else
						local flag38 = flag26 and v37 and not flag25 and not flag31

						if flag38 then
							local saleRetryAt = tbl8.saleRetryAt
							flag38 = os.clock() >= saleRetryAt
						end

						if flag38 then
							flag25 = true

							task.spawn(function()
								local ok, result, result2 = pcall(fn59, true)

								if not ok then
									result, result2 = tbl8.waitForSale("RequestFailed")
								end

								if result or result2 == SellEnums.Status.Empty then
									flag23 = true
								end

								flag25 = false
							end)
						elseif flag21 and flag22 and not flag23 and not flag24 and not flag25 and not flag31 and os.clock() >= n16 then
							flag25 = true

							task.spawn(function()
								local ok, result, result2 = pcall(fn59)

								if not ok then
									local flag39 = v37 and not tbl8.pending
									result = false
									result2 = "RequestFailed"

									if flag39 then
										result, result2 = tbl8.waitForSale("RequestFailed")
									end
								end

								if result or result2 == SellEnums.Status.Empty then
									flag23 = true

									if result2 == SellEnums.Status.Empty then
										lib:Notify({
											Title = text("Bag Full"),
											Content = text("All fish are locked; unlock fish to make room."),
											Duration = 4,
										})
									end
								else
									if not flag26 then
										fn60(result2)
									end

									local flag39 = not flag26

									if flag39 then
										flag39 = result2 == "NoSafeRoute" or result2 == "PositionCorrected" or result2 == "TweenInterrupted" or result2 == "TweenFailed" or result2 == "MerchantOutOfRange" or result2 == "ReturnPositionChanged"
									end

									if flag39 then
										flag24 = true
									else
										n16 = os.clock() + 10
									end
								end

								flag25 = false
							end)
						elseif flag20 and not flag24 and not flag25 and not flag31 then
							n18 += 1

							if n18 >= n17 then
								n18 = 0
								flag25 = true

								task.spawn(function()
									local ok, result, result2 = pcall(fn59)

									if not ok then
										local flag39 = v37 and not tbl8.pending
										local flag40 = false
										result2 = "RequestFailed"

										if flag39 then
											result, result2 = tbl8.waitForSale("RequestFailed")
										else
											result = flag40
										end
									end

									if result or result2 == SellEnums.Status.Empty then
										flag23 = true
									end

									if not result and result2 ~= SellEnums.Status.Empty and not flag26 then
										fn60(result2)

										if result2 == "NoSafeRoute" or result2 == "PositionCorrected" or result2 == "TweenInterrupted" or result2 == "TweenFailed" or result2 == "MerchantOutOfRange" or result2 == "ReturnPositionChanged" then
											flag24 = true
										end
									end

									flag25 = false
								end)
							end
						end
					end
				end
			end)

			task.spawn(function()
				while flag11 do
					task.wait(50)

					if flag28 then
						pcall(function()
							local VirtualUser = game:GetService("VirtualUser")
							VirtualUser:CaptureController()
							VirtualUser:ClickButton2(Vector2.new(0, 0))
						end)
					end
				end
			end)

			fn62 = function()
				if not flag11 then
					return
				end
				flag11 = false
				resumeSoldFish = false
				flag13 = false
				flag32 = false
				genv.HuneHubBossCastTarget = nil
				genv.HuneHubBossCastError = nil
				genv.HuneHubBossWaiting = nil
				genv.HuneHubBossValidateCast = nil
				fn49()

				for _, v42 in ipairs(tbl9) do
					pcall(function()
						v42:Disconnect()
					end)
				end

				table.clear(tbl9)
				local huneHubFishingMaster = genv.HuneHubFishingMaster

				if type(huneHubFishingMaster) == "table" and huneHubFishingMaster.Window then
					pcall(function()
						huneHubFishingMaster.Window:Destroy()
					end)
				end

				genv.HuneHubFishingMaster = nil
			end

			local str10 = "rbxthumb://type=Asset&id=121962960881141&w=150&h=150"

			local function fn92()
				local ok, result = pcall(function()
					return lib:CreateWindow({
						Title = text("Hune Hub | Fishing Master"),
						Icon = str10,
						Author = "@hune205",
						Folder = "Hune Hub",
						Size = UDim2.fromOffset(580, 460),
						MinSize = Vector2.new(560, 350),
						MaxSize = Vector2.new(850, 560),
						Transparent = true,
						Theme = "Dark",
						Resizable = true,
						SideBarWidth = 200,
						BackgroundImageTransparency = 0.42,
						HideSearchBar = true,
						ScrollBarEnabled = false,
						User = {
							Enabled = true,
							Anonymous = true,
							Callback = function()
								print("Hune Hub")
							end,
						},
					})
				end)

				if not ok or not result then
					fn62()

					for _, v42 in ipairs({ lib.ScreenGui, lib.NotificationGui, lib.DropdownGui, lib.TooltipGui }) do
						pcall(function()
							if v42 then
								v42:Destroy()
							end
						end)
					end

					error("Hune Hub UI could not open: " .. tostring(result), 0)
				end

				return result
			end

			v39 = fn92()
			v39:SetBackgroundImage("rbxthumb://type=Asset&id=121962960881141&w=150&h=150")
			v39:SetToggleKey(Enum.KeyCode.RightControl)
			configManager = v39.ConfigManager
			v39:Tag({ Title = text("2.0"), Icon = "code", Color = Color3.fromHex("#FFD84A"), Radius = 6 })

				-- Direct mode: skip the UI key checker; the game controls remain available.

			local color6 = Color3.fromHex

			v39:EditOpenButton({
				Title = text("Hune Hub"),
				Icon = str10,
				CornerRadius = UDim.new(0, 16),
				StrokeThickness = 2,
				Color = ColorSequence.new(Color3.fromHex("#7ED957"), color6("#F28C28")),
				OnlyMobile = false,
				Enabled = true,
				Draggable = true,
			})

			genv.HuneHubFishingMaster = { Window = v39, Unload = fn62 }
			MainSection = v39:Section({ Title = text("Main"), Icon = "house", Opened = true })
			MiscSection = v39:Section({ Title = text("Misc & Player"), Icon = "badge-alert", Opened = true })
			SettingsSection = v39:Section({ Title = text("Settings"), Icon = "settings", Opened = true })
			AboutTab = MainSection:Tab({ Title = text("Info"), Icon = "info", Locked = false })
			FarmTab = MainSection:Tab({ Title = text("Auto Farm"), Icon = "fish", Locked = false })
			SellTab = MainSection:Tab({ Title = text("Auto Sell"), Icon = "coins", Locked = false })
			TeleTab = MainSection:Tab({ Title = text("Island"), Icon = "map-pin", Locked = false })
			QuestTab = MainSection:Tab({ Title = text("Quest"), Icon = "scroll-text", Locked = false })
			BossTab = MainSection:Tab({ Title = text("Boss"), Icon = "swords", Locked = false })
			GachaTab = MainSection:Tab({ Title = text("Gacha"), Icon = "dices", Locked = false })
			ShopTab = MainSection:Tab({ Title = text("Shop"), Icon = "shopping-cart", Locked = false })
			RewardTab = MainSection:Tab({ Title = text("Rewards"), Icon = "gift", Locked = false })
			MiscTab = MiscSection:Tab({ Title = text("Local Player"), Icon = "user", Locked = false })
			SettingsTab = SettingsSection:Tab({ Title = text("Config"), Icon = "file-cog", Locked = false })
			LanguageTab = SettingsSection:Tab({ Title = text("Language"), Icon = "languages", Locked = false })

			local function fn93()
				local ok, result = pcall(function()
					local request_2 = syn and syn.request or http and http.request or request
					if not request_2 then
						return nil
					end

					local v42 = request_2({
						Url = "https://discord.com/api/v9/invites/fHdf4yXpVE?with_counts=true",
						Method = "GET",
						Timeout = 2,
					})

					if v42 and v42.StatusCode == 200 then
						return v42.Body
					end
					return nil
				end)

				if ok and result then
					local ok2, result2 = pcall(function()
						return HttpService2:JSONDecode(result)
					end)

					if ok2 and result2 then
						return {
							serverName = (result2.guild or {}).name or "Hune Hub",
							members = result2.approximate_member_count or "Unknown",
							online = result2.approximate_presence_count or "Unknown",
						}
					end
				end

				return { serverName = "Hune Hub", members = "Unknown", online = "Unknown" }
			end

			local v42 = fn93()
			AboutTab:Section({ Title = text("Information") })

			AboutTab:Paragraph({
				Title = text("Discord Community"),
				Desc = text("Server: ") .. tostring(v42.serverName) .. "\nOnline: " .. tostring(v42.online) .. "\nMembers: " .. tostring(v42.members),
				Image = "users",
				ImageSize = 22,
				Buttons = {
					{
						Title = text("Join Discord"),
						Icon = "external-link",
						Callback = function()
							local ok = pcall(function()
								if not setclipboard then
									error("Clipboard is unavailable")
								end

								setclipboard("https://discord.gg/fHdf4yXpVE")
							end)

							lib:Notify({
								Title = text("Hune Hub"),
								Content = ok and "Discord invite copied!" or "Clipboard is not supported by this executor.",
								Duration = 3,
							})
						end,
					},
				},
			})

			AboutTab:Paragraph({
				Title = text("Owner"),
				Desc = text("Discord: hune205"),
				Image = "crown",
				ImageSize = 24,
				Buttons = {
					{
						Title = text("Copy Owner ID"),
						Icon = "copy",
						Callback = function()
							pcall(function()
								if setclipboard then
									setclipboard("920035051033485353")
								end
							end)
						end,
					},
				},
			})

			FarmTab:Section({ Title = text("Main Features") })

			FarmToggle = FarmTab:Toggle({
				Title = text("Auto Farm"),
				Default = false,
				Flag = "AutoFarm",
				Callback = function(arg)
					resumeSoldFish = arg
					flag12 = arg
					flag13 = arg
					flag14 = arg
					flag15 = arg
					n23 += 1
					flag34 = false
					n24 += 1
					flag35 = false

					if arg then
						local v43 = fn52()
						tbl8.farmSpotPending = true

						if v43 and not flag31 and not flag25 and not flag26 and not tbl8.pending then
							cFrame2 = v43.CFrame

							if flag30 then
								cFrame = cFrame2
							end

							tbl8.farmSpotPending = false
						end

						fn54()
						n25 = 0
						v38 = nil
						idling = fn53() or FishingEnums.State.Idling

						if idling == FishingEnums.State.Caught then
							fn91()
						end

						lib:Notify({
							Title = text("Auto Farm Enabled"),
							Content = tbl8.farmSpotPending and "The fishing position will be saved when movement finishes." or "The current fishing position and facing direction were saved.",
							Duration = 3,
						})
					else
						tbl8.farmSpotPending = false
						tbl8.resumeFarm = false
						tbl8.resumeSoldFish = false
						tbl8.rodId = nil
						tbl10.skipPending = false
						flag32 = false
						n22 += 1
						flag33 = false
						n10 += 1
						flag17 = false
						idling = fn53() or FishingEnums.State.Idling

						lib:Notify({
							Title = text("Auto Farm Disabled"),
							Content = text("The complete fishing cycle has stopped."),
							Duration = 2,
						})
					end
				end,
			})

			FarmTab:Toggle({
				Title = text("Auto Skill + Low HP"),
				Default = false,
				Flag = "AutoSkill",
				Callback = function(arg)
					flag16 = arg

					if arg and flag32 then
						fn85()
					end
				end,
			})

			FarmTab:Input({
				Title = text("Skill Combo(Z,X,C,V)"),
				Desc = text("Enter Skills , Separated By Commas. Omit A Key To Skip It."),
				Default = tbl7.defaultOrder,
				Placeholder = "Z,C,X,V",
				Flag = "SkillComboOrder",
				Callback = function(arg)
					if tbl7.setOrder(arg) then
						tbl7.saveOrderSoon(arg)
					end
				end,
			})

			FarmTab:Section({ Title = text("Fish Rarity Filter") })

			FarmTab:Dropdown({
				Title = text("Target Rarities"),
				Values = RarityEnums.Order,
				Value = { "Legendary", "Mythical", "Divine" },
				Multi = true,
				AllowNone = true,
				Flag = "FarmTargetRarities",
				Callback = function(arg)
					tbl10:setSelected(tbl10.farmRarities, arg)
					local v43 = fn53()

					if v43 == FishingEnums.State.FirstPull or v43 == FishingEnums.State.Reeling then
						tbl10:allowsCurrent()
					end
				end,
			})

			FarmTab:Toggle({
				Title = text("Filter Fish by Rarity"),
				Default = false,
				Flag = "SkipUnselectedFish",
				Callback = function(farmEnabled)
					tbl10.farmEnabled = farmEnabled

					if farmEnabled then
						local v43 = fn53()

						if v43 == FishingEnums.State.FirstPull or v43 == FishingEnums.State.Reeling then
							tbl10:allowsCurrent()
						end
					else
						tbl10.skipPending = false
					end
				end,
			})

			FarmTab:Section({ Title = text("Speed Settings") })

			FarmTab:Slider({
				Title = text("Farm Delay (Seconds)"),
				Value = { Min = 0.1, Max = 2, Default = 0.35 },
				Step = 0.01,
				Flag = "FarmDelay",
				Callback = function(arg)
					n7 = arg
				end,
			})

			FarmTab:Section({ Title = text("Position Settings") })

			FarmTab:Toggle({
				Title = text("Stop Farm If Moved"),
				Default = false,
				Flag = "LockPosition",
				Callback = function(arg)
					flag30 = arg

					if arg then
						local v43 = fn52()

						if v43 then
							cFrame = v43.CFrame

							lib:Notify({
								Title = text("Fishing Area Saved"),
								Content = text("Auto Farm will stop if you move more than 8 studs away."),
								Duration = 3,
							})
						end
					else
						cFrame = nil
					end
				end,
			})

			FarmTab:Button({
				Title = text("Save Fishing Position"),
				Callback = function()
					if flag25 or flag31 or flag26 or tbl8.pending then
						lib:Notify({
							Title = text("Position Not Saved"),
							Content = text("Wait for the current movement to finish."),
							Duration = 3,
						})

						return
					end

					local v43 = fn52()

					if v43 then
						cFrame2 = v43.CFrame
						cFrame = cFrame2
						tbl8.farmSpotPending = false

						lib:Notify({
							Title = text("Position Saved"),
							Content = text("The current fishing position has been saved."),
							Duration = 2,
						})
					else
						lib:Notify({
							Title = text("Position Not Saved"),
							Content = text("Character position is not ready yet."),
							Duration = 3,
						})
					end
				end,
			})

			FarmTab:Button({
				Title = text("Return To Fishing Position"),
				Callback = function()
					if cFrame2 then
						if flag31 or flag25 or tbl8.pending or flag26 then
							return
						end

						task.spawn(function()
							flag31 = true
							fn58()
							local v43, v44 = fn57(cFrame2)
							flag31 = false

							lib:Notify({
								Title = v43 and "Position Reached" or "Safe Route Unavailable",
								Content = v43 and "Walked to the saved fishing position." or tostring(v44),
								Duration = 3,
							})
						end)
					else
						lib:Notify({
							Title = text("No Saved Position"),
							Content = text("Save a fishing position first."),
							Duration = 3,
						})
					end
				end,
			})

			SellTab:Section({ Title = text("Automatic Fish Selling") })

			SellTab:Dropdown({
				Title = text("Sell Travel Method"),
				Values = { "Tween", "Walk" },
				Default = "Tween",
				Multi = false,
				Flag = "SellTravelMethodV2",
				Callback = function(method)
					if method ~= "Walk" and method ~= "Tween" then
						return
					end
					tbl8.method = method
					flag24 = false
					n16 = 0

					if tbl8.pending then
						tbl8.attempts = 0
						tbl8.retryAt = 0
					end
				end,
			})

			SellTab:Slider({
				Title = text("Sell Tween Speed (Studs/Second)"),
				Value = { Min = 20, Max = 70, Default = 30 },
				Step = 1,
				Flag = "SellTweenSpeed",
				Callback = function(arg)
					local num = tonumber(arg)

					if num then
						tbl8.tweenSpeed = math.clamp(num, 20, 70)
					end
				end,
			})

			SellTab:Section({ Title = text("Auto Lock Fish by Rarity") })

			SellTab:Dropdown({
				Title = text("Rarities to Lock"),
				Values = RarityEnums.Order,
				Value = { "Legendary", "Mythical", "Divine" },
				Multi = true,
				AllowNone = true,
				Flag = "SellKeepRarities",
				Callback = function(arg)
					tbl10:setSelected(tbl10.sellRarities, arg)
					tbl10:queueLocks()
				end,
			})

			SellTab:Toggle({
				Title = text("Auto Lock Fish"),
				Default = false,
				Flag = "AutoLockProtectedFish",
				Callback = function(sellEnabled)
					tbl10.sellEnabled = sellEnabled
					tbl10:queueLocks()
				end,
			})

			SellTab:Toggle({
				Title = text("Auto Sell When Bag Full"),
				Default = false,
				Flag = "AutoSellWhenBagFull",
				Callback = function(arg)
					flag21 = arg
					flag24 = false
					flag22 = false
					flag23 = false
					n16 = 0

					if not arg and not flag20 and not flag25 and not tbl8.pending and not flag26 then
						flag26 = false
						v37 = nil
					end
				end,
			})

			SellTab:Toggle({
				Title = text("Auto Sell On Timer"),
				Default = false,
				Flag = "AutoSellOnTimer",
				Callback = function(arg)
					flag20 = arg
					flag24 = false
					n18 = 0

					if not arg and not flag21 and not flag25 and not tbl8.pending and not flag26 then
						flag26 = false
						v37 = nil
					end
				end,
			})

			SellTab:Slider({
				Title = text("Sell Interval (Seconds)"),
				Value = { Min = 15, Max = 300, Default = 60 },
				Step = 1,
				Flag = "SellInterval",
				Callback = function(arg)
					local num = tonumber(arg)

					if num then
						n17 = math.clamp(num, 15, 300)
					end
				end,
			})

			SellTab:Button({
				Title = text("Sell All Fish Now"),
				Callback = function()
					if flag25 then
						lib:Notify({
							Title = text("Sell In Progress"),
							Content = text("The current merchant sale is still running."),
							Duration = 3,
						})

						return
					end

					flag25 = true

					task.spawn(function()
						local ok, result, result2 = pcall(fn59, true)

						if not ok then
							local flag37 = v37 and not tbl8.pending
							result2 = "RequestFailed"
							result = false

							if flag37 then
								result, result2 = tbl8.waitForSale("RequestFailed")
							end
						end

						if result2 == "ReturnCompleted" then
							lib:Notify({
								Title = text("Fishing Position Restored"),
								Content = text("Returned to the saved fishing spot."),
								Duration = 3,
							})
						elseif not result and not flag26 then
							fn60(result2)
						end

						flag25 = false
					end)
				end,
			})

			local function fn94()
				TeleTab:Paragraph({
					Title = text("Island Travel Warning"),
					Desc = text("Using Island Travel May Get You Kicked From The Game. We Are Not Responsible For Any Resulting Kick."),
				})

				TeleTab:Section({ Title = text("Island Unlock") })
				local str11 = tbl5["Starter Island"] and "Starter Island" or tbl6[1]
				local flag37 = false

				local tbl16 = {
					[4] = "Bring 3 Legendary Fish From Desert Island",
					[5] = "Bring Frozen Crown Dragonfish, Frosttusk Seal, And Frostmaw Monster From Snow Island",
					[6] = "Bring Ancient Trihorn Fish (1,200 Kg), Stormblade Shark (2,000 Kg), And Lavascale Dragonfish (2,500 Kg) From Volcanic Island",
				}

				local function fn95()
					local v43

					pcall(function()
						v43 = PlayerDataV2Controller:Fetch(localPlayer)
					end)

					return v43
				end

				local function fn96(arg, arg2)
					local v43 = IslandConfig[arg.id]
					return arg.defaultUnlocked or v43 and v43.defaultUnlocked == true or arg2 and arg2.UnlockedIslands and arg2.UnlockedIslands[arg.id] == true
				end

				local function fn97()
					local v43 = tbl5[str11]
					if not v43 then
						return text("Select An Island.")
					end
					local v44 = fn95()
					if not v44 then
						return text("Player Data Is Not Ready.")
					end

					if fn96(v43, v44) then
						return v43.name .. text(" Is Unlocked.")
					end
					local tbl17 = IslandConfig[v43.id] or {}
					local v45 = fn55(tbl17.unlockCost or 0)
					local v46 = tbl16[v43.order]
					local str12 = "unlock_island_" .. v43.order
					local current = v44 and v44.Quest and v44.Quest.Current
					current = current and current.Id == str12 and text("Quest Active") or text("Quest Not Started")
					local str13 = text("Level ") .. tostring(tbl17.requiredLevel or 1) .. text("; Cost: ") .. v45 .. text(" Coins")

					if v46 then
						str13 ..= "; " .. text(v46)
					end

					return str13 .. text(". Status: ") .. current .. "."
				end

				local v43 = nil

				local function fn98()
					if v43 and v43.SetDesc then
						v43:SetDesc(fn97())
					end
				end

				TeleTab:Dropdown({
					Title = text("Select Island"),
					Values = tbl6,
					Default = str11,
					Multi = false,
					Flag = "SelectedIsland",
					Callback = function(arg)
						str11 = arg
						fn98()
					end,
				})

				v43 = TeleTab:Paragraph({ Title = text("Unlock Requirements"), Desc = fn97() })

				TeleTab:Button({
					Title = text("Start Island Unlock Quest"),
					Callback = function()
						if flag37 then
							return
						end
						local v44 = tbl5[str11]
						if not v44 then
							return
						end
						local v45 = fn95()
						if not v45 then
							lib:Notify({ Title = text("Island Unlock"), Content = text("Player Data Is Not Ready."), Duration = 3 })
							return
						end

						if fn96(v44, v45) then
							lib:Notify({
								Title = text("Island Unlocked"),
								Content = v44.name .. text(" Is Already Unlocked."),
								Duration = 3,
							})

							return
						end

						local v46 = tbl5[tbl6[v44.order - 1]]

						if v46 and not fn96(v46, v45) then
							local name = v46.name

							lib:Notify({
								Title = text("Previous Island Locked"),
								Content = text("Unlock ") .. name .. text(" First."),
								Duration = 4,
							})

							return
						end

						local str12 = "unlock_island_" .. v44.order
						local current = v45.Quest and v45.Quest.Current

						if current and current.Id == str12 then
							lib:Notify({
								Title = text("Quest Active"),
								Content = v44.name .. text(" Unlock Quest Is Already Active."),
								Duration = 3,
							})

							return
						end

						if current and current.Id and current.Id ~= "" then
							local id = current.Id

							lib:Notify({
								Title = text("Another Quest Active"),
								Content = text("Complete Or Cancel ") .. id .. text(" First."),
								Duration = 4,
							})

							return
						end

						flag37 = true

						task.spawn(function()
							local ok, result, result2 = pcall(function()
								return client.GetController("QuestController"):Accept(str12)
							end)

							flag37 = false
							fn98()
							local v47 = lib
							local notify2 = v47.Notify
							local tbl17 = { Title = ok and result and "Unlock Quest Started" or "Unlock Quest Failed" }

							if ok then
								ok = result and "Collect The Requirements For " .. v44.name .. "."

								if not ok then
									ok = tostring(result2 or "Requirements Not Met.")
								end
							end

							tbl17.Content = ok or "Quest Controller Is Not Ready."
							tbl17.Duration = 4
							notify2(v47, tbl17)
						end)
					end,
				})

				TeleTab:Button({
					Title = text("Unlock Selected Island"),
					Callback = function()
						if flag37 then
							return
						end
						local v44 = tbl5[str11]
						if not v44 then
							return
						end
						local v45 = fn95()
						if not v45 then
							lib:Notify({ Title = text("Island Unlock"), Content = text("Player Data Is Not Ready."), Duration = 3 })
							return
						end

						if fn96(v44, v45) then
							lib:Notify({
								Title = text("Island Unlocked"),
								Content = v44.name .. text(" Is Already Unlocked."),
								Duration = 3,
							})

							return
						end

						local str12 = "unlock_island_" .. v44.order
						local current = v45.Quest and v45.Quest.Current

						if not current or current.Id ~= str12 then
							local name = v44.name

							lib:Notify({
								Title = text("Quest Required"),
								Content = text("Start The ") .. name .. text(" Unlock Quest First."),
								Duration = 4,
							})

							return
						end

						flag37 = true

						task.spawn(function()
							local ok, result, result2 = pcall(function()
								return client.GetController("QuestController"):Complete(str12)
							end)

							flag37 = false
							fn98()
							local v46 = lib
							local notify2 = v46.Notify
							local tbl17 = { Title = ok and result and "Island Unlocked" or "Unlock Requirements Missing" }

							if ok then
								ok = result and v44.name .. " Is Now Unlocked."

								if not ok then
									ok = tostring(result2 or "Check The Quest Requirements.")
								end
							end

							tbl17.Content = ok or "Quest Controller Is Not Ready."
							tbl17.Duration = 4
							notify2(v46, tbl17)
						end)
					end,
				})

				TeleTab:Button({ Title = text("Refresh Unlock Status"), Callback = fn98 })
				TeleTab:Section({ Title = text("Island Travel") })

				TeleTab:Slider({
					Title = text("Travel Speed (Studs/s)"),
					Value = { Min = 20, Max = 300, Default = 70 },
					Step = 5,
					Flag = "IslandTravelSpeed",
					Callback = function(arg)
						local num = tonumber(arg)

						if num then
							genv.HuneHubTravelSpeed = math.clamp(num, 20, 300)
						end
					end,
				})

				local n26 = 0

				TeleTab:Button({
					Title = text("Travel To Island"),
					Callback = function()
						if flag31 then
							lib:Notify({
								Title = text("Movement Busy"),
								Content = text("Wait for the current travel action to finish."),
								Duration = 3,
							})

							return
						end

						n26 += 1
						local v44 = n26
						local v45 = str11

						task.spawn(function()
							local v46 = v45

							lib:Notify({
								Title = text("Island Travel"),
								Content = text("Tweening to ") .. v46 .. text(" at ") .. tostring(genv.HuneHubTravelSpeed) .. text(" studs per second."),
								Duration = 3,
							})

							local v47, v48 = fn80(v45, function()
								return flag11 and n26 == v44
							end)

							if v47 then
								local str12 = v45 .. "."
								lib:Notify({ Title = text("Travel Complete"), Content = text("Arrived at ") .. str12, Duration = 3 })
							elseif v48 == "Cancelled" then
								lib:Notify({ Title = text("Travel Stopped"), Content = text("Island tween was cancelled."), Duration = 3 })
							elseif v48 == "DestinationNotLoaded" then
								lib:Notify({
									Title = text("Destination Not Loaded"),
									Content = text("The destination island has no loaded landing point yet."),
									Duration = 4,
								})
							elseif v48 == "MovementBusy" then
								lib:Notify({
									Title = text("Movement Busy"),
									Content = text("Wait for the current travel action to finish."),
									Duration = 3,
								})
							elseif v48 == "AlreadyAtDestination" then
								lib:Notify({
									Title = text("Already At Destination"),
									Content = text("You are already on the selected island."),
									Duration = 3,
								})
							elseif v48 == "ArrivalUnconfirmed" then
								lib:Notify({
									Title = text("Travel Failed"),
									Content = text("The island did not confirm arrival."),
									Duration = 4,
								})
							else
								lib:Notify({ Title = text("Travel Stopped"), Content = tostring(v48), Duration = 4 })
							end
						end)
					end,
				})

				TeleTab:Button({
					Title = text("Stop Island Travel"),
					Callback = function()
						n26 += 1
					end,
				})
			end

			fn94()

			local function fn95()
				local QuestConfig = require(data.Config.QuestConfig)
				local RegionConfig = require(data.Config.RegionConfig)
				local BossSpawnerFX = require(ReplicatedStorage.Shared.Lib.BossSpawnerFX)
				local getItemCount = require(ReplicatedStorage.Shared.getItemCount)
				local tbl16 = { text("Auto Detect Quest") }
				local tbl17 = {}

				for k, v43 in pairs(QuestConfig.Data) do
					local str11 = (v43.name or k) .. " [" .. k .. "]"
					tbl17[str11] = k
					table.insert(tbl16, str11)
				end

				table.sort(tbl16)
				local v43 = nil
				local flag37 = false
				local flag38 = false
				local flag39 = true
				local flag40 = false
				local str11 = ""
				local n26 = -math.huge
				local v44 = nil
				local n27 = -math.huge
				local v45 = nil
				local id = nil

				local tbl18 = {
					unlock_island_4 = "island_desert",
					unlock_island_5 = "island_snow",
					unlock_island_6 = "island_volcano",
					white_tiger = "island_desert",
					phoenix = "island_snow",
					azure_dragon = "island_volcano",
					supreme_king = "island_fossil",
					bamboo_rod = "island_jungle",
					heaven_piercer_turtle_rod = "island_fossil",
					zen_staff_rod = "island_fossil",
					dread_fish_rod = "island_fossil",
				}

				local function fn96(arg, arg2)
					if not arg2 then
						return false
					end
					local flag41 = IslandConfig[arg2.id]
					flag41 = flag41 and flag41.defaultUnlocked == true
					local flag42

					if flag41 then
						flag42 = flag41
					else
						flag42 = arg.UnlockedIslands and arg.UnlockedIslands[arg2.id] == true
					end

					return flag42
				end

				local tbl19 = {
					unlock_island_2 = "island_jungle",
					unlock_island_3 = "island_desert",
					unlock_island_4 = "island_snow",
					unlock_island_5 = "island_volcano",
					unlock_island_6 = "island_fossil",
				}

				local function fn97(arg)
					local tbl20 = {}

					for k, v46 in pairs(QuestConfig.Data) do
						local visibleWhenIslandUnlocked = v46.visibleWhenIslandUnlocked
						local v47 = tbl19[k]

						if not ((arg.Quest or {}).Done or {})[k] and (not visibleWhenIslandUnlocked or fn96(arg, Catalog.Island.GetById(visibleWhenIslandUnlocked))) and (not v47 or not fn96(arg, Catalog.Island.GetById(v47))) then
							table.insert(tbl20, { id = k, info = v46 })
						end
					end

					table.sort(tbl20, function(arg2, arg3)
						local tbl21 = { unlock_islands = 1, rods = 2, souls = 3, skills = 4 }
						local n28 = tbl21[arg2.info.questType] or 5
						local n29 = tbl21[arg3.info.questType] or 5
						if n28 ~= n29 then
							return n28 < n29
						end
						local sortOrder = arg2.info.sortOrder or 100
						local sortOrder2 = arg3.info.sortOrder or 100
						return sortOrder == sortOrder2 and arg2.id < arg3.id or sortOrder < sortOrder2
					end)

					return tbl20[1] and tbl20[1].id
				end

				local function fn98()
					if resumeSoldFish then
						return false
					end

					if not pcall(function()
						FarmToggle:Set(true)
					end) or not resumeSoldFish then
						pcall(function()
							FarmToggle:SetValue(true)
						end)
					end

					return resumeSoldFish
				end

				local function fn99()
					if not flag40 then
						return
					end

					if flag38 then
						return
					end
					flag40 = false

					if not pcall(function()
						FarmToggle:Set(false)
					end) or resumeSoldFish then
						pcall(function()
							FarmToggle:SetValue(false)
						end)
					end
				end

				local function fn100(arg, arg2)
					local n28 = ((arg.Inventory or {}).Books or {})[arg2] or 0
					local v46 = pairs
					local rods = arg.Rods or {}

					for _, rod in v46(rods) do
						local v47 = pairs
						local bookSlots = rod.BookSlots or {}

						for _, bookSlot in v47(bookSlots) do
							if bookSlot == arg2 then
								n28 -= 1
							end
						end
					end

					return math.max(0, n28)
				end

				local function fn101(arg, arg2)
					local fishes = Catalog.Island.GetById(arg2)
					local v46 = pairs
					fishes = fishes and fishes.fishes or {}

					for _, fishe in v46(fishes) do
						if fishe.fishId == arg then
							return true
						end
					end

					return false
				end

				local tbl20 = {
					unlock_island_4 = { "island_desert", "Legendary" },
					heaven_piercer_turtle_rod = { "island_fossil", "Legendary" },
					dread_fish_rod = { "island_fossil", "Mythical" },
					phoenix = { "island_snow", "Legendary" },
					azure_dragon = { "island_volcano", "Legendary" },
					white_tiger = { "island_desert", "Legendary", 1000 },
				}

				local function fn102(arg, arg2)
					local progress = arg2.Progress or {}
					local fishes = (arg.Inventory or {}).Fishes or {}
					local flag41 = type(progress.RequiredCoin) == "number"

					if flag41 then
						flag41 = (arg.Coin or 0) < progress.RequiredCoin
					end

					if flag41 then
						return false
					end

					for _, v46 in ipairs({
						{ "RequiredFished", "CurrentFished" },
						{ "RequiredKills", "CurrentKills" },
						{ "CatchWithSkill", "CurrentUsedSkill" },
					}) do
						local v47 = progress[v46[1]]
						local flag42 = type(v47) == "number"

						if flag42 then
							flag42 = (progress[v46[2]] or 0) < v47
						end

						if flag42 then
							return false
						end
					end

					local flag42 = type(progress.RequiredBamboo) == "number"

					if flag42 then
						local requiredBamboo = progress.RequiredBamboo
						flag42 = getItemCount(arg, "bamboo_fragment") < requiredBamboo
					end

					if flag42 then
						return false
					end

					if type(progress.RequiredFishes) == "table" then
						for k, requiredFishe in pairs(progress.RequiredFishes) do
							local n28 = 0

							for _, fishe in pairs(fishes) do
								local flag43 = arg2.Id == "unlock_island_6"

								if flag43 then
									local n29 = k == "ancient_trihorn_fish" and 1200

									if n29 then
										flag43 = n29
									else
										flag43 = k == "stormblade_shark" and 2000
									end

									flag43 = flag43 or k == "lavascale_dragonfish" and 2500 or 0
								end

								flag43 = flag43 or 0
								local flag44 = fishe.fishId == k

								if flag44 then
									flag44 = (fishe.weight or 0) >= flag43
								end

								if flag44 then
									n28 += 1
								end
							end

							if n28 < requiredFishe then
								return false
							end
						end
					end

					if type(progress.RequiredBooks) == "table" then
						for k, requiredBook in pairs(progress.RequiredBooks) do
							if fn100(arg, k) < requiredBook then
								return false
							end
						end
					end

					local requiredBookId = progress.RequiredBookId

					if requiredBookId then
						requiredBookId = fn100(arg, progress.RequiredBookId) < (progress.RequiredBookCount or 1)
					end

					if requiredBookId then
						return false
					end
					local v46 = tbl20[arg2.Id]

					if type(progress.RequiredFish) == "number" then
						local n28

						if v46 then
							if arg2.Id == "white_tiger" then
								local v47 = pairs
								local currentFish = progress.CurrentFish or {}
								n28 = 0

								for _, v48 in v47(currentFish) do
									local v49 = fishes[v48]
									local flag43 = v49 and Catalog.Fish.GetById(v49.fishId)
									flag43 = flag43 and flag43.rarity == v46[2]

									if flag43 then
										flag43 = (v49.weight or 0) >= (v46[3] or 0)
									end

									if flag43 and fn101(v49.fishId, v46[1]) then
										n28 += 1
									end
								end
							else
								n28 = 0

								for _, fishe in pairs(fishes) do
									local v47 = Catalog.Fish.GetById(fishe.fishId)

									if v47 and v47.rarity == v46[2] and fn101(fishe.fishId, v46[1]) then
										n28 += 1
									end
								end
							end
						else
							if type(progress.CurrentFish) ~= "number" then
								return false
							end
							n28 = progress.CurrentFish
						end

						if n28 < progress.RequiredFish then
							return false
						end
					end

					return true
				end

				local function fn103(arg, arg2)
					local progress = arg2.Progress or {}
					local fishes = (arg.Inventory or {}).Fishes or {}

					for _, v46 in ipairs({
						{ "RequiredFished", "CurrentFished" },
						{ "RequiredKills", "CurrentKills" },
						{ "CatchWithSkill", "CurrentUsedSkill" },
					}) do
						local v47 = progress[v46[1]]
						local flag41 = type(v47) == "number"

						if flag41 then
							flag41 = (progress[v46[2]] or 0) < v47
						end

						if flag41 then
							return true
						end
					end

					local flag41 = type(progress.RequiredBamboo) == "number"

					if flag41 then
						local requiredBamboo = progress.RequiredBamboo
						flag41 = getItemCount(arg, "bamboo_fragment") < requiredBamboo
					end

					if flag41 then
						return true
					end

					if type(progress.RequiredFishes) == "table" then
						for k, requiredFishe in pairs(progress.RequiredFishes) do
							local n28 = 0

							for _, fishe in pairs(fishes) do
								local flag42 = arg2.Id == "unlock_island_6"

								if flag42 then
									flag42 = k == "ancient_trihorn_fish" and 1200 or k == "stormblade_shark" and 2000 or k == "lavascale_dragonfish" and 2500 or 0
								end

								flag42 = flag42 or 0
								local flag43 = fishe.fishId == k

								if flag43 then
									flag43 = (fishe.weight or 0) >= flag42
								end

								if flag43 then
									n28 += 1
								end
							end

							if n28 < requiredFishe then
								return true
							end
						end
					end

					if type(progress.RequiredFish) == "number" then
						local v46 = tbl20[arg2.Id]
						local n28

						if v46 then
							local currentFish = arg2.Id == "white_tiger" and (progress.CurrentFish or {}) or fishes
							n28 = 0

							for _, v47 in pairs(currentFish) do
								local flag42 = arg2.Id == "white_tiger" and fishes[v47] or v47
								local flag43 = flag42 and Catalog.Fish.GetById(flag42.fishId)
								flag43 = flag43 and flag43.rarity == v46[2]

								if flag43 then
									flag43 = (flag42.weight or 0) >= (v46[3] or 0)
								end

								if flag43 and fn101(flag42.fishId, v46[1]) then
									n28 += 1
								end
							end
						else
							n28 = 0

							if type(progress.CurrentFish) == "number" then
								n28 = progress.CurrentFish
							end
						end

						if n28 < progress.RequiredFish then
							return true
						end
					end

					return false
				end

				QuestTab:Section({ Title = text("Auto Quest") })

				QuestTab:Dropdown({
					Title = text("Select Quest"),
					Values = tbl16,
					Default = text("Auto Detect Quest"),
					Flag = "AutoQuestSelection",
					Callback = function(arg)
						v43 = tbl17[arg]
						v44 = nil
						n26 = -math.huge
						n27 = -math.huge
						v45 = nil
						str11 = ""
						fn99()
					end,
				})

				local v46 = QuestTab:Toggle({
					Title = text("Auto Quest"),
					Default = false,
					Flag = "AutoQuest",
					Callback = function(arg)
						flag37 = arg
						v44 = nil
						n26 = -math.huge
						n27 = -math.huge
						str11 = ""

						if not arg then
							fn99()
						end
					end,
				})

				QuestTab:Toggle({
					Title = text("Travel To Quest Island"),
					Default = true,
					Flag = "QuestAutoTravel",
					Callback = function(arg)
						flag39 = arg
					end,
				})

				task.spawn(function()
					while flag11 do
						task.wait(2)

						if flag37 and not flag31 and not flag25 and not tbl8.pending and not flag26 then
							local ok, result = pcall(function()
								return PlayerDataV2Controller:Fetch(localPlayer)
							end)

							if ok and type(result) == "table" then
								local quest = result.Quest or {}
								local current = quest.Current
								local id2 = v43 or current and current.Id or fn97(result)
								local v47 = id2 and QuestConfig.Data[id2]

								if not v47 then
									fn99()

									if str11 ~= "no_quest" then
										str11 = "no_quest"

										lib:Notify({
											Title = text("Auto Quest"),
											Content = text("Start A Quest In Game Or Select One In This Tab."),
											Duration = 4,
										})
									end
								elseif not current and quest.Done and quest.Done[id2] and not v47.repeatable then
									fn99()
									flag37 = false

									pcall(function()
										v46:Set(false)
									end)

									lib:Notify({ Title = text("Auto Quest Complete"), Content = v47.name or id2, Duration = 4 })
								elseif current and v43 and current.Id ~= v43 then
									fn99()

									if id ~= current.Id then
										id = current.Id

										lib:Notify({
											Title = text("Another Quest Active"),
											Content = text("Finish Or Cancel ") .. tostring(current.Id) .. " First.",
											Duration = 4,
										})
									end
								elseif not current and os.clock() - n26 >= 10 then
									fn99()
									n26 = os.clock()

									local ok2, result2 = pcall(function()
										return client.GetController("QuestController"):Accept(id2)
									end)

									if ok2 and result2 then
										lib:Notify({ Title = text("Quest Started"), Content = v47.name or id2, Duration = 3 })
									else
										n26 = os.clock() + 50

										if not ok2 then
											warn("[Hune Hub] Quest accept failed: " .. tostring(result2))
										end
									end
								elseif current then
									local v48 = fn102(result, current)
									local v49 = fn103(result, current)
									local v50 = tbl18[id2]
									local flag41 = v49 and v50 and fn61() ~= v50

									if v49 and not flag38 then
										if flag41 and flag39 then
											fn99()
											local v51 = Catalog.Island.GetById(v50)

											if v51 and v45 ~= v50 and os.clock() - n27 >= 30 then
												n27 = os.clock()

												task.spawn(function()
													local v52, v53 = fn80(v51.name, function()
														return flag11 and flag37
													end)

													local flag42 = not v52 and flag37

													if flag42 then
														flag42 = v53 == "DestinationNotLoaded" or v53 == "ArrivalUnconfirmed" or v53 == "PositionCorrected" or v53 == "TweenInterrupted" or v53 == "TweenFailed"
													end

													if flag42 then
														v45 = v50
														local name = v51.name

														lib:Notify({
															Title = text("Auto Quest"),
															Content = text("Tween to ") .. name .. text(" failed: ") .. tostring(v53) .. ".",
															Duration = 5,
														})
													end
												end)
											end

											if str11 ~= "travel_" .. v50 then
												str11 = "travel_" .. v50

												lib:Notify({
													Title = text("Auto Quest"),
													Content = v51 and "Tweening To " .. v51.name or "Quest Island Not Found.",
													Duration = 4,
												})
											end
										elseif not flag41 then
											if fn98() then
												flag40 = true
											end

											if str11 ~= "fish_" .. id2 then
												str11 = "fish_" .. id2

												lib:Notify({
													Title = text("Auto Quest"),
													Content = text("Fishing For ") .. (v47.name or id2),
													Duration = 4,
												})
											end
										else
											fn99()
										end
									else
										fn99()
										local str12 = v48 and "claim"

										if not str12 then
											str12 = false

											if flag38 then
												str12 = "boss_priority"
											end

											str12 = str12 or "materials"
										end

										if str11 ~= str12 then
											str11 = str12
											local v51 = lib
											local notify2 = v51.Notify
											local tbl21 = { Title = text("Auto Quest") }
											local content = v48 and "Requirements Ready; Claiming Quest."

											if not content then
												content = false

												if flag38 then
													content = "Auto Boss Has Priority."
												end

												content = content or "Waiting For Coins, Books, Or Other Materials."
											end

											tbl21.Content = content
											tbl21.Duration = 4
											notify2(v51, tbl21)
										end
									end

									if v48 and os.clock() - n26 >= 30 then
										local v51, v52, v53 = pairs((result.Inventory or {}).Fishes or {})
										local n28 = 0

										for k in v51, v52, v53 do
											n28 += 1
										end

										local str12 = ""

										pcall(function()
											str12 = HttpService2:JSONEncode(current.Progress or {})
										end)

										local str13 = id2 .. ":" .. str12 .. ":" .. n28 .. ":" .. tostring((result.Coin or 0) >= ((current.Progress or {}).RequiredCoin or 0))

										if str13 ~= v44 then
											v44 = str13
											n26 = os.clock()

											local ok2, result2 = pcall(function()
												return client.GetController("QuestController"):Complete(id2)
											end)

											if ok2 and result2 then
												fn99()

												lib:Notify({
													Title = text("Quest Completed"),
													Content = v47.name or id2,
													Duration = 4,
												})
											elseif not ok2 then
												warn("[Hune Hub] Quest completion failed: " .. tostring(result2))
											end
										end
									end
								end
							end
						end
					end
				end)

				local module = nil
				local n28 = 3

				pcall(function()
					local lib2 = ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("Lib")
					lib2 = lib2 and lib2:FindFirstChild("LocalMovementLock")

					if lib2 then
						module = require(lib2)
					end
				end)

				pcall(function()
					local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig")

					if worldConfig then
						local module2 = require(worldConfig)

						if module2 and type(module2.SEA_LEVEL) == "number" then
							n28 = module2.SEA_LEVEL
						end
					end
				end)

				local flag41 = false
				local flag42 = false

				local function fn104(arg, arg2, arg3)
					arg = arg or localPlayer.Character
					arg2 = arg2 or arg and arg:FindFirstChildOfClass("Humanoid")
					arg3 = arg3 or arg and arg:FindFirstChild("HumanoidRootPart")
					if not arg2 or not arg3 then
						return
					end
					arg3.AssemblyLinearVelocity = Vector3.zero
					arg3.AssemblyAngularVelocity = Vector3.zero
					arg2.PlatformStand = false
					arg2.Sit = false
					arg2.AutoRotate = true

					if module and type(module.SetLocked) == "function" then
						pcall(function()
							module.SetLocked("BossSmartFly", false)
						end)
					end

					task.defer(function()
						if not arg2 or not arg2.Parent or not arg3.Parent or arg2.Health <= 0 then
							return
						end
						arg3.AssemblyLinearVelocity = Vector3.zero

						pcall(function()
							arg2:ChangeState(Enum.HumanoidStateType.GettingUp)
						end)

						task.wait(0.06)

						pcall(function()
							arg2:ChangeState(Enum.HumanoidStateType.Landed)
						end)

						task.wait(0.06)

						pcall(function()
							arg2:ChangeState(Enum.HumanoidStateType.Running)
						end)
					end)
				end

				local function fn105(arg, arg2, arg3)
					if flag41 then
						return false, "AlreadyTweening"
					end
					local TweenService = game:GetService("TweenService")
					local RunService = game:GetService("RunService")
					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
						return false, "CharacterNotReady"
					end

					if typeof(arg) == "Vector3" then
						arg = CFrame.new(arg)
					end

					if typeof(arg) ~= "CFrame" then
						return false, "InvalidTarget"
					end

					if arg2 and not arg2() then
						return false, "Cancelled"
					end
					local position = arg.Position
					local position2 = humanoidRootPart.Position
					local magnitude = (position - position2).Magnitude
					flag41 = true
					flag42 = false

					pcall(function()
						localPlayer:RequestStreamAroundAsync(position, 3)
					end)

					if module and type(module.SetLocked) == "function" then
						pcall(function()
							module.SetLocked("BossSmartFly", true)
						end)
					end

					local autoRotate = humanoid.AutoRotate
					local platformStand = humanoid.PlatformStand
					local tbl21 = {}
					humanoid.Sit = false
					humanoid.AutoRotate = false
					humanoid.PlatformStand = true

					local connection = RunService.PreSimulation:Connect(function()
						if not flag41 or not humanoidRootPart.Parent then
							return
						end
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
					end)

					local connection2 = RunService.Stepped:Connect(function()
						if not flag41 or not character.Parent then
							return
						end

						for _, descendant in ipairs(character:GetDescendants()) do
							if descendant:IsA("BasePart") then
								if tbl21[descendant] == nil then
									tbl21[descendant] = descendant.CanCollide
								end

								descendant.CanCollide = false
							end
						end
					end)

					local n29 = math.clamp(tonumber(arg3) or tonumber(genv.HuneHubTravelSpeed) or 70, 20, 140)
					local n30 = math.clamp(math.ceil(magnitude / (n29 >= 100 and 150 or 130)), 1, 150)
					local flag43 = magnitude > 120
					local n31 = n28 + 20
					local tbl22 = {}
					local n32 = magnitude > 5 and n30 or 0

					for i = 1, n32 do
						local n33 = i / n30
						local v47 = position2:Lerp(position, n33)
						local n34

						if flag43 then
							local n35 = math.sin(n33 * 3.1415926535897931) * 28
							n34 = math.max(position2.Y, position.Y, n31) + n35
						else
							n34 = math.max(v47.Y, n31)
						end

						local rotation

						if i == n30 then
							rotation = arg.Rotation
						else
							local vector = Vector3.new(position.X - v47.X, 0, position.Z - v47.Z)

							if vector.Magnitude > 0.1 then
								rotation = CFrame.lookAt(Vector3.zero, vector).Rotation
							else
								rotation = humanoidRootPart.CFrame.Rotation
							end
						end

						tbl22[i] = CFrame.new(v47.X, n34, v47.Z) * rotation
					end

					table.insert(tbl22, arg)

					local function fn106()
						connection:Disconnect()
						connection2:Disconnect()

						for k, v47 in pairs(tbl21) do
							if k.Parent then
								k.CanCollide = v47
							end
						end

						fn104(character, humanoid, humanoidRootPart)
						humanoid.PlatformStand = platformStand
						humanoid.AutoRotate = autoRotate
						flag41 = false
					end

					local flag44 = true
					local str12 = "Cancelled"

					local ok, result = pcall(function()
						for i, v47 in ipairs(tbl22) do
							if flag42 or not flag41 or not humanoidRootPart.Parent or humanoid.Health <= 0 or arg2 and not arg2() then
								flag44 = false
								str12 = flag42 and "ManualStop" or "ConditionFailed"
								break
							else
								local flag45 = i == #tbl22
								local magnitude2 = (humanoidRootPart.Position - v47.Position).Magnitude
								local linear = Enum.EasingStyle.Linear
								flag45 = flag45 and magnitude2 > 15
								local n33 = n29

								if flag45 then
									n33 = math.min(n29, 20)
								end

								local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(math.max(magnitude2 / n33, 0.01), linear, Enum.EasingDirection.Out), { CFrame = v47 })
								tween:Play()

								while tween.PlaybackState == Enum.PlaybackState.Playing do
									if flag42 or not flag11 or not humanoidRootPart.Parent or humanoid.Health <= 0 or arg2 and not arg2() then
										tween:Cancel()
										break
									else
										task.wait(0.05)
									end
								end

								local playbackState = tween.PlaybackState
								tween:Destroy()

								if playbackState ~= Enum.PlaybackState.Completed then
									flag44 = false
									str12 = "TweenInterrupted"
									break
								end
							end
						end
					end)

					fn106()
					if not ok then
						return false, "Error: " .. tostring(result)
					end

					if not flag44 then
						return false, str12
					end
					task.wait(0.25)
					local flag45 = humanoidRootPart.Parent and (humanoidRootPart.Position - position).Magnitude <= 4
					return flag45, flag45 and "Success" or "ArrivalUnconfirmed"
				end

				local n29 = -math.huge
				local str12 = ""
				local n30 = 0
				local v47 = nil
				local v48 = nil
				local v49 = nil
				local n31 = 0
				local v50 = nil
				local id2 = nil
				local tbl21

				tbl21 = {
					observations = {},
					probes = {},
					lastStream = {},
					generation = 0,
					espRecords = {},
					regionWatchers = {},
					notifiedEffects = {},
					notifyEnabled = false,
					espEnabled = false,
					lastManualScanAt = -math.huge,
					observe = function()
						local now5 = os.clock()

						for _, v51 in ipairs(CollectionService:GetTagged(RegionConfig.BossTag)) do
							if v51:IsA("BasePart") and v51:IsDescendantOf(workspace) then
								local attribute = v51:GetAttribute(RegionConfig.BossAttribute)
								local flag43 = type(attribute) == "string" and Catalog.BossRegion.GetById(attribute)
								local v52 = flag43 and BossSpawnerFX.GetForRegion(v51)

								if v52 then
									if BossSpawnerFX.IsActive(v52) then
										tbl21.observations[attribute] = {
											id = attribute,
											islandId = flag43.fallbackIslandId,
											position = v51.Position,
											region = v51,
											seenAt = now5,
										}
									else
										tbl21.observations[attribute] = nil
									end
								end
							end
						end
					end,
					probe = function(arg)
						local v51 = fn79(arg)
						if v51 then
							tbl21.probes[arg] = v51.Position
							return v51.Position
						end

						for _, v52 in ipairs(CollectionService:GetTagged(RegionConfig.IslandTag)) do
							if v52:IsA("BasePart") and v52:GetAttribute(RegionConfig.IslandAttribute) == arg then
								tbl21.probes[arg] = v52.Position
								return v52.Position
							end
						end

						local world = workspace:FindFirstChild("World")
						world = world and world:FindFirstChild("Islands")
						local v52 = world and world:FindFirstChild(arg)

						if v52 and v52:IsA("Model") and v52:FindFirstChildWhichIsA("BasePart", true) then
							tbl21.probes[arg] = v52:GetPivot().Position
						end

						return tbl21.probes[arg]
					end,
					resolve = function(arg)
						local region = arg.region
						local v51 = region and region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region)
						if v51 and BossSpawnerFX.IsActive(v51) then
							return region
						end
						local now5 = os.clock()
						if now5 - (tbl21.lastStream[arg.id] or -math.huge) < 8 then
							return nil
						end
						tbl21.lastStream[arg.id] = now5

						pcall(function()
							localPlayer:RequestStreamAroundAsync(arg.position, 2)
						end)

						tbl21.observe()
						local region2 = tbl21.observations[arg.id]
						region2 = region2 and region2.region
						local v52 = region2 and region2:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region2)
						return v52 and BossSpawnerFX.IsActive(v52) and region2 or nil
					end,
				}

				local function fn106()
					tbl21.observe()
					local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
					local huge = math.huge
					local v51 = nil

					for k, observation in pairs(tbl21.observations) do
						local region = observation.region
						local v52 = region and region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region)

						if not v52 or not BossSpawnerFX.IsActive(v52) then
							tbl21.observations[k] = nil
						else
							local magnitude = humanoidRootPart and (humanoidRootPart.Position - observation.position).Magnitude or 0

							if magnitude < huge then
								huge = magnitude
								v51 = observation
							end
						end
					end

					return v51
				end

				local v51 = nil
				local now5 = nil
				local lastSignal = "Not detected"
				local str13 = "None"
				local str14 = "None"
				local action = "Boss radar is waiting for a spawn signal."
				local now6 = nil

				tbl21.clearEsp = function(arg)
					local v52 = tbl21.espRecords[arg]
					if not v52 then
						return
					end
					tbl21.espRecords[arg] = nil

					if v52.attributeConnection then
						v52.attributeConnection:Disconnect()
					end

					if v52.ancestryConnection then
						v52.ancestryConnection:Disconnect()
					end

					if v52.gui then
						v52.gui:Destroy()
					end
				end

				tbl21.deactivate = function(arg)
					if not tbl21.observations[arg] and not tbl21.notifiedEffects[arg] and not tbl21.espRecords[arg] then
						return
					end
					tbl21.observations[arg] = nil
					tbl21.notifiedEffects[arg] = nil
					tbl21.clearEsp(arg)

					if v50 and v50.id == arg then
						v50 = nil
					end

					now6 = os.time()
					action = "Boss marker cleared. Waiting for a spawn signal."
				end

				tbl21.distanceText = function(arg, arg2, arg3)
					local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
					humanoidRootPart = humanoidRootPart and math.floor((humanoidRootPart.Position - arg.Position).Magnitude + 0.5)
					return text("BOSS: ") .. arg2 .. "\n" .. arg3 .. " | " .. (humanoidRootPart and humanoidRootPart .. text(" studs") or text("Distance unavailable")), humanoidRootPart
				end

				tbl21.startDistanceLoop = function()
					if tbl21.distanceLoopRunning then
						return
					end
					tbl21.distanceLoopRunning = true

					task.spawn(function()
						while flag11 and tbl21.espEnabled and next(tbl21.espRecords) do
							for k, espRecord in pairs(tbl21.espRecords) do
								if espRecord.effect:IsDescendantOf(workspace) and BossSpawnerFX.IsActive(espRecord.effect) and espRecord.label.Parent then
									local v52 = tbl21.distanceText(espRecord.effect, espRecord.bossName, espRecord.islandName)

									if espRecord.label.Text ~= v52 then
										espRecord.label.Text = v52
									end
								else
									tbl21.deactivate(k)
								end
							end

							task.wait(1)
						end

						tbl21.distanceLoopRunning = false
					end)
				end

				tbl21.showEsp = function(arg)
					if not tbl21.espEnabled then
						return
					end
					local region = arg.region
					local v52 = region and region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region)
					if not v52 or not BossSpawnerFX.IsActive(v52) then
						return
					end
					local v53 = tbl21.espRecords[arg.id]
					if v53 and v53.effect == v52 and v53.gui.Parent then
						return
					end
					tbl21.clearEsp(arg.id)
					local name = Catalog.BossRegion.GetById(arg.id)
					local v54 = name and Catalog.Island.GetById(name.fallbackIslandId)
					name = name and name.name or arg.id
					local name2 = v54 and v54.name or "Unknown Island"
					local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")
					if not playerGui2 then
						return
					end
					local billboardGui = Instance.new("BillboardGui")
					billboardGui.Name = "HuneHubBossESP"
					billboardGui.Adornee = v52
					billboardGui.AlwaysOnTop = true
					billboardGui.MaxDistance = 15000
					billboardGui.Size = UDim2.fromOffset(260, 70)
					billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 7, 0)
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = "BossLocation"
					textLabel.Size = UDim2.fromScale(1, 1)
					textLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					textLabel.BackgroundTransparency = 0.25
					textLabel.TextColor3 = Color3.fromRGB(255, 95, 95)
					textLabel.TextStrokeTransparency = 0.35
					textLabel.TextScaled = true
					textLabel.TextWrapped = true
					textLabel.Font = Enum.Font.GothamBold
					textLabel.Text = tbl21.distanceText(v52, name, name2)
					textLabel.Parent = billboardGui
					billboardGui.Parent = playerGui2
					local tbl22 = { effect = v52, gui = billboardGui, label = textLabel, bossName = name, islandName = name2 }
					tbl21.espRecords[arg.id] = tbl22

					tbl22.attributeConnection = v52:GetAttributeChangedSignal(BossSpawnerFX.ActiveAttribute):Connect(function()
						if not BossSpawnerFX.IsActive(v52) then
							tbl21.deactivate(arg.id)
						end
					end)

					tbl22.ancestryConnection = v52.AncestryChanged:Connect(function()
						if not v52:IsDescendantOf(workspace) then
							tbl21.deactivate(arg.id)
						end
					end)

					tbl21.startDistanceLoop()
				end

				tbl21.announce = function(arg, arg2)
					if not tbl21.notifyEnabled or tbl21.notifiedEffects[arg.id] == arg2 then
						return
					end
					tbl21.notifiedEffects[arg.id] = arg2
					local name = Catalog.BossRegion.GetById(arg.id)
					local name2 = name and Catalog.Island.GetById(name.fallbackIslandId)
					name = name and name.name or arg.id
					name2 = name2 and name2.name or "Unknown Island"
					local v52, v53 = tbl21.distanceText(arg2, name, name2)
					now5 = os.time()
					str13 = name
					str14 = name2
					now6 = nil
					action = "Boss location detected. Auto Boss is temporarily disabled."

					lib:Notify({
						Title = text("Boss Spotted: ") .. name,
						Content = string.format("%s | %s | X: %.0f, Z: %.0f", name2, v53 and v53 .. text(" studs away") or text("Distance unavailable"), arg2.Position.X, arg2.Position.Z),
						Duration = 6,
					})
				end

				tbl21.refreshEsp = function()
					tbl21.observe()

					for k in pairs(tbl21.notifiedEffects) do
						if not tbl21.observations[k] then
							tbl21.deactivate(k)
						end
					end

					for k in pairs(tbl21.espRecords) do
						if not tbl21.observations[k] then
							tbl21.deactivate(k)
						end
					end

					for k, observation in pairs(tbl21.observations) do
						local region = observation.region and observation.region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(observation.region)

						if region and BossSpawnerFX.IsActive(region) then
							tbl21.announce(observation, region)
							tbl21.showEsp(observation)
						else
							tbl21.deactivate(k)
						end
					end

					v50 = fn106()
				end

				tbl21.groundContext = function(arg)
					local v52 = Catalog.BossRegion.GetById(arg:GetAttribute(RegionConfig.BossAttribute))
					local num = tonumber(v52 and Catalog.Island.GetWaterY(v52.fallbackIslandId)) or n28
					local filterDescendantsInstances = {}
					local v53 = ipairs
					local Players2 = game:GetService("Players")

					for _, player in v53(Players2:GetPlayers()) do
						if player.Character then
							table.insert(filterDescendantsInstances, player.Character)
						end
					end

					local tbl22 = {}

					for _, v54 in ipairs(CollectionService:GetTagged(RegionConfig.IslandTag)) do
						table.insert(filterDescendantsInstances, v54)
						local isBasePart = v54:IsA("BasePart") and v52

						if isBasePart then
							local fallbackIslandId = v52.fallbackIslandId
							isBasePart = v54:GetAttribute(RegionConfig.IslandAttribute) == fallbackIslandId
						end

						if isBasePart then
							table.insert(tbl22, v54)
						end
					end

					for _, v54 in ipairs(CollectionService:GetTagged(RegionConfig.BossTag)) do
						table.insert(filterDescendantsInstances, v54)
					end

					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = filterDescendantsInstances
					raycastParams.RespectCanCollide = true
					raycastParams.IgnoreWater = false
					local raycastParams2 = RaycastParams.new()
					raycastParams2.FilterType = Enum.RaycastFilterType.Include
					local world = workspace:FindFirstChild("World")
					world = world and world:FindFirstChild("Islands")
					raycastParams2.FilterDescendantsInstances = world and { world } or {}
					local character = localPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					local v54 = fn52()
					local n32 = humanoid and v54 and humanoid.HipHeight + v54.Size.Y * 0.5 or 3
					local n33

					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
						local leftLeg = character:FindFirstChild("Left Leg")
						n33 = n32 + (leftLeg and leftLeg.Size.Y or 2)
					else
						n33 = n32
					end

					local cast = FishingConfig.Cast

					return {
						rays = raycastParams,
						mapRays = raycastParams2,
						waterY = num,
						lift = math.max(n33, 2),
						minCast = tonumber(cast.BaitMinDist) or 30,
						maxCast = math.min(tonumber(cast.BaitMaxDist) or 60, (tonumber(cast.ServerMaxDistance) or 80) - 2),
						zones = tbl22,
					}
				end

				tbl21.targetValid = function(arg, arg2, arg3)
					if not arg.Parent then
						return false
					end
					local v52 = arg.CFrame:PointToObjectSpace(arg2)
					local n32 = arg.Size * 0.5
					local n33 = n32.X - 0.1
					local flag43 = math.abs(v52.X) > n33
					local flag44

					if flag43 then
						flag44 = flag43
					else
						local y = n32.Y
						flag44 = math.abs(v52.Y) > y
					end

					if not flag44 then
						local n34 = n32.Z - 0.1
						flag44 = math.abs(v52.Z) > n34
					end

					if flag44 then
						return false
					end
					return workspace:Raycast(arg2 + Vector3.new(0, 100, 0), Vector3.new(0, -100, 0), arg3.mapRays) == nil
				end

				tbl21.dryGround = function(arg, arg2)
					return arg and arg.Normal.Y >= 0.75 and arg.Material ~= Enum.Material.Water and arg.Position.Y > arg2.waterY + 0.25 and (arg.Instance:IsA("Terrain") or arg.Instance:IsA("BasePart") and arg.Instance.CanCollide and arg.Instance.Anchored)
				end

				tbl21.supportAt = function(arg, arg2)
					local rays = arg2.rays
					local hit = workspace:Raycast(arg + Vector3.new(0, 1, 0), Vector3.new(0, -(arg2.lift + 2), 0), rays)
					if not tbl21.dryGround(hit, arg2) then
						return false
					end
					return math.abs(arg.Y - hit.Position.Y - arg2.lift) <= 1.25
				end

				tbl21.readyToFish = function(arg, arg2, arg3)
					local v52 = fn52()
					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
					local parent = arg and arg.Parent and BossSpawnerFX.GetForRegion(arg)
					if not v52 or not humanoid or humanoid.Health <= 0 or not parent or not BossSpawnerFX.IsActive(parent) or not arg2 or not arg3 or (v52.Position - arg2.Position).Magnitude > 4 or humanoid:GetState() == Enum.HumanoidStateType.Swimming or math.abs(v52.AssemblyLinearVelocity.Y) > 3 then
						return false
					end
					local v53 = tbl21.groundContext(arg)
					local magnitude = (v52.Position - arg3).Magnitude
					return magnitude >= v53.minCast - 1 and magnitude <= v53.maxCast and tbl21.supportAt(v52.Position, v53) and tbl21.targetValid(arg, arg3, v53)
				end

				local function fn107(arg)
					local v52 = fn52()
					if not v52 then
						return nil, nil
					end
					local v53 = tbl21.groundContext(arg)
					local n32 = arg.Size * 0.5
					local tbl22 = {}

					local function fn108(arg2, arg3)
						local v54 = arg.CFrame:PointToWorldSpace(Vector3.new(arg2, 0, arg3))
						local vector = Vector3.new(v54.X, v53.waterY, v54.Z)

						if tbl21.targetValid(arg, vector, v53) then
							table.insert(tbl22, vector)
						end
					end

					local v54 = BossSpawnerFX.GetForRegion(arg)

					if v54 then
						local v55 = arg.CFrame:PointToObjectSpace(v54.Position)
						local clamp = math.clamp
						local z = v55.Z
						local n33 = -n32.Z + 1
						local n34 = n32.Z - 1
						fn108(math.clamp(v55.X, -n32.X + 1, n32.X - 1), clamp(z, n33, n34))
					end

					local n33 = math.max(n32.X - 2, 0)
					local n34 = math.max(n32.Z - 2, 0)
					local n35 = math.clamp(math.ceil(arg.Size.X / 20), 2, 32)
					local n36 = math.clamp(math.ceil(arg.Size.Z / 20), 2, 32)

					for i = 0, n35 do
						local n37 = -n33 + 2 * n33 * i / n35
						fn108(n37, -n34)
						fn108(n37, n34)
					end

					for i = 1, n36 - 1 do
						local n37 = -n34 + 2 * n34 * i / n36
						fn108(-n33, n37)
						fn108(n33, n37)
					end

					for i = -1, 1 do
						for i2 = -1, 1 do
							fn108(i * n32.X * 0.5, i2 * n32.Z * 0.5)
						end
					end

					local tbl23 = { v53.minCast + 2, (v53.minCast + v53.maxCast) * 0.5, v53.maxCast - 2 }
					local huge = math.huge
					local cframe = nil
					local v55 = nil

					for i, v56 in ipairs(tbl22) do
						if not flag11 or not flag38 or not arg.Parent then
							return nil, nil
						end

						for _, v57 in ipairs(tbl23) do
							for i2 = 0, 15 do
								local n37 = i2 * 3.1415926535897931 / 8
								local rays = v53.rays
								local hit = workspace:Raycast(v56 + Vector3.new(math.cos(n37) * v57, 120, math.sin(n37) * v57), Vector3.new(0, -124, 0), rays)

								if tbl21.dryGround(hit, v53) then
									local n38 = hit.Position + Vector3.new(0, v53.lift + 0.1, 0)
									local magnitude = (n38 - v56).Magnitude
									local flag43 = magnitude >= v53.minCast and magnitude <= v53.maxCast

									if flag43 then
										for _, v58 in ipairs({
											Vector3.new(1.2, 0, 0),
											Vector3.new(-1.2, 0, 0),
											Vector3.new(0, 0, 1.2),
											Vector3.new(0, 0, -1.2),
										}) do
											if not tbl21.supportAt(n38 + v58, v53) then
												flag43 = false
												break
											end
										end
									end

									if flag43 and #v53.zones > 0 then
										flag43 = false

										for _, zone in ipairs(v53.zones) do
											local v58 = zone.CFrame:PointToObjectSpace(n38)
											local n39 = zone.Size * 0.5
											local x = n39.X
											local flag44 = math.abs(v58.X) <= x

											if flag44 then
												local y = n39.Y
												flag44 = math.abs(v58.Y) <= y
											end

											local flag45

											if flag44 then
												local z = n39.Z
												flag45 = math.abs(v58.Z) <= z
											else
												flag45 = flag44
											end

											if flag45 then
												flag43 = true
												break
											end
										end
									end

									if flag43 and workspace:Raycast(hit.Position + Vector3.new(0, 0.3, 0), Vector3.new(0, 120, 0), v53.rays) == nil then
										local n39 = (v52.Position - n38).Magnitude + math.abs(magnitude - tbl23[2]) * 2

										if n39 < huge then
											cframe = CFrame.lookAt(n38, Vector3.new(v56.X, n38.Y, v56.Z))
											huge = n39
											v55 = v56
										end
									end
								end
							end
						end

						if i % 4 == 0 then
							task.wait()
						end
					end

					return cframe, v55
				end

				local function fn108(arg)
					if not arg then
						return "None"
					end
					local n32 = math.max(0, os.time() - arg)
					local v52 = os.date("%H:%M:%S", arg)
					if n32 < 60 then
						return string.format("%s (%ds ago)", v52, n32)
					end

					if n32 < 3600 then
						return string.format("%s (%dm ago)", v52, math.floor(n32 / 60))
					end
					local floor2 = math.floor
					return string.format("%s (%dh %dm ago)", v52, math.floor(n32 / 3600), floor2(n32 % 3600 / 60))
				end

				local function fn109()
					if not v51 or not v51.SetDesc then
						return
					end

					pcall(function()
						local v52 = v50
						local tbl22 = { "Mode: Boss Radar + ESP" }

						if v52 then
							local v53 = Catalog.BossRegion.GetById(v52.id)
							local v54 = v53 and Catalog.Island.GetById(v53.fallbackIslandId)
							str13 = v53 and v53.name or v52.id
							str14 = v54 and v54.name or "Unknown"
							table.insert(tbl22, "Status: Active boss region")
							table.insert(tbl22, "Location: " .. str13 .. " | Island: " .. str14)
							table.insert(tbl22, "Source: BossSpawnerFX Active")
							table.insert(tbl22, "Detected: " .. fn108(now5))
						else
							table.insert(tbl22, "Status: Waiting for a boss spawn signal")
							table.insert(tbl22, "Last signal: " .. lastSignal)

							if now5 then
								table.insert(tbl22, "Last boss: " .. str13 .. " (" .. str14 .. ")")
								table.insert(tbl22, "Detected: " .. fn108(now5))

								if now6 then
									table.insert(tbl22, "Last seen: " .. fn108(now6))
								end
							end
						end

						table.insert(tbl22, "Action: " .. action)
						v51:SetDesc(table.concat(tbl22, "\n"))
					end)
				end

				local function fn110(arg, arg2)
					if not flag38 or str12 == arg then
						return
					end
					str12 = arg
					lib:Notify({ Title = text("Auto Boss"), Content = arg2, Duration = 4 })
				end

				local fn111 = nil

				fn111 = function(arg)
					local flag43 = not flag11

					if not flag43 then
						flag43 = not (tbl21.notifyEnabled or tbl21.espEnabled)
					end

					if flag43 then
						return
					end
					lastSignal = arg or "Server Broadcast"
					if tbl21.signalScanRunning then
						tbl21.rescanRequested = true
						return
					end
					tbl21.signalScanRunning = true
					local generation = tbl21.generation
					local flag44 = arg == "Server Broadcast: BossSpawnSound"

					task.spawn(function()
						pcall(function()
							v50 = fn106()

							if (flag44 or not v50) and workspace.StreamingEnabled then
								for _, v52 in ipairs(Catalog.Island.GetAll()) do
									local flag45 = not flag11 or generation ~= tbl21.generation

									if not flag45 then
										flag45 = not (tbl21.notifyEnabled or tbl21.espEnabled)
									end

									if not flag45 then
										local ok, result = pcall(tbl21.probe, v52.id)

										if ok and result then
											pcall(function()
												localPlayer:RequestStreamAroundAsync(result, 2)
											end)

											tbl21.refreshEsp()
											if not (v50 and not flag44) then
												task.wait(0.15)
												continue
											end
										else
											task.wait(0.15)
											continue
										end
									end

									break
								end
							end

							if flag11 and generation == tbl21.generation and (tbl21.notifyEnabled or tbl21.espEnabled) then
								tbl21.refreshEsp()

								if not v50 then
									action = "Waiting for a boss spawn signal."
								end

								fn109()
							end
						end)

						if generation ~= tbl21.generation then
							v50 = nil
						end

						tbl21.signalScanRunning = false

						if tbl21.rescanRequested then
							tbl21.rescanRequested = false

							if flag11 and (tbl21.notifyEnabled or tbl21.espEnabled) and not v50 then
								task.delay(1, function()
									fn111("Boss Spawn Follow-Up")
								end)
							end
						elseif arg == "Server Broadcast: BossSpawnSound" and not v50 then
							task.delay(2, function()
								if flag11 and generation == tbl21.generation and (tbl21.notifyEnabled or tbl21.espEnabled) then
									tbl21.refreshEsp()
									fn109()
								end
							end)
						end
					end)
				end

				tbl21.watchRegion = function(arg)
					if not arg:IsA("BasePart") or tbl21.regionWatchers[arg] then
						return
					end
					local tbl22 = {}
					tbl21.regionWatchers[arg] = tbl22

					tbl22.attach = function(effect)
						if not effect or not effect:IsA("BasePart") or tbl22.effect == effect then
							return
						end

						if tbl22.attributeConnection then
							tbl22.attributeConnection:Disconnect()
						end

						tbl22.effect = effect

						tbl22.attributeConnection = effect:GetAttributeChangedSignal(BossSpawnerFX.ActiveAttribute):Connect(function()
							if not flag11 then
								return
							end

							if BossSpawnerFX.IsActive(effect) then
								fn111("Boss Effect Activated")
							else
								local attribute = arg:GetAttribute(RegionConfig.BossAttribute)

								if type(attribute) == "string" then
									tbl21.deactivate(attribute)
								end

								tbl21.refreshEsp()
								fn109()
							end
						end)

						if BossSpawnerFX.IsActive(effect) then
							fn111("Loaded Active Boss")
						end
					end

					tbl22.childConnection = arg.ChildAdded:Connect(function(child)
						if child.Name == BossSpawnerFX.RootName then
							tbl22.attach(child)
						end
					end)

					tbl22.destroyConnection = arg.Destroying:Connect(function()
						if tbl22.attributeConnection then
							tbl22.attributeConnection:Disconnect()
						end

						if tbl22.childConnection then
							tbl22.childConnection:Disconnect()
						end

						if tbl22.destroyConnection then
							tbl22.destroyConnection:Disconnect()
						end

						tbl21.regionWatchers[arg] = nil
						local attribute = arg:GetAttribute(RegionConfig.BossAttribute)

						if type(attribute) == "string" then
							tbl21.deactivate(attribute)
						end
					end)

					tbl22.attach(BossSpawnerFX.GetForRegion(arg))
				end

				for _, v52 in ipairs(CollectionService:GetTagged(RegionConfig.BossTag)) do
					tbl21.watchRegion(v52)
				end

				fn48(CollectionService:GetInstanceAddedSignal(RegionConfig.BossTag):Connect(tbl21.watchRegion))

				fn48({ Disconnect = function()
					for k, regionWatcher in pairs(tbl21.regionWatchers) do
						if regionWatcher.attributeConnection then
							regionWatcher.attributeConnection:Disconnect()
						end

						if regionWatcher.childConnection then
							regionWatcher.childConnection:Disconnect()
						end

						if regionWatcher.destroyConnection then
							regionWatcher.destroyConnection:Disconnect()
						end

						tbl21.regionWatchers[k] = nil
					end

					for k in pairs(tbl21.espRecords) do
						tbl21.clearEsp(k)
					end
				end })

				pcall(function()
					fn48(BossSpawnSound.OnClientEvent:Connect(function()
						fn111("Server Broadcast: BossSpawnSound")
					end))
				end)

				BossTab:Section({ Title = text("Boss Alerts") })

				BossTab:Toggle({
					Title = text("Notify Boss"),
					Default = false,
					Flag = "NotifyBoss",
					Callback = function(notifyEnabled)
						tbl21.notifyEnabled = notifyEnabled

						if notifyEnabled then
							tbl21.refreshEsp()
							local flag43 = not v50

							if flag43 then
								local lastManualScanAt = tbl21.lastManualScanAt
								flag43 = os.clock() - lastManualScanAt >= 15
							end

							if flag43 then
								tbl21.lastManualScanAt = os.clock()
								fn111("Boss Alerts Enabled")
							end
						else
							table.clear(tbl21.notifiedEffects)

							if not tbl21.espEnabled then
								tbl21.generation = tbl21.generation + 1
							end
						end
					end,
				})

				BossTab:Toggle({
					Title = text("ESP Boss"),
					Default = false,
					Flag = "ESPBoss",
					Callback = function(espEnabled)
						tbl21.espEnabled = espEnabled

						if espEnabled then
							tbl21.refreshEsp()
							local flag43 = not v50

							if flag43 then
								local lastManualScanAt = tbl21.lastManualScanAt
								flag43 = os.clock() - lastManualScanAt >= 15
							end

							if flag43 then
								tbl21.lastManualScanAt = os.clock()
								fn111("Boss Alerts Enabled")
							end
						else
							for k in pairs(tbl21.espRecords) do
								tbl21.clearEsp(k)
							end

							if not tbl21.notifyEnabled then
								tbl21.generation = tbl21.generation + 1
							end
						end
					end,
				})

				tbl21.step = function()
					if not flag38 then
						return
					end
					local v52 = v50
					v50 = fn106()

					if v50 and (not v52 or v52.id ~= v50.id) then
						now5 = os.time()
						now6 = nil
					elseif v52 and not v50 then
						now6 = os.time()
					end

					local generation = tbl21.generation
					local v53 = v50

					if not v53 then
						action = "Waiting for a boss spawn signal. Normal farming continues."
						id2 = nil
						v47 = nil
						v48 = nil
						v49 = nil
						genv.HuneHubBossCastTarget = nil
						genv.HuneHubBossCastError = nil
						genv.HuneHubBossWaiting = nil
						tbl21.engaged = false
						return
					end

					local v54 = tbl21.resolve(v53)

					if not v54 then
						genv.HuneHubBossCastTarget = nil
						genv.HuneHubBossCastError = nil
						genv.HuneHubBossWaiting = nil
						tbl21.engaged = false
						action = "Checking boss activity. Normal farming continues until confirmation."
						return
					end

					local function fn112()
						local parent = v54.Parent and BossSpawnerFX.GetForRegion(v54)
						return flag11 and not flag25 and generation == tbl21.generation and parent and BossSpawnerFX.IsActive(parent)
					end

					if not fn112() then
						return
					end
					tbl21.engaged = true

					if id2 ~= v53.id then
						id2 = v53.id
						now5 = os.time()
						lastSignal = "BossSpawnerFX Active"
						local v55 = Catalog.BossRegion.GetById(v53.id)
						fn110("detected_" .. v53.id, "Active boss region: " .. (v55 and v55.name or v53.id) .. ". Searching for a dry fishing spot.")
					end

					local v55 = flag31
					local v56

					if flag31 then
						v56 = v55
					else
						v56 = flag25
					end

					if v56 or tbl8.pending or flag26 then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						action = "Waiting for the current movement or sale to finish."
						return
					end

					if v47 ~= v54 or not v48 and os.clock() - n31 >= 8 then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						v47 = v54
						n31 = os.clock()
						action = "Loading the boss shoreline and checking dry landing spots."
						fn109()

						if workspace.StreamingEnabled then
							pcall(function()
								localPlayer:RequestStreamAroundAsync(v54.Position, 2)
							end)

							local v57 = tbl21.probe(v53.islandId)

							if v57 then
								local v58 = v54.CFrame:PointToObjectSpace(v57)
								local n32 = v54.Size * 0.5
								local z = v58.Z
								local v59 = v54.CFrame:PointToWorldSpace(Vector3.new(math.clamp(v58.X, -n32.X, n32.X), 0, math.clamp(z, -n32.Z, n32.Z)))

								pcall(function()
									localPlayer:RequestStreamAroundAsync(v59, 2)
								end)
							end
						end

						if not fn112() then
							return
						end
						local v57, v58 = fn107(v54)
						if not fn112() then
							return
						end
						v48 = v57
						v49 = v58
					end

					local v57 = v48
					local v58 = v49

					if not v57 or not v58 then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						action = "No dry spot within casting range yet; retrying the shoreline scan."
						return
					end

					if tbl21.readyToFish(v54, v57, v58) then
						genv.HuneHubBossCastTarget = v58
						genv.HuneHubBossWaiting = nil
						action = "Fishing from dry ground inside boss casting range."

						if genv.HuneHubBossCastError then
							action = "Cast pending: " .. tostring(genv.HuneHubBossCastError)

							if os.clock() - n30 >= 15 then
								n30 = os.clock()
								warn("[Hune Hub] Boss cast: " .. tostring(genv.HuneHubBossCastError))
							end
						end

						return
					end

					genv.HuneHubBossWaiting = true
					genv.HuneHubBossCastTarget = nil
					if os.clock() - n29 < 8 then
						return
					end
					n29 = os.clock()
					action = "Tweening directly to dry shoreline near the active boss."
					fn109()
					flag31 = true

					local ok, result = pcall(function()
						fn58()
						if not fn112() then
							return false, "Cancelled"
						end
						return fn105(v57, fn112)
					end)

					flag31 = false
					if not fn112() then
						return
					end

					if ok and result and tbl21.readyToFish(v54, v57, v58) then
						cFrame2 = fn52().CFrame
						cFrame = flag30 and cFrame2 or nil
						n25 = os.clock() + 0.8
						genv.HuneHubBossCastTarget = v58
						genv.HuneHubBossWaiting = nil
						action = "Landed on dry ground. Facing the boss region and starting fishing."
					else
						v48 = nil
						v49 = nil
						action = "Landing not confirmed; rescanning dry ground before fishing."

						if not ok then
							warn("[Hune Hub] Boss travel: " .. tostring(result))
						end
					end

					fn109()
				end

				genv.HuneHubBossValidateCast = function()
					return flag11 and not flag31 and not flag25 and tbl21.readyToFish(v47, v48, v49)
				end
			end

			fn95()
		end

		local function fn63(arg, arg2, arg3)
			local v40 = tbl11[arg]
			GachaTab:Section({ Title = v40.name .. text(" Gacha") })
			local str10

			if arg == "Aura" then
				str10 = fn55(AuraGachaConfig.Pull.CostGem) .. text(" Gems Per Spin")
			elseif arg == "Skill" then
				str10 = text("Coin Price Is Quoted Before Every Spin")
			else
				local v41 = CrateConfig.GetCrate(v40.crateId)
				str10 = fn55(CrateConfig.GetPrice(v40.crateId, 1)) .. " " .. (v41 and v41.Currency or "Coins") .. text(" Per Spin")
			end

			GachaTab:Paragraph({ Title = text("Cost"), Desc = str10 })
			local name = v40.name

			v40.toggle = GachaTab:Toggle({
				Title = text("Auto Spin ") .. name,
				Default = false,
				Flag = arg3.toggle,
				Callback = function(enabled)
					v40.enabled = enabled

					if enabled then
						fn51(arg)
					end
				end,
			})

			GachaTab:Dropdown({
				Title = v40.name .. text(" Stop At Or Above Rarity"),
				Values = arg2,
				Default = v40.rarity,
				Multi = false,
				Flag = arg3.rarity,
				Callback = function(rarity)
					v40.rarity = rarity
				end,
			})

			GachaTab:Slider({
				Title = v40.name .. text(" Maximum Spins"),
				Value = { Min = 1, Max = 100, Default = 10 },
				Step = 1,
				Flag = arg3.amount,
				Callback = function(amount)
					v40.amount = amount
				end,
			})
		end

		fn63("Aura", fn50(AuraGachaConfig.RarityOdds), { toggle = "AutoSpinAuraGacha", rarity = "GachaStopRarity", amount = "MaximumGachaSpins" })

		fn63("Skill", fn50(SkillGachaConfig.RarityOdds), {
			toggle = "AutoSpinSkillGacha",
			rarity = "SkillGachaStopRarity",
			amount = "MaximumSkillGachaSpins",
		})

		fn63("Ocean", fn50(nil, "crate_ocean_chest"), {
			toggle = "AutoSpinOceanChest",
			rarity = "OceanChestStopRarity",
			amount = "MaximumOceanChestSpins",
		})

		fn63("Dragon", fn50(nil, "crate_dragon_chest"), {
			toggle = "AutoSpinDragonChest",
			rarity = "DragonChestStopRarity",
			amount = "MaximumDragonChestSpins",
		})

		ShopTab:Section({ Title = text("Buy Fishing Rods") })

		do
			local tbl12 = {}

			for k, v40 in pairs(RodShopConfig) do
				local v41 = Catalog.Rod.GetById(k)

				if v41 then
					table.insert(tbl12, { id = k, rod = v41, listing = v40 })
				end
			end

			table.sort(tbl12, function(arg, arg2)
				return arg.listing.price < arg2.listing.price
			end)

			local tbl13 = {}
			local tbl14 = {}

			for _, v40 in ipairs(tbl12) do
				local str10 = string.format("%s [%s] - %s %s", v40.rod.name, v40.rod.rarity, fn55(v40.listing.price), v40.listing.currency or "Coin")
				tbl13[str10] = v40
				table.insert(tbl14, str10)
			end

			local v40 = tbl12[1]
			local flag36 = false

			ShopTab:Dropdown({
				Title = text("Select Rod To Buy"),
				Values = tbl14,
				Default = tbl14[1],
				Multi = false,
				Flag = "ShopSelectedRod",
				Callback = function(arg)
					v40 = tbl13[arg] or tbl12[1]
				end,
			})

			ShopTab:Button({
				Title = text("Buy Selected Rod"),
				Callback = function()
					if flag36 then
						return
					end
					local v41 = v40
					if not v41 then
						return
					end

					local ok, result = pcall(function()
						return PlayerDataV2Controller:Fetch(localPlayer)
					end)

					if not ok or type(result) ~= "table" then
						lib:Notify({ Title = text("Rod Shop"), Content = text("Player data is not ready."), Duration = 3 })
						return
					end

					if result.Rods and result.Rods[v41.id] then
						lib:Notify({ Title = text("Rod Shop"), Content = text("You already own this rod."), Duration = 3 })
						return
					end
					local islandId = v41.listing.islandId
					local v42 = islandId and IslandConfig[islandId]
					local flag37

					if islandId then
						flag37 = not (v42 and v42.defaultUnlocked)
					else
						flag37 = islandId
					end

					if flag37 then
						flag37 = not (result.UnlockedIslands and result.UnlockedIslands[islandId] == true)
					end

					if flag37 then
						lib:Notify({ Title = text("Rod Shop"), Content = text("Unlock the rod's island first."), Duration = 3 })
						return
					end
					local currency = v41.listing.currency or "Coin"
					local n26 = tonumber(v41.listing.price) or 0
					if (tonumber(result[currency]) or 0) < n26 then
						lib:Notify({ Title = text("Rod Shop"), Content = text("Not enough ") .. currency .. ".", Duration = 3 })
						return
					end
					flag36 = true

					local ok2, result2 = pcall(function()
						return v35:Fire(v41.id)
					end)

					flag36 = false

					lib:Notify({
						Title = text("Rod Shop"),
						Content = ok2 and result2 and "Bought " .. v41.rod.name .. "." or "Purchase failed; check balance and requirements.",
						Duration = 4,
					})
				end,
			})
		end

		do
			local DailyRewardUtil = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Lib"):WaitForChild("DailyRewardUtil"))

			local v40 = packet("GroupReward/Claim"):Response({
				ok = packet.Boolean8,
				reason = packet.String,
				group_id = packet.NumberU32,
				joined = packet.Boolean8,
				claimed = packet.Boolean8,
				rarity = packet.String,
				is_new = packet.Boolean8,
			})

			local v41 = packet("GroupReward/GetState"):Response({
				enabled = packet.Boolean8,
				group_id = packet.NumberU32,
				joined = packet.Boolean8,
				claimed = packet.Boolean8,
			})

			local v42 = packet("RedeemCode", packet.String):Response(packet.NumberU8)
			local str10 = ""
			local flag36 = false
			local n26 = 0

			local function fn64(arg)
				if flag36 then
					return
				end

				if arg and os.clock() < n26 then
					return
				end
				local dailyReward = PlayerDataV2Controller:Fetch(localPlayer)
				dailyReward = dailyReward and dailyReward.DailyReward
				if type(dailyReward) ~= "table" then
					return
				end
				local v43 = DailyRewardUtil.compute_state(dailyReward, DailyRewardUtil.get_now())

				if not v43.ClaimableDay then
					if not arg then
						local v44 = math.ceil(DailyRewardUtil.seconds_until_next_claim(dailyReward))

						lib:Notify({
							Title = text("Daily Reward"),
							Content = text("Next claim in ") .. fn56(v44) .. ".",
							Duration = 3,
						})
					end

					return
				end

				flag36 = true

				local ok, result = pcall(function()
					return v36:Fire()
				end)

				flag36 = false

				if ok and result == true then
					n26 = 0

					lib:Notify({
						Title = text("Daily Reward"),
						Content = text("Claimed day ") .. tostring(v43.ClaimableDay) .. ".",
						Duration = 3,
					})
				else
					n26 = os.clock() + 300

					if not arg then
						lib:Notify({ Title = text("Daily Reward"), Content = text("Claim rejected by game."), Duration = 3 })
					end
				end
			end

			RewardTab:Section({ Title = text("Daily Login") })

			RewardTab:Button({
				Title = text("Claim Daily Reward"),
				Callback = function()
					fn64(false)
				end,
			})

			RewardTab:Toggle({
				Title = text("Auto Claim Daily Reward"),
				Default = false,
				Flag = "AutoDailyReward",
				Callback = function(arg)
					flag27 = arg

					if arg then
						task.spawn(function()
							pcall(function()
								fn64(true)
							end)
						end)
					end
				end,
			})

			RewardTab:Section({ Title = text("Group & Gift Inbox") })

			RewardTab:Button({
				Title = text("Claim Group Reward"),
				Callback = function()
					local ok, result = pcall(function()
						return v41:Fire()
					end)

					if not ok or type(result) ~= "table" or not result.enabled then
						lib:Notify({ Title = text("Group Reward"), Content = text("Group reward is unavailable."), Duration = 3 })
						return
					end

					if result.claimed then
						lib:Notify({ Title = text("Group Reward"), Content = text("Already claimed."), Duration = 3 })
						return
					end

					if not result.joined then
						local ok2, result2 = pcall(function()
							return game:GetService("GroupService"):PromptJoinAsync(result.group_id)
						end)

						if not ok2 or result2 ~= Enum.GroupMembershipStatus.Joined and result2 ~= Enum.GroupMembershipStatus.AlreadyMember then
							lib:Notify({
								Title = text("Group Reward"),
								Content = text("Join the game's group, then claim again."),
								Duration = 3,
							})

							return
						end
					end

					local ok2, result2 = pcall(function()
						return v40:Fire()
					end)

					lib:Notify({
						Title = text("Group Reward"),
						Content = ok2 and type(result2) == "table" and result2.ok and "Claimed group reward." or type(result2) == "table" and result2.reason or "Claim failed.",
						Duration = 3,
					})
				end,
			})

			RewardTab:Button({
				Title = text("Claim All Gift Inbox Items"),
				Callback = function()
					local ok = pcall(function()
						ClaimAll:Fire()
					end)

					lib:Notify({
						Title = text("Gift Inbox"),
						Content = ok and "Claim request sent. Check your gift inbox." or "Claim request failed.",
						Duration = 3,
					})
				end,
			})

			RewardTab:Section({ Title = text("Redeem Code") })

			RewardTab:Input({
				Title = text("Code"),
				Value = "",
				Placeholder = text("Enter game code"),
				Callback = function(arg)
					str10 = tostring(arg or "")
				end,
			})

			RewardTab:Button({
				Title = text("Redeem Code"),
				Callback = function()
					local match = str10:match("^%s*(.-)%s*$")
					if match == "" then
						return
					end

					local ok, result = pcall(function()
						return v42:Fire(match)
					end)

					local tbl12 = {
						[0] = "Code redeemed.",
						"Invalid code.",
						"Code expired.",
						"Code already redeemed.",
						"Requirements not met.",
						"Save failed; retry later.",
						"Redemption is busy.",
						"Migrated game passes added.",
					}

					lib:Notify({
						Title = text("Redeem Code"),
						Content = ok and (tbl12[result] or "Unknown response.") or "Request failed.",
						Duration = 3,
					})
				end,
			})

			task.spawn(function()
				while flag11 do
					task.wait(30)

					if flag27 then
						pcall(function()
							fn64(true)
						end)
					end
				end
			end)
		end

		RewardTab:Section({ Title = text("Session Statistics") })
		local v40 = RewardTab:Paragraph({ Title = text("Session Statistics"), Desc = text("Fish Caught: 0 | Coins Earned: 0 | Time: 0m 00s") })

		task.spawn(function()
			while flag11 do
				task.wait(2)

				if v40 and v40.SetDesc then
					pcall(function()
						local v41 = n19
						local v42 = fn56
						v40:SetDesc(string.format(text("Fish Caught: %d | Coins Earned: %s | Time: %s"), v41, fn55(n20), v42(tick() - now3)))
					end)
				end
			end
		end)

		MiscTab:Section({ Title = text("Movement") })

		MiscTab:Toggle({
			Title = text("Anti-AFK"),
			Default = true,
			Flag = "AntiAFK",
			Callback = function(arg)
				flag28 = arg
			end,
		})

		MiscTab:Toggle({
			Title = text("Freeze Character"),
			Default = false,
			Flag = "FreezeCharacter",
			Callback = function(anchored)
				flag29 = anchored
				local v41 = fn52()

				if v41 then
					v41.Anchored = anchored
				end
			end,
		})

		MiscTab:Section({ Title = text("System Utilities") })

		local function fn64()
			local flag36 = false
			local flag37 = false
			local Lighting = game:GetService("Lighting")
			local numberSequence = NumberSequence.new(1)
			local debris = workspace:FindFirstChild("Debris")
			local world = workspace:FindFirstChild("World")
			local islands = world and world:FindFirstChild("Islands")
			local color6 = Color3.fromRGB(145, 145, 145)

			local tbl12 = {
				"tree",
				"leaf",
				"leaves",
				"palm",
				"caydua",
				"duwa",
				"bush",
				"grass",
				"foliage",
				"plant",
				"vine",
				"flower",
			}

			local function fn65(arg)
				return debris and arg:IsDescendantOf(debris) or arg:FindFirstAncestor("ClientAuraEffect") ~= nil
			end

			local function fn66(descendant)
				pcall(function()
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false
						descendant.Rate = 0
						descendant.Transparency = numberSequence
						descendant:Clear()
					elseif descendant:IsA("Beam") or descendant:IsA("Trail") then
						descendant.Enabled = false
						descendant.Transparency = numberSequence
					elseif descendant:IsA("Fire") then
						descendant.Enabled = false
						descendant.Size = 0
						descendant.Heat = 0
					elseif descendant:IsA("Smoke") then
						descendant.Enabled = false
						descendant.Opacity = 0
						descendant.Size = 0
					elseif descendant:IsA("Sparkles") then
						descendant:Destroy()
					elseif descendant:IsA("Highlight") then
						descendant.Enabled = false
						descendant.FillTransparency = 1
						descendant.OutlineTransparency = 1
					elseif descendant:IsA("PointLight") or descendant:IsA("SurfaceLight") or descendant:IsA("SpotLight") then
						descendant.Enabled = false
						descendant.Brightness = 0
					elseif descendant:IsA("PostEffect") then
						descendant.Enabled = false
					elseif descendant:IsA("Explosion") then
						descendant.Visible = false
					elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
						descendant.Transparency = 1
						descendant.Texture = ""
					elseif descendant:IsA("SurfaceAppearance") then
						descendant:Destroy()
					elseif descendant:IsA("SpecialMesh") then
						descendant.TextureId = ""
					elseif descendant:IsA("BasePart") then
						descendant.Material = Enum.Material.SmoothPlastic

						pcall(function()
							descendant.MaterialVariant = ""
						end)

						descendant.Reflectance = 0
						descendant.CastShadow = false

						if fn65(descendant) then
							descendant.LocalTransparencyModifier = 1
						end

						if descendant:IsA("MeshPart") then
							descendant.TextureID = ""
							descendant.RenderFidelity = Enum.RenderFidelity.Performance
						elseif descendant:IsA("UnionOperation") then
							descendant.RenderFidelity = Enum.RenderFidelity.Performance
						end
					elseif descendant:IsA("Sky") then
						descendant:Destroy()
					elseif descendant:IsA("Atmosphere") then
						descendant.Density = 0
						descendant.Haze = 0
						descendant.Glare = 0
					end
				end)
			end

			local function fn67(arg)
				if arg.CanCollide then
					return false
				end
				local parent = arg

				while parent and parent ~= islands do
					local v41 = string.lower(parent.Name)

					for _, v42 in ipairs(tbl12) do
						if string.find(v41, v42, 1, true) then
							return true
						end
					end

					parent = parent.Parent
				end

				local color7 = arg.Color
				return color7.G > 0.25 and color7.G > color7.R * 1.15 and color7.G > color7.B * 1.15
			end

			local function fn68(arg)
				local parent = arg.Parent

				while parent and parent ~= islands do
					if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
						return true
					end
					parent = parent.Parent
				end

				return false
			end

			local function fn69(arg)
				pcall(function()
					if arg:IsA("Clouds") then
						arg.Cover = 0
						arg.Density = 0
					elseif arg:IsA("BasePart") and islands and arg:IsDescendantOf(islands) and arg.Anchored and not fn68(arg) then
						local v41 = fn67(arg)
						arg.Color = color6

						if v41 then
							arg.LocalTransparencyModifier = 1
						end
					end
				end)
			end

			local function fn70(descendant)
				if descendant.Name == "Debris" and descendant.Parent == workspace then
					debris = descendant
				elseif descendant.Name == "World" and descendant.Parent == workspace then
					world = descendant
				elseif descendant.Name == "Islands" and world and descendant.Parent == world then
					islands = descendant
				end

				fn66(descendant)

				if flag37 then
					fn69(descendant)
				end
			end

			local function fn71()
				pcall(function()
					Lighting.EnvironmentDiffuseScale = 0
					Lighting.EnvironmentSpecularScale = 0
					Lighting.GlobalShadows = false
					Lighting.Ambient = Color3.fromRGB(150, 150, 150)
					Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
				end)

				local terrain = workspace.Terrain

				if sethiddenproperty then
					pcall(function()
						sethiddenproperty(terrain, "Decoration", false)
					end)
				end

				pcall(function()
					for _, v41 in ipairs({ "Grass", "LeafyGrass", "Ground", "Rock", "Slate", "Sand", "Snow", "Mud" }) do
						local v42 = Enum.Material[v41]

						if v42 then
							pcall(function()
								terrain:SetMaterialColor(v42, color6)
							end)
						end
					end

					local clouds = terrain:FindFirstChildOfClass("Clouds")

					if clouds then
						fn69(clouds)
					end
				end)
			end

			local function fn72()
				if flag36 then
					return false
				end
				flag36 = true

				task.spawn(function()
					pcall(function()
						packet("SetSettings", packet.String, packet.Any):Response(packet.Boolean8):Fire("Show VFX (Other Players)", false)
					end)
				end)

				pcall(function()
					local EffectController = client.GetController("EffectController")
					local effect = EffectController.Effect

					local function effect2(arg, arg2, arg3, arg4, ...)
						if type(arg2) == "string" and arg2:sub(1, 9) == "Movesets/" and typeof(arg4) == "Instance" and arg4:IsA("Player") and arg4 ~= localPlayer then
							return
						end
						return effect(arg, arg2, arg3, arg4, ...)
					end

					EffectController.Effect = effect2

					fn48({ Disconnect = function()
						if EffectController.Effect == effect2 then
							EffectController.Effect = effect
						end
					end })
				end)

				pcall(function()
					local level01 = Enum.QualityLevel.Level01
					settings().Rendering.QualityLevel = level01
				end)

				pcall(function()
					game:GetService("MaterialService").Use2022Materials = false
				end)

				pcall(function()
					Lighting.GlobalShadows = false
					Lighting.ShadowSoftness = 0
				end)

				pcall(function()
					local terrain = workspace.Terrain
					terrain.WaterWaveSize = 0
					terrain.WaterWaveSpeed = 0
					terrain.WaterReflectance = 0
					terrain.WaterTransparency = 1
					terrain.CastShadow = false
				end)

				fn48(workspace.DescendantAdded:Connect(fn70))
				fn48(Lighting.DescendantAdded:Connect(fn66))

				task.spawn(function()
					local n26 = 0

					for _, descendant in ipairs(workspace:GetDescendants()) do
						if not flag11 then
							return
						end
						fn70(descendant)
						n26 += 1

						if n26 % 250 == 0 then
							task.wait()
						end
					end

					for _, descendant in ipairs(Lighting:GetDescendants()) do
						if not flag11 then
							return
						end
						fn66(descendant)
					end

					lib:Notify({
						Title = text("Fix Lag"),
						Content = flag37 and "Pro Mode Applied To The Map And VFX." or "Textures And VFX Have Been Reduced.",
						Duration = 3,
					})
				end)

				return true
			end

			MiscTab:Button({
				Title = text("Fix Lag Pro (Boost FPS)"),
				Callback = function()
					if flag37 then
						lib:Notify({ Title = text("Fix Lag Pro"), Content = text("Pro Mode Is Already Active."), Duration = 3 })
						return
					end
					flag37 = true
					fn72()
					fn71()
				end,
			})
		end

		fn64()

		MiscTab:Button({
			Title = text("Rejoin Server"),
			Callback = function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
			end,
		})

		MiscTab:Button({ Title = text("Unload Hub"), Callback = fn62 })

		local function fn65()
			tbl3.migrateLegacyProfiles("fishingMaster", configManager)

			local function fn66(arg)
				return tbl3.update(function(arg2)
					arg2.fishingMaster = type(arg2.fishingMaster) == "table" and arg2.fishingMaster or {}
					arg2.fishingMaster.autoload = tostring(arg or "None")
				end)
			end

			local function fn67()
				local fishingMaster = tbl3.read().fishingMaster
				return type(fishingMaster) == "table" and type(fishingMaster.autoload) == "string" and fishingMaster.autoload ~= "" and fishingMaster.autoload or "None"
			end

			local function fn68(arg)
				if not arg then
					return ""
				end
				return tostring(arg):gsub("[%c%s]+", "")
			end

			local function fn69()
				local tbl12 = {}

				for k in pairs(tbl3.profiles("fishingMaster")) do
					table.insert(tbl12, k)
				end

				table.sort(tbl12)

				if #tbl12 == 0 then
					table.insert(tbl12, "Default")
				end

				return tbl12
			end

			local function fn70(arg)
				local tbl12 = { "None" }
				local v41 = ipairs
				local tbl13 = arg or {}

				for _, v42 in v41(tbl13) do
					table.insert(tbl12, v42)
				end

				return tbl12
			end

			local v41 = nil
			local v42 = nil
			local str10 = ""
			local v43 = fn69()
			local str11 = v43[1] or "Default"
			local str12 = fn67()
			local str13 = str12
			local flag36 = false

			local function fn71()
				local v44 = fn69()

				if v41 then
					pcall(function()
						v41:Refresh(v44)
					end)
				end

				if v42 then
					pcall(function()
						v42:Refresh(fn70(v44))
					end)
				end
			end

			SettingsTab:Section({ Title = text("Interface Settings") })

			SettingsTab:Dropdown({
				Title = text("Theme"),
				Values = { "Dark", "Light", "Aqua", "Amethyst", "Mocha", "Latte", "Transparent" },
				Default = "Dark",
				Flag = "Theme",
				Callback = function(arg)
					pcall(function()
						lib:SetTheme(arg)
					end)
				end,
			})

			local v44 = LanguageTab
			local dropdown = v44.Dropdown
			local tbl12 = { Title = text("Select Language"), Values = { "Auto / Tự Động (Roblox)", "Tiếng Việt", "English" } }
			local default = tbl4.mode == "auto" and "Auto / Tự Động (Roblox)"

			if not default then
				default = tbl4.mode == "vi" and "Tiếng Việt" or "English"
			end

			tbl12.Default = default

			tbl12.Callback = function(arg)
				local mode = arg == "Tiếng Việt" and "vi"

				if not mode then
					mode = arg == "English" and "en" or "auto"
				end

				tbl4.mode = mode
				tbl4.code = mode == "auto" and tbl4.detect() or mode
				genv.HuneHubFishingLanguageMode = mode
				local v45 = tbl4.save(mode)

				task.defer(function()
					tbl4.refreshGui(lib)
				end)

				lib:Notify({
					Title = text("Language"),
					Content = v45 and text("Language updated and saved.") or text("Language updated for this session, but could not be saved."),
					Duration = 4,
				})
			end

			dropdown(v44, tbl12)
			SettingsTab:Section({ Title = text("Profile Management System") })

			SettingsTab:Input({
				Title = text("New Config Name"),
				Default = str10,
				Placeholder = text("e.g. AutoFarm"),
				Callback = function(arg)
					str10 = fn68(arg)
				end,
			})

			SettingsTab:Button({
				Title = text("Save Config"),
				Callback = function()
					if flag36 then
						return
					end
					flag36 = true
					local v45 = str10

					if v45 == "" then
						lib:Notify({ Title = text("Hune Hub"), Content = text("Please enter config name first!"), Duration = 4 })
						flag36 = false
						return
					end

					local ok, result = pcall(function()
						tbl3.saveProfile("fishingMaster", v45, v39, configManager)
					end)

					if ok then
						str11 = v45
						lib:Notify({ Title = text("Hune Hub"), Content = text("Saved: ") .. v45, Duration = 3 })
						fn71()
					else
						lib:Notify({ Title = text("Hune Hub"), Content = text("Save config failed: ") .. tostring(result), Duration = 5 })
					end

					flag36 = false
				end,
			})

			v41 = SettingsTab:Dropdown({
				Title = text("Select Config To Load/Delete"),
				Values = v43,
				Default = str11,
				Callback = function(arg)
					str11 = arg
				end,
			})

			SettingsTab:Button({
				Title = text("Load Config"),
				Callback = function()
					if not str11 or str11 == "" then
						return
					end

					local ok, result = pcall(function()
						tbl3.loadProfile("fishingMaster", str11, v39, configManager)
					end)

					if ok then
						lib:Notify({ Title = text("Hune Hub"), Content = text("Loaded: ") .. str11, Duration = 3 })
					else
						lib:Notify({ Title = text("Hune Hub"), Content = text("Load config failed: ") .. tostring(result), Duration = 5 })
					end
				end,
			})

			SettingsTab:Button({
				Title = text("Delete Config"),
				Callback = function()
					if not str11 or str11 == "" then
						return
					end
					local v45 = str11

					local ok, result = pcall(function()
						if not tbl3.profiles("fishingMaster")[v45] then
							error("profile not found")
						end

						if not tbl3.update(function(arg)
							arg.fishingMaster.profiles[v45] = nil

							if arg.fishingMaster.autoload == v45 then
								arg.fishingMaster.autoload = "None"
							end
						end) then
							error("could not delete profile")
						end
					end)

					if ok then
						if v45 == str12 then
							str12 = "None"
							str13 = "None"
							fn66("None")
						end

						lib:Notify({ Title = text("Hune Hub"), Content = text("Deleted: ") .. v45, Duration = 3 })
						fn71()
					else
						lib:Notify({
							Title = text("Hune Hub"),
							Content = text("Delete config failed: ") .. tostring(result),
							Duration = 5,
						})
					end
				end,
			})

			v42 = SettingsTab:Dropdown({
				Title = text("Select Auto Load Config"),
				Values = fn70(v43),
				Default = str12,
				Callback = function(arg)
					str13 = arg
				end,
			})

			SettingsTab:Button({
				Title = text("Set Auto Load Config"),
				Callback = function()
					str12 = str13 or "None"
					if not fn66(str12) then
						lib:Notify({ Title = text("Hune Hub"), Content = text("Save failed; retry later."), Duration = 5 })
						return
					end
					lib:Notify({ Title = text("Hune Hub"), Content = text("Auto load set to: ") .. str12, Duration = 4 })
				end,
			})

			task.spawn(function()
				task.wait(2)
				local v45 = fn67()
				if v45 == "None" or v45 == "" then
					return
				end
				local flag37 = false

				for i = 1, 5 do
					if pcall(function()
						tbl3.loadProfile("fishingMaster", v45, v39, configManager)
					end) then
						flag37 = true
						break
					else
						task.wait(1)
					end
				end

				if flag37 then
					lib:Notify({ Title = text("Hune Hub"), Content = text("Auto Loaded Config (") .. v45 .. ")", Duration = 5 })
				end
			end)

			AboutTab:Select()
			lib:Notify({ Title = text("Hune Hub"), Content = text("Join Discord For More Update New!!!"), Duration = 5 })

			lib:Notify({
				Title = text("Hune Hub Ready"),
				Content = text("Fishing Master is ready. Enable Auto Farm to begin."),
				Duration = 4,
			})
		end

		fn65()
	end, v29, ...)

	if not v30 then
		if huneConsole.Error then
			v4(huneConsole.Error, v2(v31))
		end
	end

	return v31

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
		genv.HuneHubPreviousSession = type(genv.HuneHubFishingMaster) == "table"

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

					local result = tbl3.read()

					if type(isfile) == "function" and isfile(tbl3.path) then
						local ok

						ok, result = pcall(function()
							return HttpService2:JSONDecode(readfile(tbl3.path))
						end)

						if not ok or type(result) ~= "table" then
							error("existing config JSON is invalid")
						end
					end

					result.version = 1
					arg(result)

					if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("Hune Hub") then
						makefolder("Hune Hub")
					end

					local json = HttpService2:JSONEncode(result)
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
				["Teleport Instant"] = "Dịch Chuyển Tức Thì",
				["Auto Lock Fish by Rarity"] = "Tự Khóa Cá Theo Độ Hiếm",
				["Rarities to Lock"] = "Độ Hiếm Cần Khóa",
				["Auto Lock Fish"] = "Tự Khóa Cá",
				["Auto Sell When Bag Full"] = "Tự Bán Khi Túi Đầy",
				["Auto Sell On Timer"] = "Tự Bán Theo Giờ",
				["Sell Interval (Seconds)"] = "Chu Kỳ Bán (Giây)",
				["Sell All Fish Now"] = "Bán Tất Cả Cá Ngay",
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
				["Selling Fish"] = "Đang Bán Cá",
				["Sell Pending"] = "Đang Chờ Xác Nhận Bán Cá",
				["Moving to the nearest Fish Merchant."] = "Đang Đến Người Bán Cá Gần Nhất.",
				["The sale has not been confirmed. The script will retry."] = "Chưa Xác Nhận Bán Cá. Script Sẽ Thử Lại.",
				["No safe position was found near the Fish Merchant."] = "Không Tìm Thấy Vị Trí An Toàn Gần Người Bán Cá.",
				["The game moved the character away from the Fish Merchant."] = "Game Đã Đưa Nhân Vật Ra Xa Người Bán Cá.",
				["The sale could not be completed."] = "Không Thể Hoàn Tất Bán Cá.",
				["Finishing Current Fish"] = "Đang Câu Xong Cá Hiện Tại",
				["The sale will start when the current fight ends."] = "Sẽ Bắt Đầu Bán Khi Lượt Câu Hiện Tại Kết Thúc.",
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
				["LAST SEEN: "] = "THẤY LẦN CUỐI: ",
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
			local localeId = nil

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
				method = "Walk",
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
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character and character.DisplayName == displayName then
					character.DisplayName = displayName2
				end

				if v39 and v39.Parent and v39.Text == v40 then
					v39.RichText = richText
					v39.Text = text2
				end
			end
		end

		local fn50

		do
			local tbl11 = { Up = "W", Left = "A", Right = "D", W = "W", A = "A", D = "D" }
			local tbl12 = { A = true, W = true, D = true }

			fn50 = function(arg)
				local v39 = nil

				pcall(function()
					v39 = FishingConfig.Counter.DirectionToKey[arg]
				end)

				local v40 = v39 or tbl11[arg]
				return tbl12[v40] and v40 or nil
			end
		end

		local tbl11, fn51, fn52

		do
			local tbl12 = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythical = 6, Divine = 7 }

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

			fn51 = function(arg, arg2)
				local tbl13 = {}

				if arg2 then
					local v39 = ipairs
					local tbl14 = CrateConfig.GetPool(arg2) or {}

					for _, v40 in v39(tbl14) do
						local rarity = v40.Item and v40.Item.rarity

						if rarity then
							tbl13[rarity] = true
						end
					end
				else
					local v39 = pairs
					arg = arg or {}

					for k in v39(arg) do
						tbl13[k] = true
					end
				end

				local tbl14 = {}

				for _, v39 in ipairs(RarityEnums.Order) do
					if tbl13[v39] then
						table.insert(tbl14, v39)
					end
				end

				return tbl14
			end

			local function fn53(arg)
				local Coin

				if arg == "Aura" then
					Coin = v31:Fire(1)
				elseif arg == "Skill" then
					local v39 = v32:Fire(1)
					if type(v39) ~= "table" or not v39.ok then
						return nil, type(v39) == "table" and v39.reason or "QuoteUnavailable"
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

			local function fn54(arg, arg2)
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

			local tbl13 = {
				insufficient_gem = "Not enough Gems.",
				insufficient_coin = "Not enough Coins.",
				storage_full = "Skill storage is full.",
				busy = "The shop is busy. Try again shortly.",
				QuoteUnavailable = "Skill price is unavailable.",
				NoResponse = "The shop did not respond.",
				NoResults = "The shop returned no item.",
			}

			fn52 = function(arg)
				local v39 = tbl11[arg]
				if not v39 or v39.running or not v39.enabled then
					return
				end
				v39.running = true

				task.spawn(function()
					task.wait(0.1)
					local n26 = 0
					local exitTo = nil
					local ok, result, result2

					while true do
						local enabled = flag11 and v39.enabled

						if enabled then
							enabled = n26 < math.max(1, math.floor(tonumber(v39.amount) or 10))
						end

						if enabled then
							while flag11 and v39.enabled and flag36 do
								task.wait(0.05)
							end

							if not flag11 or not v39.enabled then
								exitTo = 1
								break
							else
								flag36 = true
								ok, result, result2 = pcall(fn53, arg)
								flag36 = false

								if not ok or not result then
									exitTo = 2
									break
								else
									n26 += 1
									local n27 = tbl12[v39.rarity] or 5
									local exitTo2 = nil

									for _, result3 in ipairs(result.results) do
										if n27 <= (tbl12[result3.rarity] or 0) then
											exitTo2 = 1
											break
										end
									end

									if exitTo2 ~= 1 then
										if n26 < math.max(1, math.floor(tonumber(v39.amount) or 10)) then
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
						fn54(v39, v39.enabled and ("Reached the %d-spin limit."):format(n26) or nil)
						return
					end

					if exitTo == 2 then
						local str10 = tostring(ok and result2 or result)
						fn54(v39, "Stopped: " .. (tbl13[str10] or str10))
						return
					end

					fn54(v39, string.format("%s (%s) after %d spins", tostring(u4_2.aura_id or u4_2.skill_id or u4_2.rod_skin_id or "?"), tostring(u4_2.rarity), n26))
				end)
			end
		end

		local fn53

		fn53 = function()
			return (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
		end

		local fn54

		fn54 = function()
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

		local fn55, fn56, fn57, walkTo, fn58, fn59, fn60, fn61, v39, configManager

		do
			local function fn62(arg)
				if not arg or not arg:IsA("Tool") then
					return false
				end
				local v40 = nil

				pcall(function()
					v40 = Catalog.Rod.GetById(arg.Name)
				end)

				return v40 ~= nil
			end

			fn55 = function(arg)
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
					if fn62(child) then
						return true
					end
				end

				local backpack = localPlayer:FindFirstChildOfClass("Backpack")
				if not backpack then
					return false
				end
				local v40 = nil

				for _, child in ipairs(backpack:GetChildren()) do
					if fn62(child) then
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
						elseif os.clock() >= n26 then
							break
						end
					end
				end

				return false
			end

			local v40 = nil
			local v41 = nil

			local function fn63()
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

			local function fn64(arg)
				local v42 = fn53()
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

			local function fn65()
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

					local flag36 = ok2 and type(result2) == "table"
					local tryAutoCast

					if flag36 then
						tryAutoCast = result2.TryAutoCast or result2[14]
					else
						tryAutoCast = flag36
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

				local v42, v43 = fn63()

				if v42 and v43 then
					if pcall(v42) then
						local now5 = os.clock()

						while flag11 and resumeSoldFish and not flag31 and os.clock() - now5 < 2 do
							local v44 = fn54()

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

				local v44 = fn64(n26)

				return (pcall(function()
					FishingPackets.FishCast:Fire(n26, v44)
				end))
			end

			fn56 = function(arg)
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

			fn57 = function(arg)
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
				local hit = workspace:Raycast(arg.Position + Vector3.new(0, 1, 0), Vector3.new(0, -10, 0), raycastParams) or workspace:Spherecast(arg.Position + Vector3.new(0, 1, 0), 2, Vector3.new(0, -10, 0), raycastParams)
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
					local n26 = arg2.Position + unit * math.min(i * 2, magnitude)
					local hit = workspace:Spherecast(n26 + Vector3.new(0, 2, 0), 1.5, Vector3.new(0, -12, 0), raycastParams)

					if not hit then
						hit = workspace:Raycast(n26 + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), raycastParams)
					end

					if hit and hit.Material == Enum.Material.Water then
						return false, "NoSafeRoute"
					end
				end

				local tbl12 = {}

				local function fn66(descendant)
					if descendant:IsA("BasePart") and tbl12[descendant] == nil then
						tbl12[descendant] = descendant.CanCollide
						descendant.CanCollide = false
					end
				end

				for _, descendant in ipairs(arg:GetDescendants()) do
					fn66(descendant)
				end

				local connection = arg.DescendantAdded:Connect(fn66)

				local connection2 = game:GetService("RunService").Stepped:Connect(function()
					for k in pairs(tbl12) do
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

						if tbl8.walkGap(arg2.Position, arg4) <= 3.5 and math.abs(arg2.Position.Y - arg4.Y) <= 8 then
							return true, "ObstaclePassed"
						end

						if not tbl8.hasSolidGroundUnder(arg2, arg) then
							return false, "NoSafeRoute"
						end
						task.wait(0.05)
						if (arg2.Position - position).Magnitude > 15 then
							return false, "PositionCorrected"
						end
						position = arg2.Position
					end

					return false, "Stuck"
				end)

				connection2:Disconnect()
				connection:Disconnect()

				for k, v42 in pairs(tbl12) do
					if k.Parent then
						k.CanCollide = v42
					end
				end

				if not ok then
					return false, "Stuck"
				end
				return result, result2
			end

			tbl8.shouldJumpObstacle = function(arg, arg2, arg3)
				if not arg or not arg3 then
					return false
				end
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { arg3 }
				raycastParams.RespectCanCollide = true
				local position = arg.Position
				local vector = Vector3.new(arg2.X, 0, arg2.Z)
				if vector.Magnitude < 0.1 then
					return false
				end
				local unit = vector.Unit

				if workspace:Spherecast(position + Vector3.new(0, -1.2, 0), 0.6, unit * 3.2, raycastParams) then
					if not workspace:Raycast(position + Vector3.new(0, 2.2, 0), unit * 3.5, raycastParams) then
						return true
					end
				end

				return false
			end

			walkTo = function(arg, arg2)
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
					return false, "CharacterNotReady"
				end

				if humanoidRootPart.Anchored then
					humanoidRootPart.Anchored = false
				end

				pcall(function()
					humanoid:UnequipTools()
				end)

				if humanoid.WalkSpeed < 16 then
					humanoid.WalkSpeed = 16
				end

				if humanoid.JumpPower < 50 then
					humanoid.JumpPower = 50
				end

				humanoid.AutoRotate = true

				pcall(function()
					local playerModule = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")

					if playerModule then
						require(playerModule):GetControls():Enable()
					end
				end)

				if humanoid.FloorMaterial == Enum.Material.Water or not tbl8.hasSolidGroundUnder(humanoidRootPart, character) then
					return false, "NoSafeRoute"
				end
				local magnitude = (humanoidRootPart.Position - arg.Position).Magnitude

				if magnitude <= 8 then
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

				local function fn66()
					local ok, result = pcall(function()
						return PathfindingService:CreatePath({
							AgentRadius = 2.4,
							AgentHeight = 5,
							AgentCanJump = true,
							WaypointSpacing = 7,
							Costs = { Water = math.huge },
						})
					end)

					if not ok or not result then
						return nil
					end

					if not pcall(function()
						result:ComputeAsync(humanoidRootPart.Position, arg.Position)
					end) or result.Status ~= Enum.PathStatus.Success then
						result:Destroy()

						local ok2, result2 = pcall(function()
							return PathfindingService:CreatePath({
								AgentRadius = 2,
								AgentHeight = 5,
								AgentCanJump = true,
								WaypointSpacing = 8,
								Costs = { Water = math.huge },
							})
						end)

						if ok2 and result2 then
							if pcall(function()
								result2:ComputeAsync(humanoidRootPart.Position, arg.Position)
							end) and result2.Status == Enum.PathStatus.Success then
								local waypoints = result2:GetWaypoints()
								result2:Destroy()
								return #waypoints > 0 and waypoints or nil
							end

							result2:Destroy()
						end

						return nil
					end

					local waypoints = result:GetWaypoints()
					result:Destroy()
					return #waypoints > 0 and waypoints or nil
				end

				local v42 = fn66()
				if not v42 then
					return false, "NoSafeRoute"
				end
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { character }
				raycastParams.RespectCanCollide = true

				for _, v43 in ipairs(v42) do
					local hit = workspace:Raycast(v43.Position + Vector3.new(0, 5, 0), Vector3.new(0, -14, 0), raycastParams)
					if not hit or hit.Material == Enum.Material.Water then
						return false, "NoSafeRoute"
					end
				end

				local position = humanoidRootPart.Position
				local now5 = os.clock()
				local n26 = 1
				local now6, position2, v43

				while n26 <= #v42 do
					if not flag11 or localPlayer.Character ~= character or humanoid.Health <= 0 or arg2 and not arg2() then
						humanoid:MoveTo(humanoidRootPart.Position)
						return false, "Cancelled"
					end

					if humanoid.FloorMaterial == Enum.Material.Water then
						humanoid:MoveTo(humanoidRootPart.Position)
						return false, "NoSafeRoute"
					end
					local v44 = v42[n26]
					local n27 = n26 == #v42 and 2.8 or 4
					if tbl8.walkGap(humanoidRootPart.Position, v44.Position) <= n27 and math.abs(humanoidRootPart.Position.Y - v44.Position.Y) <= 6 then
						n26 += 1
						continue
					end

					if v44.Action == Enum.PathWaypointAction.Jump then
						humanoid.Jump = true

						pcall(function()
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end)
					end

					humanoid:MoveTo(v44.Position)
					local clamp = math.clamp
					local n28 = os.clock() + clamp(tbl8.walkGap(humanoidRootPart.Position, v44.Position) / math.max(humanoid.WalkSpeed, 4) * 2.2 + 2.5, 3, 8)
					local now7 = os.clock()
					local v45 = tbl8.walkGap(humanoidRootPart.Position, v44.Position)
					local flag36 = v44.Action == Enum.PathWaypointAction.Jump
					local flag37 = false
					local exitTo = nil

					while true do
						if tbl8.walkGap(humanoidRootPart.Position, v44.Position) > n27 or math.abs(humanoidRootPart.Position.Y - v44.Position.Y) > 6 then
							if not flag11 or localPlayer.Character ~= character or humanoid.Health <= 0 or arg2 and not arg2() then
								exitTo = 2
								break
							else
								task.wait(0.1)

								if humanoid.FloorMaterial == Enum.Material.Water then
									exitTo = 3
									break
								else
									now6 = os.clock()
									position2 = humanoidRootPart.Position
									local n29 = v44.Position - position2

									if humanoid.FloorMaterial ~= Enum.Material.Air and tbl8.shouldJumpObstacle(humanoidRootPart, n29.Magnitude > 0.05 and n29.Unit or humanoidRootPart.CFrame.LookVector, character) then
										humanoid.Jump = true

										pcall(function()
											humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
										end)
									end

									local magnitude2 = (position2 - position).Magnitude

									if math.max(20, humanoid.WalkSpeed * math.max(now6 - now5, 0.01) * 3.5 + 10) < magnitude2 then
										exitTo = 4
										break
									else
										local v46 = tbl8.walkGap(position2, v44.Position)

										if v46 < v45 - 0.8 then
											v45 = v46
											now7 = now6
										end

										if now6 - now7 > 1 and not flag36 then
											humanoid.Jump = true

											pcall(function()
												humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
											end)

											humanoid:MoveTo(v44.Position)
											flag36 = true
											now5 = now6
											position = position2
											now7 = now6
											n28 = math.max(n28, now6 + 2.5)
											continue
										elseif now6 - now7 > 1.6 and not flag37 then
											if not tbl8.passWalkObstacle(character, humanoidRootPart, humanoid, v44.Position, arg2) then
												humanoid.Jump = true

												pcall(function()
													humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
												end)

												task.wait(0.2)
												humanoid:MoveTo(v44.Position)

												if not (tbl8.walkGap(humanoidRootPart.Position, v44.Position) <= n27) then
													now5 = now6
													position = position2
													continue
												else
													exitTo = 7
													break
												end
											else
												position = humanoidRootPart.Position
												now5 = os.clock()
												v45 = tbl8.walkGap(humanoidRootPart.Position, v44.Position)
												local n30 = math.max(n28, now5 + 2.5)
												humanoid:MoveTo(v44.Position)
												flag37 = true
												now7 = now5
												n28 = n30
												continue
											end
										elseif now6 - now7 > 2.6 then
											v43 = fn66()

											if v43 and #v43 > 0 then
												exitTo = 5
												break
											elseif now6 >= n28 or now6 - now7 > 4 then
												exitTo = 6
												break
											else
												now5 = now6
												position = position2
												continue
											end
										elseif not (n28 <= now6) then
											now5 = now6
											position = position2
											continue
										end
									end
								end
							end
						else
							exitTo = 1
							break
						end

						break
					end

					if exitTo ~= 1 then
						if exitTo == 2 then
							humanoid:MoveTo(humanoidRootPart.Position)
							return false, "Cancelled"
						end

						if exitTo == 3 then
							humanoid:MoveTo(humanoidRootPart.Position)
							return false, "NoSafeRoute"
						end

						if exitTo == 4 then
							humanoid:MoveTo(position2)
							return false, "PositionCorrected"
						end

						if exitTo == 5 then
							n26 = 1
							now5 = now6
							position = position2
							v42 = v43
						else
							if exitTo == 6 then
								humanoid:MoveTo(position2)
								return false, "Stuck"
							end

							if exitTo ~= 7 then
								humanoid:MoveTo(position2)
								return false, "Stuck"
							end
							now5 = now6
							position = position2
						end
					end

					n26 += 1
				end

				if (humanoidRootPart.Position - arg.Position).Magnitude <= 12 or tbl8.walkGap(humanoidRootPart.Position, arg.Position) <= 10 then
					return true, "WalkFinished"
				end
				return false, "ArrivalUnconfirmed"
			end

			tbl8.walkTo = walkTo

			local function tweenTo(arg, arg2, arg3, arg4)
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
				local flag36 = magnitude > 160
				local tbl12 = {}

				for i = 1, n26 do
					local n27 = i / n26

					if i == n26 then
						tbl12[i] = arg
					else
						local v42 = position:Lerp(position2, n27)
						local vector

						if flag36 then
							local z = v42.Z
							vector = Vector3.new(v42.X, math.max(position.Y, position2.Y) + math.sin(n27 * 3.1415926535897931) * 25, z)
						else
							vector = v42
						end

						local rotation = humanoidRootPart.CFrame.Rotation
						tbl12[i] = CFrame.new(vector) * rotation
					end
				end

				local tbl13 = {}

				local function fn66(descendant)
					if descendant:IsA("BasePart") and tbl13[descendant] == nil then
						tbl13[descendant] = descendant.CanCollide
						descendant.CanCollide = false
					end
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					fn66(descendant)
				end

				local connection = character.DescendantAdded:Connect(fn66)

				local connection2 = game:GetService("RunService").Stepped:Connect(function()
					for k in pairs(tbl13) do
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
					for _, v42 in ipairs(tbl12) do
						local flag37 = not flag11 or localPlayer.Character ~= character or not humanoidRootPart.Parent or humanoid.Health <= 0
						local flag38

						if flag37 then
							flag38 = flag37
						else
							local v43 = arg2

							if arg2 then
								flag38 = not arg2()
							else
								flag38 = v43
							end
						end

						if flag38 then
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
							local flag39 = not flag11 or localPlayer.Character ~= character or not humanoidRootPart.Parent or humanoid.Health <= 0
							local flag40

							if flag39 then
								flag40 = flag39
							else
								local v44 = arg2

								if arg2 then
									flag40 = not arg2()
								else
									flag40 = v44
								end
							end

							if flag40 then
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
							local magnitude3 = (position4 - position3).Magnitude

							if not (math.max(12, n27 * (now6 - now5) * 3 + 4) < magnitude3) then
								position3 = position4
								now5 = now6
								continue
							end

							tween:Cancel()
							return false, "PositionCorrected"
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

				for k, v42 in pairs(tbl13) do
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
				local flag37 = not humanoidRootPart.Parent

				if not flag37 then
					flag37 = (humanoidRootPart.Position - arg.Position).Magnitude > (arg4 and 1.5 or 8)
				end

				if flag37 then
					return false, "ArrivalUnconfirmed"
				end
				return true, result2
			end

			tbl8.tweenTo = tweenTo
			local fn66 = nil

			fn66 = function(arg)
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
					return fn66(arg.Parent)
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

			local function fn67(arg)
				local lower = string.lower
				local str10 = tostring(arg):gsub("[^%w]", "")
				return lower(str10)
			end

			local function fn68(arg)
				local isProximityPrompt = arg:IsA("ProximityPrompt") and arg or arg:FindFirstChildWhichIsA("ProximityPrompt", true)
				return fn66(isProximityPrompt and isProximityPrompt.Parent or arg)
			end

			local function fn69(arg)
				local v42 = fn53()
				if not v42 then
					return nil, nil
				end
				local v43 = nil
				local v44 = nil
				local huge = math.huge
				local str10 = arg == "npc_fish_seller" and "fishmerchant" or fn67(arg)

				local function fn70(arg2, arg3)
					if not arg2:IsDescendantOf(workspace) then
						return
					end
					local flag36 = arg2:GetAttribute("InteractiveId") == arg

					if not flag36 and arg3 and (arg2:IsA("Model") or arg2:IsA("BasePart")) then
						local v45 = fn67(arg2.Name)
						flag36 = v45 == str10

						if not flag36 then
							flag36 = arg == "npc_fish_seller"

							if flag36 then
								flag36 = v45 == "nana" or v45 == "seller" or v45 == "fishseller" or v45 == "npcfishseller"
							end
						end

						flag36 = flag36 and arg2:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
					end

					if flag36 then
						local v45 = fn68(arg2)

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

				local tbl12 = {}

				pcall(function()
					tbl12 = CollectionService:GetTagged("Interactive")
				end)

				for _, v45 in ipairs(tbl12) do
					fn70(v45, false)
				end

				if not v43 then
					local descendants = workspace:GetDescendants()

					for _, descendant in ipairs(descendants) do
						fn70(descendant, false)
					end

					if not v43 then
						for _, descendant in ipairs(descendants) do
							fn70(descendant, true)
						end
					end
				end

				return v43, v44
			end

			local function fn70(arg, arg2)
				local v42 = fn53()
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

			fn58 = function(arg)
				local reeling = FishingEnums.State.Reeling

				if fn54() == reeling and resumeSoldFish then
					if arg then
						lib:Notify({
							Title = text("Finishing Current Fish"),
							Content = text("The sale will start when the current fight ends."),
							Duration = 4,
						})
					end

					local n26 = os.clock() + 35

					while true do
						if flag11 and os.clock() < n26 then
							local reeling2 = FishingEnums.State.Reeling
							if fn54() == reeling2 then
								task.wait(0.1)
								continue
							end
						end

						break
					end
				end

				local v42 = fn54()

				if v42 == FishingEnums.State.Caught then
					local n26 = os.clock() + 3

					while true do
						local flag36 = flag11 and os.clock() < n26
						local flag37

						if flag36 then
							local caught = FishingEnums.State.Caught
							flag37 = fn54() == caught
						else
							flag37 = flag36
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
					local flag36 = flag11 and os.clock() < n26
					local flag37

					if flag36 then
						local idling2 = FishingEnums.State.Idling
						flag37 = fn54() ~= idling2
					else
						flag37 = flag36
					end

					if flag37 then
						local caught = FishingEnums.State.Caught

						if fn54() == caught and fn47 then
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
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				character = character and character:FindFirstChild("HumanoidRootPart")

				if humanoid then
					pcall(function()
						humanoid:UnequipTools()
					end)

					task.wait(0.1)

					if humanoid.WalkSpeed < 16 then
						humanoid.WalkSpeed = 16
					end

					if humanoid.JumpPower < 50 then
						humanoid.JumpPower = 50
					end

					if humanoid.JumpHeight < 7.2 then
						humanoid.JumpHeight = 7.2
					end

					humanoid.AutoRotate = true
				end

				if character then
					character.Anchored = false
				end

				pcall(function()
					local playerModule = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")

					if playerModule then
						require(playerModule):GetControls():Enable()
					end
				end)
			end

			local function fn71(arg, arg2, arg3)
				local n26 = tonumber(arg) or 0
				local n27 = tonumber(arg2) or 0
				n20 += n26

				lib:Notify({
					Title = text("Fish Sold"),
					Content = string.format(text("+%s Coins (%d Fish) • %s"), fn56(n26), n27, arg3),
					Duration = 3,
				})

				return true, SellEnums.Status.Ok, n26, n27, arg3
			end

			tbl8.teleportTo = function(cFrame3)
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
					return false, "CharacterNotReady"
				end
				humanoidRootPart.CFrame = cFrame3
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				task.wait(0.2)
				if localPlayer.Character ~= character or not humanoidRootPart.Parent or humanoid.Health <= 0 then
					return false, "CharacterNotReady"
				end

				if (humanoidRootPart.Position - cFrame3.Position).Magnitude > 4 then
					return false, "PositionCorrected"
				end

				if not tbl8.hasSolidGroundUnder(humanoidRootPart, character) then
					return false, "NoSafeRoute"
				end
				return true, "Teleported"
			end

			tbl8.moveTo = function(arg, arg2)
				if tbl8.method == "Teleport Instant" then
					return tbl8.teleportTo(arg)
				end

				if tbl8.method == "Tween" then
					local v42, v43 = tweenTo(arg, nil, tbl8.tweenSpeed, arg2)
					if v42 or not arg2 then
						return v42, v43
					end
					local v44, v45 = walkTo(arg)
					if v44 then
						return true, "WalkReturn"
					end
					return false, v45 or v43
				end

				return walkTo(arg)
			end

			tbl8.merchantCandidates = function(arg)
				local v42 = fn53()
				if not v42 then
					return nil
				end
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { v42.Parent }
				raycastParams.RespectCanCollide = true
				local tbl12 = {}
				local vector = Vector3.new(v42.Position.X - arg.X, 0, v42.Position.Z - arg.Z)
				local n26 = vector.Magnitude > 0.1 and math.atan2(vector.Z, vector.X) or 0

				for _, v43 in ipairs({ 6, 9, 13, 17 }) do
					for i = 0, 7 do
						local n27 = n26 + i * 3.1415926535897931 / 4
						local hit = workspace:Raycast(arg + Vector3.new(math.cos(n27) * v43, 0, math.sin(n27) * v43) + Vector3.new(0, 3, 0), Vector3.new(0, -25, 0), raycastParams)

						if hit and hit.Material ~= Enum.Material.Water then
							local n28 = hit.Position + Vector3.new(0, 3, 0)

							if (n28 - arg).Magnitude <= 20 then
								table.insert(tbl12, {
									cframe = CFrame.new(n28),
									distance = (v42.Position - n28).Magnitude,
									merchantDistance = (n28 - arg).Magnitude,
								})
							end
						end
					end
				end

				table.sort(tbl12, function(arg2, arg3)
					return arg2.distance < arg3.distance
				end)

				return tbl12
			end

			tbl8.walkToMerchant = function(arg)
				local v42 = fn53()
				if not v42 then
					return false, "CharacterNotReady"
				end

				if (v42.Position - arg).Magnitude <= 20 then
					return true, "MerchantInRange"
				end
				local tbl12 = tbl8.merchantCandidates(arg) or {}
				local v43 = fn70(arg, 8)

				if v43 then
					table.insert(tbl12, 1, {
						cframe = v43,
						distance = (v42.Position - v43.Position).Magnitude,
						merchantDistance = (v43.Position - arg).Magnitude,
					})
				end

				local str10 = "NoSafeRoute"

				for i = 1, math.min(#tbl12, 8) do
					local v44, v45 = walkTo(tbl12[i].cframe, function()
						local v44 = fn53()
						if v44 and (v44.Position - arg).Magnitude <= 20 then
							return false
						end
						return true
					end)

					local v46 = fn53()
					if v46 and (v46.Position - arg).Magnitude <= 20 then
						return true, "MerchantInRange"
					end

					if v44 then
						if v46 and (v46.Position - arg).Magnitude <= 20 then
							return true, v45
						end
						str10 = "MerchantOutOfRange"
						continue
					end

					str10 = v45 or str10
					if v45 ~= "NoSafeRoute" and v45 ~= "ArrivalUnconfirmed" and v45 ~= "Cancelled" then
						return false, str10
					end
				end

				local v44 = fn53()
				if v44 and (v44.Position - arg).Magnitude <= 20 then
					return true, "MerchantInRange"
				end
				return false, str10
			end

			tbl8.teleportToMerchant = function(arg)
				local v42 = fn53()
				if not v42 then
					return false, "CharacterNotReady"
				end
				local tbl12 = tbl8.merchantCandidates(arg) or {}

				table.sort(tbl12, function(arg2, arg3)
					if math.abs(arg2.merchantDistance - arg3.merchantDistance) < 1 then
						return arg2.distance < arg3.distance
					end
					return arg2.merchantDistance < arg3.merchantDistance
				end)

				local n26 = 0

				for _, v43 in ipairs(tbl12) do
					local position = v43.cframe.Position
					if not (math.abs(position.Y - arg.Y) <= 8) then
						continue
					end
					n26 += 1
					local teleportTo = tbl8.teleportTo
					local cframe = CFrame.lookAt
					local vector = Vector3.new(arg.X, position.Y, arg.Z)
					local v44, v45 = teleportTo(cframe(position, vector))
					if v42.Parent and (v42.Position - arg).Magnitude <= 20 and (v44 or v45 == "NoSafeRoute" or v45 == "PositionCorrected") then
						return true, "MerchantInRange"
					end

					if v45 == "PositionCorrected" or v45 == "CharacterNotReady" then
						return false, v45
					end

					if n26 >= 3 then
						return false, v45 or "MerchantOutOfRange"
					end
				end

				local v43 = fn70(arg, 6)
				if not v43 then
					return false, "CharacterNotReady"
				end
				local v44, v45 = tbl8.teleportTo(v43)
				if v42.Parent and (v42.Position - arg).Magnitude <= 20 and (v44 or v45 == "NoSafeRoute" or v45 == "PositionCorrected") then
					return true, "MerchantInRange"
				end
				return false, v45 or "MerchantOutOfRange"
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
				local flag36 = humanoid and humanoid.Health > 0 and Vector3.new(n26.X, 0, n26.Z).Magnitude <= 4.5 and math.abs(n26.Y) <= 4 and math.abs(arg.AssemblyLinearVelocity.Y) <= 5

				if flag36 then
					local swimming = Enum.HumanoidStateType.Swimming
					flag36 = humanoid:GetState() ~= swimming
				end

				return flag36 and humanoid.FloorMaterial ~= Enum.Material.Water and tbl8.hasSolidGroundUnder(arg, arg2)
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
					result2 = "ReturnFailed"
					result = false
				end

				if result and (tbl8.method == "Walk" or result2 == "WalkReturn") then
					humanoid:MoveTo(v42.Position)
					local n26 = os.clock() + 3

					while flag11 and localPlayer.Character == character and humanoidRootPart.Parent and humanoid.Health > 0 and os.clock() < n26 and not tbl8.atSavedSpot(humanoidRootPart, character, v42) do
						task.wait(0.1)
					end

					if humanoidRootPart.Parent then
						humanoid:MoveTo(humanoidRootPart.Position)
					end
				end

				local v43

				if result then
					if tbl8.method == "Teleport Instant" then
						humanoidRootPart.CFrame = v42
					else
						local rotation = v42.Rotation
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * rotation
					end

					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					for i = 1, 3 do
						task.wait(0.15)

						if not flag11 or not tbl8.atSavedSpot(humanoidRootPart, character, v42) then
							if (humanoidRootPart.Position - v42.Position).Magnitude <= 5 then
								humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							else
								result = false
								result2 = "ReturnPositionChanged"
							end

							break
						end
					end

					v43 = result
				else
					v43 = result
				end

				if not v43 then
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

			fn59 = function(arg)
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

				local npcFishSeller, v42 = fn69("npc_fish_seller")

				if not v42 then
					if flag26 then
						return tbl8.waitForSale("MerchantNotFound")
					end
					return false, "MerchantNotFound", 0, 0
				end

				local v43 = fn53()

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
				local flag36 = false
				v37 = cFrame3

				if not flag26 then
					tbl8.rodId = nil
					local character = localPlayer.Character

					if character then
						for _, child in ipairs(character:GetChildren()) do
							if fn62(child) then
								tbl8.rodId = child.Name
								break
							end
						end
					end
				end

				flag31 = true

				if not pcall(function()
					fn58(arg)

					if (v43.Position - v42).Magnitude > 20 then
						local v44, v45

						if tbl8.method == "Walk" then
							v44, v45 = tbl8.walkToMerchant(v42)
						elseif tbl8.method == "Teleport Instant" then
							v44, v45 = tbl8.teleportToMerchant(v42)
						else
							v44 = fn70(v42, 6)
							v44 = v44 and tbl8.moveTo(v44)
							v45 = nil
						end

						if not v44 then
							str10 = v45 or "TweenFailed"
							error("Unable to reach Fish Merchant")
						end
					end

					local v44 = npcFishSeller:IsDescendantOf(workspace) and fn68(npcFishSeller) or nil

					if not v44 or not v43.Parent or (v43.Position - v44).Magnitude > 20 then
						str10 = "MerchantOutOfRange"
						error("Fish Merchant is not within sell range")
					end

					task.wait(0.5)
					local v45 = npcFishSeller:IsDescendantOf(workspace) and fn68(npcFishSeller) or nil

					if not v45 or not v43.Parent or (v43.Position - v45).Magnitude > 20 then
						str10 = "MerchantOutOfRange"
						error("Fish Merchant is no longer within sell range")
					end

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
						flag36 = true
						local v46, v47, v48 = v30:Fire()
						str10 = v46
						n26 = v47
						n27 = v48
						if str10 == SellEnums.Status.Busy then
							task.wait(0.5)
							continue
						end
						break
					end
				end) then
					if not flag36 then
						local str11 = str10 or "RequestFailed"

						if not v43.Parent or (v43.Position - cFrame3.Position).Magnitude > 1.5 then
							tbl8.tryRestore()
						else
							v37 = nil
						end

						flag31 = false
						return false, str11, 0, 0
					end

					flag31 = false
					return tbl8.waitForSale(str10 or "RequestFailed")
				end

				local flag37 = str10 == SellEnums.Status.Ok
				local flag38 = str10 == SellEnums.Status.Empty

				if str10 == SellEnums.Status.OutOfRange or str10 == SellEnums.Status.NoPass or str10 == SellEnums.Status.Locked then
					flag26 = false
					tbl8.saleAttempts = 0
					tbl8.saleRetryAt = 0
					tbl8.tryRestore()
					flag31 = false
					return false, str10, tonumber(n26) or 0, tonumber(n27) or 0
				end

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
					return fn71(n26, n27, "Fish Merchant")
				end

				if flag38 then
					return false, str10, tonumber(n26) or 0, tonumber(n27) or 0
				end
			end

			local function fn72()
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

			local function fn73(arg, arg2)
				local flag36 = not arg2
				if flag36 and (arg == "PositionCorrected" or arg == "TweenInterrupted" or arg == "TweenFailed") then
					return
				end
				local lastFailureKey = tostring(arg) .. ":" .. tostring(tbl8.pending) .. ":" .. tostring(tbl8.lastReturnReason)
				local now5 = os.clock()
				if flag36 and lastFailureKey == tbl8.lastFailureKey and now5 - tbl8.lastFailureAt < 6 then
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
					local flag37 = tbl8.method == "Walk" and text("No safe walking route to Fish Merchant. Switch to Tween in Auto Sell if fishing on water.") or text("No safe position was found near the Fish Merchant.")
					lib:Notify({ Title = text("Safe Route Unavailable"), Content = flag37, Duration = 4 })
				elseif arg == "PositionCorrected" then
					lib:Notify({
						Title = text("Sell Request Failed"),
						Content = text("The game moved the character away from the Fish Merchant."),
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
						Content = text("The sale could not be completed.") .. " (" .. tostring(arg) .. ")",
						Duration = 4,
					})
				end
			end

			fn60 = function()
				local currentIslandId = nil

				pcall(function()
					local IslandRegionController = client.GetController("IslandRegionController")
					currentIslandId = IslandRegionController and IslandRegionController:GetCurrentIslandId()
				end)

				return currentIslandId
			end

			local function fn74(arg)
				for _, v42 in ipairs(CollectionService:GetTagged("IslandRegion")) do
					if v42:IsA("BasePart") and v42:IsDescendantOf(workspace) and v42:GetAttribute("islandId") == arg then
						return v42
					end
				end

				return nil
			end

			local function fn75(arg)
				local world = workspace:FindFirstChild("World")
				world = world and world:FindFirstChild("Islands")
				world = world and world:FindFirstChild(arg)
				if not world then
					return nil
				end

				for _, v42 in ipairs(CollectionService:GetTagged("Interactive")) do
					if v42:IsDescendantOf(world) then
						local attribute = v42:GetAttribute("InteractiveId")

						if type(attribute) == "string" and attribute:match("^npc_unlock_island_%d+$") then
							local v43 = fn68(v42)
							if v43 then
								return fn70(v43, 6)
							end
						end
					end
				end

				local spawnPoint = world:FindFirstChild("SpawnPoint")
				local v42 = fn66(spawnPoint)
				if v42 then
					return CFrame.new(v42 + Vector3.new(0, 4, 0))
				end

				for _, v43 in ipairs(CollectionService:GetTagged("Interactive")) do
					if v43:IsDescendantOf(world) then
						if v43:GetAttribute("InteractiveId") ~= "npc_fish_seller" then
							continue
						end
						local v44 = fn68(v43)
						if v44 then
							return fn70(v44, 5)
						end
					end
				end

				for _, descendant in ipairs(world:GetDescendants()) do
					if descendant:IsA("BasePart") then
						local v43 = fn67(descendant.Name)
						if v43 == "spawn" or v43 == "spawnpoint" or v43 == "teleportpoint" or v43 == "arrival" then
							return CFrame.new(descendant.Position + Vector3.new(0, 4, 0))
						end
					end
				end

				local v43 = fn74(arg)

				if v43 then
					local n26 = v43.Position + Vector3.new(0, v43.Size.Y * 0.5 + 80, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.RespectCanCollide = true
					local filterDescendantsInstances = { v43 }
					local zones = world:FindFirstChild("Zones")

					if zones then
						table.insert(filterDescendantsInstances, zones)
					end

					if localPlayer.Character then
						table.insert(filterDescendantsInstances, localPlayer.Character)
					end

					raycastParams.FilterDescendantsInstances = filterDescendantsInstances
					local hit = workspace:Raycast(n26, Vector3.new(0, -v43.Size.Y - 250, 0), raycastParams)
					if hit and hit.Instance:IsDescendantOf(world) and hit.Normal.Y > 0.5 then
						return CFrame.new(hit.Position + Vector3.new(0, 4, 0))
					end
				end

				return nil
			end

			local function fn76(arg, arg2)
				local v42 = tbl5[arg]
				if not v42 then
					return false, "IslandNotFound"
				end

				if flag31 or flag25 or tbl8.pending or flag26 then
					return false, "MovementBusy"
				end
				local id = v42.id
				if fn60() == id then
					return false, "AlreadyAtDestination"
				end

				if not fn53() then
					return false, "CharacterNotReady"
				end
				flag31 = true

				local ok, result, result2 = pcall(function()
					fn58()
					if arg2 and not arg2() then
						return false, "Cancelled"
					end
					local v43 = fn75(v42.id)
					local v44

					if not v43 then
						local v45 = fn74(v42.id)

						if v45 then
							pcall(function()
								localPlayer:RequestStreamAroundAsync(v45.Position, 2)
							end)

							v43 = fn75(v42.id)
						end

						v44 = v43
					else
						v44 = v43
					end

					if not v44 then
						return false, "DestinationNotLoaded"
					end
					local v45, v46 = tweenTo(v44, arg2)
					if not v45 then
						return false, v46
					end
					local n26 = os.clock() + 4

					while flag11 and os.clock() < n26 do
						if arg2 and not arg2() then
							return false, "Cancelled"
						end
						local id2 = v42.id

						if fn60() == id2 then
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

			local function fn77()
				n14 += 1
				n12 = 0
				n13 = 0
				flag18 = false
				n15 = 0
			end

			local function fn78()
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
										local tbl12 = { phase = "Casting", remaining = v42.remaining }
										local expiresAt = type(v43) == "table" and v43.expiresAt

										if not expiresAt then
											expiresAt = os.clock() + math.max(tonumber(v42.remaining) or 0, 0.5) + 10
										end

										tbl12.expiresAt = expiresAt
										v44[k] = tbl12
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

			local function fn79()
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

			local function fn80()
				return n13 > 0 and n12 > 0 and n12 <= n13 * finisherPct + 0.001
			end

			local function fn81()
				if flag18 or not flag11 or not flag32 or not flag16 or not tbl10:allowsCurrent() then
					return
				end
				flag18 = true
				local v42 = n14

				task.spawn(function()
					local v43 = fn78()
					local v44, v45, v46 = fn79()

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
								local flag36 = false
								local n28 = nil

								for i = 0, n27 - 1 do
									n28 = ((tbl7.nextIndex or 1) + i - 1) % n27 + 1
									local v49 = order[n28]
									local num = tonumber(v49:match("%d+"))
									local v50 = v44[v49]
									local v51 = tbl7[v49]
									local slotUnlockLevels = v45 and v45.slotUnlockLevels and v45.slotUnlockLevels[num]
									local flag37 = num <= n26 and (not v45 or slotUnlockLevels ~= nil and (v46 == nil or v46 >= slotUnlockLevels))
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
											local flag38 = cooldownActive.phase == "Cooldown"

											if flag38 then
												flag38 = not cooldownActive.endTick

												if not flag38 then
													local endTick = cooldownActive.endTick
													flag38 = tick() < endTick
												end
											end

											if flag38 then
												str10 = "Cooldown"
											end
										end
									end

									if flag37 and type(v50) == "string" and v50 ~= "" then
										if str10 == "Casting" or str10 == "Cooldown" then
											flag36 = true
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
									if flag36 then
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

			local function fn82(arg, arg2)
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

			local function fn83()
				local flag36 = flag33 or not tbl10:allowsCurrent()
				local flag37

				if flag36 then
					flag37 = flag36
				else
					flag37 = not (flag11 and flag13 and flag32)
				end

				if flag37 then
					return
				end
				flag33 = true
				local v42 = n22

				task.spawn(function()
					while true do
						if flag11 and flag13 and flag32 and v42 == n22 and tbl10:allowsCurrent() then
							local v43 = fn54()

							if v43 and v43 ~= FishingEnums.State.Reeling then
								flag32 = false
								break
							else
								if flag16 and fn80() then
									fn81()
									task.wait(0.01)
								else
									if flag16 then
										fn81()
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

			local function fn84()
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

			local function fn85(arg, arg2)
				local flag36 = flag34

				if not flag34 then
					flag36 = not (flag11 and flag12)
				end

				if flag36 or not tbl10:allowsCurrent() then
					return
				end
				flag34 = true
				n23 += 1
				local v42 = n23
				idling = FishingEnums.State.FirstPull

				task.spawn(function()
					local v43, v44 = fn84()
					local n26 = v43 + 0.025
					local oscillateSpeed = FishingConfig.FirstPull and FishingConfig.FirstPull.OscillateSpeed or 2.4
					local num = tonumber(arg2)
					local num2 = tonumber(arg)
					local timeLimit

					if num2 then
						timeLimit = num2
					else
						timeLimit = FishingConfig.FirstPull and FishingConfig.FirstPull.TimeLimit
					end

					timeLimit = timeLimit or 2

					if num then
						timeLimit -= workspace:GetServerTimeNow() - num
					end

					local n27 = os.clock() + math.max(timeLimit - 0.1, 0.05)
					task.wait(0.05)
					local v45 = nil

					while flag11 and flag12 and v42 == n23 and tbl10:allowsCurrent() and os.clock() < n27 do
						local v46 = fn54()

						if v46 == FishingEnums.State.FirstPull then
							local pullBarValue = nil
							local flag37

							if num then
								local n28 = workspace:GetServerTimeNow() - num
								local n29 = math.max(n28, 0) * oscillateSpeed % 2
								pullBarValue = PullBarMath.Position(n28, oscillateSpeed)
								flag37 = n29 <= 1
							else
								pcall(function()
									pullBarValue = FishingController:GetPullBarValue()
								end)

								flag37 = type(pullBarValue) == "number" and v45 and pullBarValue > v45 + 0.001
							end

							if type(pullBarValue) == "number" then
								flag37 = flag37 and pullBarValue >= n26 and pullBarValue <= v44

								if flag37 then
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

					local flag37 = flag11 and flag12 and v42 == n23 and tbl10:allowsCurrent()

					if flag37 then
						local firstPull = FishingEnums.State.FirstPull
						flag37 = fn54() == firstPull
					end

					if flag37 then
						pcall(function()
							FishingPackets.FishFirstPull:Fire()
						end)
					end
				end)
			end

			local function fn86()
				local currentCamera = workspace.CurrentCamera
				local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
				local tbl12 = {}
				local vector2 = Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.92)
				local vector22 = Vector2.new(viewportSize.X * 0.15, viewportSize.Y * 0.82)
				local vector23 = Vector2.new
				local n26 = viewportSize.X * 0.85
				local n27 = viewportSize.Y * 0.82
				tbl12[1] = vector2
				tbl12[2] = vector22

				do
					local values = table.pack(vector23(n26, n27))
					table.move(values, 1, values.n, 3, tbl12)
				end

				for _, v42 in ipairs(tbl12) do
					local tbl13 = {}

					pcall(function()
						tbl13 = playerGui:GetGuiObjectsAtPosition(v42.X, v42.Y)
					end)

					local flag36 = false

					for _, v43 in ipairs(tbl13) do
						while true do
							if v43 and v43 ~= playerGui then
								if v43:GetAttribute("LootItemCard") == true then
									flag36 = true
									break
								else
									v43 = v43.Parent
									continue
								end
							end

							break
						end

						if flag36 then
							break
						end
					end

					if not flag36 then
						return v42
					end
				end

				return tbl12[1]
			end

			fn47 = function()
				local v42 = fn86()

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

			local function fn87()
				local flag36 = flag35

				if not flag35 then
					flag36 = not (flag11 and flag15)
				end

				if flag36 then
					return
				end
				flag35 = true
				local v42 = n24
				local confirmReadyDelay = FishingConfig.Loot and FishingConfig.Loot.ConfirmReadyDelay or 0.75

				task.spawn(function()
					task.wait(confirmReadyDelay + 0.08)
					local n26 = 0

					while true do
						local flag37 = flag11 and flag15 and v42 == n24

						if flag37 then
							local caught = FishingEnums.State.Caught
							flag37 = fn54() == caught
						end

						if flag37 and n26 < 12 then
							if not LootController then
								pcall(function()
									LootController = client.GetController("LootController")
								end)
							end

							local flag38 = false

							if LootController then
								pcall(function()
									flag38 = LootController:IsFishingLootActive()
								end)
							end

							if flag38 then
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
				fn85(arg3, arg4)
			end))

			fn48(FishingPackets.FishReelStartAck.OnClientEvent:Connect(function(currentFishId, arg, arg2)
				if not flag11 then
					return
				end
				tbl10.currentFishId = currentFishId
				if not tbl10:allowsCurrent() then
					return
				end
				fn82(arg, arg2)

				if flag16 then
					fn81()
				end

				if not flag13 then
					return
				end
				fn83()
			end))

			fn48(FishingPackets.FishReelHPUpdate.OnClientEvent:Connect(function(arg)
				if not flag11 or not tbl10:allowsCurrent() then
					return
				end
				n12 = tonumber(arg) or n12

				if fn80() then
					if flag16 then
						fn81()
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
					fn81()
				end
			end))

			fn48(FishingPackets.FishQTEPrompt.OnClientEvent:Connect(function(arg, arg2)
				if not (flag11 and flag14) or not tbl10:allowsCurrent() then
					return
				end
				local v42 = fn50(arg)
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

					local flag36 = state ~= FishingEnums.State.Reeling

					if flag36 then
						flag36 = not (state == nil and flag32)
					end

					if flag36 then
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
				fn77()

				if arg then
					n19 += 1
					n20 += arg3 or 0

					if flag15 then
						fn87()
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
				fn77()
				idling = FishingEnums.State.Idling
				n25 = os.clock() + n7
			end))

			fn48(FishingPackets.FishSkillWindow.OnClientEvent:Connect(function(arg)
				local n26 = math.max(tonumber(arg) or 0, 0)
				n15 = math.max(n15, os.clock() + n26)
			end))

			task.spawn(function()
				local state = 1
				local autoFishing, autoFishing2, autoFishing3, stallTimeoutSec, v42, pending, now5, character, humanoid, flag36, flag37, farmSpotPending, flag38, humanoidRootPart, flag39, humanoidRootPart2, v43, flag40, flag41, currentFishId, n26, n27, v44, v45, flag42, flag43, flag44, now6, max, num

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
							state = 11
						else
							state = 10
						end
					elseif state == 10 then
						stallTimeoutSec = autoFishing3
						state = 12
					elseif state == 11 then
						stallTimeoutSec = FishingConfig.AutoFishing.StallTimeoutSec
						state = 12
					elseif state == 12 then
						if stallTimeoutSec then
							state = 14
						else
							state = 13
						end
					elseif state == 13 then
						stallTimeoutSec = 30
						state = 14
					elseif state == 14 then
						if flag11 then
							state = 16
						else
							state = 15
						end
					elseif state == 15 then
						return
					elseif state == 16 then
						v42 = flag25

						if flag25 then
							state = 18
						else
							state = 17
						end
					elseif state == 17 then
						v42 = flag31
						state = 18
					elseif state == 18 then
						if v42 then
							state = 20
						else
							state = 19
						end
					elseif state == 19 then
						v42 = flag26
						state = 20
					elseif state == 20 then
						if v42 then
							state = 22
						else
							state = 21
						end
					elseif state == 21 then
						pending = tbl8.pending
						state = 23
					elseif state == 22 then
						pending = v42
						state = 23
					elseif state == 23 then
						if pending then
							state = 25
						else
							state = 24
						end
					elseif state == 24 then
						pending = genv.HuneHubBossWaiting
						state = 25
					elseif state == 25 then
						if pending then
							state = 30
						else
							state = 26
						end
					elseif state == 26 then
						pending = flag21

						if flag21 then
							state = 27
						else
							state = 28
						end
					elseif state == 27 then
						pending = flag22
						state = 28
					elseif state == 28 then
						if pending then
							state = 29
						else
							state = 30
						end
					elseif state == 29 then
						pending = not tbl8.resumeFarm
						state = 30
					elseif state == 30 then
						if pending then
							state = 132
						else
							state = 31
						end
					elseif state == 31 then
						if not resumeSoldFish then
							state = 131
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
						flag36 = not character

						if flag36 then
							state = 37
						else
							state = 36
						end
					elseif state == 36 then
						flag37 = not humanoid
						state = 38
					elseif state == 37 then
						flag37 = flag36
						state = 38
					elseif state == 38 then
						if flag37 then
							state = 40
						else
							state = 39
						end
					elseif state == 39 then
						flag37 = humanoid.Health <= 0
						state = 40
					elseif state == 40 then
						if flag37 then
							state = 130
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
						flag38 = not cFrame2
						state = 45
					elseif state == 44 then
						flag38 = farmSpotPending
						state = 45
					elseif state == 45 then
						if flag38 then
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
						flag39 = flag30

						if flag30 then
							state = 51
						else
							state = 52
						end
					elseif state == 51 then
						flag39 = cFrame
						state = 52
					elseif state == 52 then
						if flag39 then
							state = 53
						else
							state = 54
						end
					elseif state == 53 then
						flag39 = not flag31
						state = 54
					elseif state == 54 then
						if flag39 then
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
						v43 = fn54()

						if v43 == v38 then
							state = 63
						else
							state = 59
						end
					elseif state == 59 then
						local v46 = v38
						v38 = v43
						now4 = now5
						flag40 = v46 == FishingEnums.State.FirstPull

						if flag40 then
							state = 60
						else
							state = 61
						end
					elseif state == 60 then
						flag40 = v43 ~= FishingEnums.State.FirstPull
						state = 61
					elseif state == 61 then
						if flag40 then
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
						flag41 = v43 == FishingEnums.State.Holding

						if flag41 then
							state = 66
						else
							state = 65
						end
					elseif state == 65 then
						flag41 = v43 == FishingEnums.State.Throwing
						state = 66
					elseif state == 66 then
						if flag41 then
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
						if v43 ~= FishingEnums.State.Escaped then
							state = 106
						else
							state = 72
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
						fn87()
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
						fn82(n26, n27)
						state = 85
					elseif state == 85 then
						fn83()
						state = 106
					elseif state == 86 then
						task.wait(0.05)
						state = 14
					elseif state == 87 then
						tbl10:skipCurrent()
						task.wait(0.05)
						state = 14
					elseif state == 88 then
						idling = v43

						if tbl10.skipPending then
							state = 90
						else
							state = 89
						end
					elseif state == 89 then
						fn85()
						state = 106
					elseif state == 90 then
						tbl10:skipCurrent()
						state = 106
					elseif state == 91 then
						idling = v43

						if now5 - now4 >= stallTimeoutSec then
							state = 92
						else
							state = 106
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
						state = 14
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
						v44 = fn55()

						if v44 then
							state = 102
						else
							state = 103
						end
					elseif state == 102 then
						v44 = fn65()
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
						state = 14
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
						state = 14
					elseif state == 110 then
						if not (tbl8.resumeAt <= now5) then
							state = 129
						else
							state = 111
						end
					elseif state == 111 then
						if tbl8.resumeStage == 0 then
							state = 128
						else
							state = 112
						end
					elseif state == 112 then
						v45 = fn54()
						flag42 = v45 ~= FishingEnums.State.Idling

						if flag42 then
							state = 113
						else
							state = 114
						end
					elseif state == 113 then
						flag42 = v45 ~= nil
						state = 114
					elseif state == 114 then
						if flag42 then
							state = 116
						else
							state = 115
						end
					elseif state == 115 then
						flag43 = flag42
						state = 117
					elseif state == 116 then
						flag43 = now5 - tbl8.resumeCancelAt >= 2
						state = 117
					elseif state == 117 then
						if flag43 then
							state = 127
						else
							state = 118
						end
					elseif state == 118 then
						flag44 = fn55(tbl8.rodId)

						if flag44 then
							state = 119
						else
							state = 120
						end
					elseif state == 119 then
						local idling2 = FishingEnums.State.Idling
						flag44 = fn54() == idling2
						state = 120
					elseif state == 120 then
						if flag44 then
							state = 122
						else
							state = 121
						end
					elseif state == 121 then
						tbl8.resumeAt = os.clock() + 0.5
						state = 129
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
						num = 0.35
						state = 126
					elseif state == 126 then
						n25 = now6 + max(num, 0.3)
						state = 129
					elseif state == 127 then
						tbl8.resumeCancelAt = now5

						pcall(function()
							FishingPackets.FishCancel:Fire()
						end)

						pcall(function()
							humanoid:UnequipTools()
						end)

						tbl8.resumeAt = os.clock() + 0.35
						state = 129
					elseif state == 128 then
						pcall(function()
							humanoid:UnequipTools()
						end)

						tbl8.resumeStage = 1
						tbl8.resumeAt = os.clock() + 0.25
						v38 = nil
						state = 129
					elseif state == 129 then
						task.wait(0.1)
						state = 14
					elseif state == 130 then
						task.wait(0.2)
						state = 14
					elseif state == 131 then
						v38 = nil
						task.wait(0.1)
						state = 14
					elseif state == 132 then
						v38 = nil
						task.wait(0.1)
						state = 14
					end
				end
			end)

			task.spawn(function()
				while flag11 do
					task.wait(1)
					local flag36 = flag21

					if flag21 then
						local bagRefreshAfter = tbl8.bagRefreshAfter
						flag36 = os.clock() >= bagRefreshAfter
					end

					if flag36 then
						local v42 = fn72()

						if v42 ~= nil then
							flag22 = v42

							if not v42 then
								flag23 = false
							end
						end
					end

					if tbl8.pending then
						local flag37 = flag11 and not flag25 and not flag31

						if flag37 then
							local retryAt = tbl8.retryAt
							flag37 = os.clock() >= retryAt
						end

						if flag37 then
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
						local flag37 = flag26 and v37 and not flag25 and not flag31

						if flag37 then
							local saleRetryAt = tbl8.saleRetryAt
							flag37 = os.clock() >= saleRetryAt
						end

						if flag37 then
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
									local flag38 = v37 and not tbl8.pending
									result = false
									result2 = "RequestFailed"

									if flag38 then
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
										fn73(result2)
									end

									n16 = os.clock() + 12
								end

								flag25 = false
							end)
						elseif flag20 and not flag24 and not flag25 and not flag31 then
							n18 += 1

							if n17 <= n18 then
								n18 = 0
								flag25 = true

								task.spawn(function()
									local ok, result, result2 = pcall(fn59)

									if not ok then
										local flag38 = v37 and not tbl8.pending
										result2 = "RequestFailed"
										result = false

										if flag38 then
											result, result2 = tbl8.waitForSale("RequestFailed")
										end
									end

									if result or result2 == SellEnums.Status.Empty then
										flag23 = true
									end

									if not result and result2 ~= SellEnums.Status.Empty and not flag26 then
										fn73(result2)
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

			fn61 = function()
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

			local function fn88()
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
					fn61()

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

			v39 = fn88()
			v39:SetBackgroundImage("rbxthumb://type=Asset&id=121962960881141&w=150&h=150")
			v39:SetToggleKey(Enum.KeyCode.RightControl)
			configManager = v39.ConfigManager
			v39:Tag({ Title = text("2.0"), Icon = "code", Color = Color3.fromHex("#FFD84A"), Radius = 6 })

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

			genv.HuneHubFishingMaster = { Window = v39, Unload = fn61 }
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

			local function fn89()
				local ok, result = pcall(function()
					local request_3 = syn and syn.request or http and http.request or request
					if not request_3 then
						return nil
					end

					local v42 = request_3({
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

			local v42 = fn89()
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
						local v43 = fn53()
						tbl8.farmSpotPending = true

						if v43 and not flag31 and not flag25 and not flag26 and not tbl8.pending then
							cFrame2 = v43.CFrame

							if flag30 then
								cFrame = cFrame2
							end

							tbl8.farmSpotPending = false
						end

						fn55()
						n25 = 0
						v38 = nil
						idling = fn54() or FishingEnums.State.Idling

						if idling == FishingEnums.State.Caught then
							fn87()
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
						idling = fn54() or FishingEnums.State.Idling

						lib:Notify({
							Title = text("Auto Farm Disabled"),
							Content = text("The complete fishing cycle has stopped."),
							Duration = 2,
						})
					end
				end,
			})

			local v43 = FarmTab:Toggle({
				Title = text("Auto Skill + Low HP"),
				Default = false,
				Flag = "AutoSkill",
				Callback = function(arg)
					flag16 = arg

					if arg and flag32 then
						fn81()
					end
				end,
			})

			FarmTab:Input({
				Title = text("Skill Combo (Z,X,C,V)"),
				Desc = text("Enter Skills In Order, Separated By Commas. Omit A Key To Skip It."),
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
					local v44 = fn54()

					if v44 == FishingEnums.State.FirstPull or v44 == FishingEnums.State.Reeling then
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
						local v44 = fn54()

						if v44 == FishingEnums.State.FirstPull or v44 == FishingEnums.State.Reeling then
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
						local v44 = fn53()

						if v44 then
							cFrame = v44.CFrame

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
					local v44 = flag25
					local v45

					if flag25 then
						v45 = v44
					else
						v45 = flag31
					end

					if v45 or flag26 or tbl8.pending then
						lib:Notify({
							Title = text("Position Not Saved"),
							Content = text("Wait for the current movement to finish."),
							Duration = 3,
						})

						return
					end

					local v46 = fn53()

					if v46 then
						cFrame2 = v46.CFrame
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
							local v44, v45 = walkTo(cFrame2)
							flag31 = false

							lib:Notify({
								Title = v44 and "Position Reached" or "Safe Route Unavailable",
								Content = v44 and "Walked to the saved fishing position." or tostring(v45),
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
				Values = { "Walk", "Tween", "Teleport Instant" },
				Default = "Walk",
				Multi = false,
				Flag = "SellTravelMethodV2",
				Callback = function(method)
					if method ~= "Walk" and method ~= "Tween" and method ~= "Teleport Instant" then
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
					lib:Notify({ Title = text("Selling Fish"), Content = text("Moving to the nearest Fish Merchant."), Duration = 2 })

					task.spawn(function()
						local ok, result, result2 = pcall(fn59, true)

						if not ok then
							local flag36 = v37 and not tbl8.pending
							result2 = "RequestFailed"
							result = false

							if flag36 then
								result, result2 = tbl8.waitForSale("RequestFailed")
							end
						end

						if result2 == "ReturnCompleted" then
							lib:Notify({
								Title = text("Fishing Position Restored"),
								Content = text("Returned to the saved fishing spot."),
								Duration = 3,
							})
						elseif not result then
							if flag26 then
								lib:Notify({
									Title = text("Sell Pending"),
									Content = text("The sale has not been confirmed. The script will retry."),
									Duration = 4,
								})
							else
								fn73(result2, true)
							end
						end

						flag25 = false
					end)
				end,
			})

			local function fn90()
				TeleTab:Section({ Title = text("Island Unlock") })
				local str11 = tbl5["Starter Island"] and "Starter Island" or tbl6[1]
				local flag36 = false

				local tbl12 = {
					[4] = "Bring 3 Legendary Fish From Desert Island",
					[5] = "Bring Frozen Crown Dragonfish, Frosttusk Seal, And Frostmaw Monster From Snow Island",
					[6] = "Bring Ancient Trihorn Fish (1,200 Kg), Stormblade Shark (2,000 Kg), And Lavascale Dragonfish (2,500 Kg) From Volcanic Island",
				}

				local function fn91()
					local v44

					pcall(function()
						v44 = PlayerDataV2Controller:Fetch(localPlayer)
					end)

					return v44
				end

				local function fn92(arg, arg2)
					local v44 = IslandConfig[arg.id]
					return arg.defaultUnlocked or v44 and v44.defaultUnlocked == true or arg2 and arg2.UnlockedIslands and arg2.UnlockedIslands[arg.id] == true
				end

				local function fn93()
					local v44 = tbl5[str11]
					if not v44 then
						return text("Select An Island.")
					end
					local v45 = fn91()
					if not v45 then
						return text("Player Data Is Not Ready.")
					end

					if fn92(v44, v45) then
						return v44.name .. text(" Is Unlocked.")
					end
					local tbl13 = IslandConfig[v44.id] or {}
					local v46 = fn56(tbl13.unlockCost or 0)
					local v47 = tbl12[v44.order]
					local str12 = "unlock_island_" .. v44.order
					local current = v45 and v45.Quest and v45.Quest.Current
					current = current and current.Id == str12 and text("Quest Active") or text("Quest Not Started")
					local str13 = text("Level ") .. tostring(tbl13.requiredLevel or 1) .. text("; Cost: ") .. v46 .. text(" Coins")

					if v47 then
						str13 ..= "; " .. text(v47)
					end

					return str13 .. text(". Status: ") .. current .. "."
				end

				local v44 = nil

				local function fn94()
					if v44 and v44.SetDesc then
						v44:SetDesc(fn93())
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
						fn94()
					end,
				})

				v44 = TeleTab:Paragraph({ Title = text("Unlock Requirements"), Desc = fn93() })

				TeleTab:Button({
					Title = text("Start Island Unlock Quest"),
					Callback = function()
						if flag36 then
							return
						end
						local v45 = tbl5[str11]
						if not v45 then
							return
						end
						local v46 = fn91()
						if not v46 then
							lib:Notify({ Title = text("Island Unlock"), Content = text("Player Data Is Not Ready."), Duration = 3 })
							return
						end

						if fn92(v45, v46) then
							lib:Notify({
								Title = text("Island Unlocked"),
								Content = v45.name .. text(" Is Already Unlocked."),
								Duration = 3,
							})

							return
						end

						local v47 = tbl5[tbl6[v45.order - 1]]

						if v47 and not fn92(v47, v46) then
							local name = v47.name

							lib:Notify({
								Title = text("Previous Island Locked"),
								Content = text("Unlock ") .. name .. text(" First."),
								Duration = 4,
							})

							return
						end

						local str12 = "unlock_island_" .. v45.order
						local current = v46.Quest and v46.Quest.Current

						if current and current.Id == str12 then
							lib:Notify({
								Title = text("Quest Active"),
								Content = v45.name .. text(" Unlock Quest Is Already Active."),
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

						flag36 = true

						task.spawn(function()
							local ok, result, result2 = pcall(function()
								return client.GetController("QuestController"):Accept(str12)
							end)

							flag36 = false
							fn94()
							local v48 = lib
							local notify2 = v48.Notify
							local tbl13 = { Title = ok and result and "Unlock Quest Started" or "Unlock Quest Failed" }

							if ok then
								ok = result and "Collect The Requirements For " .. v45.name .. "."

								if not ok then
									ok = tostring(result2 or "Requirements Not Met.")
								end
							end

							tbl13.Content = ok or "Quest Controller Is Not Ready."
							tbl13.Duration = 4
							notify2(v48, tbl13)
						end)
					end,
				})

				TeleTab:Button({
					Title = text("Unlock Selected Island"),
					Callback = function()
						if flag36 then
							return
						end
						local v45 = tbl5[str11]
						if not v45 then
							return
						end
						local v46 = fn91()
						if not v46 then
							lib:Notify({ Title = text("Island Unlock"), Content = text("Player Data Is Not Ready."), Duration = 3 })
							return
						end

						if fn92(v45, v46) then
							lib:Notify({
								Title = text("Island Unlocked"),
								Content = v45.name .. text(" Is Already Unlocked."),
								Duration = 3,
							})

							return
						end

						local str12 = "unlock_island_" .. v45.order
						local current = v46.Quest and v46.Quest.Current

						if not current or current.Id ~= str12 then
							local name = v45.name

							lib:Notify({
								Title = text("Quest Required"),
								Content = text("Start The ") .. name .. text(" Unlock Quest First."),
								Duration = 4,
							})

							return
						end

						flag36 = true

						task.spawn(function()
							local ok, result, result2 = pcall(function()
								return client.GetController("QuestController"):Complete(str12)
							end)

							flag36 = false
							fn94()
							local v47 = lib
							local notify2 = v47.Notify
							local tbl13 = { Title = ok and result and "Island Unlocked" or "Unlock Requirements Missing" }

							if ok then
								ok = result and v45.name .. " Is Now Unlocked."

								if not ok then
									ok = tostring(result2 or "Check The Quest Requirements.")
								end
							end

							tbl13.Content = ok or "Quest Controller Is Not Ready."
							tbl13.Duration = 4
							notify2(v47, tbl13)
						end)
					end,
				})

				TeleTab:Button({ Title = text("Refresh Unlock Status"), Callback = fn94 })
				TeleTab:Section({ Title = text("Island Travel") })

				local function fn95()
					local TweenService = game:GetService("TweenService")
					local CoreGui = game:GetService("CoreGui")
					local StarterGui = game:GetService("StarterGui")
					local v45 = localPlayer
					local v46 = playerGui

					if type(genv.HuneHubInstantTP) == "table" and type(genv.HuneHubInstantTP.Stop) == "function" then
						pcall(genv.HuneHubInstantTP.Stop)
					end

					local str12 = "rbxthumb://type=Asset&id=121962960881141&w=150&h=150"
					local n26 = 0.75
					local vector = Vector3.new(0, 3, 0)

					local tbl13 = {
						{ name = "Starter Island", pos = Vector3.new(-111.63, 12.05, 328.32) },
						{ name = "Jungle Island", pos = Vector3.new(-1208.78, 10.11, -132.93) },
						{ name = "Desert Island", pos = Vector3.new(-24.45, 9.77, -1066.15) },
						{ name = "Snow Island", pos = Vector3.new(1240.44, 9.72, -309.4) },
						{ name = "Volcano Island", pos = Vector3.new(1874.55, 13.12, 1063.6) },
						{ name = "Fossil Island", pos = Vector3.new(-574.39, 13.87, 2296.03) },
					}

					if genv.HuneHubPreviousSession then
						local character = v45.Character
						local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
						character = character and character:FindFirstChildOfClass("Humanoid")

						if humanoidRootPart and character then
							for _, v47 in ipairs(tbl13) do
								if (humanoidRootPart.Position - v47.pos - vector).Magnitude <= 18 then
									if humanoidRootPart.Anchored or character.WalkSpeed == 0 and character.JumpPower == 0 and character.JumpHeight == 0 and not character.AutoRotate then
										humanoidRootPart.Anchored = false

										if character.WalkSpeed == 0 then
											character.WalkSpeed = 16
										end

										if character.JumpPower == 0 then
											character.JumpPower = 50
										end

										if character.JumpHeight == 0 then
											character.JumpHeight = 7.2
										end

										character.AutoRotate = true

										pcall(function()
											local playerModule = v45.PlayerScripts:FindFirstChild("PlayerModule")

											if playerModule then
												require(playerModule):GetControls():Enable()
											end
										end)
									end

									break
								end
							end
						end
					end

					genv.HuneHubPreviousSession = nil

					local tbl14 = {
						background = Color3.fromRGB(14, 20, 28),
						panel = Color3.fromRGB(22, 30, 39),
						row = Color3.fromRGB(34, 43, 52),
						selected = Color3.fromRGB(28, 83, 72),
						mint = Color3.fromRGB(101, 245, 179),
						white = Color3.fromRGB(243, 249, 251),
						muted = Color3.fromRGB(153, 172, 182),
						gold = Color3.fromRGB(255, 207, 94),
						cyan = Color3.fromRGB(91, 204, 221),
					}

					local function fn96(arg, arg2, parent)
						local instance = Instance.new(arg)

						for k, v47 in pairs(arg2) do
							instance[k] = v47
						end

						instance.Parent = parent
						return instance
					end

					local function fn97(arg, arg2)
						fn96("UICorner", { CornerRadius = UDim.new(0, arg2) }, arg)
					end

					local tbl15 = {}

					tbl15.title = pcall(function()
						return Enum.Font.MontserratBlack
					end) and Enum.Font.MontserratBlack or Enum.Font.GothamBlack

					tbl15.header = pcall(function()
						return Enum.Font.MontserratBold
					end) and Enum.Font.MontserratBold or Enum.Font.GothamBold

					tbl15.body = pcall(function()
						return Enum.Font.MontserratMedium
					end) and Enum.Font.MontserratMedium or Enum.Font.GothamMedium

					tbl15.regular = pcall(function()
						return Enum.Font.Montserrat
					end) and Enum.Font.Montserrat or Enum.Font.Gotham

					tbl15.code = pcall(function()
						return Enum.Font.RobotoMono
					end) and Enum.Font.RobotoMono or Enum.Font.GothamBold

					local function fn98(arg, arg2, arg3)
						return fn96("UIStroke", {
							Color = arg3 or Color3.fromRGB(0, 0, 0),
							Thickness = 1,
							Transparency = arg2 or 0.75,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
						}, arg)
					end

					local tbl16 = {}
					local flag37 = true
					local v47 = nil
					local flag38 = false
					local v48 = nil
					local tbl17 = {}
					local tbl18 = {}
					local v49 = nil

					local function fn99()
						local ok, result = pcall(function()
							return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
						end)

						if not ok then
							return
						end
						v49 = result

						pcall(function()
							StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
						end)
					end

					local function fn100()
						if v49 == nil then
							return
						end
						local v50 = v49
						v49 = nil

						pcall(function()
							StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, v50)
						end)
					end

					local function fn101(arg, arg2)
						pcall(function()
							arg2.BreakJointsOnDeath = false
						end)

						local connection = nil

						connection = arg2.Died:Connect(function()
							connection:Disconnect()

							task.defer(function()
								if not flag37 or not arg.Parent then
									return
								end

								for _, descendant in ipairs(arg:GetDescendants()) do
									if descendant:IsA("BasePart") then
										descendant.Anchored = true
										descendant.CanCollide = false
									end
								end
							end)
						end)

						table.insert(tbl16, connection)
					end

					local function fn102()
						for _, v50 in ipairs(tbl18) do
							pcall(function()
								v50:Disconnect()
							end)
						end

						table.clear(tbl18)

						for _, v50 in ipairs(tbl17) do
							pcall(function()
								v50:Cancel()
							end)
						end

						table.clear(tbl17)

						if v48 then
							v48:Destroy()
							v48 = nil
						end
					end

					local function fn103(arg)
						fn102()

						local ScreenGui = fn96("ScreenGui", {
							Name = "HuneHubTravelOverlay",
							ResetOnSpawn = false,
							IgnoreGuiInset = true,
							DisplayOrder = 100000,
							ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
						}, nil)

						if not pcall(function()
							ScreenGui.Parent = CoreGui
						end) then
							ScreenGui.Parent = v46
						end

						v48 = ScreenGui

						local Frame = fn96("Frame", {
							Size = UDim2.fromScale(1, 1),
							BackgroundColor3 = tbl14.background,
							BorderSizePixel = 0,
							ClipsDescendants = true,
							Active = true,
							ZIndex = 1,
						}, ScreenGui)

						local v50 = fn96
						local tbl19 = { Rotation = 35 }
						local colorSequence = ColorSequence.new
						local tbl20 = {}
						local v51 = ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 15, 24))
						local v52 = ColorSequenceKeypoint.new(0.55, Color3.fromRGB(17, 37, 43))
						local new = ColorSequenceKeypoint.new
						local color7 = Color3.fromRGB
						tbl20[1] = v51
						tbl20[2] = v52

						do
							local values = table.pack(new(1, color7(9, 17, 28)))
							table.move(values, 1, values.n, 3, tbl20)
						end

						tbl19.Color = colorSequence(tbl20)
						v50("UIGradient", tbl19, Frame)

						local Frame2 = fn96("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1.15, 1.3),
							BackgroundColor3 = Color3.fromRGB(27, 66, 69),
							BorderSizePixel = 0,
							ZIndex = 2,
						}, Frame)

						local v53 = fn96
						local tbl21 = { Rotation = 32 }
						local numberSequence = NumberSequence.new
						local tbl22 = {}
						local v54 = NumberSequenceKeypoint.new(0, 1)
						local v55 = NumberSequenceKeypoint.new(0.5, 0.69)
						local new2 = NumberSequenceKeypoint.new
						tbl22[1] = v54
						tbl22[2] = v55

						do
							local values = table.pack(new2(1, 1))
							table.move(values, 1, values.n, 3, tbl22)
						end

						tbl21.Transparency = numberSequence(tbl22)
						v53("UIGradient", tbl21, Frame2)
						TweenService:Create(Frame2, TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.fromScale(0.54, 0.5) }):Play()
						local tbl23 = {}

						for _, v56 in ipairs({
							{ diameter = 470, color = tbl14.cyan, speed = 34, strokeTrans = 0.72 },
							{ diameter = 610, color = tbl14.gold, speed = -25, strokeTrans = 0.76 },
							{ diameter = 760, color = tbl14.cyan, speed = 17, strokeTrans = 0.8 },
						}) do
							local Frame3 = fn96("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromOffset(v56.diameter, v56.diameter),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ZIndex = 2,
							}, Frame)

							fn97(Frame3, v56.diameter)
							local UIStroke = fn96("UIStroke", { Color = v56.color, Thickness = 1.2, Transparency = v56.strokeTrans }, Frame3)
							local v57 = fn96
							local tbl24 = {}
							local numberSequence2 = NumberSequence.new
							local tbl25 = {}
							local v58 = NumberSequenceKeypoint.new(0, 0)
							local v59 = NumberSequenceKeypoint.new(0.35, 0.3)
							local v60 = NumberSequenceKeypoint.new(0.7, 0.95)
							tbl25[1] = v58
							tbl25[2] = v59
							tbl25[3] = v60

							do
								local values = table.pack(NumberSequenceKeypoint.new(1, 1))
								table.move(values, 1, values.n, 4, tbl25)
							end

							tbl24.Transparency = numberSequence2(tbl25)
							v57("UIGradient", tbl24, UIStroke)

							fn97(fn96("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0, 0),
								Size = UDim2.fromOffset(5, 5),
								BackgroundColor3 = v56.color,
								BorderSizePixel = 0,
								ZIndex = 3,
							}, Frame3), 3)

							table.insert(tbl23, { frame = Frame3, speed = v56.speed })
						end

						local Frame3 = fn96("Frame", {
							Position = UDim2.new(-0.24, 0, 0, 0),
							Size = UDim2.new(0.18, 0, 1, 0),
							BackgroundColor3 = tbl14.cyan,
							BorderSizePixel = 0,
							ZIndex = 2,
						}, Frame)

						local v56 = fn96
						local tbl24 = { Rotation = 0 }
						local numberSequence2 = NumberSequence.new
						local tbl25 = {}
						local v57 = NumberSequenceKeypoint.new(0, 1)
						local v58 = NumberSequenceKeypoint.new(0.5, 0.95)
						local new3 = NumberSequenceKeypoint.new
						tbl25[1] = v57
						tbl25[2] = v58

						do
							local values = table.pack(new3(1, 1))
							table.move(values, 1, values.n, 3, tbl25)
						end

						tbl24.Transparency = numberSequence2(tbl25)
						v56("UIGradient", tbl24, Frame3)
						TweenService:Create(Frame3, TweenInfo.new(10, Enum.EasingStyle.Linear), { Position = UDim2.new(1.06, 0, 0, 0) }):Play()

						local Frame4 = fn96("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.54),
							Size = UDim2.new(0.88, 0, 0, 246),
							BackgroundColor3 = tbl14.panel,
							BorderSizePixel = 0,
							ZIndex = 3,
						}, Frame)

						fn97(Frame4, 20)
						fn96("UISizeConstraint", { MaxSize = Vector2.new(460, 246) }, Frame4)
						fn96("UIStroke", { Color = Color3.fromRGB(68, 123, 117), Thickness = 1.5, Transparency = 0.18 }, Frame4)
						TweenService:Create(Frame4, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.49) }):Play()

						local ImageLabel = fn96("ImageLabel", {
							Position = UDim2.fromOffset(24, 24),
							Size = UDim2.fromOffset(52, 52),
							BackgroundColor3 = Color3.fromRGB(31, 65, 56),
							BorderSizePixel = 0,
							Image = str12,
							ScaleType = Enum.ScaleType.Fit,
							ZIndex = 4,
						}, Frame4)

						fn97(ImageLabel, 14)
						fn96("UIStroke", { Color = tbl14.mint, Thickness = 1, Transparency = 0.35 }, ImageLabel)

						local TextLabel = fn96("TextLabel", {
							Position = UDim2.fromOffset(88, 24),
							Size = UDim2.new(1, -112, 0, 52),
							BackgroundTransparency = 1,
							Text = "HUNE HUB",
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Center,
							TextColor3 = tbl14.white,
							Font = tbl15.title,
							TextSize = 28,
							RichText = true,
							ZIndex = 4,
						}, Frame4)

						fn98(TextLabel, 0.7)
						local v59 = fn96
						local tbl26 = {}
						local colorSequence2 = ColorSequence.new
						local tbl27 = {}
						local v60 = ColorSequenceKeypoint.new(0, tbl14.mint)
						local v61 = ColorSequenceKeypoint.new(0.58, tbl14.white)
						local new4 = ColorSequenceKeypoint.new
						local gold = tbl14.gold
						tbl27[1] = v60
						tbl27[2] = v61

						do
							local values = table.pack(new4(1, gold))
							table.move(values, 1, values.n, 3, tbl27)
						end

						tbl26.Color = colorSequence2(tbl27)
						v59("UIGradient", tbl26, TextLabel)

						fn96("Frame", {
							Position = UDim2.fromOffset(24, 88),
							Size = UDim2.new(1, -48, 0, 1),
							BackgroundColor3 = Color3.fromRGB(70, 85, 94),
							BorderSizePixel = 0,
							ZIndex = 4,
						}, Frame4).BackgroundTransparency = 0.35

						local Frame5 = fn96("Frame", {
							Position = UDim2.fromOffset(24, 99),
							Size = UDim2.new(1, -48, 0, 80),
							BackgroundColor3 = Color3.fromRGB(15, 23, 31),
							BackgroundTransparency = 0.5,
							BorderSizePixel = 0,
							ZIndex = 4,
						}, Frame4)

						fn97(Frame5, 12)
						fn96("UIStroke", { Color = Color3.fromRGB(48, 86, 88), Thickness = 1, Transparency = 0.6 }, Frame5)

						fn96("TextLabel", {
							Position = UDim2.fromOffset(20, 9),
							Size = UDim2.new(0.43, 0, 0, 15),
							BackgroundTransparency = 1,
							Text = "Travel",
							TextXAlignment = Enum.TextXAlignment.Left,
							TextColor3 = tbl14.muted,
							Font = tbl15.header,
							TextSize = 10,
							ZIndex = 5,
						}, Frame5)

						fn96("TextLabel", {
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -20, 0, 9),
							Size = UDim2.new(0.52, 0, 0, 15),
							BackgroundTransparency = 1,
							Text = "TO  " .. string.upper(arg),
							TextXAlignment = Enum.TextXAlignment.Right,
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextColor3 = tbl14.gold,
							Font = tbl15.header,
							TextSize = 10,
							ZIndex = 5,
						}, Frame5)

						local Frame6 = fn96("Frame", {
							Position = UDim2.new(0, 25, 0, 48),
							Size = UDim2.new(1, -50, 0, 2),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ZIndex = 5,
						}, Frame5)

						local tbl28 = {}

						for i = 0, 17 do
							local Frame7 = fn96("Frame", {
								Position = UDim2.new(i / 18, 0, 0, 0),
								Size = UDim2.new(0.027777777777777776, 0, 1, 0),
								BackgroundColor3 = tbl14.mint,
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ZIndex = 5,
							}, Frame6)

							fn97(Frame7, 2)
							tbl28[i + 1] = Frame7
						end

						for _, v62 in ipairs({ 25, -25 }) do
							local v63 = fn96

							fn97(v63("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = v62 > 0 and UDim2.new(0, v62, 0, 49) or UDim2.new(1, v62, 0, 49),
								Size = UDim2.fromOffset(8, 8),
								BackgroundColor3 = v62 > 0 and tbl14.cyan or tbl14.gold,
								BorderSizePixel = 0,
								ZIndex = 7,
							}, Frame5), 4)
						end

						local Frame7 = fn96("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0, 25, 0, 49),
							Size = UDim2.fromOffset(46, 36),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ZIndex = 8,
						}, Frame5)

						local tbl29 = {
							{ 43, 18 },
							{ 40, 14 },
							{ 26, 14 },
							{ 18, 3 },
							{ 14, 3 },
							{ 16, 14 },
							{ 10, 14 },
							{ 7, 9 },
							{ 4, 9 },
							{ 5, 16 },
							{ 4, 18 },
							{ 5, 20 },
							{ 4, 27 },
							{ 7, 27 },
							{ 10, 22 },
							{ 16, 22 },
							{ 14, 33 },
							{ 18, 33 },
							{ 26, 22 },
							{ 40, 22 },
							{ 43, 18 },
						}

						for i = 1, #tbl29 - 1 do
							local v62 = tbl29[i]
							local v63 = tbl29[i + 1]
							local n27 = v63[1] - v62[1]
							local n28 = v63[2] - v62[2]

							fn97(fn96("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromOffset((v62[1] + v63[1]) / 2, (v62[2] + v63[2]) / 2),
								Size = UDim2.fromOffset(math.sqrt(n27 * n27 + n28 * n28) + 1, 2.4),
								Rotation = math.deg(math.atan2(n28, n27)),
								BackgroundColor3 = tbl14.mint,
								BorderSizePixel = 0,
								ZIndex = 9,
							}, Frame7), 2)
						end

						local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear)
						local tbl30 = {}

						table.insert(tbl18, Frame7:GetPropertyChangedSignal("Position"):Connect(function()
							local x = Frame6.AbsoluteSize.X
							if x <= 0 then
								return
							end
							local n27 = Frame7.Position.X.Scale * x - 22

							for i, v62 in ipairs(tbl28) do
								local flag39 = ((i - 1) / 18 + 0.027777777777777776) * x <= n27

								if tbl30[i] ~= flag39 then
									tbl30[i] = flag39
									v62.BackgroundTransparency = flag39 and 0.06 or 1
								end
							end
						end))

						local tween = TweenService:Create(Frame7, tweenInfo, { Position = UDim2.new(1, -25, 0, 49) })
						table.insert(tbl17, tween)
						tween:Play()

						local Frame8 = fn96("Frame", {
							Position = UDim2.new(0, 24, 1, -40),
							Size = UDim2.new(1, -48, 0, 5),
							BackgroundColor3 = Color3.fromRGB(46, 61, 67),
							BorderSizePixel = 0,
							ZIndex = 4,
						}, Frame4)

						fn97(Frame8, 4)
						local Frame9 = fn96("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = tbl14.mint, BorderSizePixel = 0, ZIndex = 5 }, Frame8)
						fn97(Frame9, 4)
						fn96("UIGradient", { Color = ColorSequence.new(tbl14.mint, tbl14.gold) }, Frame9)
						TweenService:Create(Frame9, TweenInfo.new(10, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) }):Play()

						local TextLabel2 = fn96("TextLabel", {
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -24, 1, -30),
							Size = UDim2.fromOffset(48, 20),
							BackgroundTransparency = 1,
							Text = tostring(10) .. "s",
							TextXAlignment = Enum.TextXAlignment.Right,
							TextColor3 = tbl14.mint,
							Font = tbl15.header,
							TextSize = 12,
							RichText = true,
							ZIndex = 4,
						}, Frame4)

						fn98(TextLabel2, 0.75)

						fn98(fn96("TextLabel", {
							Position = UDim2.new(0, 24, 1, -30),
							Size = UDim2.new(1, -100, 0, 20),
							BackgroundTransparency = 1,
							Text = "HUNE HUB",
							TextColor3 = tbl14.muted,
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = tbl15.header,
							TextSize = 10,
							RichText = true,
							ZIndex = 4,
						}, Frame4), 0.85)

						for _, v62 in ipairs(tbl23) do
							local v63 = TweenService
							local create = v63.Create
							local frame = v62.frame
							local linear = Enum.EasingStyle.Linear
							local out = Enum.EasingDirection.Out
							local v64 = create(v63, frame, TweenInfo.new(360 / math.abs(v62.speed), linear, out, -1), { Rotation = v62.speed > 0 and 360 or -360 })
							table.insert(tbl17, v64)
							v64:Play()
						end

						return { gui = ScreenGui, base = Frame, card = Frame4, countdown = TextLabel2 }
					end

					local function fn104(arg)
						if not arg or not arg.gui.Parent then
							return
						end
						TweenService:Create(arg.card, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromScale(0.5, 0.55), Size = UDim2.new(0.79, 0, 0, 260) }):Play()
						task.wait(0.23)
						if not arg.gui.Parent then
							return
						end

						local Frame = fn96("Frame", {
							Size = UDim2.fromScale(1, 1),
							BackgroundColor3 = tbl14.cyan,
							BackgroundTransparency = 0.94,
							BorderSizePixel = 0,
							ZIndex = 9,
						}, arg.gui)

						local Frame2 = fn96("Frame", {
							Position = UDim2.fromScale(0, 0),
							Size = UDim2.fromScale(0.505, 1),
							BackgroundColor3 = tbl14.background,
							BorderSizePixel = 0,
							ZIndex = 10,
						}, arg.gui)

						fn96("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(9, 17, 27), Color3.fromRGB(18, 40, 45)) }, Frame2)

						local Frame3 = fn96("Frame", {
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(1, 0),
							Size = UDim2.new(0, 24, 1, 0),
							BackgroundColor3 = tbl14.mint,
							BorderSizePixel = 0,
							ZIndex = 11,
						}, Frame2)

						local new = NumberSequenceKeypoint.new
						fn96("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), new(1, 0.91) }) }, Frame3)

						local Frame4 = fn96("Frame", {
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(1, 0),
							Size = UDim2.new(0, 4, 1, 0),
							BackgroundColor3 = tbl14.mint,
							BorderSizePixel = 0,
							ZIndex = 11,
						}, Frame2)

						fn96("UIGradient", { Color = ColorSequence.new(tbl14.cyan, tbl14.mint), Rotation = 90 }, Frame4)

						local Frame5 = fn96("Frame", {
							Position = UDim2.fromScale(0.495, 0),
							Size = UDim2.fromScale(0.505, 1),
							BackgroundColor3 = tbl14.background,
							BorderSizePixel = 0,
							ZIndex = 10,
						}, arg.gui)

						fn96("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(18, 40, 45), Color3.fromRGB(9, 17, 27)) }, Frame5)
						local Frame6 = fn96("Frame", { Size = UDim2.new(0, 24, 1, 0), BackgroundColor3 = tbl14.gold, BorderSizePixel = 0, ZIndex = 11 }, Frame5)
						local new2 = NumberSequenceKeypoint.new
						fn96("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.91), new2(1, 1) }) }, Frame6)
						local Frame7 = fn96("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = tbl14.gold, BorderSizePixel = 0, ZIndex = 11 }, Frame5)
						fn96("UIGradient", { Color = ColorSequence.new(tbl14.gold, tbl14.mint), Rotation = 90 }, Frame7)
						arg.base.Visible = false
						local tweenInfo = TweenInfo.new(0.86, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
						TweenService:Create(Frame, TweenInfo.new(0.86, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Frame2, tweenInfo, { Position = UDim2.fromScale(-0.51, 0) }):Play()
						TweenService:Create(Frame5, tweenInfo, { Position = UDim2.fromScale(1.01, 0) }):Play()
						task.wait(0.87)

						if v48 == arg.gui then
							fn102()
						end
					end

					local tbl19 = {}

					for _, v50 in ipairs(tbl13) do
						tbl19[v50.name] = v50
					end

					tbl19["Volcanic Island"] = tbl19["Volcano Island"]

					local function fn105(arg, arg2, arg3)
						if not flag37 or v47 ~= arg or arg.finishing then
							return
						end
						arg.finishing = true
						v47 = nil
						flag38 = true

						if arg2 then
							cFrame = nil
							cFrame2 = nil
							v38 = nil
							n25 = os.clock() + 1
						end

						if arg.visual and arg.visual.countdown then
							arg.visual.countdown.Text = ""
						end

						task.spawn(function()
							if arg.visual then
								pcall(fn104, arg.visual)
							end

							fn102()
							fn100()
							flag31 = false
							flag38 = false

							if flag37 and arg.callback then
								pcall(arg.callback, arg2, arg3)
							end
						end)
					end

					local function fn106(arg, character, root)
						if not flag37 or v47 ~= arg or arg.placementPending then
							return
						end
						arg.placementPending = true
						arg.character = character
						arg.root = root
						local landingCFrame = arg.landingCFrame or CFrame.new(arg.island.pos + vector)
						arg.target = landingCFrame
						arg.landed = false

						while flag37 and v47 == arg and arg.placementAttempts < 2 do
							arg.placementAttempts = arg.placementAttempts + 1

							if pcall(function()
								character:PivotTo(landingCFrame)
								root.AssemblyLinearVelocity = Vector3.zero
								root.AssemblyAngularVelocity = Vector3.zero
							end) then
								task.wait(0.75)
								if not flag37 or v47 ~= arg then
									return
								end
								local humanoid = character:FindFirstChildOfClass("Humanoid")
								local n27 = math.max(12, (humanoid and humanoid.WalkSpeed or 16) * n26 + 8)

								if root.Parent and (root.Position - landingCFrame.Position).Magnitude <= n27 then
									arg.landed = true
									arg.placementPending = false

									if arg.minimumElapsed then
										fn105(arg, true, "Arrived at " .. arg.island.name .. ".")
									end

									return
								end
							end

							if arg.placementAttempts < 2 then
								task.wait(0.3)
							end
						end

						arg.placementPending = false

						if flag37 and v47 == arg then
							fn105(arg, false, "Could not confirm the landing after two attempts.")
						end
					end

					local function fn107(arg)
						for i = 10, 1, -1 do
							if not flag37 or v47 ~= arg then
								return
							end

							if arg.visual and arg.visual.countdown then
								arg.visual.countdown.Text = tostring(i) .. "s"
							end

							task.wait(1)
						end

						if not flag37 or v47 ~= arg then
							return
						end
						arg.minimumElapsed = true

						if arg.landed then
							fn105(arg, true, "Arrived at " .. arg.island.name .. ".")
						elseif arg.visual and arg.visual.countdown then
							arg.visual.countdown.Text = "..."
						end
					end

					local function fn108(arg, arg2)
						local humanoidRootPart = arg:WaitForChild("HumanoidRootPart", 10)
						if not humanoidRootPart or not flag37 or v47 ~= arg2 then
							return
						end
						local humanoid = arg:WaitForChild("Humanoid", 10)
						if not humanoid or humanoid.Health <= 0 then
							return
						end
						task.wait(0.15)
						if not flag37 or v47 ~= arg2 or not arg.Parent then
							return
						end
						fn106(arg2, arg, humanoidRootPart)
					end

					local connection = v45.CharacterAdded:Connect(function(character)
						local v50 = v47
						local armed = v47

						if v50 then
							armed = v50.armed
						end

						if armed then
							task.spawn(fn108, character, v50)
						end
					end)

					table.insert(tbl16, connection)

					return {
						Start = function(arg, arg2, arg3)
							if not flag37 then
								return false, "Travel unavailable."
							end

							if v47 or flag38 or flag31 or flag25 or tbl8.pending or flag26 then
								return false, "Movement busy."
							end
							local v50 = tbl19[arg]
							if not v50 then
								return false, "Fixed island position not found."
							end

							if arg3 ~= nil and typeof(arg3) ~= "CFrame" then
								return false, "Invalid landing position."
							end
							local character = v45.Character
							local humanoid = character and character:FindFirstChildOfClass("Humanoid")
							if not humanoid or humanoid.Health <= 0 then
								return false, "Character not ready."
							end

							local tbl20 = {
								island = v50,
								landingCFrame = arg3,
								callback = arg2,
								minimumElapsed = false,
								landed = false,
								armed = false,
								placementAttempts = 0,
							}

							v47 = tbl20
							flag31 = true

							task.spawn(function()
								local ok = pcall(fn58)
								if not flag37 or v47 ~= tbl20 then
									return
								end

								if not ok then
									fn105(tbl20, false, "Could not finish the current fishing action.")
									return
								end
								character = v45.Character
								humanoid = character and character:FindFirstChildOfClass("Humanoid")
								if not humanoid or humanoid.Health <= 0 then
									fn105(tbl20, false, "Character not ready after fishing stopped.")
									return
								end
								local ok2, visual = pcall(fn103, v50.name)
								if not ok2 then
									fn105(tbl20, false, "Could not open the travel transition.")
									return
								end
								tbl20.visual = visual
								fn99()
								pcall(fn101, character, humanoid)
								tbl20.armed = true
								task.spawn(fn107, tbl20)

								task.delay(20, function()
									if v47 == tbl20 then
										if tbl20.placementPending then
											task.delay(4, function()
												if v47 == tbl20 then
													fn105(tbl20, false, "Travel sequence timed out.")
												end
											end)
										elseif tbl20.placementAttempts == 0 then
											local character2 = v45.Character
											local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
											local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")

											if humanoidRootPart and humanoid2 and humanoid2.Health > 0 then
												tbl20.minimumElapsed = true
												task.spawn(fn106, tbl20, character2, humanoidRootPart)
											else
												fn105(tbl20, false, "Travel sequence timed out.")
											end
										else
											fn105(tbl20, false, "Travel sequence timed out.")
										end
									end
								end)

								if not pcall(function()
									humanoid.Health = 0
								end) then
									fn105(tbl20, false, "Could not start the respawn travel.")
								end
							end)

							return true
						end,
						Cancel = function()
							if v47 then
								fn105(v47, false, "Island travel cancelled.")
								return true
							end
							return false
						end,
						Stop = function()
							if not flag37 then
								return
							end
							flag37 = false
							local flag39 = v47 ~= nil or flag38
							v47 = nil
							flag38 = false

							for _, v50 in ipairs(tbl16) do
								pcall(function()
									v50:Disconnect()
								end)
							end

							fn102()
							fn100()

							if flag39 then
								flag31 = false
							end
						end,
					}
				end

				local v45 = fn95()
				fn48({ Disconnect = v45.Stop })

				TeleTab:Button({
					Title = text("Travel To Island"),
					Callback = function()
						local v46 = str11

						local v47, v48 = v45.Start(v46, function(content, arg)
							local v47 = lib
							local notify2 = v47.Notify
							local tbl13 = { Title = content and text("Travel Complete") or text("Travel Failed") }

							if content then
								local str12 = v46 .. "."
								content = text("Arrived at ") .. str12
							end

							tbl13.Content = content or tostring(arg)
							tbl13.Duration = 4
							notify2(v47, tbl13)
						end)

						if not v47 then
							lib:Notify({ Title = text("Travel Failed"), Content = tostring(v48), Duration = 4 })
						end
					end,
				})

				TeleTab:Button({
					Title = text("Stop Island Travel"),
					Callback = function()
						v45.Cancel()
					end,
				})
			end

			fn90()

			local function fn91()
				local QuestConfig = require(data.Config.QuestConfig)
				local RegionConfig = require(data.Config.RegionConfig)
				local BossSpawnerFX = require(ReplicatedStorage.Shared.Lib.BossSpawnerFX)
				local getItemCount = require(ReplicatedStorage.Shared.getItemCount)
				local tbl12 = { text("Auto Detect Quest") }
				local tbl13 = {}

				for k, v44 in pairs(QuestConfig.Data) do
					local str11 = (v44.name or k) .. " [" .. k .. "]"
					tbl13[str11] = k
					table.insert(tbl12, str11)
				end

				table.sort(tbl12)
				local v44 = nil
				local flag36 = false
				local flag37 = false
				local flag38 = true
				local flag39 = false
				local str11 = ""
				local n26 = -math.huge
				local v45 = nil
				local n27 = -math.huge
				local v46 = nil
				local id = nil

				local tbl14 = {
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

				local function fn92(arg, arg2)
					if not arg2 then
						return false
					end
					local v47 = IslandConfig[arg2.id]
					return v47 and v47.defaultUnlocked == true or arg.UnlockedIslands and arg.UnlockedIslands[arg2.id] == true
				end

				local tbl15 = {
					unlock_island_2 = "island_jungle",
					unlock_island_3 = "island_desert",
					unlock_island_4 = "island_snow",
					unlock_island_5 = "island_volcano",
					unlock_island_6 = "island_fossil",
				}

				local function fn93(arg)
					local tbl16 = {}

					for k, v47 in pairs(QuestConfig.Data) do
						local visibleWhenIslandUnlocked = v47.visibleWhenIslandUnlocked
						local v48 = tbl15[k]

						if not ((arg.Quest or {}).Done or {})[k] and (not visibleWhenIslandUnlocked or fn92(arg, Catalog.Island.GetById(visibleWhenIslandUnlocked))) and (not v48 or not fn92(arg, Catalog.Island.GetById(v48))) then
							table.insert(tbl16, { id = k, info = v47 })
						end
					end

					table.sort(tbl16, function(arg2, arg3)
						local tbl17 = { unlock_islands = 1, rods = 2, souls = 3, skills = 4 }
						local n28 = tbl17[arg2.info.questType] or 5
						local n29 = tbl17[arg3.info.questType] or 5
						if n28 ~= n29 then
							return n28 < n29
						end
						local sortOrder = arg2.info.sortOrder or 100
						local sortOrder2 = arg3.info.sortOrder or 100
						return sortOrder == sortOrder2 and arg2.id < arg3.id or sortOrder < sortOrder2
					end)

					return tbl16[1] and tbl16[1].id
				end

				local function fn94()
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

				local function fn95()
					if not flag39 then
						return
					end

					if flag37 then
						return
					end
					flag39 = false

					if not pcall(function()
						FarmToggle:Set(false)
					end) or resumeSoldFish then
						pcall(function()
							FarmToggle:SetValue(false)
						end)
					end
				end

				local function fn96(arg, arg2)
					local n28 = ((arg.Inventory or {}).Books or {})[arg2] or 0
					local v47 = pairs
					local rods = arg.Rods or {}

					for _, rod in v47(rods) do
						local v48 = pairs
						local bookSlots = rod.BookSlots or {}

						for _, bookSlot in v48(bookSlots) do
							if bookSlot == arg2 then
								n28 -= 1
							end
						end
					end

					return math.max(0, n28)
				end

				local function fn97(arg, arg2)
					local v47 = Catalog.Island.GetById(arg2)
					local v48 = pairs
					local fishes = v47 and v47.fishes or {}

					for _, fishe in v48(fishes) do
						if fishe.fishId == arg then
							return true
						end
					end

					return false
				end

				local tbl16 = {
					unlock_island_4 = { "island_desert", "Legendary" },
					heaven_piercer_turtle_rod = { "island_fossil", "Legendary" },
					dread_fish_rod = { "island_fossil", "Mythical" },
					phoenix = { "island_snow", "Legendary" },
					azure_dragon = { "island_volcano", "Legendary" },
					white_tiger = { "island_desert", "Legendary", 1000 },
				}

				local function fn98(arg, arg2)
					local progress = arg2.Progress or {}
					local fishes = (arg.Inventory or {}).Fishes or {}
					local flag40 = type(progress.RequiredCoin) == "number"

					if flag40 then
						flag40 = (arg.Coin or 0) < progress.RequiredCoin
					end

					if flag40 then
						return false
					end

					for _, v47 in ipairs({
						{ "RequiredFished", "CurrentFished" },
						{ "RequiredKills", "CurrentKills" },
						{ "CatchWithSkill", "CurrentUsedSkill" },
					}) do
						local v48 = progress[v47[1]]
						local flag41 = type(v48) == "number"

						if flag41 then
							flag41 = (progress[v47[2]] or 0) < v48
						end

						if flag41 then
							return false
						end
					end

					local flag41 = type(progress.RequiredBamboo) == "number"

					if flag41 then
						local requiredBamboo = progress.RequiredBamboo
						flag41 = getItemCount(arg, "bamboo_fragment") < requiredBamboo
					end

					if flag41 then
						return false
					end

					if type(progress.RequiredFishes) == "table" then
						for k, requiredFishe in pairs(progress.RequiredFishes) do
							local n28 = 0

							for _, fishe in pairs(fishes) do
								local n29 = arg2.Id == "unlock_island_6" and (k == "ancient_trihorn_fish" and 1200 or k == "stormblade_shark" and 2000 or k == "lavascale_dragonfish" and 2500 or 0) or 0
								local flag42 = fishe.fishId == k

								if flag42 then
									flag42 = (fishe.weight or 0) >= n29
								end

								if flag42 then
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
							if fn96(arg, k) < requiredBook then
								return false
							end
						end
					end

					local requiredBookId = progress.RequiredBookId

					if requiredBookId then
						requiredBookId = fn96(arg, progress.RequiredBookId) < (progress.RequiredBookCount or 1)
					end

					if requiredBookId then
						return false
					end
					local v47 = tbl16[arg2.Id]

					if type(progress.RequiredFish) == "number" then
						local n28

						if v47 then
							if arg2.Id == "white_tiger" then
								local v48 = pairs
								local currentFish = progress.CurrentFish or {}
								n28 = 0

								for _, v49 in v48(currentFish) do
									local v50 = fishes[v49]
									local flag42 = v50 and Catalog.Fish.GetById(v50.fishId)
									flag42 = flag42 and flag42.rarity == v47[2]

									if flag42 then
										flag42 = (v50.weight or 0) >= (v47[3] or 0)
									end

									if flag42 and fn97(v50.fishId, v47[1]) then
										n28 += 1
									end
								end
							else
								n28 = 0

								for _, fishe in pairs(fishes) do
									local v48 = Catalog.Fish.GetById(fishe.fishId)

									if v48 and v48.rarity == v47[2] and fn97(fishe.fishId, v47[1]) then
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

				local function fn99(arg, arg2)
					local progress = arg2.Progress or {}
					local fishes = (arg.Inventory or {}).Fishes or {}

					for _, v47 in ipairs({
						{ "RequiredFished", "CurrentFished" },
						{ "RequiredKills", "CurrentKills" },
						{ "CatchWithSkill", "CurrentUsedSkill" },
					}) do
						local v48 = progress[v47[1]]
						local flag40 = type(v48) == "number"

						if flag40 then
							flag40 = (progress[v47[2]] or 0) < v48
						end

						if flag40 then
							return true
						end
					end

					local flag40 = type(progress.RequiredBamboo) == "number"

					if flag40 then
						local requiredBamboo = progress.RequiredBamboo
						flag40 = getItemCount(arg, "bamboo_fragment") < requiredBamboo
					end

					if flag40 then
						return true
					end

					if type(progress.RequiredFishes) == "table" then
						for k, requiredFishe in pairs(progress.RequiredFishes) do
							local n28 = 0

							for _, fishe in pairs(fishes) do
								local n29 = arg2.Id == "unlock_island_6" and (k == "ancient_trihorn_fish" and 1200 or k == "stormblade_shark" and 2000 or k == "lavascale_dragonfish" and 2500 or 0) or 0
								local flag41 = fishe.fishId == k

								if flag41 then
									flag41 = (fishe.weight or 0) >= n29
								end

								if flag41 then
									n28 += 1
								end
							end

							if n28 < requiredFishe then
								return true
							end
						end
					end

					if type(progress.RequiredFish) == "number" then
						local v47 = tbl16[arg2.Id]
						local n28

						if v47 then
							local currentFish = arg2.Id == "white_tiger" and (progress.CurrentFish or {}) or fishes
							n28 = 0

							for _, v48 in pairs(currentFish) do
								local flag41 = arg2.Id == "white_tiger" and fishes[v48] or v48
								local flag42 = flag41 and Catalog.Fish.GetById(flag41.fishId)
								flag42 = flag42 and flag42.rarity == v47[2]
								local flag43

								if flag42 then
									flag43 = (flag41.weight or 0) >= (v47[3] or 0)
								else
									flag43 = flag42
								end

								flag43 = flag43 and fn97(flag41.fishId, v47[1])

								if flag43 then
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
					Values = tbl12,
					Default = text("Auto Detect Quest"),
					Flag = "AutoQuestSelection",
					Callback = function(arg)
						v44 = tbl13[arg]
						v45 = nil
						n26 = -math.huge
						n27 = -math.huge
						v46 = nil
						str11 = ""
						fn95()
					end,
				})

				local v47 = QuestTab:Toggle({
					Title = text("Auto Quest"),
					Default = false,
					Flag = "AutoQuest",
					Callback = function(arg)
						flag36 = arg
						v45 = nil
						n26 = -math.huge
						n27 = -math.huge
						str11 = ""

						if not arg then
							fn95()
						end
					end,
				})

				QuestTab:Toggle({
					Title = text("Travel To Quest Island"),
					Default = true,
					Flag = "QuestAutoTravel",
					Callback = function(arg)
						flag38 = arg
					end,
				})

				task.spawn(function()
					while flag11 do
						task.wait(2)

						if flag36 and not flag31 and not flag25 and not tbl8.pending and not flag26 then
							local ok, result = pcall(function()
								return PlayerDataV2Controller:Fetch(localPlayer)
							end)

							if ok and type(result) == "table" then
								local quest = result.Quest or {}
								local current = quest.Current
								local id2 = v44 or current and current.Id or fn93(result)
								local v48 = id2 and QuestConfig.Data[id2]

								if not v48 then
									fn95()

									if str11 ~= "no_quest" then
										str11 = "no_quest"

										lib:Notify({
											Title = text("Auto Quest"),
											Content = text("Start A Quest In Game Or Select One In This Tab."),
											Duration = 4,
										})
									end
								elseif not current and quest.Done and quest.Done[id2] and not v48.repeatable then
									fn95()
									flag36 = false

									pcall(function()
										v47:Set(false)
									end)

									lib:Notify({ Title = text("Auto Quest Complete"), Content = v48.name or id2, Duration = 4 })
								elseif current and v44 and current.Id ~= v44 then
									fn95()

									if id ~= current.Id then
										id = current.Id

										lib:Notify({
											Title = text("Another Quest Active"),
											Content = text("Finish Or Cancel ") .. tostring(current.Id) .. " First.",
											Duration = 4,
										})
									end
								elseif not current and os.clock() - n26 >= 10 then
									fn95()
									n26 = os.clock()

									local ok2, result2 = pcall(function()
										return client.GetController("QuestController"):Accept(id2)
									end)

									if ok2 and result2 then
										lib:Notify({ Title = text("Quest Started"), Content = v48.name or id2, Duration = 3 })
									else
										n26 = os.clock() + 50

										if not ok2 then
											warn("[Hune Hub] Quest accept failed: " .. tostring(result2))
										end
									end
								elseif current then
									local v49 = fn98(result, current)
									local v50 = fn99(result, current)
									local v51 = tbl14[id2]
									local flag40 = v50 and v51 and fn60() ~= v51

									if v50 and not flag37 then
										if flag40 and flag38 then
											fn95()
											local v52 = Catalog.Island.GetById(v51)

											if v52 and v46 ~= v51 and os.clock() - n27 >= 30 then
												n27 = os.clock()

												task.spawn(function()
													local v53, v54 = fn76(v52.name, function()
														return flag11 and flag36
													end)

													local flag41 = not v53 and flag36

													if flag41 then
														flag41 = v54 == "DestinationNotLoaded" or v54 == "ArrivalUnconfirmed" or v54 == "PositionCorrected" or v54 == "TweenInterrupted" or v54 == "TweenFailed"
													end

													if flag41 then
														v46 = v51
														local name = v52.name

														lib:Notify({
															Title = text("Auto Quest"),
															Content = text("Tween to ") .. name .. text(" failed: ") .. tostring(v54) .. ".",
															Duration = 5,
														})
													end
												end)
											end

											if str11 ~= "travel_" .. v51 then
												str11 = "travel_" .. v51

												lib:Notify({
													Title = text("Auto Quest"),
													Content = v52 and "Tweening To " .. v52.name or "Quest Island Not Found.",
													Duration = 4,
												})
											end
										elseif not flag40 then
											if fn94() then
												flag39 = true
											end

											if str11 ~= "fish_" .. id2 then
												str11 = "fish_" .. id2

												lib:Notify({
													Title = text("Auto Quest"),
													Content = text("Fishing For ") .. (v48.name or id2),
													Duration = 4,
												})
											end
										else
											fn95()
										end
									else
										fn95()
										local str12 = v49 and "claim"
										local str13

										if str12 then
											str13 = str12
										else
											str13 = flag37 and "boss_priority" or "materials"
										end

										if str11 ~= str13 then
											str11 = str13

											lib:Notify({
												Title = text("Auto Quest"),
												Content = v49 and "Requirements Ready; Claiming Quest." or flag37 and "Auto Boss Has Priority." or "Waiting For Coins, Books, Or Other Materials.",
												Duration = 4,
											})
										end
									end

									if v49 and os.clock() - n26 >= 30 then
										local v52, v53, v54 = pairs((result.Inventory or {}).Fishes or {})
										local n28 = 0

										for k in v52, v53, v54 do
											n28 += 1
										end

										local str12 = ""

										pcall(function()
											str12 = HttpService2:JSONEncode(current.Progress or {})
										end)

										local str13 = id2 .. ":" .. str12 .. ":" .. n28 .. ":" .. tostring((result.Coin or 0) >= ((current.Progress or {}).RequiredCoin or 0))

										if str13 ~= v45 then
											v45 = str13
											n26 = os.clock()

											local ok2, result2 = pcall(function()
												return client.GetController("QuestController"):Complete(id2)
											end)

											if ok2 and result2 then
												fn95()

												lib:Notify({
													Title = text("Quest Completed"),
													Content = v48.name or id2,
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

				local flag40 = false
				local flag41 = false

				local function fn100(arg, arg2, arg3)
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

				local function fn101(arg, arg2, arg3)
					if flag40 then
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
					flag40 = true
					flag41 = false

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
					local tbl17 = {}
					humanoid.Sit = false
					humanoid.AutoRotate = false
					humanoid.PlatformStand = true

					local connection = RunService.PreSimulation:Connect(function()
						if not flag40 or not humanoidRootPart.Parent then
							return
						end
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
					end)

					local connection2 = RunService.Stepped:Connect(function()
						if not flag40 or not character.Parent then
							return
						end

						for _, descendant in ipairs(character:GetDescendants()) do
							if descendant:IsA("BasePart") then
								if tbl17[descendant] == nil then
									tbl17[descendant] = descendant.CanCollide
								end

								descendant.CanCollide = false
							end
						end
					end)

					local n29 = math.clamp(tonumber(arg3) or tonumber(genv.HuneHubTravelSpeed) or 70, 20, 140)
					local n30 = math.clamp(math.ceil(magnitude / (n29 >= 100 and 150 or 130)), 1, 150)
					local flag42 = magnitude > 120
					local n31 = n28 + 20
					local tbl18 = {}
					local n32 = magnitude > 5 and n30 or 0

					for i = 1, n32 do
						local n33 = i / n30
						local v48 = position2:Lerp(position, n33)
						local n34

						if flag42 then
							local n35 = math.sin(n33 * 3.1415926535897931) * 28
							n34 = math.max(position2.Y, position.Y, n31) + n35
						else
							n34 = math.max(v48.Y, n31)
						end

						local rotation

						if i == n30 then
							rotation = arg.Rotation
						else
							local vector = Vector3.new(position.X - v48.X, 0, position.Z - v48.Z)

							if vector.Magnitude > 0.1 then
								rotation = CFrame.lookAt(Vector3.zero, vector).Rotation
							else
								rotation = humanoidRootPart.CFrame.Rotation
							end
						end

						tbl18[i] = CFrame.new(v48.X, n34, v48.Z) * rotation
					end

					table.insert(tbl18, arg)

					local function fn102()
						connection:Disconnect()
						connection2:Disconnect()

						for k, v48 in pairs(tbl17) do
							if k.Parent then
								k.CanCollide = v48
							end
						end

						fn100(character, humanoid, humanoidRootPart)
						humanoid.PlatformStand = platformStand
						humanoid.AutoRotate = autoRotate
						flag40 = false
					end

					local flag43 = true
					local str12 = "Cancelled"

					local ok, result = pcall(function()
						for i, v48 in ipairs(tbl18) do
							if flag41 or not flag40 or not humanoidRootPart.Parent or humanoid.Health <= 0 or arg2 and not arg2() then
								flag43 = false
								str12 = flag41 and "ManualStop" or "ConditionFailed"
								break
							else
								local flag44 = i == #tbl18
								local magnitude2 = (humanoidRootPart.Position - v48.Position).Magnitude
								local linear = Enum.EasingStyle.Linear
								flag44 = flag44 and magnitude2 > 15
								local n33 = n29

								if flag44 then
									n33 = math.min(n29, 20)
								end

								local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(math.max(magnitude2 / n33, 0.01), linear, Enum.EasingDirection.Out), { CFrame = v48 })
								tween:Play()

								while tween.PlaybackState == Enum.PlaybackState.Playing do
									if flag41 or not flag11 or not humanoidRootPart.Parent or humanoid.Health <= 0 or arg2 and not arg2() then
										tween:Cancel()
										break
									else
										task.wait(0.05)
									end
								end

								local playbackState = tween.PlaybackState
								tween:Destroy()

								if playbackState ~= Enum.PlaybackState.Completed then
									flag43 = false
									str12 = "TweenInterrupted"
									break
								end
							end
						end
					end)

					fn102()
					if not ok then
						return false, "Error: " .. tostring(result)
					end

					if not flag43 then
						return false, str12
					end
					task.wait(0.25)
					local flag44 = humanoidRootPart.Parent and (humanoidRootPart.Position - position).Magnitude <= 4
					return flag44, flag44 and "Success" or "ArrivalUnconfirmed"
				end

				local flag42 = false
				local n29 = -math.huge
				local str12 = ""
				local n30 = 0
				local v48 = nil
				local v49 = nil
				local v50 = nil
				local n31 = 0
				local v51 = nil
				local id2 = nil

				local tbl17 = {
					observations = {},
					probes = {},
					lastStream = {},
					generation = 0,
					espRecords = {},
					regionWatchers = {},
					notifiedEffects = {},
					lastNotifiedAt = {},
					notifyEnabled = false,
					espEnabled = false,
					lastWorldScanAt = -math.huge,
					travelInProgress = false,
					travelAttempts = 0,
					travelRetryAt = -math.huge,
					movingToBank = false,
				}

				local fn102 = nil

				tbl17.isInterested = function()
					return flag37 or tbl17.notifyEnabled or tbl17.espEnabled
				end

				tbl17.observe = function()
					local now5 = os.clock()

					for _, v52 in ipairs(CollectionService:GetTagged(RegionConfig.BossTag)) do
						if v52:IsA("BasePart") and v52:IsDescendantOf(workspace) then
							local attribute = v52:GetAttribute(RegionConfig.BossAttribute)
							local flag43 = type(attribute) == "string" and Catalog.BossRegion.GetById(attribute)
							local v53 = flag43 and BossSpawnerFX.GetForRegion(v52)

							if v53 then
								if BossSpawnerFX.IsActive(v53) then
									tbl17.observations[attribute] = {
										id = attribute,
										islandId = flag43.fallbackIslandId,
										position = v52.Position,
										region = v52,
										seenAt = now5,
									}
								elseif v53:GetAttribute(BossSpawnerFX.ActiveAttribute) == false then
									tbl17.observations[attribute] = nil
								elseif tbl17.observations[attribute] then
									tbl17.markUnloaded(attribute, v52, v53)
								end
							end
						end
					end
				end

				tbl17.probe = function(arg)
					if tbl17.probes[arg] then
						return tbl17.probes[arg]
					end
					local v52 = fn75(arg)
					if v52 then
						tbl17.probes[arg] = v52.Position
						return v52.Position
					end

					for _, v53 in ipairs(CollectionService:GetTagged(RegionConfig.IslandTag)) do
						if v53:IsA("BasePart") and v53:GetAttribute(RegionConfig.IslandAttribute) == arg then
							tbl17.probes[arg] = v53.Position
							return v53.Position
						end
					end

					local world = workspace:FindFirstChild("World")
					world = world and world:FindFirstChild("Islands")
					world = world and world:FindFirstChild(arg)

					if world and world:IsA("Model") and world:FindFirstChildWhichIsA("BasePart", true) then
						tbl17.probes[arg] = world:GetPivot().Position
					end

					return tbl17.probes[arg]
				end

				tbl17.resolve = function(arg)
					local region = arg.region
					local v52 = region and region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region)
					if v52 and BossSpawnerFX.IsActive(v52) then
						return region
					end
					local now5 = os.clock()
					if now5 - (tbl17.lastStream[arg.id] or -math.huge) < 8 then
						return nil
					end
					tbl17.lastStream[arg.id] = now5

					pcall(function()
						localPlayer:RequestStreamAroundAsync(arg.position, 2)
					end)

					tbl17.observe()
					local region2 = tbl17.observations[arg.id]
					region2 = region2 and region2.region
					local v53 = region2 and region2:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region2)
					return v53 and BossSpawnerFX.IsActive(v53) and region2 or nil
				end

				local function fn103(arg)
					if not arg then
						tbl17.observe()
					end

					local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
					local huge = math.huge
					local v52 = nil

					for k, observation in pairs(tbl17.observations) do
						local region = observation.region
						local v53 = region and region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region)

						if v53 and BossSpawnerFX.IsActive(v53) then
							local magnitude = humanoidRootPart and (humanoidRootPart.Position - observation.position).Magnitude or 0

							if magnitude < huge then
								huge = magnitude
								v52 = observation
							end
						elseif v53 and v53:GetAttribute(BossSpawnerFX.ActiveAttribute) == false then
							tbl17.deactivate(k)
						else
							tbl17.markUnloaded(k, region, v53)
						end
					end

					return v52
				end

				local v52 = nil
				local now5 = nil
				local lastSignal = "Not detected"
				local str13 = "None"
				local str14 = "None"
				local action = "Boss radar is waiting for a spawn signal."
				local now6 = nil

				tbl17.clearEsp = function(arg)
					local v53 = tbl17.espRecords[arg]
					if not v53 then
						return
					end
					tbl17.espRecords[arg] = nil

					if v53.attributeConnection then
						v53.attributeConnection:Disconnect()
					end

					if v53.ancestryConnection then
						v53.ancestryConnection:Disconnect()
					end

					if v53.gui then
						v53.gui:Destroy()
					end

					if v53.anchor then
						v53.anchor:Destroy()
					end
				end

				tbl17.markUnloaded = function(arg, arg2, arg3)
					if arg2 and arg3 and arg2:IsDescendantOf(workspace) then
						local v53 = BossSpawnerFX.GetForRegion(arg2)
						if v53 and v53 ~= arg3 then
							return
						end
					end

					local v53 = tbl17.observations[arg]
					local flag43 = not arg2 or v53 and v53.region == arg2

					if v53 and flag43 then
						v53.region = nil
					end

					local v54 = tbl17.espRecords[arg]

					if v54 and (flag43 or arg3 and v54.effect == arg3) and (not arg3 or v54.effect == arg3) then
						if v54.attributeConnection then
							v54.attributeConnection:Disconnect()
						end

						if v54.ancestryConnection then
							v54.ancestryConnection:Disconnect()
						end

						v54.attributeConnection = nil
						v54.ancestryConnection = nil
						v54.effect = nil
					end
				end

				tbl17.deactivate = function(arg)
					if not tbl17.observations[arg] and not tbl17.notifiedEffects[arg] and not tbl17.espRecords[arg] then
						return
					end
					tbl17.observations[arg] = nil
					tbl17.notifiedEffects[arg] = nil
					tbl17.clearEsp(arg)

					if v51 and v51.id == arg then
						v51 = nil
					end

					now6 = os.time()
					action = "Boss marker cleared. Waiting for a spawn signal."
				end

				tbl17.distanceText = function(arg, arg2, arg3, arg4)
					local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
					humanoidRootPart = humanoidRootPart and math.floor((humanoidRootPart.Position - arg.Position).Magnitude + 0.5)
					return text(arg4 and "LAST SEEN: " or "BOSS: ") .. arg2 .. "\n" .. arg3 .. " | " .. (humanoidRootPart and humanoidRootPart .. text(" studs") or text("Distance unavailable")), humanoidRootPart
				end

				tbl17.startDistanceLoop = function()
					if tbl17.distanceLoopRunning then
						return
					end
					tbl17.distanceLoopRunning = true

					task.spawn(function()
						while flag11 and tbl17.espEnabled and next(tbl17.espRecords) do
							for k, espRecord in pairs(tbl17.espRecords) do
								if not espRecord.gui.Parent or not espRecord.anchor.Parent or not espRecord.label.Parent then
									local v53 = tbl17.observations[k]
									tbl17.clearEsp(k)

									if v53 then
										tbl17.showEsp(v53)
									end
								else
									local effect = espRecord.effect

									if effect and effect:IsDescendantOf(workspace) then
										if BossSpawnerFX.IsActive(effect) then
											espRecord.anchor.Position = effect.Position
											local v53 = tbl17.observations[k]

											if v53 then
												v53.position = effect.Position
											end
										elseif effect:GetAttribute(BossSpawnerFX.ActiveAttribute) == false then
											tbl17.deactivate(k)
										else
											tbl17.markUnloaded(k, nil, effect)
										end
									elseif effect then
										tbl17.markUnloaded(k, nil, effect)
									end

									if tbl17.espRecords[k] == espRecord then
										local v53 = tbl17.distanceText(espRecord.anchor, espRecord.bossName, espRecord.islandName, espRecord.effect == nil)

										if espRecord.label.Text ~= v53 then
											espRecord.label.Text = v53
										end

										local color7 = espRecord.effect and Color3.fromRGB(255, 95, 95) or Color3.fromRGB(255, 205, 90)

										if espRecord.label.TextColor3 ~= color7 then
											espRecord.label.TextColor3 = color7
										end
									end
								end
							end

							task.wait(2)
						end

						tbl17.distanceLoopRunning = false
					end)
				end

				tbl17.showEsp = function(arg)
					if not tbl17.espEnabled then
						return
					end
					local region = arg.region
					local v53 = region and region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(region)

					if v53 and not BossSpawnerFX.IsActive(v53) then
						v53 = nil
					end

					if not v53 and not arg.position then
						return
					end
					local v54 = tbl17.espRecords[arg.id]
					if v54 and v54.effect == v53 and v54.gui.Parent and v54.anchor.Parent then
						v54.anchor.Position = v53 and v53.Position or arg.position
						return
					end
					tbl17.clearEsp(arg.id)
					local v55 = Catalog.BossRegion.GetById(arg.id)
					local name = v55 and Catalog.Island.GetById(v55.fallbackIslandId)
					local name2 = v55 and v55.name or arg.id
					name = name and name.name or "Unknown Island"
					local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")
					if not playerGui2 then
						return
					end
					local part = Instance.new("Part")
					part.Name = "HuneHubBossESPAnchor"
					part.Size = Vector3.one
					part.Anchored = true
					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
					part.Transparency = 1
					part.Position = v53 and v53.Position or arg.position
					part.Parent = workspace
					local billboardGui = Instance.new("BillboardGui")
					billboardGui.Name = "HuneHubBossESP"

					pcall(function()
						billboardGui.ResetOnSpawn = false
					end)

					billboardGui.Adornee = part
					billboardGui.AlwaysOnTop = true
					billboardGui.MaxDistance = 6500
					billboardGui.Size = UDim2.fromOffset(260, 70)
					billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 7, 0)
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = "BossLocation"
					textLabel.Size = UDim2.fromScale(1, 1)
					textLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					textLabel.BackgroundTransparency = 0.25
					textLabel.TextColor3 = v53 and Color3.fromRGB(255, 95, 95) or Color3.fromRGB(255, 205, 90)
					textLabel.TextStrokeTransparency = 0.35
					textLabel.TextScaled = true
					textLabel.TextWrapped = true
					textLabel.Font = Enum.Font.GothamBold
					textLabel.Text = tbl17.distanceText(part, name2, name, v53 == nil)
					textLabel.Parent = billboardGui
					billboardGui.Parent = playerGui2
					local tbl18 = { effect = v53, anchor = part, gui = billboardGui, label = textLabel, bossName = name2, islandName = name }
					tbl17.espRecords[arg.id] = tbl18

					if v53 then
						tbl18.attributeConnection = v53:GetAttributeChangedSignal(BossSpawnerFX.ActiveAttribute):Connect(function()
							if v53:GetAttribute(BossSpawnerFX.ActiveAttribute) == false then
								tbl17.deactivate(arg.id)
							end
						end)

						tbl18.ancestryConnection = v53.AncestryChanged:Connect(function()
							if not v53:IsDescendantOf(workspace) then
								tbl17.markUnloaded(arg.id, region, v53)
							end
						end)
					end

					tbl17.startDistanceLoop()
				end

				tbl17.announce = function(arg, arg2)
					if not tbl17.notifyEnabled or tbl17.notifiedEffects[arg.id] == arg2 then
						return
					end
					tbl17.notifiedEffects[arg.id] = arg2
					local now7 = os.clock()
					if now7 - (tbl17.lastNotifiedAt[arg.id] or -math.huge) < 30 then
						return
					end
					tbl17.lastNotifiedAt[arg.id] = now7
					local name = Catalog.BossRegion.GetById(arg.id)
					local name2 = name and Catalog.Island.GetById(name.fallbackIslandId)
					name = name and name.name or arg.id
					name2 = name2 and name2.name or "Unknown Island"
					local v53, v54 = tbl17.distanceText(arg2, name, name2)
					now5 = os.time()
					str13 = name
					str14 = name2
					now6 = nil
					action = flag37 and "Boss detected. Preparing a safe casting spot." or "Boss location detected."

					lib:Notify({
						Title = text("Boss Spotted: ") .. name,
						Content = string.format("%s | %s | X: %.0f, Z: %.0f", name2, v54 and v54 .. text(" studs away") or text("Distance unavailable"), arg2.Position.X, arg2.Position.Z),
						Duration = 6,
					})
				end

				tbl17.refreshEsp = function()
					tbl17.observe()

					for k in pairs(tbl17.notifiedEffects) do
						if not tbl17.observations[k] then
							tbl17.deactivate(k)
						end
					end

					for k in pairs(tbl17.espRecords) do
						if not tbl17.observations[k] then
							tbl17.deactivate(k)
						end
					end

					for k, observation in pairs(tbl17.observations) do
						local region = observation.region and observation.region:IsDescendantOf(workspace) and BossSpawnerFX.GetForRegion(observation.region)

						if region and BossSpawnerFX.IsActive(region) then
							tbl17.announce(observation, region)
							tbl17.showEsp(observation)
						elseif region and region:GetAttribute(BossSpawnerFX.ActiveAttribute) == false then
							tbl17.deactivate(k)
						else
							tbl17.markUnloaded(k, observation.region, region)
							tbl17.showEsp(observation)
						end
					end

					v51 = fn103(true)
				end

				tbl17.queueRefresh = function()
					if tbl17.refreshQueued or not tbl17.isInterested() then
						return
					end
					tbl17.refreshQueued = true

					task.delay(0.15, function()
						tbl17.refreshQueued = false

						if flag11 and tbl17.isInterested() then
							tbl17.refreshEsp()
							fn102()
						end
					end)
				end

				tbl17.groundContext = function(arg)
					local v53 = Catalog.BossRegion.GetById(arg:GetAttribute(RegionConfig.BossAttribute))
					local num = tonumber(v53 and Catalog.Island.GetWaterY(v53.fallbackIslandId)) or n28
					local filterDescendantsInstances = {}
					local v54 = ipairs
					local Players2 = game:GetService("Players")

					for _, player in v54(Players2:GetPlayers()) do
						if player.Character then
							table.insert(filterDescendantsInstances, player.Character)
						end
					end

					local tbl18 = {}

					for _, v55 in ipairs(CollectionService:GetTagged(RegionConfig.IslandTag)) do
						table.insert(filterDescendantsInstances, v55)
						local isBasePart = v55:IsA("BasePart") and v53

						if isBasePart then
							local fallbackIslandId = v53.fallbackIslandId
							isBasePart = v55:GetAttribute(RegionConfig.IslandAttribute) == fallbackIslandId
						end

						if isBasePart then
							table.insert(tbl18, v55)
						end
					end

					for _, v55 in ipairs(CollectionService:GetTagged(RegionConfig.BossTag)) do
						table.insert(filterDescendantsInstances, v55)
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
					local v55 = fn53()
					local n32 = humanoid and v55 and humanoid.HipHeight + v55.Size.Y * 0.5 or 3

					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
						local leftLeg = character:FindFirstChild("Left Leg")
						n32 += leftLeg and leftLeg.Size.Y or 2
					end

					local cast = FishingConfig.Cast

					return {
						rays = raycastParams,
						mapRays = raycastParams2,
						waterY = num,
						lift = math.max(n32, 2),
						minCast = tonumber(cast.BaitMinDist) or 30,
						maxCast = math.min(tonumber(cast.BaitMaxDist) or 60, (tonumber(cast.ServerMaxDistance) or 80) - 2),
						zones = tbl18,
					}
				end

				tbl17.targetValid = function(arg, arg2, arg3)
					if not arg.Parent then
						return false
					end
					local v53 = arg.CFrame:PointToObjectSpace(arg2)
					local n32 = arg.Size * 0.5
					local n33 = n32.X - 0.1
					local flag43 = math.abs(v53.X) > n33
					local flag44

					if flag43 then
						flag44 = flag43
					else
						local y = n32.Y
						flag44 = math.abs(v53.Y) > y
					end

					if not flag44 then
						local n34 = n32.Z - 0.1
						flag44 = math.abs(v53.Z) > n34
					end

					if flag44 then
						return false
					end
					return workspace:Raycast(arg2 + Vector3.new(0, 100, 0), Vector3.new(0, -100, 0), arg3.mapRays) == nil
				end

				tbl17.dryGround = function(arg, arg2)
					local flag43 = arg and arg.Normal.Y >= 0.75 and arg.Material ~= Enum.Material.Water and arg.Position.Y > arg2.waterY + 0.25

					if flag43 then
						flag43 = arg.Instance:IsA("Terrain")

						if not flag43 then
							flag43 = arg.Instance:IsA("BasePart") and arg.Instance.CanCollide and arg.Instance.Anchored
						end
					end

					return flag43
				end

				tbl17.supportAt = function(arg, arg2)
					local rays = arg2.rays
					local hit = workspace:Raycast(arg + Vector3.new(0, 1, 0), Vector3.new(0, -(arg2.lift + 2), 0), rays)
					if not tbl17.dryGround(hit, arg2) then
						return false
					end
					return math.abs(arg.Y - hit.Position.Y - arg2.lift) <= 1.25
				end

				tbl17.readyToFish = function(arg, arg2, arg3)
					local v53 = fn53()
					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
					local parent = arg and arg.Parent and BossSpawnerFX.GetForRegion(arg)
					if not v53 or not humanoid or humanoid.Health <= 0 or not parent or not BossSpawnerFX.IsActive(parent) or not arg2 or not arg3 or (v53.Position - arg2.Position).Magnitude > 4 or humanoid:GetState() == Enum.HumanoidStateType.Swimming or math.abs(v53.AssemblyLinearVelocity.Y) > 3 then
						return false
					end
					local v54 = tbl17.groundContext(arg)
					local magnitude = (v53.Position - arg3).Magnitude
					return magnitude >= v54.minCast - 1 and magnitude <= v54.maxCast and tbl17.supportAt(v53.Position, v54) and tbl17.targetValid(arg, arg3, v54)
				end

				local function fn104(arg)
					local v53 = fn53()
					if not v53 then
						return nil, nil
					end
					local v54 = tbl17.groundContext(arg)
					local n32 = arg.Size * 0.5
					local tbl18 = {}

					local function fn105(arg2, arg3)
						local v55 = arg.CFrame:PointToWorldSpace(Vector3.new(arg2, 0, arg3))
						local vector = Vector3.new(v55.X, v54.waterY, v55.Z)

						if tbl17.targetValid(arg, vector, v54) then
							table.insert(tbl18, vector)
						end
					end

					local v55 = BossSpawnerFX.GetForRegion(arg)

					if v55 then
						local v56 = arg.CFrame:PointToObjectSpace(v55.Position)
						local clamp = math.clamp
						local z = v56.Z
						local n33 = -n32.Z + 1
						local n34 = n32.Z - 1
						fn105(math.clamp(v56.X, -n32.X + 1, n32.X - 1), clamp(z, n33, n34))
					end

					local n33 = math.max(n32.X - 2, 0)
					local n34 = math.max(n32.Z - 2, 0)
					local n35 = math.clamp(math.ceil(arg.Size.X / 20), 2, 32)
					local n36 = math.clamp(math.ceil(arg.Size.Z / 20), 2, 32)

					for i = 0, n35 do
						local n37 = -n33 + 2 * n33 * i / n35
						fn105(n37, -n34)
						fn105(n37, n34)
					end

					for i = 1, n36 - 1 do
						local n37 = -n34 + 2 * n34 * i / n36
						fn105(-n33, n37)
						fn105(n33, n37)
					end

					for i = -1, 1 do
						for i2 = -1, 1 do
							fn105(i * n32.X * 0.5, i2 * n32.Z * 0.5)
						end
					end

					local tbl19 = { v54.minCast + 2, (v54.minCast + v54.maxCast) * 0.5, v54.maxCast - 2 }
					local huge = math.huge
					local cframe = nil
					local v56 = nil

					for i, v57 in ipairs(tbl18) do
						if not flag11 or not flag37 or not arg.Parent then
							return nil, nil
						end

						for _, v58 in ipairs(tbl19) do
							for i2 = 0, 15 do
								local n37 = i2 * 3.1415926535897931 / 8
								local rays = v54.rays
								local hit = workspace:Raycast(v57 + Vector3.new(math.cos(n37) * v58, 120, math.sin(n37) * v58), Vector3.new(0, -124, 0), rays)

								if tbl17.dryGround(hit, v54) then
									local n38 = hit.Position + Vector3.new(0, v54.lift + 0.1, 0)
									local magnitude = (n38 - v57).Magnitude
									local flag43 = magnitude >= v54.minCast and magnitude <= v54.maxCast

									if flag43 then
										for _, v59 in ipairs({
											Vector3.new(1.2, 0, 0),
											Vector3.new(-1.2, 0, 0),
											Vector3.new(0, 0, 1.2),
											Vector3.new(0, 0, -1.2),
										}) do
											if not tbl17.supportAt(n38 + v59, v54) then
												flag43 = false
												break
											end
										end
									end

									if flag43 and #v54.zones > 0 then
										flag43 = false

										for _, zone in ipairs(v54.zones) do
											local v59 = zone.CFrame:PointToObjectSpace(n38)
											local n39 = zone.Size * 0.5
											local x = n39.X
											local flag44 = math.abs(v59.X) <= x

											if flag44 then
												local y = n39.Y
												flag44 = math.abs(v59.Y) <= y
											end

											if flag44 then
												local z = n39.Z
												flag44 = math.abs(v59.Z) <= z
											end

											if flag44 then
												flag43 = true
												break
											end
										end
									end

									if flag43 then
										flag43 = workspace:Raycast(hit.Position + Vector3.new(0, 0.3, 0), Vector3.new(0, 120, 0), v54.rays) == nil
									end

									if flag43 then
										local n39 = (v53.Position - n38).Magnitude + math.abs(magnitude - tbl19[2]) * 2

										if n39 < huge then
											cframe = CFrame.lookAt(n38, Vector3.new(v57.X, n38.Y, v57.Z))
											huge = n39
											v56 = v57
										end
									end
								end
							end
						end

						if i % 4 == 0 then
							task.wait()
						end
					end

					return cframe, v56
				end

				local function fn105(arg)
					if not arg then
						return "None"
					end
					local n32 = math.max(0, os.time() - arg)
					local v53 = os.date("%H:%M:%S", arg)
					if n32 < 60 then
						return string.format("%s (%ds ago)", v53, n32)
					end

					if n32 < 3600 then
						return string.format("%s (%dm ago)", v53, math.floor(n32 / 60))
					end
					return string.format("%s (%dh %dm ago)", v53, math.floor(n32 / 3600), math.floor(n32 % 3600 / 60))
				end

				fn102 = function()
					if not v52 or not v52.SetDesc then
						return
					end

					pcall(function()
						local v53 = v51
						local tbl18 = { "Mode: Boss Radar + ESP" }

						if v53 then
							local v54 = Catalog.BossRegion.GetById(v53.id)
							local v55 = v54 and Catalog.Island.GetById(v54.fallbackIslandId)
							str13 = v54 and v54.name or v53.id
							str14 = v55 and v55.name or "Unknown"
							table.insert(tbl18, "Status: Active boss region")
							table.insert(tbl18, "Location: " .. str13 .. " | Island: " .. str14)
							table.insert(tbl18, "Source: BossSpawnerFX Active")
							table.insert(tbl18, "Detected: " .. fn105(now5))
						else
							table.insert(tbl18, "Status: Waiting for a boss spawn signal")
							table.insert(tbl18, "Last signal: " .. lastSignal)

							if now5 then
								table.insert(tbl18, "Last boss: " .. str13 .. " (" .. str14 .. ")")
								table.insert(tbl18, "Detected: " .. fn105(now5))

								if now6 then
									table.insert(tbl18, "Last seen: " .. fn105(now6))
								end
							end
						end

						table.insert(tbl18, "Action: " .. action)
						;(nil):SetDesc(table.concat(tbl18, "\n"))
					end)
				end

				local function fn106(arg, arg2)
					if not flag37 or str12 == arg then
						return
					end
					str12 = arg
					lib:Notify({ Title = text("Auto Boss"), Content = arg2, Duration = 4 })
				end

				local fn107 = nil

				fn107 = function(arg)
					if not flag11 or not tbl17.isInterested() then
						return
					end
					lastSignal = arg or "Server Broadcast"

					if tbl17.signalScanRunning then
						if arg == "Server Broadcast: BossSpawnSound" then
							tbl17.rescanRequested = true
						end

						return
					end

					tbl17.signalScanRunning = true
					local generation = tbl17.generation
					local streamingEnabled = (arg == "Server Broadcast: BossSpawnSound" or arg == "Auto Boss Enabled") and workspace.StreamingEnabled

					if streamingEnabled then
						local lastWorldScanAt = tbl17.lastWorldScanAt
						streamingEnabled = os.clock() - lastWorldScanAt >= 45
					end

					task.spawn(function()
						pcall(function()
							v51 = fn103()

							if streamingEnabled and not v51 then
								tbl17.lastWorldScanAt = os.clock()

								for _, v53 in ipairs(Catalog.Island.GetAll()) do
									if not (not flag11 or generation ~= tbl17.generation or not tbl17.isInterested()) then
										local ok, result = pcall(tbl17.probe, v53.id)

										if ok and result then
											pcall(function()
												localPlayer:RequestStreamAroundAsync(result, 1)
											end)

											tbl17.refreshEsp()
											if not v51 then
												task.wait(3)
												continue
											end
										else
											task.wait(3)
											continue
										end
									end

									break
								end
							end

							if flag11 and generation == tbl17.generation and tbl17.isInterested() then
								tbl17.refreshEsp()

								if not v51 then
									action = "Waiting for a boss spawn signal."
								end

								fn102()
							end
						end)

						if generation ~= tbl17.generation then
							v51 = nil
						end

						tbl17.signalScanRunning = false

						if tbl17.rescanRequested then
							tbl17.rescanRequested = false

							if flag11 and tbl17.isInterested() and not v51 then
								task.delay(1, function()
									fn107("Boss Spawn Follow-Up")
								end)
							end
						elseif arg == "Server Broadcast: BossSpawnSound" and not v51 then
							task.delay(2, function()
								if flag11 and generation == tbl17.generation and tbl17.isInterested() then
									tbl17.refreshEsp()
									fn102()
								end
							end)
						end
					end)
				end

				tbl17.watchRegion = function(arg)
					if not arg:IsA("BasePart") or tbl17.regionWatchers[arg] then
						return
					end
					local tbl18 = {}
					tbl17.regionWatchers[arg] = tbl18

					tbl18.attach = function(effect)
						if not effect or not effect:IsA("BasePart") or tbl18.effect == effect then
							return
						end

						if tbl18.attributeConnection then
							tbl18.attributeConnection:Disconnect()
						end

						tbl18.effect = effect

						tbl18.attributeConnection = effect:GetAttributeChangedSignal(BossSpawnerFX.ActiveAttribute):Connect(function()
							if not flag11 then
								return
							end

							if BossSpawnerFX.IsActive(effect) then
								tbl17.queueRefresh()
							elseif effect:GetAttribute(BossSpawnerFX.ActiveAttribute) == false then
								local attribute = arg:GetAttribute(RegionConfig.BossAttribute)

								if type(attribute) == "string" then
									tbl17.deactivate(attribute)
								end

								tbl17.queueRefresh()
							end
						end)

						if BossSpawnerFX.IsActive(effect) then
							tbl17.queueRefresh()
						end
					end

					tbl18.childConnection = arg.ChildAdded:Connect(function(child)
						if child.Name == BossSpawnerFX.RootName then
							tbl18.attach(child)
						end
					end)

					tbl18.destroyConnection = arg.Destroying:Connect(function()
						if tbl18.attributeConnection then
							tbl18.attributeConnection:Disconnect()
						end

						if tbl18.childConnection then
							tbl18.childConnection:Disconnect()
						end

						if tbl18.destroyConnection then
							tbl18.destroyConnection:Disconnect()
						end

						tbl17.regionWatchers[arg] = nil
						local attribute = arg:GetAttribute(RegionConfig.BossAttribute)

						if type(attribute) == "string" then
							tbl17.markUnloaded(attribute, arg, tbl18.effect)
						end
					end)

					tbl18.attach(BossSpawnerFX.GetForRegion(arg))
				end

				for _, v53 in ipairs(CollectionService:GetTagged(RegionConfig.BossTag)) do
					tbl17.watchRegion(v53)
				end

				fn48(CollectionService:GetInstanceAddedSignal(RegionConfig.BossTag):Connect(tbl17.watchRegion))

				fn48(localPlayer.CharacterAdded:Connect(function()
					tbl17.movingToBank = false

					task.delay(1, function()
						if flag11 and tbl17.espEnabled then
							tbl17.refreshEsp()
						end
					end)
				end))

				fn48({ Disconnect = function()
					for k, regionWatcher in pairs(tbl17.regionWatchers) do
						if regionWatcher.attributeConnection then
							regionWatcher.attributeConnection:Disconnect()
						end

						if regionWatcher.childConnection then
							regionWatcher.childConnection:Disconnect()
						end

						if regionWatcher.destroyConnection then
							regionWatcher.destroyConnection:Disconnect()
						end

						tbl17.regionWatchers[k] = nil
					end

					for k in pairs(tbl17.espRecords) do
						tbl17.clearEsp(k)
					end
				end })

				pcall(function()
					fn48(BossSpawnSound.OnClientEvent:Connect(function()
						fn107("Server Broadcast: BossSpawnSound")
					end))
				end)

				BossTab:Section({ Title = text("Boss Alerts") })

				BossTab:Toggle({
					Title = text("Notify Boss"),
					Default = false,
					Flag = "NotifyBoss",
					Callback = function(notifyEnabled)
						tbl17.notifyEnabled = notifyEnabled

						if notifyEnabled then
							tbl17.refreshEsp()
						else
							table.clear(tbl17.notifiedEffects)

							if not tbl17.espEnabled and not flag37 then
								tbl17.generation = tbl17.generation + 1
							end
						end
					end,
				})

				BossTab:Toggle({
					Title = text("ESP Boss"),
					Default = false,
					Flag = "ESPBoss",
					Callback = function(espEnabled)
						tbl17.espEnabled = espEnabled

						if espEnabled then
							tbl17.refreshEsp()
						else
							for k in pairs(tbl17.espRecords) do
								tbl17.clearEsp(k)
							end

							if not tbl17.notifyEnabled and not flag37 then
								tbl17.generation = tbl17.generation + 1
							end
						end
					end,
				})

				local flag43 = false

				BossTab:Toggle({
					Title = text("Auto Boss"),
					Default = false,
					Flag = "AutoBoss",
					Callback = function(arg)
						flag37 = arg
						genv.HuneHubBossWaiting = nil
						genv.HuneHubBossCastTarget = nil
						genv.HuneHubBossCastError = nil
						tbl17.engaged = false
						str12 = ""
						id2 = nil
						tbl17.generation = (tbl17.generation or 0) + 1
						v51 = nil
						v48 = nil
						v49 = nil
						v50 = nil
						n31 = -math.huge
						tbl17.travelAttempts = 0
						tbl17.travelRetryAt = -math.huge
						tbl17.travelRegion = nil
						tbl17.castReady = false
						tbl17.movingToBank = false
						local flag44 = not arg

						if flag44 then
							flag41 = true

							if tbl17.travelInProgress then
								FixedIslandTravel.Cancel()
							end

							tbl17.travelInProgress = false
						end

						if arg then
							n29 = -math.huge
							action = "Checking for an existing boss, then waiting for spawn signals."
							fn107("Auto Boss Enabled")
							flag43 = flag16

							if not resumeSoldFish then
								local character = localPlayer.Character
								local humanoid = character and character:FindFirstChildOfClass("Humanoid")

								if humanoid then
									pcall(function()
										humanoid:UnequipTools()
									end)
								end
							end
						else
							action = "Auto Boss is off."

							if not flag43 and flag16 then
								flag16 = false

								pcall(function()
									if v43 then
										v43:Set(false)
									end
								end)
							end

							if flag42 then
								flag42 = false

								if not flag39 then
									if not pcall(function()
										FarmToggle:Set(false)
									end) or resumeSoldFish then
										pcall(function()
											FarmToggle:SetValue(false)
										end)
									end
								end

								local character = localPlayer.Character
								local humanoid = character and character:FindFirstChildOfClass("Humanoid")

								if humanoid then
									pcall(function()
										humanoid:UnequipTools()
									end)
								end
							end
						end

						if flag44 and not flag36 then
							fn95()
						end

						fn102()
					end,
				})

				tbl17.startTravel = function(arg, travelRegion, arg2, arg3)
					local travelInProgress = tbl17.travelInProgress or tbl17.movingToBank

					if not travelInProgress then
						local travelRetryAt = tbl17.travelRetryAt
						travelInProgress = os.clock() < travelRetryAt
					end

					if travelInProgress then
						return false
					end

					if tbl17.travelRegion ~= travelRegion then
						tbl17.travelRegion = travelRegion
						tbl17.travelAttempts = 0
					end

					if tbl17.travelAttempts >= 3 then
						action = "Travel stopped after three attempts. Toggle Auto Boss to retry."
						genv.HuneHubBossWaiting = true
						fn106("travel_limit_" .. travelRegion, "Boss travel stopped after three attempts. Toggle Auto Boss to retry.")
						return false
					end

					if flag42 then
						flag42 = false

						if not flag39 then
							pcall(function()
								FarmToggle:Set(false)
							end)
						end
					end

					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						pcall(function()
							humanoid:UnequipTools()
						end)
					end

					local generation = tbl17.generation

					local v53, v54 = FixedIslandTravel.Start(arg, function(arg4, arg5)
						tbl17.travelInProgress = false
						if not flag11 or not flag37 or generation ~= tbl17.generation then
							return
						end

						if not v51 or v51.id ~= travelRegion then
							genv.HuneHubBossWaiting = nil
							genv.HuneHubBossCastTarget = nil
							tbl17.engaged = false
							return
						end

						v48 = nil
						v49 = nil
						v50 = nil
						n31 = -math.huge
						genv.HuneHubBossCastTarget = nil
						genv.HuneHubBossWaiting = true

						if arg4 then
							tbl17.travelRetryAt = os.clock() + 1.5
							action = "Arrived on island. Locating safe dry bank near boss..."

							task.delay(0.2, function()
								local humanoid2 = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

								if humanoid2 then
									pcall(function()
										humanoid2:UnequipTools()
									end)
								end
							end)
						else
							tbl17.travelRetryAt = os.clock() + 12
							action = "Boss travel failed: " .. tostring(arg5)
						end

						fn102()
					end, arg2)

					if not v53 then
						tbl17.travelRetryAt = os.clock() + 5
						action = "Boss travel pending: " .. tostring(v54)
						return false
					end

					tbl17.travelInProgress = true
					tbl17.travelAttempts = tbl17.travelAttempts + 1
					genv.HuneHubBossWaiting = true
					genv.HuneHubBossCastTarget = nil
					action = arg3
					fn102()
					return true
				end

				tbl17.moveToBank = function(arg, arg2, arg3)
					if tbl17.movingToBank or tbl17.travelInProgress then
						return
					end
					tbl17.movingToBank = true
					tbl17.castReady = false
					genv.HuneHubBossWaiting = true
					genv.HuneHubBossCastTarget = nil
					action = "Moving to safe dry bank near boss..."
					fn102()

					task.spawn(function()
						local generation = tbl17.generation

						local function fn108()
							return flag11 and flag37 and not tbl17.travelInProgress and generation == tbl17.generation and v51 ~= nil and not tbl17.readyToFish(arg2, arg, arg3)
						end

						local character = localPlayer.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")

						if humanoid then
							pcall(function()
								humanoid:UnequipTools()
							end)
						end

						local flag44 = false
						local v53 = fn53()

						if v53 and (v53.Position - arg.Position).Magnitude <= 4 then
							flag44 = true
						end

						if not flag44 and tbl8.walkTo then
							local ok, result = pcall(function()
								return tbl8.walkTo(arg, fn108)
							end)

							if ok and result then
								flag44 = true
							end
						end

						if not flag44 and fn108() then
							action = "Gliding safely to boss fishing spot..."
							fn102()

							local ok, result = pcall(function()
								return fn101(arg, fn108, 45)
							end)

							if not (ok and result) then
								if not result and fn108 and tbl8.tweenTo then
									pcall(function()
										if tbl8.tweenTo(arg, fn108, 40, true) then
											flag44 = true
										end
									end)
								end
							end
						end

						local v54 = fn53()
						local humanoid2 = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

						if v54 and humanoid2 and humanoid2.Health > 0 and arg3 then
							local magnitude = (v54.Position - arg.Position).Magnitude

							if magnitude > 4 and magnitude <= 12 then
								humanoid2:MoveTo(arg.Position)
								local n32 = os.clock() + 2

								while os.clock() < n32 and v54.Parent and humanoid2.Health > 0 and (v54.Position - arg.Position).Magnitude > 3.8 do
									task.wait(0.08)
								end
							end

							pcall(function()
								local vector = Vector3.new(arg3.X, v54.Position.Y, arg3.Z)
								v54.CFrame = CFrame.lookAt(v54.Position, vector)
								v54.AssemblyLinearVelocity = Vector3.zero
								v54.AssemblyAngularVelocity = Vector3.zero
							end)
						end

						tbl17.movingToBank = false
						if not flag11 or not flag37 or generation ~= tbl17.generation then
							return
						end
						task.wait(0.15)

						if fn108() or tbl17.readyToFish(arg2, arg, arg3) then
							pcall(tbl17.step)
						end
					end)
				end

				tbl17.step = function()
					if not flag37 then
						return
					end

					if tbl17.travelInProgress or tbl17.movingToBank then
						return
					end
					local v53 = v51
					v51 = fn103()
					local flag44 = v51

					if v51 then
						flag44 = not v53 or v53.id ~= v51.id
					end

					if flag44 then
						now5 = os.time()
						now6 = nil
					elseif v53 and not v51 then
						now6 = os.time()
					end

					local generation = tbl17.generation
					local v54 = v51

					if not v54 then
						action = "Waiting for a boss spawn signal."
						id2 = nil
						v48 = nil
						v49 = nil
						v50 = nil
						tbl17.travelRegion = nil
						tbl17.travelAttempts = 0
						tbl17.bankScanFailures = 0
						genv.HuneHubBossCastTarget = nil
						genv.HuneHubBossCastError = nil
						genv.HuneHubBossWaiting = nil
						tbl17.engaged = false
						tbl17.castReady = false
						tbl17.movingToBank = false

						if flag42 then
							flag42 = false

							if not flag39 then
								if not pcall(function()
									FarmToggle:Set(false)
								end) or resumeSoldFish then
									pcall(function()
										FarmToggle:SetValue(false)
									end)
								end
							end

							local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

							if humanoid then
								pcall(function()
									humanoid:UnequipTools()
								end)
							end
						end

						if not flag43 and flag16 then
							flag16 = false

							pcall(function()
								if v43 then
									v43:Set(false)
								end
							end)
						end

						return
					end

					local v55 = tbl17.resolve(v54)

					if not v55 then
						genv.HuneHubBossCastTarget = nil
						genv.HuneHubBossCastError = nil
						genv.HuneHubBossWaiting = nil
						tbl17.engaged = false
						action = "Checking boss activity."
						return
					end

					local function fn108()
						local parent = v55.Parent and BossSpawnerFX.GetForRegion(v55)
						return flag11 and flag37 and not flag25 and generation == tbl17.generation and parent and BossSpawnerFX.IsActive(parent)
					end

					if not fn108() then
						if flag42 then
							flag42 = false

							if not flag39 then
								if not pcall(function()
									FarmToggle:Set(false)
								end) or resumeSoldFish then
									pcall(function()
										FarmToggle:SetValue(false)
									end)
								end
							end

							local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

							if humanoid then
								pcall(function()
									humanoid:UnequipTools()
								end)
							end
						end

						return
					end

					tbl17.engaged = true
					genv.HuneHubBossWaiting = true
					genv.HuneHubBossCastTarget = nil

					if tbl17.travelRegion ~= v54.id then
						tbl17.travelRegion = v54.id
						tbl17.travelAttempts = 0
						tbl17.travelRetryAt = -math.huge
						tbl17.castReady = false
						tbl17.bankScanFailures = 0
					end

					if id2 ~= v54.id then
						id2 = v54.id
						now5 = os.time()
						lastSignal = "BossSpawnerFX Active"
						local v56 = Catalog.BossRegion.GetById(v54.id)
						fn106("detected_" .. v54.id, "Active boss region: " .. (v56 and v56.name or v54.id) .. ". Searching for a dry fishing spot.")
					end

					if tbl17.travelInProgress or tbl17.movingToBank or flag31 or flag25 or tbl8.pending or flag26 then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						action = tbl17.movingToBank and "Moving to safe dry bank near boss..." or "Waiting for the current movement or sale to finish."
						return
					end

					local name = Catalog.Island.GetById(v54.islandId)
					name = name and name.name
					if not name then
						action = "Boss island is missing from the game catalog."
						return
					end
					local v56 = fn53()
					if not v56 then
						return
					end
					local islandId = v54.islandId
					if fn60() ~= islandId and (v56.Position - v55.Position).Magnitude > 220 then
						tbl17.startTravel(name, v54.id, nil, "Traveling to the island with the active boss.")
						return
					end

					if v48 ~= v55 or not v49 and os.clock() - n31 >= 8 then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						v48 = v55
						n31 = os.clock()
						action = "Loading the boss shoreline and checking dry landing spots."
						fn102()

						if workspace.StreamingEnabled then
							pcall(function()
								localPlayer:RequestStreamAroundAsync(v55.Position, 2)
							end)

							local v57 = tbl17.probe(v54.islandId)

							if v57 then
								local v58 = v55.CFrame:PointToObjectSpace(v57)
								local n32 = v55.Size * 0.5
								local z = v58.Z
								local v59 = v55.CFrame:PointToWorldSpace(Vector3.new(math.clamp(v58.X, -n32.X, n32.X), 0, math.clamp(z, -n32.Z, n32.Z)))

								pcall(function()
									localPlayer:RequestStreamAroundAsync(v59, 2)
								end)
							end
						end

						if not fn108() then
							return
						end
						local bankScanFailures, v57 = fn104(v55)
						if not fn108() then
							return
						end
						v49 = bankScanFailures
						v50 = v57
						local v58 = tbl17
						bankScanFailures = bankScanFailures and 0

						if not bankScanFailures then
							bankScanFailures = (tbl17.bankScanFailures or 0) + 1
						end

						v58.bankScanFailures = bankScanFailures
					end

					local v57 = v49
					local v58 = v50

					if not v57 or not v58 then
						genv.HuneHubBossWaiting = true
						genv.HuneHubBossCastTarget = nil
						action = "No dry spot within casting range yet; retrying the shoreline scan."

						if (tbl17.bankScanFailures or 0) >= 2 then
							fn106("no_bank_" .. v54.id, "No verified dry casting spot is loaded near this boss. Waiting for the shoreline.")
						end

						return
					end

					if tbl17.readyToFish(v55, v57, v58) then
						if not resumeSoldFish then
							flag42 = fn94()
						end

						if not flag16 then
							flag43 = false
							flag16 = true

							pcall(function()
								if v43 then
									v43:Set(true)
								end
							end)

							if flag32 then
								fn81()
							end
						end

						if not tbl17.castReady then
							cFrame2 = v56.CFrame
							cFrame = flag30 and cFrame2 or nil
							fn55()
							n25 = os.clock() + 0.8
							tbl17.castReady = true
						end

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
					tbl17.castReady = false
					tbl17.moveToBank(v57, v55, v58)
				end

				genv.HuneHubBossValidateCast = function()
					return flag11 and flag37 and not flag31 and not flag25 and tbl17.readyToFish(v48, v49, v50)
				end

				task.spawn(function()
					while flag11 do
						task.wait(1.5)

						if flag37 and not tbl17.stepRunning and (v51 or tbl17.engaged or tbl17.travelInProgress or tbl17.movingToBank or genv.HuneHubBossWaiting) then
							tbl17.stepRunning = true
							local ok, result = pcall(tbl17.step)
							tbl17.stepRunning = false

							if not ok then
								genv.HuneHubBossWaiting = tbl17.engaged and true or nil
								genv.HuneHubBossCastTarget = nil
								action = tbl17.engaged and "Shoreline scan interrupted; retrying." or "Radar scan interrupted; retrying while normal farming continues."

								if os.clock() - n30 >= 15 then
									n30 = os.clock()
									warn("[Hune Hub] Boss scan: " .. tostring(result))
								end
							end
						end
					end
				end)
			end

			fn91()
		end

		local function fn62(arg, arg2, arg3)
			local v40 = tbl11[arg]
			GachaTab:Section({ Title = v40.name .. text(" Gacha") })
			local str10

			if arg == "Aura" then
				str10 = fn56(AuraGachaConfig.Pull.CostGem) .. text(" Gems Per Spin")
			elseif arg == "Skill" then
				str10 = text("Coin Price Is Quoted Before Every Spin")
			else
				local v41 = CrateConfig.GetCrate(v40.crateId)
				str10 = fn56(CrateConfig.GetPrice(v40.crateId, 1)) .. " " .. (v41 and v41.Currency or "Coins") .. text(" Per Spin")
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
						fn52(arg)
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

		fn62("Aura", fn51(AuraGachaConfig.RarityOdds), { toggle = "AutoSpinAuraGacha", rarity = "GachaStopRarity", amount = "MaximumGachaSpins" })

		fn62("Skill", fn51(SkillGachaConfig.RarityOdds), {
			toggle = "AutoSpinSkillGacha",
			rarity = "SkillGachaStopRarity",
			amount = "MaximumSkillGachaSpins",
		})

		fn62("Ocean", fn51(nil, "crate_ocean_chest"), {
			toggle = "AutoSpinOceanChest",
			rarity = "OceanChestStopRarity",
			amount = "MaximumOceanChestSpins",
		})

		fn62("Dragon", fn51(nil, "crate_dragon_chest"), {
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
				local str10 = string.format("%s [%s] - %s %s", v40.rod.name, v40.rod.rarity, fn56(v40.listing.price), v40.listing.currency or "Coin")
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

			local function fn63(arg)
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
							Content = text("Next claim in ") .. fn57(v44) .. ".",
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
					fn63(false)
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
								fn63(true)
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

						local flag37 = not ok2
						local flag38

						if flag37 then
							flag38 = flag37
						else
							flag38 = result2 ~= Enum.GroupMembershipStatus.Joined and result2 ~= Enum.GroupMembershipStatus.AlreadyMember
						end

						if flag38 then
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
							fn63(true)
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
						local v42 = fn57
						v40:SetDesc(string.format(text("Fish Caught: %d | Coins Earned: %s | Time: %s"), v41, fn56(n20), v42(tick() - now3)))
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
				local v41 = fn53()

				if v41 then
					v41.Anchored = anchored
				end
			end,
		})

		MiscTab:Section({ Title = text("System Utilities") })

		local function fn63()
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

			local function fn64(arg)
				return debris and arg:IsDescendantOf(debris) or arg:FindFirstAncestor("ClientAuraEffect") ~= nil
			end

			local function fn65(descendant)
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

						if fn64(descendant) then
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

			local function fn66(arg)
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

			local function fn67(arg)
				local parent = arg.Parent

				while parent and parent ~= islands do
					if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
						return true
					end
					parent = parent.Parent
				end

				return false
			end

			local function fn68(arg)
				pcall(function()
					if arg:IsA("Clouds") then
						arg.Cover = 0
						arg.Density = 0
					elseif arg:IsA("BasePart") and islands and arg:IsDescendantOf(islands) and arg.Anchored and not fn67(arg) then
						local v41 = fn66(arg)
						arg.Color = color6

						if v41 then
							arg.LocalTransparencyModifier = 1
						end
					end
				end)
			end

			local function fn69(descendant)
				if descendant.Name == "Debris" and descendant.Parent == workspace then
					debris = descendant
				elseif descendant.Name == "World" and descendant.Parent == workspace then
					world = descendant
				elseif descendant.Name == "Islands" and world and descendant.Parent == world then
					islands = descendant
				end

				fn65(descendant)

				if flag37 then
					fn68(descendant)
				end
			end

			local function fn70()
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
						fn68(clouds)
					end
				end)
			end

			local function fn71()
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

				fn48(workspace.DescendantAdded:Connect(fn69))
				fn48(Lighting.DescendantAdded:Connect(fn65))

				task.spawn(function()
					local n26 = 0

					for _, descendant in ipairs(workspace:GetDescendants()) do
						if not flag11 then
							return
						end
						fn69(descendant)
						n26 += 1

						if n26 % 250 == 0 then
							task.wait()
						end
					end

					for _, descendant in ipairs(Lighting:GetDescendants()) do
						if not flag11 then
							return
						end
						fn65(descendant)
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
					fn71()
					fn70()
				end,
			})
		end

		fn63()

		MiscTab:Button({
			Title = text("Rejoin Server"),
			Callback = function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
			end,
		})

		MiscTab:Button({ Title = text("Unload Hub"), Callback = fn61 })

		local function fn64()
			tbl3.migrateLegacyProfiles("fishingMaster", configManager)

			local function fn65(arg)
				return tbl3.update(function(arg2)
					arg2.fishingMaster = type(arg2.fishingMaster) == "table" and arg2.fishingMaster or {}
					arg2.fishingMaster.autoload = tostring(arg or "None")
				end)
			end

			local function fn66()
				local fishingMaster = tbl3.read().fishingMaster
				return type(fishingMaster) == "table" and type(fishingMaster.autoload) == "string" and fishingMaster.autoload ~= "" and fishingMaster.autoload or "None"
			end

			local function fn67(arg)
				if not arg then
					return ""
				end
				return tostring(arg):gsub("[%c%s]+", "")
			end

			local function fn68()
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

			local function fn69(arg)
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
			local v43 = fn68()
			local str11 = v43[1] or "Default"
			local str12 = fn66()
			local str13 = str12
			local flag36 = false

			local function fn70()
				local v44 = fn68()

				if v41 then
					pcall(function()
						v41:Refresh(v44)
					end)
				end

				if v42 then
					pcall(function()
						v42:Refresh(fn69(v44))
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
				local mode = arg == "Tiếng Việt" and "vi" or arg == "English" and "en" or "auto"
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
					str10 = fn67(arg)
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
						fn70()
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
							fn65("None")
						end

						lib:Notify({ Title = text("Hune Hub"), Content = text("Deleted: ") .. v45, Duration = 3 })
						fn70()
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
				Values = fn69(v43),
				Default = str12,
				Callback = function(arg)
					str13 = arg
				end,
			})

			SettingsTab:Button({
				Title = text("Set Auto Load Config"),
				Callback = function()
					str12 = str13 or "None"
					if not fn65(str12) then
						lib:Notify({ Title = text("Hune Hub"), Content = text("Save failed; retry later."), Duration = 5 })
						return
					end
					lib:Notify({ Title = text("Hune Hub"), Content = text("Auto load set to: ") .. str12, Duration = 4 })
				end,
			})

			task.spawn(function()
				task.wait(2)
				local v45 = fn66()
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

		fn64()
	end, v29, ...)

	if not v30 then
		if huneConsole.Error then
			v4(huneConsole.Error, v2(v31))
		end
	end

	return v31

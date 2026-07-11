local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait() :: Model
local hum = character.Humanoid :: Humanoid
local TS = game:GetService("TweenService")
local TPS = game:GetService("TeleportService")
local RS = game:GetService("RunService")
local repStore = game:GetService("ReplicatedStorage")
local camera = workspace.Camera
local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local PROXY_URL = "https://sbeuilib.liali22gk.workers.dev/" 
local AUTH_KEY = "@Suga1771KeyVoid!"

function safeloadstring(url)
	local code = game:HttpGet(url)
	local func, errorMessage = loadstring(code)

	if func then
		print("Script compiled! Executing...")
		return func()
	else
		warn("LOADSTRING FAILED: " .. tostring(errorMessage))
		return nil
	end
end

local Lighting = game:GetService("Lighting")

local Defaults = {
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd
}

local function ApplyGraphicsPreset(mode)
	Lighting.Brightness = Defaults.Brightness
	Lighting.GlobalShadows = Defaults.GlobalShadows
	Lighting.Ambient = Defaults.Ambient
	Lighting.OutdoorAmbient = Defaults.OutdoorAmbient
	Lighting.FogEnd = Defaults.FogEnd

	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("BloomEffect") or v:IsA("BlurEffect") then v:Destroy() end
	end

	if mode == "Lighting Fix" then
		Lighting.Brightness = 2
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.new(1, 1, 1)
	elseif mode == "Fake RTX" then
		local bloom = Instance.new("BloomEffect", Lighting)
		bloom.Intensity = 0.5
		bloom.Size = 24
		bloom.Threshold = 0.8
		local blur = Instance.new("BlurEffect", Lighting)
		blur.Size = 4
	end

	if mode == "Potato Mode" or mode == "Safe Potato Mode" or mode == "Default" then
		local isPotato = (mode:find("Potato"))
		local descendants = game:GetDescendants()
		local budget = 250
		local count = 0

		for _, v in pairs(descendants) do
			if mode == "Safe Potato Mode" or mode == "Default" then
				count = count + 1
				if count >= budget then count = 0 task.wait() end
			end

			if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
				v.Material = isPotato and Enum.Material.SmoothPlastic or Enum.Material.Plastic
				v.Reflectance = isPotato and 0 or v.Reflectance
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = isPotato and 1 or 0
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Enabled = not isPotato
			end
		end
	end

	print("Preset Applied: " .. mode)
end

function initServerList()
	--safeloadstring("https://raw.githubusercontent.com/SugaBlaz/Server_Lister/refs/heads/main/Main")
end

if not repStore:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
	local detection = Instance.new("Decal")
	detection.Name = "juisdfj0i32i0eidsuf0iok"
	detection.Parent = repStore
end

-- // NEBULA UI INITIALIZATION //
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SugaBlaz/UI-Library/refs/heads/main/Nebula%20UI.lua"))()

local uiDestroyed = false 

function init()
	local function Notify(Text)
		Library:Notify({
			Title = "Notification",
			Text = Text,
			Duration = 3
		})
	end
	local Window = Library:CreateWindow({
		Name = "Universal Hub",
		Theme = "Midnight", 
		SaveName = "UniversalHubConfig",
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		KeySystem = true,
		KeySettings = {
			Title = "Universal Hub Key",
			Key = "skibidi", --"https://sbeuilib.liali22gk.workers.dev/verify-key?key=",
			InsertKeyAtEnd = true,
			SaveKey = true,
			KeyLink = "https://rekonise.com/universal-hub-key-0rs04",
			Callback = function()
				Library:Notify({
					Title = "Key",
					Text = "Key Completion done! Loading Universal Hub...",
					Duration = 3
				})
			end
		}
	})

	-- Function to safely clean up the UI
	local function destroyUI()
		uiDestroyed = true
		Library:Destroy()
		script:Destroy()
	end

	-- // MAIN TAB //
	local MainTab = Window:CreateTab("Main")
	MainTab:CreateSection("Main")

	MainTab:CreateToggle({
		Name = "Xray",
		CurrentValue = false,
		Flag = "XrayToggle",
		Callback = function(state)
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					local charModel = obj:FindFirstAncestorOfClass("Model")
					local isCharacter = charModel and charModel:FindFirstChildOfClass("Humanoid")

					if isCharacter then
						if obj.Name == "HumanoidRootPart" then
							obj.Transparency = 1
						else
							obj.Transparency = 0
						end
					else
						obj.Transparency = state and 0.8 or 0
					end
				end
			end
		end
	})

	local espFolder = {}
	local espConnection

	MainTab:CreateToggle({
		Name = "ESP & Tracers",
		CurrentValue = false,
		Flag = "ESPToggle",
		Callback = function(state)
			local function removeESP(player)
				if espFolder[player] then
					if espFolder[player].Gui then espFolder[player].Gui:Destroy() end
					if espFolder[player].Highlight then espFolder[player].Highlight:Destroy() end
					if espFolder[player].Tracer then espFolder[player].Tracer:Remove() end
					if espFolder[player].CharConn then espFolder[player].CharConn:Disconnect() end
					espFolder[player] = nil
				end
			end

			local function createESP(targetPlayer)
				if targetPlayer == plrs.LocalPlayer then return end
				removeESP(targetPlayer)

				local function setup(character)
					local head = character:WaitForChild("Head", 10)
					local root = character:WaitForChild("HumanoidRootPart", 10)
					if not head or not root then return end

					local teamColor = targetPlayer.TeamColor and targetPlayer.TeamColor.Color or Color3.fromRGB(255, 255, 255)

					local billboard = Instance.new("BillboardGui")
					billboard.Name = "p_esp"
					billboard.Size = UDim2.new(0, 200, 0, 70)
					billboard.StudsOffset = Vector3.new(0, 3, 0)
					billboard.AlwaysOnTop = true
					billboard.Adornee = head
					billboard.Parent = head

					local textLabel = Instance.new("TextLabel")
					textLabel.Size = UDim2.new(1, 0, 1, 0)
					textLabel.BackgroundTransparency = 1
					textLabel.TextColor3 = teamColor
					textLabel.TextStrokeTransparency = 0.5
					textLabel.TextSize = 14
					textLabel.Font = Enum.Font.GothamBold
					textLabel.Text = targetPlayer.DisplayName
					textLabel.Parent = billboard

					local highlight = Instance.new("Highlight")
					highlight.Adornee = character
					highlight.FillTransparency = 1
					highlight.OutlineColor = teamColor
					highlight.Parent = character

					local tracer = Drawing.new("Line")
					tracer.Visible = false
					tracer.Color = teamColor
					tracer.Thickness = 1
					tracer.Transparency = 1

					espFolder[targetPlayer] = {
						Gui = billboard,
						Label = textLabel,
						Highlight = highlight,
						Tracer = tracer,
						CharConn = nil 
					}
				end

				if targetPlayer.Character then task.spawn(setup, targetPlayer.Character) end
				local conn = targetPlayer.CharacterAdded:Connect(function(char)
					task.spawn(setup, char)
				end)

				if not espFolder[targetPlayer] then espFolder[targetPlayer] = {} end
				espFolder[targetPlayer].CharConn = conn
			end

			if state then
				for _, p in ipairs(plrs:GetPlayers()) do
					createESP(p)
				end

				espFolder.AddedConn = plrs.PlayerAdded:Connect(createESP)
				espFolder.RemovedConn = plrs.PlayerRemoving:Connect(removeESP)

				espConnection = game:GetService("RunService").RenderStepped:Connect(function()
					local camera = workspace.CurrentCamera
					local myChar = plrs.LocalPlayer.Character
					local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
					local screenBottom = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

					for player, data in pairs(espFolder) do
						if typeof(player) == "Instance" and player:IsA("Player") then
							local char = player.Character
							local root = char and char:FindFirstChild("HumanoidRootPart")

							if char and root and data.Tracer then
								local pos, onScreen = camera:WorldToViewportPoint(root.Position)

								if onScreen then
									data.Tracer.From = screenBottom
									data.Tracer.To = Vector2.new(pos.X, pos.Y)
									data.Tracer.Visible = true
								else
									data.Tracer.Visible = false
								end

								if myRoot then
									local dist = math.floor((myRoot.Position - root.Position).Magnitude)
									data.Label.Text = string.format("%s\n[%d studs]", player.DisplayName, dist)
								else
									data.Label.Text = player.DisplayName
								end
							elseif data.Tracer then
								data.Tracer.Visible = false
							end
						end
					end
				end)
			else
				if espConnection then espConnection:Disconnect() espConnection = nil end
				if espFolder.AddedConn then espFolder.AddedConn:Disconnect() end
				if espFolder.RemovedConn then espFolder.RemovedConn:Disconnect() end

				for player, _ in pairs(espFolder) do
					if typeof(player) == "Instance" and player:IsA("Player") then
						removeESP(player)
					end
				end
			end
		end
	})

	MainTab:CreateTextbox({
		Name = "Go to:",
		CurrentValue = "",
		PlaceholderText = "Username or 'random'",
		Flag = "GotoTxt",
		Callback = function(text)
			if text == "" then return end

			text = text:lower()
			local playersList = plrs:GetPlayers()
			local target = nil

			if text == "random" then
				if #playersList > 1 then
					local others = {}
					for _, p in ipairs(playersList) do
						if p ~= plr then table.insert(others, p) end
					end
					target = others[math.random(1, #others)]
				else
					target = playersList[1]
				end
			end

			if not target then
				for _, plr in ipairs(playersList) do
					if plr.Name:lower() == text or plr.DisplayName:lower() == text then
						target = plr
						break
					end
				end
			end

			if not target then
				local bestScore = 0
				for _, plr in ipairs(playersList) do
					local nameLower = plr.Name:lower()
					local displayLower = plr.DisplayName:lower()

					local function getMatchScore(targetName :string)
						local score = 0
						for i = 1, math.min(#text, #targetName) do
							if text:sub(i, i) == targetName:sub(i, i) then
								score += 1
							else
								break
							end
						end
						return score
					end

					local score = math.max(getMatchScore(nameLower), getMatchScore(displayLower))

					if score > bestScore then
						bestScore = score
						target = plr
					end
				end
			end

			if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
				character:PivotTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
			else
				Library:Notify({
					Title = "Error",
					Text = "Player not found or has no character",
					Duration = 3
				})
			end
		end
	})

	-- // CHARACTER TAB //
	local CharTab = Window:CreateTab("Character")
	CharTab:CreateSection("Character")

	CharTab:CreateSlider({
		Name = "WalkSpeed",
		Range = {0, 200},
		CurrentValue = 16,
		Flag = "WSSlider",
		Callback = function(num)
			hum.WalkSpeed = num
		end,
	})

	CharTab:CreateSlider({
		Name = "JumpPower",
		Range = {0, 200},
		CurrentValue = 50,
		Flag = "JPSlider",
		Callback = function(num)
			hum.JumpPower = num
		end,
	})

	local speed = 0
	CharTab:CreateTextbox({
		Name = "Fly Speed",
		CurrentValue = "0",
		PlaceholderText = "0",
		Flag = "FlySpeedTxt",
		Callback = function(text)
			local num = tonumber(text)
			if num then
				speed = num
			end
		end,
	})

	local flyConnection
	local att, lv, ao

	CharTab:CreateToggle({
		Name = "Fly",
		CurrentValue = false,
		Flag = "FlyToggle",
		Callback = function(state)
			if flyConnection then flyConnection:Disconnect() flyConnection = nil end
			if att then att:Destroy() att = nil end
			if lv then lv:Destroy() lv = nil end
			if ao then ao:Destroy() ao = nil end

			local root = hum.RootPart
			if not root or not hum then return end

			if state then
				hum.PlatformStand = true 

				att = Instance.new("Attachment")
				att.Name = "FlyAtt"
				att.Position = Vector3.zero
				att.Parent = root

				lv = Instance.new("LinearVelocity")
				lv.Attachment0 = att
				lv.MaxForce = math.huge
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
				lv.RelativeTo = Enum.ActuatorRelativeTo.World
				lv.Parent = root

				ao = Instance.new("AlignOrientation")
				ao.Attachment0 = att
				ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
				ao.RigidityEnabled = true 
				ao.Parent = root

				flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
					if not root or not hum then return end

					local moveDir = hum.MoveDirection
					local camCF = camera.CFrame

					if moveDir.Magnitude > 0 then
						local lateralMove = camCF:VectorToObjectSpace(moveDir)
						lv.VectorVelocity = camCF:VectorToWorldSpace(Vector3.new(lateralMove.X, 0, lateralMove.Z)) * speed
					else
						lv.VectorVelocity = Vector3.zero
					end

					ao.CFrame = camCF
				end)
			else
				if hum then
					hum.PlatformStand = false
					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
			end
		end,
	})

	local noclipRadius = 10
	CharTab:CreateSlider({
		Name = "Noclip Radius",
		CurrentValue = 10,
		Range = {0, 50},
		Flag = "NoclipRadSlider",
		Callback = function(num)
			if num then
				noclipRadius = num
			end
		end,
	})

	local noclipConnection
	local affectedParts = {}

	CharTab:CreateToggle({
		Name = "Noclip",
		CurrentValue = false,
		Flag = "NoclipToggle",
		Callback = function(state)
			if state then
				noclipConnection = game:GetService("RunService").Stepped:Connect(function()
					local root = hum.RootPart
					if not character or not root then return end

					local params = RaycastParams.new()
					params.FilterDescendantsInstances = {character}
					params.FilterType = Enum.RaycastFilterType.Exclude
					local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
					local ground = ray and ray.Instance

					for _, v in pairs(character:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end

					local nearby = workspace:GetPartBoundsInRadius(root.Position, noclipRadius)
					local currentFrameParts = {}

					for _, part in pairs(nearby) do
						if part:IsA("BasePart") and part ~= ground and not part:IsDescendantOf(character) then
							local relativeDiff = part.Position.Y - (root.Position.Y - 2.5)

							if relativeDiff > 0.5 then
								if affectedParts[part] == nil then
									affectedParts[part] = part.CanCollide
								end
								part.CanCollide = false
								currentFrameParts[part] = true
							end
						end
					end

					for part, _ in pairs(affectedParts) do
						if not currentFrameParts[part] then
							part.CanCollide = affectedParts[part]
							affectedParts[part] = nil
						end
					end
				end)
			else
				if noclipConnection then 
					noclipConnection:Disconnect() 
					noclipConnection = nil 
				end

				for part, originalValue in pairs(affectedParts) do
					if part and part.Parent then
						part.CanCollide = originalValue
					end
				end

				table.clear(affectedParts)

				if character then
					for _, v in pairs(character:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = true
						end
					end
				end
			end
		end
	})

	local infJumpConnection = nil
	CharTab:CreateToggle({
		Name = "Infinite Jump",
		CurrentValue = false,
		Flag = "InfJumpToggle",
		Callback = function(Value)
			if Value then
				infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
					local character = plrs.LocalPlayer.Character
					if character then
						local hum = character:FindFirstChildOfClass("Humanoid")
						if hum then
							hum:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end
				end)
			else
				if infJumpConnection then
					infJumpConnection:Disconnect()
					infJumpConnection = nil
				end
			end
		end
	})
	
	local ComabatTab = Window:CreateTab("Combat")
	ComabatTab:CreateSection("Combat")
	
	local selectedOptionAimbot = "Nearest"
	local AimbotOptions = {"Nearest"}
	
	local dropdown = ComabatTab:CreateDropdown({
		Name = "Aimbot Target",
		Options = AimbotOptions,
		Callback = function(selectedOption)
			selectedOptionAimbot = selectedOption
		end,
	})
	
	local function updateAimbotOptions()
		dropdown:Update(AimbotOptions)
	end
	
	plrs.PlayerAdded:Connect(function(p)
		if not (p == plr) then
			table.insert(AimbotOptions, p.Name)
			updateAimbotOptions()
		end
	end)
	
	plrs.PlayerRemoving:Connect(function(p)
		for i, name in ipairs(AimbotOptions) do
			if name == p.Name then
				table.remove(AimbotOptions, i)
				break
			end
		end
		updateAimbotOptions()
	end)
	
	local aimconn = nil

	ComabatTab:CreateToggle({
		Name = "Aimbot",
		CurrentValue = false,
		Flag = "AimbotToggle",
		Callback = function(state)
			if state then
				local function getTarget()
					if selectedOptionAimbot == "Nearest" then
						local closestPlayer = nil
						local shortestDistance = math.huge
						local myHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

						if not myHrp then return nil end

						for _, player in ipairs(plrs:GetPlayers()) do
							if player ~= plr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
								local hum = player.Character:FindFirstChildOfClass("Humanoid")
								if hum and hum.Health > 0 then
									local distance = (player.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
									if distance < shortestDistance then
										shortestDistance = distance
										closestPlayer = player
									end
								end
							end
						end
						return closestPlayer
					else
						local targetPlayer = plrs:FindFirstChild(selectedOptionAimbot)
						if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
							local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health > 0 then
								return targetPlayer
							end
						end
					end
					return nil
				end

				aimconn = RS.RenderStepped:Connect(function()
					local target = getTarget()
					local myChar = plr.Character
					local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

					if target and myHrp then
						local targetHrp = target.Character.HumanoidRootPart
						local targetPos = targetHrp.Position

						camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)

						local dir = (targetPos - myHrp.Position).Unit
						myHrp.CFrame = CFrame.new(myHrp.Position, myHrp.Position + Vector3.new(dir.X, 0, dir.Z))
					else
						aimconn:Disconnect()
						aimconn = nil
					end
				end)
			else
				if aimconn then
					aimconn:Disconnect()
					aimconn = nil
				end
			end
		end,
	})

	local isAimInitialized = false -- Track if we've set up the hooks yet
	local aimSettings = { Enabled = false }

	ComabatTab:CreateToggle({
		Name = "Silent Aim", 
		CurrentValue = false,
		Flag = "SilentAimToggle",
		Callback = function(state)
			aimSettings.Enabled = state -- Just flip the switch

			-- Only run the setup code ONCE (the first time the toggle is turned on)
			if state and not isAimInitialized then
				isAimInitialized = true

				local Camera = workspace.CurrentCamera
				local Players = game:GetService("Players")
				local RunService = game:GetService("RunService")
				local UserInputService = game:GetService("UserInputService")
				local LocalPlayer = Players.LocalPlayer
				local Mouse = LocalPlayer:GetMouse()

				-- 1. Create the FOV Circle
				local fov_circle = Drawing.new("Circle")
				fov_circle.Thickness = 1
				fov_circle.NumSides = 100
				fov_circle.Radius = 130
				fov_circle.Color = Color3.fromRGB(54, 57, 241)

				-- 2. Target Selector
				local function getClosest()
					local closest, dist = nil, 130
					for _, p in next, Players:GetPlayers() do
						if p == LocalPlayer or p.Team == LocalPlayer.Team then continue end
						local char = p.Character
						local root = char and char:FindFirstChild("HumanoidRootPart")
						if root and char.Humanoid.Health > 0 then
							local pos, vis = Camera:WorldToViewportPoint(root.Position)
							if vis then
								local mDist = (UserInputService:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
								if mDist < dist then
									closest = root
									dist = mDist
								end
							end
						end
					end
					return closest
				end

				-- 3. Visual Loop
				RunService.RenderStepped:Connect(function()
					fov_circle.Visible = aimSettings.Enabled
					if aimSettings.Enabled then
						fov_circle.Position = UserInputService:GetMouseLocation()
					end
				end)

				-- 4. The Hooks (Metatable manipulation)
				local oldNamecall
				oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
					local method = getnamecallmethod()
					local args = {...}
					if aimSettings.Enabled and self == workspace and not checkcaller() then
						if method == "Raycast" then
							local target = getClosest()
							if target then
								args[2] = (target.Position - args[1]).Unit * 1000
								return oldNamecall(self, unpack(args))
							end
						end
					end
					return oldNamecall(self, ...)
				end))

				local oldIndex
				oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
					if aimSettings.Enabled and self == Mouse and not checkcaller() then
						local target = getClosest()
						if target and (index == "Target" or index == "Hit") then
							return (index == "Target") and target or target.CFrame
						end
					end
					return oldIndex(self, index)
				end))
			end
		end
	})


	-- // ADMIN TAB //
	local AdminTab = Window:CreateTab("Admin")
	AdminTab:CreateSection("Admin")

	AdminTab:CreateButton({
		Name = "Infinite Yield",
		Callback = function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
		end,
	})

	AdminTab:CreateButton({
		Name = "Namless Admin (Reworked, use at own risk)",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
		end,
	})

	AdminTab:CreateButton({
		Name = "Namless Admin (Orginal)",
		Callback = function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source'))()
		end,
	})

	AdminTab:CreateButton({
		Name = "Fedora Admin",
		Callback = function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/alexx1212/fedoratoomutch/main/toomucth'))()
		end,
	})

	AdminTab:CreateButton({
		Name = "Cmd X",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))()
		end,
	})


	-- // TROLLING TAB //
	local TrollTab = Window:CreateTab("Trolling")
	TrollTab:CreateSection("Trolling")

	TrollTab:CreateToggle({
		Name = "Touch Fling",
		CurrentValue = false,
		Flag = "FlingToggle",
		Callback = function(state)
			local vel = nil
			local hrp = hum.RootPart
			local movel = 0.1
			
			task.spawn(function()
				while state do
					RS.Heartbeat:Wait()
					
					vel = hrp.Velocity
					hrp.Velocity = vel * 1000000 + Vector3.new(0, 1000000, 0)
					
					RS.RenderStepped:Wait()
					
					if character and character.Parent and hrp and hrp.Parent then
						hrp.Velocity = vel
					end
					
					RS.Stepped:Wait()
						
					if character and character.Parent and hrp and hrp.Parent then
						hrp.Velocity = vel + Vector3.new(0, movel, 0)
						movel = movel * -1
					end
				end
			end)
		end,
	})

	local SKY_HEIGHT = 700
	
	TrollTab:CreateTextbox({
		Name = "Sky Height",
		CurrentValue = 700,
		PlaceholderText = 0,
		Flag = "SkyHtSlider",
		Callback = function(text)
			local num = tonumber(text)
			if num then
				SKY_HEIGHT = num
			end
		end,
	})

	local storedPos
	local invisConn
	local ghost

	TrollTab:CreateToggle({
		Name = "Invisiblity",
		CurrentValue = false,
		Flag = "InvisToggle",
		Callback = function(state)
			if state then
				local realChar = character
				local hrp = hum.RootPart
				character.Archivable = true
				storedPos = hrp.CFrame

				invisConn = RS.RenderStepped:Connect(function()
					hrp.CFrame = storedPos * CFrame.new(0, SKY_HEIGHT, 0)
				end)

				ghost = realChar:Clone()
				ghost.Parent = workspace

				for _, part in ipairs(ghost:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = false
						part.CanCollide = true
						part.Transparency = 0.8
					end
				end

				ghost:WaitForChild("HumanoidRootPart").CFrame = storedPos

				camera.CameraSubject = ghost:WaitForChild("Humanoid")
				plr.Character = ghost
			else
				if ghost then
					local realChar = plr.Character.Parent:FindFirstChild(plr.Name) or character

					invisConn:Disconnect()
					invisConn = nil

					if realChar then
						realChar:PivotTo(ghost.HumanoidRootPart.CFrame)
					end

					ghost:Destroy()
					ghost = nil
				end

				plr.Character = character
				camera.CameraSubject = hum
			end
		end,
	})
	
	local AntiTrollTab = Window:CreateTab("Anti-Troll")
	AntiTrollTab:CreateSection("Anti-Troll")
	
	AntiTrollTab:CreateToggle({
		Name = "Anti-Fling",
		CurrentValue = false,
		Flag = "AntiFlingT",
		Callback = function(state)
			-- We use a global-to-callback variable to track if THIS toggle session is active
			_G.AntiFlingActive = state 

			if state then
				-- Create a single connection instead of hundreds of individual ones
				if not _G.AntiFlingConnection then
					_G.AntiFlingConnection = RS.Heartbeat:Connect(function()
						if not _G.AntiFlingActive then return end

						if not character then return end

						for _, player in pairs(plrs:GetPlayers()) do
							if player ~= plr and player.Character then
								local root = player.Character:FindFirstChild("HumanoidRootPart")
								if root then
									-- Reset physical properties to prevent high-velocity collisions
									root.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
									root.CanCollide = false
									root.Velocity = Vector3.new(0, 0, 0)
									root.RotVelocity = Vector3.new(0, 0, 0)
								end
							end
						end
					end)
				end
			else
				_G.AntiFlingActive = false
				if _G.AntiFlingConnection then
					_G.AntiFlingConnection:Disconnect()
					_G.AntiFlingConnection = nil
				end
			end
		end,
	})
	
	local maxTPDist = 5
	
	AntiTrollTab:CreateSlider({
		Name = "Anti TP Max Distance",
		Range = {5, 50},
		CurrentValue = 5,
		Flag = "AntiTPMaxDist",
		Callback = function(newValue)
			maxTPDist = newValue
		end,
	})
	
	AntiTrollTab:CreateToggle({
		Name = "Anti-TP",
		CurrentValue = false,
		Flag = "AntiTPT",
		Callback = function(state)
			_G.AntiTPActive = state

			if _G.AntiTPConnection then 
				_G.AntiTPConnection:Disconnect() 
				_G.AntiTPConnection = nil
			end

			if state then
				local lastCF = plr.Character and plr.Character:GetPivot()

				_G.AntiTPConnection = RS.Heartbeat:Connect(function()
					if not _G.AntiTPActive then return end

					local char = plr.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")

					if root and lastCF then
						local distance = (root.Position - lastCF.Position).Magnitude

						if distance > maxTPDist then 
							root.CFrame = lastCF
							Notify("Anti-TP triggered! Resetting position.")
						else
							lastCF = root.CFrame
						end
					elseif char then
						lastCF = char:GetPivot()
					end
				end)
			end
		end,
	})
	
	AntiTrollTab:CreateToggle({
		Name = "Anti-Anchor",
		CurrentValue = false,
		Flag = "AntiAnchorT",
		Callback = function(state)
			_G.AntiAnchor = state
			task.spawn(function()
				while _G.AntiAnchor do
					local hrp = hum.RootPart
					if hrp and hrp.Anchored then
						hrp.Anchored = false
					end
					task.wait(0.1) -- Doesn't need to be frame-perfect
				end
			end)
		end,
	})
	
	local fallThreshold = -400

	AntiTrollTab:CreateSlider({
		Name = "Anti-Void Fall Thresold",
		Range = {100, 4000},
		CurrentValue = 400,
		Flag = "AntiVoidS",
		Callback = function(newValue)
			fallThreshold = -newValue
		end,
	})
	
	AntiTrollTab:CreateToggle({
		Name = "Anti-Void",
		CurrentValue = false,
		Flag = "AntiVoidT",
		Callback = function(state)
			_G.AntiVoidActive = state

			-- Clean up existing connection
			if _G.AntiVoidConnection then 
				_G.AntiVoidConnection:Disconnect() 
				_G.AntiVoidConnection = nil
			end

			if state then
				local lastSafeCF = nil

				_G.AntiVoidConnection = RS.Heartbeat:Connect(function()
					if not _G.AntiVoidActive then return end

					local char = plr.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local hum = char and char:FindFirstChildOfClass("Humanoid")

					if root and hum then
						if hum.FloorMaterial ~= Enum.Material.Air then
							lastSafeCF = root.CFrame
						end

						-- 2. Check if we have fallen into the void
						if root.Position.Y < fallThreshold then
							if lastSafeCF then
								-- Teleport back to safety
								root.CFrame = lastSafeCF + Vector3.new(0, 3, 0) -- Slight offset to prevent clipping
								root.Velocity = Vector3.new(0, 0, 0) -- Stop the falling momentum
								root.RotVelocity = Vector3.new(0, 0, 0)
								Notify("Anti-void triggered! Teleported back.")
							else
								-- Fallback if no safe point was recorded (e.g. spawned and fell immediately)
								root.CFrame = CFrame.new(0, 50, 0) 
								root.Velocity = Vector3.new(0, 0, 0)
							end
						end
					end
				end)
			end
		end,
	})

	AntiTrollTab:CreateToggle({
		Name = "Anti-Killbrick",
		CurrentValue = false,
		Flag = "AntiKillT",
		Callback = function(state)
			_G.AntiKillActive = state

			if _G.AntiKillConnection then 
				_G.AntiKillConnection:Disconnect() 
				_G.AntiKillConnection = nil
			end

			if state then
				_G.AntiKillConnection = RS.Stepped:Connect(function()
					if not _G.AntiKillActive then return end

					if character then
						for _, part in pairs(character:GetChildren()) do
							if part:IsA("BasePart") then
								part.CanTouch = false
							end
						end
					end
				end)
			else
				if character then
					for _, part in pairs(character:GetChildren()) do
						if part:IsA("BasePart") then
							part.CanTouch = true
						end
					end
				end
			end
		end,
	})
	
	local WorkspaceTab = Window:CreateTab("Workspace")
	WorkspaceTab:CreateSection("Workspace")
	
	WorkspaceTab:CreateSlider({
		Name = "Time",
		Range = {0, 24},
		Increment = 0.1,
		CurrentValue = game.Lighting.ClockTime,
		Flag = "Time",
		Callback = function(value)
			game.Lighting.ClockTime = value
		end
	})
	
	WorkspaceTab:CreateSlider({
		Name = "Gravity",
		Range = {0, 1000},
		CurrentValue = 196.2,
		Flag = "Gravity",
		Callback = function(value)
			workspace.Gravity = value
		end
	})
	
	_G.InteractionRadius = 15

	-- 1. Radius Slider
	WorkspaceTab:CreateSlider({
		Name = "Aura Radius",
		Range = {0, 50},
		Increment = 1,
		CurrentValue = 15,
		Flag = "InteractRadiusS",
		Callback = function(Value)
			_G.InteractionRadius = Value
		end,
	})

	WorkspaceTab:CreateToggle({
		Name = "Click Aura",
		CurrentValue = false,
		Flag = "ClickAuraT",
		Callback = function(state)
			_G.ClickAuraEnabled = state
			task.spawn(function()
				while _G.ClickAuraEnabled do
					local root = hum.RootPart
					if root then
						for _, v in pairs(workspace:GetDescendants()) do
							if v:IsA("ClickDetector") then
								local parent = v.Parent
								if parent:IsA("BasePart") and (parent.Position - root.Position).Magnitude <= _G.InteractionRadius then
									fireclickdetector(v)
								end
							end
						end
					end
					task.wait(0.3) -- Controls click speed
				end
			end)
		end,
	})

	-- 3. Proximity Aura Toggle
	WorkspaceTab:CreateToggle({
		Name = "Auto Proximity",
		CurrentValue = false,
		Flag = "ProxPromptT",
		Callback = function(state)
			_G.ProxEnabled = state
			-- Starting the loop directly in the toggle
			task.spawn(function()
				while _G.ProxEnabled do
					local root = hum.RootPart
					if root then
						for _, v in pairs(workspace:GetDescendants()) do
							if v:IsA("ProximityPrompt") then
								-- Check distance to the prompt's parent
								local promptPos = (v.Parent:IsA("Model") and v.Parent:GetPivot().Position) or v.Parent.Position
								if (promptPos - root.Position).Magnitude <= _G.InteractionRadius then
									fireproximityprompt(v)
								end
							end
						end
					end
					task.wait(0.2) -- Controls prompt trigger speed
				end
			end)
		end,
	})

	-- // SERVER TAB //
	local ServerTab = Window:CreateTab("Server")
	ServerTab:CreateSection("Server")

	local function GetServerList(placeId, cursor, sortOrder)
		local reqFunc = (syn and syn.request) or (http and http.request) or http_request or request
		if not reqFunc then return nil end

		local url = string.format("%s/v1/games/%s/servers/Public?limit=100", PROXY_URL, tostring(placeId))
		if cursor then url = url .. "&cursor=" .. cursor end
		if sortOrder then url = url .. "&sortOrder=" .. sortOrder end

		local response = reqFunc({
			Url = url,
			Method = "GET",
			Headers = {
				["X-SBEUI-Auth"] = AUTH_KEY,
				["X-Roblox-Subdomain"] = "games"
			}
		})

		if response.Success then
			local success, decoded = pcall(function() return Http:JSONDecode(response.Body) end)
			return success and decoded or nil
		end
		return nil
	end

	ServerTab:CreateButton({
		Name = "Join Smallest Server",
		Callback = function()
			local placeId = game.PlaceId
			local currentId = game.JobId

			local servers = GetServerList(placeId, nil, "Asc")

			if servers and servers.data then
				local targetServer = nil
				for _, server in pairs(servers.data) do
					if server.id ~= currentId and server.playing > 0 and server.playing < server.maxPlayers then
						targetServer = server
						break
					end
				end

				if targetServer then
					TPS:TeleportToPlaceInstance(placeId, targetServer.id, plr)
				else
					Library:Notify({
						Title = "Failed",
						Text = "Hop Failed. Could not find a server.",
						Duration = 3
					})
				end
			end
		end,
	})

	ServerTab:CreateButton({
		Name = "Server Hop",
		Callback = function()
			local placeId = game.PlaceId
			local currentId = game.JobId

			local servers = GetServerList(placeId, nil, "Desc")

			if servers and servers.data then
				local possibleServers = {}
				for _, server in pairs(servers.data) do
					if server.id ~= currentId and server.playing < server.maxPlayers then
						table.insert(possibleServers, server.id)
					end
				end

				if #possibleServers > 0 then
					local randomId = possibleServers[math.random(1, #possibleServers)]
					TPS:TeleportToPlaceInstance(placeId, randomId, plr)
				else
					Library:Notify({
						Title = "Failed",
						Text = "Hop Failed. Could not find a server.",
						Duration = 3
					})
				end
			end
		end,
	})

	ServerTab:CreateButton({
		Name = "Rejoin server",
		Callback = function()
			local place = game.PlaceId
			local jobId = game.JobId
			local delay = 2

			task.delay(delay, function()
				TPS:TeleportToPlaceInstance(place, jobId, plr)
			end)
		end,
	})


	-- // EXECUTABLES & VISUALS TAB //
	local ExecTab = Window:CreateTab("Executables / Tools")
	ExecTab:CreateSection("Executables")

	ExecTab:CreateButton({
		Name = "Suga's Imported Script Hub",
		Callback = function()
			safeloadstring("https://raw.githubusercontent.com/SugaBlaz/Universal-Hub/refs/heads/main/Script%20Hub%20(Open%20Source)")
		end,
	})

	ExecTab:CreateButton({
		Name = "Open Server List",
		Callback = function()
			initServerList()
		end,
	})
	
	ExecTab:CreateButton({
		Name = "Dex Explorer",
		Callback = function()
			safeloadstring("https://rawscripts.net/raw/Universal-Script-Keyless-mobile-dex-17888")
		end,
	})
	
	ExecTab:CreateButton({
		Name = "Infinix Executor",
		Callback = function()
			safeloadstring("https://raw.githubusercontent.com/SugaBlaz/Owned-Scripts/refs/heads/main/Infinix%20Executor")
		end,
	})

	local VisTab = Window:CreateTab("Visuals")
	VisTab:CreateSection("Visuals & Graphics")

	VisTab:CreateDropdown({
		Name = "Graphics Preset",
		CurrentOption = "Default",
		Options = {"Default", "Lighting Fix", "Fake RTX", "Potato Mode", "Safe Potato Mode"},
		Flag = "GraphicsDrop",
		Callback = function(mode)
			Library:Notify({
				Title = "Graphics",
				Text = "Switching to " .. mode .. "...",
				Duration = 2
			})

			if mode == "Potato Mode" then
				ApplyGraphicsPreset("Potato Mode")
			else
				task.spawn(function()
					ApplyGraphicsPreset(mode)
				end)
			end
		end
	})

	VisTab:CreateToggle({
		Name = "Remove Textures",
		CurrentValue = false,
		Flag = "RemTexToggle",
		Callback = function(state)
			for _, v in pairs(game:GetDescendants()) do
				if v:IsA("Decal") or v:IsA("Texture") then
					v.Transparency = state and 1 or 0
				end
			end
		end
	})
	
	VisTab:CreateButton({
		Name = "Remove Textures & Decals (Rejoin to reset)",
		Callback = function()
			for _, v in pairs(game:GetDescendants()) do
				if v:IsA("Decal") or v:IsA("Texture") then
					v:Destroy()
				end
			end
		end
	})

	-- // SYSTEM & CONTROLS //
	local SysTab = Window:CreateTab("System & Controls")
	SysTab:CreateSection("System")

	SysTab:CreateButton({
		Name = "Unlock FPS (999)",
		Callback = function()
			if setfpscap then
				setfpscap(999)
			else
				Library:Notify({
					Title = "Failed",
					Text = "Sorry, your executor doesnt support this function.",
					Duration = 3
				})
			end
		end
	})

	local statsLabel = SysTab:CreateLabel("Ping: ... | FPS: ...")

	task.spawn(function()
		while not uiDestroyed do
			task.wait(1)
			local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
			local ping = math.floor(game:GetService("Players").LocalPlayer:GetNetworkPing() * 1000)
			local statStr = "Ping: " .. ping .. "ms | FPS: " .. fps

			pcall(function()
				if statsLabel.Set then
					statsLabel:Set(statStr)
				elseif statsLabel.Text then
					statsLabel.Text = statStr
				end
			end)
		end
	end)

	local SysTab = Window.SettingsTab
	
	SysTab:CreateSection("Ui Controls")

	SysTab:CreateButton({
		Name = "Destroy Ui",
		Callback = function()
			destroyUI()
		end
	})

	SysTab:CreateKeybind({
		Name = "Destroy Ui Bind",
		CurrentKey = "F1",
		Flag = "DestroyBnd",
		Callback = function()
			destroyUI()
		end
	})

	SysTab:CreateButton({
		Name = "Restart Ui",
		Callback = function()
			destroyUI()
			task.wait(0.5)
			safeloadstring("https://raw.githubusercontent.com/SugaBlaz/Universal-Hub/refs/heads/main/Hub")
		end
	})

	SysTab:CreateKeybind({
		Name = "Restart Ui Bind",
		CurrentKey = "F2",
		Flag = "RestartBnd",
		Callback = function()
			destroyUI()
			task.wait(0.5)
			safeloadstring("https://raw.githubusercontent.com/SugaBlaz/Universal-Hub/refs/heads/main/Hub")
		end
	})
	
	local CreditTab = Window:CreateTab("Credits")

	CreditTab:CreateSection("Credits")
	CreditTab:CreateLabel("Made By SugaBlaz")
	CreditTab:CreateLabel("Version 1.2")
end

init()

plr.CharacterAdded:Connect(function(c)
	character = c :: Model
	hum = c:WaitForChild("Humanoid") :: Humanoid
end)

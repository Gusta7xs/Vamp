-- U CAN USE TS IN UR ROBLOX GAME --

local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau"))() --require(script:WaitForChild('ModuleScript'));

local Notification = NeverLose:CreateNotification();
local Logging = NeverLose:CreateLogger();
local Indicator = NeverLose:CreateIndicator();
local window = NeverLose:CreateWindow({
	Logo = NeverLose.GlobalLogo,
	Name = "Neverlose",
	Content = "Speed Keyboard Escape",
	Size = NeverLose.Scales.Default,
	ConfigFolder = "NeverLoseConfigs",
	Enable3DRenderer = false,
	Keybind = "Insert"
});

local Watermark = window:Watermark();

local HC = Indicator.new({
	Name = "HC",
	Icon = 'crosshairs',
	Color = 'Red',
})

local ping = Watermark:AddBlock("chart-four-vertical-bars" , "0MS");
local UITogg = Watermark:AddBlock("cube-vertexes" , "Neverlose");

UITogg:Input(function()
	window:ToggleInterface();
end);

task.spawn(function()
	while true do task.wait(1)
		ping:SetText(tostring(math.random(30,90))..'MS')
	end
end)

-- ADDED Main tab
local Main = window:AddTab({
	Icon = 'house',
	Name = "Main",
})

-- SECTION AUTO WIN
local AutoWin = Main:AddSection({
	Name = "AUTO WIN",
	Position = 'left'
})

-- SECTION PLAYER
local Player = Main:AddSection({
	Name = "PLAYER",
	Position = 'right'
})

-- ===== AUTO WIN SECTION =====
AutoWin:AddLabel('Auto Win Configurations', true)

-- ===== ESTÁGIOS 1-15 (WinBlock) =====
local STAGE_NAMES = {}
for i = 1, 15 do
	table.insert(STAGE_NAMES, "Estágio " .. i)
end

-- Safe Points disponíveis
local SAFE_POINTS = {
	{name = "Safe Point 1", pos = Vector3.new(-1, 9, 191)},
	{name = "Safe Point 2", pos = Vector3.new(-31, 31, 625)},
	{name = "Safe Point 3", pos = Vector3.new(1, 76, 934)},
}

local autoWinEnabled = false
local autoWinMode = "Tween"
local autoWinThread = nil
local autoWinDelay = 1
local teleportDelay = 0.5
local selectedStage = "Estágio 1"
local selectedSafePoints = {"Safe Point 1", "Safe Point 2", "Safe Point 3"}

local teleportSlider = nil
local tweenSlider = nil

-- ===== SIMULAÇÃO DO W PRESSIONADO (APENAS DURANTE TWEEN) =====
local wSimulationThread = nil
local wSimulationEnabled = false

-- Função para simular o W pressionado constantemente
local function StartWSimulation()
	if wSimulationThread then
		task.cancel(wSimulationThread)
		wSimulationThread = nil
	end
	
	if not wSimulationEnabled then return end
	
	wSimulationThread = task.spawn(function()
		local player = game:GetService("Players").LocalPlayer
		if not player then return end
		
		while wSimulationEnabled do
			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
				
				if humanoid and rootPart then
					local originalPos = rootPart.Position
					local moveDirection = humanoid.MoveDirection
					if moveDirection.Magnitude < 0.1 then
						moveDirection = Vector3.new(0, 0, 1)
					end
					
					rootPart.CFrame = rootPart.CFrame + (moveDirection * 0.02)
					task.wait(0.01)
					rootPart.CFrame = CFrame.new(originalPos)
					task.wait(0.01)
				end
			end
			task.wait(0.02)
		end
	end)
end

-- Função para parar a simulação do W
local function StopWSimulation()
	wSimulationEnabled = false
	if wSimulationThread then
		task.cancel(wSimulationThread)
		wSimulationThread = nil
	end
end

-- ===== FUNÇÃO PARA RESETAR O PERSONAGEM =====
local function ResetCharacter()
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.AutoRotate = true
    end
end

-- Função para encontrar o WinBlock pelo nome
local function FindWinBlock(stageNumber)
	local player = game:GetService("Players").LocalPlayer
	if not player then return nil end
	
	local winBlocks = workspace:GetDescendants()
	
	for _, obj in ipairs(winBlocks) do
		local name = obj.Name or ""
		if string.find(name, "WinBlock") then
			local stageNum = string.match(name, "%d+")
			if stageNum and tonumber(stageNum) == stageNumber then
				return obj
			end
		end
	end
	
	return nil
end

-- Função para teleportar para o WinBlock
local function TeleportToWinBlock(stageNumber, mode)
	local winBlock = FindWinBlock(stageNumber)
	if not winBlock then
		print("WinBlock Estágio " .. stageNumber .. " não encontrado!")
		Logging.new("triangle-exclamation", "WinBlock " .. stageNumber .. " não encontrado!", 3)
		return false
	end
	
	local position = winBlock.Position
	local player = game:GetService("Players").LocalPlayer
	if not player or not player.Character then return false end
	
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end
	
	print("Teleportando para WinBlock Estágio " .. stageNumber .. " em: " .. tostring(position))
	Logging.new("flag", "WinBlock " .. stageNumber .. " encontrado!", 1.5)
	
	if mode == "Teleport" then
		rootPart.CFrame = CFrame.new(position)
		return true
	elseif mode == "Tween" then
		wSimulationEnabled = true
		StartWSimulation()
		
		local tweenInfo = TweenInfo.new(
			2,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		)
		
		local tween = game:GetService("TweenService"):Create(
			rootPart,
			tweenInfo,
			{CFrame = CFrame.new(position)}
		)
		tween:Play()
		tween.Completed:Wait()
		
		StopWSimulation()
		return true
	end
	
	return false
end

-- ===== EVITAR BALLERINACHOCOLITA =====
local function AvoidBallerinaChocolita()
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character then return false end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local myPos = rootPart.Position
    local avoided = false
    
    local allBallerinas = workspace:GetDescendants()
    
    for _, obj in ipairs(allBallerinas) do
        if obj.Name == "BallerinaChocolita" and obj:IsA("BasePart") then
            local npcPos = obj.Position
            local distance = (npcPos - myPos).Magnitude
            
            local dangerRadius = 20
            
            if distance < dangerRadius then
                local direction = (myPos - npcPos).Unit
                local targetPos = myPos + (direction * 25)
                targetPos = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
                
                if targetPos.Y > 0 then
                    rootPart.CFrame = CFrame.new(targetPos)
                    avoided = true
                    print("Evitando BallerinaChocolita! Distância:", math.round(distance))
                    Logging.new("person-running", "⚠️ Evitando Ballerina!", 1.5)
                    break
                end
            end
        end
    end
    
    return avoided
end

-- Loop para evitar a NPC
task.spawn(function()
    while true do
        task.wait(0.3)
        if autoWinEnabled then
            AvoidBallerinaChocolita()
        end
    end
end)

-- Função para mover para posição normal (safe points)
local function MovePlayerToPosition(position, mode)
	local player = game:GetService("Players").LocalPlayer
	if not player or not player.Character then return false end
	
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end
	
	if mode == "Teleport" then
		rootPart.CFrame = CFrame.new(position)
		return true
	elseif mode == "Tween" then
		wSimulationEnabled = true
		StartWSimulation()
		
		local tweenInfo = TweenInfo.new(
			2,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		)
		
		local tween = game:GetService("TweenService"):Create(
			rootPart,
			tweenInfo,
			{CFrame = CFrame.new(position)}
		)
		tween:Play()
		tween.Completed:Wait()
		
		StopWSimulation()
		return true
	end
	
	return false
end

-- Função para pegar os safe points selecionados em ordem
local function GetSelectedSafePoints()
	local selected = {}
	for _, sp in ipairs(SAFE_POINTS) do
		if selectedSafePoints[sp.name] then
			table.insert(selected, sp)
		end
	end
	table.sort(selected, function(a, b)
		local idxA, idxB = 0, 0
		for i, sp in ipairs(SAFE_POINTS) do
			if sp.name == a.name then idxA = i end
			if sp.name == b.name then idxB = i end
		end
		return idxA < idxB
	end)
	return selected
end

-- Função principal do Auto Win
local function StartAutoWin()
	if autoWinThread then
		task.cancel(autoWinThread)
		autoWinThread = nil
	end
	
	if not autoWinEnabled then return end
	
	autoWinThread = task.spawn(function()
		local stageNumber = tonumber(string.match(selectedStage, "%d+")) or 1
		local selectedPoints = GetSelectedSafePoints()
		
		print("Auto Win iniciado em modo: " .. autoWinMode)
		print("Estágio alvo: " .. selectedStage)
		print("Safe Points selecionados: " .. #selectedPoints)
		Logging.new("flag", "Auto Win iniciado!", 2)
		
		local cycleCount = 0
		
		while autoWinEnabled do
			cycleCount = cycleCount + 1
			print("Ciclo #" .. cycleCount .. " iniciado")
			
			-- PASSO 1: Passar pelos Safe Points selecionados em ordem
			for i, sp in ipairs(selectedPoints) do
				if not autoWinEnabled then break end
				
				print("Teleportando para " .. sp.name .. ": " .. tostring(sp.pos))
				Logging.new("location-pin", sp.name .. "...", 1.5)
				
				local success = MovePlayerToPosition(sp.pos, autoWinMode)
				if not success then
					print("Falha ao teleportar para " .. sp.name)
					Logging.new("triangle-exclamation", "Falha no " .. sp.name .. "!", 2)
					break
				end
				
				task.wait(0.2)
			end
			
			if not autoWinEnabled then break end
			
			-- PASSO 2: Teleportar para o WinBlock do estágio
			print("Teleportando para WinBlock " .. selectedStage)
			Logging.new("flag", "Indo para " .. selectedStage .. "...", 1.5)
			
			local success = TeleportToWinBlock(stageNumber, autoWinMode)
			if not success then
				print("Falha ao teleportar para o estágio")
				Logging.new("triangle-exclamation", "Falha ao teleportar para o estágio!", 2)
				break
			end
			
			print("Ciclo #" .. cycleCount .. " concluído!")
			Logging.new("check", "Ciclo #" .. cycleCount .. " concluído!", 1.5)
			
			if not autoWinEnabled then break end
			
			task.wait(autoWinDelay)
		end
		
		print("Auto Win finalizado após " .. cycleCount .. " ciclos")
		Notification.new({
			Title = "Auto Win",
			Content = "Finalizado após " .. cycleCount .. " ciclos!",
			Duration = 3,
		})
		
		autoWinThread = nil
	end)
end

-- Toggle do Auto Win
AutoWin:AddLabel('Enabled'):AddToggle({
	Default = false,
	Callback = function(v)
		autoWinEnabled = v
		getgenv().AutoWinEnabled = v
		
		if v then
			StartAutoWin()
		else
			if autoWinThread then
				task.cancel(autoWinThread)
				autoWinThread = nil
				print("Auto Win cancelado")
				Logging.new("circle-slash", "Auto Win cancelado", 2)
			end
			StopWSimulation()
			ResetCharacter()
		end
	end,
	Flag = "AutoWinEnabled",
})

-- Dropdown para selecionar o estágio (1-15) WinBlock
AutoWin:AddLabel('Estágio (WinBlock)'):AddDropdown({
	Default = "Estágio 1",
	Values = STAGE_NAMES,
	Callback = function(v)
		selectedStage = v
		getgenv().SelectedStage = v
		local stageNum = tonumber(string.match(v, "%d+")) or 1
		print("Estágio selecionado:", v)
		
		local winBlock = FindWinBlock(stageNum)
		if winBlock then
			Logging.new("flag", "Estágio " .. v .. " - WinBlock encontrado!", 2)
			Notification.new({
				Title = "Estágio " .. v,
				Content = "WinBlock encontrado! Posição: " .. tostring(winBlock.Position),
				Duration = 2,
			})
		else
			Logging.new("triangle-exclamation", "Estágio " .. v .. " - WinBlock NÃO encontrado!", 3)
			Notification.new({
				Title = "Aviso",
				Content = "WinBlock Estágio " .. v .. " não encontrado!",
				Duration = 2,
			})
		end
		
		if autoWinEnabled then
			StartAutoWin()
		end
	end,
	Flag = "AutoWinStage",
})

-- MULTI-DROPDOWN para Safe Points
AutoWin:AddLabel('Safe Points (Multi-Select)'):AddDropdown({
	Default = {"Safe Point 1", "Safe Point 2", "Safe Point 3"},
	Multi = true,
	Values = {"Safe Point 1", "Safe Point 2", "Safe Point 3"},
	Callback = function(v)
		selectedSafePoints = v
		getgenv().SelectedSafePoints = v
		
		local count = 0
		local names = {}
		for key, value in pairs(v) do
			if value == true then
				count = count + 1
				table.insert(names, key)
			end
		end
		
		print("Safe Points selecionados:", count, "->", table.concat(names, ", "))
		Logging.new("location-pin", count .. " Safe Points selecionados", 2)
		
		if autoWinEnabled then
			StartAutoWin()
		end
	end,
	Flag = "AutoWinSafePoints",
})

-- Dropdown para escolher o modo de movimento
AutoWin:AddLabel('Movement Mode'):AddDropdown({
	Default = "Tween",
	Values = {"Tween", "Teleport"},
	Callback = function(v)
		autoWinMode = v
		getgenv().AutoWinMode = v
		print("Modo alterado para:", v)
		Logging.new("arrows-small-directional", "Modo: " .. v, 2)
		
		if v == "Teleport" then
			if teleportSlider then teleportSlider:SetVisible(true) end
			if tweenSlider then tweenSlider:SetVisible(false) end
		else
			if teleportSlider then teleportSlider:SetVisible(false) end
			if tweenSlider then tweenSlider:SetVisible(true) end
		end
		
		if autoWinEnabled then
			StartAutoWin()
		end
	end,
	Flag = "AutoWinMode",
})

-- SLIDER para Teleport (Delay)
teleportSlider = AutoWin:AddLabel('Teleport Delay')
teleportSlider:AddSlider({
	Min = 0,
	Max = 5,
	Rounding = 1,
	Default = 0.5,
	Type = "s",
	Size = 125,
	Callback = function(v)
		teleportDelay = v
		getgenv().TeleportDelay = v
		print("Teleport Delay set to:", v, "seconds")
	end,
	Flag = "TeleportDelay",
})
teleportSlider:SetVisible(false)

-- SLIDER para Tween (Speed/Duration)
tweenSlider = AutoWin:AddLabel('Tween Speed')
tweenSlider:AddSlider({
	Min = 0.5,
	Max = 5,
	Rounding = 1,
	Default = 2,
	Type = "s",
	Size = 125,
	Callback = function(v)
		getgenv().TweenSpeed = v
		print("Tween Speed set to:", v, "seconds")
	end,
	Flag = "TweenSpeed",
})
tweenSlider:SetVisible(true)

-- SLIDER para Delay entre ciclos (sempre visível)
AutoWin:AddLabel('Cycle Delay'):AddSlider({
	Min = 0,
	Max = 10,
	Rounding = 1,
	Default = 1,
	Type = "s",
	Size = 125,
	Callback = function(v)
		autoWinDelay = v
		getgenv().AutoWinDelay = v
		print("Cycle Delay set to:", v, "seconds")
	end,
	Flag = "AutoWinDelay",
})

-- Label para mostrar status
local statusLabel = AutoWin:AddLabel('Status: Disabled ❌')

-- Monitorar o status do Auto Win
task.spawn(function()
	while true do
		task.wait(1)
		if autoWinEnabled then
			if autoWinThread then
				local stageNum = tonumber(string.match(selectedStage, "%d+")) or 1
				local winBlock = FindWinBlock(stageNum)
				local count = 0
				for key, value in pairs(selectedSafePoints) do
					if value == true then
						count = count + 1
					end
				end
				local status = "Active 🔄 | " .. selectedStage
				if winBlock then
					status = status .. " | ✓ WinBlock"
				else
					status = status .. " | ✗ WinBlock"
				end
				status = status .. " | " .. count .. " Safe Points"
				status = status .. " | " .. autoWinMode
				if autoWinMode == "Tween" and wSimulationEnabled then
					status = status .. " | ⌨️ W"
				end
				statusLabel:SetText(status)
			else
				statusLabel:SetText('Status: Stopped ⚠️')
			end
		else
			statusLabel:SetText('Status: Disabled ❌')
		end
	end
end)

-- Botão para teleportar para o WinBlock do estágio selecionado
AutoWin:AddButton({
	Icon = 'flag',
	Name = 'Go to WinBlock',
	Callback = function()
		local stageNum = tonumber(string.match(selectedStage, "%d+")) or 1
		print("Teleportando para WinBlock " .. selectedStage)
		
		local success = TeleportToWinBlock(stageNum, autoWinMode)
		if success then
			Notification.new({
				Title = "Auto Win",
				Content = "Teleportado para " .. selectedStage .. "!",
				Duration = 2,
			})
		else
			Notification.new({
				Title = "Erro",
				Content = "WinBlock " .. selectedStage .. " não encontrado!",
				Duration = 3,
			})
		end
	end,
})

-- Botão para teleportar para os Safe Points selecionados em ordem
AutoWin:AddButton({
	Icon = 'location-pin',
	Name = 'Go to Safe Points',
	Callback = function()
		local selectedPoints = GetSelectedSafePoints()
		if #selectedPoints == 0 then
			Notification.new({
				Title = "Aviso",
				Content = "Nenhum Safe Point selecionado!",
				Duration = 2,
			})
			return
		end
		
		print("Teleportando para " .. #selectedPoints .. " Safe Points em ordem")
		
		for i, sp in ipairs(selectedPoints) do
			print("Teleportando para " .. sp.name .. ": " .. tostring(sp.pos))
			Logging.new("location-pin", sp.name .. "...", 1.5)
			MovePlayerToPosition(sp.pos, autoWinMode)
			task.wait(0.2)
		end
		
		Notification.new({
			Title = "Auto Win",
			Content = "Teleportado para " .. #selectedPoints .. " Safe Points!",
			Duration = 2,
		})
	end,
})

-- ===== PLAYER SECTION =====
Player:AddLabel('Player Configurations', true)

local WalkSpeedToggle = Player:AddLabel('WalkSpeed Enabled')
WalkSpeedToggle:AddToggle({
	Default = false,
	Callback = function(v)
		getgenv().WalkSpeedEnabled = v
		if v then
			local player = game:GetService("Players").LocalPlayer
			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = getgenv().WalkSpeedValue or 16
				end
			end
		else
			local player = game:GetService("Players").LocalPlayer
			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 16
				end
			end
		end
		print("WalkSpeed Enabled:", v)
	end,
	Flag = "WalkSpeedEnabled",
})

local WalkSpeedSlider = Player:AddLabel('WalkSpeed Value')
WalkSpeedSlider:AddSlider({
	Min = 16,
	Max = 200,
	Rounding = 0,
	Default = 50,
	Type = "",
	Size = 125,
	Callback = function(v)
		getgenv().WalkSpeedValue = v
		if getgenv().WalkSpeedEnabled then
			local player = game:GetService("Players").LocalPlayer
			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = v
				end
			end
		end
		print("WalkSpeed Value set to:", v)
	end,
	Flag = "WalkSpeedValue",
})

Player:AddLabel('WalkSpeed Keybind'):AddKeybind({
	Default = 'G',
	Callback = function(v)
		getgenv().WalkSpeedKeybind = v
		print("WalkSpeed keybind set to:", v)
	end,
	Flag = "WalkSpeedKeybind",
})

-- ===== SERVER TAB =====
local ServerTab = window:AddTab({
	Icon = 'globe-simplified',
	Name = "Server",
})

local ServerSection = ServerTab:AddSection({
	Name = "SERVER CONTROLS",
	Position = 'left'
})

-- Variáveis
local reexecuteEnabled = false
local currentJobId = game.JobId

-- Função para rejoin
local function Rejoin()
	local success, err = pcall(function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
	end)
	
	if success then
		print("Rejoin executado!")
		Logging.new("arrow-spin-clockwise", "Rejoin executado!", 2)
	else
		print("Erro ao rejoin:", err)
		Logging.new("triangle-exclamation", "Erro ao rejoin!", 3)
	end
end

-- Função para Server Hop
local function ServerHop()
	local success, err = pcall(function()
		local servers = {}
		local response = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
		local data = game:GetService("HttpService"):JSONDecode(response)
		
		if data and data.data then
			for _, server in ipairs(data.data) do
				if server.playing and server.playing < server.maxPlayers then
					table.insert(servers, server.id)
				end
			end
		end
		
		if #servers > 0 then
			local randomServer = servers[math.random(1, #servers)]
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, randomServer, game:GetService("Players").LocalPlayer)
			print("Server Hop para:", randomServer)
			Logging.new("arrow-spin-clockwise-10", "Server Hop executado!", 2)
		else
			print("Nenhum servidor disponível!")
			Logging.new("triangle-exclamation", "Nenhum servidor disponível!", 3)
		end
	end)
	
	if not success then
		print("Erro ao server hop:", err)
		Logging.new("triangle-exclamation", "Erro ao server hop!", 3)
	end
end

-- Função para entrar em um Job ID específico
local function TeleportToJobId(jobId)
	if not jobId or jobId == "" then
		Notification.new({
			Title = "Erro",
			Content = "Job ID vazio!",
			Duration = 2,
		})
		return
	end
	
	local success, err = pcall(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, game:GetService("Players").LocalPlayer)
	end)
	
	if success then
		print("Teleportando para Job ID:", jobId)
		Logging.new("flag", "Teleportando para Job ID: " .. jobId, 2)
	else
		print("Erro ao teleportar:", err)
		Logging.new("triangle-exclamation", "Erro ao teleportar!", 3)
	end
end

-- Botão Rejoin
ServerSection:AddButton({
	Icon = 'arrow-spin-clockwise',
	Name = 'Rejoin',
	Callback = function()
		Rejoin()
	end,
})

-- Botão Server Hop
ServerSection:AddButton({
	Icon = 'arrow-spin-clockwise-10',
	Name = 'Server Hop',
	Callback = function()
		ServerHop()
	end,
})

-- Botão Copy Job ID
ServerSection:AddButton({
	Icon = 'document-circle-slash',
	Name = 'Copy Job ID',
	Callback = function()
		local jobId = game.JobId
		setclipboard(jobId)
		print("Job ID copiado:", jobId)
		Notification.new({
			Title = "Job ID",
			Content = "Job ID copiado para o clipboard!",
			Duration = 2,
		})
		Logging.new("check", "Job ID copiado!", 2)
	end,
})

-- Campo de texto para Job ID
ServerSection:AddLabel('Job ID'):AddTextInput({
	Default = "",
	Placeholder = "Cole o Job ID aqui...",
	Size = 200,
	Callback = function(v)
		getgenv().JobIdInput = v
		print("Job ID inserido:", v)
	end,
	Flag = "JobIdInput",
})

-- Botão Enter Job ID
ServerSection:AddButton({
	Icon = 'arrow-right-from-portrait-rectangle',
	Name = 'Enter Job ID',
	Callback = function()
		local jobId = getgenv().JobIdInput or ""
		if jobId == "" then
			Notification.new({
				Title = "Erro",
				Content = "Por favor, insira um Job ID!",
				Duration = 2,
			})
			return
		end
		TeleportToJobId(jobId)
	end,
})

-- Toggle Reexecute
ServerSection:AddLabel('Reexecute on Join'):AddToggle({
	Default = false,
	Callback = function(v)
		reexecuteEnabled = v
		getgenv().ReexecuteEnabled = v
		print("Reexecute enabled:", v)
		
		if v then
			Notification.new({
				Title = "Reexecute",
				Content = "Reexecute ativado! O script será reexecutado ao entrar em um novo servidor.",
				Duration = 3,
			})
			Logging.new("check", "Reexecute ativado!", 2)
		else
			Logging.new("circle-slash", "Reexecute desativado!", 2)
		end
	end,
	Flag = "ReexecuteEnabled",
})

-- Monitorar mudança de servidor para reexecutar
task.spawn(function()
	while true do
		task.wait(1)
		if reexecuteEnabled then
			local newJobId = game.JobId
			if newJobId ~= currentJobId then
				print("Servidor mudou! Reexecutando...")
				currentJobId = newJobId
				
				Notification.new({
					Title = "Reexecute",
					Content = "Novo servidor detectado! Reexecutando...",
					Duration = 3,
				})
				
				task.spawn(function()
					loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau"))()
				end)
			end
		end
	end
end)

-- ===== WALKSPEED LOGIC =====
local function ApplyWalkSpeed()
	local player = game:GetService("Players").LocalPlayer
	if not player then return end
	
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			if getgenv().WalkSpeedEnabled then
				local speed = getgenv().WalkSpeedValue or 50
				humanoid.WalkSpeed = speed
			else
				humanoid.WalkSpeed = 16
			end
		end
	end
end

local function BypassWalkSpeed()
	if getgenv().WalkSpeedExecuted then
		print("Walkspeed Already Bypassed - Applying Settings Changes")
		if not getgenv().WalkSpeedEnabled then
			return
		end
	else
		getgenv().WalkSpeedExecuted = true
		print("Walkspeed Bypassed")

		local mt = getrawmetatable(game)
		setreadonly(mt, false)

		local oldindex = mt.__index
		mt.__index = newcclosure(function(self, b)
			if b == 'WalkSpeed' then
				return 16
			end
			return oldindex(self, b)
		end)
	end
end

getgenv().WalkSpeedEnabled = getgenv().WalkSpeedEnabled or false
getgenv().WalkSpeedValue = getgenv().WalkSpeedValue or 50
getgenv().WalkSpeedKeybind = getgenv().WalkSpeedKeybind or 'G'

BypassWalkSpeed()

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	BypassWalkSpeed()
	task.wait(0.1)
	ApplyWalkSpeed()
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		if getgenv().WalkSpeedEnabled then
			ApplyWalkSpeed()
		end
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	local keyName = input.KeyCode.Name
	if keyName == getgenv().WalkSpeedKeybind then
		getgenv().WalkSpeedEnabled = not getgenv().WalkSpeedEnabled
		
		if NeverLose.Flags and NeverLose.Flags["WalkSpeedEnabled"] then
			NeverLose.Flags["WalkSpeedEnabled"]:SetValue(getgenv().WalkSpeedEnabled)
		end
		
		ApplyWalkSpeed()
		print("WalkSpeed Toggled:", getgenv().WalkSpeedEnabled)
		
		if getgenv().WalkSpeedEnabled then
			Logging.new("person-running", "WalkSpeed Enabled - Speed: " .. tostring(getgenv().WalkSpeedValue), 3)
		else
			Logging.new("person", "WalkSpeed Disabled", 3)
		end
	end
end)

---------- Menu Configuration ------------
window.UserSettings:AddLabel("Menu Keybind"):AddKeybind({
	Default = 'Insert',
	Callback = function(v)
		window.Keybind = v;
		
		Logging.new("ps4-touchpad",'Changed ui keybind to '..tostring(v),5)
	end,
})

window.UserSettings:AddLabel('Menu Scale'):AddDropdown({
	Default = "Default",
	Values = {"Default",'Large','Mobile','Small'},
	Callback = function(v)
		window:SetSize(NeverLose.Scales[v]);
		
		Logging.new("crop",'Changed ui size to '..tostring(v),5)
	end,
})

window.UserSettings:AddLabel('3D Menu'):AddToggle({
	Default = false,
	Callback = function(v)
		window:Set3DRender(v);
	end,
})

window.UserSettings:AddButton({
	Icon = 'discord',
	Name = 'Discord',
	Callback = function()
		print('invite')
		
		Logging.new("discord",'Copied discord invite link',5)
	end,
})

-- ===== UNLOAD BUTTON =====
window.UserSettings:AddButton({
	Icon = 'power-off',
	Name = 'Unload Menu',
	Callback = function()
		ResetCharacter()
		
		local player = game:GetService("Players").LocalPlayer
		if player and player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end
		
		if autoWinThread then
			task.cancel(autoWinThread)
			autoWinThread = nil
		end
		
		StopWSimulation()
		
		window:ToggleInterface()
		
		if Watermark then
			Watermark:SetRender(false)
		end
		
		if HC then
			HC:SetRender(false)
		end
		
		for flag, v in pairs(NeverLose.Flags) do
			NeverLose.Flags[flag] = nil
		end
		
		if NeverLose.ScreenGui then
			NeverLose.ScreenGui:Destroy()
		end
		
		if Notification then
			pcall(function() Notification:Destroy() end)
		end
		
		if Logging then
			pcall(function() Logging:Destroy() end)
		end
		
		for i, v in pairs(NeverLose.GlobalSignals) do
			pcall(v.Disconnect, v)
			NeverLose.GlobalSignals[i] = nil
		end
		
		print("\n\n=== NEVERLOSE UNLOADED ===\n\n")
		
		task.spawn(function()
			local notif = NeverLose:CreateNotification()
			notif.new({
				Title = "Neverlose",
				Content = "Menu unloaded successfully!",
				Duration = 2,
			})
			task.wait(2.5)
			pcall(function() notif:Destroy() end)
		end)
	end,
})
-- ===== END UNLOAD BUTTON =====

Notification.new({
	Title = "Notification",
	Content = "This is Neverlose Notification",
	Duration = 5,
})

task.wait(1)
Notification.new({
	Title = "Neverlose",
	Content = "Initialization in progress",
	Duration = 7,
})


HC:SetRender(true);

-- RGB COLOR CHANGING FOR "Speed Keyboard Escape" TEXT
task.spawn(function()
	local colors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 165, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(238, 130, 238)
	}
	
	local colorIndex = 1
	
	while true do
		task.wait(0.5)
		
		if not NeverLose.ScreenGui or not NeverLose.ScreenGui.Parent then
			break
		end
		
		for _, child in ipairs(NeverLose.ScreenGui:GetDescendants()) do
			if child:IsA("TextLabel") and child.Text == "Speed Keyboard Escape" then
				child.TextColor3 = colors[colorIndex]
				child.TextTransparency = 0
				break
			end
		end
		
		colorIndex = colorIndex + 1
		if colorIndex > #colors then
			colorIndex = 1
		end
	end
end)

while true do task.wait(3)
	if not NeverLose.ScreenGui or not NeverLose.ScreenGui.Parent then
		break
	end
	
	Watermark:SetRender(true);
	
	HC:SetColor('Red')
	HC:SetText("FL")
	task.wait(3);
	Watermark:SetRender(false);
	HC:SetColor('Green');
	HC:SetText("AUTO")
	task.wait(3)
	Watermark:SetRender(true);
	HC:SetColor('White')
	HC:SetText("HC")
	task.wait(1)
	Watermark:SetRender(false);
	HC:SetRender(false);
	task.wait(1)
	HC:SetRender(true);
end

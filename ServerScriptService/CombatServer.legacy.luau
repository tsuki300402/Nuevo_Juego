-- Script: CombatServer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local abilityEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AbilityEvent")
local WeaponsData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponsData"))

-- Control de cooldowns en el servidor para evitar exploits/hacks
local serverCooldowns = {}

abilityEvent.OnServerEvent:Connect(function(player, weaponName, keyName)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart
	local weapon = WeaponsData[weaponName]
	if not weapon or not weapon.Abilities[keyName] then return end

	local ability = weapon.Abilities[keyName]
	local playerId = player.UserId

	if not serverCooldowns[playerId] then
		serverCooldowns[playerId] = {}
	end

	local lastUsed = serverCooldowns[playerId][keyName] or 0
	local now = tick()

	-- Validar cooldown en el servidor (con 0.2s de tolerancia por latencia)
	if (now - lastUsed) < (ability.Cooldown - 0.2) then
		return
	end
	serverCooldowns[playerId][keyName] = now

	-- Pequeño efecto visual temporal (muestra el radio del golpe)
	local visualEffect = Instance.new("Part")
	visualEffect.Shape = Enum.PartType.Cylinder
	visualEffect.Size = Vector3.new(0.5, ability.Range * 2, ability.Range * 2)
	visualEffect.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
	visualEffect.Anchored = true
	visualEffect.CanCollide = false
	visualEffect.Material = Enum.Material.Neon
	visualEffect.Color = (keyName == "Q") and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 100, 0)
	visualEffect.Transparency = 0.5
	visualEffect.Parent = workspace

	game:GetService("Debris"):AddItem(visualEffect, 0.25)

	-- Detectar enemigos o dummies frente al jugador
	local range = ability.Range
	local damage = ability.Damage

	for _, target in pairs(workspace:GetChildren()) do
		if target:IsA("Model") and target ~= character and target:FindFirstChild("Humanoid") and target:FindFirstChild("HumanoidRootPart") then
			local targetHRP = target.HumanoidRootPart
			local distance = (targetHRP.Position - rootPart.Position).Magnitude

			if distance <= range then
				-- Comprobar si está enfrente (ángulo de visión de 120 grados)
				local directionToTarget = (targetHRP.Position - rootPart.Position).Unit
				local dotProduct = rootPart.CFrame.LookVector:Dot(directionToTarget)

				if dotProduct > 0.1 or keyName == "E" then -- El ataque 'E' golpea en 360 grados
					target.Humanoid:TakeDamage(damage)
					print(player.Name .. " golpeó a " .. target.Name .. " por " .. damage .. " de daño!")
				end
			end
		end
	end
end)

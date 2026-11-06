-- LocalScript: CombatClient
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local abilityEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AbilityEvent")
local WeaponsData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponsData"))

-- Arma actualmente equipada (por defecto la Espada de Hierro)
local currentWeapon = "EspadaHierro"
local cooldowns = { Q = 0, E = 0 }

local function useAbility(keyName)
	local weapon = WeaponsData[currentWeapon]
	if not weapon or not weapon.Abilities[keyName] then return end

	local ability = weapon.Abilities[keyName]
	local currentTime = tick()

	-- Verificar si está en enfriamiento (cooldown)
	if currentTime < cooldowns[keyName] then
		local remaining = math.ceil(cooldowns[keyName] - currentTime)
		print("Habilidad en recarga: " .. remaining .. "s restantes")
		return
	end

	-- Iniciar cooldown
	cooldowns[keyName] = currentTime + ability.Cooldown
	print("¡Usaste [" .. keyName .. "] " .. ability.Name .. "!")

	-- Avisar al servidor para que valide el daño y la animación
	abilityEvent:FireServer(currentWeapon, keyName)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- Si está escribiendo en el chat, ignorar

	if input.KeyCode == Enum.KeyCode.Q then
		useAbility("Q")
	elseif input.KeyCode == Enum.KeyCode.E then
		useAbility("E")
	end
end)
-- Mesa de crafteo: receta simple
-- 5 Madera + 3 Piedra = Pico de Piedra (herramienta)

local mesa = workspace:FindFirstChild("MesaDeCrafteo")
if not mesa then
	return print("[Crafteo] No se encontro la MesaDeCrafteo en Workspace")
end

local RECETA = {
	Madera = 5,
	Piedra = 3,
}

local function tieneRecursos(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end
	for recurso, necesario in RECETA do
		local valor = leaderstats:FindFirstChild(recurso)
		if not valor or valor.Value < necesario then
			return false
		end
	end
	return true
end

local function consumirRecursos(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	for recurso, necesario in RECETA do
		local valor = leaderstats:FindFirstChild(recurso)
		if valor then
			valor.Value -= necesario
		end
	end
end

local function crearPico(player)
	local pico = Instance.new("Tool")
	pico.Name = "PicoDePiedra"
	pico.ToolTip = "Crafteado con 5 Madera y 3 Piedra"

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1, 4)
	handle.Material = Enum.Material.Slate
	handle.Color = Color3.fromRGB(130, 130, 130)
	handle.Parent = pico

	pico.Parent = player:FindFirstChild("Backpack")
end

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Craftear Pico de Piedra"
prompt.ObjectText = "Mesa de Crafteo (5 Madera + 3 Piedra)"
prompt.HoldDuration = 2
prompt.MaxActivationDistance = 8
prompt.Parent = mesa

prompt.Triggered:Connect(function(player)
	if tieneRecursos(player) then
		consumirRecursos(player)
		crearPico(player)
	else
		-- Aviso simple por el chat del sistema
		local msg = Instance.new("Message")
		msg.Parent = workspace
		msg.Text = player.Name .. ": te faltan recursos (5 Madera + 3 Piedra)"
		task.delay(3, function() msg:Destroy() end)
	end
end)

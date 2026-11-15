-- Sistema de recoleccion de recursos (estilo Albion)
-- Los nodos se agotan al recolectarlos y reaparecen despues de un tiempo.

local Players = game:GetService("Players")
local recursosFolder = workspace:FindFirstChild("Recursos")
if not recursosFolder then
	return print("[Recoleccion] No se encontro la carpeta Recursos en Workspace")
end

-- ===== Inventario en el leaderboard =====
local function crearInventario(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for _, recurso in {"Madera", "Piedra", "Mineral"} do
		local valor = Instance.new("IntValue")
		valor.Name = recurso
		valor.Value = 0
		valor.Parent = leaderstats
	end
end

Players.PlayerAdded:Connect(crearInventario)
for _, player in Players:GetPlayers() do
	crearInventario(player)
end

local function darRecurso(player, tipo)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local valor = leaderstats:FindFirstChild(tipo)
		if valor then
			valor.Value += 1
		end
	end
end

-- ===== Recoleccion de nodos =====
local function recolectar(nodo, player)
	local cantidad = nodo:GetAttribute("Cantidad") or 0
	if cantidad <= 0 then return end

	-- Restar 1 al nodo
	nodo:SetAttribute("Cantidad", cantidad - 1)
	darRecurso(player, nodo:GetAttribute("TipoRecurso") or nodo.Name)

	-- Actualizar tamano visualmente para mostrar cuanto queda
	local max = nodo:GetAttribute("CantidadMax") or 1
	local restante = (cantidad - 1) / max
	nodo.Size = Vector3.new(2 + 2 * restante, 2 + 2 * restante, 2 + 2 * restante)

	-- Si se agoto, ocultarlo y programar el respawn
	if cantidad - 1 <= 0 then
		nodo.Transparency = 1
		nodo.CanCollide = false
		local prompt = nodo:FindFirstChildOfClass("ProximityPrompt")
		if prompt then prompt.Enabled = false end

		task.delay(nodo:GetAttribute("TiempoRespawn") or 15, function()
			nodo:SetAttribute("Cantidad", nodo:GetAttribute("CantidadMax") or 5)
			nodo.Transparency = 0
			nodo.CanCollide = true
			nodo.Size = Vector3.new(4, 4, 4)
			if prompt then prompt.Enabled = true end
		end)
	end
end

local function configurarNodo(nodo)
	if not nodo:IsA("BasePart") then return end
	if nodo:FindFirstChildOfClass("ProximityPrompt") then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Recolectar " .. nodo.Name
	prompt.ObjectText = nodo.Name
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 8
	prompt.Parent = nodo

	prompt.Triggered:Connect(function(player)
		recolectar(nodo, player)
	end)
end

for _, nodo in recursosFolder:GetChildren() do
	configurarNodo(nodo)
end
recursosFolder.DescendantAdded:Connect(configurarNodo)

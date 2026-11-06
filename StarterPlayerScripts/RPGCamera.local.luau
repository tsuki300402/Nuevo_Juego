-- LocalScript: RPGCamera (Vista sobre el hombro y centrado dinámico)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuración de cámara RPG
camera.CameraType = Enum.CameraType.Custom
player.CameraMinZoomDistance = 7
player.CameraMaxZoomDistance = 14

-- Desplazamiento sobre el hombro (estilo RPG de acción)
local function adjustCamera()
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") then
		local humanoid = character.Humanoid
		-- Habilita que el personaje gire suavemente hacia donde mira la cámara
		humanoid.AutoRotate = true
		humanoid.CameraOffset = Vector3.new(1.8, 0.5, 0) -- Ligero desvío hacia la derecha
	end
end

player.CharacterAdded:Connect(function()
	task.wait(0.2)
	adjustCamera()
end)

adjustCamera()

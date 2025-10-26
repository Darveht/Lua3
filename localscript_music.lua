 
-- LocalScript para Sistema de Música
-- Coloca esto en StarterPlayer > StarterPlayerScripts
 
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
-- ESPERAR REMOTES
local remoteFolder = ReplicatedStorage:WaitForChild("RoogleRemotes", 10)
if not remoteFolder then
    warn("❌ ERROR: No se encontró la carpeta RoogleRemotes")
    return
end
 
local publishMusicFunction = remoteFolder:WaitForChild("PublishMusic", 5)
local getMusicEvent = remoteFolder:WaitForChild("GetMusic", 5)
local getPendingMusicEvent = remoteFolder:WaitForChild("GetPendingMusic", 5)
local toggleMusicStatusEvent = remoteFolder:WaitForChild("ToggleMusicStatus", 5)
 
-- Obtener GUI principal
local screenGui = playerGui:WaitForChild("RoogleGui", 10)
if not screenGui then
    warn("❌ ERROR: No se encontró RoogleGui")
    return
end
 
local mainFrame = screenGui:FindFirstChild("Frame")
 
-- ========== BOTÓN DE MÚSICA ==========
local musicButton = Instance.new("TextButton")
musicButton.Name = "MusicButton"
musicButton.Size = UDim2.new(0, 45, 0, 45)
musicButton.Position = UDim2.new(1, -180, 0, 15)
musicButton.AnchorPoint = Vector2.new(1, 0)
musicButton.BackgroundColor3 = Color3.fromRGB(255, 87, 34)
musicButton.Text = "🎵"
musicButton.Font = Enum.Font.GothamBold
musicButton.TextSize = 22
musicButton.BorderSizePixel = 0
musicButton.ZIndex = 5
musicButton.Parent = mainFrame
 
local musicCorner = Instance.new("UICorner")
musicCorner.CornerRadius = UDim.new(1, 0)
musicCorner.Parent = musicButton
 
-- ========== PANEL DE MÚSICA ==========
local musicPanel = Instance.new("ScrollingFrame")
musicPanel.Name = "MusicPanel"
musicPanel.Size = UDim2.new(1, 0, 1, 0)
musicPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
musicPanel.BorderSizePixel = 0
musicPanel.Visible = false
musicPanel.ZIndex = 10
musicPanel.ScrollBarThickness = 8
musicPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
musicPanel.Parent = mainFrame
 
local musicLayout = Instance.new("UIListLayout")
musicLayout.SortOrder = Enum.SortOrder.LayoutOrder
musicLayout.Padding = UDim.new(0, 20)
musicLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
musicLayout.Parent = musicPanel
 
local musicPadding = Instance.new("UIPadding")
musicPadding.PaddingLeft = UDim.new(0, 20)
musicPadding.PaddingRight = UDim.new(0, 20)
musicPadding.PaddingTop = UDim.new(0, 30)
musicPadding.PaddingBottom = UDim.new(0, 30)
musicPadding.Parent = musicPanel
 
-- Header
local musicHeaderContainer = Instance.new("Frame")
musicHeaderContainer.Size = UDim2.new(1, 0, 0, 50)
musicHeaderContainer.BackgroundTransparency = 1
musicHeaderContainer.LayoutOrder = 1
musicHeaderContainer.Parent = musicPanel
 
local musicTitle = Instance.new("TextLabel")
musicTitle.Size = UDim2.new(1, -60, 1, 0)
musicTitle.BackgroundTransparency = 1
musicTitle.Text = "🎵 ENVIAR MÚSICA"
musicTitle.Font = Enum.Font.GothamBold
musicTitle.TextSize = 28
musicTitle.TextColor3 = Color3.fromRGB(255, 87, 34)
musicTitle.TextXAlignment = Enum.TextXAlignment.Left
musicTitle.ZIndex = 11
musicTitle.Parent = musicHeaderContainer
 
local musicCloseButton = Instance.new("TextButton")
musicCloseButton.Size = UDim2.new(0, 45, 0, 45)
musicCloseButton.Position = UDim2.new(1, 0, 0, 0)
musicCloseButton.AnchorPoint = Vector2.new(1, 0)
musicCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
musicCloseButton.Text = "✕"
musicCloseButton.Font = Enum.Font.GothamBold
musicCloseButton.TextSize = 24
musicCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
musicCloseButton.BorderSizePixel = 0
musicCloseButton.ZIndex = 11
musicCloseButton.Parent = musicHeaderContainer
 
local musicCloseCorner = Instance.new("UICorner")
musicCloseCorner.CornerRadius = UDim.new(1, 0)
musicCloseCorner.Parent = musicCloseButton
 
-- Contenedor de campos
local musicFieldsContainer = Instance.new("Frame")
musicFieldsContainer.Size = UDim2.new(1, 0, 0, 400)
musicFieldsContainer.BackgroundTransparency = 1
musicFieldsContainer.LayoutOrder = 2
musicFieldsContainer.Parent = musicPanel
 
local musicFieldsLayout = Instance.new("UIListLayout")
musicFieldsLayout.SortOrder = Enum.SortOrder.LayoutOrder
musicFieldsLayout.Padding = UDim.new(0, 15)
musicFieldsLayout.Parent = musicFieldsContainer
 
-- Campo: Nombre de la música
local musicNameLabel = Instance.new("TextLabel")
musicNameLabel.Size = UDim2.new(1, 0, 0, 25)
musicNameLabel.BackgroundTransparency = 1
musicNameLabel.Text = "🎼 Nombre de la música"
musicNameLabel.Font = Enum.Font.GothamBold
musicNameLabel.TextSize = 18
musicNameLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
musicNameLabel.TextXAlignment = Enum.TextXAlignment.Left
musicNameLabel.LayoutOrder = 1
musicNameLabel.ZIndex = 11
musicNameLabel.Parent = musicFieldsContainer
 
local musicNameInput = Instance.new("TextBox")
musicNameInput.Name = "MusicNameInput"
musicNameInput.Size = UDim2.new(1, 0, 0, 50)
musicNameInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
musicNameInput.Text = ""
musicNameInput.PlaceholderText = "Nombre de la canción..."
musicNameInput.Font = Enum.Font.Gotham
musicNameInput.TextSize = 18
musicNameInput.TextColor3 = Color3.fromRGB(0, 0, 0)
musicNameInput.TextXAlignment = Enum.TextXAlignment.Left
musicNameInput.ClearTextOnFocus = false
musicNameInput.BorderSizePixel = 0
musicNameInput.LayoutOrder = 2
musicNameInput.ZIndex = 11
musicNameInput.Parent = musicFieldsContainer
 
local musicNameCorner = Instance.new("UICorner")
musicNameCorner.CornerRadius = UDim.new(0, 10)
musicNameCorner.Parent = musicNameInput
 
local musicNamePadding = Instance.new("UIPadding")
musicNamePadding.PaddingLeft = UDim.new(0, 15)
musicNamePadding.PaddingRight = UDim.new(0, 15)
musicNamePadding.Parent = musicNameInput
 
-- Campo: ID de la música
local musicIdLabel = Instance.new("TextLabel")
musicIdLabel.Size = UDim2.new(1, 0, 0, 25)
musicIdLabel.BackgroundTransparency = 1
musicIdLabel.Text = "🔢 ID de Roblox Audio"
musicIdLabel.Font = Enum.Font.GothamBold
musicIdLabel.TextSize = 18
musicIdLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
musicIdLabel.TextXAlignment = Enum.TextXAlignment.Left
musicIdLabel.LayoutOrder = 3
musicIdLabel.ZIndex = 11
musicIdLabel.Parent = musicFieldsContainer
 
local musicIdInput = Instance.new("TextBox")
musicIdInput.Name = "MusicIdInput"
musicIdInput.Size = UDim2.new(1, 0, 0, 50)
musicIdInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
musicIdInput.Text = ""
musicIdInput.PlaceholderText = "ID del audio (solo números)..."
musicIdInput.Font = Enum.Font.Gotham
musicIdInput.TextSize = 18
musicIdInput.TextColor3 = Color3.fromRGB(0, 0, 0)
musicIdInput.TextXAlignment = Enum.TextXAlignment.Left
musicIdInput.ClearTextOnFocus = false
musicIdInput.BorderSizePixel = 0
musicIdInput.LayoutOrder = 4
musicIdInput.ZIndex = 11
musicIdInput.Parent = musicFieldsContainer
 
local musicIdCorner = Instance.new("UICorner")
musicIdCorner.CornerRadius = UDim.new(0, 10)
musicIdCorner.Parent = musicIdInput
 
local musicIdPadding = Instance.new("UIPadding")
musicIdPadding.PaddingLeft = UDim.new(0, 15)
musicIdPadding.PaddingRight = UDim.new(0, 15)
musicIdPadding.Parent = musicIdInput
 
-- Campo: Categoría
local musicCategoryLabel = Instance.new("TextLabel")
musicCategoryLabel.Size = UDim2.new(1, 0, 0, 25)
musicCategoryLabel.BackgroundTransparency = 1
musicCategoryLabel.Text = "🏷️ Categoría"
musicCategoryLabel.Font = Enum.Font.GothamBold
musicCategoryLabel.TextSize = 18
musicCategoryLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
musicCategoryLabel.TextXAlignment = Enum.TextXAlignment.Left
musicCategoryLabel.LayoutOrder = 5
musicCategoryLabel.ZIndex = 11
musicCategoryLabel.Parent = musicFieldsContainer
 
local musicCategoryInput = Instance.new("TextBox")
musicCategoryInput.Name = "MusicCategoryInput"
musicCategoryInput.Size = UDim2.new(1, 0, 0, 50)
musicCategoryInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
musicCategoryInput.Text = ""
musicCategoryInput.PlaceholderText = "Ej: Pop, Rock, Clásica..."
musicCategoryInput.Font = Enum.Font.Gotham
musicCategoryInput.TextSize = 18
musicCategoryInput.TextColor3 = Color3.fromRGB(0, 0, 0)
musicCategoryInput.TextXAlignment = Enum.TextXAlignment.Left
musicCategoryInput.ClearTextOnFocus = false
musicCategoryInput.BorderSizePixel = 0
musicCategoryInput.LayoutOrder = 6
musicCategoryInput.ZIndex = 11
musicCategoryInput.Parent = musicFieldsContainer
 
local musicCategoryCorner = Instance.new("UICorner")
musicCategoryCorner.CornerRadius = UDim.new(0, 10)
musicCategoryCorner.Parent = musicCategoryInput
 
local musicCategoryPadding = Instance.new("UIPadding")
musicCategoryPadding.PaddingLeft = UDim.new(0, 15)
musicCategoryPadding.PaddingRight = UDim.new(0, 15)
musicCategoryPadding.Parent = musicCategoryInput
 
-- Botón enviar
local submitMusicButton = Instance.new("TextButton")
submitMusicButton.Name = "SubmitMusicButton"
submitMusicButton.Size = UDim2.new(1, 0, 0, 55)
submitMusicButton.BackgroundColor3 = Color3.fromRGB(255, 87, 34)
submitMusicButton.Text = "🎵 Enviar Música a Revisión"
submitMusicButton.Font = Enum.Font.GothamBold
submitMusicButton.TextSize = 20
submitMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitMusicButton.BorderSizePixel = 0
submitMusicButton.LayoutOrder = 7
submitMusicButton.ZIndex = 11
submitMusicButton.Parent = musicFieldsContainer
 
local submitMusicCorner = Instance.new("UICorner")
submitMusicCorner.CornerRadius = UDim.new(0, 10)
submitMusicCorner.Parent = submitMusicButton
 
-- ========== EVENTOS ==========
musicButton.MouseButton1Click:Connect(function()
    musicPanel.Visible = true
    musicNameInput.Text = ""
    musicIdInput.Text = ""
    musicCategoryInput.Text = ""
end)
 
musicCloseButton.MouseButton1Click:Connect(function()
    musicPanel.Visible = false
end)
 
submitMusicButton.MouseButton1Click:Connect(function()
    local musicName = musicNameInput.Text
    local musicId = musicIdInput.Text
    local musicCategory = musicCategoryInput.Text
    
    if musicName ~= "" and musicId ~= "" and musicCategory ~= "" then
        local success, result = pcall(function()
            return publishMusicFunction:InvokeServer(musicName, musicId, musicCategory)
        end)
        
        if success and result then
            musicNameInput.Text = ""
            musicIdInput.Text = ""
            musicCategoryInput.Text = ""
            musicPanel.Visible = false
            print("✓ Música enviada a revisión")
        else
            warn("✗ Error al enviar música")
        end
    else
        warn("⚠ Por favor completa todos los campos")
    end
end)
 
task.wait(0.1)
musicFieldsContainer.Size = UDim2.new(1, 0, 0, musicFieldsLayout.AbsoluteContentSize.Y)
musicPanel.CanvasSize = UDim2.new(0, 0, 0, musicLayout.AbsoluteContentSize.Y + 60)
 
print("✓ Sistema de música cargado")
 

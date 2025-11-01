-- LocalScript para Sistema de Música
-- Coloca esto en StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ESPERAR a que TODO el sistema principal esté listo
repeat task.wait(0.1) until _G.RoogleCoreLoaded and _G.RoogleFunctionsLoaded and _G.RoogleClient
print("⏳ Sistema principal detectado, iniciando Music...")
local R = _G.RoogleClient

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
musicCloseButton.Text = "X"
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

R.musicCategoryInput = Instance.new("TextBox")
R.musicCategoryInput.Name = "MusicCategoryInput"
R.musicCategoryInput.Size = UDim2.new(1, 0, 0, 50)
R.musicCategoryInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
R.musicCategoryInput.Text = ""
R.musicCategoryInput.PlaceholderText = "Ej: Pop, Rock, Electrónica..."
R.musicCategoryInput.Font = Enum.Font.Gotham
R.musicCategoryInput.TextSize = 18
R.musicCategoryInput.TextColor3 = Color3.fromRGB(0, 0, 0)
R.musicCategoryInput.TextXAlignment = Enum.TextXAlignment.Left
R.musicCategoryInput.ClearTextOnFocus = false
R.musicCategoryInput.BorderSizePixel = 0
R.musicCategoryInput.LayoutOrder = 6
R.musicCategoryInput.ZIndex = 11
R.musicCategoryInput.Parent = musicFieldsContainer

local musicCategoryCorner = Instance.new("UICorner")
musicCategoryCorner.CornerRadius = UDim.new(0, 10)
musicCategoryCorner.Parent = R.musicCategoryInput

local musicCategoryPadding = Instance.new("UIPadding")
musicCategoryPadding.PaddingLeft = UDim.new(0, 15)
musicCategoryPadding.PaddingRight = UDim.new(0, 15)
musicCategoryPadding.Parent = R.musicCategoryInput

-- NUEVO: Campo Precio (opcional)
local musicPriceLabel = Instance.new("TextLabel")
musicPriceLabel.Size = UDim2.new(1, 0, 0, 25)
musicPriceLabel.BackgroundTransparency = 1
musicPriceLabel.Text = "💰 Precio (Robux) - Opcional (0 = Gratis)"
musicPriceLabel.Font = Enum.Font.GothamBold
musicPriceLabel.TextSize = 18
musicPriceLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
musicPriceLabel.TextXAlignment = Enum.TextXAlignment.Left
musicPriceLabel.LayoutOrder = 7
musicPriceLabel.ZIndex = 11
musicPriceLabel.Parent = musicFieldsContainer

R.musicPriceInput = Instance.new("TextBox")
R.musicPriceInput.Name = "MusicPriceInput"
R.musicPriceInput.Size = UDim2.new(1, 0, 0, 50)
R.musicPriceInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
R.musicPriceInput.Text = "0"
R.musicPriceInput.PlaceholderText = "0 (Gratis) o pon un precio en Robux"
R.musicPriceInput.Font = Enum.Font.Gotham
R.musicPriceInput.TextSize = 18
R.musicPriceInput.TextColor3 = Color3.fromRGB(0, 0, 0)
R.musicPriceInput.TextXAlignment = Enum.TextXAlignment.Left
R.musicPriceInput.ClearTextOnFocus = false
R.musicPriceInput.BorderSizePixel = 0
R.musicPriceInput.LayoutOrder = 8
R.musicPriceInput.ZIndex = 11
R.musicPriceInput.Parent = musicFieldsContainer

local musicPriceCorner = Instance.new("UICorner")
musicPriceCorner.CornerRadius = UDim.new(0, 10)
musicPriceCorner.Parent = R.musicPriceInput

local musicPricePadding = Instance.new("UIPadding")
musicPricePadding.PaddingLeft = UDim.new(0, 15)
musicPricePadding.PaddingRight = UDim.new(0, 15)
musicPricePadding.Parent = R.musicPriceInput

-- Nota informativa sobre monetización
local musicPriceNote = Instance.new("TextLabel")
musicPriceNote.Size = UDim2.new(1, 0, 0, 60)
musicPriceNote.BackgroundColor3 = Color3.fromRGB(255, 243, 224)
musicPriceNote.Text = "ℹ️ NOTA: Las músicas de pago requieren configuración del admin. Los pagos se procesarán automáticamente y recibirás el 50% de las ganancias."
musicPriceNote.Font = Enum.Font.Gotham
musicPriceNote.TextSize = 14
musicPriceNote.TextColor3 = Color3.fromRGB(100, 100, 100)
musicPriceNote.TextWrapped = true
musicPriceNote.TextXAlignment = Enum.TextXAlignment.Left
musicPriceNote.TextYAlignment = Enum.TextYAlignment.Top
musicPriceNote.LayoutOrder = 9
musicPriceNote.ZIndex = 11
musicPriceNote.Parent = musicFieldsContainer

local musicPriceNoteCorner = Instance.new("UICorner")
musicPriceNoteCorner.CornerRadius = UDim.new(0, 8)
musicPriceNoteCorner.Parent = musicPriceNote

local musicPriceNotePadding = Instance.new("UIPadding")
musicPriceNotePadding.PaddingLeft = UDim.new(0, 12)
musicPriceNotePadding.PaddingRight = UDim.new(0, 12)
musicPriceNotePadding.PaddingTop = UDim.new(0, 10)
musicPriceNotePadding.PaddingBottom = UDim.new(0, 10)
musicPriceNotePadding.Parent = musicPriceNote

-- Botón enviar
R.submitMusicButton = Instance.new("TextButton")
R.submitMusicButton.Name = "SubmitMusicButton"
R.submitMusicButton.Size = UDim2.new(1, 0, 0, 55)
R.submitMusicButton.BackgroundColor3 = Color3.fromRGB(255, 87, 34)
R.submitMusicButton.Text = "📤 Enviar Música a Revisión"
R.submitMusicButton.Font = Enum.Font.GothamBold
R.submitMusicButton.TextSize = 20
R.submitMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
R.submitMusicButton.BorderSizePixel = 0
R.submitMusicButton.LayoutOrder = 11
R.submitMusicButton.ZIndex = 11
R.submitMusicButton.Parent = musicFieldsContainer

local submitMusicCorner = Instance.new("UICorner")
submitMusicCorner.CornerRadius = UDim.new(0, 10)
submitMusicCorner.Parent = R.submitMusicButton

-- ========== EVENTOS ==========
musicButton.MouseButton1Click:Connect(function()
    musicPanel.Visible = true
    musicNameInput.Text = ""
    musicIdInput.Text = ""
    musicCategoryInput.Text = ""
    musicPriceInput.Text = "0" -- Reset price to default
    musicGamePassInput.Text = "" -- Reset Game Pass ID
end)

musicCloseButton.MouseButton1Click:Connect(function()
    musicPanel.Visible = false
end)

R.submitMusicButton.MouseButton1Click:Connect(function()
    local musicName = musicNameInput.Text
    local musicId = musicIdInput.Text
    local category = R.musicCategoryInput.Text
    local price = tonumber(R.musicPriceInput.Text) or 0
    
    if musicName == "" or musicId == "" or category == "" then
        warn("⚠ Por favor completa todos los campos obligatorios")
        return
    end
    
    R.loadingPanel.Visible = true
    R.loadingLabel.Text = "Enviando música..."
    
    local success, result = pcall(function()
        return publishMusicFunction:InvokeServer(musicName, musicId, category, price)
    end)
    
    R.loadingPanel.Visible = false
    
    if success and result then
        musicNameInput.Text = ""
        musicIdInput.Text = ""
        R.musicCategoryInput.Text = ""
        R.musicPriceInput.Text = "0"
        musicPanel.Visible = false
        print("✓ Música enviada a revisión")
    else
        warn("✗ Error al enviar música:", result)
    end
end)

task.wait(0.1)
-- Adjusting the size calculation to account for new elements
local totalContentHeight = musicLayout.AbsoluteContentSize.Y + 60 -- Base height for header, etc.
if musicFieldsContainer then
    local fieldsLayoutAbsoluteContentSize = musicFieldsLayout.AbsoluteContentSize.Y
    -- Add heights of all elements within musicFieldsContainer to ensure correct scrolling
    local elements = musicFieldsContainer:GetChildren()
    for _, element in ipairs(elements) do
        if element:IsA("UIBaseObject") then
            fieldsLayoutAbsoluteContentSize = fieldsLayoutAbsoluteContentSize + element.Size.Y.Offset + musicFieldsLayout.Padding.Y.Offset -- Rough estimation
        end
    end
    musicFieldsContainer.Size = UDim2.new(1, 0, 0, fieldsLayoutAbsoluteContentSize)
    totalContentHeight = totalContentHeight + fieldsLayoutAbsoluteContentSize
end

musicPanel.CanvasSize = UDim2.new(0, 0, 0, totalContentHeight)

print("✓ Sistema de música cargado")

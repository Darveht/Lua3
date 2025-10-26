-- LocalScript: Coloca esto en StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- OCULTAR MUNDO 3D Y UI DE ROBLOX
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
player.CameraMode = Enum.CameraMode.LockFirstPerson
player.CameraMaxZoomDistance = 0.5
player.CameraMinZoomDistance = 0.5

-- Ocultar el jugador
local function hideCharacter(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
end

if player.Character then
    hideCharacter(player.Character)
end

player.CharacterAdded:Connect(hideCharacter)

-- ESPERAR REMOTES (con timeout de seguridad)
local remoteFolder = ReplicatedStorage:WaitForChild("RoogleRemotes", 10)

if not remoteFolder then
    warn("❌ ERROR: No se encontró la carpeta RoogleRemotes. Asegúrate de que Server.lua esté en ServerScriptService.")
    return
end

local getArticlesEvent = remoteFolder:WaitForChild("GetArticles", 5)
local publishArticleFunction = remoteFolder:WaitForChild("PublishArticle", 5)
local checkAdminEvent = remoteFolder:WaitForChild("CheckAdmin", 5)
local getArticleByIdEvent = remoteFolder:WaitForChild("GetArticleById", 5)
local getPendingArticlesEvent = remoteFolder:WaitForChild("GetPendingArticles", 5)
local getAllArticlesEvent = remoteFolder:WaitForChild("GetAllArticles", 5)
local toggleArticleStatusEvent = remoteFolder:WaitForChild("ToggleArticleStatus", 5)
local getUserProfileEvent = remoteFolder:WaitForChild("GetUserProfile", 5)
local followUserEvent = remoteFolder:WaitForChild("FollowUser", 5)
local unfollowUserEvent = remoteFolder:WaitForChild("UnfollowUser", 5)
local searchUsersEvent = remoteFolder:WaitForChild("SearchUsers", 5)
local verifyUserEvent = remoteFolder:WaitForChild("VerifyUser", 5)
local unverifyUserEvent = remoteFolder:WaitForChild("UnverifyUser", 5)
local getRobloxStatsEvent = remoteFolder:WaitForChild("GetRobloxStats", 5)

if not (getArticlesEvent and publishArticleFunction and checkAdminEvent and getArticleByIdEvent) then
    warn("❌ ERROR: No se pudieron cargar todos los RemoteEvents")
    return
end

-- Función para formatear números grandes (millones, miles)
local function formatLargeNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- Verificar si es admin
local isAdmin = checkAdminEvent:InvokeServer()

-- CREAR GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoogleGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Contenedor principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- ========== VISTA DE INICIO ==========
local centerContainer = Instance.new("Frame")
centerContainer.Size = UDim2.new(0.6, 0, 0, 150)
centerContainer.Position = UDim2.new(0.5, 0, 0.35, 0)
centerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
centerContainer.BackgroundTransparency = 1
centerContainer.Parent = mainFrame

local centerLayout = Instance.new("UIListLayout")
centerLayout.SortOrder = Enum.SortOrder.LayoutOrder
centerLayout.Padding = UDim.new(0, 15)
centerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
centerLayout.Parent = centerContainer

-- Logo
local logo = Instance.new("TextLabel")
logo.Name = "RoogleLogo"
logo.Size = UDim2.new(1, 0, 0, 60)
logo.BackgroundTransparency = 1
logo.Text = "Roogle"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 52
logo.TextColor3 = Color3.fromRGB(66, 133, 244)
logo.LayoutOrder = 1
logo.Parent = centerContainer

-- Barra de búsqueda principal
local searchContainer = Instance.new("Frame")
searchContainer.Name = "SearchContainer"
searchContainer.Size = UDim2.new(1, 0, 0, 50)
searchContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchContainer.BorderSizePixel = 0
searchContainer.LayoutOrder = 2
searchContainer.Parent = centerContainer

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 25)
searchCorner.Parent = searchContainer

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Color3.fromRGB(200, 200, 200)
searchStroke.Thickness = 1
searchStroke.Parent = searchContainer

local searchListLayout = Instance.new("UIListLayout")
searchListLayout.FillDirection = Enum.FillDirection.Horizontal
searchListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
searchListLayout.Parent = searchContainer

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 40, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = 24
searchIcon.Parent = searchContainer

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -80, 1, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Buscar en Roogle..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 18
searchBox.TextColor3 = Color3.fromRGB(0, 0, 0)
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchContainer

local searchButton = Instance.new("TextButton")
searchButton.Size = UDim2.new(0, 40, 1, 0)
searchButton.BackgroundTransparency = 1
searchButton.Text = "→"
searchButton.Font = Enum.Font.GothamBold
searchButton.TextSize = 24
searchButton.TextColor3 = Color3.fromRGB(66, 133, 244)
searchButton.Parent = searchContainer

-- ========== SECCIONES DE ARTÍCULOS EN INICIO ==========
local homeSectionsContainer = Instance.new("ScrollingFrame")
homeSectionsContainer.Name = "HomeSectionsContainer"
homeSectionsContainer.Size = UDim2.new(0.9, 0, 0.5, 0)
homeSectionsContainer.Position = UDim2.new(0.5, 0, 0.6, 0)
homeSectionsContainer.AnchorPoint = Vector2.new(0.5, 0)
homeSectionsContainer.BackgroundTransparency = 1
homeSectionsContainer.BorderSizePixel = 0
homeSectionsContainer.ScrollBarThickness = 6
homeSectionsContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
homeSectionsContainer.Parent = mainFrame

local homeSectionsLayout = Instance.new("UIListLayout")
homeSectionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
homeSectionsLayout.Padding = UDim.new(0, 30)
homeSectionsLayout.Parent = homeSectionsContainer

-- ========== VISTA DE RESULTADOS ==========
local resultsFrame = Instance.new("Frame")
resultsFrame.Name = "ResultsFrame"
resultsFrame.Size = UDim2.new(1, 0, 1, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resultsFrame.BorderSizePixel = 0
resultsFrame.Visible = false
resultsFrame.Parent = mainFrame

-- Header de resultados (ALTURA REDUCIDA - fijo en la parte superior)
local resultsHeader = Instance.new("Frame")
resultsHeader.Size = UDim2.new(1, 0, 0, 65)
resultsHeader.Position = UDim2.new(0, 0, 0, 0)
resultsHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resultsHeader.BorderSizePixel = 0
resultsHeader.ZIndex = 2
resultsHeader.Parent = resultsFrame

-- Botón volver al inicio (en resultados)
local homeButton = Instance.new("TextButton")
homeButton.Size = UDim2.new(0, 35, 0, 35)
homeButton.Position = UDim2.new(0, 12, 0.5, -17.5)
homeButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
homeButton.Text = "🏠"
homeButton.Font = Enum.Font.GothamBold
homeButton.TextSize = 18
homeButton.BorderSizePixel = 0
homeButton.ZIndex = 3
homeButton.Parent = resultsHeader

local homeCorner = Instance.new("UICorner")
homeCorner.CornerRadius = UDim.new(0, 17.5)
homeCorner.Parent = homeButton

local logoHeader = Instance.new("TextLabel")
logoHeader.Size = UDim2.new(0, 90, 1, 0)
logoHeader.Position = UDim2.new(0, 58, 0, 0)
logoHeader.BackgroundTransparency = 1
logoHeader.Text = "Roogle"
logoHeader.Font = Enum.Font.GothamBold
logoHeader.TextSize = 26
logoHeader.TextColor3 = Color3.fromRGB(66, 133, 244)
logoHeader.TextXAlignment = Enum.TextXAlignment.Left
logoHeader.Parent = resultsHeader

-- Barra de búsqueda en header (ALTURA REDUCIDA Y VISIBLE)
local searchContainerHeader = Instance.new("Frame")
searchContainerHeader.Name = "SearchContainerHeader"
searchContainerHeader.Size = UDim2.new(0, 450, 0, 38)
searchContainerHeader.Position = UDim2.new(0, 165, 0.5, -19)
searchContainerHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchContainerHeader.BorderSizePixel = 0
searchContainerHeader.ZIndex = 3
searchContainerHeader.Parent = resultsHeader

local searchCornerHeader = Instance.new("UICorner")
searchCornerHeader.CornerRadius = UDim.new(0, 19)
searchCornerHeader.Parent = searchContainerHeader

local searchLayoutHeader = Instance.new("UIListLayout")
searchLayoutHeader.FillDirection = Enum.FillDirection.Horizontal
searchLayoutHeader.VerticalAlignment = Enum.VerticalAlignment.Center
searchLayoutHeader.Parent = searchContainerHeader

local searchIconHeader = Instance.new("TextLabel")
searchIconHeader.Size = UDim2.new(0, 32, 1, 0)
searchIconHeader.BackgroundTransparency = 1
searchIconHeader.Text = "🔍"
searchIconHeader.TextSize = 18
searchIconHeader.ZIndex = 4
searchIconHeader.Parent = searchContainerHeader

local searchBoxHeader = Instance.new("TextBox")
searchBoxHeader.Name = "SearchBoxHeader"
searchBoxHeader.Size = UDim2.new(1, -64, 1, 0)
searchBoxHeader.BackgroundTransparency = 1
searchBoxHeader.Text = ""
searchBoxHeader.PlaceholderText = "Buscar..."
searchBoxHeader.Font = Enum.Font.Gotham
searchBoxHeader.TextSize = 15
searchBoxHeader.TextColor3 = Color3.fromRGB(0, 0, 0)
searchBoxHeader.TextXAlignment = Enum.TextXAlignment.Left
searchBoxHeader.ClearTextOnFocus = false
searchBoxHeader.ZIndex = 4
searchBoxHeader.Parent = searchContainerHeader

local searchButtonHeader = Instance.new("TextButton")
searchButtonHeader.Name = "SearchButtonHeader"
searchButtonHeader.Size = UDim2.new(0, 32, 1, 0)
searchButtonHeader.BackgroundTransparency = 1
searchButtonHeader.Text = "→"
searchButtonHeader.Font = Enum.Font.GothamBold
searchButtonHeader.TextSize = 20
searchButtonHeader.TextColor3 = Color3.fromRGB(66, 133, 244)
searchButtonHeader.ZIndex = 4
searchButtonHeader.Parent = searchContainerHeader

-- Lista de resultados (scrolleable, debajo del header - AJUSTADA)
local resultsScrollFrame = Instance.new("ScrollingFrame")
resultsScrollFrame.Name = "ResultsScrollFrame"
resultsScrollFrame.Size = UDim2.new(1, 0, 1, -65)
resultsScrollFrame.Position = UDim2.new(0, 0, 0, 65)
resultsScrollFrame.BackgroundTransparency = 1
resultsScrollFrame.BorderSizePixel = 0
resultsScrollFrame.ScrollBarThickness = 8
resultsScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
resultsScrollFrame.Parent = resultsFrame

local resultsLayout = Instance.new("UIListLayout")
resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
resultsLayout.Padding = UDim.new(0, 0)
resultsLayout.Parent = resultsScrollFrame

local resultsPadding = Instance.new("UIPadding")
resultsPadding.PaddingLeft = UDim.new(0, 30)
resultsPadding.PaddingRight = UDim.new(0, 30)
resultsPadding.PaddingTop = UDim.new(0, 20)
resultsPadding.PaddingBottom = UDim.new(0, 30)
resultsPadding.Parent = resultsScrollFrame

-- ========== VISTA DE ARTÍCULO COMPLETO ==========
local articleViewFrame = Instance.new("ScrollingFrame")
articleViewFrame.Name = "ArticleViewFrame"
articleViewFrame.Size = UDim2.new(1, 0, 1, 0)
articleViewFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
articleViewFrame.BorderSizePixel = 0
articleViewFrame.ScrollBarThickness = 8
articleViewFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
articleViewFrame.Visible = false
articleViewFrame.Parent = mainFrame

local articleLayout = Instance.new("UIListLayout")
articleLayout.SortOrder = Enum.SortOrder.LayoutOrder
articleLayout.Padding = UDim.new(0, 20)
articleLayout.Parent = articleViewFrame

local articlePadding = Instance.new("UIPadding")
articlePadding.PaddingLeft = UDim.new(0, 25)
articlePadding.PaddingRight = UDim.new(0, 25)
articlePadding.PaddingTop = UDim.new(0, 30)
articlePadding.PaddingBottom = UDim.new(0, 30)
articlePadding.Parent = articleViewFrame

-- Botón volver
local backButton = Instance.new("TextButton")
backButton.Name = "BackButton"
backButton.Size = UDim2.new(0, 100, 0, 40)
backButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
backButton.Text = "← Volver"
backButton.Font = Enum.Font.GothamBold
backButton.TextSize = 16
backButton.TextColor3 = Color3.fromRGB(60, 60, 60)
backButton.BorderSizePixel = 0
backButton.LayoutOrder = 1
backButton.Parent = articleViewFrame

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 8)
backCorner.Parent = backButton

-- ========== VISTA DE PERFIL DE USUARIO ==========
local profileFrame = Instance.new("ScrollingFrame")
profileFrame.Name = "ProfileFrame"
profileFrame.Size = UDim2.new(1, 0, 1, 0)
profileFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
profileFrame.BorderSizePixel = 0
profileFrame.ScrollBarThickness = 8
profileFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
profileFrame.Visible = false
profileFrame.Parent = mainFrame

local profileLayout = Instance.new("UIListLayout")
profileLayout.SortOrder = Enum.SortOrder.LayoutOrder
profileLayout.Padding = UDim.new(0, 20)
profileLayout.Parent = profileFrame

local profilePadding = Instance.new("UIPadding")
profilePadding.PaddingLeft = UDim.new(0, 30)
profilePadding.PaddingRight = UDim.new(0, 30)
profilePadding.PaddingTop = UDim.new(0, 30)
profilePadding.PaddingBottom = UDim.new(0, 30)
profilePadding.Parent = profileFrame

-- Botón volver del perfil
local profileBackButton = Instance.new("TextButton")
profileBackButton.Name = "ProfileBackButton"
profileBackButton.Size = UDim2.new(0, 100, 0, 40)
profileBackButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
profileBackButton.Text = "← Volver"
profileBackButton.Font = Enum.Font.GothamBold
profileBackButton.TextSize = 16
profileBackButton.TextColor3 = Color3.fromRGB(60, 60, 60)
profileBackButton.BorderSizePixel = 0
profileBackButton.LayoutOrder = 1
profileBackButton.Parent = profileFrame

local profileBackCorner = Instance.new("UICorner")
profileBackCorner.CornerRadius = UDim.new(0, 8)
profileBackCorner.Parent = profileBackButton

-- ========== PANEL DE CARGA ==========
local loadingPanel = Instance.new("Frame")
loadingPanel.Size = UDim2.new(1, 0, 1, 0)
loadingPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingPanel.BackgroundTransparency = 0.7
loadingPanel.BorderSizePixel = 0
loadingPanel.Visible = false
loadingPanel.ZIndex = 20
loadingPanel.Parent = mainFrame

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(0.5, 0, 0, 50)
loadingLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "Enviando a revisión..."
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextSize = 28
loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingLabel.Parent = loadingPanel

-- ========== BOTONES DE NAVEGACIÓN SUPERIOR ==========
-- Botón de creador (icono)
local creatorButton = Instance.new("TextButton")
creatorButton.Name = "CreatorButton"
creatorButton.Size = UDim2.new(0, 45, 0, 45)
creatorButton.Position = UDim2.new(1, -70, 0, 15)
creatorButton.AnchorPoint = Vector2.new(1, 0)
creatorButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
creatorButton.Text = "✏️"
creatorButton.Font = Enum.Font.GothamBold
creatorButton.TextSize = 22
creatorButton.BorderSizePixel = 0
creatorButton.ZIndex = 5
creatorButton.Parent = mainFrame

local creatorCorner = Instance.new("UICorner")
creatorCorner.CornerRadius = UDim.new(1, 0)
creatorCorner.Parent = creatorButton

-- Botón de administrador (solo visible para admins)
local adminPanelButton
if isAdmin then
    adminPanelButton = Instance.new("TextButton")
    adminPanelButton.Name = "AdminPanelButton"
    adminPanelButton.Size = UDim2.new(0, 45, 0, 45)
    adminPanelButton.Position = UDim2.new(1, -15, 0, 15)
    adminPanelButton.AnchorPoint = Vector2.new(1, 0)
    adminPanelButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
    adminPanelButton.Text = "👑"
    adminPanelButton.Font = Enum.Font.GothamBold
    adminPanelButton.TextSize = 22
    adminPanelButton.BorderSizePixel = 0
    adminPanelButton.ZIndex = 5
    adminPanelButton.Parent = mainFrame
    
    local adminPanelCorner = Instance.new("UICorner")
    adminPanelCorner.CornerRadius = UDim.new(1, 0)
    adminPanelCorner.Parent = adminPanelButton
end

-- ========== PANEL DE CREADOR (PANTALLA COMPLETA) ==========
local creatorPanel = Instance.new("ScrollingFrame")
creatorPanel.Name = "CreatorPanel"
creatorPanel.Size = UDim2.new(1, 0, 1, 0)
creatorPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
creatorPanel.BorderSizePixel = 0
creatorPanel.Visible = false
creatorPanel.ZIndex = 10
creatorPanel.ScrollBarThickness = 8
creatorPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
creatorPanel.Parent = mainFrame

local creatorLayout = Instance.new("UIListLayout")
creatorLayout.SortOrder = Enum.SortOrder.LayoutOrder
creatorLayout.Padding = UDim.new(0, 20)
creatorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
creatorLayout.Parent = creatorPanel

local creatorPadding = Instance.new("UIPadding")
creatorPadding.PaddingLeft = UDim.new(0, 20)
creatorPadding.PaddingRight = UDim.new(0, 20)
creatorPadding.PaddingTop = UDim.new(0, 30)
creatorPadding.PaddingBottom = UDim.new(0, 30)
creatorPadding.Parent = creatorPanel

-- Header con título y botón cerrar
local creatorHeaderContainer = Instance.new("Frame")
creatorHeaderContainer.Size = UDim2.new(1, 0, 0, 50)
creatorHeaderContainer.BackgroundTransparency = 1
creatorHeaderContainer.LayoutOrder = 1
creatorHeaderContainer.Parent = creatorPanel

local creatorTitle = Instance.new("TextLabel")
creatorTitle.Size = UDim2.new(1, -60, 1, 0)
creatorTitle.Position = UDim2.new(0, 0, 0, 0)
creatorTitle.BackgroundTransparency = 1
creatorTitle.Text = "✏️ CREAR ARTÍCULO"
creatorTitle.Font = Enum.Font.GothamBold
creatorTitle.TextSize = 28
creatorTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
creatorTitle.TextXAlignment = Enum.TextXAlignment.Left
creatorTitle.TextScaled = false
creatorTitle.ZIndex = 11
creatorTitle.Parent = creatorHeaderContainer

local creatorCloseButton = Instance.new("TextButton")
creatorCloseButton.Size = UDim2.new(0, 45, 0, 45)
creatorCloseButton.Position = UDim2.new(1, 0, 0, 0)
creatorCloseButton.AnchorPoint = Vector2.new(1, 0)
creatorCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
creatorCloseButton.Text = "✕"
creatorCloseButton.Font = Enum.Font.GothamBold
creatorCloseButton.TextSize = 24
creatorCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
creatorCloseButton.BorderSizePixel = 0
creatorCloseButton.ZIndex = 11
creatorCloseButton.Parent = creatorHeaderContainer

local creatorCloseCorner = Instance.new("UICorner")
creatorCloseCorner.CornerRadius = UDim.new(1, 0)
creatorCloseCorner.Parent = creatorCloseButton

-- Contenedor de campos
local creatorFieldsContainer = Instance.new("Frame")
creatorFieldsContainer.Size = UDim2.new(1, 0, 0, 600)
creatorFieldsContainer.BackgroundTransparency = 1
creatorFieldsContainer.LayoutOrder = 2
creatorFieldsContainer.Parent = creatorPanel

local creatorFieldsLayout = Instance.new("UIListLayout")
creatorFieldsLayout.SortOrder = Enum.SortOrder.LayoutOrder
creatorFieldsLayout.Padding = UDim.new(0, 15)
creatorFieldsLayout.Parent = creatorFieldsContainer

-- Etiqueta Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📝 Título del artículo"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.LayoutOrder = 1
titleLabel.ZIndex = 11
titleLabel.Parent = creatorFieldsContainer

-- Campo Título
local titleInput = Instance.new("TextBox")
titleInput.Name = "TitleInput"
titleInput.Size = UDim2.new(1, 0, 0, 50)
titleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
titleInput.Text = ""
titleInput.PlaceholderText = "Escribe el título del artículo..."
titleInput.Font = Enum.Font.Gotham
titleInput.TextSize = 18
titleInput.TextColor3 = Color3.fromRGB(0, 0, 0)
titleInput.TextXAlignment = Enum.TextXAlignment.Left
titleInput.ClearTextOnFocus = false
titleInput.BorderSizePixel = 0
titleInput.LayoutOrder = 2
titleInput.ZIndex = 11
titleInput.Parent = creatorFieldsContainer

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleInput

local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 15)
titlePadding.PaddingRight = UDim.new(0, 15)
titlePadding.Parent = titleInput

-- Etiqueta Contenido
local contentLabel = Instance.new("TextLabel")
contentLabel.Size = UDim2.new(1, 0, 0, 25)
contentLabel.BackgroundTransparency = 1
contentLabel.Text = "📄 Contenido del artículo"
contentLabel.Font = Enum.Font.GothamBold
contentLabel.TextSize = 18
contentLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
contentLabel.TextXAlignment = Enum.TextXAlignment.Left
contentLabel.LayoutOrder = 3
contentLabel.ZIndex = 11
contentLabel.Parent = creatorFieldsContainer

-- Campo Contenido
local contentInput = Instance.new("TextBox")
contentInput.Name = "ContentInput"
contentInput.Size = UDim2.new(1, 0, 0, 350)
contentInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
contentInput.Text = ""
contentInput.PlaceholderText = "Escribe el contenido completo del artículo..."
contentInput.Font = Enum.Font.Gotham
contentInput.TextSize = 18
contentInput.TextColor3 = Color3.fromRGB(0, 0, 0)
contentInput.TextXAlignment = Enum.TextXAlignment.Left
contentInput.TextYAlignment = Enum.TextYAlignment.Top
contentInput.ClearTextOnFocus = false
contentInput.MultiLine = true
contentInput.TextWrapped = true
contentInput.BorderSizePixel = 0
contentInput.LayoutOrder = 4
contentInput.ZIndex = 11
contentInput.Parent = creatorFieldsContainer

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = contentInput

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingLeft = UDim.new(0, 15)
contentPadding.PaddingTop = UDim.new(0, 15)
contentPadding.PaddingRight = UDim.new(0, 15)
contentPadding.PaddingBottom = UDim.new(0, 15)
contentPadding.Parent = contentInput

-- Botón enviar a revisión
local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(1, 0, 0, 55)
submitButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
submitButton.Text = "📤 Enviar a Revisión"
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 20
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.BorderSizePixel = 0
submitButton.LayoutOrder = 5
submitButton.ZIndex = 11
submitButton.Parent = creatorFieldsContainer

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 10)
submitCorner.Parent = submitButton

-- Actualizar CanvasSize dinámicamente
task.wait(0.1)
creatorFieldsContainer.Size = UDim2.new(1, 0, 0, creatorFieldsLayout.AbsoluteContentSize.Y)
creatorPanel.CanvasSize = UDim2.new(0, 0, 0, creatorLayout.AbsoluteContentSize.Y + 60)

-- ========== PANEL DE ADMINISTRADOR (solo para admins) ==========
local adminPanel
local adminScrollContainer
local adminSearchBox
local allArticlesContainer

if isAdmin then
    adminPanel = Instance.new("ScrollingFrame")
    adminPanel.Name = "AdminPanel"
    adminPanel.Size = UDim2.new(1, 0, 1, 0)
    adminPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    adminPanel.BorderSizePixel = 0
    adminPanel.Visible = false
    adminPanel.ZIndex = 10
    adminPanel.ScrollBarThickness = 8
    adminPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    adminPanel.Parent = mainFrame
    
    local adminLayout = Instance.new("UIListLayout")
    adminLayout.SortOrder = Enum.SortOrder.LayoutOrder
    adminLayout.Padding = UDim.new(0, 15)
    adminLayout.Parent = adminPanel
    
    local adminPadding = Instance.new("UIPadding")
    adminPadding.PaddingLeft = UDim.new(0, 30)
    adminPadding.PaddingRight = UDim.new(0, 30)
    adminPadding.PaddingTop = UDim.new(0, 30)
    adminPadding.PaddingBottom = UDim.new(0, 30)
    adminPadding.Parent = adminPanel
    
    -- Header del panel de admin
    local adminHeaderContainer = Instance.new("Frame")
    adminHeaderContainer.Size = UDim2.new(1, 0, 0, 60)
    adminHeaderContainer.BackgroundTransparency = 1
    adminHeaderContainer.LayoutOrder = 1
    adminHeaderContainer.Parent = adminPanel
    
    local adminPanelTitle = Instance.new("TextLabel")
    adminPanelTitle.Size = UDim2.new(1, -60, 1, 0)
    adminPanelTitle.BackgroundTransparency = 1
    adminPanelTitle.Text = "👑 PANEL"
    adminPanelTitle.Font = Enum.Font.GothamBold
    adminPanelTitle.TextSize = 28
    adminPanelTitle.TextColor3 = Color3.fromRGB(234, 67, 53)
    adminPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
    adminPanelTitle.ZIndex = 11
    adminPanelTitle.Parent = adminHeaderContainer
    
    local adminCloseButton = Instance.new("TextButton")
    adminCloseButton.Size = UDim2.new(0, 45, 0, 45)
    adminCloseButton.Position = UDim2.new(1, 0, 0, 0)
    adminCloseButton.AnchorPoint = Vector2.new(1, 0)
    adminCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    adminCloseButton.Text = "✕"
    adminCloseButton.Font = Enum.Font.GothamBold
    adminCloseButton.TextSize = 24
    adminCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
    adminCloseButton.BorderSizePixel = 0
    adminCloseButton.ZIndex = 11
    adminCloseButton.Parent = adminHeaderContainer
    
    local adminCloseCorner = Instance.new("UICorner")
    adminCloseCorner.CornerRadius = UDim.new(1, 0)
    adminCloseCorner.Parent = adminCloseButton
    
    -- Sección: Buscar y Verificar Usuarios
    local userManagementTitle = Instance.new("TextLabel")
    userManagementTitle.Size = UDim2.new(1, 0, 0, 30)
    userManagementTitle.BackgroundTransparency = 1
    userManagementTitle.Text = "👥 Gestión de Usuarios"
    userManagementTitle.Font = Enum.Font.GothamBold
    userManagementTitle.TextSize = 22
    userManagementTitle.TextColor3 = Color3.fromRGB(50, 50, 50)
    userManagementTitle.TextXAlignment = Enum.TextXAlignment.Left
    userManagementTitle.LayoutOrder = 2
    userManagementTitle.ZIndex = 11
    userManagementTitle.Parent = adminPanel
    
    -- Barra de búsqueda de usuarios
    local userSearchContainer = Instance.new("Frame")
    userSearchContainer.Size = UDim2.new(1, 0, 0, 50)
    userSearchContainer.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    userSearchContainer.BorderSizePixel = 0
    userSearchContainer.LayoutOrder = 3
    userSearchContainer.ZIndex = 11
    userSearchContainer.Parent = adminPanel
    
    local userSearchCorner = Instance.new("UICorner")
    userSearchCorner.CornerRadius = UDim.new(0, 10)
    userSearchCorner.Parent = userSearchContainer
    
    local userSearchLayout = Instance.new("UIListLayout")
    userSearchLayout.FillDirection = Enum.FillDirection.Horizontal
    userSearchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    userSearchLayout.Padding = UDim.new(0, 10)
    userSearchLayout.Parent = userSearchContainer
    
    local userSearchPadding = Instance.new("UIPadding")
    userSearchPadding.PaddingLeft = UDim.new(0, 15)
    userSearchPadding.PaddingRight = UDim.new(0, 15)
    userSearchPadding.Parent = userSearchContainer
    
    local userSearchIcon = Instance.new("TextLabel")
    userSearchIcon.Size = UDim2.new(0, 30, 0, 30)
    userSearchIcon.BackgroundTransparency = 1
    userSearchIcon.Text = "🔍"
    userSearchIcon.TextSize = 20
    userSearchIcon.ZIndex = 12
    userSearchIcon.Parent = userSearchContainer
    
    adminSearchBox = Instance.new("TextBox")
    adminSearchBox.Name = "AdminSearchBox"
    adminSearchBox.Size = UDim2.new(1, -50, 1, 0)
    adminSearchBox.BackgroundTransparency = 1
    adminSearchBox.Text = ""
    adminSearchBox.PlaceholderText = "Buscar usuario por nombre..."
    adminSearchBox.Font = Enum.Font.Gotham
    adminSearchBox.TextSize = 18
    adminSearchBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    adminSearchBox.TextXAlignment = Enum.TextXAlignment.Left
    adminSearchBox.ClearTextOnFocus = false
    adminSearchBox.ZIndex = 12
    adminSearchBox.Parent = userSearchContainer
    
    -- Contenedor de resultados de búsqueda de usuarios
    adminScrollContainer = Instance.new("ScrollingFrame")
    adminScrollContainer.Name = "AdminScrollContainer"
    adminScrollContainer.Size = UDim2.new(1, 0, 0, 250)
    adminScrollContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    adminScrollContainer.BorderSizePixel = 0
    adminScrollContainer.ScrollBarThickness = 6
    adminScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    adminScrollContainer.LayoutOrder = 4
    adminScrollContainer.ZIndex = 11
    adminScrollContainer.Parent = adminPanel
    
    local adminScrollCorner = Instance.new("UICorner")
    adminScrollCorner.CornerRadius = UDim.new(0, 10)
    adminScrollCorner.Parent = adminScrollContainer
    
    local adminScrollLayout = Instance.new("UIListLayout")
    adminScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    adminScrollLayout.Padding = UDim.new(0, 10)
    adminScrollLayout.Parent = adminScrollContainer
    
    local adminScrollPadding = Instance.new("UIPadding")
    adminScrollPadding.PaddingLeft = UDim.new(0, 15)
    adminScrollPadding.PaddingRight = UDim.new(0, 15)
    adminScrollPadding.PaddingTop = UDim.new(0, 15)
    adminScrollPadding.PaddingBottom = UDim.new(0, 15)
    adminScrollPadding.Parent = adminScrollContainer
    
    -- Separador
    local separator1 = Instance.new("Frame")
    separator1.Size = UDim2.new(1, 0, 0, 2)
    separator1.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    separator1.BorderSizePixel = 0
    separator1.LayoutOrder = 5
    separator1.ZIndex = 11
    separator1.Parent = adminPanel
    
    -- Sección: Gestión de Artículos
    local articlesManagementTitle = Instance.new("TextLabel")
    articlesManagementTitle.Size = UDim2.new(1, 0, 0, 30)
    articlesManagementTitle.BackgroundTransparency = 1
    articlesManagementTitle.Text = "📋 Gestión de Artículos"
    articlesManagementTitle.Font = Enum.Font.GothamBold
    articlesManagementTitle.TextSize = 22
    articlesManagementTitle.TextColor3 = Color3.fromRGB(50, 50, 50)
    articlesManagementTitle.TextXAlignment = Enum.TextXAlignment.Left
    articlesManagementTitle.LayoutOrder = 6
    articlesManagementTitle.ZIndex = 11
    articlesManagementTitle.Parent = adminPanel
    
    -- Botón actualizar
    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.new(1, 0, 0, 45)
    refreshButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
    refreshButton.Text = "🔄 Actualizar Artículos"
    refreshButton.Font = Enum.Font.GothamBold
    refreshButton.TextSize = 18
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.BorderSizePixel = 0
    refreshButton.LayoutOrder = 7
    refreshButton.ZIndex = 11
    refreshButton.Parent = adminPanel
    
    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 10)
    refreshCorner.Parent = refreshButton
    
    -- Contenedor de todos los artículos
    allArticlesContainer = Instance.new("ScrollingFrame")
    allArticlesContainer.Name = "AllArticlesContainer"
    allArticlesContainer.Size = UDim2.new(1, 0, 0, 400)
    allArticlesContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    allArticlesContainer.BorderSizePixel = 0
    allArticlesContainer.ScrollBarThickness = 6
    allArticlesContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    allArticlesContainer.LayoutOrder = 8
    allArticlesContainer.ZIndex = 11
    allArticlesContainer.Parent = adminPanel
    
    local allArticlesCorner = Instance.new("UICorner")
    allArticlesCorner.CornerRadius = UDim.new(0, 10)
    allArticlesCorner.Parent = allArticlesContainer
    
    local allArticlesLayout = Instance.new("UIListLayout")
    allArticlesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    allArticlesLayout.Padding = UDim.new(0, 10)
    allArticlesLayout.Parent = allArticlesContainer
    
    local allArticlesPadding = Instance.new("UIPadding")
    allArticlesPadding.PaddingLeft = UDim.new(0, 15)
    allArticlesPadding.PaddingRight = UDim.new(0, 15)
    allArticlesPadding.PaddingTop = UDim.new(0, 15)
    allArticlesPadding.PaddingBottom = UDim.new(0, 15)
    allArticlesPadding.Parent = allArticlesContainer
    
    -- Separador
    local separator2 = Instance.new("Frame")
    separator2.Size = UDim2.new(1, 0, 0, 2)
    separator2.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    separator2.BorderSizePixel = 0
    separator2.LayoutOrder = 9
    separator2.ZIndex = 11
    separator2.Parent = adminPanel
    
    -- Sección: Publicar como Sistema
    local systemTitle = Instance.new("TextLabel")
    systemTitle.Size = UDim2.new(1, 0, 0, 30)
    systemTitle.BackgroundTransparency = 1
    systemTitle.Text = "📢 Publicar Anuncio del Sistema"
    systemTitle.Font = Enum.Font.GothamBold
    systemTitle.TextSize = 22
    systemTitle.TextColor3 = Color3.fromRGB(50, 50, 50)
    systemTitle.TextXAlignment = Enum.TextXAlignment.Left
    systemTitle.LayoutOrder = 10
    systemTitle.ZIndex = 11
    systemTitle.Parent = adminPanel
    
    -- Campo título del sistema
    local systemTitleInput = Instance.new("TextBox")
    systemTitleInput.Name = "SystemTitleInput"
    systemTitleInput.Size = UDim2.new(1, 0, 0, 50)
    systemTitleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    systemTitleInput.Text = ""
    systemTitleInput.PlaceholderText = "Título del anuncio..."
    systemTitleInput.Font = Enum.Font.Gotham
    systemTitleInput.TextSize = 18
    systemTitleInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    systemTitleInput.TextXAlignment = Enum.TextXAlignment.Left
    systemTitleInput.ClearTextOnFocus = false
    systemTitleInput.BorderSizePixel = 0
    systemTitleInput.LayoutOrder = 11
    systemTitleInput.ZIndex = 11
    systemTitleInput.Parent = adminPanel
    
    local systemTitleCorner = Instance.new("UICorner")
    systemTitleCorner.CornerRadius = UDim.new(0, 10)
    systemTitleCorner.Parent = systemTitleInput
    
    local systemTitlePadding = Instance.new("UIPadding")
    systemTitlePadding.PaddingLeft = UDim.new(0, 15)
    systemTitlePadding.PaddingRight = UDim.new(0, 15)
    systemTitlePadding.Parent = systemTitleInput
    
    -- Campo contenido del sistema
    local systemContentInput = Instance.new("TextBox")
    systemContentInput.Name = "SystemContentInput"
    systemContentInput.Size = UDim2.new(1, 0, 0, 150)
    systemContentInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    systemContentInput.Text = ""
    systemContentInput.PlaceholderText = "Contenido del anuncio..."
    systemContentInput.Font = Enum.Font.Gotham
    systemContentInput.TextSize = 16
    systemContentInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    systemContentInput.TextXAlignment = Enum.TextXAlignment.Left
    systemContentInput.TextYAlignment = Enum.TextYAlignment.Top
    systemContentInput.ClearTextOnFocus = false
    systemContentInput.MultiLine = true
    systemContentInput.TextWrapped = true
    systemContentInput.BorderSizePixel = 0
    systemContentInput.LayoutOrder = 12
    systemContentInput.ZIndex = 11
    systemContentInput.Parent = adminPanel
    
    local systemContentCorner = Instance.new("UICorner")
    systemContentCorner.CornerRadius = UDim.new(0, 10)
    systemContentCorner.Parent = systemContentInput
    
    local systemContentPadding = Instance.new("UIPadding")
    systemContentPadding.PaddingLeft = UDim.new(0, 15)
    systemContentPadding.PaddingTop = UDim.new(0, 15)
    systemContentPadding.PaddingRight = UDim.new(0, 15)
    systemContentPadding.PaddingBottom = UDim.new(0, 15)
    systemContentPadding.Parent = systemContentInput
    
    -- Botón publicar como sistema
    local systemPublishButton = Instance.new("TextButton")
    systemPublishButton.Name = "SystemPublishButton"
    systemPublishButton.Size = UDim2.new(1, 0, 0, 50)
    systemPublishButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
    systemPublishButton.Text = "📢 Publicar como Sistema"
    systemPublishButton.Font = Enum.Font.GothamBold
    systemPublishButton.TextSize = 18
    systemPublishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    systemPublishButton.BorderSizePixel = 0
    systemPublishButton.LayoutOrder = 13
    systemPublishButton.ZIndex = 11
    systemPublishButton.Parent = adminPanel
    
    local systemPublishCorner = Instance.new("UICorner")
    systemPublishCorner.CornerRadius = UDim.new(0, 10)
    systemPublishCorner.Parent = systemPublishButton
    
    -- Conectar botón de publicar sistema
    systemPublishButton.MouseButton1Click:Connect(function()
        local title = systemTitleInput.Text
        local content = systemContentInput.Text
        
        if title ~= "" and content ~= "" then
            loadingPanel.Visible = true
            loadingLabel.Text = "Publicando anuncio del sistema..."
            
            -- Pasar true como tercer parámetro para publicar como Sistema
            local success, result = pcall(function()
                return publishArticleFunction:InvokeServer(title, content, true)
            end)
            
            loadingPanel.Visible = false
            
            if success and result then
                systemTitleInput.Text = ""
                systemContentInput.Text = ""
                loadAllArticles()
                loadHomeSections() -- Actualizar página de inicio
                print("✓ Anuncio del sistema publicado")
            else
                warn("✗ Error al publicar anuncio")
            end
        else
            warn("⚠ Completa título y contenido")
        end
    end)
end

-- ========== FUNCIONES ==========

local previousView = "home"

local function setInterfaceView(viewName)
    previousView = (centerContainer.Visible and "home") or (resultsFrame.Visible and "results") or (articleViewFrame.Visible and "article") or (profileFrame.Visible and "profile") or previousView
    
    centerContainer.Visible = (viewName == "home")
    homeSectionsContainer.Visible = (viewName == "home")
    resultsFrame.Visible = (viewName == "results")
    articleViewFrame.Visible = (viewName == "article")
    profileFrame.Visible = (viewName == "profile")
    creatorPanel.Visible = (viewName == "creator")
    if adminPanel then
        adminPanel.Visible = (viewName == "admin")
    end
    
    if viewName == "home" then
        loadHomeSections()
    end
end

-- Función para crear insignia de verificación (PALOMITA ✓)
local function createVerifiedBadge()
    local badgeContainer = Instance.new("Frame")
    badgeContainer.Name = "VerifiedBadge"
    badgeContainer.Size = UDim2.new(0, 20, 0, 20)
    badgeContainer.BackgroundColor3 = Color3.fromRGB(29, 161, 242)
    badgeContainer.BorderSizePixel = 0
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = badgeContainer
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.Font = Enum.Font.GothamBold
    checkmark.TextSize = 14
    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkmark.Parent = badgeContainer
    
    return badgeContainer
end

-- Función para mostrar perfil de usuario
local function showUserProfile(userId)
    loadingPanel.Visible = true
    loadingLabel.Text = "Cargando perfil..."
    
    local success, profileData = pcall(function()
        return getUserProfileEvent:InvokeServer(userId)
    end)
    
    loadingPanel.Visible = false
    
    if not success or not profileData then
        warn("No se pudo cargar el perfil del usuario")
        return
    end
    
    -- Limpiar perfil anterior
    for _, child in ipairs(profileFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and child.Name ~= "ProfileBackButton" then
            child:Destroy()
        end
    end
    
    local userInfo = profileData.userInfo
    local articles = profileData.articles
    
    -- Contenedor de información del usuario
    local userInfoContainer = Instance.new("Frame")
    userInfoContainer.Size = UDim2.new(1, 0, 0, 230)
    userInfoContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    userInfoContainer.BorderSizePixel = 0
    userInfoContainer.LayoutOrder = 2
    userInfoContainer.Parent = profileFrame
    
    local userInfoCorner = Instance.new("UICorner")
    userInfoCorner.CornerRadius = UDim.new(0, 15)
    userInfoCorner.Parent = userInfoContainer
    
    local userInfoLayout = Instance.new("UIListLayout")
    userInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    userInfoLayout.Padding = UDim.new(0, 12)
    userInfoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    userInfoLayout.Parent = userInfoContainer
    
    local userInfoPadding = Instance.new("UIPadding")
    userInfoPadding.PaddingLeft = UDim.new(0, 20)
    userInfoPadding.PaddingRight = UDim.new(0, 20)
    userInfoPadding.PaddingTop = UDim.new(0, 20)
    userInfoPadding.PaddingBottom = UDim.new(0, 20)
    userInfoPadding.Parent = userInfoContainer
    
    -- Foto de perfil
    local profileImage = Instance.new("ImageLabel")
    profileImage.Size = UDim2.new(0, 100, 0, 100)
    profileImage.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    profileImage.Image = userInfo.thumbnail
    profileImage.LayoutOrder = 1
    profileImage.Parent = userInfoContainer
    
    local profileImageCorner = Instance.new("UICorner")
    profileImageCorner.CornerRadius = UDim.new(1, 0)
    profileImageCorner.Parent = profileImage
    
    -- Nombre de usuario con insignia (INSIGNIA AL LADO DEL NOMBRE)
    local usernameContainer = Instance.new("Frame")
    usernameContainer.Size = UDim2.new(1, 0, 0, 30)
    usernameContainer.BackgroundTransparency = 1
    usernameContainer.LayoutOrder = 2
    usernameContainer.Parent = userInfoContainer
    
    local usernameLayout = Instance.new("UIListLayout")
    usernameLayout.FillDirection = Enum.FillDirection.Horizontal
    usernameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    usernameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    usernameLayout.Padding = UDim.new(0, 6)
    usernameLayout.Parent = usernameContainer
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0, 0, 0, 30)
    usernameLabel.AutomaticSize = Enum.AutomaticSize.X
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = userInfo.username
    usernameLabel.Font = Enum.Font.GothamBold
    usernameLabel.TextSize = 24
    usernameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    usernameLabel.Parent = usernameContainer
    
    -- INSIGNIA AL LADO DEL NOMBRE (NO DE LA FECHA)
    if userInfo.verified then
        local verifiedBadge = createVerifiedBadge()
        verifiedBadge.Parent = usernameContainer
    end
    
    -- Estadísticas (seguidores, siguiendo, artículos)
    local statsContainer = Instance.new("Frame")
    statsContainer.Size = UDim2.new(1, 0, 0, 25)
    statsContainer.BackgroundTransparency = 1
    statsContainer.LayoutOrder = 3
    statsContainer.Parent = userInfoContainer
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.FillDirection = Enum.FillDirection.Horizontal
    statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    statsLayout.Padding = UDim.new(0, 20)
    statsLayout.Parent = statsContainer
    
    local followersLabel = Instance.new("TextLabel")
    followersLabel.Name = "FollowersLabel"
    followersLabel.Size = UDim2.new(0, 0, 1, 0)
    followersLabel.AutomaticSize = Enum.AutomaticSize.X
    followersLabel.BackgroundTransparency = 1
    followersLabel.Font = Enum.Font.Gotham
    followersLabel.TextSize = 16
    followersLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    followersLabel.Parent = statsContainer
    
    local followingLabel = Instance.new("TextLabel")
    followingLabel.Size = UDim2.new(0, 0, 1, 0)
    followingLabel.AutomaticSize = Enum.AutomaticSize.X
    followingLabel.BackgroundTransparency = 1
    followingLabel.Font = Enum.Font.Gotham
    followingLabel.TextSize = 16
    followingLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    followingLabel.Parent = statsContainer
    
    local articlesLabel = Instance.new("TextLabel")
    articlesLabel.Size = UDim2.new(0, 0, 1, 0)
    articlesLabel.AutomaticSize = Enum.AutomaticSize.X
    articlesLabel.BackgroundTransparency = 1
    articlesLabel.Text = string.format("%d Artículos", #articles)
    articlesLabel.Font = Enum.Font.Gotham
    articlesLabel.TextSize = 16
    articlesLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    articlesLabel.Parent = statsContainer
    
    -- DETECTOR: Si es el usuario Sistema (userId = 1), obtener estadísticas reales de Roblox
    if userId == 1 then
        followersLabel.Text = "Cargando..."
        followingLabel.Text = "Cargando..."
        
        task.spawn(function()
            local success, robloxStats = pcall(function()
                return getRobloxStatsEvent:InvokeServer(userId)
            end)
            
            if success and robloxStats then
                followersLabel.Text = string.format("%s Seguidores", formatLargeNumber(robloxStats.followers))
                followingLabel.Text = string.format("%s Siguiendo", formatLargeNumber(robloxStats.following))
            else
                -- Si falla, usar valores de la base de datos
                followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                followingLabel.Text = string.format("%d Siguiendo", profileData.followingCount)
            end
        end)
    else
        -- Para usuarios normales, usar valores de la base de datos
        followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
        followingLabel.Text = string.format("%d Siguiendo", profileData.followingCount)
    end
    
    -- BOTÓN SEGUIR ANTES QUE ARTÍCULOS (solo si no es el propio perfil)
    if userId ~= player.UserId then
        local followButton = Instance.new("TextButton")
        followButton.Name = "FollowButton"
        followButton.Size = UDim2.new(0, 150, 0, 40)
        followButton.BackgroundColor3 = profileData.isFollowing and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(66, 133, 244)
        followButton.Text = profileData.isFollowing and "Dejar de Seguir" or "Seguir"
        followButton.Font = Enum.Font.GothamBold
        followButton.TextSize = 16
        followButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        followButton.BorderSizePixel = 0
        followButton.LayoutOrder = 4
        followButton.Parent = userInfoContainer
        
        local followCorner = Instance.new("UICorner")
        followCorner.CornerRadius = UDim.new(0, 10)
        followCorner.Parent = followButton
        
        followButton.MouseButton1Click:Connect(function()
            local success, result
            if profileData.isFollowing then
                success, result = pcall(function()
                    return unfollowUserEvent:InvokeServer(userId)
                end)
                if success and result then
                    followButton.Text = "Seguir"
                    followButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                    profileData.isFollowing = false
                    profileData.followersCount = profileData.followersCount - 1
                    followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                end
            else
                success, result = pcall(function()
                    return followUserEvent:InvokeServer(userId)
                end)
                if success and result then
                    followButton.Text = "Dejar de Seguir"
                    followButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    profileData.isFollowing = true
                    profileData.followersCount = profileData.followersCount + 1
                    followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                end
            end
        end)
    end
    
    -- Título de artículos DESPUÉS DEL BOTÓN SEGUIR
    local articlesTitle = Instance.new("TextLabel")
    articlesTitle.Size = UDim2.new(1, 0, 0, 30)
    articlesTitle.BackgroundTransparency = 1
    articlesTitle.Text = "📚 Artículos Publicados"
    articlesTitle.Font = Enum.Font.GothamBold
    articlesTitle.TextSize = 20
    articlesTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    articlesTitle.TextXAlignment = Enum.TextXAlignment.Left
    articlesTitle.LayoutOrder = 3
    articlesTitle.Parent = profileFrame
    
    -- Mostrar artículos del usuario
    if #articles == 0 then
        local noArticlesLabel = Instance.new("TextLabel")
        noArticlesLabel.Size = UDim2.new(1, 0, 0, 50)
        noArticlesLabel.BackgroundTransparency = 1
        noArticlesLabel.Text = "Este usuario aún no ha publicado artículos"
        noArticlesLabel.Font = Enum.Font.Gotham
        noArticlesLabel.TextSize = 16
        noArticlesLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        noArticlesLabel.LayoutOrder = 4
        noArticlesLabel.Parent = profileFrame
    else
        for i, article in ipairs(articles) do
            local articleCard = Instance.new("Frame")
            articleCard.Size = UDim2.new(1, 0, 0, 120)
            articleCard.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
            articleCard.BorderSizePixel = 0
            articleCard.LayoutOrder = 3 + i
            articleCard.Parent = profileFrame
            
            local articleCardCorner = Instance.new("UICorner")
            articleCardCorner.CornerRadius = UDim.new(0, 10)
            articleCardCorner.Parent = articleCard
            
            local articleCardLayout = Instance.new("UIListLayout")
            articleCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
            articleCardLayout.Padding = UDim.new(0, 8)
            articleCardLayout.Parent = articleCard
            
            local articleCardPadding = Instance.new("UIPadding")
            articleCardPadding.PaddingLeft = UDim.new(0, 15)
            articleCardPadding.PaddingRight = UDim.new(0, 15)
            articleCardPadding.PaddingTop = UDim.new(0, 15)
            articleCardPadding.PaddingBottom = UDim.new(0, 15)
            articleCardPadding.Parent = articleCard
            
            local articleTitleLabel = Instance.new("TextButton")
            articleTitleLabel.Size = UDim2.new(1, 0, 0, 30)
            articleTitleLabel.BackgroundTransparency = 1
            articleTitleLabel.Text = article.title
            articleTitleLabel.Font = Enum.Font.GothamBold
            articleTitleLabel.TextSize = 18
            articleTitleLabel.TextColor3 = Color3.fromRGB(26, 115, 232)
            articleTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            articleTitleLabel.TextWrapped = true
            articleTitleLabel.LayoutOrder = 1
            articleTitleLabel.Parent = articleCard
            
            articleTitleLabel.MouseButton1Click:Connect(function()
                showArticle(article.id)
            end)
            
            local articleDesc = Instance.new("TextLabel")
            articleDesc.Size = UDim2.new(1, 0, 0, 40)
            articleDesc.BackgroundTransparency = 1
            articleDesc.Text = string.sub(article.description, 1, 100) .. (string.len(article.description) > 100 and "..." or "")
            articleDesc.Font = Enum.Font.Gotham
            articleDesc.TextSize = 14
            articleDesc.TextColor3 = Color3.fromRGB(100, 100, 100)
            articleDesc.TextXAlignment = Enum.TextXAlignment.Left
            articleDesc.TextYAlignment = Enum.TextYAlignment.Top
            articleDesc.TextWrapped = true
            articleDesc.LayoutOrder = 2
            articleDesc.Parent = articleCard
            
            local articleDate = Instance.new("TextLabel")
            articleDate.Size = UDim2.new(1, 0, 0, 18)
            articleDate.BackgroundTransparency = 1
            articleDate.Text = article.dateCreated
            articleDate.Font = Enum.Font.Gotham
            articleDate.TextSize = 12
            articleDate.TextColor3 = Color3.fromRGB(150, 150, 150)
            articleDate.TextXAlignment = Enum.TextXAlignment.Left
            articleDate.LayoutOrder = 3
            articleDate.Parent = articleCard
        end
    end
    
    -- Actualizar CanvasSize
    task.wait(0.1)
    profileFrame.CanvasSize = UDim2.new(0, 0, 0, profileLayout.AbsoluteContentSize.Y + 60)
    
    setInterfaceView("profile")
end

local function showArticle(articleId)
    local article = getArticleByIdEvent:InvokeServer(articleId)
    
    if not article then
        warn("Artículo no encontrado")
        return
    end
    
    for _, child in ipairs(articleViewFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Name ~= "BackButton" then
                child:Destroy()
            end
        end
    end
    
    -- Título del artículo
    local articleTitle = Instance.new("TextLabel")
    articleTitle.Size = UDim2.new(1, 0, 0, 0)
    articleTitle.AutomaticSize = Enum.AutomaticSize.Y
    articleTitle.BackgroundTransparency = 1
    articleTitle.Text = article.title
    articleTitle.Font = Enum.Font.GothamBold
    articleTitle.TextSize = 36
    articleTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    articleTitle.TextXAlignment = Enum.TextXAlignment.Left
    articleTitle.TextWrapped = true
    articleTitle.LayoutOrder = 2
    articleTitle.Parent = articleViewFrame
    
    -- Información del autor (clickeable)
    local authorContainer = Instance.new("TextButton")
    authorContainer.Size = UDim2.new(1, 0, 0, 60)
    authorContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    authorContainer.BorderSizePixel = 0
    authorContainer.LayoutOrder = 3
    authorContainer.AutoButtonColor = false
    authorContainer.Text = ""
    authorContainer.Parent = articleViewFrame
    
    local authorCorner = Instance.new("UICorner")
    authorCorner.CornerRadius = UDim.new(0, 10)
    authorCorner.Parent = authorContainer
    
    authorContainer.MouseButton1Click:Connect(function()
        showUserProfile(article.authorId)
    end)
    
    -- Foto del autor
    local authorImage = Instance.new("ImageLabel")
    authorImage.Size = UDim2.new(0, 45, 0, 45)
    authorImage.Position = UDim2.new(0, 10, 0.5, -22.5)
    authorImage.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    authorImage.Image = article.authorThumbnail
    authorImage.Parent = authorContainer
    
    local authorImageCorner = Instance.new("UICorner")
    authorImageCorner.CornerRadius = UDim.new(1, 0)
    authorImageCorner.Parent = authorImage
    
    -- Información del autor y fecha
    local authorInfoContainer = Instance.new("Frame")
    authorInfoContainer.Size = UDim2.new(1, -70, 1, 0)
    authorInfoContainer.Position = UDim2.new(0, 65, 0, 0)
    authorInfoContainer.BackgroundTransparency = 1
    authorInfoContainer.Parent = authorContainer
    
    local authorInfoLayout = Instance.new("UIListLayout")
    authorInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    authorInfoLayout.Padding = UDim.new(0, 4)
    authorInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    authorInfoLayout.Parent = authorInfoContainer
    
    -- Nombre del autor con insignia (INSIGNIA AL LADO DEL NOMBRE)
    local authorNameContainer = Instance.new("Frame")
    authorNameContainer.Size = UDim2.new(1, 0, 0, 20)
    authorNameContainer.BackgroundTransparency = 1
    authorNameContainer.LayoutOrder = 1
    authorNameContainer.Parent = authorInfoContainer
    
    local authorNameLayout = Instance.new("UIListLayout")
    authorNameLayout.FillDirection = Enum.FillDirection.Horizontal
    authorNameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    authorNameLayout.Padding = UDim.new(0, 5)
    authorNameLayout.Parent = authorNameContainer
    
    local authorName = Instance.new("TextLabel")
    authorName.Size = UDim2.new(0, 0, 0, 20)
    authorName.AutomaticSize = Enum.AutomaticSize.X
    authorName.BackgroundTransparency = 1
    authorName.Text = "Por " .. article.author
    authorName.Font = Enum.Font.GothamBold
    authorName.TextSize = 16
    authorName.TextColor3 = Color3.fromRGB(50, 50, 50)
    authorName.TextXAlignment = Enum.TextXAlignment.Left
    authorName.Parent = authorNameContainer
    
    -- INSIGNIA AL LADO DEL NOMBRE (NO DE LA FECHA)
    if article.verified then
        local verifiedBadge = createVerifiedBadge()
        verifiedBadge.Parent = authorNameContainer
    end
    
    -- FECHA SIN INSIGNIA
    local articleDate = Instance.new("TextLabel")
    articleDate.Size = UDim2.new(1, 0, 0, 16)
    articleDate.BackgroundTransparency = 1
    articleDate.Text = article.dateCreated
    articleDate.Font = Enum.Font.Gotham
    articleDate.TextSize = 14
    articleDate.TextColor3 = Color3.fromRGB(120, 120, 120)
    articleDate.TextXAlignment = Enum.TextXAlignment.Left
    articleDate.LayoutOrder = 2
    articleDate.Parent = authorInfoContainer
    
    -- Línea separadora
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    separator.BorderSizePixel = 0
    separator.LayoutOrder = 4
    separator.Parent = articleViewFrame
    
    -- Contenido del artículo (SIN LÍMITE DE TAMAÑO)
    local articleContent = Instance.new("TextLabel")
    articleContent.Size = UDim2.new(1, 0, 0, 0)
    articleContent.AutomaticSize = Enum.AutomaticSize.Y
    articleContent.BackgroundTransparency = 1
    articleContent.Text = article.content
    articleContent.Font = Enum.Font.Gotham
    articleContent.TextSize = 18
    articleContent.TextColor3 = Color3.fromRGB(50, 50, 50)
    articleContent.TextXAlignment = Enum.TextXAlignment.Left
    articleContent.TextYAlignment = Enum.TextYAlignment.Top
    articleContent.TextWrapped = true
    articleContent.LayoutOrder = 5
    articleContent.Parent = articleViewFrame
    
    -- Actualizar CanvasSize para permitir scroll completo
    task.wait(0.1)
    articleViewFrame.CanvasSize = UDim2.new(0, 0, 0, articleLayout.AbsoluteContentSize.Y + 60)
    
    setInterfaceView("article")
end

-- Función para crear sección de artículos (horizontal)
local function createHomeSection(title, articles, parent, layoutOrder)
    if #articles == 0 then return end
    
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Size = UDim2.new(1, 0, 0, 220)
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.LayoutOrder = layoutOrder
    sectionContainer.Parent = parent
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Padding = UDim.new(0, 10)
    sectionLayout.Parent = sectionContainer
    
    -- Título de la sección
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, 0, 0, 30)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = title
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextSize = 22
    sectionTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.LayoutOrder = 1
    sectionTitle.Parent = sectionContainer
    
    -- Scroll horizontal de artículos
    local articlesScroll = Instance.new("ScrollingFrame")
    articlesScroll.Size = UDim2.new(1, 0, 0, 180)
    articlesScroll.BackgroundTransparency = 1
    articlesScroll.BorderSizePixel = 0
    articlesScroll.ScrollBarThickness = 4
    articlesScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    articlesScroll.ScrollingDirection = Enum.ScrollingDirection.X
    articlesScroll.CanvasSize = UDim2.new(0, #articles * 320, 0, 0)
    articlesScroll.LayoutOrder = 2
    articlesScroll.Parent = sectionContainer
    
    local articlesLayout = Instance.new("UIListLayout")
    articlesLayout.FillDirection = Enum.FillDirection.Horizontal
    articlesLayout.Padding = UDim.new(0, 15)
    articlesLayout.Parent = articlesScroll
    
    -- Crear tarjetas de artículos
    for i, article in ipairs(articles) do
        local articleCard = Instance.new("TextButton")
        articleCard.Size = UDim2.new(0, 300, 1, -10)
        articleCard.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        articleCard.BorderSizePixel = 0
        articleCard.AutoButtonColor = false
        articleCard.Text = ""
        articleCard.LayoutOrder = i
        articleCard.Parent = articlesScroll
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 10)
        cardCorner.Parent = articleCard
        
        local cardLayout = Instance.new("UIListLayout")
        cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cardLayout.Padding = UDim.new(0, 8)
        cardLayout.Parent = articleCard
        
        local cardPadding = Instance.new("UIPadding")
        cardPadding.PaddingLeft = UDim.new(0, 15)
        cardPadding.PaddingRight = UDim.new(0, 15)
        cardPadding.PaddingTop = UDim.new(0, 15)
        cardPadding.PaddingBottom = UDim.new(0, 15)
        cardPadding.Parent = articleCard
        
        -- Título
        local cardTitle = Instance.new("TextLabel")
        cardTitle.Size = UDim2.new(1, 0, 0, 50)
        cardTitle.BackgroundTransparency = 1
        cardTitle.Text = article.title
        cardTitle.Font = Enum.Font.GothamBold
        cardTitle.TextSize = 18
        cardTitle.TextColor3 = Color3.fromRGB(26, 115, 232)
        cardTitle.TextXAlignment = Enum.TextXAlignment.Left
        cardTitle.TextYAlignment = Enum.TextYAlignment.Top
        cardTitle.TextWrapped = true
        cardTitle.LayoutOrder = 1
        cardTitle.Parent = articleCard
        
        -- Descripción
        local cardDesc = Instance.new("TextLabel")
        cardDesc.Size = UDim2.new(1, 0, 0, 60)
        cardDesc.BackgroundTransparency = 1
        cardDesc.Text = string.sub(article.description, 1, 100) .. "..."
        cardDesc.Font = Enum.Font.Gotham
        cardDesc.TextSize = 14
        cardDesc.TextColor3 = Color3.fromRGB(100, 100, 100)
        cardDesc.TextXAlignment = Enum.TextXAlignment.Left
        cardDesc.TextYAlignment = Enum.TextYAlignment.Top
        cardDesc.TextWrapped = true
        cardDesc.LayoutOrder = 2
        cardDesc.Parent = articleCard
        
        -- Autor con insignia
        local authorContainer = Instance.new("Frame")
        authorContainer.Size = UDim2.new(1, 0, 0, 20)
        authorContainer.BackgroundTransparency = 1
        authorContainer.LayoutOrder = 3
        authorContainer.Parent = articleCard
        
        local authorLayout = Instance.new("UIListLayout")
        authorLayout.FillDirection = Enum.FillDirection.Horizontal
        authorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        authorLayout.Padding = UDim.new(0, 5)
        authorLayout.Parent = authorContainer
        
        local authorText = Instance.new("TextLabel")
        authorText.Size = UDim2.new(0, 0, 0, 18)
        authorText.AutomaticSize = Enum.AutomaticSize.X
        authorText.BackgroundTransparency = 1
        authorText.Text = article.author
        authorText.Font = Enum.Font.Gotham
        authorText.TextSize = 13
        authorText.TextColor3 = Color3.fromRGB(0, 102, 204)
        authorText.Parent = authorContainer
        
        if article.verified then
            local badge = createVerifiedBadge()
            badge.Size = UDim2.new(0, 14, 0, 14)
            badge.Parent = authorContainer
        end
        
        articleCard.MouseButton1Click:Connect(function()
            showArticle(article.id)
        end)
    end
end

local function createArticleCard(article, parent, index)
    local resultCard = Instance.new("Frame")
    resultCard.Size = UDim2.new(1, 0, 0, 130)
    resultCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultCard.BorderSizePixel = 0
    resultCard.LayoutOrder = index
    resultCard.Parent = parent
    
    local cardLayout = Instance.new("UIListLayout")
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding = UDim.new(0, 8)
    cardLayout.Parent = resultCard
    
    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingLeft = UDim.new(0, 15)
    cardPadding.PaddingRight = UDim.new(0, 15)
    cardPadding.PaddingTop = UDim.new(0, 15)
    cardPadding.PaddingBottom = UDim.new(0, 15)
    cardPadding.Parent = resultCard
    
    -- Título clickeable
    local resultTitle = Instance.new("TextButton")
    resultTitle.Size = UDim2.new(1, 0, 0, 28)
    resultTitle.BackgroundTransparency = 1
    resultTitle.Text = article.title
    resultTitle.Font = Enum.Font.GothamBold
    resultTitle.TextSize = 20
    resultTitle.TextColor3 = Color3.fromRGB(26, 115, 232)
    resultTitle.TextXAlignment = Enum.TextXAlignment.Left
    resultTitle.TextWrapped = true
    resultTitle.LayoutOrder = 1
    resultTitle.Parent = resultCard
    
    resultTitle.MouseButton1Click:Connect(function()
        showArticle(article.id)
    end)
    
    -- Descripción
    local resultDesc = Instance.new("TextLabel")
    resultDesc.Size = UDim2.new(1, 0, 0, 40)
    resultDesc.BackgroundTransparency = 1
    resultDesc.Text = string.sub(article.description, 1, 150) .. (string.len(article.description) > 150 and "..." or "")
    resultDesc.Font = Enum.Font.Gotham
    resultDesc.TextSize = 15
    resultDesc.TextColor3 = Color3.fromRGB(70, 70, 70)
    resultDesc.TextXAlignment = Enum.TextXAlignment.Left
    resultDesc.TextYAlignment = Enum.TextYAlignment.Top
    resultDesc.TextWrapped = true
    resultDesc.LayoutOrder = 2
    resultDesc.Parent = resultCard
    
    -- Autor (clickeable) con verificación AL LADO DEL NOMBRE - VERSIÓN CORRECTA
    local authorContainer = Instance.new("Frame")
    authorContainer.Size = UDim2.new(1, 0, 0, 20)
    authorContainer.BackgroundTransparency = 1
    authorContainer.LayoutOrder = 3
    authorContainer.Parent = resultCard
    
    local authorLayout = Instance.new("UIListLayout")
    authorLayout.FillDirection = Enum.FillDirection.Horizontal
    authorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    authorLayout.Padding = UDim.new(0, 5)
    authorLayout.Parent = authorContainer
    
    local authorButton = Instance.new("TextButton")
    authorButton.Size = UDim2.new(0, 0, 0, 18)
    authorButton.AutomaticSize = Enum.AutomaticSize.X
    authorButton.BackgroundTransparency = 1
    authorButton.Text = article.author
    authorButton.Font = Enum.Font.Gotham
    authorButton.TextSize = 14
    authorButton.TextColor3 = Color3.fromRGB(0, 102, 204)
    authorButton.Parent = authorContainer
    
    -- INSIGNIA AL LADO DEL NOMBRE
    if article.verified then
        local verifiedBadge = createVerifiedBadge()
        verifiedBadge.Size = UDim2.new(0, 16, 0, 16)
        verifiedBadge.Parent = authorContainer
    end
    
    -- FECHA SEPARADA (SIN INSIGNIA)
    local dateText = Instance.new("TextLabel")
    dateText.Size = UDim2.new(0, 0, 0, 18)
    dateText.AutomaticSize = Enum.AutomaticSize.X
    dateText.BackgroundTransparency = 1
    dateText.Text = " • " .. article.dateCreated
    dateText.Font = Enum.Font.Gotham
    authorText.TextSize = 14
    dateText.TextColor3 = Color3.fromRGB(120, 120, 120)
    dateText.Parent = authorContainer
    
    authorButton.MouseButton1Click:Connect(function()
        showUserProfile(article.authorId)
    end)
    
    -- Línea separadora
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    divider.BorderSizePixel = 0
    divider.LayoutOrder = 4
    divider.Parent = resultCard
end

local function loadArticles(query)
    for _, child in ipairs(resultsScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local success, articles = pcall(function()
        return getArticlesEvent:InvokeServer(query)
    end)
    
    if not success or not articles then
        warn("Error al cargar artículos")
        return
    end
    
    if #articles == 0 then
        local noResults = Instance.new("TextLabel")
        noResults.Size = UDim2.new(1, 0, 0, 100)
        noResults.BackgroundTransparency = 1
        noResults.Text = query == "" and "No hay artículos disponibles" or "No se encontraron resultados para " .. query
        noResults.Font = Enum.Font.Gotham
        noResults.TextSize = 18
        noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
        noResults.Parent = resultsScrollFrame
    else
        for i, article in ipairs(articles) do
            createArticleCard(article, resultsScrollFrame, i)
        end
    end
    
    task.wait(0.1)
    resultsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, resultsLayout.AbsoluteContentSize.Y + 60)
end

-- Función para cargar secciones en página de inicio
local function loadHomeSections()
    -- Limpiar secciones anteriores
    for _, child in ipairs(homeSectionsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local success, articles = pcall(function()
        return getArticlesEvent:InvokeServer("")
    end)
    
    if not success or not articles then
        return
    end
    
    -- Filtrar artículos del sistema
    local systemArticles = {}
    local userArticles = {}
    
    for _, article in ipairs(articles) do
        if article.author == "Sistema" then
            table.insert(systemArticles, article)
        else
            table.insert(userArticles, article)
        end
    end
    
    -- Sección 1: Artículos Destacados (del sistema)
    if #systemArticles > 0 then
        createHomeSection("⭐ Artículos Destacados", systemArticles, homeSectionsContainer, 1)
    end
    
    -- Sección 2: Artículos Nuevos (últimos 5)
    local newArticles = {}
    for i = 1, math.min(5, #userArticles) do
        table.insert(newArticles, userArticles[i])
    end
    if #newArticles > 0 then
        createHomeSection("🆕 Artículos Nuevos", newArticles, homeSectionsContainer, 2)
    end
    
    -- Sección 3: Artículos Recientes
    if #userArticles > 5 then
        local recentArticles = {}
        for i = 6, math.min(15, #userArticles) do
            table.insert(recentArticles, userArticles[i])
        end
        if #recentArticles > 0 then
            createHomeSection("📚 Artículos Recientes", recentArticles, homeSectionsContainer, 3)
        end
    end
    
    task.wait(0.1)
    homeSectionsContainer.CanvasSize = UDim2.new(0, 0, 0, homeSectionsLayout.AbsoluteContentSize.Y + 30)
end

local function runSearch(textBox)
    local query = textBox.Text
    loadArticles(query)
    setInterfaceView("results")
    searchBoxHeader.Text = query
end

local function loadAllArticles()
    if not isAdmin or not allArticlesContainer then
        return
    end
    
    -- Limpiar artículos anteriores
    for _, child in ipairs(allArticlesContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local success, allArticles = pcall(function()
        return getAllArticlesEvent:InvokeServer()
    end)
    
    if not success or not allArticles then
        warn("Error al cargar todos los artículos")
        return
    end
    
    if #allArticles == 0 then
        local noArticles = Instance.new("TextLabel")
        noArticles.Size = UDim2.new(1, 0, 0, 50)
        noArticles.BackgroundTransparency = 1
        noArticles.Text = "No hay artículos en el sistema"
        noArticles.Font = Enum.Font.Gotham
        noArticles.TextSize = 16
        noArticles.TextColor3 = Color3.fromRGB(150, 150, 150)
        noArticles.ZIndex = 12
        noArticles.Parent = allArticlesContainer
    else
        -- Ordenar por estado: pending > active > inactive
        local sortedArticles = {}
        for _, article in ipairs(allArticles) do
            table.insert(sortedArticles, article)
        end
        table.sort(sortedArticles, function(a, b)
            local order = {pending = 1, active = 2, inactive = 3}
            return (order[a.status] or 4) < (order[b.status] or 4)
        end)
        
        for i, article in ipairs(sortedArticles) do
            local articleCard = Instance.new("Frame")
            articleCard.Size = UDim2.new(1, 0, 0, 180)
            articleCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            articleCard.BorderSizePixel = 0
            articleCard.LayoutOrder = i
            articleCard.ZIndex = 12
            articleCard.Parent = allArticlesContainer
            
            local articleCardCorner = Instance.new("UICorner")
            articleCardCorner.CornerRadius = UDim.new(0, 8)
            articleCardCorner.Parent = articleCard
            
            local articleCardStroke = Instance.new("UIStroke")
            articleCardStroke.Color = Color3.fromRGB(220, 220, 220)
            articleCardStroke.Thickness = 1
            articleCardStroke.Parent = articleCard
            
            local articleCardLayout = Instance.new("UIListLayout")
            articleCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
            articleCardLayout.Padding = UDim.new(0, 8)
            articleCardLayout.Parent = articleCard
            
            local articleCardPadding = Instance.new("UIPadding")
            articleCardPadding.PaddingLeft = UDim.new(0, 15)
            articleCardPadding.PaddingRight = UDim.new(0, 15)
            articleCardPadding.PaddingTop = UDim.new(0, 12)
            articleCardPadding.PaddingBottom = UDim.new(0, 12)
            articleCardPadding.Parent = articleCard
            
            -- Estado del artículo
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(1, 0, 0, 20)
            statusLabel.BackgroundTransparency = 1
            local statusText = {pending = "⏳ PENDIENTE", active = "✅ ACTIVO", inactive = "❌ INACTIVO"}
            local statusColor = {pending = Color3.fromRGB(255, 152, 0), active = Color3.fromRGB(76, 175, 80), inactive = Color3.fromRGB(244, 67, 54)}
            statusLabel.Text = statusText[article.status] or "DESCONOCIDO"
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextSize = 14
            statusLabel.TextColor3 = statusColor[article.status] or Color3.fromRGB(100, 100, 100)
            statusLabel.TextXAlignment = Enum.TextXAlignment.Left
            statusLabel.LayoutOrder = 1
            statusLabel.ZIndex = 13
            statusLabel.Parent = articleCard
            
            local articleTitle = Instance.new("TextLabel")
            articleTitle.Size = UDim2.new(1, 0, 0, 25)
            articleTitle.BackgroundTransparency = 1
            articleTitle.Text = article.title
            articleTitle.Font = Enum.Font.GothamBold
            articleTitle.TextSize = 18
            articleTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
            articleTitle.TextXAlignment = Enum.TextXAlignment.Left
            articleTitle.TextWrapped = true
            articleTitle.LayoutOrder = 2
            articleTitle.ZIndex = 13
            articleTitle.Parent = articleCard
            
            local articleDesc = Instance.new("TextLabel")
            articleDesc.Size = UDim2.new(1, 0, 0, 40)
            articleDesc.BackgroundTransparency = 1
            articleDesc.Text = string.sub(article.description, 1, 100) .. (string.len(article.description) > 100 and "..." or "")
            articleDesc.Font = Enum.Font.Gotham
            articleDesc.TextSize = 14
            articleDesc.TextColor3 = Color3.fromRGB(100, 100, 100)
            articleDesc.TextXAlignment = Enum.TextXAlignment.Left
            articleDesc.TextYAlignment = Enum.TextYAlignment.Top
            articleDesc.TextWrapped = true
            articleDesc.LayoutOrder = 3
            articleDesc.ZIndex = 13
            articleDesc.Parent = articleCard
            
            local articleAuthor = Instance.new("TextLabel")
            articleAuthor.Size = UDim2.new(1, 0, 0, 18)
            articleAuthor.BackgroundTransparency = 1
            articleAuthor.Text = "Por " .. article.author .. " • " .. article.dateCreated
            articleAuthor.Font = Enum.Font.Gotham
            articleAuthor.TextSize = 13
            articleAuthor.TextColor3 = Color3.fromRGB(120, 120, 120)
            articleAuthor.TextXAlignment = Enum.TextXAlignment.Left
            articleAuthor.LayoutOrder = 4
            articleAuthor.ZIndex = 13
            articleAuthor.Parent = articleCard
            
            local buttonsContainer = Instance.new("Frame")
            buttonsContainer.Size = UDim2.new(1, 0, 0, 40)
            buttonsContainer.BackgroundTransparency = 1
            buttonsContainer.LayoutOrder = 5
            buttonsContainer.ZIndex = 13
            buttonsContainer.Parent = articleCard
            
            local buttonsLayout = Instance.new("UIListLayout")
            buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
            buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            buttonsLayout.Padding = UDim.new(0, 15)
            buttonsLayout.Parent = buttonsContainer
            
            -- Botones según el estado
            if article.status == "pending" then
                -- Aprobar
                local approveButton = Instance.new("TextButton")
                approveButton.Size = UDim2.new(0, 120, 0, 35)
                approveButton.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
                approveButton.Text = "✓ Aprobar"
                approveButton.Font = Enum.Font.GothamBold
                approveButton.TextSize = 15
                approveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                approveButton.BorderSizePixel = 0
                approveButton.ZIndex = 14
                approveButton.Parent = buttonsContainer
                
                local approveCorner = Instance.new("UICorner")
                approveCorner.CornerRadius = UDim.new(0, 8)
                approveCorner.Parent = approveButton
                
                -- Rechazar
                local rejectButton = Instance.new("TextButton")
                rejectButton.Size = UDim2.new(0, 120, 0, 35)
                rejectButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                rejectButton.Text = "✗ Rechazar"
                rejectButton.Font = Enum.Font.GothamBold
                rejectButton.TextSize = 15
                rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                rejectButton.BorderSizePixel = 0
                rejectButton.ZIndex = 14
                rejectButton.Parent = buttonsContainer
                
                local rejectCorner = Instance.new("UICorner")
                rejectCorner.CornerRadius = UDim.new(0, 8)
                rejectCorner.Parent = rejectButton
                
                approveButton.MouseButton1Click:Connect(function()
                    local success = toggleArticleStatusEvent:InvokeServer(article.id, "active")
                    if success then
                        loadAllArticles()
                    end
                end)
                
                rejectButton.MouseButton1Click:Connect(function()
                    local success = toggleArticleStatusEvent:InvokeServer(article.id, "inactive")
                    if success then
                        loadAllArticles()
                    end
                end)
                
            elseif article.status == "active" then
                -- Desactivar
                local deactivateButton = Instance.new("TextButton")
                deactivateButton.Size = UDim2.new(0, 140, 0, 35)
                deactivateButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                deactivateButton.Text = "Desactivar"
                deactivateButton.Font = Enum.Font.GothamBold
                deactivateButton.TextSize = 15
                deactivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                deactivateButton.BorderSizePixel = 0
                deactivateButton.ZIndex = 14
                deactivateButton.Parent = buttonsContainer
                
                local deactivateCorner = Instance.new("UICorner")
                deactivateCorner.CornerRadius = UDim.new(0, 8)
                deactivateCorner.Parent = deactivateButton
                
                deactivateButton.MouseButton1Click:Connect(function()
                    local success = toggleArticleStatusEvent:InvokeServer(article.id, "inactive")
                    if success then
                        loadAllArticles()
                    end
                end)
                
            else -- inactive
                -- Reactivar
                local reactivateButton = Instance.new("TextButton")
                reactivateButton.Size = UDim2.new(0, 140, 0, 35)
                reactivateButton.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
                reactivateButton.Text = "Reactivar"
                reactivateButton.Font = Enum.Font.GothamBold
                reactivateButton.TextSize = 15
                reactivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                reactivateButton.BorderSizePixel = 0
                reactivateButton.ZIndex = 14
                reactivateButton.Parent = buttonsContainer
                
                local reactivateCorner = Instance.new("UICorner")
                reactivateCorner.CornerRadius = UDim.new(0, 8)
                reactivateCorner.Parent = reactivateButton
                
                reactivateButton.MouseButton1Click:Connect(function()
                    local success = toggleArticleStatusEvent:InvokeServer(article.id, "active")
                    if success then
                        loadAllArticles()
                    end
                end)
            end
        end
    end
    
    task.wait(0.1)
    allArticlesContainer.CanvasSize = UDim2.new(0, 0, 0, allArticlesContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 30)
    
    task.wait(0.1)
    adminPanel.CanvasSize = UDim2.new(0, 0, 0, adminPanel:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 60)
end

-- Función para buscar y mostrar usuarios (panel admin)
local function searchAndDisplayUsers(query)
    if not isAdmin or not adminScrollContainer then
        return
    end
    
    -- Limpiar resultados anteriores
    for _, child in ipairs(adminScrollContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local success, users = pcall(function()
        return searchUsersEvent:InvokeServer(query)
    end)
    
    if not success or not users then
        warn("Error al buscar usuarios")
        return
    end
    
    if #users == 0 then
        local noUsers = Instance.new("TextLabel")
        noUsers.Size = UDim2.new(1, 0, 0, 50)
        noUsers.BackgroundTransparency = 1
        noUsers.Text = query == "" and "No hay usuarios registrados" or "No se encontraron usuarios"
        noUsers.Font = Enum.Font.Gotham
        noUsers.TextSize = 16
        noUsers.TextColor3 = Color3.fromRGB(150, 150, 150)
        noUsers.ZIndex = 12
        noUsers.Parent = adminScrollContainer
    else
        for i, user in ipairs(users) do
            local userCard = Instance.new("Frame")
            userCard.Size = UDim2.new(1, 0, 0, 80)
            userCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            userCard.BorderSizePixel = 0
            userCard.LayoutOrder = i
            userCard.ZIndex = 12
            userCard.Parent = adminScrollContainer
            
            local userCardCorner = Instance.new("UICorner")
            userCardCorner.CornerRadius = UDim.new(0, 8)
            userCardCorner.Parent = userCard
            
            local userCardStroke = Instance.new("UIStroke")
            userCardStroke.Color = Color3.fromRGB(220, 220, 220)
            userCardStroke.Thickness = 1
            userCardStroke.Parent = userCard
            
            -- Foto del usuario
            local userImage = Instance.new("ImageLabel")
            userImage.Size = UDim2.new(0, 50, 0, 50)
            userImage.Position = UDim2.new(0, 15, 0.5, -25)
            userImage.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            userImage.Image = user.thumbnail
            userImage.ZIndex = 13
            userImage.Parent = userCard
            
            local userImageCorner = Instance.new("UICorner")
            userImageCorner.CornerRadius = UDim.new(1, 0)
            userImageCorner.Parent = userImage
            
            -- Información del usuario
            local userInfoFrame = Instance.new("Frame")
            userInfoFrame.Size = UDim2.new(1, -180, 1, 0)
            userInfoFrame.Position = UDim2.new(0, 75, 0, 0)
            userInfoFrame.BackgroundTransparency = 1
            userInfoFrame.ZIndex = 13
            userInfoFrame.Parent = userCard
            
            local userInfoLayout = Instance.new("UIListLayout")
            userInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
            userInfoLayout.Padding = UDim.new(0, 5)
            userInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            userInfoLayout.Parent = userInfoFrame
            
            -- Nombre con insignia
            local usernameContainer = Instance.new("Frame")
            usernameContainer.Name = "UsernameContainer"
            usernameContainer.Size = UDim2.new(1, 0, 0, 22)
            usernameContainer.BackgroundTransparency = 1
            usernameContainer.LayoutOrder = 1
            usernameContainer.ZIndex = 13
            usernameContainer.Parent = userInfoFrame
            
            local usernameLayout = Instance.new("UIListLayout")
            usernameLayout.FillDirection = Enum.FillDirection.Horizontal
            usernameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            usernameLayout.Padding = UDim.new(0, 5)
            usernameLayout.Parent = usernameContainer
            
            local usernameLabel = Instance.new("TextLabel")
            usernameLabel.Size = UDim2.new(0, 0, 0, 22)
            usernameLabel.AutomaticSize = Enum.AutomaticSize.X
            usernameLabel.BackgroundTransparency = 1
            usernameLabel.Text = user.username
            usernameLabel.Font = Enum.Font.GothamBold
            usernameLabel.TextSize = 16
            usernameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
            usernameLabel.ZIndex = 14
            usernameLabel.Parent = usernameContainer
            
            if user.verified then
                local verifiedBadge = createVerifiedBadge()
                verifiedBadge.Size = UDim2.new(0, 18, 0, 18)
                verifiedBadge.ZIndex = 14
                verifiedBadge.Parent = usernameContainer
            end
            
            -- Estadísticas
            local userStats = Instance.new("TextLabel")
            userStats.Size = UDim2.new(1, 0, 0, 18)
            userStats.BackgroundTransparency = 1
            userStats.Text = string.format("%d artículos • %d seguidores", user.articlesPublished or 0, #(user.followers or {}))
            userStats.Font = Enum.Font.Gotham
            userStats.TextSize = 13
            userStats.TextColor3 = Color3.fromRGB(120, 120, 120)
            userStats.TextXAlignment = Enum.TextXAlignment.Left
            userStats.LayoutOrder = 2
            userStats.ZIndex = 14
            userStats.Parent = userInfoFrame
            
            -- Botón verificar/desverificar
            local verifyButton = Instance.new("TextButton")
            verifyButton.Size = UDim2.new(0, 100, 0, 35)
            verifyButton.Position = UDim2.new(1, -110, 0.5, -17.5)
            verifyButton.BackgroundColor3 = user.verified and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(29, 161, 242)
            verifyButton.Text = user.verified and "Desverificar" or "Verificar"
            verifyButton.Font = Enum.Font.GothamBold
            verifyButton.TextSize = 14
            verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            verifyButton.BorderSizePixel = 0
            verifyButton.ZIndex = 14
            verifyButton.Parent = userCard
            
            local verifyCorner = Instance.new("UICorner")
            verifyCorner.CornerRadius = UDim.new(0, 8)
            verifyCorner.Parent = verifyButton
            
            verifyButton.MouseButton1Click:Connect(function()
                local success
                if user.verified then
                    success = unverifyUserEvent:InvokeServer(user.userId)
                    if success then
                        user.verified = false
                        verifyButton.Text = "Verificar"
                        verifyButton.BackgroundColor3 = Color3.fromRGB(29, 161, 242)
                        -- Remover insignia
                        for _, child in ipairs(usernameContainer:GetChildren()) do
                            if child.Name == "VerifiedBadge" then
                                child:Destroy()
                            end
                        end
                    end
                else
                    success = verifyUserEvent:InvokeServer(user.userId)
                    if success then
                        user.verified = true
                        verifyButton.Text = "Desverificar"
                        verifyButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                        -- Agregar insignia
                        local verifiedBadge = createVerifiedBadge()
                        verifiedBadge.Size = UDim2.new(0, 18, 0, 18)
                        verifiedBadge.ZIndex = 14
                        verifiedBadge.Parent = usernameContainer
                    end
                end
            end)
        end
    end
    
    task.wait(0.1)
    adminScrollContainer.CanvasSize = UDim2.new(0, 0, 0, adminScrollContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 30)
end

-- ========== EVENTOS ==========

searchButton.MouseButton1Click:Connect(function()
    runSearch(searchBox)
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        runSearch(searchBox)
    end
end)

-- Búsqueda en header
searchButtonHeader.MouseButton1Click:Connect(function()
    runSearch(searchBoxHeader)
end)

searchBoxHeader.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        runSearch(searchBoxHeader)
    end
end)

-- Volver al inicio desde resultados
homeButton.MouseButton1Click:Connect(function()
    setInterfaceView("home")
    searchBox.Text = ""
end)

backButton.MouseButton1Click:Connect(function()
    setInterfaceView(previousView)
end)

profileBackButton.MouseButton1Click:Connect(function()
    setInterfaceView(previousView)
end)

-- Panel de creador
creatorButton.MouseButton1Click:Connect(function()
    setInterfaceView("creator")
    titleInput.Text = ""
    contentInput.Text = ""
end)

creatorCloseButton.MouseButton1Click:Connect(function()
    setInterfaceView("home")
end)

submitButton.MouseButton1Click:Connect(function()
    local title = titleInput.Text
    local content = contentInput.Text
    
    if title ~= "" and content ~= "" then
        loadingPanel.Visible = true
        loadingLabel.Text = "Enviando a revisión..."
        creatorPanel.Visible = false
        
        local success, result = pcall(function()
            return publishArticleFunction:InvokeServer(title, content)
        end)
        
        loadingPanel.Visible = false
        
        if success and result == true then
            print("✓ Artículo enviado a revisión")
            setInterfaceView("home")
        else
            warn("✗ Error al enviar:", result)
        end
    else
        warn("⚠ Por favor completa todos los campos")
    end
end)

-- Panel de administrador (solo para admins)
if isAdmin and adminPanelButton and adminPanel then
    adminPanelButton.MouseButton1Click:Connect(function()
        setInterfaceView("admin")
        loadAllArticles()
        searchAndDisplayUsers("")
    end)
    
    local adminCloseButton = adminPanel:FindFirstChild("Frame"):FindFirstChild("TextButton")
    if adminCloseButton then
        adminCloseButton.MouseButton1Click:Connect(function()
            setInterfaceView("home")
        end)
    end
    
    -- Botón actualizar
    local refreshButton = nil
    for _, child in ipairs(adminPanel:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("Actualizar") then
            refreshButton = child
            break
        end
    end
    
    if refreshButton then
        refreshButton.MouseButton1Click:Connect(function()
            loadAllArticles()
            searchAndDisplayUsers(adminSearchBox.Text)
        end)
    end
    
    -- Búsqueda de usuarios en tiempo real
    if adminSearchBox then
        adminSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            searchAndDisplayUsers(adminSearchBox.Text)
        end)
    end
end

loadArticles("")
loadHomeSections()

print("✓ Roogle cargado exitosamente")
print("✓ Interfaz lista para usar")
print("✓ Persistencia de datos activada")
print("✓ Sistema de perfiles implementado")
print("✓ Insignias de verificación con palomita activadas")
print("✓ Sistema de estados (pending/active/inactive)")
if isAdmin then
    print("✓ Modo administrador activado")
    print("✓ Panel admin con gestión completa de artículos")
    print("✓ Panel admin con búsqueda de usuarios en tiempo real")
end

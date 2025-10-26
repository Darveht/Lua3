-- Roogle_Core.LocalScript (1 de 3)
-- Este script define TODAS las variables y crea TODA la interfaz de usuario.

-- Crear el espacio de nombres global para compartir variables
_G.RoogleClient = {}
local R = _G.RoogleClient

-- ========== SERVICIOS Y REMOTES ==========
R.Players = game:GetService("Players")
R.player = R.Players.LocalPlayer
R.playerGui = R.player:WaitForChild("PlayerGui")
R.ReplicatedStorage = game:GetService("ReplicatedStorage")
R.StarterGui = game:GetService("StarterGui")

-- OCULTAR MUNDO 3D Y UI DE ROBLOX
R.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
R.player.CameraMode = Enum.CameraMode.LockFirstPerson
R.player.CameraMaxZoomDistance = 0.5
R.player.CameraMinZoomDistance = 0.5

-- Ocultar el jugador
local function hideCharacter(character)
        for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                        part.Transparency = 1
                end
        end
end

if R.player.Character then
        hideCharacter(R.player.Character)
end

R.player.CharacterAdded:Connect(hideCharacter)

-- ESPERAR REMOTES (con timeout de seguridad)
R.remoteFolder = R.ReplicatedStorage:WaitForChild("RoogleRemotes", 10)

if not R.remoteFolder then
        warn("❌ ERROR: No se encontró la carpeta RoogleRemotes. Asegúrate de que Server.lua esté en ServerScriptService.")
        return
end

R.getArticlesEvent = R.remoteFolder:WaitForChild("GetArticles", 5)
R.publishArticleFunction = R.remoteFolder:WaitForChild("PublishArticle", 5)
R.checkAdminEvent = R.remoteFolder:WaitForChild("CheckAdmin", 5)
R.getArticleByIdEvent = R.remoteFolder:WaitForChild("GetArticleById", 5)
R.getPendingArticlesEvent = R.remoteFolder:WaitForChild("GetPendingArticles", 5)
R.getAllArticlesEvent = R.remoteFolder:WaitForChild("GetAllArticles", 5)
R.toggleArticleStatusEvent = R.remoteFolder:WaitForChild("ToggleArticleStatus", 5)
R.getUserProfileEvent = R.remoteFolder:WaitForChild("GetUserProfile", 5)
R.followUserEvent = R.remoteFolder:WaitForChild("FollowUser", 5)
R.unfollowUserEvent = R.remoteFolder:WaitForChild("UnfollowUser", 5)
R.searchUsersEvent = R.remoteFolder:WaitForChild("SearchUsers", 5)
R.verifyUserEvent = R.remoteFolder:WaitForChild("VerifyUser", 5)
R.unverifyUserEvent = R.remoteFolder:WaitForChild("UnverifyUser", 5)
R.getRobloxStatsEvent = R.remoteFolder:WaitForChild("GetRobloxStats", 5)
R.checkBanStatusEvent = R.remoteFolder:WaitForChild("CheckBanStatus", 5)
R.banUserEvent = R.remoteFolder:WaitForChild("BanUser", 5)
R.unbanUserEvent = R.remoteFolder:WaitForChild("UnbanUser", 5)
R.processUnbanPaymentEvent = R.remoteFolder:WaitForChild("ProcessUnbanPayment", 5)
R.publishMusicFunction = R.remoteFolder:WaitForChild("PublishMusic", 5)
R.getPendingMusicEvent = R.remoteFolder:WaitForChild("GetPendingMusic", 5)
R.toggleMusicStatusEvent = R.remoteFolder:WaitForChild("ToggleMusicStatus", 5)

if not (R.getArticlesEvent and R.publishArticleFunction and R.checkAdminEvent and R.getArticleByIdEvent) then
        warn("❌ ERROR: No se pudieron cargar todos los RemoteEvents")
        return
end

-- Función para formatear números grandes (millones, miles)
R.formatLargeNumber = function(num)
        if num >= 1000000 then
                return string.format("%.1fM", num / 1000000)
        elseif num >= 1000 then
                return string.format("%.1fK", num / 1000)
        else
                return tostring(num)
        end
end

-- Verificar si es admin
R.isAdmin = R.checkAdminEvent:InvokeServer()

-- ========== CREAR GUI (Base) ==========
R.screenGui = Instance.new("ScreenGui")
R.screenGui.Name = "RoogleGui"
R.screenGui.ResetOnSpawn = false
R.screenGui.IgnoreGuiInset = true
R.screenGui.Parent = R.playerGui

-- Contenedor principal
R.mainFrame = Instance.new("Frame")
R.mainFrame.Size = UDim2.new(1, 0, 1, 0)
R.mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.mainFrame.BorderSizePixel = 0
R.mainFrame.Parent = R.screenGui

-- ========== VISTA DE INICIO ==========
R.centerContainer = Instance.new("Frame")
R.centerContainer.Size = UDim2.new(0.6, 0, 0, 150)
R.centerContainer.Position = UDim2.new(0.5, 0, 0.22, 0)
R.centerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
R.centerContainer.BackgroundTransparency = 1
R.centerContainer.Parent = R.mainFrame

local centerLayout = Instance.new("UIListLayout")
centerLayout.SortOrder = Enum.SortOrder.LayoutOrder
centerLayout.Padding = UDim.new(0, 20)
centerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
centerLayout.Parent = R.centerContainer

-- Logo
R.logo = Instance.new("TextLabel")
R.logo.Name = "RoogleLogo"
R.logo.Size = UDim2.new(1, 0, 0, 60)
R.logo.BackgroundTransparency = 1
R.logo.Text = "Roogle"
R.logo.Font = Enum.Font.GothamBold
R.logo.TextSize = 52
R.logo.TextColor3 = Color3.fromRGB(66, 133, 244)
R.logo.LayoutOrder = 1
R.logo.Parent = R.centerContainer

-- Barra de búsqueda principal
local searchContainer = Instance.new("Frame")
searchContainer.Name = "SearchContainer"
searchContainer.Size = UDim2.new(1, 0, 0, 50)
searchContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchContainer.BorderSizePixel = 0
searchContainer.LayoutOrder = 2
searchContainer.Parent = R.centerContainer

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

R.searchBox = Instance.new("TextBox")
R.searchBox.Name = "SearchBox"
R.searchBox.Size = UDim2.new(1, -80, 1, 0)
R.searchBox.BackgroundTransparency = 1
R.searchBox.Text = ""
R.searchBox.PlaceholderText = "Buscar en Roogle..."
R.searchBox.Font = Enum.Font.Gotham
R.searchBox.TextSize = 18
R.searchBox.TextColor3 = Color3.fromRGB(0, 0, 0)
R.searchBox.TextXAlignment = Enum.TextXAlignment.Left
R.searchBox.ClearTextOnFocus = false
R.searchBox.Parent = searchContainer

R.searchButton = Instance.new("TextButton")
R.searchButton.Size = UDim2.new(0, 40, 1, 0)
R.searchButton.BackgroundTransparency = 1
R.searchButton.Text = "→"
R.searchButton.Font = Enum.Font.GothamBold
R.searchButton.TextSize = 24
R.searchButton.TextColor3 = Color3.fromRGB(66, 133, 244)
R.searchButton.Parent = searchContainer

-- ========== SECCIONES DE ARTÍCULOS EN INICIO ==========
R.homeSectionsContainer = Instance.new("ScrollingFrame")
R.homeSectionsContainer.Name = "HomeSectionsContainer"
R.homeSectionsContainer.Size = UDim2.new(0.9, 0, 0.55, 0)
R.homeSectionsContainer.Position = UDim2.new(0.5, 0, 0.43, 0)
R.homeSectionsContainer.AnchorPoint = Vector2.new(0.5, 0)
R.homeSectionsContainer.BackgroundTransparency = 1
R.homeSectionsContainer.BorderSizePixel = 0
R.homeSectionsContainer.ScrollBarThickness = 6
R.homeSectionsContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.homeSectionsContainer.Parent = R.mainFrame

R.homeSectionsLayout = Instance.new("UIListLayout")
R.homeSectionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
R.homeSectionsLayout.Padding = UDim.new(0, 30)
R.homeSectionsLayout.Parent = R.homeSectionsContainer

-- ========== VISTA DE RESULTADOS ==========
R.resultsFrame = Instance.new("Frame")
R.resultsFrame.Name = "ResultsFrame"
R.resultsFrame.Size = UDim2.new(1, 0, 1, 0)
R.resultsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.resultsFrame.BorderSizePixel = 0
R.resultsFrame.Visible = false
R.resultsFrame.Parent = R.mainFrame

-- Header de resultados
R.resultsHeader = Instance.new("Frame")
R.resultsHeader.Size = UDim2.new(1, 0, 0, 65)
R.resultsHeader.Position = UDim2.new(0, 0, 0, 0)
R.resultsHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.resultsHeader.BorderSizePixel = 0
R.resultsHeader.ZIndex = 2
R.resultsHeader.Parent = R.resultsFrame

-- Botón volver al inicio (en resultados)
R.homeButton = Instance.new("TextButton")
R.homeButton.Size = UDim2.new(0, 35, 0, 35)
R.homeButton.Position = UDim2.new(0, 12, 0.5, -17.5)
R.homeButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
R.homeButton.Text = "🏠"
R.homeButton.Font = Enum.Font.GothamBold
R.homeButton.TextSize = 18
R.homeButton.BorderSizePixel = 0
R.homeButton.ZIndex = 3
R.homeButton.Parent = R.resultsHeader

local homeCorner = Instance.new("UICorner")
homeCorner.CornerRadius = UDim.new(0, 17.5)
homeCorner.Parent = R.homeButton

R.logoHeader = Instance.new("TextLabel")
R.logoHeader.Size = UDim2.new(0, 90, 1, 0)
R.logoHeader.Position = UDim2.new(0, 58, 0, 0)
R.logoHeader.BackgroundTransparency = 1
R.logoHeader.Text = "Roogle"
R.logoHeader.Font = Enum.Font.GothamBold
R.logoHeader.TextSize = 26
R.logoHeader.TextColor3 = Color3.fromRGB(66, 133, 244)
R.logoHeader.TextXAlignment = Enum.TextXAlignment.Left
R.logoHeader.Parent = R.resultsHeader

-- Barra de búsqueda en header
R.searchContainerHeader = Instance.new("Frame")
R.searchContainerHeader.Name = "SearchContainerHeader"
R.searchContainerHeader.Size = UDim2.new(0, 450, 0, 38)
R.searchContainerHeader.Position = UDim2.new(0, 165, 0.5, -19)
R.searchContainerHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.searchContainerHeader.BorderSizePixel = 0
R.searchContainerHeader.ZIndex = 3
R.searchContainerHeader.Parent = R.resultsHeader

local searchCornerHeader = Instance.new("UICorner")
searchCornerHeader.CornerRadius = UDim.new(0, 19)
searchCornerHeader.Parent = R.searchContainerHeader

local searchLayoutHeader = Instance.new("UIListLayout")
searchLayoutHeader.FillDirection = Enum.FillDirection.Horizontal
searchLayoutHeader.VerticalAlignment = Enum.VerticalAlignment.Center
searchLayoutHeader.Parent = R.searchContainerHeader

local searchIconHeader = Instance.new("TextLabel")
searchIconHeader.Size = UDim2.new(0, 32, 1, 0)
searchIconHeader.BackgroundTransparency = 1
searchIconHeader.Text = "🔍"
searchIconHeader.TextSize = 18
searchIconHeader.ZIndex = 4
searchIconHeader.Parent = R.searchContainerHeader

R.searchBoxHeader = Instance.new("TextBox")
R.searchBoxHeader.Name = "SearchBoxHeader"
R.searchBoxHeader.Size = UDim2.new(1, -64, 1, 0)
R.searchBoxHeader.BackgroundTransparency = 1
R.searchBoxHeader.Text = ""
R.searchBoxHeader.PlaceholderText = "Buscar..."
R.searchBoxHeader.Font = Enum.Font.Gotham
R.searchBoxHeader.TextSize = 15
R.searchBoxHeader.TextColor3 = Color3.fromRGB(0, 0, 0)
R.searchBoxHeader.TextXAlignment = Enum.TextXAlignment.Left
R.searchBoxHeader.ClearTextOnFocus = false
R.searchBoxHeader.ZIndex = 4
R.searchBoxHeader.Parent = R.searchContainerHeader

R.searchButtonHeader = Instance.new("TextButton")
R.searchButtonHeader.Name = "SearchButtonHeader"
R.searchButtonHeader.Size = UDim2.new(0, 32, 1, 0)
R.searchButtonHeader.BackgroundTransparency = 1
R.searchButtonHeader.Text = "→"
R.searchButtonHeader.Font = Enum.Font.GothamBold
R.searchButtonHeader.TextSize = 20
R.searchButtonHeader.TextColor3 = Color3.fromRGB(66, 133, 244)
R.searchButtonHeader.ZIndex = 4
R.searchButtonHeader.Parent = R.searchContainerHeader

-- Lista de resultados
R.resultsScrollFrame = Instance.new("ScrollingFrame")
R.resultsScrollFrame.Name = "ResultsScrollFrame"
R.resultsScrollFrame.Size = UDim2.new(1, 0, 1, -65)
R.resultsScrollFrame.Position = UDim2.new(0, 0, 0, 65)
R.resultsScrollFrame.BackgroundTransparency = 1
R.resultsScrollFrame.BorderSizePixel = 0
R.resultsScrollFrame.ScrollBarThickness = 8
R.resultsScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.resultsScrollFrame.Parent = R.resultsFrame

R.resultsLayout = Instance.new("UIListLayout")
R.resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
R.resultsLayout.Padding = UDim.new(0, 0)
R.resultsLayout.Parent = R.resultsScrollFrame

local resultsPadding = Instance.new("UIPadding")
resultsPadding.PaddingLeft = UDim.new(0, 30)
resultsPadding.PaddingRight = UDim.new(0, 30)
resultsPadding.PaddingTop = UDim.new(0, 20)
resultsPadding.PaddingBottom = UDim.new(0, 30)
resultsPadding.Parent = R.resultsScrollFrame

-- ========== VISTA DE ARTÍCULO COMPLETO ==========
R.articleViewFrame = Instance.new("ScrollingFrame")
R.articleViewFrame.Name = "ArticleViewFrame"
R.articleViewFrame.Size = UDim2.new(1, 0, 1, 0)
R.articleViewFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.articleViewFrame.BorderSizePixel = 0
R.articleViewFrame.ScrollBarThickness = 8
R.articleViewFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.articleViewFrame.Visible = false
R.articleViewFrame.Parent = R.mainFrame

R.articleLayout = Instance.new("UIListLayout")
R.articleLayout.SortOrder = Enum.SortOrder.LayoutOrder
R.articleLayout.Padding = UDim.new(0, 20)
R.articleLayout.Parent = R.articleViewFrame

local articlePadding = Instance.new("UIPadding")
articlePadding.PaddingLeft = UDim.new(0, 25)
articlePadding.PaddingRight = UDim.new(0, 25)
articlePadding.PaddingTop = UDim.new(0, 30)
articlePadding.PaddingBottom = UDim.new(0, 30)
articlePadding.Parent = R.articleViewFrame

-- Botón volver
R.backButton = Instance.new("TextButton")
R.backButton.Name = "BackButton"
R.backButton.Size = UDim2.new(0, 100, 0, 40)
R.backButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
R.backButton.Text = "← Volver"
R.backButton.Font = Enum.Font.GothamBold
R.backButton.TextSize = 16
R.backButton.TextColor3 = Color3.fromRGB(60, 60, 60)
R.backButton.BorderSizePixel = 0
R.backButton.LayoutOrder = 1
R.backButton.Parent = R.articleViewFrame

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 8)
backCorner.Parent = R.backButton

-- ========== VISTA DE PERFIL DE USUARIO ==========
R.profileFrame = Instance.new("ScrollingFrame")
R.profileFrame.Name = "ProfileFrame"
R.profileFrame.Size = UDim2.new(1, 0, 1, 0)
R.profileFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.profileFrame.BorderSizePixel = 0
R.profileFrame.ScrollBarThickness = 8
R.profileFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.profileFrame.Visible = false
R.profileFrame.Parent = R.mainFrame

R.profileLayout = Instance.new("UIListLayout")
R.profileLayout.SortOrder = Enum.SortOrder.LayoutOrder
R.profileLayout.Padding = UDim.new(0, 20)
R.profileLayout.Parent = R.profileFrame

local profilePadding = Instance.new("UIPadding")
profilePadding.PaddingLeft = UDim.new(0, 30)
profilePadding.PaddingRight = UDim.new(0, 30)
profilePadding.PaddingTop = UDim.new(0, 30)
profilePadding.PaddingBottom = UDim.new(0, 30)
profilePadding.Parent = R.profileFrame

-- Botón volver del perfil
R.profileBackButton = Instance.new("TextButton")
R.profileBackButton.Name = "ProfileBackButton"
R.profileBackButton.Size = UDim2.new(0, 100, 0, 40)
R.profileBackButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
R.profileBackButton.Text = "← Volver"
R.profileBackButton.Font = Enum.Font.GothamBold
R.profileBackButton.TextSize = 16
R.profileBackButton.TextColor3 = Color3.fromRGB(60, 60, 60)
R.profileBackButton.BorderSizePixel = 0
R.profileBackButton.LayoutOrder = 1
R.profileBackButton.Parent = R.profileFrame

local profileBackCorner = Instance.new("UICorner")
profileBackCorner.CornerRadius = UDim.new(0, 8)
profileBackCorner.Parent = R.profileBackButton

-- ========== PANEL DE CARGA ==========
R.loadingPanel = Instance.new("Frame")
R.loadingPanel.Size = UDim2.new(1, 0, 1, 0)
R.loadingPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
R.loadingPanel.BackgroundTransparency = 0.7
R.loadingPanel.BorderSizePixel = 0
R.loadingPanel.Visible = false
R.loadingPanel.ZIndex = 20
R.loadingPanel.Parent = R.mainFrame

R.loadingLabel = Instance.new("TextLabel")
R.loadingLabel.Size = UDim2.new(0.5, 0, 0, 50)
R.loadingLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
R.loadingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
R.loadingLabel.BackgroundTransparency = 1
R.loadingLabel.Text = "Enviando a revisión..."
R.loadingLabel.Font = Enum.Font.GothamBold
R.loadingLabel.TextSize = 28
R.loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
R.loadingLabel.Parent = R.loadingPanel

-- ========== BOTONES DE NAVEGACIÓN SUPERIOR ==========
-- Reloj (hora actual)
R.clockLabel = Instance.new("TextLabel")
R.clockLabel.Name = "ClockLabel"
R.clockLabel.Size = UDim2.new(0, 100, 0, 30)
R.clockLabel.Position = UDim2.new(0, 15, 0, 15)
R.clockLabel.BackgroundTransparency = 1
R.clockLabel.Text = os.date("%H:%M")
R.clockLabel.Font = Enum.Font.GothamBold
R.clockLabel.TextSize = 18
R.clockLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
R.clockLabel.TextXAlignment = Enum.TextXAlignment.Left
R.clockLabel.ZIndex = 5
R.clockLabel.Parent = R.mainFrame

-- Actualizar reloj cada segundo
task.spawn(function()
        while true do
                task.wait(1)
                R.clockLabel.Text = os.date("%H:%M")
        end
end)

-- Botón de configuración
R.settingsButton = Instance.new("TextButton")
R.settingsButton.Name = "SettingsButton"
R.settingsButton.Size = UDim2.new(0, 45, 0, 45)
R.settingsButton.Position = R.isAdmin and UDim2.new(1, -70, 0, 15) or UDim2.new(1, -15, 0, 15)
R.settingsButton.AnchorPoint = Vector2.new(1, 0)
R.settingsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
R.settingsButton.Text = "⚙️"
R.settingsButton.Font = Enum.Font.GothamBold
R.settingsButton.TextSize = 22
R.settingsButton.BorderSizePixel = 0
R.settingsButton.ZIndex = 5
R.settingsButton.Parent = R.mainFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(1, 0)
settingsCorner.Parent = R.settingsButton

-- Botón de creador (icono)
R.creatorButton = Instance.new("TextButton")
R.creatorButton.Name = "CreatorButton"
R.creatorButton.Size = UDim2.new(0, 45, 0, 45)
R.creatorButton.Position = R.isAdmin and UDim2.new(1, -125, 0, 15) or UDim2.new(1, -70, 0, 15)
R.creatorButton.AnchorPoint = Vector2.new(1, 0)
R.creatorButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
R.creatorButton.Text = "✏️"
R.creatorButton.Font = Enum.Font.GothamBold
R.creatorButton.TextSize = 22
R.creatorButton.BorderSizePixel = 0
R.creatorButton.ZIndex = 5
R.creatorButton.Parent = R.mainFrame

local creatorCorner = Instance.new("UICorner")
creatorCorner.CornerRadius = UDim.new(1, 0)
creatorCorner.Parent = R.creatorButton

-- Botón de administrador (solo visible para admins)
if R.isAdmin then
        R.adminPanelButton = Instance.new("TextButton")
        R.adminPanelButton.Name = "AdminPanelButton"
        R.adminPanelButton.Size = UDim2.new(0, 45, 0, 45)
        R.adminPanelButton.Position = UDim2.new(1, -15, 0, 15)
        R.adminPanelButton.AnchorPoint = Vector2.new(1, 0)
        R.adminPanelButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
        R.adminPanelButton.Text = "👑"
        R.adminPanelButton.Font = Enum.Font.GothamBold
        R.adminPanelButton.TextSize = 22
        R.adminPanelButton.BorderSizePixel = 0
        R.adminPanelButton.ZIndex = 5
        R.adminPanelButton.Parent = R.mainFrame

        local adminPanelCorner = Instance.new("UICorner")
        adminPanelCorner.CornerRadius = UDim.new(1, 0)
        adminPanelCorner.Parent = R.adminPanelButton
end

-- ========== PANEL DE CREADOR (PANTALLA COMPLETA) ==========
R.creatorPanel = Instance.new("ScrollingFrame")
R.creatorPanel.Name = "CreatorPanel"
R.creatorPanel.Size = UDim2.new(1, 0, 1, 0)
R.creatorPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.creatorPanel.BorderSizePixel = 0
R.creatorPanel.Visible = false
R.creatorPanel.ZIndex = 10
R.creatorPanel.ScrollBarThickness = 8
R.creatorPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.creatorPanel.Parent = R.mainFrame

local creatorLayout = Instance.new("UIListLayout")
creatorLayout.SortOrder = Enum.SortOrder.LayoutOrder
creatorLayout.Padding = UDim.new(0, 20)
creatorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
creatorLayout.Parent = R.creatorPanel

local creatorPadding = Instance.new("UIPadding")
creatorPadding.PaddingLeft = UDim.new(0, 20)
creatorPadding.PaddingRight = UDim.new(0, 20)
creatorPadding.PaddingTop = UDim.new(0, 30)
creatorPadding.PaddingBottom = UDim.new(0, 30)
creatorPadding.Parent = R.creatorPanel

-- Header con título y botón cerrar
local creatorHeaderContainer = Instance.new("Frame")
creatorHeaderContainer.Size = UDim2.new(1, 0, 0, 50)
creatorHeaderContainer.BackgroundTransparency = 1
creatorHeaderContainer.LayoutOrder = 1
creatorHeaderContainer.Parent = R.creatorPanel

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

R.creatorCloseButton = Instance.new("TextButton")
R.creatorCloseButton.Size = UDim2.new(0, 45, 0, 45)
R.creatorCloseButton.Position = UDim2.new(1, 0, 0, 0)
R.creatorCloseButton.AnchorPoint = Vector2.new(1, 0)
R.creatorCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
R.creatorCloseButton.Text = "✕"
R.creatorCloseButton.Font = Enum.Font.GothamBold
R.creatorCloseButton.TextSize = 24
R.creatorCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
R.creatorCloseButton.BorderSizePixel = 0
R.creatorCloseButton.ZIndex = 11
R.creatorCloseButton.Parent = creatorHeaderContainer

local creatorCloseCorner = Instance.new("UICorner")
creatorCloseCorner.CornerRadius = UDim.new(1, 0)
creatorCloseCorner.Parent = R.creatorCloseButton

-- Contenedor de campos
local creatorFieldsContainer = Instance.new("Frame")
creatorFieldsContainer.Size = UDim2.new(1, 0, 0, 600)
creatorFieldsContainer.BackgroundTransparency = 1
creatorFieldsContainer.LayoutOrder = 2
creatorFieldsContainer.Parent = R.creatorPanel

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
R.titleInput = Instance.new("TextBox")
R.titleInput.Name = "TitleInput"
R.titleInput.Size = UDim2.new(1, 0, 0, 50)
R.titleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
R.titleInput.Text = ""
R.titleInput.PlaceholderText = "Escribe el título del artículo..."
R.titleInput.Font = Enum.Font.Gotham
R.titleInput.TextSize = 18
R.titleInput.TextColor3 = Color3.fromRGB(0, 0, 0)
R.titleInput.TextXAlignment = Enum.TextXAlignment.Left
R.titleInput.ClearTextOnFocus = false
R.titleInput.BorderSizePixel = 0
R.titleInput.LayoutOrder = 2
R.titleInput.ZIndex = 11
R.titleInput.Parent = creatorFieldsContainer

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = R.titleInput

local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 15)
titlePadding.PaddingRight = UDim.new(0, 15)
titlePadding.Parent = R.titleInput

-- Etiqueta Categoría
local categoryLabel = Instance.new("TextLabel")
categoryLabel.Size = UDim2.new(1, 0, 0, 25)
categoryLabel.BackgroundTransparency = 1
categoryLabel.Text = "🏷️ Categoría"
categoryLabel.Font = Enum.Font.GothamBold
categoryLabel.TextSize = 18
categoryLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
categoryLabel.LayoutOrder = 3
categoryLabel.ZIndex = 11
categoryLabel.Parent = creatorFieldsContainer

-- Campo Categoría
R.categoryInput = Instance.new("TextBox")
R.categoryInput.Name = "CategoryInput"
R.categoryInput.Size = UDim2.new(1, 0, 0, 50)
R.categoryInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
R.categoryInput.Text = ""
R.categoryInput.PlaceholderText = "Ej: Tecnología, Deportes, Entretenimiento..."
R.categoryInput.Font = Enum.Font.Gotham
R.categoryInput.TextSize = 18
R.categoryInput.TextColor3 = Color3.fromRGB(0, 0, 0)
R.categoryInput.TextXAlignment = Enum.TextXAlignment.Left
R.categoryInput.ClearTextOnFocus = false
R.categoryInput.BorderSizePixel = 0
R.categoryInput.LayoutOrder = 4
R.categoryInput.ZIndex = 11
R.categoryInput.Parent = creatorFieldsContainer

local categoryCorner = Instance.new("UICorner")
categoryCorner.CornerRadius = UDim.new(0, 10)
categoryCorner.Parent = R.categoryInput

local categoryPadding = Instance.new("UIPadding")
categoryPadding.PaddingLeft = UDim.new(0, 15)
categoryPadding.PaddingRight = UDim.new(0, 15)
categoryPadding.Parent = R.categoryInput

-- Etiqueta Contenido
local contentLabel = Instance.new("TextLabel")
contentLabel.Size = UDim2.new(1, 0, 0, 25)
contentLabel.BackgroundTransparency = 1
contentLabel.Text = "📄 Contenido del artículo"
contentLabel.Font = Enum.Font.GothamBold
contentLabel.TextSize = 18
contentLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
contentLabel.TextXAlignment = Enum.TextXAlignment.Left
contentLabel.LayoutOrder = 5
contentLabel.ZIndex = 11
contentLabel.Parent = creatorFieldsContainer

-- Campo Contenido
R.contentInput = Instance.new("TextBox")
R.contentInput.Name = "ContentInput"
R.contentInput.Size = UDim2.new(1, 0, 0, 350)
R.contentInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
R.contentInput.Text = ""
R.contentInput.PlaceholderText = "Escribe el contenido completo del artículo..."
R.contentInput.Font = Enum.Font.Gotham
R.contentInput.TextSize = 18
R.contentInput.TextColor3 = Color3.fromRGB(0, 0, 0)
R.contentInput.TextXAlignment = Enum.TextXAlignment.Left
R.contentInput.TextYAlignment = Enum.TextYAlignment.Top
R.contentInput.ClearTextOnFocus = false
R.contentInput.MultiLine = true
R.contentInput.TextWrapped = true
R.contentInput.BorderSizePixel = 0
R.contentInput.LayoutOrder = 6
R.contentInput.ZIndex = 11
R.contentInput.Parent = creatorFieldsContainer

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = R.contentInput

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingLeft = UDim.new(0, 15)
contentPadding.PaddingTop = UDim.new(0, 15)
contentPadding.PaddingRight = UDim.new(0, 15)
contentPadding.PaddingBottom = UDim.new(0, 15)
contentPadding.Parent = R.contentInput

-- Botón enviar a revisión
R.submitButton = Instance.new("TextButton")
R.submitButton.Name = "SubmitButton"
R.submitButton.Size = UDim2.new(1, 0, 0, 55)
R.submitButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
R.submitButton.Text = "📤 Enviar a Revisión"
R.submitButton.Font = Enum.Font.GothamBold
R.submitButton.TextSize = 20
R.submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
R.submitButton.BorderSizePixel = 0
R.submitButton.LayoutOrder = 7
R.submitButton.ZIndex = 11
R.submitButton.Parent = creatorFieldsContainer

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 10)
submitCorner.Parent = R.submitButton

-- Actualizar CanvasSize dinámicamente
task.wait(0.1)
creatorFieldsContainer.Size = UDim2.new(1, 0, 0, creatorFieldsLayout.AbsoluteContentSize.Y)
R.creatorPanel.CanvasSize = UDim2.new(0, 0, 0, creatorLayout.AbsoluteContentSize.Y + 60)

-- ========== PANEL DE ADMINISTRADOR (solo para admins) ==========
if R.isAdmin then
        R.adminPanel = Instance.new("ScrollingFrame")
        R.adminPanel.Name = "AdminPanel"
        R.adminPanel.Size = UDim2.new(1, 0, 1, 0)
        R.adminPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        R.adminPanel.BorderSizePixel = 0
        R.adminPanel.Visible = false
        R.adminPanel.ZIndex = 10
        R.adminPanel.ScrollBarThickness = 8
        R.adminPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        R.adminPanel.Parent = R.mainFrame

        local adminLayout = Instance.new("UIListLayout")
        adminLayout.SortOrder = Enum.SortOrder.LayoutOrder
        adminLayout.Padding = UDim.new(0, 15)
        adminLayout.Parent = R.adminPanel

        local adminPadding = Instance.new("UIPadding")
        adminPadding.PaddingLeft = UDim.new(0, 30)
        adminPadding.PaddingRight = UDim.new(0, 30)
        adminPadding.PaddingTop = UDim.new(0, 30)
        adminPadding.PaddingBottom = UDim.new(0, 30)
        adminPadding.Parent = R.adminPanel

        -- Header del panel de admin
        local adminHeaderContainer = Instance.new("Frame")
        adminHeaderContainer.Size = UDim2.new(1, 0, 0, 60)
        adminHeaderContainer.BackgroundTransparency = 1
        adminHeaderContainer.LayoutOrder = 1
        adminHeaderContainer.Parent = R.adminPanel

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

        R.adminCloseButton = Instance.new("TextButton")
        R.adminCloseButton.Size = UDim2.new(0, 45, 0, 45)
        R.adminCloseButton.Position = UDim2.new(1, 0, 0, 0)
        R.adminCloseButton.AnchorPoint = Vector2.new(1, 0)
        R.adminCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        R.adminCloseButton.Text = "✕"
        R.adminCloseButton.Font = Enum.Font.GothamBold
        R.adminCloseButton.TextSize = 24
        R.adminCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
        R.adminCloseButton.BorderSizePixel = 0
        R.adminCloseButton.ZIndex = 11
        R.adminCloseButton.Parent = adminHeaderContainer

        local adminCloseCorner = Instance.new("UICorner")
        adminCloseCorner.CornerRadius = UDim.new(1, 0)
        adminCloseCorner.Parent = R.adminCloseButton

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
        userManagementTitle.Parent = R.adminPanel

        -- Barra de búsqueda de usuarios
        local userSearchContainer = Instance.new("Frame")
        userSearchContainer.Size = UDim2.new(1, 0, 0, 50)
        userSearchContainer.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
        userSearchContainer.BorderSizePixel = 0
        userSearchContainer.LayoutOrder = 3
        userSearchContainer.ZIndex = 11
        userSearchContainer.Parent = R.adminPanel

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

        R.adminSearchBox = Instance.new("TextBox")
        R.adminSearchBox.Name = "AdminSearchBox"
        R.adminSearchBox.Size = UDim2.new(1, -50, 1, 0)
        R.adminSearchBox.BackgroundTransparency = 1
        R.adminSearchBox.Text = ""
        R.adminSearchBox.PlaceholderText = "Buscar usuario por nombre..."
        R.adminSearchBox.Font = Enum.Font.Gotham
        R.adminSearchBox.TextSize = 18
        R.adminSearchBox.TextColor3 = Color3.fromRGB(0, 0, 0)
        R.adminSearchBox.TextXAlignment = Enum.TextXAlignment.Left
        R.adminSearchBox.ClearTextOnFocus = false
        R.adminSearchBox.ZIndex = 12
        R.adminSearchBox.Parent = userSearchContainer

        -- Contenedor de resultados de búsqueda de usuarios
        R.adminScrollContainer = Instance.new("ScrollingFrame")
        R.adminScrollContainer.Name = "AdminScrollContainer"
        R.adminScrollContainer.Size = UDim2.new(1, 0, 0, 250)
        R.adminScrollContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        R.adminScrollContainer.BorderSizePixel = 0
        R.adminScrollContainer.ScrollBarThickness = 6
        R.adminScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        R.adminScrollContainer.LayoutOrder = 4
        R.adminScrollContainer.ZIndex = 11
        R.adminScrollContainer.Parent = R.adminPanel

        local adminScrollCorner = Instance.new("UICorner")
        adminScrollCorner.CornerRadius = UDim.new(0, 10)
        adminScrollCorner.Parent = R.adminScrollContainer

        local adminScrollLayout = Instance.new("UIListLayout")
        adminScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        adminScrollLayout.Padding = UDim.new(0, 10)
        adminScrollLayout.Parent = R.adminScrollContainer

        local adminScrollPadding = Instance.new("UIPadding")
        adminScrollPadding.PaddingLeft = UDim.new(0, 15)
        adminScrollPadding.PaddingRight = UDim.new(0, 15)
        adminScrollPadding.PaddingTop = UDim.new(0, 15)
        adminScrollPadding.PaddingBottom = UDim.new(0, 15)
        adminScrollPadding.Parent = R.adminScrollContainer

        -- Separador
        local separator1 = Instance.new("Frame")
        separator1.Size = UDim2.new(1, 0, 0, 2)
        separator1.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        separator1.BorderSizePixel = 0
        separator1.LayoutOrder = 5
        separator1.ZIndex = 11
        separator1.Parent = R.adminPanel

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
        articlesManagementTitle.Parent = R.adminPanel

        -- Botón actualizar
        R.refreshButton = Instance.new("TextButton")
        R.refreshButton.Size = UDim2.new(1, 0, 0, 45)
        R.refreshButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        R.refreshButton.Text = "🔄 Actualizar Artículos"
        R.refreshButton.Font = Enum.Font.GothamBold
        R.refreshButton.TextSize = 18
        R.refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        R.refreshButton.BorderSizePixel = 0
        R.refreshButton.LayoutOrder = 7
        R.refreshButton.ZIndex = 11
        R.refreshButton.Parent = R.adminPanel

        local refreshCorner = Instance.new("UICorner")
        refreshCorner.CornerRadius = UDim.new(0, 10)
        refreshCorner.Parent = R.refreshButton

        -- Contenedor de todos los artículos
        R.allArticlesContainer = Instance.new("ScrollingFrame")
        R.allArticlesContainer.Name = "AllArticlesContainer"
        R.allArticlesContainer.Size = UDim2.new(1, 0, 0, 400)
        R.allArticlesContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        R.allArticlesContainer.BorderSizePixel = 0
        R.allArticlesContainer.ScrollBarThickness = 6
        R.allArticlesContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        R.allArticlesContainer.LayoutOrder = 8
        R.allArticlesContainer.ZIndex = 11
        R.allArticlesContainer.Parent = R.adminPanel

        local allArticlesCorner = Instance.new("UICorner")
        allArticlesCorner.CornerRadius = UDim.new(0, 10)
        allArticlesCorner.Parent = R.allArticlesContainer

        local allArticlesLayout = Instance.new("UIListLayout")
        allArticlesLayout.SortOrder = Enum.SortOrder.LayoutOrder
        allArticlesLayout.Padding = UDim.new(0, 10)
        allArticlesLayout.Parent = R.allArticlesContainer

        local allArticlesPadding = Instance.new("UIPadding")
        allArticlesPadding.PaddingLeft = UDim.new(0, 15)
        allArticlesPadding.PaddingRight = UDim.new(0, 15)
        allArticlesPadding.PaddingTop = UDim.new(0, 15)
        allArticlesPadding.PaddingBottom = UDim.new(0, 15)
        allArticlesPadding.Parent = R.allArticlesContainer

        -- Separador
        local separator2 = Instance.new("Frame")
        separator2.Size = UDim2.new(1, 0, 0, 2)
        separator2.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        separator2.BorderSizePixel = 0
        separator2.LayoutOrder = 9
        separator2.ZIndex = 11
        separator2.Parent = R.adminPanel

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
        systemTitle.Parent = R.adminPanel

        -- Campo título del sistema
        R.systemTitleInput = Instance.new("TextBox")
        R.systemTitleInput.Name = "SystemTitleInput"
        R.systemTitleInput.Size = UDim2.new(1, 0, 0, 50)
        R.systemTitleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
        R.systemTitleInput.Text = ""
        R.systemTitleInput.PlaceholderText = "Título del anuncio..."
        R.systemTitleInput.Font = Enum.Font.Gotham
        R.systemTitleInput.TextSize = 18
        R.systemTitleInput.TextColor3 = Color3.fromRGB(0, 0, 0)
        R.systemTitleInput.TextXAlignment = Enum.TextXAlignment.Left
        R.systemTitleInput.ClearTextOnFocus = false
        R.systemTitleInput.BorderSizePixel = 0
        R.systemTitleInput.LayoutOrder = 11
        R.systemTitleInput.ZIndex = 11
        R.systemTitleInput.Parent = R.adminPanel

        local systemTitleCorner = Instance.new("UICorner")
        systemTitleCorner.CornerRadius = UDim.new(0, 10)
        systemTitleCorner.Parent = R.systemTitleInput

        local systemTitlePadding = Instance.new("UIPadding")
        systemTitlePadding.PaddingLeft = UDim.new(0, 15)
        systemTitlePadding.PaddingRight = UDim.new(0, 15)
        systemTitlePadding.Parent = R.systemTitleInput

        -- Campo contenido del sistema
        R.systemContentInput = Instance.new("TextBox")
        R.systemContentInput.Name = "SystemContentInput"
        R.systemContentInput.Size = UDim2.new(1, 0, 0, 150)
        R.systemContentInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
        R.systemContentInput.Text = ""
        R.systemContentInput.PlaceholderText = "Contenido del anuncio..."
        R.systemContentInput.Font = Enum.Font.Gotham
        R.systemContentInput.TextSize = 16
        R.systemContentInput.TextColor3 = Color3.fromRGB(0, 0, 0)
        R.systemContentInput.TextXAlignment = Enum.TextXAlignment.Left
        R.systemContentInput.TextYAlignment = Enum.TextYAlignment.Top
        R.systemContentInput.ClearTextOnFocus = false
        R.systemContentInput.MultiLine = true
        R.systemContentInput.TextWrapped = true
        R.systemContentInput.BorderSizePixel = 0
        R.systemContentInput.LayoutOrder = 12
        R.systemContentInput.ZIndex = 11
        R.systemContentInput.Parent = R.adminPanel

        local systemContentCorner = Instance.new("UICorner")
        systemContentCorner.CornerRadius = UDim.new(0, 10)
        systemContentCorner.Parent = R.systemContentInput

        local systemContentPadding = Instance.new("UIPadding")
        systemContentPadding.PaddingLeft = UDim.new(0, 15)
        systemContentPadding.PaddingTop = UDim.new(0, 15)
        systemContentPadding.PaddingRight = UDim.new(0, 15)
        systemContentPadding.PaddingBottom = UDim.new(0, 15)
        systemContentPadding.Parent = R.systemContentInput

        -- Botón publicar como sistema
        R.systemPublishButton = Instance.new("TextButton")
        R.systemPublishButton.Name = "SystemPublishButton"
        R.systemPublishButton.Size = UDim2.new(1, 0, 0, 50)
        R.systemPublishButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
        R.systemPublishButton.Text = "📢 Publicar como Sistema"
        R.systemPublishButton.Font = Enum.Font.GothamBold
        R.systemPublishButton.TextSize = 18
        R.systemPublishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        R.systemPublishButton.BorderSizePixel = 0
        R.systemPublishButton.LayoutOrder = 13
        R.systemPublishButton.ZIndex = 11
        R.systemPublishButton.Parent = R.adminPanel

        local systemPublishCorner = Instance.new("UICorner")
        systemPublishCorner.CornerRadius = UDim.new(0, 10)
        systemPublishCorner.Parent = R.systemPublishButton

        -- Separador
        local separator3 = Instance.new("Frame")
        separator3.Size = UDim2.new(1, 0, 0, 2)
        separator3.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        separator3.BorderSizePixel = 0
        separator3.LayoutOrder = 14
        separator3.ZIndex = 11
        separator3.Parent = R.adminPanel

        -- Sección: Gestión de Música
        local musicManagementTitle = Instance.new("TextLabel")
        musicManagementTitle.Size = UDim2.new(1, 0, 0, 30)
        musicManagementTitle.BackgroundTransparency = 1
        musicManagementTitle.Text = "🎵 Gestión de Música"
        musicManagementTitle.Font = Enum.Font.GothamBold
        musicManagementTitle.TextSize = 22
        musicManagementTitle.TextColor3 = Color3.fromRGB(50, 50, 50)
        musicManagementTitle.TextXAlignment = Enum.TextXAlignment.Left
        musicManagementTitle.LayoutOrder = 15
        musicManagementTitle.ZIndex = 11
        musicManagementTitle.Parent = R.adminPanel

        -- Botón actualizar música
        R.refreshMusicButton = Instance.new("TextButton")
        R.refreshMusicButton.Size = UDim2.new(1, 0, 0, 45)
        R.refreshMusicButton.BackgroundColor3 = Color3.fromRGB(255, 87, 34)
        R.refreshMusicButton.Text = "🔄 Actualizar Música"
        R.refreshMusicButton.Font = Enum.Font.GothamBold
        R.refreshMusicButton.TextSize = 18
        R.refreshMusicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        R.refreshMusicButton.BorderSizePixel = 0
        R.refreshMusicButton.LayoutOrder = 16
        R.refreshMusicButton.ZIndex = 11
        R.refreshMusicButton.Parent = R.adminPanel

        local refreshMusicCorner = Instance.new("UICorner")
        refreshMusicCorner.CornerRadius = UDim.new(0, 10)
        refreshMusicCorner.Parent = R.refreshMusicButton

        -- Contenedor de todas las músicas
        R.allMusicContainer = Instance.new("ScrollingFrame")
        R.allMusicContainer.Name = "AllMusicContainer"
        R.allMusicContainer.Size = UDim2.new(1, 0, 0, 300)
        R.allMusicContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        R.allMusicContainer.BorderSizePixel = 0
        R.allMusicContainer.ScrollBarThickness = 6
        R.allMusicContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        R.allMusicContainer.LayoutOrder = 17
        R.allMusicContainer.ZIndex = 11
        R.allMusicContainer.Parent = R.adminPanel

        local allMusicCorner = Instance.new("UICorner")
        allMusicCorner.CornerRadius = UDim.new(0, 10)
        allMusicCorner.Parent = R.allMusicContainer

        local allMusicLayout = Instance.new("UIListLayout")
        allMusicLayout.SortOrder = Enum.SortOrder.LayoutOrder
        allMusicLayout.Padding = UDim.new(0, 10)
        allMusicLayout.Parent = R.allMusicContainer

        local allMusicPadding = Instance.new("UIPadding")
        allMusicPadding.PaddingLeft = UDim.new(0, 15)
        allMusicPadding.PaddingRight = UDim.new(0, 15)
        allMusicPadding.PaddingTop = UDim.new(0, 15)
        allMusicPadding.PaddingBottom = UDim.new(0, 15)
        allMusicPadding.Parent = R.allMusicContainer
end

-- ========== PANEL DE CONFIGURACIÓN ==========
R.settingsPanel = Instance.new("ScrollingFrame")
R.settingsPanel.Name = "SettingsPanel"
R.settingsPanel.Size = UDim2.new(1, 0, 1, 0)
R.settingsPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.settingsPanel.BorderSizePixel = 0
R.settingsPanel.Visible = false
R.settingsPanel.ZIndex = 10
R.settingsPanel.ScrollBarThickness = 8
R.settingsPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.settingsPanel.Parent = R.mainFrame

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Padding = UDim.new(0, 20)
settingsLayout.Parent = R.settingsPanel

local settingsPadding = Instance.new("UIPadding")
settingsPadding.PaddingLeft = UDim.new(0, 30)
settingsPadding.PaddingRight = UDim.new(0, 30)
settingsPadding.PaddingTop = UDim.new(0, 30)
settingsPadding.PaddingBottom = UDim.new(0, 30)
settingsPadding.Parent = R.settingsPanel

-- Header
local settingsHeaderContainer = Instance.new("Frame")
settingsHeaderContainer.Size = UDim2.new(1, 0, 0, 60)
settingsHeaderContainer.BackgroundTransparency = 1
settingsHeaderContainer.LayoutOrder = 1
settingsHeaderContainer.Parent = R.settingsPanel

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -60, 1, 0)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ CONFIGURACIÓN"
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 28
settingsTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.ZIndex = 11
settingsTitle.Parent = settingsHeaderContainer

R.settingsCloseButton = Instance.new("TextButton")
R.settingsCloseButton.Size = UDim2.new(0, 45, 0, 45)
R.settingsCloseButton.Position = UDim2.new(1, 0, 0, 0)
R.settingsCloseButton.AnchorPoint = Vector2.new(1, 0)
R.settingsCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
R.settingsCloseButton.Text = "✕"
R.settingsCloseButton.Font = Enum.Font.GothamBold
R.settingsCloseButton.TextSize = 24
R.settingsCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
R.settingsCloseButton.BorderSizePixel = 0
R.settingsCloseButton.ZIndex = 11
R.settingsCloseButton.Parent = settingsHeaderContainer

local settingsCloseCorner = Instance.new("UICorner")
settingsCloseCorner.CornerRadius = UDim.new(1, 0)
settingsCloseCorner.Parent = R.settingsCloseButton

-- Versión del juego
local versionContainer = Instance.new("Frame")
versionContainer.Size = UDim2.new(1, 0, 0, 100)
versionContainer.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
versionContainer.BorderSizePixel = 0
versionContainer.LayoutOrder = 2
versionContainer.ZIndex = 11
versionContainer.Parent = R.settingsPanel

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(0, 12)
versionCorner.Parent = versionContainer

local versionLayout = Instance.new("UIListLayout")
versionLayout.SortOrder = Enum.SortOrder.LayoutOrder
versionLayout.Padding = UDim.new(0, 8)
versionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
versionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
versionLayout.Parent = versionContainer

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 0, 0, 30)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "Versión del Juego"
versionLabel.Font = Enum.Font.GothamBold
versionLabel.TextSize = 18
versionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
versionLabel.LayoutOrder = 1
versionLabel.ZIndex = 12
versionLabel.Parent = versionContainer

local versionNumber = Instance.new("TextLabel")
versionNumber.Name = "VersionNumber"
versionNumber.Size = UDim2.new(1, 0, 0, 35)
versionNumber.BackgroundTransparency = 1
versionNumber.Text = "Cargando..."
versionNumber.Font = Enum.Font.GothamBold
versionNumber.TextSize = 32
versionNumber.TextColor3 = Color3.fromRGB(66, 133, 244)
versionNumber.LayoutOrder = 2
versionNumber.ZIndex = 12
versionNumber.Parent = versionContainer

-- Detectar versión automáticamente
task.spawn(function()
        local success, placeVersion = pcall(function()
                return game.PlaceVersion
        end)
        if success then
                versionNumber.Text = "v" .. tostring(placeVersion)
        else
                versionNumber.Text = "v1.0.0"
        end
end)

-- Derechos reservados
local copyrightContainer = Instance.new("Frame")
copyrightContainer.Size = UDim2.new(1, 0, 0, 80)
copyrightContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
copyrightContainer.BorderSizePixel = 0
copyrightContainer.LayoutOrder = 3
copyrightContainer.ZIndex = 11
copyrightContainer.Parent = R.settingsPanel

local copyrightCorner = Instance.new("UICorner")
copyrightCorner.CornerRadius = UDim.new(0, 12)
copyrightCorner.Parent = copyrightContainer

local copyrightText = Instance.new("TextLabel")
copyrightText.Size = UDim2.new(1, -40, 1, 0)
copyrightText.Position = UDim2.new(0, 20, 0, 0)
copyrightText.BackgroundTransparency = 1
copyrightText.Text = "© 2025 Glam. Todos los derechos reservados."
copyrightText.Font = Enum.Font.Gotham
copyrightText.TextSize = 16
copyrightText.TextColor3 = Color3.fromRGB(80, 80, 80)
copyrightText.TextWrapped = true
copyrightText.ZIndex = 12
copyrightText.Parent = copyrightContainer

-- Advertencia spam/enlaces
local warningContainer = Instance.new("Frame")
warningContainer.Size = UDim2.new(1, 0, 0, 150)
warningContainer.BackgroundColor3 = Color3.fromRGB(255, 243, 224)
warningContainer.BorderSizePixel = 0
warningContainer.LayoutOrder = 4
warningContainer.ZIndex = 11
warningContainer.Parent = R.settingsPanel

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 12)
warningCorner.Parent = warningContainer

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = Color3.fromRGB(255, 193, 7)
warningStroke.Thickness = 2
warningStroke.Parent = warningContainer

local warningLayout = Instance.new("UIListLayout")
warningLayout.SortOrder = Enum.SortOrder.LayoutOrder
warningLayout.Padding = UDim.new(0, 10)
warningLayout.Parent = warningContainer

local warningPadding = Instance.new("UIPadding")
warningPadding.PaddingLeft = UDim.new(0, 20)
warningPadding.PaddingRight = UDim.new(0, 20)
warningPadding.PaddingTop = UDim.new(0, 15)
warningPadding.PaddingBottom = UDim.new(0, 15)
warningPadding.Parent = warningContainer

local warningTitle = Instance.new("TextLabel")
warningTitle.Size = UDim2.new(1, 0, 0, 25)
warningTitle.BackgroundTransparency = 1
warningTitle.Text = "⚠️ ADVERTENCIA"
warningTitle.Font = Enum.Font.GothamBold
warningTitle.TextSize = 18
warningTitle.TextColor3 = Color3.fromRGB(255, 111, 0)
warningTitle.TextXAlignment = Enum.TextXAlignment.Left
warningTitle.LayoutOrder = 1
warningTitle.ZIndex = 12
warningTitle.Parent = warningContainer

local warningText = Instance.new("TextLabel")
warningText.Size = UDim2.new(1, 0, 0, 80)
warningText.BackgroundTransparency = 1
warningText.Text = "Cualquier artículo que se use para promocionar, hacer spam o contenga enlaces será eliminado inmediatamente de la plataforma. El autor puede ser sancionado."
warningText.Font = Enum.Font.Gotham
warningText.TextSize = 15
warningText.TextColor3 = Color3.fromRGB(100, 100, 100)
warningText.TextWrapped = true
warningText.TextXAlignment = Enum.TextXAlignment.Left
warningText.TextYAlignment = Enum.TextYAlignment.Top
warningText.LayoutOrder = 2
warningText.ZIndex = 12
warningText.Parent = warningContainer

-- Botón Términos y Condiciones
R.termsButton = Instance.new("TextButton")
R.termsButton.Size = UDim2.new(1, 0, 0, 55)
R.termsButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
R.termsButton.Text = "📜 Términos y Condiciones"
R.termsButton.Font = Enum.Font.GothamBold
R.termsButton.TextSize = 18
R.termsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
R.termsButton.BorderSizePixel = 0
R.termsButton.LayoutOrder = 5
R.termsButton.ZIndex = 11
R.termsButton.Parent = R.settingsPanel

local termsButtonCorner = Instance.new("UICorner")
termsButtonCorner.CornerRadius = UDim.new(0, 12)
termsButtonCorner.Parent = R.termsButton

-- Actualizar CanvasSize
task.wait(0.1)
R.settingsPanel.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 60)

-- ========== PANEL DE TÉRMINOS Y CONDICIONES ==========
R.termsPanel = Instance.new("ScrollingFrame")
R.termsPanel.Name = "TermsPanel"
R.termsPanel.Size = UDim2.new(1, 0, 1, 0)
R.termsPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.termsPanel.BorderSizePixel = 0
R.termsPanel.Visible = false
R.termsPanel.ZIndex = 10
R.termsPanel.ScrollBarThickness = 8
R.termsPanel.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
R.termsPanel.Parent = R.mainFrame

local termsLayoutUI = Instance.new("UIListLayout")
termsLayoutUI.SortOrder = Enum.SortOrder.LayoutOrder
termsLayoutUI.Padding = UDim.new(0, 20)
termsLayoutUI.Parent = R.termsPanel

local termsPaddingUI = Instance.new("UIPadding")
termsPaddingUI.PaddingLeft = UDim.new(0, 30)
termsPaddingUI.PaddingRight = UDim.new(0, 30)
termsPaddingUI.PaddingTop = UDim.new(0, 30)
termsPaddingUI.PaddingBottom = UDim.new(0, 30)
termsPaddingUI.Parent = R.termsPanel

-- Header términos
local termsHeaderContainer = Instance.new("Frame")
termsHeaderContainer.Size = UDim2.new(1, 0, 0, 60)
termsHeaderContainer.BackgroundTransparency = 1
termsHeaderContainer.LayoutOrder = 1
termsHeaderContainer.Parent = R.termsPanel

local termsHeaderTitle = Instance.new("TextLabel")
termsHeaderTitle.Size = UDim2.new(1, -60, 1, 0)
termsHeaderTitle.BackgroundTransparency = 1
termsHeaderTitle.Text = "📜 TÉRMINOS Y CONDICIONES"
termsHeaderTitle.Font = Enum.Font.GothamBold
termsHeaderTitle.TextSize = 26
termsHeaderTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
termsHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
termsHeaderTitle.ZIndex = 11
termsHeaderTitle.Parent = termsHeaderContainer

R.termsCloseButton = Instance.new("TextButton")
R.termsCloseButton.Size = UDim2.new(0, 45, 0, 45)
R.termsCloseButton.Position = UDim2.new(1, 0, 0, 0)
R.termsCloseButton.AnchorPoint = Vector2.new(1, 0)
R.termsCloseButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
R.termsCloseButton.Text = "✕"
R.termsCloseButton.Font = Enum.Font.GothamBold
R.termsCloseButton.TextSize = 24
R.termsCloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
R.termsCloseButton.BorderSizePixel = 0
R.termsCloseButton.ZIndex = 11
R.termsCloseButton.Parent = termsHeaderContainer

local termsCloseCorner = Instance.new("UICorner")
termsCloseCorner.CornerRadius = UDim.new(1, 0)
termsCloseCorner.Parent = R.termsCloseButton

-- Contenido de términos
local termsContent = Instance.new("TextLabel")
termsContent.Size = UDim2.new(1, 0, 0, 0)
termsContent.AutomaticSize = Enum.AutomaticSize.Y
termsContent.BackgroundTransparency = 1
termsContent.Text = [[1. ACEPTACIÓN DE LOS TÉRMINOS

Al usar Roogle, aceptas cumplir con estos términos y condiciones.

2. USO DEL SERVICIO

• Roogle es un motor de búsqueda de artículos creados por la comunidad.
• Los usuarios pueden publicar artículos que serán revisados por administradores.
• El contenido debe ser apropiado y respetuoso.

3. CONTENIDO PROHIBIDO

Está estrictamente prohibido publicar:
• Spam o promociones no autorizadas
• Enlaces externos sin autorización
• Contenido ofensivo, difamatorio o ilegal
• Material protegido por derechos de autor

4. MODERACIÓN

• Todos los artículos pasan por revisión antes de publicarse.
• Los administradores pueden aprobar, rechazar o eliminar contenido.
• Los usuarios que violen las normas pueden ser sancionados o baneados.

5. PROPIEDAD INTELECTUAL

• Los usuarios retienen los derechos de su contenido original.
• Al publicar, otorgas a Roogle licencia para mostrar tu contenido.
• © 2025 Glam. Todos los derechos reservados.

6. PRIVACIDAD

• Roogle respeta tu privacidad dentro de la plataforma Roblox.
• La información del usuario se usa solo para funciones del juego.

7. MODIFICACIONES

• Estos términos pueden actualizarse sin previo aviso.
• Es responsabilidad del usuario revisar los términos periódicamente.

8. CONTACTO

Para preguntas o reportes, contacta a los administradores del juego.

Última actualización: 26 de octubre de 2025]]
termsContent.Font = Enum.Font.Gotham
termsContent.TextSize = 16
termsContent.TextColor3 = Color3.fromRGB(50, 50, 50)
termsContent.TextXAlignment = Enum.TextXAlignment.Left
termsContent.TextYAlignment = Enum.TextYAlignment.Top
termsContent.TextWrapped = true
termsContent.LayoutOrder = 2
termsContent.ZIndex = 11
termsContent.Parent = R.termsPanel

-- Actualizar CanvasSize
task.wait(0.1)
R.termsPanel.CanvasSize = UDim2.new(0, 0, 0, termsLayoutUI.AbsoluteContentSize.Y + 60)

print("✓ Roogle Core (1/3) cargado: UI y variables listas.")


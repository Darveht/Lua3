
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

if not (getArticlesEvent and publishArticleFunction and checkAdminEvent and getArticleByIdEvent) then
    warn("❌ ERROR: No se pudieron cargar todos los RemoteEvents")
    return
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

-- ========== VISTA DE RESULTADOS ==========
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Name = "ResultsFrame"
resultsFrame.Size = UDim2.new(1, 0, 1, 0)
resultsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resultsFrame.BorderSizePixel = 0
resultsFrame.ScrollBarThickness = 8
resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
resultsFrame.Visible = false
resultsFrame.Parent = mainFrame

local resultsLayout = Instance.new("UIListLayout")
resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
resultsLayout.Padding = UDim.new(0, 15)
resultsLayout.Parent = resultsFrame

local resultsPadding = Instance.new("UIPadding")
resultsPadding.PaddingLeft = UDim.new(0, 100)
resultsPadding.PaddingRight = UDim.new(0, 100)
resultsPadding.PaddingTop = UDim.new(0, 90)
resultsPadding.PaddingBottom = UDim.new(0, 30)
resultsPadding.Parent = resultsFrame

-- Header de resultados
local resultsHeader = Instance.new("Frame")
resultsHeader.Size = UDim2.new(1, 0, 0, 80)
resultsHeader.Position = UDim2.new(0, 0, 0, 0)
resultsHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resultsHeader.BorderSizePixel = 0
resultsHeader.ZIndex = 2
resultsHeader.Parent = resultsFrame

local logoHeader = Instance.new("TextLabel")
logoHeader.Size = UDim2.new(0, 100, 1, 0)
logoHeader.Position = UDim2.new(0, 30, 0, 0)
logoHeader.BackgroundTransparency = 1
logoHeader.Text = "Roogle"
logoHeader.Font = Enum.Font.GothamBold
logoHeader.TextSize = 30
logoHeader.TextColor3 = Color3.fromRGB(66, 133, 244)
logoHeader.TextXAlignment = Enum.TextXAlignment.Left
logoHeader.Parent = resultsHeader

local searchContainerHeader = searchContainer:Clone()
searchContainerHeader.Size = UDim2.new(0, 500, 0, 40)
searchContainerHeader.Position = UDim2.new(0, 150, 0.5, -20)
searchContainerHeader.Parent = resultsHeader

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
articlePadding.PaddingLeft = UDim.new(0, 150)
articlePadding.PaddingRight = UDim.new(0, 150)
articlePadding.PaddingTop = UDim.new(0, 40)
articlePadding.PaddingBottom = UDim.new(0, 40)
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
loadingLabel.Text = "Publicando artículo..."
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextSize = 28
loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingLabel.Parent = loadingPanel

-- ========== PANEL DE ADMINISTRADOR ==========
if isAdmin then
    local adminButton = Instance.new("TextButton")
    adminButton.Name = "AdminButton"
    adminButton.Size = UDim2.new(0, 120, 0, 35)
    adminButton.Position = UDim2.new(1, -15, 0, 15)
    adminButton.AnchorPoint = Vector2.new(1, 0)
    adminButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
    adminButton.Text = "✏ Publicar"
    adminButton.Font = Enum.Font.GothamBold
    adminButton.TextSize = 16
    adminButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    adminButton.BorderSizePixel = 0
    adminButton.ZIndex = 5
    adminButton.Parent = mainFrame

    local adminCorner = Instance.new("UICorner")
    adminCorner.CornerRadius = UDim.new(0, 8)
    adminCorner.Parent = adminButton

    -- PANEL DE PUBLICACIÓN
    local publishPanel = Instance.new("Frame")
    publishPanel.Name = "PublishPanel"
    publishPanel.Size = UDim2.new(1, 0, 1, 0)
    publishPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    publishPanel.BackgroundTransparency = 0.5
    publishPanel.BorderSizePixel = 0
    publishPanel.Visible = false
    publishPanel.ZIndex = 10
    publishPanel.Parent = mainFrame

    -- Contenedor del formulario
    local formContainer = Instance.new("Frame")
    formContainer.Size = UDim2.new(0, 700, 0, 600)
    formContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    formContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    formContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    formContainer.BorderSizePixel = 0
    formContainer.ZIndex = 11
    formContainer.Parent = publishPanel

    local formCorner = Instance.new("UICorner")
    formCorner.CornerRadius = UDim.new(0, 12)
    formCorner.Parent = formContainer

    -- Título del panel
    local publishTitle = Instance.new("TextLabel")
    publishTitle.Size = UDim2.new(1, -100, 0, 40)
    publishTitle.Position = UDim2.new(0, 30, 0, 20)
    publishTitle.BackgroundTransparency = 1
    publishTitle.Text = "✏ PUBLICAR NUEVO ARTÍCULO"
    publishTitle.Font = Enum.Font.GothamBold
    publishTitle.TextSize = 24
    publishTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    publishTitle.TextXAlignment = Enum.TextXAlignment.Left
    publishTitle.ZIndex = 12
    publishTitle.Parent = formContainer

    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -20, 0, 20)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = Color3.fromRGB(100, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.ZIndex = 12
    closeButton.Parent = formContainer

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton

    -- Etiqueta Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 25)
    titleLabel.Position = UDim2.new(0, 30, 0, 80)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "📝 Título del artículo"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 12
    titleLabel.Parent = formContainer

    -- Campo Título
    local titleInput = Instance.new("TextBox")
    titleInput.Name = "TitleInput"
    titleInput.Size = UDim2.new(1, -60, 0, 45)
    titleInput.Position = UDim2.new(0, 30, 0, 110)
    titleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    titleInput.Text = ""
    titleInput.PlaceholderText = "Escribe el título del artículo..."
    titleInput.Font = Enum.Font.Gotham
    titleInput.TextSize = 16
    titleInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleInput.TextXAlignment = Enum.TextXAlignment.Left
    titleInput.ClearTextOnFocus = false
    titleInput.BorderSizePixel = 0
    titleInput.ZIndex = 12
    titleInput.Parent = formContainer

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleInput

    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 15)
    titlePadding.Parent = titleInput

    -- Etiqueta Contenido
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -60, 0, 25)
    contentLabel.Position = UDim2.new(0, 30, 0, 170)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = "📄 Contenido del artículo"
    contentLabel.Font = Enum.Font.GothamBold
    contentLabel.TextSize = 16
    contentLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.ZIndex = 12
    contentLabel.Parent = formContainer

    -- Campo Contenido
    local contentInput = Instance.new("TextBox")
    contentInput.Name = "ContentInput"
    contentInput.Size = UDim2.new(1, -60, 0, 280)
    contentInput.Position = UDim2.new(0, 30, 0, 200)
    contentInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    contentInput.Text = ""
    contentInput.PlaceholderText = "Escribe el contenido completo del artículo..."
    contentInput.Font = Enum.Font.Gotham
    contentInput.TextSize = 16
    contentInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    contentInput.TextXAlignment = Enum.TextXAlignment.Left
    contentInput.TextYAlignment = Enum.TextYAlignment.Top
    contentInput.ClearTextOnFocus = false
    contentInput.MultiLine = true
    contentInput.TextWrapped = true
    contentInput.BorderSizePixel = 0
    contentInput.ZIndex = 12
    contentInput.Parent = formContainer

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentInput

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.Parent = contentInput

    -- Botón publicar
    local publishButton = Instance.new("TextButton")
    publishButton.Name = "PublishArticleButton"
    publishButton.Size = UDim2.new(1, -60, 0, 50)
    publishButton.Position = UDim2.new(0, 30, 0, 500)
    publishButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
    publishButton.Text = "✓ Publicar Artículo"
    publishButton.Font = Enum.Font.GothamBold
    publishButton.TextSize = 18
    publishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    publishButton.BorderSizePixel = 0
    publishButton.ZIndex = 12
    publishButton.Parent = formContainer

    local pubCorner = Instance.new("UICorner")
    pubCorner.CornerRadius = UDim.new(0, 8)
    pubCorner.Parent = publishButton

    -- EVENTOS DE PUBLICACIÓN
    adminButton.MouseButton1Click:Connect(function()
        publishPanel.Visible = true
        titleInput.Text = ""
        contentInput.Text = ""
    end)

    closeButton.MouseButton1Click:Connect(function()
        publishPanel.Visible = false
    end)

    publishButton.MouseButton1Click:Connect(function()
        local title = titleInput.Text
        local content = contentInput.Text

        if title ~= "" and content ~= "" then
            loadingPanel.Visible = true
            publishPanel.Visible = false

            local success, result = pcall(function()
                return publishArticleFunction:InvokeServer(title, content)
            end)

            loadingPanel.Visible = false

            if success and result == true then
                print("✓ Artículo publicado exitosamente")
                loadArticles("")
            else
                warn("✗ Error al publicar:", result)
            end
        else
            warn("⚠ Por favor completa todos los campos")
        end
    end)
end

-- ========== FUNCIONES ==========

local function setInterfaceView(viewName)
    centerContainer.Visible = (viewName == "home")
    resultsFrame.Visible = (viewName == "results")
    articleViewFrame.Visible = (viewName == "article")
end

local function showArticle(articleId)
    local article = getArticleByIdEvent:InvokeServer(articleId)
    
    if not article then
        warn("Artículo no encontrado")
        return
    end
    
    for _, child in ipairs(articleViewFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            if child.Name ~= "BackButton" then
                child:Destroy()
            end
        end
    end
    
    -- Título del artículo
    local articleTitle = Instance.new("TextLabel")
    articleTitle.Size = UDim2.new(1, 0, 0, 0)
    articleTitle.BackgroundTransparency = 1
    articleTitle.Text = article.title
    articleTitle.Font = Enum.Font.GothamBold
    articleTitle.TextSize = 36
    articleTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    articleTitle.TextXAlignment = Enum.TextXAlignment.Left
    articleTitle.TextYAlignment = Enum.TextYAlignment.Top
    articleTitle.TextWrapped = true
    articleTitle.LayoutOrder = 2
    articleTitle.Parent = articleViewFrame
    articleTitle.Size = UDim2.new(1, 0, 0, articleTitle.TextBounds.Y + 10)
    
    -- Información del autor
    local authorContainer = Instance.new("Frame")
    authorContainer.Size = UDim2.new(1, 0, 0, 60)
    authorContainer.BackgroundTransparency = 1
    authorContainer.LayoutOrder = 3
    authorContainer.Parent = articleViewFrame
    
    local authorLayout = Instance.new("UIListLayout")
    authorLayout.FillDirection = Enum.FillDirection.Horizontal
    authorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    authorLayout.Padding = UDim.new(0, 15)
    authorLayout.Parent = authorContainer
    
    local authorImage = Instance.new("ImageLabel")
    authorImage.Size = UDim2.new(0, 50, 0, 50)
    authorImage.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    authorImage.Image = article.authorThumbnail
    authorImage.Parent = authorContainer
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(1, 0)
    imageCorner.Parent = authorImage
    
    local authorInfo = Instance.new("Frame")
    authorInfo.Size = UDim2.new(0, 300, 1, 0)
    authorInfo.BackgroundTransparency = 1
    authorInfo.Parent = authorContainer
    
    local authorInfoLayout = Instance.new("UIListLayout")
    authorInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    authorInfoLayout.Padding = UDim.new(0, 2)
    authorInfoLayout.Parent = authorInfo
    
    local authorName = Instance.new("TextLabel")
    authorName.Size = UDim2.new(1, 0, 0, 20)
    authorName.BackgroundTransparency = 1
    authorName.Text = "Por " .. article.author
    authorName.Font = Enum.Font.GothamBold
    authorName.TextSize = 16
    authorName.TextColor3 = Color3.fromRGB(60, 60, 60)
    authorName.TextXAlignment = Enum.TextXAlignment.Left
    authorName.LayoutOrder = 1
    authorName.Parent = authorInfo
    
    local articleDate = Instance.new("TextLabel")
    articleDate.Size = UDim2.new(1, 0, 0, 18)
    articleDate.BackgroundTransparency = 1
    articleDate.Text = article.dateCreated
    articleDate.Font = Enum.Font.Gotham
    articleDate.TextSize = 14
    articleDate.TextColor3 = Color3.fromRGB(120, 120, 120)
    articleDate.TextXAlignment = Enum.TextXAlignment.Left
    articleDate.LayoutOrder = 2
    articleDate.Parent = authorInfo
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 2)
    divider.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    divider.BorderSizePixel = 0
    divider.LayoutOrder = 4
    divider.Parent = articleViewFrame
    
    local articleContent = Instance.new("TextLabel")
    articleContent.Size = UDim2.new(1, 0, 0, 0)
    articleContent.BackgroundTransparency = 1
    articleContent.Text = article.content
    articleContent.Font = Enum.Font.Gotham
    articleContent.TextSize = 18
    articleContent.TextColor3 = Color3.fromRGB(60, 60, 60)
    articleContent.TextXAlignment = Enum.TextXAlignment.Left
    articleContent.TextYAlignment = Enum.TextYAlignment.Top
    articleContent.TextWrapped = true
    articleContent.LayoutOrder = 5
    articleContent.Parent = articleViewFrame
    articleContent.Size = UDim2.new(1, 0, 0, articleContent.TextBounds.Y + 20)
    
    task.wait(0.1)
    articleViewFrame.CanvasSize = UDim2.new(0, 0, 0, articleLayout.AbsoluteContentSize.Y + 80)
    
    setInterfaceView("article")
end

function loadArticles(query)
    for _, child in ipairs(resultsFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ArticleFrame" then
            child:Destroy()
        end
    end

    if not query or query == "" then
        setInterfaceView("home")
    else
        setInterfaceView("results")
        searchContainerHeader:FindFirstChild("SearchBox").Text = query
    end

    local articles = getArticlesEvent:InvokeServer(query)

    if #articles == 0 then
        local noResults = Instance.new("TextLabel")
        noResults.Size = UDim2.new(1, 0, 0, 100)
        noResults.BackgroundTransparency = 1
        noResults.Text = 'No se encontraron resultados para: "' .. query .. '"'
        noResults.Font = Enum.Font.Gotham
        noResults.TextSize = 20
        noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
        noResults.LayoutOrder = 100
        noResults.Parent = resultsFrame
    else
        for i, article in ipairs(articles) do
            local articleFrame = Instance.new("Frame")
            articleFrame.Name = "ArticleFrame"
            articleFrame.Size = UDim2.new(1, 0, 0, 140)
            articleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            articleFrame.BorderSizePixel = 0
            articleFrame.LayoutOrder = i + 1
            articleFrame.Parent = resultsFrame

            local authorThumb = Instance.new("ImageLabel")
            authorThumb.Size = UDim2.new(0, 60, 0, 60)
            authorThumb.Position = UDim2.new(0, 0, 0, 10)
            authorThumb.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            authorThumb.Image = article.authorThumbnail
            authorThumb.Parent = articleFrame

            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0)
            thumbCorner.Parent = authorThumb

            local articleTitle = Instance.new("TextButton")
            articleTitle.Size = UDim2.new(1, -80, 0, 30)
            articleTitle.Position = UDim2.new(0, 75, 0, 5)
            articleTitle.BackgroundTransparency = 1
            articleTitle.Text = article.title
            articleTitle.Font = Enum.Font.GothamBold
            articleTitle.TextSize = 22
            articleTitle.TextColor3 = Color3.fromRGB(26, 13, 171)
            articleTitle.TextXAlignment = Enum.TextXAlignment.Left
            articleTitle.TextTruncate = Enum.TextTruncate.AtEnd
            articleTitle.Parent = articleFrame

            local articleDesc = Instance.new("TextLabel")
            articleDesc.Size = UDim2.new(1, -80, 0, 60)
            articleDesc.Position = UDim2.new(0, 75, 0, 40)
            articleDesc.BackgroundTransparency = 1
            articleDesc.Text = article.description
            articleDesc.Font = Enum.Font.Gotham
            articleDesc.TextSize = 16
            articleDesc.TextColor3 = Color3.fromRGB(60, 60, 60)
            articleDesc.TextXAlignment = Enum.TextXAlignment.Left
            articleDesc.TextYAlignment = Enum.TextYAlignment.Top
            articleDesc.TextWrapped = true
            articleDesc.Parent = articleFrame

            local articleAuthor = Instance.new("TextLabel")
            articleAuthor.Size = UDim2.new(1, -80, 0, 20)
            articleAuthor.Position = UDim2.new(0, 75, 1, -25)
            articleAuthor.BackgroundTransparency = 1
            articleAuthor.Text = "Por " .. article.author .. " • " .. article.dateCreated
            articleAuthor.Font = Enum.Font.Gotham
            articleAuthor.TextSize = 14
            articleAuthor.TextColor3 = Color3.fromRGB(120, 120, 120)
            articleAuthor.TextXAlignment = Enum.TextXAlignment.Left
            articleAuthor.Parent = articleFrame

            articleTitle.MouseButton1Click:Connect(function()
                showArticle(article.id)
            end)
        end
    end

    resultsFrame.CanvasSize = UDim2.new(0, 0, 0, resultsLayout.AbsoluteContentSize.Y + 60)
end

local function runSearch(inputBox)
    local query = inputBox.Text
    loadArticles(query)
end

-- EVENTOS DE BÚSQUEDA
searchButton.MouseButton1Click:Connect(function()
    runSearch(searchBox)
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        runSearch(searchBox)
    end
end)

local headerSearchBox = searchContainerHeader:FindFirstChild("SearchBox")
local headerSearchButton = searchContainerHeader:FindFirstChildOfClass("TextButton")

if headerSearchButton then
    headerSearchButton.MouseButton1Click:Connect(function()
        runSearch(headerSearchBox)
    end)
end

if headerSearchBox then
    headerSearchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            runSearch(headerSearchBox)
        end
    end)
end

backButton.MouseButton1Click:Connect(function()
    setInterfaceView("results")
end)

loadArticles("")

print("✓ Roogle cargado exitosamente")
print("✓ Interfaz lista para usar")

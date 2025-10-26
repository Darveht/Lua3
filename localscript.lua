-- LocalScript: Coloca esto en StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los remotes estén listos
local remoteFolder = ReplicatedStorage:WaitForChild("RoogleRemotes")
local getArticlesEvent = remoteFolder:WaitForChild("GetArticles")
-- ¡IMPORTANTE! Ahora usamos InvokeServer para la publicación para esperar la respuesta del servidor.
local publishArticleFunction = remoteFolder:WaitForChild("PublishArticle") 
local checkAdminEvent = remoteFolder:WaitForChild("CheckAdmin")

-- Verificar si es admin
local isAdmin = checkAdminEvent:InvokeServer()

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoogleGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Contenedor principal de la GUI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- CONTENEDOR CENTRAL DE BÚSQUEDA (Vista de inicio)
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

-- Barra de búsqueda contenedor
local searchContainer = Instance.new("Frame")
searchContainer.Name = "SearchContainer"
searchContainer.Size = UDim2.new(1, 0, 0, 50)
searchContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchContainer.BorderSizePixel = 0
searchContainer.LayoutOrder = 2
searchContainer.Parent = centerContainer

local searchListLayout = Instance.new("UIListLayout")
searchListLayout.FillDirection = Enum.FillDirection.Horizontal
searchListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
searchListLayout.Parent = searchContainer

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 25)
searchCorner.Parent = searchContainer

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Color3.fromRGB(200, 200, 200)
searchStroke.Thickness = 1
searchStroke.Parent = searchContainer

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 40, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = 24
searchIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
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


-- CONTENEDOR DE RESULTADOS (Vista de resultados)
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Name = "ResultsFrame"
resultsFrame.Size = UDim2.new(1, 0, 1, 0)
resultsFrame.Position = UDim2.new(0, 0, 0, 0)
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

-- HEADER DENTRO DEL FRAME DE RESULTADOS
local resultsHeader = Instance.new("Frame")
resultsHeader.Size = UDim2.new(1, 0, 0, 80)
resultsHeader.Position = UDim2.new(0, 0, 0, 0)
resultsHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resultsHeader.BorderSizePixel = 0
resultsHeader.ZIndex = 2
resultsHeader.Parent = resultsFrame

local logoHeader = logo:Clone()
logoHeader.Size = UDim2.new(0, 100, 1, 0)
logoHeader.TextSize = 30
logoHeader.Position = UDim2.new(0, 30, 0, 0)
logoHeader.TextXAlignment = Enum.TextXAlignment.Left
logoHeader.Parent = resultsHeader

local searchContainerHeader = searchContainer:Clone()
searchContainerHeader.Size = UDim2.new(0, 500, 0, 40)
searchContainerHeader.Position = UDim2.new(0, 150, 0.5, -20)
searchContainerHeader.Parent = resultsHeader
searchContainerHeader:WaitForChild("SearchBox").TextSize = 16


-- PANEL DE CARGA (Para publicación en tiempo real)
local loadingPanel = Instance.new("Frame")
loadingPanel.Size = UDim2.new(1, 0, 1, 0)
loadingPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingPanel.BackgroundTransparency = 0.8
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


-- Lógica y UI para el Administrador
if isAdmin then
    local adminButton = Instance.new("TextButton")
    adminButton.Name = "AdminButton"
    adminButton.Size = UDim2.new(0, 120, 0, 35)
    adminButton.Position = UDim2.new(1, -15, 0, 15)
    adminButton.AnchorPoint = Vector2.new(1, 0)
    adminButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
    adminButton.Text = "Publicar"
    adminButton.Font = Enum.Font.GothamBold
    adminButton.TextSize = 16
    adminButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    adminButton.BorderSizePixel = 0
    adminButton.ZIndex = 5
    adminButton.Parent = mainFrame

    local adminCorner = Instance.new("UICorner")
    adminCorner.CornerRadius = UDim.new(0, 8)
    adminCorner.Parent = adminButton

    -- PANEL DE PUBLICACIÓN (A pantalla completa y con campos visibles)
    local publishPanel = Instance.new("Frame")
    publishPanel.Size = UDim2.new(1, 0, 1, 0)
    publishPanel.Position = UDim2.new(0, 0, 0, 0)
    publishPanel.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    publishPanel.BorderSizePixel = 0
    publishPanel.Visible = false
    publishPanel.ZIndex = 10
    publishPanel.Parent = mainFrame

    -- Contenedor interior para centrar y limitar el ancho del formulario
    local formContainer = Instance.new("Frame")
    formContainer.Size = UDim2.new(0.8, 0, 0.9, 0)
    formContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    formContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    formContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    formContainer.BorderSizePixel = 0
    formContainer.Parent = publishPanel

    local formCorner = Instance.new("UICorner")
    formCorner.CornerRadius = UDim.new(0, 12)
    formCorner.Parent = formContainer

    local formStroke = Instance.new("UIStroke")
    formStroke.Color = Color3.fromRGB(200, 200, 200)
    formStroke.Thickness = 2
    formStroke.Parent = formContainer


    -- UILISTLAYOUT para organizar los inputs verticalmente
    local pubListLayout = Instance.new("UIListLayout")
    pubListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pubListLayout.Padding = UDim.new(0, 10)
    pubListLayout.Parent = formContainer
    
    local pubPadding = Instance.new("UIPadding")
    pubPadding.PaddingTop = UDim.new(0, 60) 
    pubPadding.PaddingBottom = UDim.new(0, 10)
    pubPadding.PaddingLeft = UDim.new(0, 20)
    pubPadding.PaddingRight = UDim.new(0, 20)
    pubPadding.Parent = formContainer


    -- Título del panel (Flotante)
    local publishTitle = Instance.new("TextLabel")
    publishTitle.Size = UDim2.new(0.6, 0, 0, 30)
    publishTitle.Position = UDim2.new(0, 20, 0, 15)
    publishTitle.BackgroundTransparency = 1
    publishTitle.Text = "PUBLICACIÓN DE ARTÍCULO"
    publishTitle.Font = Enum.Font.GothamBold
    publishTitle.TextSize = 24
    publishTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    publishTitle.TextXAlignment = Enum.TextXAlignment.Left
    publishTitle.ZIndex = 11
    publishTitle.Parent = formContainer

    -- Botón cerrar (Flotante)
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -15, 0, 15)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = Color3.fromRGB(100, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.ZIndex = 11
    closeButton.Parent = formContainer

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton

    -- Input Título - ETIQUETA (Visible)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20) -- Altura fija 20px
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Título del artículo"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 1
    titleLabel.Parent = formContainer

    -- Input Título - CAJA DE TEXTO (Visible)
    local titleInput = Instance.new("TextBox")
    titleInput.Name = "TitleInput" 
    titleInput.Size = UDim2.new(1, 0, 0, 40) -- Altura fija 40px
    titleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    titleInput.Text = ""
    titleInput.PlaceholderText = "Escribe el título aquí..."
    titleInput.Font = Enum.Font.Gotham
    titleInput.TextSize = 16
    titleInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleInput.TextXAlignment = Enum.TextXAlignment.Left
    titleInput.ClearTextOnFocus = false
    titleInput.BorderSizePixel = 0
    titleInput.LayoutOrder = 2
    titleInput.Parent = formContainer

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleInput

    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 15)
    titlePadding.Parent = titleInput

    -- Input Descripción - ETIQUETA (Visible)
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20) -- Altura fija 20px
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Descripción / Contenido"
    descLabel.Font = Enum.Font.GothamBold
    descLabel.TextSize = 16
    descLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.LayoutOrder = 3
    descLabel.Parent = formContainer

    -- Input Descripción - CONTENEDOR GRANDE (Garantizando visibilidad)
    local descInputContainer = Instance.new("Frame")
    descInputContainer.Size = UDim2.new(1, 0, 0, 300) -- Altura fija 300px
    descInputContainer.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    descInputContainer.BorderSizePixel = 0
    descInputContainer.LayoutOrder = 4
    descInputContainer.Parent = formContainer
    
    local descCorner = Instance.new("UICorner")
    descCorner.CornerRadius = UDim.new(0, 8)
    descCorner.Parent = descInputContainer
    
    local descInput = Instance.new("TextBox")
    descInput.Name = "DescriptionInput"
    descInput.Size = UDim2.new(1, 0, 1, 0) -- Rellena el contenedor
    descInput.BackgroundTransparency = 1
    descInput.Text = ""
    descInput.PlaceholderText = "Escribe la descripción del artículo..."
    descInput.Font = Enum.Font.Gotham
    descInput.TextSize = 16
    descInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    descInput.TextXAlignment = Enum.TextXAlignment.Left
    descInput.TextYAlignment = Enum.TextYAlignment.Top
    descInput.ClearTextOnFocus = false
    descInput.MultiLine = true
    descInput.TextWrapped = true
    descInput.BorderSizePixel = 0
    descInput.Parent = descInputContainer

    local descPadding = Instance.new("UIPadding")
    descPadding.PaddingLeft = UDim.new(0, 15)
    descPadding.PaddingTop = UDim.new(0, 10)
    descPadding.Parent = descInput
    
    -- Botón publicar 
    local publishButton = Instance.new("TextButton")
    publishButton.Name = "PublishArticleButton"
    publishButton.Size = UDim2.new(0, 180, 0, 45)
    publishButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
    publishButton.Text = "Publicar Artículo"
    publishButton.Font = Enum.Font.GothamBold
    publishButton.TextSize = 18
    publishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    publishButton.BorderSizePixel = 0
    publishButton.ZIndex = 11
    publishButton.LayoutOrder = 5
    publishButton.Parent = formContainer

    local pubCorner = Instance.new("UICorner")
    pubCorner.CornerRadius = UDim.new(0, 8)
    pubCorner.Parent = publishButton
    
    local pubLayoutProperties = Instance.new("UIListLayout")
    pubLayoutProperties.FillDirection = Enum.FillDirection.Horizontal
    pubLayoutProperties.HorizontalAlignment = Enum.HorizontalAlignment.Right
    pubLayoutProperties.Parent = publishButton.Parent
    
    -- Eventos de publicación
    adminButton.MouseButton1Click:Connect(function()
        publishPanel.Visible = true
        titleInput.Text = ""
        descInput.Text = ""
    end)

    closeButton.MouseButton1Click:Connect(function()
        publishPanel.Visible = false
    end)

    publishButton.MouseButton1Click:Connect(function()
        local title = titleInput.Text
        local desc = descInput.Text
        
        if title ~= "" and desc ~= "" then
            -- 1. Mostrar la animación de carga
            loadingPanel.Visible = true
            publishPanel.Visible = false
            
            -- 2. Invocar al servidor y esperar la respuesta (InvokeServer)
            local success, result = pcall(function()
                return publishArticleFunction:InvokeServer(title, desc)
            end)
            
            -- 3. Ocultar la animación de carga
            loadingPanel.Visible = false

            if success and result == true then
                print("Publicación exitosa!")
                -- 4. Recargar los artículos para mostrar el nuevo contenido en tiempo real
                loadArticles("") 
            else
                warn("Error al publicar el artículo:", result)
                -- Opcional: Mostrar un mensaje de error al usuario
                loadingLabel.Text = "Error al publicar. Revisa el servidor."
                task.wait(2)
                loadingLabel.Text = "Publicando artículo..."
            end
        end
    end)
end

-- Función para cambiar la vista de interfaz
local function setInterfaceView(viewName)
    if viewName == "home" then
        centerContainer.Visible = true
        resultsFrame.Visible = false
    elseif viewName == "results" then
        centerContainer.Visible = false
        resultsFrame.Visible = true
    end
end

-- Función para cargar artículos
local function loadArticles(query)
    -- Limpiar resultados anteriores
    for _, child in ipairs(resultsLayout:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ArticleFrame" then
            child:Destroy()
        end
    end

    if not query or query == "" then
        setInterfaceView("home")
    else
        setInterfaceView("results")
        
        searchContainerHeader:WaitForChild("SearchBox").Text = query

        local articles = getArticlesEvent:InvokeServer(query)

        if #articles == 0 then
            local noResults = Instance.new("TextLabel")
            noResults.Size = UDim2.new(1, 0, 0, 100)
            noResults.BackgroundTransparency = 1
            noResults.Text = "No se encontraron resultados para: \"" .. query .. "\""
            noResults.Font = Enum.Font.Gotham
            noResults.TextSize = 20
            noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
            noResults.LayoutOrder = 100
            noResults.Parent = resultsFrame
        else
            for i, article in ipairs(articles) do
                local articleFrame = Instance.new("Frame")
                articleFrame.Name = "ArticleFrame"
                articleFrame.Size = UDim2.new(1, 0, 0, 120)
                articleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                articleFrame.BorderSizePixel = 0
                articleFrame.LayoutOrder = i + 1
                articleFrame.Parent = resultsFrame
                
                -- ... creación de elementos de artículo (título, descripción, autor) ...
                local articleTitle = Instance.new("TextLabel")
                articleTitle.Size = UDim2.new(1, 0, 0, 30)
                articleTitle.Position = UDim2.new(0, 0, 0, 0)
                articleTitle.BackgroundTransparency = 1
                articleTitle.Text = article.title
                articleTitle.Font = Enum.Font.GothamBold
                articleTitle.TextSize = 22
                articleTitle.TextColor3 = Color3.fromRGB(26, 13, 171)
                articleTitle.TextXAlignment = Enum.TextXAlignment.Left
                articleTitle.TextTruncate = Enum.TextTruncate.AtEnd
                articleTitle.Parent = articleFrame
                
                local articleDesc = Instance.new("TextLabel")
                articleDesc.Size = UDim2.new(1, 0, 0, 60)
                articleDesc.Position = UDim2.new(0, 0, 0, 35)
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
                articleAuthor.Size = UDim2.new(1, 0, 0, 20)
                articleAuthor.Position = UDim2.new(0, 0, 1, -20)
                articleAuthor.BackgroundTransparency = 1
                articleAuthor.Text = "Por " .. article.author
                articleAuthor.Font = Enum.Font.Gotham
                articleAuthor.TextSize = 14
                articleAuthor.TextColor3 = Color3.fromRGB(120, 120, 120)
                articleAuthor.TextXAlignment = Enum.TextXAlignment.Left
                articleAuthor.Parent = articleFrame
            end
        end

        resultsFrame.CanvasSize = UDim2.new(0, 0, 0, resultsLayout.AbsoluteContentSize.Y + 60)
    end
end

local function runSearch(inputBox)
    local query = inputBox.Text
    loadArticles(query)
    if inputBox == searchBox and resultsFrame.Visible then
        searchContainerHeader:WaitForChild("SearchBox").Text = query
    elseif inputBox ~= searchBox and not resultsFrame.Visible then
        searchBox.Text = query
    end
end

searchButton.MouseButton1Click:Connect(function() runSearch(searchBox) end)
searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then runSearch(searchBox) end
end)

if resultsHeader then
    local headerSearchBox = searchContainerHeader:WaitForChild("SearchBox")
    local headerSearchButton = searchContainerHeader:WaitForChild("TextButton")

    headerSearchButton.MouseButton1Click:Connect(function() runSearch(headerSearchBox) end)
    headerSearchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then runSearch(headerSearchBox) end
    end)
end

loadArticles("")

print("Roogle Local cargado correctamente con publicación en tiempo real y campos visibles.")


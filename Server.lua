
-- ServerScript: Coloca esto en ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- BASE DE DATOS EN MEMORIA
local articlesDatabase = {}

-- Función para generar ID único
local function generateId()
    return HttpService:GenerateGUID(false)
end

-- Función para obtener thumbnail del jugador
local function getPlayerThumbnail(userId)
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size150x150
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    return content
end

-- CREAR REMOTES SI NO EXISTEN (automático)
local remoteFolder = ReplicatedStorage:FindFirstChild("RoogleRemotes")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "RoogleRemotes"
    remoteFolder.Parent = ReplicatedStorage
end

local function createRemote(name, className)
    local remote = remoteFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new(className)
        remote.Name = name
        remote.Parent = remoteFolder
    end
    return remote
end

-- Crear todos los remotes automáticamente
local getArticlesEvent = createRemote("GetArticles", "RemoteFunction")
local publishArticleFunction = createRemote("PublishArticle", "RemoteFunction")
local checkAdminEvent = createRemote("CheckAdmin", "RemoteFunction")
local getArticleByIdEvent = createRemote("GetArticleById", "RemoteFunction")

-- FUNCIONES DEL SERVIDOR

-- PUBLICAR ARTÍCULO
publishArticleFunction.OnServerInvoke = function(player, title, description)
    print(string.format("[%s] Publicando artículo: %s", player.Name, title))
    
    task.wait(0.5)
    
    local newArticle = {
        id = generateId(),
        title = title,
        description = description,
        content = description,
        author = player.Name,
        authorId = player.UserId,
        authorThumbnail = getPlayerThumbnail(player.UserId),
        timestamp = os.time(),
        dateCreated = os.date("%d/%m/%Y %H:%M")
    }
    
    table.insert(articlesDatabase, 1, newArticle)
    
    print(string.format("[SERVER] Artículo '%s' guardado. Total: %d", title, #articlesDatabase))
    
    return true
end

-- OBTENER ARTÍCULOS
getArticlesEvent.OnServerInvoke = function(player, query)
    print(string.format("[%s] Buscando: '%s'", player.Name, query or ""))
    
    if not query or query == "" then
        return articlesDatabase
    end
    
    local results = {}
    local queryLower = string.lower(query)
    
    for _, article in ipairs(articlesDatabase) do
        local titleLower = string.lower(article.title)
        local descLower = string.lower(article.description)
        
        if string.find(titleLower, queryLower) or string.find(descLower, queryLower) then
            table.insert(results, article)
        end
    end
    
    print(string.format("[SERVER] Encontrados %d resultados", #results))
    return results
end

-- OBTENER ARTÍCULO POR ID
getArticleByIdEvent.OnServerInvoke = function(player, articleId)
    for _, article in ipairs(articlesDatabase) do
        if article.id == articleId then
            return article
        end
    end
    return nil
end

-- VERIFICAR ADMIN (todos son admin en esta versión)
checkAdminEvent.OnServerInvoke = function(player)
    return true
end

-- ARTÍCULOS DE EJEMPLO
table.insert(articlesDatabase, {
    id = generateId(),
    title = "Bienvenido a Roogle",
    description = "Roogle es tu motor de búsqueda de artículos. Usa la barra de búsqueda para encontrar contenido interesante.",
    content = "Roogle es tu motor de búsqueda de artículos. Usa la barra de búsqueda para encontrar contenido interesante. Los administradores pueden publicar nuevos artículos usando el botón 'Publicar' en la esquina superior derecha.",
    author = "Sistema",
    authorId = 1,
    authorThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png",
    timestamp = os.time(),
    dateCreated = os.date("%d/%m/%Y %H:%M")
})

table.insert(articlesDatabase, {
    id = generateId(),
    title = "Cómo usar Roogle",
    description = "Aprende a navegar y buscar artículos en Roogle de manera efectiva.",
    content = "Roogle te permite buscar artículos de manera rápida y eficiente. Simplemente escribe palabras clave en la barra de búsqueda y presiona Enter o haz clic en el botón de búsqueda. Puedes hacer clic en cualquier título para ver el artículo completo con todos los detalles.",
    author = "Sistema",
    authorId = 1,
    authorThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png",
    timestamp = os.time() - 3600,
    dateCreated = os.date("%d/%m/%Y %H:%M")
})

print("=== ✓ Roogle Server Iniciado ===")
print("✓ Artículos en base de datos:", #articlesDatabase)
print("✓ RemoteEvents creados automáticamente")
print("✓ Sistema listo para usar")

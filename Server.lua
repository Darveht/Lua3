
-- ServerScript: Coloca esto en ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- BASE DE DATOS EN MEMORIA
local articlesDatabase = {} -- Artículos aprobados
local pendingArticles = {} -- Artículos pendientes de aprobación

-- LISTA DE ADMINISTRADORES
local ADMINS = {
    "Vegetl_t"
}

-- Función para verificar si es admin
local function isAdmin(playerName)
    for _, adminName in ipairs(ADMINS) do
        if adminName == playerName then
            return true
        end
    end
    return false
end

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
local getPendingArticlesEvent = createRemote("GetPendingArticles", "RemoteFunction")
local approveArticleEvent = createRemote("ApproveArticle", "RemoteFunction")
local rejectArticleEvent = createRemote("RejectArticle", "RemoteFunction")

-- FUNCIONES DEL SERVIDOR

-- PUBLICAR ARTÍCULO (ahora va a pendientes)
publishArticleFunction.OnServerInvoke = function(player, title, description)
    print(string.format("[%s] Enviando artículo a revisión: %s", player.Name, title))
    
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
    
    table.insert(pendingArticles, 1, newArticle)
    
    print(string.format("[SERVER] Artículo '%s' enviado a revisión. Pendientes: %d", title, #pendingArticles))
    
    return true
end

-- OBTENER ARTÍCULOS (solo aprobados)
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

-- VERIFICAR ADMIN
checkAdminEvent.OnServerInvoke = function(player)
    return isAdmin(player.Name)
end

-- OBTENER ARTÍCULOS PENDIENTES (solo admins)
getPendingArticlesEvent.OnServerInvoke = function(player)
    if not isAdmin(player.Name) then
        warn("[SERVER] Usuario no autorizado intentó acceder a pendientes:", player.Name)
        return {}
    end
    
    print(string.format("[ADMIN %s] Consultando artículos pendientes: %d", player.Name, #pendingArticles))
    return pendingArticles
end

-- APROBAR ARTÍCULO (solo admins)
approveArticleEvent.OnServerInvoke = function(player, articleId)
    if not isAdmin(player.Name) then
        warn("[SERVER] Usuario no autorizado intentó aprobar:", player.Name)
        return false
    end
    
    for i, article in ipairs(pendingArticles) do
        if article.id == articleId then
            table.remove(pendingArticles, i)
            table.insert(articlesDatabase, 1, article)
            print(string.format("[ADMIN %s] Artículo APROBADO: '%s'", player.Name, article.title))
            return true
        end
    end
    
    return false
end

-- RECHAZAR ARTÍCULO (solo admins)
rejectArticleEvent.OnServerInvoke = function(player, articleId)
    if not isAdmin(player.Name) then
        warn("[SERVER] Usuario no autorizado intentó rechazar:", player.Name)
        return false
    end
    
    for i, article in ipairs(pendingArticles) do
        if article.id == articleId then
            table.remove(pendingArticles, i)
            print(string.format("[ADMIN %s] Artículo RECHAZADO: '%s'", player.Name, article.title))
            return true
        end
    end
    
    return false
end

-- ARTÍCULOS DE EJEMPLO (ya aprobados)
table.insert(articlesDatabase, {
    id = generateId(),
    title = "Bienvenido a Roogle",
    description = "Roogle es tu motor de búsqueda de artículos. Usa la barra de búsqueda para encontrar contenido interesante.",
    content = "Roogle es tu motor de búsqueda de artículos. Usa la barra de búsqueda para encontrar contenido interesante. Cualquier usuario puede publicar artículos que serán revisados por administradores antes de aparecer en las búsquedas.",
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
print("✓ Artículos aprobados:", #articlesDatabase)
print("✓ Artículos pendientes:", #pendingArticles)
print("✓ Administradores:", table.concat(ADMINS, ", "))
print("✓ RemoteEvents creados automáticamente")
print("✓ Sistema listo para usar")

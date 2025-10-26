
-- ServerScript: Coloca esto en ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- BASE DE DATOS EN MEMORIA (simulando Firestore)
-- En producción, esto debería conectarse a una base de datos real
local articlesDatabase = {}

-- CONFIGURACIÓN REMOTA
local remoteFolder = ReplicatedStorage:WaitForChild("RoogleRemotes")
local getArticlesEvent = remoteFolder:WaitForChild("GetArticles")
local publishArticleFunction = remoteFolder:WaitForChild("PublishArticle")
local checkAdminEvent = remoteFolder:WaitForChild("CheckAdmin")
local getArticleByIdEvent = remoteFolder:WaitForChild("GetArticleById")

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

-- PUBLICAR ARTÍCULO (con guardado en tiempo real)
local function handlePublishArticle(player, title, description)
    print(string.format("[%s] Publicando artículo: %s", player.Name, title))
    
    -- Simular latencia de red (puedes ajustar o eliminar)
    task.wait(0.5)
    
    -- Crear nuevo artículo
    local newArticle = {
        id = generateId(),
        title = title,
        description = description,
        content = description, -- El contenido completo es la descripción
        author = player.Name,
        authorId = player.UserId,
        authorThumbnail = getPlayerThumbnail(player.UserId),
        timestamp = os.time(),
        dateCreated = os.date("%d/%m/%Y %H:%M")
    }
    
    -- Guardar en la "base de datos"
    table.insert(articlesDatabase, 1, newArticle) -- Insertar al inicio para que aparezca primero
    
    print(string.format("[SERVER] Artículo '%s' guardado exitosamente. Total artículos: %d", title, #articlesDatabase))
    
    -- Retornar éxito al cliente
    return true
end

-- OBTENER ARTÍCULOS (con búsqueda)
local function handleGetArticles(player, query)
    print(string.format("[%s] Buscando: '%s'", player.Name, query or ""))
    
    -- Si no hay búsqueda, retornar todos los artículos
    if not query or query == "" then
        print(string.format("[SERVER] Retornando %d artículos", #articlesDatabase))
        return articlesDatabase
    end
    
    -- Buscar artículos que coincidan con la consulta
    local results = {}
    local queryLower = string.lower(query)
    
    for _, article in ipairs(articlesDatabase) do
        local titleLower = string.lower(article.title)
        local descLower = string.lower(article.description)
        
        if string.find(titleLower, queryLower) or string.find(descLower, queryLower) then
            table.insert(results, article)
        end
    end
    
    print(string.format("[SERVER] Encontrados %d resultados para '%s'", #results, query))
    return results
end

-- OBTENER ARTÍCULO POR ID (para vista completa)
local function handleGetArticleById(player, articleId)
    print(string.format("[%s] Obteniendo artículo ID: %s", player.Name, articleId))
    
    for _, article in ipairs(articlesDatabase) do
        if article.id == articleId then
            return article
        end
    end
    
    return nil
end

-- VERIFICAR ADMIN
local function handleCheckAdmin(player)
    -- Por ahora todos son admin para pruebas
    -- En producción, verificar con una lista de IDs o grupos
    return true
end

-- CONECTAR EVENTOS
publishArticleFunction.OnServerInvoke = handlePublishArticle
getArticlesEvent.OnServerInvoke = handleGetArticles
checkAdminEvent.OnServerInvoke = handleCheckAdmin
getArticleByIdEvent.OnServerInvoke = handleGetArticleById

-- Crear algunos artículos de ejemplo al iniciar
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

print("=== Roogle Server Iniciado ===")
print("Artículos en base de datos:", #articlesDatabase)
print("Sistema de publicación en tiempo real activo")

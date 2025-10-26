-- ServerScript: Coloca esto en ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

-- DATASTORES PARA PERSISTENCIA
local articlesDataStore = DataStoreService:GetDataStore("RoogleArticlesV2")
local usersDataStore = DataStoreService:GetDataStore("RoogleUsersV2")

-- BASE DE DATOS EN MEMORIA
local articlesDatabase = {} -- TODOS los artículos (activos e inactivos)
local usersDatabase = {} -- Información de usuarios

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

-- Función para cargar datos del DataStore
local function loadData()
    local success, articlesData = pcall(function()
        return articlesDataStore:GetAsync("articles")
    end)
    
    if success and articlesData then
        articlesDatabase = articlesData
        print("[DATASTORE] Cargados", #articlesDatabase, "artículos")
    else
        print("[DATASTORE] No hay artículos guardados, iniciando con datos de ejemplo")
        -- Artículos de ejemplo
        table.insert(articlesDatabase, {
        id = generateId(),
        title = "Bienvenido a Roogle",
        description = "Roogle es tu motor de búsqueda de artículos. Usa la barra de búsqueda para encontrar contenido interesante.",
        content = "Roogle es tu motor de búsqueda de artículos. Usa la barra de búsqueda para encontrar contenido interesante. Cualquier usuario puede publicar artículos que serán revisados por administradores antes de aparecer en las búsquedas.\n\nLos artículos pueden tener cualquier longitud, desde unas pocas palabras hasta miles de palabras. El sistema mostrará todo el contenido completo con scroll automático.",
        author = "Sistema",
        authorId = 1,
        authorThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        timestamp = os.time(),
        dateCreated = os.date("%d/%m/%Y %H:%M"),
        verified = true,
        status = "active" -- active, pending, inactive
        })
        
        table.insert(articlesDatabase, {
        id = generateId(),
        title = "Como usar Roogle",
        description = "Aprende a navegar y buscar artículos en Roogle de manera efectiva.",
        content = "Roogle te permite buscar artículos de manera rápida y eficiente. Simplemente escribe palabras clave en la barra de búsqueda y presiona Enter o haz clic en el botón de búsqueda. Puedes hacer clic en cualquier título para ver el artículo completo con todos los detalles.\n\nAhora también puedes hacer clic en el nombre de cualquier autor para ver su perfil completo, donde encontrarás su foto, seguidores, usuarios que sigue y todos sus artículos publicados.",
        author = "Sistema",
        authorId = 1,
        authorThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        timestamp = os.time() - 3600,
        dateCreated = os.date("%d/%m/%Y %H:%M"),
        verified = true,
        status = "active"
        })
    end
    
    local successUsers, usersData = pcall(function()
        return usersDataStore:GetAsync("users")
    end)
    
    if successUsers and usersData then
        usersDatabase = usersData
        print("[DATASTORE] Cargados", #usersDatabase, "usuarios")
    end
end

-- Función para guardar datos en el DataStore
local function saveData()
    pcall(function()
        articlesDataStore:SetAsync("articles", articlesDatabase)
        usersDataStore:SetAsync("users", usersDatabase)
        print("[DATASTORE] Datos guardados exitosamente")
    end)
end

-- Guardar automáticamente cada 30 segundos
task.spawn(function()
    while true do
        task.wait(30)
        saveData()
    end
end)

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
local getAllArticlesEvent = createRemote("GetAllArticles", "RemoteFunction")
local toggleArticleStatusEvent = createRemote("ToggleArticleStatus", "RemoteFunction")
local getUserProfileEvent = createRemote("GetUserProfile", "RemoteFunction")
local followUserEvent = createRemote("FollowUser", "RemoteFunction")
local unfollowUserEvent = createRemote("UnfollowUser", "RemoteFunction")
local searchUsersEvent = createRemote("SearchUsers", "RemoteFunction")
local verifyUserEvent = createRemote("VerifyUser", "RemoteFunction")
local unverifyUserEvent = createRemote("UnverifyUser", "RemoteFunction")
local getRobloxStatsEvent = createRemote("GetRobloxStats", "RemoteFunction")

-- FUNCIONES DEL SERVIDOR

-- Obtener o crear información de usuario
local function getOrCreateUser(player)
    for _, user in ipairs(usersDatabase) do
        if user.userId == player.UserId then
            return user
        end
    end
    
    -- Crear nuevo usuario
    local newUser = {
    userId = player.UserId,
    username = player.Name,
    thumbnail = getPlayerThumbnail(player.UserId),
    verified = isAdmin(player.Name),
    followers = {},
    following = {},
    articlesPublished = 0
    }
    
    table.insert(usersDatabase, newUser)
    saveData()
    return newUser
end

-- PUBLICAR ARTÍCULO (va con estado pending o active si es Sistema)
publishArticleFunction.OnServerInvoke = function(player, title, description, asSystem)
    print(string.format("[%s] Enviando artículo a revisión: %s", player.Name, title))
    
    task.wait(0.5)
    
    -- Si es admin y marca asSystem, publicar como Sistema
    local isSystemArticle = isAdmin(player.Name) and asSystem
    
    local newArticle = {
    id = generateId(),
    title = title,
    description = description,
    content = description,
    author = isSystemArticle and "Sistema" or player.Name,
    authorId = isSystemArticle and 1 or player.UserId,
    authorThumbnail = isSystemArticle and "rbxasset://textures/ui/GuiImagePlaceholder.png" or getPlayerThumbnail(player.UserId),
    timestamp = os.time(),
    dateCreated = os.date("%d/%m/%Y %H:%M"),
    verified = true,
    status = isSystemArticle and "active" or "pending" -- Sistema se publica directo como activo
    }
    
    table.insert(articlesDatabase, 1, newArticle)
    saveData()
    
    if isSystemArticle then
        print(string.format("[SISTEMA] Anuncio publicado: '%s'", title))
    else
        print(string.format("[SERVER] Artículo '%s' enviado a revisión", title))
    end
    
    return true
end

-- OBTENER ARTÍCULOS (solo activos)
getArticlesEvent.OnServerInvoke = function(player, query)
    print(string.format("[%s] Buscando: '%s'", player.Name, query or ""))
    
    local activeArticles = {}
    for _, article in ipairs(articlesDatabase) do
        if article.status == "active" then
            table.insert(activeArticles, article)
        end
    end
    
    if not query or query == "" then
        return activeArticles
    end
    
    local results = {}
    local queryLower = string.lower(query)
    
    for _, article in ipairs(activeArticles) do
        local titleLower = string.lower(article.title)
        local descLower = string.lower(article.description)
        
        if string.find(titleLower, queryLower) or string.find(descLower, queryLower) then
            table.insert(results, article)
        end
    end
    
    print(string.format("[SERVER] Encontrados %d resultados", #results))
    return results
end

-- OBTENER TODOS LOS ARTÍCULOS (para admin)
getAllArticlesEvent.OnServerInvoke = function(player)
    if not isAdmin(player.Name) then
        return {}
    end
    
    return articlesDatabase
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
    
    local pending = {}
    for _, article in ipairs(articlesDatabase) do
        if article.status == "pending" then
            table.insert(pending, article)
        end
    end
    
    print(string.format("[ADMIN %s] Consultando artículos pendientes: %d", player.Name, #pending))
    return pending
end

-- CAMBIAR ESTADO DE ARTÍCULO (aprobar/desactivar/activar)
toggleArticleStatusEvent.OnServerInvoke = function(player, articleId, newStatus)
    if not isAdmin(player.Name) then
        warn("[SERVER] Usuario no autorizado intentó cambiar estado:", player.Name)
        return false
    end
    
    for _, article in ipairs(articlesDatabase) do
        if article.id == articleId then
            local oldStatus = article.status
            article.status = newStatus
            
            -- Actualizar contador de artículos del usuario solo si se activa por primera vez
            if oldStatus == "pending" and newStatus == "active" then
                for _, user in ipairs(usersDatabase) do
                    if user.userId == article.authorId then
                        user.articlesPublished = (user.articlesPublished or 0) + 1
                        break
                    end
                end
            elseif oldStatus == "active" and newStatus == "inactive" then
                for _, user in ipairs(usersDatabase) do
                    if user.userId == article.authorId then
                        user.articlesPublished = math.max(0, (user.articlesPublished or 0) - 1)
                        break
                    end
                end
            end
            
            saveData()
            print(string.format("[ADMIN %s] Artículo '%s' cambiado a %s", player.Name, article.title, newStatus))
            return true
        end
    end
    
    return false
end

-- OBTENER PERFIL DE USUARIO
getUserProfileEvent.OnServerInvoke = function(player, userId)
    local userInfo = nil
    for _, user in ipairs(usersDatabase) do
        if user.userId == userId then
            userInfo = user
            break
        end
    end
    
    if not userInfo then
        -- Crear usuario si no existe
        local targetPlayer = Players:GetPlayerByUserId(userId)
        if targetPlayer then
            userInfo = getOrCreateUser(targetPlayer)
        else
            -- Crear usuario básico
            local username = Players:GetNameFromUserIdAsync(userId)
            userInfo = {
            userId = userId,
            username = username,
            thumbnail = getPlayerThumbnail(userId),
            verified = isAdmin(username),
            followers = {},
            following = {},
            articlesPublished = 0
            }
            table.insert(usersDatabase, userInfo)
            saveData()
        end
    end
    
    -- Obtener artículos ACTIVOS del usuario
    local userArticles = {}
    for _, article in ipairs(articlesDatabase) do
        if article.authorId == userId and article.status == "active" then
            table.insert(userArticles, article)
        end
    end
    
    return {
    userInfo = userInfo,
    articles = userArticles,
    followersCount = #userInfo.followers,
    followingCount = #userInfo.following,
    isFollowing = table.find(userInfo.followers, player.UserId) ~= nil
    }
end

-- SEGUIR USUARIO
followUserEvent.OnServerInvoke = function(player, targetUserId)
    local currentUser = getOrCreateUser(player)
    local targetUser = nil
    
    for _, user in ipairs(usersDatabase) do
        if user.userId == targetUserId then
            targetUser = user
            break
        end
    end
    
    if not targetUser then
        return false
    end
    
    -- Agregar a siguiendo del usuario actual
    if not table.find(currentUser.following, targetUserId) then
        table.insert(currentUser.following, targetUserId)
    end
    
    -- Agregar a seguidores del usuario objetivo
    if not table.find(targetUser.followers, player.UserId) then
        table.insert(targetUser.followers, player.UserId)
    end
    
    saveData()
    return true
end

-- DEJAR DE SEGUIR USUARIO
unfollowUserEvent.OnServerInvoke = function(player, targetUserId)
    local currentUser = getOrCreateUser(player)
    local targetUser = nil
    
    for _, user in ipairs(usersDatabase) do
        if user.userId == targetUserId then
            targetUser = user
            break
        end
    end
    
    if not targetUser then
        return false
    end
    
    -- Remover de siguiendo del usuario actual
    local followingIndex = table.find(currentUser.following, targetUserId)
    if followingIndex then
        table.remove(currentUser.following, followingIndex)
    end
    
    -- Remover de seguidores del usuario objetivo
    local followerIndex = table.find(targetUser.followers, player.UserId)
    if followerIndex then
        table.remove(targetUser.followers, followerIndex)
    end
    
    saveData()
    return true
end

-- BUSCAR USUARIOS (para panel admin)
searchUsersEvent.OnServerInvoke = function(player, query)
    if not isAdmin(player.Name) then
        return {}
    end
    
    if not query or query == "" then
        return usersDatabase
    end
    
    local results = {}
    local queryLower = string.lower(query)
    
    for _, user in ipairs(usersDatabase) do
        local usernameLower = string.lower(user.username)
        if string.find(usernameLower, queryLower) then
            table.insert(results, user)
        end
    end
    
    return results
end

-- VERIFICAR USUARIO (solo admins)
verifyUserEvent.OnServerInvoke = function(player, targetUserId)
    if not isAdmin(player.Name) then
        return false
    end
    
    for _, user in ipairs(usersDatabase) do
        if user.userId == targetUserId then
            user.verified = true
            
            -- Actualizar verificación en todos sus artículos
            for _, article in ipairs(articlesDatabase) do
                if article.authorId == targetUserId then
                    article.verified = true
                end
            end
            
            saveData()
            print(string.format("[ADMIN %s] Usuario VERIFICADO: %s", player.Name, user.username))
            return true
        end
    end
    
    return false
end

-- DESVERIFICAR USUARIO (solo admins)
unverifyUserEvent.OnServerInvoke = function(player, targetUserId)
    if not isAdmin(player.Name) then
        return false
    end
    
    for _, user in ipairs(usersDatabase) do
        if user.userId == targetUserId then
            user.verified = false
            
            -- Actualizar verificación en todos sus artículos
            for _, article in ipairs(articlesDatabase) do
                if article.authorId == targetUserId then
                    article.verified = false
                end
            end
            
            saveData()
            print(string.format("[ADMIN %s] Usuario DESVERIFICADO: %s", player.Name, user.username))
            return true
        end
    end
    
    return false
end

-- OBTENER ESTADÍSTICAS REALES DE ROBLOX (para el usuario Sistema)
getRobloxStatsEvent.OnServerInvoke = function(player, targetUserId)
    -- Solo para el usuario Sistema (userId = 1)
    if targetUserId ~= 1 then
        return nil
    end
    
    local success, result = pcall(function()
        -- Obtener información del perfil de Roblox en tiempo real
        local userId = 1 -- Roblox (el usuario oficial de Roblox)
        
        -- Intentar obtener datos reales usando Friends API
        local friendsSuccess, friendsCount = pcall(function()
            local friends = Players:GetFriendsAsync(userId)
            local count = 0
            for _ in pairs(friends:GetCurrentPage()) do
                count = count + 1
            end
            while not friends.IsFinished do
                friends:AdvanceToNextPageAsync()
                for _ in pairs(friends:GetCurrentPage()) do
                    count = count + 1
                end
            end
            return count
        end)
        
        -- Si no se pueden obtener datos reales, usar valores predeterminados altos
        local followers = friendsSuccess and friendsCount or 5000000
        local following = 0
        
        return {
        followers = followers,
        following = following,
        isRealData = friendsSuccess
        }
    end)
    
    if success and result then
        return result
    else
        -- Valores predeterminados si falla
        return {
        followers = 5000000,
        following = 0,
        isRealData = false
        }
    end
end

-- Cargar datos al iniciar
loadData()

-- Guardar datos cuando un jugador sale
Players.PlayerRemoving:Connect(function()
    saveData()
end)

-- Guardar datos cuando el servidor se cierra
game:BindToClose(function()
    saveData()
    task.wait(2)
end)

print("=== ✓ Roogle Server Iniciado ===")
print("✓ Artículos totales:", #articlesDatabase)
print("✓ Usuarios registrados:", #usersDatabase)
print("✓ Administradores:", table.concat(ADMINS, ", "))
print("✓ RemoteEvents creados automáticamente")
print("✓ DataStore configurado para persistencia")
print("✓ Sistema de estados implementado (pending/active/inactive)")
print("✓ Sistema listo para usar")


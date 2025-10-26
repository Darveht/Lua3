-- ServerScript: Coloca esto en ServerScriptService
 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
 
-- DATASTORES PARA PERSISTENCIA
local articlesDataStore = DataStoreService:GetDataStore("RoogleArticlesV2")
local usersDataStore = DataStoreService:GetDataStore("RoogleUsersV2")
local bannedUsersDataStore = DataStoreService:GetDataStore("RoogleBannedUsersV2")
local MarketplaceService = game:GetService("MarketplaceService")
 
-- ID del producto de Game Pass para desbaneo (100 Robux)
-- IMPORTANTE: Cambia este número por el ID real de tu Developer Product
local UNBAN_PRODUCT_ID = 3440708349 -- CAMBIAR por el ID del Developer Product que creaste en https://create.roblox.com
 
-- BASE DE DATOS EN MEMORIA
local articlesDatabase = {} -- TODOS los artículos (activos e inactivos)
local usersDatabase = {} -- Información de usuarios
local bannedUsers = {} -- Usuarios baneados {userId, banEndTime, reason}
 
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
        category = "Tutorial",
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
        category = "Tutorial",
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
    
    local successBanned, bannedData = pcall(function()
        return bannedUsersDataStore:GetAsync("banned")
    end)
    
    if successBanned and bannedData then
        bannedUsers = bannedData
        print("[DATASTORE] Cargados", #bannedUsers, "usuarios baneados")
    end
end
 
-- Función para guardar datos en el DataStore
local function saveData()
    pcall(function()
        articlesDataStore:SetAsync("articles", articlesDatabase)
        usersDataStore:SetAsync("users", usersDatabase)
        bannedUsersDataStore:SetAsync("banned", bannedUsers)
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
print("[SERVER] Creando sistema de RemoteEvents...")
local remoteFolder = ReplicatedStorage:FindFirstChild("RoogleRemotes")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "RoogleRemotes"
    remoteFolder.Parent = ReplicatedStorage
    print("[SERVER] ✓ Carpeta RoogleRemotes creada")
else
    print("[SERVER] ✓ Carpeta RoogleRemotes encontrada")
end
 
local function createRemote(name, className)
    local remote = remoteFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new(className)
        remote.Name = name
        remote.Parent = remoteFolder
        print(string.format("[SERVER] ✓ Remote creado: %s (%s)", name, className))
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
local checkBanStatusEvent = createRemote("CheckBanStatus", "RemoteFunction")
local banUserEvent = createRemote("BanUser", "RemoteFunction")
local unbanUserEvent = createRemote("UnbanUser", "RemoteFunction")
local processUnbanPaymentEvent = createRemote("ProcessUnbanPayment", "RemoteFunction")
local publishMusicFunction = createRemote("PublishMusic", "RemoteFunction")
local getMusicEvent = createRemote("GetMusic", "RemoteFunction")
local getPendingMusicEvent = createRemote("GetPendingMusic", "RemoteFunction")
local toggleMusicStatusEvent = createRemote("ToggleMusicStatus", "RemoteFunction")
local getVerifiedUsersEvent = createRemote("GetVerifiedUsers", "RemoteFunction")
local purchaseMusicEvent = createRemote("PurchaseMusic", "RemoteFunction")
 
-- FUNCIONES DEL SERVIDOR
 
-- Función para detectar spam/enlaces en texto
local function containsSpamOrLinks(text)
    local lowerText = string.lower(text)
    
    -- Detectar enlaces (http, https, www, .com, .net, etc)
    local linkPatterns = {
    "http://",
    "https://",
    "www%.",
    "%.com",
    "%.net",
    "%.org",
    "%.gg",
    "discord",
    "bit%.ly",
    "tinyurl"
    }
    
    for _, pattern in ipairs(linkPatterns) do
        if string.find(lowerText, pattern) then
            return true, "enlaces"
        end
    end
    
    -- Detectar palabras de spam comunes
    local spamWords = {
    "compra",
    "gratis",
    "free robux",
    "robux gratis",
    "gana dinero",
    "promocion",
    "descuento",
    "visita mi",
    "suscribete",
    "subscribe",
    "sigueme",
    "follow me"
    }
    
    for _, word in ipairs(spamWords) do
        if string.find(lowerText, word) then
            return true, "spam"
        end
    end
    
    return false
end
 
-- Función para verificar si un usuario está baneado
local function isUserBanned(userId)
    for i, ban in ipairs(bannedUsers) do
        if ban.userId == userId then
            -- Verificar si el baneo ya expiró
            if os.time() >= ban.banEndTime then
                -- Baneo expirado, eliminar
                table.remove(bannedUsers, i)
                saveData()
                return false, nil
            end
            return true, ban
        end
    end
    return false, nil
end
 
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
publishArticleFunction.OnServerInvoke = function(player, title, description, category, asSystem)
    print(string.format("[%s] Enviando artículo a revisión: %s", player.Name, title))
    
    task.wait(0.5)
    
    -- Si es admin y marca asSystem, publicar como Sistema
    local isSystemArticle = isAdmin(player.Name) and asSystem
    
    -- Si NO es admin, verificar spam/enlaces
    if not isAdmin(player.Name) then
        local hasSpam, spamType = containsSpamOrLinks(title .. " " .. description)
        if hasSpam then
            warn(string.format("[SPAM DETECTADO] Usuario %s intentó publicar con %s", player.Name, spamType))
            return false, "Tu artículo contiene contenido prohibido (" .. spamType .. ") y no puede ser publicado."
        end
    end
    
    local newArticle = {
    id = generateId(),
    title = title,
    description = description,
    content = description,
    category = category or "General",
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
    
    -- Si no hay query, devolver TODOS los usuarios ordenados por nombre
    if not query or query == "" then
        local sortedUsers = {}
        for _, user in ipairs(usersDatabase) do
            table.insert(sortedUsers, user)
        end
        -- Ordenar alfabéticamente
        table.sort(sortedUsers, function(a, b)
            return string.lower(a.username) < string.lower(b.username)
        end)
        print(string.format("[ADMIN %s] Mostrando %d usuarios totales", player.Name, #sortedUsers))
        return sortedUsers
    end
    
    -- Si hay query, filtrar por nombre
    local results = {}
    local queryLower = string.lower(query)
    
    for _, user in ipairs(usersDatabase) do
        local usernameLower = string.lower(user.username)
        if string.find(usernameLower, queryLower) then
            table.insert(results, user)
        end
    end
    
    print(string.format("[ADMIN %s] Búsqueda '%s': %d resultados", player.Name, query, #results))
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
    
    -- Siempre retornar 16M de seguidores para el Sistema (como Roblox)
    return {
    followers = 16000000,
    following = 0,
    isRealData = true
    }
end
 
-- VERIFICAR ESTADO DE BANEO (ahora acepta userId opcional para admins)
checkBanStatusEvent.OnServerInvoke = function(player, targetUserId)
    local checkUserId = targetUserId or player.UserId
    local isBanned, banInfo = isUserBanned(checkUserId)
    if isBanned then
        local daysLeft = math.ceil((banInfo.banEndTime - os.time()) / 86400)
        return {
        isBanned = true,
        reason = banInfo.reason,
        daysLeft = daysLeft,
        banEndTime = banInfo.banEndTime,
        userId = checkUserId
        }
    end
    return { isBanned = false, userId = checkUserId }
end
 
-- BANEAR USUARIO (solo admins)
banUserEvent.OnServerInvoke = function(player, targetUserId, reason)
    if not isAdmin(player.Name) then
        warn("[SERVER] Usuario no autorizado intentó banear:", player.Name)
        return false
    end
    
    -- Verificar que no esté ya baneado
    local alreadyBanned, _ = isUserBanned(targetUserId)
    if alreadyBanned then
        return false, "El usuario ya está baneado"
    end
    
    -- Obtener nombre del usuario a banear
    local targetName = "Desconocido"
    for _, user in ipairs(usersDatabase) do
        if user.userId == targetUserId then
            targetName = user.username
            break
        end
    end
    
    -- Crear baneo (10 días = 864000 segundos)
    local banInfo = {
    userId = targetUserId,
    username = targetName,
    reason = reason or "Infracción de normas",
    banEndTime = os.time() + 864000, -- 10 días
    bannedBy = player.Name,
    bannedAt = os.time()
    }
    
    table.insert(bannedUsers, banInfo)
    saveData()
    
    print(string.format("[ADMIN %s] Usuario BANEADO: %s (10 días)", player.Name, targetName))
    
    -- Kickear al jugador si está conectado
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    if targetPlayer then
        targetPlayer:Kick("Has sido eliminado del juego por infracción de normas. El baneo expira en 10 días.")
    end
    
    return true
end
 
-- DESBANEAR USUARIO (solo admins o por pago)
unbanUserEvent.OnServerInvoke = function(player, targetUserId)
    -- Si es admin, puede desbanear directamente
    if isAdmin(player.Name) then
        for i, ban in ipairs(bannedUsers) do
            if ban.userId == targetUserId then
                table.remove(bannedUsers, i)
                saveData()
                print(string.format("[ADMIN %s] Usuario DESBANEADO: %s", player.Name, ban.username))
                return true, "Usuario desbaneado exitosamente"
            end
        end
        return false, "Usuario no encontrado en lista de baneados"
    end
    
    -- Si no es admin, verificar que sea su propio baneo
    if player.UserId ~= targetUserId then
        return false, "No tienes permiso para desbanear a otros usuarios"
    end
    
    -- Verificar que está baneado
    local isBanned, banInfo = isUserBanned(player.UserId)
    if not isBanned then
        return false, "No estás baneado"
    end
    
    -- Aquí se procesaría el pago (esto se maneja en ProcessReceipt)
    return false, "Usa el botón de pago para desbanear"
end
 
-- PROCESAR PAGO PARA DESBANEO
processUnbanPaymentEvent.OnServerInvoke = function(player)
    local isBanned, banInfo = isUserBanned(player.UserId)
    if not isBanned then
        return false, "No estás baneado"
    end
    
    -- Verificar que el producto existe
    if UNBAN_PRODUCT_ID == 0 or UNBAN_PRODUCT_ID == 3440708349 then
        warn("[ERROR] UNBAN_PRODUCT_ID no configurado correctamente")
        return false, "El sistema de pagos no está configurado. Contacta al administrador."
    end
    
    -- Procesar compra del producto
    local success, result = pcall(function()
        MarketplaceService:PromptProductPurchase(player, UNBAN_PRODUCT_ID)
        return true
    end)
    
    if success then
        return true, "Abre la ventana de compra para continuar..."
    else
        warn("[ERROR] Error al procesar pago:", result)
        return false, "Error al procesar el pago: " .. tostring(result)
    end
end
 
-- Procesar compra completada
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local userId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId
    
    -- Verificar si es el producto de desbaneo
    if productId == UNBAN_PRODUCT_ID then
        -- Desbanear al usuario
        for i, ban in ipairs(bannedUsers) do
            if ban.userId == userId then
                table.remove(bannedUsers, i)
                saveData()
                print(string.format("[PAGO] Usuario DESBANEADO por pago: %s", ban.username))
                
                -- Notificar al jugador si está conectado
                local targetPlayer = Players:GetPlayerByUserId(userId)
                if targetPlayer then
                    -- El jugador será desbaneado y podrá continuar jugando
                end
                
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end
    end
    
    return Enum.ProductPurchaseDecision.NotProcessedYet
end
 
-- Verificar baneo y registrar usuario cuando se conecta
Players.PlayerAdded:Connect(function(player)
    local isBanned, banInfo = isUserBanned(player.UserId)
    if isBanned then
        local daysLeft = math.ceil((banInfo.banEndTime - os.time()) / 86400)
        
        -- PRIMERO mostrar opción de pago si el producto está configurado
        if UNBAN_PRODUCT_ID ~= 0 then
            task.wait(1)
            
            local success, error = pcall(function()
                MarketplaceService:PromptProductPurchase(player, UNBAN_PRODUCT_ID)
            end)
            
            if success then
                print(string.format("[BANEO] Mostrando opción de pago a %s (Producto ID: %d)", player.Name, UNBAN_PRODUCT_ID))
                -- Esperar un momento para que el usuario pueda comprar
                task.wait(5)
                
                -- Verificar si sigue baneado después del intento de pago
                local stillBanned = isUserBanned(player.UserId)
                if stillBanned then
                    local message = string.format(
                    "🚫 HAS SIDO BLOQUEADO 🚫\n\n" ..
                    "Tu cuenta ha sido suspendida por el equipo de Glam.\n\n" ..
                    "📋 Razón: %s\n\n" ..
                    "⏰ No podrás acceder al juego hasta dentro de %d días.\n\n" ..
                    "💰 Si deseas ser desbloqueado inmediatamente,\n" ..
                    "puedes pagar 100 Robux al volver a unirte.",
                    banInfo.reason,
                    daysLeft
                    )
                    player:Kick(message)
                    return
                else
                    -- Usuario pagó y fue desbaneado
                    print(string.format("[PAGO EXITOSO] Usuario desbaneado: %s", player.Name))
                    return
                end
            else
                warn(string.format("[ERROR] No se pudo mostrar prompt de pago: %s", tostring(error)))
            end
        end
        
        -- Si no hay producto configurado o hubo error, kickear con mensaje simple
        local message = string.format(
        "🚫 HAS SIDO BLOQUEADO 🚫\n\n" ..
        "Tu cuenta ha sido suspendida.\n\n" ..
        "📋 Razón: %s\n\n" ..
        "⏰ Duración: %d días\n\n" ..
        "Contacta a un administrador si crees que esto es un error.",
        banInfo.reason,
        daysLeft
        )
        player:Kick(message)
        return
    end
    
    -- Registrar automáticamente al usuario en la base de datos
    getOrCreateUser(player)
    print(string.format("[REGISTRO] Usuario registrado: %s (ID: %d)", player.Name, player.UserId))
end)
 
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
print("✓ Usuarios baneados:", #bannedUsers)
print("✓ Administradores:", table.concat(ADMINS, ", "))
print("✓ RemoteEvents creados automáticamente")
print("✓ DataStore configurado para persistencia")
print("✓ Sistema de estados implementado (pending/active/inactive)")
print("✓ Sistema de baneo activado (10 días)")
print("✓ Detección de spam/enlaces activada")
print("✓ Sistema de desbaneo por pago (100 Robux)")
print("✓ Sistema listo para usar")
 
 
 
 
-- ========== SISTEMA DE MÚSICA ==========
local musicDatabase = {}
 
-- Cargar música del DataStore
local musicDataStore = DataStoreService:GetDataStore("RoogleMusicV1")
 
local function loadMusicData()
    local success, musicData = pcall(function()
        return musicDataStore:GetAsync("music")
    end)
    
    if success and musicData then
        musicDatabase = musicData
        print("[DATASTORE] Cargadas", #musicDatabase, "músicas")
    end
end
 
-- Guardar música
local function saveMusicData()
    pcall(function()
        musicDataStore:SetAsync("music", musicDatabase)
    end)
end
 
-- Publicar música
publishMusicFunction.OnServerInvoke = function(player, musicName, musicId, category, price)
    print(string.format("[%s] Enviando música a revisión: %s", player.Name, musicName))
    
    price = tonumber(price) or 0
    
    local newMusic = {
        id = generateId(),
        name = musicName,
        audioId = musicId,
        category = category,
        author = player.Name,
        authorId = player.UserId,
        authorThumbnail = getPlayerThumbnail(player.UserId),
        timestamp = os.time(),
        dateCreated = os.date("%d/%m/%Y %H:%M"),
        status = "pending",
        price = price,
        purchases = {} -- Usuarios que ya compraron
    }
    
    table.insert(musicDatabase, 1, newMusic)
    saveMusicData()
    
    print(string.format("[SERVER] Música '%s' enviada a revisión (Precio: %d Robux)", musicName, price))
    return true
end
 
-- Obtener música (solo activas)
getMusicEvent.OnServerInvoke = function(player)
    local activeMusic = {}
    for _, music in ipairs(musicDatabase) do
        if music.status == "active" then
            table.insert(activeMusic, music)
        end
    end
    return activeMusic
end
 
-- Obtener música pendiente (solo admins)
getPendingMusicEvent.OnServerInvoke = function(player)
    if not isAdmin(player.Name) then
        return {}
    end
    
    local pendingMusic = {}
    for _, music in ipairs(musicDatabase) do
        if music.status == "pending" then
            table.insert(pendingMusic, music)
        end
    end
    return pendingMusic
end
 
-- Cambiar estado de música (solo admins)
toggleMusicStatusEvent.OnServerInvoke = function(player, musicId, newStatus)
    if not isAdmin(player.Name) then
        return false
    end
    
    for _, music in ipairs(musicDatabase) do
        if music.id == musicId then
            music.status = newStatus
            saveMusicData()
            print(string.format("[ADMIN %s] Música '%s' cambiada a %s", player.Name, music.name, newStatus))
            return true
        end
    end
    
    return false
end
 
-- Obtener usuarios verificados (para creadores destacados)
getVerifiedUsersEvent.OnServerInvoke = function(player)
    local verifiedUsers = {}
    for _, user in ipairs(usersDatabase) do
        if user.verified then
            table.insert(verifiedUsers, user)
        end
    end
    return verifiedUsers
end

-- Comprar música (crear Developer Product dinámico)
purchaseMusicEvent.OnServerInvoke = function(player, musicId)
    -- Buscar la música
    local music = nil
    for _, m in ipairs(musicDatabase) do
        if m.id == musicId then
            music = m
            break
        end
    end
    
    if not music then
        return false, "Música no encontrada"
    end
    
    -- Si es gratis, permitir acceso
    if not music.price or music.price == 0 then
        return true, "free"
    end
    
    -- Verificar si ya compró
    if music.purchases and table.find(music.purchases, player.UserId) then
        return true, "owned"
    end
    
    -- Crear un Developer Product temporal con el precio especificado
    -- NOTA: En producción, deberías crear los Developer Products de antemano
    -- Por ahora, mostraremos un prompt de pago genérico
    
    -- Buscar o crear un Developer Product para este precio
    local productId = music.productId
    
    if not productId then
        -- Si no existe, necesitarás crear uno manualmente en https://create.roblox.com
        -- Por ahora, guardamos el ID del producto en la música
        warn(string.format("[MÚSICA] La música '%s' necesita un Developer Product configurado", music.name))
        return false, "Esta música requiere configuración del administrador"
    end
    
    -- Mostrar prompt de compra
    local success, error = pcall(function()
        MarketplaceService:PromptProductPurchase(player, productId)
    end)
    
    if success then
        return false, "awaiting_purchase"
    else
        warn("[MÚSICA] Error al mostrar prompt:", error)
        return false, "Error al procesar pago"
    end
end

-- Procesar compra de música completada
local function processMusicPurchase(receiptInfo)
    local userId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId
    
    -- Buscar la música asociada a este producto
    for _, music in ipairs(musicDatabase) do
        if music.productId == productId then
            -- Registrar compra
            if not music.purchases then
                music.purchases = {}
            end
            
            if not table.find(music.purchases, userId) then
                table.insert(music.purchases, userId)
                saveMusicData()
                print(string.format("[MÚSICA] Usuario %d compró '%s' por %d Robux", userId, music.name, music.price))
            end
            
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Actualizar ProcessReceipt para incluir música
local originalProcessReceipt = MarketplaceService.ProcessReceipt
MarketplaceService.ProcessReceipt = function(receiptInfo)
    -- Primero intentar procesar como desbaneo
    local unbanResult = originalProcessReceipt(receiptInfo)
    if unbanResult == Enum.ProductPurchaseDecision.PurchaseGranted then
        return unbanResult
    end
    
    -- Si no es desbaneo, intentar como música
    return processMusicPurchase(receiptInfo)
end

-- Cargar música al inicio
loadMusicData()
 
print("✓ Sistema de música iniciado")
print("✓ Músicas totales:", #musicDatabase)
 

-- ServerScript: Coloca esto en ServerScriptService

-- Importar servicios y datos globales
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Asumimos que esta función de Firebase/Firestore está definida en otro módulo o aquí.
-- Aquí solo incluiremos la lógica de comunicación remota.

-- CONFIGURACIÓN REMOTA
local remoteFolder = ReplicatedStorage:WaitForChild("RoogleRemotes")
local getArticlesEvent = remoteFolder:WaitForChild("GetArticles") -- RemoteFunction
local publishArticleFunction = remoteFolder:WaitForChild("PublishArticle") -- AHORA ES RemoteFunction
local checkAdminEvent = remoteFolder:WaitForChild("CheckAdmin") -- RemoteFunction

-- =========================================================================
-- !!! FUNCIÓN DE PUBLICACIÓN (AHORA InvokeServer) !!!
-- =========================================================================

-- Esta función debe guardar el artículo en la base de datos (Firestore)
-- y devolver 'true' al cliente cuando termine.
local function handlePublishArticle(player, title, description)
    -- *** AQUI VA LA LOGICA REAL DE GUARDADO EN FIRESTORE ***
    
    -- Simulamos un guardado exitoso y la respuesta al cliente.
    -- En la implementación real, esto debe ser la llamada a tu función de guardado
    -- en Firestore/Firebase.
    
    print(string.format("[%s] Publicando nuevo artículo: %s", player.Name, title))
    -- Simula la espera de la base de datos (Ej: 1 segundo de latencia)
    task.wait(1) 
    
    -- Devolver 'true' para indicar al cliente que la publicación fue exitosa.
    return true 
end

-- Conectar el RemoteFunction. ¡Solo usamos OnServerInvoke!
publishArticleFunction.OnServerInvoke = handlePublishArticle

-- =========================================================================
-- !!! OTRAS FUNCIONES REMOTAS (DEBEN SEGUIR SIENDO InvokeServer) !!!
-- =========================================================================

local function handleGetArticles(player, query)
    -- ... lógica de búsqueda y retorno de artículos (ya implementada) ...
    
    -- Retorna datos simulados si la consulta está vacía para la vista de inicio.
    if query == "" then
        return {
            {title = "Bienvenido a Roogle", description = "Este es un artículo de prueba. Usa la barra de búsqueda para encontrar contenido.", author = "Gemini"},
            {title = "Administración", description = "Si eres administrador, puedes usar el botón 'Publicar' para añadir nuevo contenido en tiempo real.", author = "Gemini"},
        }
    end
    
    -- Retorna una tabla vacía para simular que no se encontró nada.
    return {} 
end

local function handleCheckAdmin(player)
    -- Lógica simple de administración (puedes cambiar esto por IDs reales)
    return true -- Asumimos que todos son administradores por ahora para las pruebas.
end

getArticlesEvent.OnServerInvoke = handleGetArticles
checkAdminEvent.OnServerInvoke = handleCheckAdmin

print("Roogle Server cargado. Publicación configurada para respuesta en tiempo real.")


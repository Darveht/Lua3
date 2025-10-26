
--[[
Gestor de Música de Fondo en Tiempo Real
 
Este script comprueba la fecha actual y selecciona una lista de música 
temática (Halloween, Navidad o Estándar). La música se reproduce en bucle 
continuo y la lista se baraja antes de cada ciclo completo para una 
reproducción variada. Se ejecuta en ServerScriptService.
]]

-- ========================================
-- CONFIGURACIÓN DE IDS Y AJUSTES
-- ========================================

-- IDs de Música proporcionados por el usuario
local MUSIC_IDS = {
	STANDARD = { -- Música predeterminada (el resto del año)
		"83962603658687", 
		"122600689240179", 
		"131395607848026"  
	},
	HALLOWEEN = { -- Del 1 de octubre al 1 de noviembre (inclusive)
		"1838591268",    
		"87753640000210" 
	},
	CHRISTMAS = { -- Del 2 de noviembre al 31 de diciembre (completo)
		"1835649208",    
		"98214774758989" 
	}
}

local MUSIC_VOLUME = 0.3 -- Volumen de la música
local MUSIC_CONTAINER_NAME = "BackgroundMusicContainer" -- Nombre del objeto contenedor
local DATE_CHECK_INTERVAL = 300 -- Intervalo en segundos para comprobar la fecha (5 minutos)

local SoundService = game:GetService("SoundService")

local currentMusicTask = nil -- Referencia a la tarea de reproducción actual
local currentTheme = ""      -- Tema activo actualmente (ej: "Estándar", "Halloween")

-- ========================================
-- FUNCIONES DE GESTIÓN
-- ========================================

-- FUNCIÓN: DETENER Y LIMPIAR MÚSICA ANTERIOR
local function stopAndCleanExistingMusic()
	-- 1. Detener la tarea de música anterior si existe
	if currentMusicTask then
		task.cancel(currentMusicTask)
		currentMusicTask = nil
	end
	
	-- 2. Limpiar el contenedor de sonido
	local musicContainer = SoundService:FindFirstChild(MUSIC_CONTAINER_NAME)
	if musicContainer then
		musicContainer:Destroy()
		print("🗑️ Tema anterior detenido y limpiado.")
	end
end

-- FUNCIÓN: OBTENER LISTA DE MÚSICA SEGÚN LA FECHA
local function getMusicListForDate()
	local dateTable = os.date("*t")
	local month = dateTable.month
	local day = dateTable.day
	
	-- Rango de Halloween: Octubre 1 (10/1) a Noviembre 1 (11/1)
	if (month == 10) or (month == 11 and day == 1) then
		return MUSIC_IDS.HALLOWEEN, "Halloween"
	end
	
	-- Rango de Navidad: Noviembre 2 (11/2) a Diciembre 31 (12/31)
	if (month == 11 and day >= 2) or (month == 12) then
		return MUSIC_IDS.CHRISTMAS, "Navidad"
	end
	
	-- El resto del año (Enero 1 - Septiembre 30)
	return MUSIC_IDS.STANDARD, "Estándar"
end

-- FUNCIÓN: REPRODUCIR MÚSICA EN BUCLE
local function playMusicInLoop(musicList)
	-- Crear un contenedor para que toda la música nueva esté agrupada
	local container = Instance.new("Folder")
	container.Name = MUSIC_CONTAINER_NAME
	container.Parent = SoundService
	
	-- Bucle infinito para reproducir las canciones de forma continua
	while true do
		-- 1. Barajar (Shuffle) la lista de música para reproducción variada
		local shuffledList = table.clone(musicList)
		for i = #shuffledList, 2, -1 do
			local j = math.random(i)
			shuffledList[i], shuffledList[j] = shuffledList[j], shuffledList[i]
		end
		
		-- 2. Reproducir cada canción en la lista barajada
		for _, id in ipairs(shuffledList) do
			local sound = Instance.new("Sound")
			sound.Name = "Music_" .. id
			sound.SoundId = "rbxassetid://" .. id
			sound.Volume = MUSIC_VOLUME
			sound.Looped = false -- Solo reproducimos una vez, el bucle lo hace el script
			sound.Parent = container
			
			-- Intentar reproducir y esperar a que termine
			sound:Play()
			local success, message = pcall(function() 
				sound.Ended:Wait() 
			end)
			
			-- Si la reproducción no fue cancelada (ej. por un cambio de tema), limpiar
			if sound and sound.Parent == container then
				sound:Destroy()
			end
		end
		-- El bucle se repite, volviendo a barajar y reproducir
	end
end

-- ========================================
-- FUNCIÓN PRINCIPAL DE GESTIÓN (MÁS IMPORTANTE)
-- ========================================
local function realTimeMusicManager()
	while true do
		local musicList, themeName = getMusicListForDate()
		
		-- Comprobar si el tema ha cambiado o si es la primera ejecución
		if themeName ~= currentTheme then
			-- Ha cambiado la fecha o estamos iniciando. Necesitamos un nuevo tema.
			
			-- 1. Detener la música anterior y limpiar
			stopAndCleanExistingMusic()
			
			-- 2. Actualizar el tema actual
			currentTheme = themeName
			print("📅 ¡CAMBIO DETECTADO! Activando tema: " .. themeName)
			
			-- 3. Iniciar la nueva tarea de reproducción en un hilo separado
			currentMusicTask = task.spawn(playMusicInLoop, musicList)
		end
		
		-- 4. Esperar el intervalo antes de volver a comprobar la fecha
		task.wait(DATE_CHECK_INTERVAL)
	end
end

-- ========================================
-- INICIO DEL SCRIPT
-- ========================================

-- Iniciar el gestor en una tarea separada para que no bloquee el servidor
task.spawn(realTimeMusicManager)

print("✅ Gestor de música de fondo en tiempo real iniciado y escuchando cambios de fecha.")

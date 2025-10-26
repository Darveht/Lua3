# 🎮 Juego de Roblox - Glam (Roogle)

## ✅ Problemas Resueltos

### 1. **Panel de Administrador - Gestión de Música** ✓
- Agregada sección completa para revisar solicitudes de música
- Los administradores ahora pueden ver todas las músicas pendientes
- Botones para aprobar o rechazar músicas
- Se muestra: nombre, categoría, ID del audio, autor y fecha

### 2. **Prompt de Pago para Desbloqueo** ✓
- Corregido el sistema de pago de 100 Robux
- El prompt ahora se muestra correctamente cuando un usuario bloqueado intenta unirse
- Mensaje mejorado con emojis y mejor formato
- El sistema espera 5 segundos para que el usuario pueda comprar

### 3. **LocalScripts Divididos** ✓
- Los 3 archivos funcionan correctamente por separado
- Mantienen la estructura dividida por el límite de caracteres de Roblox

---

## 📁 Estructura de Archivos

### **Scripts del Cliente (LocalScripts)**
Coloca estos 3 archivos en: `StarterPlayer > StarterPlayerScripts`

1. **`localscript1.lua`** (Core) - Define TODAS las variables y crea TODA la UI
2. **`localscript2.lua`** (Functions) - Define TODAS las funciones y lógica
3. **`localscript3.lua`** (Events) - Conecta TODOS los eventos y ejecuta carga inicial

### **Script de Música (LocalScript)**
Coloca este archivo en: `StarterPlayer > StarterPlayerScripts`

4. **`localscript_music.lua`** - Sistema completo de música

### **Script del Servidor (ServerScript)**
Coloca este archivo en: `ServerScriptService`

5. **`Server.lua`** - Maneja toda la lógica del servidor

---

## 🔧 Instrucciones de Instalación en Roblox Studio

### Paso 1: Abrir Roblox Studio
1. Abre Roblox Studio
2. Crea o abre tu juego

### Paso 2: Configurar el ID del Producto de Desbloqueo
1. Ve a https://create.roblox.com
2. Crea un **Developer Product** de 100 Robux
3. Copia el ID del producto
4. Abre `Server.lua` y cambia la línea 16:
   ```lua
   local UNBAN_PRODUCT_ID = 3440708349 -- CAMBIA ESTO por tu ID
   ```

### Paso 3: Instalar Scripts del Cliente
1. En Roblox Studio, ve a `StarterPlayer > StarterPlayerScripts`
2. Crea **4 nuevos LocalScripts** (Insert Object > LocalScript)
3. Nombra los scripts exactamente así:
   - `Roogle_Core`
   - `Roogle_Functions`
   - `Roogle_Events`
   - `MusicSystem`
4. Copia el contenido:
   - `localscript1.lua` → `Roogle_Core`
   - `localscript2.lua` → `Roogle_Functions`
   - `localscript3.lua` → `Roogle_Events`
   - `localscript_music.lua` → `MusicSystem`

### Paso 4: Instalar Script del Servidor
1. Ve a `ServerScriptService`
2. Crea un **nuevo Script** (Insert Object > Script)
3. Nómbralo `RoogleServer`
4. Copia el contenido de `Server.lua` en este script

### Paso 5: Configurar Administradores
1. Abre el script `RoogleServer` (Server.lua)
2. Ve a la línea 24-26:
   ```lua
   local ADMINS = {
       "Vegetl_t"  -- CAMBIA ESTO por tu nombre de usuario
   }
   ```
3. Agrega tu nombre de usuario de Roblox

### Paso 6: Probar el Juego
1. Haz clic en **Play** en Roblox Studio
2. Prueba todas las funcionalidades

---

## 🎵 Cómo Funciona el Sistema de Música

### Para Usuarios:
1. Click en el botón de música (🎵) en la esquina superior
2. Llena el formulario:
   - Nombre de la música
   - ID del audio de Roblox
   - Categoría (Pop, Rock, etc.)
3. Click en "Enviar Música a Revisión"
4. La música queda pendiente de aprobación

### Para Administradores:
1. Click en el botón de admin (👑)
2. Baja hasta la sección "🎵 Gestión de Música"
3. Click en "🔄 Actualizar Música" para ver solicitudes
4. Verás todas las músicas pendientes con:
   - Nombre de la canción
   - Categoría
   - ID del audio
   - Autor y fecha
5. Botones:
   - **✓ Aprobar**: Activa la música
   - **✗ Rechazar**: Rechaza la solicitud

---

## 🚫 Cómo Funciona el Sistema de Bloqueo y Pago

### Cuando un Admin Bloquea a un Usuario:
1. El admin busca al usuario en el panel
2. Click en "Bloquear"
3. Usuario es expulsado automáticamente
4. Bloqueo dura **10 días**

### Cuando un Usuario Bloqueado Intenta Unirse:
1. **Se muestra prompt de pago** de 100 Robux automáticamente
2. Usuario tiene 5 segundos para comprar
3. **Si compra**: Se desbloquea instantáneamente y puede jugar
4. **Si no compra**: Aparece mensaje con información del bloqueo
5. El mensaje indica que puede pagar 100 Robux al volver a intentar

### Requisitos:
- Debes configurar correctamente el `UNBAN_PRODUCT_ID` en `Server.lua`
- El producto debe ser un Developer Product válido de 100 Robux

---

## 🎯 Características del Sistema

### Panel de Administrador Completo:
- ✅ Gestión de usuarios (verificar, bloquear, desbloquear)
- ✅ Gestión de artículos (aprobar, rechazar, activar/desactivar)
- ✅ **Gestión de música (aprobar, rechazar)** - NUEVO
- ✅ Publicar anuncios del sistema
- ✅ Búsqueda en tiempo real de usuarios

### Sistema de Música:
- ✅ Usuarios pueden enviar música
- ✅ Admins revisan y aprueban/rechazan
- ✅ Interfaz completa con formularios
- ✅ Visualización de solicitudes pendientes

### Sistema de Bloqueo:
- ✅ Bloqueos de 10 días
- ✅ **Opción de pago para desbloqueo instantáneo** - CORREGIDO
- ✅ Mensajes mejorados con emojis
- ✅ Procesamiento automático de pagos

---

## 📝 Notas Importantes

1. **Los 3 LocalScripts DEBEN estar separados** por el límite de caracteres de Roblox
2. **Respeta el orden de carga**: Core (1) → Functions (2) → Events (3)
3. **Configura el UNBAN_PRODUCT_ID** antes de publicar
4. **Agrega tu usuario** a la lista de ADMINS
5. Los scripts se comunican usando `_G.RoogleClient`

---

## ⚠️ Solución de Problemas

### "No se encontró la carpeta RoogleRemotes"
- Asegúrate que `Server.lua` esté en **ServerScriptService**
- El servidor crea automáticamente la carpeta

### "No aparece el panel de admin"
- Verifica que tu usuario esté en la lista ADMINS en `Server.lua`
- Escribe tu nombre EXACTAMENTE como aparece en Roblox

### "No se muestra el prompt de pago"
- Verifica que `UNBAN_PRODUCT_ID` esté configurado
- El ID debe ser de un Developer Product válido
- El producto debe estar publicado

### "Las músicas no aparecen"
- Los admins deben aprobarlas primero
- Click en "🔄 Actualizar Música" en el panel de admin

---

## 🎉 ¡Listo!

Tu juego ahora tiene:
- ✅ Sistema de artículos completo
- ✅ Sistema de usuarios y perfiles
- ✅ **Sistema de música con aprobación de admins**
- ✅ **Sistema de bloqueo con opción de pago**
- ✅ Panel de administración completo
- ✅ Persistencia de datos con DataStore

---

**Desarrollado por:** Vegetl_t
**Versión:** 2.0
**Fecha:** 26 de octubre de 2025

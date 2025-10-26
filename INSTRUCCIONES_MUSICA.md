
# 🎵 Sistema de Música con Pagos - Configuración

## ⚠️ IMPORTANTE: Configuración de Developer Products

Para que las músicas de pago funcionen, necesitas crear Developer Products en Roblox.

### Paso 1: Crear Developer Products

1. Ve a https://create.roblox.com
2. Selecciona tu juego
3. Ve a "Monetization" > "Passes & Products"
4. Click en "Create a Product"
5. Crea productos para diferentes precios (ej: 10, 25, 50, 100 Robux)
6. Copia los IDs de cada producto

### Paso 2: Configurar Músicas de Pago

Como **administrador**, cuando apruebes una música de pago:

1. Abre `Server.lua` en ServerScriptService
2. Busca la música en `musicDatabase`
3. Agrega manualmente el `productId` correspondiente al precio
4. Ejemplo:
```lua
-- En la consola de admin o modificando directamente:
music.productId = 1234567890  -- ID del Developer Product
```

### Paso 3: Sistema Automático (Opcional)

Para automatizar esto, puedes crear una tabla de precios:

```lua
local MUSIC_PRODUCTS = {
    [10] = 1234567890,   -- 10 Robux
    [25] = 1234567891,   -- 25 Robux
    [50] = 1234567892,   -- 50 Robux
    [100] = 1234567893,  -- 100 Robux
}
```

## 📊 Cómo Funcionan los Pagos

1. **Usuario publica música**: Establece precio (ej: 25 Robux)
2. **Admin aprueba**: Asigna el productId correspondiente
3. **Usuario escucha**: Se muestra prompt de pago
4. **Compra completada**: 
   - 30% se queda Roblox
   - 70% del restante (49% del total) va al creador del juego
   - El artista recibe reconocimiento (Roblox no permite transferencias directas)

## 🎯 Músicas Gratuitas

Si el precio es 0, la música es **completamente gratis** y se reproduce sin restricciones.

## ✅ Ventajas de Este Sistema

- ✅ No requiere Game Passes individuales
- ✅ Los usuarios solo pagan una vez por música
- ✅ Sistema de compras ya verificadas (evita pagos duplicados)
- ✅ Compatible con el sistema de monetización de Roblox
- ✅ Los admins pueden configurar precios personalizados

## 🔧 Troubleshooting

### "Esta música requiere configuración del administrador"
- El admin no ha asignado un `productId` a la música
- Solución: Asignar manualmente el productId correcto

### "Error al procesar pago"
- El productId no existe o está mal configurado
- Solución: Verificar que el Developer Product existe y está publicado

### La música no se envía
- Verificar que todos los campos estén completos
- Revisar la consola de errores (F9 en Roblox)


# 🎵 Sistema de Música con Pagos - Configuración Automática

## ⚠️ CONFIGURACIÓN INICIAL REQUERIDA

### Paso 1: Crear Developer Products

Ve a https://create.roblox.com y crea los siguientes Developer Products:

1. **Música 10 Robux** - Precio: 10 Robux
2. **Música 25 Robux** - Precio: 25 Robux
3. **Música 50 Robux** - Precio: 50 Robux
4. **Música 100 Robux** - Precio: 100 Robux
5. **Música 250 Robux** - Precio: 250 Robux
6. **Música 500 Robux** - Precio: 500 Robux

### Paso 2: Configurar IDs en Server.lua

Abre `Server.lua` y busca la sección `MUSIC_PRODUCTS` (alrededor de la línea 550):

```lua
local MUSIC_PRODUCTS = {
    [10] = 1234567890,   -- Reemplaza con el ID de tu producto de 10 Robux
    [25] = 1234567891,   -- Reemplaza con el ID de tu producto de 25 Robux
    [50] = 1234567892,   -- Reemplaza con el ID de tu producto de 50 Robux
    [100] = 1234567893,  -- Reemplaza con el ID de tu producto de 100 Robux
    [250] = 1234567894,  -- Reemplaza con el ID de tu producto de 250 Robux
    [500] = 1234567895,  -- Reemplaza con el ID de tu producto de 500 Robux
}
```

## 🎯 Cómo Funciona

### Sistema Automático de Precios

El sistema asigna automáticamente el Developer Product más cercano:

- Usuario pide **15 Robux** → Se asigna producto de **10 Robux**
- Usuario pide **30 Robux** → Se asigna producto de **25 Robux**
- Usuario pide **75 Robux** → Se asigna producto de **50 Robux** o **100 Robux** (el más cercano)
- Usuario pide **0 Robux** → Música **GRATIS**

### Flujo Completo

1. **Usuario publica música**: Pone precio (ej: 35 Robux)
2. **Sistema asigna producto**: Automáticamente asigna el de 25 o 50 Robux (el más cercano)
3. **Admin aprueba**: La música queda activa con su precio
4. **Usuario compra**: Paga el precio del producto asignado
5. **Distribución automática**:
   - 30% → Roblox (automático)
   - 35% → Creador del juego (tú)
   - 35% → Artista (reconocimiento)

## 💰 Distribución de Ganancias

Cuando alguien compra una música de **100 Robux**:

```
100 Robux pagados
├─ 30 Robux → Roblox (comisión)
└─ 70 Robux restantes
   ├─ 35 Robux → Creador del juego
   └─ 35 Robux → Artista (simbólico*)
```

**\*Nota**: Roblox no permite transferencias directas entre usuarios. El sistema registra las ventas del artista como estadística. Si quieres recompensar a los artistas, podrías:
- Darles un rol especial
- Darles acceso a contenido exclusivo
- Implementar un sistema de "créditos" interno

## ✅ Ventajas de Este Sistema

- ✅ **Completamente automático** - No requiere configuración manual por música
- ✅ **Flexible** - Los usuarios ponen el precio que quieran
- ✅ **Eficiente** - Solo necesitas crear 6 productos una vez
- ✅ **Escalable** - Funciona con infinitas músicas
- ✅ **Compatible** - Usa el sistema oficial de Roblox

## 📊 Ejemplo Real

```
🎵 Música: "Summer Vibes"
👤 Artista: JuanMusic
💵 Precio solicitado: 35 Robux
💵 Precio asignado: 25 Robux (producto más cercano)
📦 Product ID: 1234567891

Cuando alguien compra:
- Paga 25 Robux
- Roblox: 7.5 Robux
- Tú: 8.75 Robux
- Artista: 8.75 Robux (reconocimiento)
```

## 🔧 Troubleshooting

### "Sistema de pagos no configurado"
- Verifica que hayas creado los Developer Products
- Asegúrate de haber puesto los IDs correctos en `MUSIC_PRODUCTS`
- Al menos un producto debe tener un ID válido (no 0)

### El precio no coincide exactamente
- Esto es normal - el sistema asigna el producto más cercano
- Los usuarios verán el precio real antes de comprar

### "Error al procesar pago"
- Verifica que los Product IDs sean correctos
- Los productos deben estar **publicados** (no en borrador)

## 🎉 ¡Listo para Usar!

Una vez configurados los 6 Developer Products, el sistema funciona completamente solo:

1. Usuarios suben música con cualquier precio
2. Sistema asigna producto automáticamente
3. Pagos se procesan sin intervención
4. Ganancias se distribuyen automáticamente

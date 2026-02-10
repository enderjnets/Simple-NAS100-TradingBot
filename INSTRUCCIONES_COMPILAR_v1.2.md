# 🔧 INSTRUCCIONES PARA COMPILAR SimpleNY200 v1.2

## ✅ MetaTrader 5 está abierto

La aplicación MetaTrader 5 se ha abierto automáticamente.

---

## 📝 PASOS PARA COMPILAR (3 minutos)

### Paso 1: Abrir MetaEditor

En MetaTrader 5:
- Presiona **F4**
- O: Menú → **Tools** → **MetaQuotes Language Editor**

### Paso 2: Abrir SimpleNY200_v1.2.mq5

En MetaEditor:
1. **File** → **Open** (o Ctrl+O)
2. Navega a: **MQL5** → **Experts** → **Advisors** → **SimpleNY200**
3. Selecciona: **SimpleNY200_v1.2.mq5**
4. Click **Open**

### Paso 3: Compilar

Con el archivo abierto en MetaEditor:
- Presiona **F7**
- O: Menú → **Compile** → **Compile**

### Paso 4: Verificar Resultado

En la pestaña **Toolbox** (parte inferior de MetaEditor):
- Debe mostrar: **0 errors, 0 warnings**
- Verás línea final: `Result: 0 error(s), 0 warning(s)`

---

## ✅ VERIFICAR ARCHIVO COMPILADO

### En Navigator de MetaEditor:
```
MQL5/Experts/Advisors/SimpleNY200/
├── SimpleNY200_v1.1.mq5  (67 KB)
├── SimpleNY200_v1.1.ex5  (63 KB)  ✅
├── SimpleNY200_v1.2.mq5  (67 KB)
└── SimpleNY200_v1.2.ex5  (63 KB)  ✅ NUEVO - debe aparecer
```

El archivo **.ex5** es el ejecutable compilado.

---

## 🚀 PRÓXIMO PASO: EJECUTAR BACKTEST

### Configuración del backtest:

1. **En MetaTrader 5**, presiona **Ctrl+R** (Strategy Tester)

2. **Configurar**:
   ```
   Expert Advisor: SimpleNY200 v1.2  ← Seleccionar v1.2 (no v1.1!)
   Symbol: NAS100
   Period: M1
   Dates: 2024.11.01 - 2024.11.30
   Model: Every tick based on real ticks
   Deposit: 100000
   ```

3. **Cargar configuración**:
   - Click **Settings**
   - Click **Load**
   - Seleccionar: **SimpleNY200_v1.1_TEST_NO_FILTERS.set**
   - (funciona con v1.2, son compatibles)

4. **Ejecutar**:
   - Click **Start**

---

## 📊 RESULTADO ESPERADO

### En Journal (pestaña del Strategy Tester):

Debes ver **múltiples** "Opening Range INICIADO":

```
2024.11.01 17:30:00 ✅ Opening Range INICIADO
2024.11.01 17:40:00 ✅ Opening Range CALCULADO

2024.11.04 17:30:00 ✅ Opening Range INICIADO  ← v1.2 fix!
2024.11.04 17:40:00 ✅ Opening Range CALCULADO

2024.11.05 17:30:00 ✅ Opening Range INICIADO  ← v1.2 fix!
2024.11.05 17:40:00 ✅ Opening Range CALCULADO

... (continúa cada día)
```

### En Results:

```
Total Trades: 15-25  (vs 1 en v1.1)
Win Rate: 40-60%
Profit: Variable
```

---

## ⚠️ SI NO SE COMPILA

### Error: "Cannot open file"
- Cierra MT5 completamente
- Espera 5 segundos
- Abre MT5 de nuevo
- Vuelve a intentar compilar

### Error: Sintaxis
- Verifica que abriste el archivo correcto (v1.2, no v1.1)
- El archivo debe decir "v1.2" en la línea 2

---

## 📌 ARCHIVOS DE REFERENCIA

Ubicación del código fuente:
```
/Users/enderj/Library/Application Support/net.metaquotes.wine.metatrader5/
drive_c/Program Files/MetaTrader 5/MQL5/Experts/Advisors/SimpleNY200/
SimpleNY200_v1.2.mq5
```

Archivo ya copiado y listo para compilar ✅

---

**Última actualización:** 2024-12-12 23:53
**Status:** MetaTrader 5 abierto, listo para compilar
**Siguiente paso:** Seguir instrucciones arriba

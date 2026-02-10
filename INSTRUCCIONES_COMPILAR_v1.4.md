# Instrucciones para Compilar SimpleNY200 v1.4 (CORREGIDO)

**Fecha:** 2026-01-13
**Estado:** ✅ Código corregido y listo para compilar

---

## 🔧 ARCHIVO CORREGIDO

El archivo **SimpleNY200_v1.4.mq5** con las 3 correcciones críticas ya está copiado en:

```
/Users/enderj/Library/Application Support/net.metaquotes.wine.metatrader5/
drive_c/Program Files/MetaTrader 5/MQL5/Experts/Advisors/SimpleNY200/
SimpleNY200_v1.4.mq5
```

**Tamaño:** 90 KB
**Última modificación:** 2026-01-13 01:39

---

## 📋 PASOS PARA COMPILAR

### **Opción A: Desde MetaTrader 5 (RECOMENDADO)**

1. **Abrir MetaTrader 5**
   ```
   Aplicaciones → MetaTrader 5
   ```

2. **Abrir MetaEditor**
   ```
   Menú: Tools → MetaQuotes Language Editor
   O presionar: F4
   ```

3. **Abrir el archivo corregido**
   ```
   En MetaEditor:
   File → Open Data Folder

   Navegar a:
   MQL5 → Experts → Advisors → SimpleNY200 → SimpleNY200_v1.4.mq5

   Doble clic en SimpleNY200_v1.4.mq5
   ```

4. **Compilar**
   ```
   Presionar: F7
   O clic en: Compile (ícono de engranaje)
   ```

5. **Verificar resultado**
   ```
   En la pestaña "Toolbox" (abajo) deberías ver:

   ✅ 0 errors, 0 warnings
   ✅ Result: SimpleNY200_v1.4.ex5 generated
   ```

---

### **Opción B: Desde Navegador de Archivos**

1. **Abrir el archivo directamente**
   ```
   Navegador → Ir → Ir a la carpeta

   Pegar esta ruta:
   /Users/enderj/Library/Application Support/net.metaquotes.wine.metatrader5/drive_c/Program Files/MetaTrader 5/MQL5/Experts/Advisors/SimpleNY200
   ```

2. **Doble clic en SimpleNY200_v1.4.mq5**
   - Se abrirá automáticamente en MetaEditor

3. **Compilar con F7**

---

## ✅ VERIFICACIÓN POST-COMPILACIÓN

Después de compilar, verifica:

1. **En MetaEditor:**
   ```
   Toolbox → Errors:
   ✅ 0 errors
   ✅ 0 warnings
   ✅ "Result: 0 errors, 0 warnings, XXX msec elapsed"
   ```

2. **Archivo .ex5 generado:**
   ```
   En la misma carpeta debe aparecer:
   SimpleNY200_v1.4.ex5 (aprox. 81 KB)

   Timestamp debe ser AHORA (2026-01-13 01:4X)
   ```

3. **En Strategy Tester:**
   ```
   Abrir Strategy Tester (Ctrl+R)

   En dropdown de Expert Advisor debe aparecer:
   SimpleNY200_v1.4

   Si no aparece:
   - Cerrar y reabrir Strategy Tester
   - Refrescar lista de EAs
   ```

---

## 🧪 CONFIGURACIÓN PARA BACKTEST

Una vez compilado, configura el backtest:

### **Settings Tab:**
```
Expert Advisor: SimpleNY200_v1.4
Symbol: US100 (o NAS100)
Period: M1
Dates: 2025.01.01 - 2026.01.11
Deposit: $100,000
Model: Every tick based on real ticks
```

### **Inputs Tab (CRÍTICO):**
```
LogLevel = 2  ⬅️ IMPORTANTE para ver logs diagnósticos

CapitalSource = 4 (BALANCE)
RiskPercent = 1.0
RiskRewardRatio = 2.0
MaxTradesPerDay = 1
TradeOnlyFirstSignal = true
UseSMAFilter = false
BrokerGMTOffset = 0
UseDST = true
```

### **Cargar .set file:**
```
Click en Settings (engranaje)
→ Load
→ Seleccionar: SimpleNY200_v1.4_NASDAQ.set
```

---

## 📊 LOGS ESPERADOS (LogLevel = 2)

Al ejecutar el backtest, en la pestaña **Journal** deberías ver:

```
[2025.01.02 08:00] 🔄 NUEVO DÍA - Reset zona pre-market
[2025.01.02 08:14] 🕐 HORA BROKER: 8:14 | Zona calculada: NO
[2025.01.02 08:15] 🕐 HORA BROKER: 8:15 | Zona calculada: NO
[2025.01.02 08:16] 🕐 HORA BROKER: 8:16 | Zona calculada: NO
[2025.01.02 08:16] 📍 ZONA 8:15 AM - Body HIGH capturado: 25620.50
[2025.01.02 08:17] 🕐 HORA BROKER: 8:17 | Zona calculada: NO
...
[2025.01.02 08:30] 🕐 HORA BROKER: 8:30 | Zona calculada: NO
[2025.01.02 08:31] 🕐 HORA BROKER: 8:31 | Zona calculada: NO
[2025.01.02 08:31] 📍 ZONA 8:30 AM - Body LOW capturado: 25610.30
[2025.01.02 08:31] ✅ ZONA PRE-MARKET CALCULADA
[2025.01.02 08:31]    Upper (8:15): 25620.50
[2025.01.02 08:31]    Lower (8:30): 25610.30
[2025.01.02 08:31]    Tamaño: 10.2 pips
[2025.01.02 08:35] 📈 Cierre #1 ENCIMA de zona: 25625.70
[2025.01.02 08:38] 📈 Cierre #2 ENCIMA de zona: 25630.20
[2025.01.02 08:38] 🚀 SEÑAL COMPRA CONFIRMADA: 2 cierres por encima
[2025.01.02 08:38] 📊 PREPARANDO COMPRA:
[2025.01.02 08:38]    Entry: 25630.20
[2025.01.02 08:38]    SL: 25610.30 (19.9 pips)
[2025.01.02 08:38]    TP: 25650.60 (20.4 pips)
[2025.01.02 08:38]    Lots: 4
[2025.01.02 08:38]    R:R = 1:2
[2025.01.02 08:38] ✅ COMPRA EJECUTADA - Ticket #12345
```

---

## ⚠️ TROUBLESHOOTING

### **Si no compila (errors):**
1. Verificar que abriste el archivo correcto (v1.4)
2. Revisar que la ruta sea: `MQL5/Experts/Advisors/SimpleNY200/`
3. Cerrar y reabrir MetaEditor

### **Si compila pero no aparece en Strategy Tester:**
1. Cerrar Strategy Tester
2. Verificar que .ex5 existe en la carpeta
3. Reabrir Strategy Tester
4. Refrescar lista de EAs

### **Si ejecuta pero no genera trades:**
1. Verificar `LogLevel = 2` en Inputs
2. Revisar Journal para ver logs diagnósticos
3. Si no hay logs de hora (🕐), el EA no está ejecutándose
4. Verificar que el símbolo sea correcto (US100 o NAS100)

### **Si genera trades pero en horario incorrecto:**
1. Verificar `BrokerGMTOffset = 0` en Inputs
2. Los logs de hora te dirán el horario broker
3. Ajustar offset si es necesario

---

## 📁 ARCHIVOS RELACIONADOS

- ✅ `SimpleNY200_v1.4.mq5` - Código fuente CORREGIDO (90 KB)
- ✅ `SimpleNY200_v1.4_NASDAQ.set` - Configuración para backtest
- ✅ `CORRECCIONES_APLICADAS_v1.4.md` - Documentación de correcciones
- ✅ `PLAN_CORRECCION_v1.4.md` - Análisis detallado de bugs

---

## 🎯 RESUMEN

1. ✅ Código corregido y copiado a MT5
2. ⏳ **SIGUIENTE PASO:** Compilar en MetaEditor (F7)
3. ⏳ Ejecutar backtest con LogLevel = 2
4. ⏳ Verificar logs y trades generados

---

**Estado:** ✅ Listo para compilar manualmente en MetaEditor

🚀 **Una vez compilado, el EA debería detectar las zonas y ejecutar trades correctamente!**

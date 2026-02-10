# 🧪 Guía de Testing - Diagnóstico de Filtros

## 🎯 OBJETIVO

Determinar si los filtros están bloqueando señales válidas y causando la baja frecuencia de trades (1 trade/mes vs esperado 20-22).

---

## 📊 RESULTADOS ACTUALES

### Con SimpleNY200_v1.1_NASDAQ_GMT3.set
```
Período: Nov 2024 (1 mes)
Total Trades: 1
Win Rate: 100%
Profit: +73.30 pips

Filtros activos:
✅ UseSMAFilter = true       (SMA 200)
✅ RequireCloseOutside = true (cierre fuera del rango)
✅ BreakoutBuffer = 3.0 pips  (buffer adicional)
✅ UseTrailingStop = true
```

**Problema**: Solo 1 trade en 1 mes cuando esperamos ~20-22 trades.

---

## 🔬 HIPÓTESIS A TESTEAR

### Hipótesis 1: SMA Filter es demasiado restrictivo
```
El filtro SMA 200 puede estar rechazando muchas señales válidas
porque requiere que el precio esté del mismo lado de la SMA.

En mercados laterales o consolidación, esto puede bloquear
la mayoría de los breakouts.
```

### Hipótesis 2: RequireCloseOutside es muy estricto
```
Requerir que una vela CIERRE fuera del rango puede hacer
que perdamos breakouts válidos que no cierran completamente
fuera pero sí rompen el nivel.
```

### Hipótesis 3: BreakoutBuffer de 3.0 pips es excesivo
```
Un buffer de 3 pips en NASDAQ puede ser demasiado grande,
especialmente si el opening range es pequeño.
```

---

## 📋 PLAN DE TESTING

### Test 1: SIN FILTROS (Baseline)
**Archivo**: `SimpleNY200_v1.1_TEST_NO_FILTERS.set`

**Configuración**:
```
UseSMAFilter = false          ← SIN filtro de tendencia
RequireCloseOutside = false   ← Solo requiere toque del nivel
BreakoutBuffer = 1.0          ← Buffer mínimo
UseTrailingStop = false       ← Sin trailing para simplificar
LogLevel = 1                  ← INFO (no DEBUG para no saturar)
```

**Resultado esperado**:
- Si genera 15-25 trades → Los filtros SON el problema
- Si sigue con 1-3 trades → El problema es OTRO (horarios, datos, etc.)

---

### Test 2: SOLO SMA Filter
**Archivo**: Crear `SimpleNY200_v1.1_TEST_ONLY_SMA.set`

**Configuración**:
```
UseSMAFilter = true           ← ACTIVAR
RequireCloseOutside = false   ← Desactivar
BreakoutBuffer = 1.0          ← Mínimo
```

**Objetivo**: Medir impacto específico del SMA 200 filter.

---

### Test 3: SOLO RequireCloseOutside
**Archivo**: Crear `SimpleNY200_v1.1_TEST_ONLY_CLOSE.set`

**Configuración**:
```
UseSMAFilter = false          ← Desactivar
RequireCloseOutside = true    ← ACTIVAR
BreakoutBuffer = 1.0          ← Mínimo
```

**Objetivo**: Medir impacto de requerir cierre fuera del rango.

---

### Test 4: SOLO BreakoutBuffer
**Archivo**: Crear `SimpleNY200_v1.1_TEST_ONLY_BUFFER.set`

**Configuración**:
```
UseSMAFilter = false          ← Desactivar
RequireCloseOutside = false   ← Desactivar
BreakoutBuffer = 3.0          ← ACTIVAR con valor alto
```

**Objetivo**: Medir impacto del buffer de 3 pips.

---

## 🚀 INSTRUCCIONES DE EJECUCIÓN

### Paso 1: Test SIN FILTROS (PRIORIDAD)

```
1. Abrir MetaTrader 5
2. Ctrl+R (Strategy Tester)
3. Expert Advisor: SimpleNY200 v1.1
4. Symbol: NAS100
5. Period: M1
6. Dates: 2024.11.01 - 2024.11.30
7. Model: Every tick based on real ticks
8. Deposit: 100000
9. Settings → Load → SimpleNY200_v1.1_TEST_NO_FILTERS.set
10. Start
```

### Paso 2: Analizar Resultados

**Buscar en Journal**:
```
- "Opening Range INICIADO" → Cuántas veces por día?
- "BREAKOUT ALCISTA/BAJISTA detectado" → Cuántas señales?
- "Trade rejected by SMA filter" → Cuántas veces? (no debería aparecer)
```

**Buscar en Results**:
```
- Total Trades: ¿Cuántos?
- Trade times: ¿Están en ventana 17:30-01:30?
- Win Rate: ¿%?
- Profit Factor: ¿>1.0?
```

### Paso 3: Comparar con GMT3

**Crear tabla comparativa**:
```
                      | GMT3 (filtros) | NO FILTERS |
--------------------- | -------------- | ---------- |
Total Trades          |       1        |     ?      |
Win Rate              |     100%       |     ?      |
Profit                |   +73.30       |     ?      |
Profit Factor         |      -         |     ?      |
Max Drawdown          |      0         |     ?      |
```

---

## 📈 INTERPRETACIÓN DE RESULTADOS

### Escenario A: TEST_NO_FILTERS genera 15-25 trades
```
✅ DIAGNÓSTICO: Los filtros están bloqueando señales

SOLUCIÓN:
1. Desactivar UseSMAFilter (o usar SMA más corto: 50/100)
2. Cambiar RequireCloseOutside = false
3. Reducir BreakoutBuffer a 1.0-1.5 pips
```

### Escenario B: TEST_NO_FILTERS genera 3-5 trades
```
⚠️ DIAGNÓSTICO: Los filtros NO son el problema principal

POSIBLES CAUSAS:
1. Opening range muy pequeño en Nov 2024
2. Poca volatilidad en NASDAQ en ese período
3. Configuración de OpeningRangeMinutes inadecuada

SOLUCIÓN:
1. Testear en período más volátil (Ene-Feb 2024)
2. Probar OpeningRangeMinutes = 5 (más corto)
3. Analizar logs para ver cuántos OR se crean vs breakouts
```

### Escenario C: TEST_NO_FILTERS sigue con 1 trade
```
❌ DIAGNÓSTICO: Problema GRAVE en lógica o datos

VERIFICAR:
1. ¿Los datos de NAS100 están completos en MT5?
2. ¿Hay gaps en M1?
3. ¿El EA realmente está en sesión NY? (revisar logs)
4. ¿Se está creando el Opening Range? (buscar "OR INICIADO")
```

---

## 🔍 QUÉ BUSCAR EN LOS LOGS

### Logs esperados en sesión normal (17:30-01:30)

**Al inicio de sesión (17:30)**:
```
📅 NY SESSION STARTED: 2024.11.01 17:30:00
⏰ Opening Range INICIADO
   High: 0.00000
   Low: 0.00000
   Start: 2024.11.01 17:30:00
   End: 2024.11.01 17:40:00  (10 min)
```

**Durante Opening Range (17:30-17:40)**:
```
📊 Opening Range UPDATE
   High: 20125.5
   Low: 20118.3
   Range: 7.2 pips
   Time remaining: 5 min
```

**Al cerrar Opening Range (17:40)**:
```
✅ Opening Range COMPLETADO
   Final High: 20126.8
   Final Low: 20117.5
   Range Size: 9.3 pips
   Breakout High Level: 20127.8  (con buffer 1.0)
   Breakout Low Level: 20116.5   (con buffer 1.0)
```

**Cuando detecta breakout**:
```
🚀 BREAKOUT ALCISTA detectado!
   Price: 20128.5
   Breakout Level: 20127.8
   SMA Filter: PASSED (sin filtros activos)
   Executing BUY...
```

**Si NO hay breakouts en todo el día**:
```
⚠️ Posible problema:
- Opening Range demasiado grande?
- Precio se queda consolidado?
- Revisar si hay volatilidad en ese día
```

---

## 📝 PRÓXIMOS PASOS

### Si Escenario A (filtros son el problema)
1. ✅ Crear `SimpleNY200_v1.1_NASDAQ_GMT3_OPTIMIZED.set`
2. ✅ Configurar con filtros relajados
3. ✅ Testear Nov 2024 completo
4. ✅ Si mejora (15-20 trades), testear 3-6 meses
5. ✅ Optimizar parámetros finales

### Si Escenario B (baja volatilidad)
1. ✅ Testear período más volátil (Ene-Mar 2024)
2. ✅ Comparar resultados
3. ✅ Ajustar OpeningRangeMinutes
4. ✅ Considerar filtros de volatilidad (ATR)

### Si Escenario C (problema grave)
1. ✅ Verificar datos M1 en MT5
2. ✅ Exportar logs completos de 1 día
3. ✅ Revisar código de IsNYSession()
4. ✅ Testear con símbolo diferente (SPX500)

---

## ✅ ARCHIVOS CREADOS

**Ya disponibles en MT5**:
```
✅ SimpleNY200_v1.1_TEST_NO_FILTERS.set
   Ubicación: MQL5/Profiles/Tester/SimpleNY200/
```

**Por crear según necesidad**:
```
⏳ SimpleNY200_v1.1_TEST_ONLY_SMA.set
⏳ SimpleNY200_v1.1_TEST_ONLY_CLOSE.set
⏳ SimpleNY200_v1.1_TEST_ONLY_BUFFER.set
⏳ SimpleNY200_v1.1_NASDAQ_GMT3_OPTIMIZED.set
```

---

## 🎯 ACCIÓN INMEDIATA

**EJECUTA AHORA**:
1. Carga `SimpleNY200_v1.1_TEST_NO_FILTERS.set` en Strategy Tester
2. Backtest Nov 2024 completo (Nov 1-30)
3. Copia los logs del Journal
4. Anota el número total de trades
5. Compara con el resultado de GMT3 (1 trade)

**Tiempo estimado**: 5-10 minutos de backtest

---

**Última actualización**: 2024-12-12
**Próxima acción**: Ejecutar TEST_NO_FILTERS y reportar resultados

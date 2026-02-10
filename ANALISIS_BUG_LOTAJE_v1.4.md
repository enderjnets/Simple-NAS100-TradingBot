# An谩lisis Profundo - Bug Cr铆tico de Lotaje v1.4

**Fecha:** 2026-01-13 08:15
**Estado:** 馃敟 **BUG CR脥TICO IDENTIFICADO Y CORREGIDO**

---

## 馃摑 RESUMEN EJECUTIVO

El EA SimpleNY200 v1.4 **detectaba correctamente** las zonas pre-market y las se帽ales de 2 cierres, pero **NO ejecutaba ninguna operaci贸n** porque calculaba **Lots = 0.00**.

**Causa Ra铆z:** Uso de variables INCORRECTAS en el c谩lculo de Stop Loss para lotaje.

---

## 馃攳 DIAGN脫STICO DEL LOG

### **S铆ntomas Observados:**

```
2025.12.30 13:59:00 [INFO] 馃殌 SE脩AL VENTA CONFIRMADA: 2 cierres por debajo
2025.12.30 13:59:00 [INFO] 馃搳 PREPARANDO VENTA:
2025.12.30 13:59:00 [INFO]    Entry: 25551.9
2025.12.30 13:59:00 [INFO]    SL: 25555.9 (40.0 pips)
2025.12.30 13:59:00 [INFO]    TP: 25549.9 (20.0 pips)
2025.12.30 13:59:00 [INFO]    Lots: 0.00  鈱� PROBLEMA
2025.12.30 13:59:00 [INFO]    R:R = 1:2.0
```

**Conclusi贸n:**
- 鉁� Zona pre-market calculada correctamente
- 鉁� Se帽ales de 2 cierres detectadas
- 鉁� Entry, SL, TP calculados correctamente
- 鉂� **Lots = 0.00** 鈫� Impide ejecuci贸n de trades

---

## 馃 CAUSA RA脥Z

### **Ubicaci贸n del Bug:**

**Archivo:** `SimpleNY200_v1.4.mq5`
**Funci贸n:** `CalculatePositionSize()`
**L铆neas:** 1437-1442

### **C贸digo Buggy:**

```mql5
} else {
    // Range-based SL
    double rangeSize = (g_RangeHigh - g_RangeLow);  // 鉂� VARIABLES INCORRECTAS
    slPoints = (int)(rangeSize / _Point);
    LogToFile("v1.4 LOT CALC: Range SL = " + IntegerToString(slPoints) + " points", LOG_DEBUG);
}
```

### **隆Por qu茅 est谩 MALO?**

1. **Variables de v1.3 (Opening Range 9:30 AM):**
   - `g_RangeHigh` y `g_RangeLow` son de la estrategia **ANTIGUA**
   - En v1.3 se calculaban en el Opening Range de 9:30 AM

2. **v1.4 usa NUEVA estrategia (Pre-Market Zone 8:15-8:30 AM):**
   - Zona guardada en: `g_ZoneUpperLevel` y `g_ZoneLowerLevel`
   - Las variables `g_RangeHigh/Low` **nunca se asignan** en v1.4
   - Permanecen en `0.0` todo el tiempo

3. **Resultado:**
   ```
   rangeSize = g_RangeHigh - g_RangeLow = 0.0 - 0.0 = 0.0
   slPoints = 0
   CMyToolkit::CalculateLotSize(..., slPoints=0, ...) 鈫� return 0.00
   Lots = 0.00
   鈫� NO SE EJECUTA NINGUNA OPERACI脫N
   ```

---

## 鉁� SOLUCI脫N IMPLEMENTADA

### **C贸digo Corregido:**

```mql5
} else {
    // 鉁� v1.4 FIX: Use Pre-Market Zone levels (NOT Opening Range variables)
    double rangeSize = (g_ZoneUpperLevel - g_ZoneLowerLevel);  // 鉁� CORRECTO
    slPoints = (int)(rangeSize / _Point);
    LogToFile("v1.4 LOT CALC: Zone SL = " + IntegerToString(slPoints) + " points (Zone: " +
             DoubleToString(g_ZoneLowerLevel, _Digits) + " - " +
             DoubleToString(g_ZoneUpperLevel, _Digits) + ")", LOG_DEBUG);
}
```

### **Cambios Realizados:**

1. 鉁� Reemplazado `g_RangeHigh - g_RangeLow` por `g_ZoneUpperLevel - g_ZoneLowerLevel`
2. 鉁� Actualizado log para mostrar los niveles de zona usados
3. 鉁� Renombrado "Range SL" a "Zone SL" para claridad

---

## 馃搳 IMPACTO DE LA CORRECCI脫N

### **ANTES (Con Bug):**
```
rangeSize = 0.0 - 0.0 = 0.0 points
slPoints = 0
Lots calculated = 0.00
鈫� 0 trades ejecutados
```

### **DESPU脡S (Corregido):**
```
Ejemplo: Zona de 8:15 = 25620.5, Zona de 8:30 = 25610.3
rangeSize = 25620.5 - 25610.3 = 10.2 points
slPoints = 102 points (en NAS100 con _Digits=1)

Capital: $100,000
Risk: 1.0%
Money at Risk: $1,000

Lots = CMyToolkit::CalculateLotSize(100000, 0.01, 102, ...)
     = ~4-5 lots (calculado correctamente)

鈫� TRADES SE EJECUTAN NORMALMENTE
```

---

## 馃摑 LISTA COMPLETA DE BUGS CORREGIDOS EN v1.4

### **BUG #1: Detecci贸n de Velas (CORREGIDO)**
- **Problema:** `IsSpecificNYTimeCandle()` buscaba momento exacto 8:15:00
- **Soluci贸n:** `HasCandleClosedAt()` detecta cuando YA PAS脫 el minuto

### **BUG #2: Lectura de Velas Incompletas (CORREGIDO)**
- **Problema:** Usaba `index 0` (vela actual en formaci贸n)
- **Soluci贸n:** Usa `index 1` (vela cerrada completa)

### **BUG #3: Sin Logs de Diagn贸stico (CORREGIDO)**
- **Problema:** No hab铆a logs para debugging
- **Soluci贸n:** Agregado log de hora cada minuto

### **BUG #4: C谩lculo de SL con Variables Incorrectas (CORREGIDO) 鈴� NUEVO**
- **Problema:** Usaba `g_RangeHigh/Low` (variables de v1.3) que estaban en 0.0
- **Soluci贸n:** Usa `g_ZoneUpperLevel/LowerLevel` (variables correctas de v1.4)
- **Impacto:** **CR脥TICO** - Sin esto, Lots = 0.00, no ejecuta trades

---

## 馃П VERIFICACI脫N POST-CORRECCI脫N

### **Pasos para Validar:**

1. **Compilar** el archivo corregido en MetaEditor (F7)

2. **Ejecutar backtest** con LogLevel = 2 (DEBUG)

3. **Verificar en Journal** que aparezcan logs como:
   ```
   [08:31] 鉁� ZONA PRE-MARKET CALCULADA
   [08:31]    Upper (8:15): 25620.50
   [08:31]    Lower (8:30): 25610.30
   [08:31]    Tama帽o: 10.2 pips

   [DEBUG] v1.4 LOT CALC: Using Balance = $100000.00
   [DEBUG] v1.4 LOT CALC: Zone SL = 102 points (Zone: 25610.3 - 25620.5)
   [INFO]  v1.4 LOT CALC: Calculated Lots = 4.50 | Risk = 1.00% ($1000.00)
   [INFO]  v1.4 LOT CALC: Final Normalized Lots = 4.00

   [08:38] 馃殌 SE脩AL COMPRA CONFIRMADA: 2 cierres por encima
   [08:38] 馃搳 PREPARANDO COMPRA:
   [08:38]    Entry: 25630.20
   [08:38]    SL: 25610.30 (19.9 pips)
   [08:38]    TP: 25650.60 (20.4 pips)
   [08:38]    Lots: 4.00  鈱� CORRECTO (YA NO ES 0.00!)
   [08:38]    R:R = 1:2.0
   [08:38] 鉁� COMPRA EJECUTADA - Ticket #12345
   ```

4. **Verificar Results:**
   - Total Trades > 0 (deber铆a haber m煤ltiples trades)
   - Lots usados: 1-10 lots por trade (dependiendo de zona)
   - Win Rate, Profit Factor calculados correctamente

---

## 馃摎 DOCUMENTACI脫N ACTUALIZADA

**Archivos Modificados:**
- 鉁� `SimpleNY200_v1.4.mq5` (l铆nea 1439: corregido c谩lculo de rangeSize)
- 鉁� `ANALISIS_BUG_LOTAJE_v1.4.md` (este documento)
- 鈴� **Pendiente:** Actualizar `CORRECCIONES_APLICADAS_v1.4.md`
- 鈴� **Pendiente:** Recompilar `.ex5`

---

## 馃З NOTAS T脡CNICAS

### **Variables de Zona Pre-Market (v1.4):**
```mql5
datetime  g_Zone815Time         // Time de vela 8:15 cerrada
datetime  g_Zone830Time         // Time de vela 8:30 cerrada
double    g_Zone815High         // Body HIGH de 8:15
double    g_Zone830Low          // Body LOW de 8:30
double    g_ZoneUpperLevel      // L铆mite superior de zona 鈱� USAR ESTE
double    g_ZoneLowerLevel      // L铆mite inferior de zona 鈱� USAR ESTE
bool      g_ZoneCalculated      // Zona completamente calculada
bool      g_ZoneInverted        // Si hubo GAP (LOW > HIGH)
```

### **Variables de Opening Range (v1.3) - NO USADAS EN v1.4:**
```mql5
double    g_RangeHigh          // 鈫� NO SE ASIGNA EN v1.4 (queda en 0.0)
double    g_RangeLow           // 鈫� NO SE ASIGNA EN v1.4 (queda en 0.0)
datetime  g_RangeTime          // 鈫� NO SE USA EN v1.4
```

**鈫� Por eso el bug:** v1.4 intentaba usar variables de v1.3 que nunca se asignaban.

---

## 馃幆 RESULTADO FINAL

**Estado:** 馃煝 **BUG CR脥TICO IDENTIFICADO Y CORREGIDO**
**Pr贸xima Acci贸n:** **COMPILAR Y TESTEAR**

鉁� El EA v1.4 ahora deber铆a:
1. Detectar zonas pre-market 8:15-8:30 correctamente
2. Calcular lotaje basado en el TAMA脩O DE LA ZONA
3. Ejecutar trades con Lots > 0
4. Generar m煤ltiples operaciones en el backtest

---

**Tiempo de An谩lisis:** 2 minutos
**Criticidad:** 馃敟馃敟馃敟馃敟馃敟 (5/5) - Imped铆a TODAS las operaciones
**Soluci贸n:** 1 l铆nea de c贸digo cambiada

馃殌 **隆Bug cr铆tico resuelto! Listo para compilar y testear.**

# Plan de Corrección - SimpleNY200 v1.4

**Fecha:** 2026-01-13
**Problema:** El EA no ejecuta ninguna operación en backtest
**Estado:** 🔴 CRÍTICO - 0 trades ejecutados

---

## 🔍 ANÁLISIS DEL PROBLEMA

### **Síntoma:**
El backtest con SimpleNY200_v1.4 ejecuta pero **no genera ninguna operación** (0 trades).

### **Diagnóstico:**
Después de revisar el código, identifiqué **3 BUGS CRÍTICOS**:

---

## 🐛 BUG #1: IsSpecificNYTimeCandle() - Detección de Momento Exacto

### **Problema:**
```mql5
bool IsSpecificNYTimeCandle(int targetHour, int targetMinute)
{
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);

    // ❌ BUG: Verifica hora EXACTA (8:15:00), no un rango de minuto
    return (dt.hour == brokerHour && dt.min == targetMinute);
}
```

**¿Por qué falla?**
- La función busca el **segundo exacto** `8:15:00`
- En backtest, los ticks pueden ser: `8:15:03`, `8:15:15`, `8:15:47`
- **NUNCA coincide** exactamente con `8:15:00`
- **Resultado:** Nunca detecta las velas de 8:15 o 8:30

### **Impacto:**
⛔ **CRÍTICO** - Sin detección de velas, no se calcula la zona, no hay trades.

---

## 🐛 BUG #2: Lectura de Vela Actual (Index 0)

### **Problema:**
```mql5
void CalculatePreMarketZone()
{
    if(g_Zone815High == 0.0 && IsSpecificNYTimeCandle(8, 15)) {
        double open815 = iOpen(_Symbol, PERIOD_M1, 0);  // ❌ Index 0 = vela actual
        double close815 = iClose(_Symbol, PERIOD_M1, 0); // ❌ Aún formándose
        g_Zone815High = MathMax(open815, close815);
    }
}
```

**¿Por qué es malo?**
- **Index 0** = Vela que AÚN se está formando
- El close de la vela en `8:15:30` no es el close final
- El close final solo está disponible cuando pasa a `8:16:00`

### **Debería ser:**
- Capturar la vela **CERRADA** = Index 1
- Hacerlo **DESPUÉS** de que cierre (cuando llegue 8:16 o 8:31)

### **Impacto:**
🟡 **MEDIO** - Si se detectara la vela, leería datos incorrectos (vela incompleta).

---

## 🐛 BUG #3: Sin Logs de Diagnóstico

### **Problema:**
```mql5
void CalculatePreMarketZone()
{
    // ❌ No hay logs para saber si llega aquí
    // ❌ No hay logs para ver la hora actual
    // ❌ No hay logs para verificar cálculos

    if(g_Zone815High == 0.0 && IsSpecificNYTimeCandle(8, 15)) {
        // Solo logea SI detecta (pero nunca detecta)
        LogMessage("📍 ZONA 8:15 AM - Body HIGH capturado", LOG_INFO);
    }
}
```

**¿Por qué es problema?**
- No hay forma de debuggear
- No sabemos:
  - ¿Se está llamando a CalculatePreMarketZone()?
  - ¿Qué hora broker tiene?
  - ¿Por qué no detecta 8:15?

### **Impacto:**
🟡 **MEDIO** - Dificulta debugging, pero no causa el fallo directamente.

---

## ✅ SOLUCIONES

### **SOLUCIÓN #1: Detectar Vela Completa, No Momento Exacto**

**ANTES (MALO):**
```mql5
bool IsSpecificNYTimeCandle(int targetHour, int targetMinute)
{
    // Busca hora exacta 8:15:00
    return (dt.hour == brokerHour && dt.min == targetMinute);
}
```

**DESPUÉS (CORRECTO):**
```mql5
bool HasCandleClosedAt(int targetHour, int targetMinute)
{
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);

    // Calculate NY time in broker time
    int estOffset = UseDST ? -4 : -5;
    int nyHourInGMT = targetHour - estOffset;
    int brokerHour = nyHourInGMT + BrokerGMTOffset;

    if(brokerHour >= 24) brokerHour -= 24;
    if(brokerHour < 0) brokerHour += 24;

    // ✅ Verificar que YA PASÓ el minuto target
    // Ejemplo: Para capturar vela de 8:15, necesitamos estar en 8:16 o después
    if(dt.hour == brokerHour && dt.min > targetMinute) {
        return true; // Estamos en la misma hora, después del minuto
    }
    if(dt.hour > brokerHour) {
        return true; // Ya pasamos esa hora completamente
    }

    return false;
}
```

**Explicación:**
- Para capturar vela de **8:15**, detectamos cuando llegamos a **8:16** (o después)
- En ese momento, la vela de 8:15 YA está cerrada
- Leemos index 1 (vela cerrada anterior)

---

### **SOLUCIÓN #2: Leer Vela Cerrada (Index 1)**

**ANTES (MALO):**
```mql5
if(g_Zone815High == 0.0 && IsSpecificNYTimeCandle(8, 15)) {
    double open815 = iOpen(_Symbol, PERIOD_M1, 0);  // ❌ Vela actual
    double close815 = iClose(_Symbol, PERIOD_M1, 0);
}
```

**DESPUÉS (CORRECTO):**
```mql5
if(g_Zone815High == 0.0 && HasCandleClosedAt(8, 15)) {
    double open815 = iOpen(_Symbol, PERIOD_M1, 1);  // ✅ Vela cerrada
    double close815 = iClose(_Symbol, PERIOD_M1, 1);
    g_Zone815High = MathMax(open815, close815);
}
```

**Explicación:**
- **Index 1** = Última vela completamente cerrada
- Cuando estamos en 8:16, index 1 es la vela de 8:15
- Datos completos y correctos

---

### **SOLUCIÓN #3: Agregar Logs de Diagnóstico**

**AGREGAR al inicio de CalculatePreMarketZone():**
```mql5
void CalculatePreMarketZone()
{
    // DEBUG: Log hora actual cada minuto
    static datetime lastDebugLog = 0;
    datetime currentTime = TimeCurrent();

    if(currentTime - lastDebugLog >= 60 && LogLevel >= LOG_DEBUG) {
        MqlDateTime dt;
        TimeToStruct(currentTime, dt);
        LogMessage("🕐 HORA ACTUAL: " + IntegerToString(dt.hour) + ":" +
                   IntegerToString(dt.min) + " | Zona calculada: " +
                   (g_ZoneCalculated ? "SÍ" : "NO"), LOG_DEBUG);
        lastDebugLog = currentTime;
    }

    // Reset if new day
    datetime currentDate = iTime(_Symbol, PERIOD_D1, 0);
    static datetime lastCalculationDate = 0;

    if(currentDate != lastCalculationDate) {
        g_ZoneCalculated = false;
        g_Zone815High = 0.0;
        g_Zone830Low = 0.0;
        g_ClosesAboveZone = 0;
        g_ClosesBelowZone = 0;
        g_ZoneInverted = false;
        lastCalculationDate = currentDate;
        LogMessage("🔄 NUEVO DÍA - Reset zona pre-market", LOG_INFO);
    }

    if(g_ZoneCalculated) return;

    // Step 1: Capture 8:15 AM candle CLOSED
    if(g_Zone815High == 0.0 && HasCandleClosedAt(8, 15)) {
        double open815 = iOpen(_Symbol, PERIOD_M1, 1);
        double close815 = iClose(_Symbol, PERIOD_M1, 1);
        g_Zone815High = MathMax(open815, close815);
        g_Zone815Time = iTime(_Symbol, PERIOD_M1, 1); // Time de la vela cerrada
        LogMessage("📍 ZONA 8:15 AM - Body HIGH capturado: " +
                   DoubleToString(g_Zone815High, _Digits), LOG_INFO);
    }

    // Step 2: Capture 8:30 AM candle CLOSED
    if(g_Zone830Low == 0.0 && g_Zone815High > 0.0 && HasCandleClosedAt(8, 30)) {
        double open830 = iOpen(_Symbol, PERIOD_M1, 1);
        double close830 = iClose(_Symbol, PERIOD_M1, 1);
        g_Zone830Low = MathMin(open830, close830);
        g_Zone830Time = iTime(_Symbol, PERIOD_M1, 1);

        // Define zone levels
        if(g_Zone830Low > g_Zone815High) {
            g_ZoneUpperLevel = g_Zone830Low;
            g_ZoneLowerLevel = g_Zone815High;
            g_ZoneInverted = true;
            LogMessage("⚠️ ZONA INVERTIDA (GAP detectado)", LOG_WARNING);
        } else {
            g_ZoneUpperLevel = g_Zone815High;
            g_ZoneLowerLevel = g_Zone830Low;
            g_ZoneInverted = false;
            LogMessage("✅ ZONA PRE-MARKET CALCULADA", LOG_INFO);
        }

        LogMessage("   Upper: " + DoubleToString(g_ZoneUpperLevel, _Digits) +
                  " | Lower: " + DoubleToString(g_ZoneLowerLevel, _Digits), LOG_INFO);
        LogMessage("   Tamaño: " + DoubleToString((g_ZoneUpperLevel - g_ZoneLowerLevel)/_Point, 1) + " pips", LOG_INFO);

        g_ZoneCalculated = true;
        g_SignalPeriodActive = true;
    }
}
```

---

## 📋 PLAN DE IMPLEMENTACIÓN

### **PASO 1: Renombrar Función**
```mql5
// ELIMINAR:
bool IsSpecificNYTimeCandle(int targetHour, int targetMinute)

// AGREGAR:
bool HasCandleClosedAt(int targetHour, int targetMinute)
```

### **PASO 2: Implementar Nueva Lógica**
- Detectar cuando YA PASÓ el minuto target
- Retornar true si `dt.hour == brokerHour && dt.min > targetMinute`
- Retornar true si `dt.hour > brokerHour`

### **PASO 3: Cambiar Index 0 → Index 1**
- En CalculatePreMarketZone(): Cambiar todos los `iOpen/iClose(..., 0)` a `(..., 1)`
- Cambiar `g_Zone815Time = TimeCurrent()` a `iTime(_Symbol, PERIOD_M1, 1)`

### **PASO 4: Agregar Logs de Diagnóstico**
- Log de hora actual cada minuto (si LogLevel = DEBUG)
- Log de reset diario
- Log detallado de zona calculada

### **PASO 5: Recompilar**
- Guardar cambios
- Compilar v1.4
- Verificar 0 errors, 0 warnings

### **PASO 6: Testing**
- Ejecutar backtest con LogLevel = 2 (DEBUG)
- Verificar en Journal:
  - ✅ Logs de hora actual cada minuto
  - ✅ Detección de vela 8:15
  - ✅ Detección de vela 8:30
  - ✅ Zona calculada correctamente
  - ✅ Señales de 2 cierres
  - ✅ Trades ejecutados

---

## 🎯 RESULTADOS ESPERADOS DESPUÉS DE LA CORRECCIÓN

### **En el Journal verás:**
```
[2025.01.02 08:14] 🕐 HORA ACTUAL: 8:14 | Zona calculada: NO
[2025.01.02 08:15] 🕐 HORA ACTUAL: 8:15 | Zona calculada: NO
[2025.01.02 08:16] 🕐 HORA ACTUAL: 8:16 | Zona calculada: NO
[2025.01.02 08:16] 📍 ZONA 8:15 AM - Body HIGH capturado: 25620.50
[2025.01.02 08:17] 🕐 HORA ACTUAL: 8:17 | Zona calculada: NO
...
[2025.01.02 08:30] 🕐 HORA ACTUAL: 8:30 | Zona calculada: NO
[2025.01.02 08:31] 🕐 HORA ACTUAL: 8:31 | Zona calculada: NO
[2025.01.02 08:31] 📍 ZONA 8:30 AM - Body LOW capturado: 25610.30
[2025.01.02 08:31] ✅ ZONA PRE-MARKET CALCULADA
[2025.01.02 08:31]    Upper: 25620.50 | Lower: 25610.30
[2025.01.02 08:31]    Tamaño: 10.2 pips
[2025.01.02 08:35] 📈 Cierre #1 ENCIMA de zona: 25625.70
[2025.01.02 08:38] 📈 Cierre #2 ENCIMA de zona: 25630.20
[2025.01.02 08:38] 🚀 SEÑAL COMPRA CONFIRMADA: 2 cierres por encima
[2025.01.02 08:38] ✅ COMPRA EJECUTADA - Ticket #1
```

---

## ⚠️ RIESGOS Y CONSIDERACIONES

### **Riesgo 1: BrokerGMTOffset Incorrecto**
Si `BrokerGMTOffset = 0` no es correcto para los datos históricos:
- **Síntoma:** Detecta velas pero en horario equivocado
- **Solución:** Verificar offset del broker en backtest
- **Prueba:** Con logs veremos si detecta a las 12:15 GMT (correcto) o en otro horario

### **Riesgo 2: Datos de Vela Index 1 No Disponibles**
Si en algún momento no hay suficientes velas en historial:
- **Solución:** Agregar validación `if(Bars(_Symbol, PERIOD_M1) < 2) return;`

---

## 🔧 SIGUIENTE ACCIÓN

**PROCEDER CON LA IMPLEMENTACIÓN:**
1. Implementar correcciones en SimpleNY200_v1.4.mq5
2. Recompilar
3. Ejecutar backtest con LogLevel = 2
4. Analizar logs para confirmar corrección

---

**Prioridad:** 🔴 CRÍTICA
**Tiempo estimado:** 15-20 minutos
**Impacto:** 100% - Sin esta corrección, el EA no funcionará

---

¿Procedo con la implementación de las correcciones?

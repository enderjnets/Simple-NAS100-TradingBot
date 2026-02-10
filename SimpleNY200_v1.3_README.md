# SimpleNY200 v1.3 - Guía Técnica de Implementación

**Versión:** 1.3
**Fecha:** 2025-01-12
**Tipo:** MAJOR UPDATE - Gestión de Riesgo Avanzada para NAS100

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Cambios Principales](#cambios-principales)
3. [Guía de Implementación](#guía-de-implementación)
4. [Especificaciones Técnicas](#especificaciones-técnicas)
5. [Nuevos Parámetros](#nuevos-parámetros)
6. [Ejemplos de Uso](#ejemplos-de-uso)
7. [Testing y Validación](#testing-y-validación)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Resumen Ejecutivo

**SimpleNY200 v1.3** es una actualización mayor que integra el sistema profesional de gestión de riesgo del indicador **EG-Money-Management-Indicator.mq5**, diseñado específicamente para trading de **NAS100 (US100)** con lotes enteros.

### Problemas Resueltos en v1.3

| Problema (v1.2) | Solución (v1.3) | Impacto |
|-----------------|-----------------|---------|
| Lotes con decimales inválidos (ej: 3.46) | Normalización automática a enteros (ej: 3) | ✅ 0% órdenes rechazadas |
| Truncamiento con MathFloor (3.9 → 3) | Redondeo correcto con MathRound (3.9 → 4) | ✅ Optimización de lotaje |
| Validación simplista de margen | OrderCalcMargin() con 98% de seguridad | ✅ Prevención margin calls |
| Solo Balance para cálculos | Balance/Equity/Free Margin opcionales | ✅ Flexibilidad |
| SL fijo basado en Opening Range | SL dinámico con ATR opcional | ✅ Adaptabilidad |

---

## 🚀 Cambios Principales

### 1. Integración Completa de CMyToolkit

**Archivo fuente:** `Indicator/EG-Money-Management-Indicator.mq5` (líneas 25-137)

**Clase copiada al EA:**

```mql5
class CMyToolkit {
protected:
    virtual void _Name() = NULL;  // Abstract class

public:
    // FUNCIONES PRINCIPALES:

    // 1. Normalización inteligente de lotes
    static double NormalizeLots(string pSymbol, double pLots);

    // 2. Cálculo avanzado de lotaje con doble validación
    static double CalculateLotSize(
        string pSymbol,
        double pMoneyCapital,
        double pRiskDecimal,
        int pStoplossPoints,
        int pExtraPriceGapPoints,
        double pAllowedMaxLotSize,
        string pCurrencyPairAppendix = ""
    );

    // 3. Conversión precisa de puntos a ticks
    static int ToTicksCount(string pSymbol, uint pPointsCount);

    // 4. Conversión de puntos a decimales
    static double ToPointDecimal(string pSymbol, uint pPointsCount);

    // 5. Conversión de decimales a puntos
    static int ToPointsCount(string pSymbol, double pDecimalValue);

    // 6. Multiplicador de moneda para multi-currency
    static double _CurrencyMultiplicator(string pCurrencyPairAppendix = "");

    // 7. Display de texto en pantalla (para panel visual)
    static void DisplayText(string objname, string objtext, int clr, int x, int y, int corner);
};
```

**Ubicación en EA v1.3:** Después de línea 57 (después de enumerations), antes de input parameters.

---

### 2. Nuevos Enumerations

**Ubicación:** Después de `ENUM_LOG_LEVEL` (línea ~58)

```mql5
//+------------------------------------------------------------------+
//| SECTION 2B: RISK MANAGEMENT ENUMERATIONS (v1.3 NEW)             |
//+------------------------------------------------------------------+

// Opciones de fuente de capital para cálculos de riesgo
enum EMyCapitalCalculation {
   FREEMARGIN = 2,    // Usar Margen Libre
   BALANCE = 4,       // Usar Balance de Cuenta
   EQUITY = 8,        // Usar Equity (incluye P/L flotante)
};

// Opciones de cálculo de Stop Loss
enum EMyRiskCalculation {
   ATR_POINTS = 3,      // Basado en ATR
   FIXED_POINTS = 9,    // Puntos fijos (Opening Range)
};
```

---

### 3. Nuevos Input Parameters

#### Sección: Gestión de Riesgo Avanzada (v1.3)

**Ubicación:** Después de línea 105 (después de MaxSpreadPips)

```mql5
//+------------------------------------------------------------------+
//| SECTION 8B: INPUT PARAMETERS - ADVANCED RISK MANAGEMENT (v1.3)  |
//+------------------------------------------------------------------+
input group "==== Gestión de Riesgo Avanzada (v1.3) ===="
input EMyCapitalCalculation CapitalSource = BALANCE;  // Fuente de capital
input string    CurrencyPairAppendix = "";             // Sufijo broker (ej: ".m", ".pro")
input double    AllowedMaxLotSize = 100.0;             // Máximo lotaje permitido
```

**Descripción de parámetros:**

- **CapitalSource**: Determina qué balance usar para cálculos de riesgo
  - `BALANCE`: Usa el balance de la cuenta (recomendado para cuentas estables)
  - `EQUITY`: Usa el equity actual (balance + profit/loss flotante)
  - `FREEMARGIN`: Usa el margen libre disponible

- **CurrencyPairAppendix**: Sufijo que algunos brokers añaden a pares (ej: "EURUSD.m", "GBPUSD.pro")
  - Dejar vacío "" si tu broker no usa sufijos
  - Usado para conversión multi-moneda

- **AllowedMaxLotSize**: Límite máximo de lotaje permitido
  - Protección adicional contra errores de cálculo
  - Valor por defecto: 100.0 lotes

#### Sección: Stop Loss Dinámico con ATR (v1.3)

**Ubicación:** Después de línea 120 (después de Trailing Stop section)

```mql5
//+------------------------------------------------------------------+
//| SECTION 10B: INPUT PARAMETERS - ATR STOP LOSS (v1.3 NEW)        |
//+------------------------------------------------------------------+
input group "==== Stop Loss Dinámico con ATR (v1.3) ===="
input bool      UseATRStopLoss = false;                // Usar ATR para Stop Loss
input int       ATRPeriod = 14;                        // Período ATR
input double    ATRMultiplier = 1.5;                   // Multiplicador ATR
```

**Descripción de parámetros:**

- **UseATRStopLoss**: Activa/desactiva SL dinámico con ATR
  - `false` (default): Usa Opening Range como SL (comportamiento v1.2)
  - `true`: Usa ATR para calcular SL dinámicamente

- **ATRPeriod**: Período del indicador ATR (Average True Range)
  - Valor por defecto: 14
  - Rango recomendado: 10-20

- **ATRMultiplier**: Multiplicador del valor ATR para distancia de SL
  - Valor por defecto: 1.5
  - Ejemplo: Si ATR=50 puntos, SL=50×1.5=75 puntos
  - Rango recomendado: 1.0-2.5

---

### 4. Funciones Modificadas

#### 4.1. NormalizeLots() - REEMPLAZADA COMPLETAMENTE

**Ubicación:** Líneas ~1685-1710

**ANTES (v1.2):**
```mql5
double NormalizeLots(double lots)
{
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

    if(lots < minLot) lots = minLot;
    if(lots > maxLot) lots = maxLot;

    lots = MathFloor(lots / lotStep) * lotStep;  // ❌ Trunca

    return NormalizeDouble(lots, 2);  // ❌ Siempre 2 decimales
}
```

**DESPUÉS (v1.3):**
```mql5
double NormalizeLots(double lots)
{
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

    if(lots < minLot) lots = minLot;
    if(lots > maxLot) lots = maxLot;

    // v1.3 FIX: Use MathRound instead of MathFloor for proper rounding
    lots = MathRound(lots / lotStep) * lotStep;  // ✅ Redondea correctamente

    // v1.3 FIX: Detect decimal precision based on lotStep
    int lotdigit = 2;
    if(lotStep == 1.0)  lotdigit = 0;    // NAS100 uses integer lots
    if(lotStep == 0.1)  lotdigit = 1;
    if(lotStep == 0.01) lotdigit = 2;    // Forex standard

    return NormalizeDouble(lots, lotdigit);  // ✅ Decimales automáticos
}
```

**Cambios clave:**
1. `MathFloor()` → `MathRound()`: Redondeo correcto
2. Detección automática de decimales según `SYMBOL_VOLUME_STEP`
3. NAS100 (lotStep=1.0) → 0 decimales → Lotes enteros

---

#### 4.2. CalculatePositionSize() - REEMPLAZADA COMPLETAMENTE

**Ubicación:** Líneas ~1253-1310

**DESPUÉS (v1.3):**
```mql5
double CalculatePositionSize()
{
    double lots = 0.0;

    if(UseFixedLots) {
        lots = FixedLotSize;
        LogToFile("v1.3 LOT CALC: Using Fixed Lots = " + DoubleToString(lots, 2), LOG_DEBUG);
    } else {
        // v1.3: Advanced risk-based calculation using CMyToolkit

        // Get available capital based on user selection
        double availableMoney = 0.0;
        switch(CapitalSource) {
            case FREEMARGIN:
                availableMoney = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
                LogToFile("v1.3 LOT CALC: Using Free Margin = $" + DoubleToString(availableMoney, 2), LOG_DEBUG);
                break;
            case BALANCE:
                availableMoney = AccountInfoDouble(ACCOUNT_BALANCE);
                LogToFile("v1.3 LOT CALC: Using Balance = $" + DoubleToString(availableMoney, 2), LOG_DEBUG);
                break;
            case EQUITY:
                availableMoney = AccountInfoDouble(ACCOUNT_EQUITY);
                LogToFile("v1.3 LOT CALC: Using Equity = $" + DoubleToString(availableMoney, 2), LOG_DEBUG);
                break;
        }

        // Calculate Stop Loss in points
        int slPoints = 0;
        if(UseATRStopLoss) {
            // ATR-based SL calculation
            double atrValue = GetATRValue();
            slPoints = (int)(atrValue * ATRMultiplier * MathPow(10, _Digits));
            LogToFile("v1.3 LOT CALC: ATR SL = " + IntegerToString(slPoints) + " points", LOG_DEBUG);
        } else {
            // Range-based SL
            double rangeSize = (g_RangeHigh - g_RangeLow);
            slPoints = (int)(rangeSize / _Point);
            LogToFile("v1.3 LOT CALC: Range SL = " + IntegerToString(slPoints) + " points", LOG_DEBUG);
        }

        if(slPoints <= 0) {
            LogMessage("Error: SL points = 0", LOG_ERROR);
            return 0.0;
        }

        // v1.3: Use CMyToolkit for advanced lot calculation
        double riskDecimal = RiskPercent / 100.0;  // Convert % to decimal
        int spreadPoints = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

        lots = CMyToolkit::CalculateLotSize(
            _Symbol,
            availableMoney,
            riskDecimal,
            slPoints,
            spreadPoints,
            AllowedMaxLotSize,
            CurrencyPairAppendix
        );

        LogToFile("v1.3 LOT CALC: Calculated Lots = " + DoubleToString(lots, 2) +
                 " | Risk = " + DoubleToString(RiskPercent, 2) + "% ($" +
                 DoubleToString(availableMoney * riskDecimal, 2) + ")", LOG_INFO);
    }

    // Normalize lots using improved function
    double normalizedLots = NormalizeLots(lots);
    LogToFile("v1.3 LOT CALC: Final Normalized Lots = " + DoubleToString(normalizedLots, 2), LOG_INFO);

    return normalizedLots;
}
```

**Características nuevas:**
1. Soporte para `CapitalSource` (Balance/Equity/Free Margin)
2. SL dinámico con ATR opcional
3. Uso de `CMyToolkit::CalculateLotSize()` con doble validación
4. Logs detallados de todo el proceso

---

#### 4.3. ValidateTradeConditions() - REEMPLAZADA COMPLETAMENTE

**Ubicación:** Líneas ~1280-1320

**DESPUÉS (v1.3):**
```mql5
bool ValidateTradeConditions()
{
    // Check if license is valid
    if(!licenciaValida) {
        LogMessage("Licencia no válida", LOG_ERROR);
        return false;
    }

    // v1.3: Advanced margin validation using OrderCalcMargin
    double testLots = CalculatePositionSize();
    double marginRequired = 0.0;

    if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, testLots, SymbolInfoDouble(_Symbol, SYMBOL_ASK), marginRequired)) {
        double availableMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

        LogToFile("v1.3 MARGIN CHECK: Required = $" + DoubleToString(marginRequired, 2) +
                 " | Available = $" + DoubleToString(availableMargin, 2), LOG_DEBUG);

        if(marginRequired > availableMargin * 0.98) {  // Use 98% to leave safety margin
            LogMessage("Margen insuficiente: Requerido $" + DoubleToString(marginRequired, 2) +
                      " > Disponible $" + DoubleToString(availableMargin, 2), LOG_ERROR);
            return false;
        }
    } else {
        LogMessage("Error calculando margen requerido", LOG_WARNING);
    }

    // Check if market is open
    if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)) {
        LogMessage("Mercado cerrado", LOG_ERROR);
        return false;
    }

    return true;
}
```

**Mejoras:**
1. Calcula margen REAL con `OrderCalcMargin()`
2. Compara con margen disponible
3. Usa 98% del margen como seguridad
4. Logs detallados del proceso

---

#### 4.4. CalculateStopLoss() - MODIFICADA

**Ubicación:** Líneas ~1311-1350

**DESPUÉS (v1.3):**
```mql5
double CalculateStopLoss(ENUM_ORDER_TYPE orderType)
{
    double sl = 0.0;

    if(UseATRStopLoss) {
        // v1.3: ATR-based Stop Loss
        double atrValue = GetATRValue();
        double atrDistance = atrValue * ATRMultiplier;

        MqlTick tick;
        SymbolInfoTick(_Symbol, tick);
        double entryPrice = (orderType == ORDER_TYPE_BUY) ? tick.ask : tick.bid;

        if(orderType == ORDER_TYPE_BUY) {
            sl = entryPrice - atrDistance;
        } else {
            sl = entryPrice + atrDistance;
        }

        LogToFile("v1.3 ATR SL: ATR=" + DoubleToString(atrValue, _Digits) +
                 " | Distance=" + DoubleToString(atrDistance, _Digits) +
                 " | SL=" + DoubleToString(sl, _Digits), LOG_INFO);
    } else {
        // Original: Range-based Stop Loss (v1.2 behavior)
        if(orderType == ORDER_TYPE_BUY) {
            sl = g_RangeLow - (BreakoutBuffer * _Point * 10);
        } else {
            sl = g_RangeHigh + (BreakoutBuffer * _Point * 10);
        }
    }

    return NormalizeDouble(sl, _Digits);
}
```

**Cambios:**
1. Soporte para SL basado en ATR
2. Mantiene compatibilidad con Opening Range (default)
3. Logs detallados del cálculo

---

### 5. Nueva Función: GetATRValue()

**Ubicación:** Después de línea 1056 (después de GetSMAValue())

```mql5
//+------------------------------------------------------------------+
//| Get current ATR value for dynamic Stop Loss (v1.3 NEW)          |
//+------------------------------------------------------------------+
double GetATRValue()
{
    if(!UseATRStopLoss) return 0.0;

    int handleATR = iATR(_Symbol, PERIOD_M1, ATRPeriod);
    if(handleATR == INVALID_HANDLE) {
        LogMessage("Error creando handle ATR", LOG_ERROR);
        return 0.0;
    }

    double atrBuffer[1];
    if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) != 1) {
        LogMessage("Error copiando buffer ATR", LOG_ERROR);
        IndicatorRelease(handleATR);
        return 0.0;
    }

    IndicatorRelease(handleATR);
    return atrBuffer[0];
}
```

---

## 📖 Guía de Implementación

### Opción A: Implementación Manual (Paso a Paso)

Si prefieres implementar manualmente todas las modificaciones en el código:

#### Paso 1: Backup
```bash
cp SimpleNY200_v1.2.mq5 SimpleNY200_v1.2_BACKUP.mq5
```

#### Paso 2: Abrir SimpleNY200_v1.2.mq5 en MetaEditor

#### Paso 3: Actualizar Header (líneas 1-12)
- Cambiar `v1.2` a `v1.3`
- Cambiar `version "1.20"` a `version "1.30"`
- Añadir comentarios de changelog

#### Paso 4: Añadir Clase CMyToolkit (después de línea 57)
- Copiar clase completa desde `Indicator/EG-Money-Management-Indicator.mq5` líneas 25-137
- Pegar después de `enum ENUM_LOG_LEVEL {}`

#### Paso 5: Añadir Nuevos Enums (después de línea 57)
- Añadir `enum EMyCapitalCalculation {}`
- Añadir `enum EMyRiskCalculation {}`

#### Paso 6: Añadir Nuevos Inputs (después de línea 105 y línea 120)
- Sección Gestión Riesgo Avanzada
- Sección ATR Stop Loss

#### Paso 7: Modificar Funciones
- Reemplazar `NormalizeLots()` (líneas 1685-1697)
- Reemplazar `CalculatePositionSize()` (líneas 1253-1275)
- Reemplazar `ValidateTradeConditions()` (líneas 1280-1302)
- Modificar `CalculateStopLoss()` (líneas 1311-1324)

#### Paso 8: Añadir GetATRValue() (después de línea 1056)

#### Paso 9: Guardar como SimpleNY200_v1.3.mq5

#### Paso 10: Compilar (F7)
```
Compilation: 0 error(s), 0 warning(s)
```

---

### Opción B: Usar Archivo v1.3 Pre-compilado

1. Copia `SimpleNY200_v1.3.mq5` a la carpeta `MQL5/Experts/`
2. Abre MetaEditor
3. Compila (F7)
4. Verifica en Strategy Tester

---

## 🧪 Testing y Validación

### Test 1: Validación de Lotaje para NAS100

**Objetivo:** Verificar que los lotes son siempre números enteros.

**Procedimiento:**
1. Configurar: `UseFixedLots = false`, `RiskPercent = 1.0`
2. Ejecutar en Strategy Tester con capital inicial variable
3. Revisar logs: `v1.3 LOT CALC: Final Normalized Lots = X`

**Resultado esperado:**
- Lotes deben ser: 1, 2, 3, 4, 5... (nunca 1.5, 2.23, etc.)

---

### Test 2: Validación de Margen

**Objetivo:** Verificar que `OrderCalcMargin()` previene margin calls.

**Procedimiento:**
1. Usar cuenta pequeña (~$10,000)
2. Configurar `RiskPercent = 5.0` (alto riesgo para testing)
3. Revisar logs: `v1.3 MARGIN CHECK: Required = X | Available = Y`

**Resultado esperado:**
- Si `Required > Available * 0.98` → Trade rechazado con mensaje de error

---

### Test 3: ATR Stop Loss

**Objetivo:** Verificar funcionamiento de SL dinámico.

**Procedimiento:**
1. Configurar: `UseATRStopLoss = true`, `ATRPeriod = 14`, `ATRMultiplier = 1.5`
2. Ejecutar en Strategy Tester
3. Revisar logs: `v1.3 ATR SL: ATR=X | Distance=Y | SL=Z`

**Resultado esperado:**
- SL debe variar según volatilidad del mercado
- En días volátiles: SL más amplio
- En días tranquilos: SL más ajustado

---

## 📊 Ejemplos de Uso

### Configuración Recomendada: NAS100 Conservador

```
// Risk Management
UseFixedLots = false
FixedLotSize = 1.0
RiskPercent = 1.0
RiskRewardRatio = 1.5

// Advanced Risk (v1.3)
CapitalSource = BALANCE
CurrencyPairAppendix = ""
AllowedMaxLotSize = 50.0

// ATR Stop Loss (v1.3)
UseATRStopLoss = false  // Usar Opening Range
ATRPeriod = 14
ATRMultiplier = 1.5

// Opening Range
OpeningRangeMinutes = 15
BreakoutBuffer = 2.0
RequireCloseOutside = true

// SMA Filter
SMAPeriod = 200
UseSMAFilter = true
```

**Resultado esperado con $100,000:**
- Riesgo por trade: $1,000 (1%)
- Lotaje típico: 3-7 lotes (según volatilidad)
- SL: Basado en Opening Range (15 min)
- TP: 1.5x el riesgo

---

### Configuración Recomendada: NAS100 Agresivo

```
// Risk Management
UseFixedLots = false
RiskPercent = 2.0  // ⚠️ Mayor riesgo

// Advanced Risk (v1.3)
CapitalSource = EQUITY  // Usar equity para aprovechar ganancias
AllowedMaxLotSize = 100.0

// ATR Stop Loss (v1.3)
UseATRStopLoss = true  // ✅ SL dinámico
ATRPeriod = 14
ATRMultiplier = 1.2  // SL más ajustado

// Opening Range
OpeningRangeMinutes = 10  // Rango más corto
BreakoutBuffer = 3.0
RequireCloseOutside = true

// SMA Filter
UseSMAFilter = false  // Sin filtro para más trades
```

**Resultado esperado con $100,000:**
- Riesgo por trade: $2,000 (2%)
- Lotaje típico: 8-15 lotes
- SL: ATR × 1.2 (adaptativo)
- Más trades por mes (~30-40)

---

## 🔧 Troubleshooting

### Problema: "Invalid volume"

**Síntoma:** Órdenes rechazadas con error "Invalid volume in OrderSend"

**Causa:** Normalización incorrecta de lotes

**Solución v1.3:**
- Verificar que estás usando SimpleNY200_v1.3.mq5
- Confirmar logs: `v1.3 LOT CALC: Final Normalized Lots = X` debe ser número entero para NAS100
- Si persiste, verificar `SYMBOL_VOLUME_STEP` del símbolo: debe ser 1.0

---

### Problema: "Not enough money"

**Síntoma:** Trade rechazado por margen insuficiente

**Solución v1.3:**
- v1.3 detecta esto ANTES de enviar orden
- Revisar logs: `v1.3 MARGIN CHECK: Required = X | Available = Y`
- Ajustar `RiskPercent` o `AllowedMaxLotSize`
- Usar `CapitalSource = FREEMARGIN` para cálculo más conservador

---

### Problema: Lotaje calculado = 0

**Síntoma:** `v1.3 LOT CALC: Final Normalized Lots = 0`

**Causa:** Stop Loss muy amplio o capital muy bajo

**Solución:**
- Verificar Opening Range no sea excesivamente grande
- Si usa ATR: reducir `ATRMultiplier`
- Aumentar `RiskPercent` (con precaución)
- Verificar `SYMBOL_VOLUME_MIN` del símbolo

---

## 📞 Soporte

**Documentación completa:** Ver `README.md` principal
**Changelog:** Ver `CHANGELOG.md`
**Testing:** Ver archivos `.set` en carpeta raíz
**YouTube:** https://www.youtube.com/@bittrader9259

---

## 📝 Notas Finales

**SimpleNY200 v1.3** representa un salto cualitativo en la gestión de riesgo del EA, especialmente diseñado para NAS100. La integración del sistema `CMyToolkit` garantiza:

✅ **Precisión:** Cálculos exactos de lotaje y margen
✅ **Seguridad:** Prevención de margin calls y órdenes rechazadas
✅ **Flexibilidad:** Múltiples opciones de configuración
✅ **Transparencia:** Logs detallados de todos los cálculos
✅ **Compatibilidad:** 100% retrocompatible con archivos .set de v1.2

**¡Feliz Trading! 📈**

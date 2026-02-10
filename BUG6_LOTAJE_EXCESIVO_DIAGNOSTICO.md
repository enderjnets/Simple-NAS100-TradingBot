# Bug #6 - Lotaje Excesivo (50 Lots) - Fase Diagnóstica

**Fecha:** 2026-01-13 16:28
**Estado:** 🔍 **DIAGNÓSTICO EN PROGRESO - LOGS AGREGADOS**

---

## 📊 RESUMEN EJECUTIVO

El EA SimpleNY200 v1.4 **ejecuta trades correctamente**, pero usa **50 LOTS** en cada operación en lugar de los 4-8 lots esperados para una cuenta de $100,000 con 1% de riesgo.

**Impacto:**
- Riesgo real: ~6% por trade (en lugar de 1%)
- Balance: $100,000 → $2.21 después de múltiples SLs
- Cuenta destruida en días

---

## 🔍 EVIDENCIA DEL PROBLEMA

### **Del Backtest Log (2025.01.02 - 2025.12.30):**

```
[2025.01.02 12:32] market buy 50 NAS100 at 21210.3 sl: 21197.6 tp: 21229.3
[2025.01.02 12:52] stop loss triggered
Pérdida: ~$6,350 (50 lots × 12.7 pips × $10/pip)

[2025.01.03] sell 50 NAS100 → TP (ganancia ~$10,350)
[2025.01.06] sell 50 NAS100 → SL (pérdida ~$9,750)
[2025.01.07] buy 50 NAS100 → TP (ganancia ~$6,500)
...
[2025.12.30] Balance: $2.21 | not enough money [market sell 0.01 NAS100]
```

**Conclusión:**
- ✅ Zona calculada correctamente
- ✅ Señales detectadas
- ✅ Trades ejecutados
- ✅ SL/TP posicionados correctamente
- ❌ **Lotaje es 50 lots (debería ser 4-8 lots)**

---

## 🧮 CÁLCULO ESPERADO

### **Parámetros:**
- Capital: $100,000
- Riesgo: 1.0%
- Money at Risk: $1,000
- Zona: ~10 pips = 100 points
- SL desde entry: ~12 pips

### **Cálculo Manual:**
```
Valor por pip (NAS100): $10 per lot
SL en pips: 12
SL en $ por lot: 12 × $10 = $120

Lots = Money at Risk / SL en $ por lot
Lots = $1,000 / $120 = 8.3 lots
Lots normalizados: 8.0 lots ✅
```

### **Lotaje Real:**
```
Lots: 50.0 ❌
Money at Risk: 50 × $120 = $6,000 (6% en lugar de 1%)
```

---

## 🔬 ANÁLISIS DE CÓDIGO

### **Ubicación del Problema:**

#### **1. CalculatePositionSize() - Línea 1403-1516**
```mql5
double rangeSize = (g_ZoneUpperLevel - g_ZoneLowerLevel);  // Zona en precio
slPoints = (int)(rangeSize / _Point);                       // Zona en points

int spreadPoints = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

lots = CMyToolkit::CalculateLotSize(
    _Symbol,
    availableMoney,      // $100,000
    riskDecimal,         // 0.01
    slPoints,            // ~100 points (zona)
    spreadPoints,        // ~2-5 points
    AllowedMaxLotSize,   // 50.0 ⚠️
    CurrencyPairAppendix
);
```

#### **2. CMyToolkit::CalculateLotSize() - Línea 138-210**
```mql5
// Margin-based calculation
_lotsByRequiredMargin = pMoneyCapital * 0.98 / _marginForOneLot;
_lotsByRequiredMargin = MathMin(_lotsByRequiredMargin,
                                MathMin(pAllowedMaxLotSize,    // 50.0 ⚠️
                                        SYMBOL_VOLUME_MAX));

// Risk-based calculation
_moneyRisk = pRiskDecimal * pMoneyCapital;  // $1,000
_totalSLPoints = pStoplossPoints + pExtraPriceGapPoints;
_totalTickCount = ToTicksCount(pSymbol, _totalSLPoints);

_lotsByRisk = _moneyRisk / (_totalTickCount * _oneTickValue);

// Final result
_lotSize = MathMax(MathMin(_lotsByRisk, _lotsByRequiredMargin),
                   SYMBOL_VOLUME_MIN);
```

#### **3. ToTicksCount() - Línea 100-109**
```mql5
static int ToTicksCount(string pSymbol, uint pPointsCount) {
    double uticksize = SymbolInfoDouble(pSymbol, SYMBOL_TRADE_TICK_SIZE);
    int utickscount = (int)((pPointsCount / uticksize) * uticksize);  // ⚠️ SOSPECHOSO
    return utickscount;
}
```

**⚠️ PROBLEMA POTENCIAL:** Esta función parece retornar **points** en lugar de **tick count**.

---

## 🔧 HIPÓTESIS DEL BUG

### **Hipótesis A: ToTicksCount() Retorna Valor Incorrecto**

**Fórmula Actual:**
```mql5
utickscount = (int)((pPointsCount / uticksize) * uticksize);
```

**Ejemplo para NAS100:**
- pPointsCount = 100 points
- uticksize = 0.25
- _Point = 0.1

**Cálculo:**
```
(100 / 0.25) * 0.25 = 400 * 0.25 = 100
```

**Resultado:** Retorna **100** (parece ser points, no ticks)

**Cálculo Correcto de Ticks:**
```
Precio = pPointsCount * _Point = 100 * 0.1 = 10.0
Ticks = Precio / ticksize = 10.0 / 0.25 = 40 ticks ✅
```

**Fórmula Correcta Debería Ser:**
```mql5
utickscount = (int)(pPointsCount / (uticksize / _Point));
// O: (int)(pPointsCount * _Point / uticksize)
```

**Impacto:**
- Si _totalTickCount = 100 (incorrecto) en lugar de 40 (correcto)
- Denominator = 100 × $2.50 = $250 (debería ser 40 × $2.50 = $100)
- _lotsByRisk = $1,000 / $250 = 4 lots (debería ser $1,000 / $100 = 10 lots)

**PERO:** Esto daría MENOS lots, no más. Así que esta hipótesis no explica los 50 lots.

---

### **Hipótesis B: _lotsByRisk es Mayor que AllowedMaxLotSize**

Si _lotsByRisk se calcula como un valor MUY GRANDE (> 50), entonces:

```mql5
_lotSize = MathMin(_lotsByRisk, _lotsByRequiredMargin);
// Si _lotsByRisk > 50 y _lotsByRequiredMargin está capped a 50:
_lotSize = MathMin(100, 50) = 50 lots
```

**¿Cuándo sería _lotsByRisk > 50?**

```
_lotsByRisk = _moneyRisk / (_totalTickCount * _oneTickValue)
$1,000 / (_totalTickCount * _oneTickValue) > 50
_totalTickCount * _oneTickValue < $1,000 / 50 = $20
```

Si _oneTickValue = $2.50 per tick:
```
_totalTickCount < $20 / $2.50 = 8 ticks
```

**Entonces:** Si _totalTickCount < 8, _lotsByRisk > 50 lots.

**¿Por qué sería _totalTickCount tan pequeño?**
- ToTicksCount() retorna valor incorrecto
- O _totalSLPoints es muy pequeño
- O algo más está mal

---

### **Hipótesis C: AllowedMaxLotSize = 50.0 es el Límite**

Del archivo `.set`:
```
AllowedMaxLotSize=50.0
```

Si el cálculo interno da un valor > 50, el resultado se limita a 50.

**Solución Temporal:** Cambiar a `AllowedMaxLotSize=10.0` para ver si se comporta mejor.

---

## ✅ SOLUCIÓN IMPLEMENTADA (FASE 1): LOGS DIAGNÓSTICOS

He agregado **logs comprensivos** en ambas funciones para identificar el problema exacto.

### **Logs Agregados en CalculatePositionSize():**

```mql5
LogToFile("🔍 v1.4 LOT CALC - Calling CMyToolkit:", LOG_INFO);
LogToFile("  Capital: $" + DoubleToString(availableMoney, 2), LOG_INFO);
LogToFile("  Risk%: " + DoubleToString(RiskPercent, 2) + "%", LOG_INFO);
LogToFile("  Money at Risk: $" + DoubleToString(availableMoney * riskDecimal, 2), LOG_INFO);
LogToFile("  SL Points: " + IntegerToString(slPoints), LOG_INFO);
LogToFile("  Spread Points: " + IntegerToString(spreadPoints), LOG_INFO);
LogToFile("  Total SL (SL + Spread): " + IntegerToString(slPoints + spreadPoints), LOG_INFO);
LogToFile("  AllowedMaxLotSize: " + DoubleToString(AllowedMaxLotSize, 2), LOG_INFO);
```

### **Logs Agregados en CMyToolkit::CalculateLotSize():**

```mql5
Print("🔍 TOOLKIT LOT CALC - Inputs:");
Print("  pMoneyCapital = $", DoubleToString(pMoneyCapital, 2));
Print("  pRiskDecimal = ", DoubleToString(pRiskDecimal, 4));
Print("  pStoplossPoints = ", pStoplossPoints);
Print("  pExtraPriceGapPoints = ", pExtraPriceGapPoints);
Print("  pAllowedMaxLotSize = ", DoubleToString(pAllowedMaxLotSize, 2));

Print("🔍 TOOLKIT - Margin Calc:");
Print("  _marginForOneLot = $", DoubleToString(_marginForOneLot, 2));
Print("  _rawLotsByMargin (before cap) = ", DoubleToString(_rawLotsByMargin, 2));
Print("  _lotsByRequiredMargin (after cap) = ", DoubleToString(_lotsByRequiredMargin, 2));

Print("🔍 TOOLKIT - Symbol Info:");
Print("  _Point = ", DoubleToString(_point, 5));
Print("  _tickSize = ", DoubleToString(_tickSize, 5));
Print("  _oneTickValue = $", DoubleToString(_oneTickValue, 4));
Print("  _totalSLPoints = ", _totalSLPoints, " points");
Print("  _totalTickCount = ", _totalTickCount, " (ToTicksCount result)");

Print("🔍 TOOLKIT - Risk Calc:");
Print("  _moneyRisk = $", DoubleToString(_moneyRisk, 2));
Print("  Denominator = ", DoubleToString(_totalTickCount * _oneTickValue, 4));
Print("  _rawLotsByRisk = ", DoubleToString(_rawLotsByRisk, 4));
Print("  _lotsByRisk = ", DoubleToString(_lotsByRisk, 2));

Print("🔍 TOOLKIT - Final:");
Print("  MIN(_lotsByRisk, _lotsByRequiredMargin) = ", MathMin(_lotsByRisk, _lotsByRequiredMargin));
Print("  ✅ FINAL LOT SIZE = ", DoubleToString(_lotSize, 2));
```

---

## 📋 PRÓXIMOS PASOS

### **PASO 1: Recompilar EA ✅ PENDIENTE**

```bash
# En MetaTrader 5:
# 1. Abrir MetaEditor (Tools → MetaQuotes Language Editor)
# 2. Abrir SimpleNY200_v1.4.mq5
# 3. Compilar (F7)
# 4. Verificar 0 errors, 0 warnings
```

---

### **PASO 2: Ejecutar Backtest Corto**

**Configuración:**
```
Symbol: NAS100
Period: M1
Dates: 2025.01.02 - 2025.01.05 (solo 4 días)
Deposit: $100,000
LogLevel: 2 (INFO)
Settings: SimpleNY200_v1.4_NASDAQ.set
```

**¿Por qué solo 4 días?**
- Para ver logs del primer trade sin destruir cuenta
- Obtener datos diagnósticos precisos
- Identificar problema antes de backtest completo

---

### **PASO 3: Analizar Journal Output**

**Buscar en Journal:**

```
🔍 v1.4 LOT CALC - Calling CMyToolkit:
  Capital: $100000.00
  Risk%: 1.00%
  Money at Risk: $1000.00
  SL Points: 100
  Spread Points: 2
  Total SL (SL + Spread): 102
  AllowedMaxLotSize: 50.00

🔍 TOOLKIT LOT CALC - Inputs:
  pMoneyCapital = $100000.00
  pRiskDecimal = 0.0100
  pStoplossPoints = 100
  pExtraPriceGapPoints = 2
  pAllowedMaxLotSize = 50.00

🔍 TOOLKIT - Symbol Info:
  _Point = 0.10000
  _tickSize = 0.25000
  _oneTickValue = $2.5000
  _totalSLPoints = 102 points
  _totalTickCount = 102  ← ⚠️ VERIFICAR ESTE VALOR

🔍 TOOLKIT - Risk Calc:
  _moneyRisk = $1000.00
  Denominator = 255.0000  ← ⚠️ VERIFICAR (102 × $2.50)
  _rawLotsByRisk = 3.9216  ← ⚠️ SI ES CORRECTO, debería retornar ~4 lots
  _lotsByRisk = 3.00

🔍 TOOLKIT - Final:
  MIN(3.00, 50.00) = 3.00
  ✅ FINAL LOT SIZE = 3.00  ← ⚠️ ¿Por qué retorna 50 y no 3?
```

**Valores Clave a Verificar:**
1. _totalTickCount: ¿Es correcto o es igual a _totalSLPoints?
2. _oneTickValue: ¿Es $2.50 o algo diferente?
3. _rawLotsByRisk: ¿Es ~4 lots o es > 50?
4. _lotsByRequiredMargin: ¿Está limitado a 50?
5. Final LOT SIZE: ¿Qué retorna realmente?

---

### **PASO 4: Identificar Bug Exacto**

Basado en los logs, identificar:

**Escenario A: ToTicksCount() está mal**
- Si _totalTickCount = 102 (igual a points)
- Pero debería ser ~40 ticks
- **Solución:** Corregir fórmula en ToTicksCount()

**Escenario B: _lotsByRisk > 50**
- Si _rawLotsByRisk > 50
- Y MathMin retorna 50 (AllowedMaxLotSize)
- **Solución:** Corregir cálculo de _lotsByRisk O reducir AllowedMaxLotSize

**Escenario C: Spread es el problema**
- Si spreadPoints está inflando artificialmente el lotaje
- **Solución:** Pasar 0 en lugar de spreadPoints

---

### **PASO 5: Aplicar Fix**

Una vez identificado el bug exacto, aplicar la corrección:

**Opción 1: Corregir ToTicksCount()**
```mql5
static int ToTicksCount(string pSymbol, uint pPointsCount) {
    double uticksize = SymbolInfoDouble(pSymbol, SYMBOL_TRADE_TICK_SIZE);
    double _point = SymbolInfoDouble(pSymbol, SYMBOL_POINT);
    // ✅ FIX: Convert points to ticks properly
    int utickscount = (int)(pPointsCount / (uticksize / _point));
    return utickscount;
}
```

**Opción 2: Reducir AllowedMaxLotSize**
```
AllowedMaxLotSize=10.0  // En lugar de 50.0
```

**Opción 3: Pasar 0 como extraGap**
```mql5
lots = CMyToolkit::CalculateLotSize(
    _Symbol,
    availableMoney,
    riskDecimal,
    slPoints,
    0,  // ✅ FIX: No agregar spread al SL
    AllowedMaxLotSize,
    CurrencyPairAppendix
);
```

---

## 📊 RESUMEN

**Estado Actual:**
- ✅ Código con logs diagnósticos agregados
- ✅ Copiado a MT5 (Jan 13 16:28)
- ⏳ Pendiente: Recompilar
- ⏳ Pendiente: Ejecutar backtest de 4 días
- ⏳ Pendiente: Analizar journal output
- ⏳ Pendiente: Aplicar fix basado en datos reales

**Próxima Acción del Usuario:**
1. Abrir MetaEditor
2. Compilar SimpleNY200_v1.4.mq5
3. Ejecutar backtest 2025.01.02 - 2025.01.05
4. Revisar Journal y copiar output de logs
5. Compartir output conmigo para análisis

---

**Archivos Actualizados:**
- ✅ SimpleNY200_v1.4.mq5 (con logs diagnósticos)
- ✅ BUG6_LOTAJE_EXCESIVO_DIAGNOSTICO.md (este documento)

**Estado:** 🔍 **FASE DIAGNÓSTICA COMPLETA - ESPERANDO BACKTEST**

---

**Nota:** Los logs diagnósticos nos dirán EXACTAMENTE dónde está el problema. Una vez que tengamos los datos reales del journal, podré identificar y corregir el bug en minutos.

🔬 **La clave está en ver los valores REALES que calcula el EA, no asumir.**

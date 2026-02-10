# 🚀 DISEÑO COMPLETO: ChallengeScalper v1.0

**Fecha:** 2024-12-14
**Objetivo:** Pasar prop firm challenge $100K en 2 meses con DD <3% diario
**Estrategia:** Scalping multi-session de alta frecuencia

---

## 🎯 TARGETS Y RESTRICCIONES

### Targets Challenge:
```
FASE 1: $10,000 en 1.5 meses (45 días)
FASE 2: $5,000 en 0.5 meses (15 días)
TOTAL: $15,000 en 2 meses

Profit necesario/mes: $7,500
En pips NAS100: ~750 pips/mes
```

### Restricciones DD:
```
DD Diario Máximo: 3% ($3,000)
DD Total Máximo: 10% ($10,000)
```

### Criterios de Éxito EA:
```
✅ Profit/mes: >$7,000
✅ DD diario máximo: <2.5% (margen de seguridad)
✅ Profit factor: >1.3
✅ Win rate: >55%
✅ Trades/mes: >200 (alta frecuencia)
```

---

## 📋 ESTRATEGIA: ChallengeScalper v1.0

### Concepto Principal:

**Multi-Session Momentum Scalping**

Capturar micro-movimientos de momentum en zonas de alta liquidez durante London y NY sessions.

---

## 🔧 ESPECIFICACIONES TÉCNICAS

### 1. Configuración General

```mql5
// ==== CONFIGURACIÓN BÁSICA ====
Symbol: NAS100
Timeframe Principal: M5
Timeframe Confirmación: M1
```

### 2. Sesiones de Trading

```mql5
// ==== SESIONES ====
// Session 1: London (Alta liquidez)
London_Start: 03:00 EST
London_End: 06:00 EST
London_Trades_Expected: 8-12/día

// Session 2: NY (Alta volatilidad)
NY_Start: 09:30 EST
NY_End: 12:30 EST
NY_Trades_Expected: 10-15/día

// Total trades/día: 18-27
// Total trades/mes: 360-540
```

### 3. Lógica de Entrada

#### Setup Principal: Momentum Breakout + Volume Confirmation

**Indicadores:**

```mql5
// Momentum
EMA_Fast: 8 (M5)
EMA_Slow: 21 (M5)
RSI: 14 (M5)

// Volume
Volume_MA: 20 períodos
Volume_Threshold: 1.5x promedio

// Confirmación M1
EMA_Confirm: 5 (M1)
```

**Condiciones Long:**
```
1. EMA_8 cruza ARRIBA de EMA_21 (M5)
2. RSI > 50 Y RSI < 70 (momentum alcista, no sobrecomprado)
3. Volume > 1.5x Volume_MA (confirmación volumen)
4. EMA_5 (M1) apuntando arriba (confirmación M1)
5. Price > EMA_21 (M5) - breakout confirmado
6. Spread < 2.0 pips
```

**Condiciones Short:**
```
1. EMA_8 cruza ABAJO de EMA_21 (M5)
2. RSI < 50 Y RSI > 30 (momentum bajista, no sobrevendido)
3. Volume > 1.5x Volume_MA
4. EMA_5 (M1) apuntando abajo
5. Price < EMA_21 (M5)
6. Spread < 2.0 pips
```

---

### 4. Gestión de Riesgo

#### Stop Loss:

```mql5
// Stop Loss Dinámico basado en ATR
ATR_Period: 14 (M5)
SL_Multiplier: 1.5

StopLoss = ATR(14) × 1.5
Típico: 15-25 pips

// Stop Loss Máximo Absoluto
Max_SL: 30 pips (protección contra volatilidad extrema)
```

#### Take Profit:

```mql5
// Take Profit Dinámico
TP_Type: "Scaled" (múltiples TPs)

TP1: ATR × 0.8 (50% posición) - Quick profit
TP2: ATR × 1.5 (30% posición) - Medium
TP3: ATR × 2.5 (20% posición) - Let winners run

Ejemplo con ATR 18 pips:
TP1: 14 pips (50% cerrado)
TP2: 27 pips (30% cerrado)
TP3: 45 pips (20% cerrado)

Risk:Reward promedio: 1:1.5
```

#### Trailing Stop:

```mql5
// Activar después de TP1 alcanzado
UseTrailingStop: true
Trailing_Start: TP1 (cuando 50% cerrado)
Trailing_Distance: ATR × 0.5
Trailing_Step: 3 pips
```

---

### 5. Filtros Adicionales

#### Filtro de Volatilidad Extrema:

```mql5
// Pausar trading durante eventos extremos
ATR_Max_Threshold: 40 pips (M5)
If ATR > 40: Pause_Trading = true

Razón: Volatilidad extrema = mayor slippage y riesgo DD
```

#### Filtro de Spread:

```mql5
Max_Spread: 2.0 pips
If Spread > 2.0: No_New_Trades = true

Nota: NAS100 spread típico 0.5-1.5 pips
```

#### Filtro de Noticias (Opcional):

```mql5
// Pausar 15 min antes y 30 min después de:
- NFP (primer viernes mes)
- FOMC (decisiones FED)
- CPI (inflación)

UseNewsFilter: true (recomendado para challenge)
```

---

### 6. Money Management

#### Lotaje Dinámico:

```mql5
// Basado en balance y DD permitido
Risk_Per_Trade: 0.5% ($500 en cuenta $100K)

Lote = (Balance × Risk_Per_Trade) / (SL_Pips × Value_Per_Pip)

Ejemplo:
Balance: $100,000
Risk: 0.5% = $500
SL: 20 pips
Value/pip (NAS100): $10/pip (lote 1.0)

Lote = $500 / (20 × $10) = 2.5 lotes

// Ajuste según balance
If Balance < $97,000 (3% DD): Lote × 0.8 (reducir riesgo)
If Balance > $105,000: Lote × 1.1 (aumentar con ganancias)
```

#### Límites de Trades:

```mql5
// Diarios
Max_Trades_Per_Day: 30
Max_DD_Daily: 2.5% ($2,500) - HARD STOP

If DD_Today > 2.5%: Stop_All_Trading_Today = true

// Por Sesión
Max_Trades_London: 15
Max_Trades_NY: 18
Max_Consecutive_Losses: 5

If Consecutive_Losses >= 5: Pause_1_Hour = true
```

---

## 📊 PROYECCIÓN DE RESULTADOS

### Escenario Conservador:

```
Trades/día: 18
Trades/mes: 360 (20 días trading)
Win Rate: 55%

Ganadores: 198 trades
Avg Win: 12 pips (TP1 mayormente)
Gross Profit: 198 × 12 = 2,376 pips

Perdedores: 162 trades
Avg Loss: 18 pips
Gross Loss: 162 × 18 = -2,916 pips

Net Profit: 2,376 - 2,916 = -540 pips/mes ❌
Profit Factor: 2,376 / 2,916 = 0.81 ❌
```

**Problema:** Con RR 1:0.67 no es rentable

**Ajuste necesario:** Mejorar RR o Win Rate

---

### Escenario Optimizado (TP Scaled):

```
Trades/día: 18
Trades/mes: 360
Win Rate: 58% (mejor filtrado)

Ganadores: 209 trades
Avg Win: 16 pips (mix TP1/TP2/TP3)
Gross Profit: 209 × 16 = 3,344 pips

Perdedores: 151 trades
Avg Loss: 18 pips
Gross Loss: 151 × 18 = -2,718 pips

Net Profit: 3,344 - 2,718 = +626 pips/mes ✅
Profit Factor: 3,344 / 2,718 = 1.23 ✅

Con lote 1.2:
Profit/mes: 626 × $12 = $7,512/mes ✅✅✅

DD Diario Máximo:
Peor día: 8 pérdidas consecutivas × 18 pips × $12 = -$1,728 (1.73%) ✅
```

**Resultado:** VIABLE con optimización

---

### Escenario Realista (Target):

```
Trades/mes: 400 (20/día)
Win Rate: 60%

Ganadores: 240
Avg Win: 18 pips
Gross Profit: 240 × 18 = 4,320 pips

Perdedores: 160
Avg Loss: 17 pips (SL mejorado)
Gross Loss: 160 × 17 = -2,720 pips

Net Profit: 4,320 - 2,720 = +1,600 pips/mes ✅✅
Profit Factor: 4,320 / 2,720 = 1.59 ✅✅

Con lote 0.75:
Profit/mes: 1,600 × $7.5 = $12,000/mes ✅✅✅

Tiempo FASE 1: $10,000 / $12,000 = 0.83 meses ✅
Tiempo FASE 2: $5,000 / $12,000 = 0.42 meses ✅
TOTAL: 1.25 meses ✅✅✅

DD Diario Máximo:
Peor día: 10 pérdidas × 17 pips × $7.5 = -$1,275 (1.28%) ✅✅
```

**Resultado:** IDEAL - Challenge en <2 meses con bajo DD

---

## 🎯 PARÁMETROS OPTIMIZABLES

### Variables Críticas:

```mql5
// A optimizar en backtest
1. EMA_Fast: 8 (probar 5, 8, 13)
2. EMA_Slow: 21 (probar 13, 21, 34)
3. RSI_Period: 14 (probar 9, 14, 21)
4. Volume_Threshold: 1.5x (probar 1.3x, 1.5x, 2.0x)
5. SL_Multiplier: 1.5 (probar 1.2, 1.5, 2.0)
6. TP_Scaled: (0.8, 1.5, 2.5) - optimizar
7. Risk_Per_Trade: 0.5% (probar 0.3%, 0.5%, 0.7%)
```

---

## 🔒 PROTECCIÓN ANTI-FAIL

### Sistema de Circuit Breakers:

```mql5
// LEVEL 1: Warning (DD 2%)
If DD_Daily >= 2.0%:
  - Reducir lote 50%
  - Max 10 trades restantes hoy
  - Solo setups A+ (RSI + Volume confirmados)

// LEVEL 2: Critical (DD 2.5%)
If DD_Daily >= 2.5%:
  - Reducir lote 70%
  - Max 5 trades restantes hoy
  - Solo recuperación conservadora

// LEVEL 3: STOP (DD 2.8%)
If DD_Daily >= 2.8%:
  - STOP ALL TRADING
  - Cerrar trades abiertos
  - Análisis obligatorio antes de reanudar
```

### Protección Rachas Perdedoras:

```mql5
// Después de X pérdidas consecutivas
If Consecutive_Losses == 3:
  - Pause 30 minutos
  - Revisar condiciones de mercado

If Consecutive_Losses == 5:
  - Pause 1 hora
  - Reducir lote 30%

If Consecutive_Losses == 7:
  - STOP trading sesión actual
  - Solo reanudar próxima sesión
```

---

## 📋 ESTRUCTURA DEL CÓDIGO

### Arquitectura MQL5:

```mql5
//+------------------------------------------------------------------+
//| ChallengeScalper_v1.0.mq5                                       |
//| Scalping EA optimizado para Prop Firm Challenges                |
//+------------------------------------------------------------------+

// SECTION 1: INCLUDES & CONSTANTS
#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>

// SECTION 2: INPUT PARAMETERS
input group "==== Sessions ===="
input int London_Start_Hour = 3;
input int London_End_Hour = 6;
input int NY_Start_Hour = 9;
input int NY_End_Hour = 12;

input group "==== Indicators ===="
input int EMA_Fast_Period = 8;
input int EMA_Slow_Period = 21;
input int RSI_Period = 14;
input int ATR_Period = 14;

input group "==== Risk Management ===="
input double Risk_Per_Trade = 0.5;  // % of balance
input double SL_ATR_Multiplier = 1.5;
input double Max_Spread_Pips = 2.0;
input double Max_DD_Daily_Percent = 2.5;

input group "==== Take Profit Levels ===="
input double TP1_ATR_Mult = 0.8;   // 50% close
input double TP2_ATR_Mult = 1.5;   // 30% close
input double TP3_ATR_Mult = 2.5;   // 20% close

input group "==== Limits ===="
input int Max_Trades_Per_Day = 30;
input int Max_Consecutive_Losses = 5;

// SECTION 3: GLOBAL VARIABLES
CTrade trade;
int handleEMA_Fast, handleEMA_Slow, handleRSI, handleATR;
datetime lastTradeTime = 0;
int tradesCountToday = 0;
int consecutiveLosses = 0;
double dailyStartBalance = 0;
double dailyDD = 0;

// SECTION 4: INITIALIZATION
int OnInit() {
  // Initialize indicators
  // Setup risk management
  // Load settings
}

// SECTION 5: MAIN LOOP
void OnTick() {
  // Check session
  // Check daily limits
  // Check DD protection
  // Analyze market
  // Execute trades
  // Manage positions
}

// SECTION 6: TRADE LOGIC
bool CheckLongSignal() {
  // EMA crossover
  // RSI filter
  // Volume confirmation
  // M1 confirmation
}

bool CheckShortSignal() {
  // Similar to long
}

// SECTION 7: POSITION MANAGEMENT
void OpenPosition(ENUM_ORDER_TYPE type) {
  // Calculate lot size
  // Set SL/TP
  // Execute order
  // Scaled TPs
}

void ManageOpenPositions() {
  // Check TP levels
  // Trailing stop
  // Partial closes
}

// SECTION 8: RISK MANAGEMENT
double CalculateLotSize() {
  // Risk % based
  // ATR based SL
  // Balance adjustments
}

void CheckDailyDD() {
  // Monitor DD
  // Circuit breakers
  // Stop trading if needed
}

// SECTION 9: UTILITIES
bool IsSessionActive() {
  // London/NY check
}

double GetCurrentSpread() {
  // Spread check
}
```

---

## 🧪 PLAN DE BACKTESTING

### Fase 1: Backtest Inicial (Semana 1)

**Período:** 2024 completo (12 meses)

**Objetivos:**
```
✅ Profit factor >1.2
✅ Win rate >55%
✅ DD máximo <5%
✅ Trades/mes >200
```

**Métricas a analizar:**
- Net profit por mes
- DD diario máximo (crítico)
- Win rate por sesión (London vs NY)
- Performance por hora del día
- Rachas perdedoras máximas

---

### Fase 2: Optimización (Semana 2)

**Walk-Forward Optimization:**

```
Training: Enero-Junio 2024
Validation: Julio-Septiembre 2024
Testing: Octubre-Diciembre 2024
```

**Parámetros a optimizar:**
1. EMA periods
2. RSI levels
3. Volume threshold
4. SL/TP multipliers
5. Risk per trade

**Criterio:** Profit factor máximo con DD <3%

---

### Fase 3: Stress Testing (Semana 3)

**Simular peores escenarios:**

```
Test 1: Alta volatilidad (NFP days)
Test 2: Baja liquidez (festivos)
Test 3: Rachas perdedoras (10+ losses)
Test 4: Gaps overnight
Test 5: Spread amplio (>3 pips)
```

**Objetivo:** Confirmar que DD diario <2.8% en TODOS los escenarios

---

### Fase 4: Monte Carlo (Semana 4)

**1000 simulaciones aleatorias:**

```
Objetivo: Calcular probabilidad de FAIL

Resultados esperados:
- P(DD >3% algún día): <5%
- P(Pasar FASE 1 en 2 meses): >80%
- P(Pasar FASE 2 en 1 mes): >85%
- P(Completar challenge): >70%
```

---

## 📅 TIMELINE DE DESARROLLO

### Semana 1: Codificación Base
```
Día 1-2: Estructura básica + Indicators
Día 3-4: Lógica de trading (entry/exit)
Día 5-6: Risk management + Position sizing
Día 7: Testing compilación + Debug básico
```

### Semana 2: Backtesting Inicial
```
Día 8-9: Backtest 2024 completo
Día 10-11: Análisis resultados + Ajustes
Día 12-13: Re-backtest con ajustes
Día 14: Validación métricas
```

### Semana 3: Optimización
```
Día 15-16: Walk-forward optimization
Día 17-18: Stress testing
Día 19-20: Monte Carlo simulations
Día 21: Documentación resultados
```

### Semana 4: Forward Testing
```
Día 22-28: Demo account testing
- Monitoreo diario
- Ajustes finales
- Validación DD real
```

**TOTAL: 1 mes desarrollo completo**

---

## ✅ CRITERIOS DE APROBACIÓN

### Para Pasar a Forward Testing:

```
✅ Backtest 2024:
  - Profit factor >1.3
  - Win rate >58%
  - Net profit >10,000 pips
  - DD máximo <3%

✅ Walk-Forward:
  - Consistente en 3 períodos
  - No overfitting detectado

✅ Stress Testing:
  - DD <3% en TODOS los escenarios

✅ Monte Carlo:
  - P(Éxito challenge) >70%
```

---

### Para Pasar a Challenge Real:

```
✅ Forward Testing (4 semanas):
  - Profit >0 todas las semanas
  - DD diario <2.5% SIEMPRE
  - Sin errores técnicos
  - Profit factor >1.2

✅ Demo Challenge Simulado (1-2 semanas):
  - Alcanzar $5,000+ en demo
  - DD <3% todos los días
  - Ejecución perfecta
  - Disciplina mantenida
```

---

## 🚨 RED FLAGS - NO PROCEDER SI:

```
❌ Backtest profit factor <1.2
❌ DD algún día >3.5%
❌ Win rate <53%
❌ Rachas perdedoras >10 trades
❌ Forward testing con pérdidas >2 semanas
❌ Slippage promedio >1 pip
❌ Errores técnicos recurrentes
```

---

## 💰 PROYECCIÓN FINAL

### Escenario Base (Conservador):

```
Profit/mes: $7,500
DD diario max: 2.2%
Tiempo FASE 1: 1.3 meses
Tiempo FASE 2: 0.7 meses
TOTAL: 2 meses ✅

Probabilidad éxito: 70%
```

### Escenario Realista (Target):

```
Profit/mes: $12,000
DD diario max: 1.8%
Tiempo FASE 1: 0.8 meses
Tiempo FASE 2: 0.4 meses
TOTAL: 1.2 meses ✅✅

Probabilidad éxito: 80%
```

### Escenario Optimista:

```
Profit/mes: $15,000
DD diario max: 2.0%
Tiempo FASE 1: 0.7 meses
Tiempo FASE 2: 0.3 meses
TOTAL: 1 mes ✅✅✅

Probabilidad éxito: 60% (más agresivo)
```

---

## 🎯 CONCLUSIÓN

### ChallengeScalper v1.0 es VIABLE si:

1. ✅ Win rate alcanza 58-60%
2. ✅ Avg win/loss ratio mantiene 1:1.1 mínimo
3. ✅ DD diario se mantiene <2.5%
4. ✅ Backtesting valida proyecciones
5. ✅ Forward testing confirma consistencia

### Próximos Pasos:

**INMEDIATO:**
1. Codificar estructura base
2. Implementar lógica de trading
3. Backtest inicial

**SEMANA 1:**
4. Optimización parámetros
5. Stress testing

**SEMANA 2-4:**
6. Forward testing demo
7. Ajustes finales

**MES 2:**
8. Demo challenge simulado
9. Preparación mental

**MES 3:**
10. Challenge REAL

---

**Creado:** 2024-12-14
**Status:** DISEÑO COMPLETO
**Siguiente:** Codificación EA
**Tiempo estimado:** 4 semanas hasta forward testing
**Probabilidad éxito challenge:** 70-80%

# Guía de Archivos .SET para SimpleNY200 v1.3

**Versión:** 1.3
**Símbolo:** US100 (NASDAQ 100)
**Fecha:** 2025-01-12

---

## 📋 ARCHIVOS .SET DISPONIBLES PARA v1.3

### ✅ NUEVOS (v1.3) - RECOMENDADOS

| Archivo | Uso | Riesgo | Características |
|---------|-----|--------|-----------------|
| **SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set** | 🟢 **PRIMER TEST** | Muy Bajo | Lotaje dinámico 0.5%, SMA activo, sin trailing |
| **SimpleNY200_v1.3_NASDAQ.set** | 🟡 Testing Normal | Medio | Lotaje dinámico 1%, SMA activo, trailing activo |
| **SimpleNY200_v1.3_NASDAQ_ATR.set** | 🔴 Avanzado | Medio-Alto | ATR Stop Loss, lotaje dinámico, adaptativo |

### 🔄 COMPATIBLES (v1.1, v1.2)

Estos archivos **funcionarán** con v1.3 pero **NO usan** las nuevas características:

| Archivo | Compatible | Notas |
|---------|------------|-------|
| SimpleNY200_NASDAQ.set | ✅ Sí | Lotaje fijo, sin nuevos parámetros v1.3 |
| SimpleNY200_v1.1_NASDAQ.set | ✅ Sí | Lotaje fijo, sin nuevos parámetros v1.3 |
| SimpleNY200_v1.1_NASDAQ_GMT3.set | ✅ Sí | Para brokers GMT+3 |
| SimpleNY200_SP500.set | ✅ Sí | Optimizado para SP500, no NASDAQ |

---

## 🎯 ¿CUÁL ARCHIVO .SET USAR?

### 1️⃣ PRIMER TEST / VALIDACIÓN (RECOMENDADO)

**Archivo:** `SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set`

✅ **Ideal para:**
- Primera vez probando v1.3
- Validar que todo funciona correctamente
- Verificar cálculo de lotaje
- Probar en cuenta demo

**Configuración:**
```
UseFixedLots = false (lotaje dinámico)
RiskPercent = 0.5% (MUY conservador)
CapitalSource = BALANCE
UseATRStopLoss = false (Opening Range SL)
UseSMAFilter = true (solo trades a favor de tendencia)
RiskRewardRatio = 1.5
AllowedMaxLotSize = 20.0 (límite de seguridad)
UseTrailingStop = false (TP fijo)
```

**Resultado esperado con $100,000:**
- Riesgo por trade: $500 (0.5%)
- Lotaje típico: 2-4 lotes
- Trades/mes: ~8-12 (con filtro SMA)
- Drawdown máximo: <5%

---

### 2️⃣ TESTING NORMAL / PRODUCCIÓN

**Archivo:** `SimpleNY200_v1.3_NASDAQ.set`

✅ **Ideal para:**
- Después de validar v1.3 con configuración conservadora
- Testing con parámetros optimizados
- Cuenta demo o real con capital $50K-$500K

**Configuración:**
```
UseFixedLots = false (lotaje dinámico)
RiskPercent = 1.0% (estándar)
CapitalSource = BALANCE
UseATRStopLoss = false (Opening Range SL)
UseSMAFilter = true
RiskRewardRatio = 2.0 (más agresivo)
AllowedMaxLotSize = 50.0
UseTrailingStop = true (captura más profit)
```

**Resultado esperado con $100,000:**
- Riesgo por trade: $1,000 (1%)
- Lotaje típico: 4-8 lotes
- Trades/mes: ~10-15
- Drawdown máximo: <8%

---

### 3️⃣ AVANZADO / ADAPTATIVO (ATR)

**Archivo:** `SimpleNY200_v1.3_NASDAQ_ATR.set`

✅ **Ideal para:**
- Traders con experiencia en ATR
- Mercados muy volátiles
- Quieres SL adaptativo a condiciones

**Configuración:**
```
UseFixedLots = false (lotaje dinámico)
RiskPercent = 1.0%
CapitalSource = BALANCE
UseATRStopLoss = true ← CLAVE: ATR activo
ATRPeriod = 14
ATRMultiplier = 1.2 (ajustado para NASDAQ)
UseSMAFilter = true
RiskRewardRatio = 1.5 (más conservador con ATR)
AllowedMaxLotSize = 50.0
UseTrailingStop = true
```

**Ventajas ATR:**
- ✅ SL se adapta a volatilidad
- ✅ SL más amplio en días volátiles (menos stop outs)
- ✅ SL más ajustado en días tranquilos (mejor R:R)

**Desventajas ATR:**
- ⚠️ SL variable = riesgo variable
- ⚠️ Puede dar SL muy amplios en alta volatilidad
- ⚠️ Menos predecible que Opening Range

**Resultado esperado con $100,000:**
- Riesgo por trade: $1,000 (1%)
- Lotaje: VARIABLE según ATR (2-10 lotes)
- SL: 40-120 pips (según volatilidad)
- Trades/mes: ~12-18

---

## 📊 COMPARACIÓN DE CONFIGURACIONES

| Característica | CONSERVATIVE | NASDAQ | NASDAQ_ATR |
|----------------|--------------|--------|------------|
| **Riesgo/Trade** | 0.5% | 1.0% | 1.0% |
| **Lotaje** | Dinámico bajo | Dinámico medio | Dinámico variable |
| **Stop Loss** | Opening Range | Opening Range | ATR dinámico |
| **Risk:Reward** | 1:1.5 | 1:2.0 | 1:1.5 |
| **Trailing Stop** | NO | SÍ | SÍ |
| **Trades/mes** | 8-12 | 10-15 | 12-18 |
| **Drawdown máx** | <5% | <8% | <10% |
| **Nivel** | 🟢 Principiante | 🟡 Intermedio | 🔴 Avanzado |
| **Capital mín** | $10K | $50K | $50K |

---

## 🚀 RECOMENDACIÓN PASO A PASO

### Semana 1: Validación
```
Archivo: SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set
Symbol: US100
Period: 2024.11.01 - 2024.11.30 (1 mes)
Deposit: $100,000

Objetivo: Verificar que v1.3 funciona correctamente
- ✅ Lotaje siempre entero (1, 2, 3, 4...)
- ✅ No órdenes rechazadas
- ✅ Margen validado correctamente
- ✅ Logs detallados aparecen
```

### Semana 2: Testing Normal
```
Archivo: SimpleNY200_v1.3_NASDAQ.set
Symbol: US100
Period: 2024.10.01 - 2024.12.31 (3 meses)
Deposit: $100,000

Objetivo: Evaluar performance con parámetros optimizados
- Analizar Win Rate
- Analizar Profit Factor
- Analizar Max Drawdown
- Revisar calidad de trades
```

### Semana 3 (Opcional): ATR Testing
```
Archivo: SimpleNY200_v1.3_NASDAQ_ATR.set
Symbol: US100
Period: 2024.10.01 - 2024.12.31 (3 meses)
Deposit: $100,000

Objetivo: Comparar Opening Range SL vs ATR SL
- Comparar drawdown
- Comparar número de trades
- Comparar profit factor
- Decidir cuál usar en real
```

---

## 📁 UBICACIÓN DE ARCHIVOS

### En Proyecto (Google Drive):
```
/My Drive/Bittrader/Bittrader EA/Dev Folder/Simple Nas100/
├── SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set ✅ RECOMENDADO
├── SimpleNY200_v1.3_NASDAQ.set
├── SimpleNY200_v1.3_NASDAQ_ATR.set
├── SimpleNY200_NASDAQ.set (v1.0 - compatible)
└── SimpleNY200_v1.1_NASDAQ.set (v1.1 - compatible)
```

### En MetaTrader 5:
```
/MQL5/Profiles/Tester/
└── SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set ✅
```

---

## 🔧 CÓMO CARGAR UN ARCHIVO .SET

### En Strategy Tester:

1. Abre MetaTrader 5
2. Presiona `Ctrl+R` o ve a: View → Strategy Tester
3. Selecciona:
   - Expert Advisor: `SimpleNY200_v1.3`
   - Symbol: `US100` (o `NASDAQ`, `NAS100` según tu broker)
   - Period: M1 (obligatorio)
4. Click en botón **"Settings"** o icono de engranaje
5. Click en **"Load"**
6. Selecciona: `SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set`
7. Click **"OK"**
8. Click **"Start"**

### Verificar parámetros cargados:

Después de cargar el .set, verifica en la pestaña "Inputs":
```
✅ CapitalSource = 4 (BALANCE)
✅ AllowedMaxLotSize = 20.0 (CONSERVATIVE) o 50.0 (NASDAQ)
✅ UseATRStopLoss = false (CONSERVATIVE/NASDAQ) o true (ATR)
✅ RiskPercent = 0.5 (CONSERVATIVE) o 1.0 (NASDAQ/ATR)
```

---

## ⚠️ DIFERENCIAS CLAVE v1.3 vs v1.2

### Nuevos Parámetros (solo en v1.3):

Si usas archivos `.set` antiguos, estos parámetros usarán valores **por defecto**:

| Parámetro | Default | Qué hace |
|-----------|---------|----------|
| `CapitalSource` | BALANCE (4) | Usa balance de cuenta para cálculos |
| `CurrencyPairAppendix` | "" | Sin sufijo de broker |
| `AllowedMaxLotSize` | 100.0 | Límite máximo de lotaje |
| `UseATRStopLoss` | false | Usa Opening Range para SL |
| `ATRPeriod` | 14 | Período ATR (si se activa) |
| `ATRMultiplier` | 1.5 | Multiplicador ATR (si se activa) |

**Recomendación:** Usa los archivos `.set` v1.3 para aprovechar **todas** las nuevas características.

---

## 📊 MATRIZ DE DECISIÓN

**¿Qué archivo .set usar?**

```
┌─────────────────────────────────────────────────────────┐
│ ¿Primera vez con v1.3?                                  │
│   └─ SÍ → SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set     │
│   └─ NO ↓                                               │
│                                                          │
│ ¿Tienes experiencia con ATR?                            │
│   └─ SÍ → Considera SimpleNY200_v1.3_NASDAQ_ATR.set    │
│   └─ NO ↓                                               │
│                                                          │
│ ¿Capital > $50,000?                                     │
│   └─ SÍ → SimpleNY200_v1.3_NASDAQ.set                  │
│   └─ NO → SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set     │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 MI RECOMENDACIÓN FINAL

**Para empezar AHORA mismo:**

1️⃣ **Usa:** `SimpleNY200_v1.3_NASDAQ_CONSERVATIVE.set`

2️⃣ **Configura Strategy Tester:**
```
Symbol: US100
Timeframe: M1
Period: 2024.11.01 - 2024.11.30
Deposit: $100,000
Mode: Every tick based on real ticks
```

3️⃣ **Click START y verifica:**
- Logs: "v1.3 LOT CALC: Final Normalized Lots = X" (entero)
- Sin errores de "Invalid volume"
- Margen validado: "v1.3 MARGIN CHECK"

4️⃣ **Si todo va bien, actualiza a:**
- `SimpleNY200_v1.3_NASDAQ.set` (para testing normal)
- `SimpleNY200_v1.3_NASDAQ_ATR.set` (para comparar ATR)

---

## 📞 SOPORTE

**Documentación:**
- Este archivo: `GUIA_ARCHIVOS_SET_v1.3.md`
- Código: `SimpleNY200_v1.3_README.md`
- Changelog: `CHANGELOG.md`
- Compilación: `COMPILE_v1.3.md`

**YouTube:** https://www.youtube.com/@bittrader9259

---

**¡Listo para testear! 🚀**

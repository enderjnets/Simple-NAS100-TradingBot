# 🎯 PLAN DE OPTIMIZACIÓN - SimpleNY200 v1.2

## ✅ STATUS ACTUAL

**Bug de reset diario:** CORREGIDO ✅

**Backtest Q1 2024 (Sin Filtros):**
- Total Trades: 42 (2 meses)
- Win Rate: 30.95% ❌
- Net Profit: -246.80 pips ❌
- Profit Factor: 0.85 ❌
- R:R Promedio: 1:1.9 ✅
- Max Drawdown: 0.90% ✅

**Conclusión:** El código funciona perfectamente, pero necesita filtros para ser rentable.

---

## 📋 ARCHIVOS DE CONFIGURACIÓN CREADOS

### 1. SimpleNY200_v1.2_TEST_NO_FILTERS.set
**Status:** ✅ Ya probado

**Configuración:**
- UseSMAFilter: false
- RequireCloseOutside: false
- BreakoutBuffer: 1.0

**Resultado:**
- 42 trades en 2 meses
- Win rate: 30.95%
- Net Profit: -246.80 pips

---

### 2. SimpleNY200_v1.2_TEST_SMA_FILTER.set
**Status:** ⏭️ Siguiente a probar

**Configuración:**
- UseSMAFilter: **true** ← ACTIVADO
- RequireCloseOutside: false
- BreakoutBuffer: 1.0

**Hipótesis:**
- Solo toma trades a favor de tendencia
- Debería reducir trades a ~20-25
- Debería aumentar win rate a ~45-55%
- Long trades ya tienen 40% win rate (mejor que short 17%)

**Resultado esperado:**
- Trades: ~20-25 (reducción 40%)
- Win Rate: 45-55% (mejora significativa)
- Profit Factor: >1.0 (rentable)

---

### 3. SimpleNY200_v1.2_TEST_CLOSE_FILTER.set
**Status:** ⏭️ Por probar

**Configuración:**
- UseSMAFilter: false
- RequireCloseOutside: **true** ← ACTIVADO
- BreakoutBuffer: 1.0

**Hipótesis:**
- Requiere confirmación fuerte (vela cerrada fuera)
- Filtra falsos breakouts
- Debería reducir trades a ~15-25
- Debería aumentar win rate a ~40-50%

**Resultado esperado:**
- Trades: ~15-25 (reducción 40-60%)
- Win Rate: 40-50%
- Menos falsos breakouts

---

### 4. SimpleNY200_v1.2_TEST_BUFFER_2.set
**Status:** ⏭️ Por probar

**Configuración:**
- UseSMAFilter: false
- RequireCloseOutside: false
- BreakoutBuffer: **2.0** ← INCREMENTADO (era 1.0)

**Hipótesis:**
- Breakouts más significativos (2 pips extra)
- Filtra breakouts marginales
- Debería reducir trades a ~30-35
- Debería aumentar win rate a ~35-45%

**Resultado esperado:**
- Trades: ~30-35 (reducción 15-25%)
- Win Rate: 35-45%
- Breakouts más limpios

---

### 5. SimpleNY200_v1.2_TEST_ALL_FILTERS.set
**Status:** ⏭️ Por probar

**Configuración:**
- UseSMAFilter: **true** ← ACTIVADO
- RequireCloseOutside: **true** ← ACTIVADO
- BreakoutBuffer: **2.0** ← INCREMENTADO

**Hipótesis:**
- Configuración MÁS CONSERVADORA
- Solo los mejores setups
- Debería reducir trades a ~8-15
- Debería aumentar win rate a ~50-65%

**Resultado esperado:**
- Trades: ~8-15 (reducción 65-80%)
- Win Rate: 50-65%
- Muy selectivo, pocos trades pero de alta calidad

---

## 🧪 PROTOCOLO DE TESTING

### Para Cada Configuración:

**1. Cargar en Strategy Tester:**
```
Expert: SimpleNY200 v1.2
Symbol: NAS100
Period: M1
Dates: 2024.01.01 - 2024.03.01 (mismo período para comparar)
Model: Every tick based on real ticks
Deposit: 100000
Settings → Load → [archivo .set correspondiente]
```

**2. Analizar Resultados:**
- Total Trades
- Win Rate
- Net Profit
- Profit Factor
- Max Drawdown
- Long vs Short performance

**3. Documentar en Tabla de Comparación:**

| Config | Trades | Win % | Net Profit | Profit Factor | Avg Win | Avg Loss | R:R | Ranking |
|--------|--------|-------|------------|---------------|---------|----------|-----|---------|
| **CLOSE_FILTER** | **39** | **33.33%** | **-103.60** | **0.93** | **108.35** | **-58.16** | **1:1.86** | 🥇 **#1 MEJOR** |
| NO_FILTERS | 42 | 30.95% | -246.80 | 0.85 | 108.16 | -57.00 | 1:1.9 | 🥈 #2 Baseline |
| ALL_FILTERS | 34 | 32.35% | -343.60 | 0.77 | 105.06 | -65.19 | 1:1.61 | 🥉 #3 |
| SMA_FILTER | 36 | 33.33% | -345.50 | 0.78 | 100.25 | -64.52 | 1:1.55 | #4 PEOR |

---

## 🎯 OBJETIVO DE OPTIMIZACIÓN

### Métricas Target:

| Métrica | Mínimo Aceptable | Ideal |
|---------|------------------|-------|
| Win Rate | >40% | >50% |
| Profit Factor | >1.2 | >1.5 |
| Net Profit | >0 pips | >500 pips |
| Trades/mes | >5 | 10-15 |
| Max Drawdown | <3% | <2% |

---

## 📊 ORDEN DE PRUEBA RECOMENDADO

### Prioridad 1: SMA_FILTER
**Razón:** Long trades ya tienen 40% win rate, el filtro SMA debería potenciar esto.

### Prioridad 2: ALL_FILTERS
**Razón:** Si SMA funciona bien, probar con todos los filtros para máxima calidad.

### Prioridad 3: CLOSE_FILTER
**Razón:** Confirmación de breakout, complementario.

### Prioridad 4: BUFFER_2
**Razón:** Menos impacto esperado, probar al final.

---

## 🚀 PRÓXIMO PASO INMEDIATO

### EJECUTAR BACKTEST CON SMA FILTER:

**1. Strategy Tester (Ctrl+R)**
```
Expert: SimpleNY200 v1.2
Symbol: NAS100
Period: M1
Dates: 2024.01.01 - 2024.03.01
Settings → Load → SimpleNY200_v1.2_TEST_SMA_FILTER.set
```

**2. Verificar Configuración:**
- En pestaña "Settings" confirmar: UseSMAFilter=true
- SMAPeriod=200

**3. Start**

**4. Analizar:**
- ¿Reducción de trades?
- ¿Aumento de win rate?
- ¿Profit factor >1.0?

---

## 📂 UBICACIÓN DE ARCHIVOS

**Archivos .set:**
```
MQL5/Profiles/Tester/SimpleNY200/
├── SimpleNY200_v1.2_TEST_NO_FILTERS.set ✅ (Probado)
├── SimpleNY200_v1.2_TEST_SMA_FILTER.set ⏭️ (Siguiente)
├── SimpleNY200_v1.2_TEST_CLOSE_FILTER.set
├── SimpleNY200_v1.2_TEST_BUFFER_2.set
└── SimpleNY200_v1.2_TEST_ALL_FILTERS.set
```

**Ejecutable:**
```
MQL5/Experts/Advisors/SimpleNY200/
└── SimpleNY200_v1.2.ex5
```

---

## 📝 NOTAS IMPORTANTES

### Observaciones del Test Baseline (NO_FILTERS):

1. **Short trades tienen mal desempeño:** 17.65% win rate vs 40% long
   - El filtro SMA debería ayudar a evitar shorts contra tendencia

2. **R:R es excelente:** 1:1.9 promedio
   - Buena gestión de riesgo
   - Solo necesita mejor win rate

3. **Max racha perdedora:** 11 trades consecutivos
   - Necesita filtros para reducir esto

4. **Drawdown muy bajo:** 0.90%
   - Sistema conservador en gestión de capital
   - Permite aumentar lote si se vuelve rentable

---

**Creado:** 2024-12-14
**Status:** Lista de configuraciones creada
**Siguiente acción:** Testear SMA_FILTER configuration

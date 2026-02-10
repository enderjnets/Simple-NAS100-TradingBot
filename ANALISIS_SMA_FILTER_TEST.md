# 📊 ANÁLISIS: SMA Filter Test - SimpleNY200 v1.2

**Fecha:** 2024-12-14 16:26
**Período:** 2024.01.01 - 2024.03.01
**Configuración:** SMA 200 Filter Activado

---

## ❌ RESULTADO PRINCIPAL: FILTRO SMA EMPEORÓ DESEMPEÑO

### Comparación Directa

| Métrica | NO_FILTERS (Baseline) | SMA_FILTER | Cambio | Evaluación |
|---------|----------------------|------------|---------|------------|
| **Total Trades** | 42 | 36 | -6 (-14%) | ⚠️ Reducción leve |
| **Win Rate** | 30.95% (13W/29L) | 33.33% (12W/24L) | +2.38% | ⚠️ Mejora mínima |
| **Net Profit** | -246.80 pips | **-345.50 pips** | **-98.70 (-40%)** | ❌ EMPEORÓ |
| **Profit Factor** | 0.85 | **0.78** | **-0.07 (-8%)** | ❌ EMPEORÓ |
| **Gross Profit** | 1,406.10 | 1,203.00 | -203.10 (-14%) | ❌ Peor |
| **Gross Loss** | -1,652.90 | -1,548.50 | +104.40 (+6%) | ✅ Mejor |
| **Avg Win** | 108.16 pips | 100.25 pips | -7.91 (-7%) | ❌ Peor |
| **Avg Loss** | -57.00 pips | **-64.52 pips** | **-7.52 (-13%)** | ❌ PEOR |
| **R:R Ratio** | 1:1.9 | 1:1.55 | -0.35 (-18%) | ❌ EMPEORÓ |
| **Max Drawdown** | 0.90% (905.40) | 0.61% (607.80) | -0.29% (-32%) | ✅ Mejor |
| **Max Losing Streak** | 11 trades (-808.70) | 6 trades (-547.60) | -5 trades (-45%) | ✅ Mejor |
| **Expected Payoff** | -5.88 | -9.60 | -3.72 (-63%) | ❌ Peor |

---

## 📈 Análisis por Dirección

### Long Trades

| Métrica | NO_FILTERS | SMA_FILTER | Cambio |
|---------|------------|------------|--------|
| Total Trades | 25 | 21 | -4 (-16%) |
| Win Rate | 40.00% | 42.86% | +2.86% |

**Análisis:** Mejora marginal en win rate, pero reducción de oportunidades.

### Short Trades

| Métrica | NO_FILTERS | SMA_FILTER | Cambio |
|---------|------------|------------|--------|
| Total Trades | 17 | 15 | -2 (-12%) |
| Win Rate | 17.65% | 20.00% | +2.35% |

**Análisis:** Mejora marginal en win rate, short trades siguen siendo muy débiles.

---

## 🔍 DIAGNÓSTICO DEL PROBLEMA

### 1. Pérdidas Promedio Aumentaron Significativamente

**-57.00 → -64.52 pips (-13%)**

**Posibles Causas:**
- El filtro SMA elimina trades ganadores rápidos
- Quedan los trades que van contra tendencia inicial
- Los stops están siendo golpeados con mayor frecuencia
- Entradas tardías (esperar confirmación SMA) resultan en peores precios

### 2. Ganancias Promedio Disminuyeron

**108.16 → 100.25 pips (-7%)**

**Posibles Causas:**
- Filtro SMA reduce momentum de entradas
- Mejores breakouts están siendo filtrados
- Entradas tardías pierden parte del movimiento inicial

### 3. Win Rate Mejoró MUY POCO

**30.95% → 33.33% (+2.38%)**

**Conclusión:** La mejora es insignificante y NO compensa:
- Pérdidas más grandes (+13%)
- Ganancias más pequeñas (-7%)
- Net profit -40% peor

### 4. Profit Factor Empeoró

**0.85 → 0.78**

**Significado:** Por cada $1 perdido, ahora solo recuperamos $0.78 (antes $0.85).

---

## 💡 TEORÍAS: Por Qué el SMA Filter Falló

### Teoría 1: SMA 200 en M1 No Es Apropiado

**Problema:**
- SMA 200 en M1 = últimos 200 minutos (~3.3 horas)
- Sesión NY completa = 6 horas (17:30-01:30)
- El SMA representa más de la mitad de la sesión
- Puede estar demasiado "ajustado" al precio intradiario

**Solución Posible:**
- Usar SMA de timeframe superior (H1, H4, D1)
- Usar SMA más corto (SMA 50 o SMA 100 en M1)

### Teoría 2: Breakout Trading ≠ Trend Following

**Problema:**
- Opening Range Breakout es estrategia de **expansión de volatilidad**
- NO necesariamente requiere tendencia direccional
- Los mejores breakouts pueden ser CONTRA tendencia (reversals)
- El SMA está eliminando breakouts válidos

**Ejemplo:**
- Precio en downtrend (debajo SMA 200)
- Opening Range breakout alcista (contra tendencia)
- SMA filter lo bloquea
- Pero podría ser un reversal válido

### Teoría 3: Entradas Tardías

**Problema:**
- Filtro SMA requiere confirmación adicional
- Precio ya movió parte del breakout
- Entrada tardía = peor precio
- Stop loss fijo = peor R:R

**Evidencia:**
- Avg Loss aumentó (-13%)
- Avg Win disminuyó (-7%)
- R:R empeoró (-18%)

### Teoría 4: El SMA Filtra los MEJORES Setups

**Hipótesis:**
- Los breakouts más fuertes ocurren cuando precio rompe AMBOS:
  1. Opening Range
  2. SMA 200 (resistencia adicional)
- Estos son raros pero muy rentables
- Al filtrar trades que van contra SMA, perdemos los grandes ganadores
- Los trades que quedan son mediocres

**Evidencia:**
- Largest profit trade: 312.10 → 220.00 (-29%)
- Gross Profit: 1,406.10 → 1,203.00 (-14%)

---

## 📊 Datos Adicionales

### Rachas

| Métrica | NO_FILTERS | SMA_FILTER | Evaluación |
|---------|------------|------------|------------|
| Max Consecutive Wins | 4 (+231.20) | 3 (+148.40) | Peor |
| Max Consecutive Losses | 11 (-808.70) | 6 (-547.60) | ✅ Mejor |
| Avg Consecutive Wins | 1 | 2 | ✅ Mejor |
| Avg Consecutive Losses | 3 | 3 | Igual |

**Observación:** SMA redujo rachas perdedoras (mejor drawdown), pero también redujo rachas ganadoras.

---

## 🎯 CONCLUSIONES

### ❌ SMA 200 Filter NO Es La Solución

**Razones:**
1. Net Profit empeoró 40%
2. Profit Factor empeoró 8%
3. R:R ratio empeoró 18%
4. Win rate mejoró solo 2.38% (insignificante)
5. Avg Loss aumentó 13%

### ✅ Aspectos Positivos

1. Drawdown mejoró 32% (0.90% → 0.61%)
2. Max losing streak redujo 45% (11 → 6 trades)
3. Más consistente (menos volatilidad)

**Pero:** Estos beneficios NO compensan la pérdida de rentabilidad.

---

## 🚀 RECOMENDACIONES

### Siguiente Test: CLOSE_FILTER

**Razón:** El problema NO es de tendencia, es de **confirmación de breakout**.

**RequireCloseOutside debería:**
- Filtrar falsos breakouts (price spikes)
- Requerir cierre de vela fuera del range
- Reducir entradas prematuras
- Mejorar calidad de señales

**Expectativa:**
- Reducir trades a ~25-30
- Aumentar win rate a ~40-45%
- Mantener R:R ratio bueno
- Mejorar profit factor

### Alternativas a Explorar

**Opción A: Filtro SMA en Timeframe Superior**
```
Usar SMA 200 de H1 o H4 en lugar de M1
Representa tendencia diaria real, no intradiaria
```

**Opción B: SMA Más Corto**
```
SMA 50 o SMA 100 en M1
Más responsive a cambios de momentum
```

**Opción C: Sin Filtro de Tendencia**
```
Enfocarse en filtros de confirmación de breakout
RequireCloseOutside + BreakoutBuffer aumentado
```

---

## 📋 PRÓXIMO PASO INMEDIATO

### EJECUTAR TEST: CLOSE_FILTER

**1. Strategy Tester (Ctrl+R)**
```
Expert: SimpleNY200 v1.2
Symbol: NAS100
Period: M1
Dates: 2024.01.01 - 2024.03.01
Settings → Load → SimpleNY200_v1.2_TEST_CLOSE_FILTER.set
```

**2. Verificar Configuración:**
```
RequireCloseOutside=true ✓
UseSMAFilter=false ✓
BreakoutBuffer=1.0 ✓
```

**3. Start**

**4. Comparar:**
```
¿Trades reducidos?
¿Win rate mejorado?
¿Avg Loss reducido?
¿Profit factor >0.85?
```

---

**Creado:** 2024-12-14
**Conclusión:** SMA Filter empeoró desempeño. Probar RequireCloseOutside.
**Status:** ⏭️ Siguiente test: CLOSE_FILTER

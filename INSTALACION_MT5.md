# SimpleNY200 v1.1 - Instalación en MT5

## ✅ ARCHIVOS INSTALADOS CORRECTAMENTE

### 📂 Estructura en MetaTrader 5

```
C:\Program Files\MetaTrader 5\MQL5\
│
├── 📁 Experts/
│   └── 📁 Advisors/
│       └── 📁 SimpleNY200/
│           ├── SimpleNY200_v1.0.mq5      (63 KB) - Versión original
│           ├── SimpleNY200_v1.0.ex5      (61 KB)
│           ├── SimpleNY200_v1.1.mq5 ✅   (67 KB) - Nueva versión
│           └── SimpleNY200_v1.1.ex5 ✅   (63 KB) - Compilado
│
└── 📁 Profiles/
    └── 📁 Tester/
        └── 📁 SimpleNY200/
            ├── SimpleNY200_Default.set         (v1.0)
            ├── SimpleNY200_NASDAQ.set          (v1.0)
            ├── SimpleNY200_SP500.set           (v1.0)
            ├── SimpleNY200_DIAGNOSTIC.set      (test)
            ├── SimpleNY200_v1.1_Default.set ✅
            ├── SimpleNY200_v1.1_NASDAQ.set  ✅
            └── SimpleNY200_v1.1_SP500.set   ✅
```

---

## 🎯 CÓMO ACCEDER EN MT5

### Método 1: Navigator (Trading en Vivo)

```
1. Abrir MetaTrader 5
2. Ver → Navigator (o Ctrl+N)
3. Expandir "Expert Advisors"
4. Expandir carpeta "SimpleNY200"
5. Verás:
   - SimpleNY200 v1.0 (⚠️ deprecado)
   - SimpleNY200 v1.1 (✅ usar este)
```

**Para usar:**
- Arrastrar "SimpleNY200 v1.1" a un gráfico M1
- Configurar parámetros o cargar .set

---

### Método 2: Strategy Tester (Backtest)

```
1. Abrir MetaTrader 5
2. Ver → Strategy Tester (o Ctrl+R)
3. En "Expert Advisor", buscar en el dropdown:
   - SimpleNY200 v1.0 (⚠️ NO usar)
   - SimpleNY200 v1.1 (✅ usar este)
```

**Para cargar configuración:**
```
1. Click en botón "Settings"
2. Click en "Load"
3. Navegar a: Profiles/Tester/SimpleNY200/
4. Seleccionar:
   - SimpleNY200_v1.1_Default.set  (genérico)
   - SimpleNY200_v1.1_NASDAQ.set   (US100)
   - SimpleNY200_v1.1_SP500.set    (US500)
```

---

## 📋 VERIFICACIÓN DE INSTALACIÓN

### Checklist ✅

- [x] SimpleNY200_v1.1.ex5 en `MQL5/Experts/Advisors/SimpleNY200/`
- [x] SimpleNY200_v1.1.mq5 en `MQL5/Experts/Advisors/SimpleNY200/`
- [x] 3 archivos .set en `MQL5/Profiles/Tester/SimpleNY200/`
- [x] EA visible en Navigator
- [x] EA visible en Strategy Tester
- [x] Archivos .set cargables desde Settings

---

## 🔄 REINICIAR MT5 (Recomendado)

Si no ves el EA en Navigator:

```
1. Cerrar MetaTrader 5 completamente
2. Esperar 5 segundos
3. Abrir MetaTrader 5
4. Navigator → Expert Advisors → SimpleNY200
```

---

## 🚀 PRIMER USO - BACKTEST

### Paso a Paso

```
1. Ctrl+R (Strategy Tester)
2. Expert Advisor: SimpleNY200 v1.1
3. Symbol: NAS100
4. Period: M1
5. Dates: 2024.11.01 - 2024.12.01
6. Model: Every tick based on real ticks
7. Deposit: 100000
8. Settings → Load → SimpleNY200_v1.1_NASDAQ.set
9. Start
```

**Resultado esperado:**
- Total trades: ~20-22
- Win rate: 40-60%
- Profit factor: 1.2-1.8

---

## ⚙️ CONFIGURACIONES DISPONIBLES

### SimpleNY200_v1.1_Default.set
```
Para: Instrumentos genéricos
Opening Range: 15 minutos
Buffer: 2.0 pips
Lote: 1.0
R:R: 1:1.5
Trailing: OFF
```

### SimpleNY200_v1.1_NASDAQ.set
```
Para: NAS100 (US100)
Opening Range: 10 minutos
Buffer: 3.0 pips
Lote: 1.0
R:R: 1:2.0
Trailing: ON (30/15)
```

### SimpleNY200_v1.1_SP500.set
```
Para: SPX500 (US500)
Opening Range: 15 minutos
Buffer: 1.5 pips
Lote: 1.5
R:R: 1:1.5
Trailing: OFF
```

---

## 🔧 CONFIGURACIÓN MANUAL

Si prefieres configurar manualmente (sin .set):

### Parámetros Obligatorios
```
BrokerGMTOffset = [TU OFFSET]  // ⚠️ IMPORTANTE
UseDST = true/false            // Según período
NYOpenHour = 9
NYOpenMinute = 30
```

### Parámetros Recomendados
```
OpeningRangeMinutes = 10-15
BreakoutBuffer = 2.0-3.0
UseSMAFilter = true
SMAPeriod = 200
RiskRewardRatio = 1.5-2.0
MaxTradesPerDay = 1
TradeOnlyFirstSignal = true
```

---

## 📊 VERIFICAR CÁLCULO DE HORARIOS

### Activar Logs DEBUG (Primera vez)

```
1. En parámetros del EA:
   LogLevel = 3 (LOG_DEBUG)

2. Ejecutar backtest corto (1 día)

3. Ver pestaña "Journal" para:
   📅 NY OPEN CALCULATED:
      Broker GMT Offset: GMT+[X]
      Use DST: YES/NO
      NY Open Time: 2024.11.01 [HORA]
      NY Close Time: 2024.11.01 [HORA]

4. Verificar que horarios sean correctos

5. Cambiar a producción:
   LogLevel = 1 (LOG_INFO)
```

---

## ⚠️ PROBLEMAS COMUNES

### EA no aparece en Navigator
- ✅ Reiniciar MT5
- ✅ Verificar ruta: `MQL5/Experts/Advisors/SimpleNY200/`
- ✅ Verificar que .ex5 existe

### No puedo cargar .set
- ✅ Verificar ruta: `MQL5/Profiles/Tester/SimpleNY200/`
- ✅ Usar botón "Load" (no "Open")

### EA no opera en backtest
- ✅ Usar timeframe M1 obligatorio
- ✅ Verificar BrokerGMTOffset
- ✅ Activar LogLevel = DEBUG para diagnóstico

---

## 📝 NOTAS IMPORTANTES

- ⚠️ Usar SOLO v1.1 (v1.0 tiene bug crítico)
- ⚠️ Timeframe obligatorio: M1
- ⚠️ Configurar BrokerGMTOffset correctamente
- ⚠️ Verificar UseDST según período de backtest
- ✅ Siempre probar en demo antes de live

---

**Última actualización:** 2024-12-12
**Versión instalada:** v1.1 [SESSION FIX]
**Status:** ✅ Ready to use

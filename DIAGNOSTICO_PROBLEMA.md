# 🔍 DIAGNÓSTICO - SimpleNY200 No Opera

## ❌ PROBLEMA DETECTADO

El EA **NO hizo operaciones** en el backtest porque el `BrokerGMTOffset` está **INCORRECTAMENTE configurado**.

---

## 📊 ANÁLISIS DE LOS LOGS

### Lo que encontramos en los logs:

```
📅 NY OPEN CALCULATED:
  Broker GMT Offset: GMT+0  ← ⚠️ INCORRECTO!
  Use DST: YES
  NY Hour in GMT: 13
  NY Hour in Broker Time: 13:30
  NY Open Time: 2024.11.29 13:30:00
  NY Close Time: 2024.11.29 21:30:00
```

### El EA está buscando sesión NY en:
```
13:30 - 21:30 (hora broker)
```

### Pero según backtest v1.0 (buggy), tu broker operaba en:
```
01:48, 05:10 ← Trades FUERA de horario esperado
```

---

## 🧮 CÁLCULO CORRECTO DEL OFFSET

### Opción 1: Broker GMT+3 (SIN DST para Nov 2024)
```
NY Open: 9:30 AM EST (horario estándar)
EST = GMT-5
9:30 AM EST = 14:30 GMT

Broker GMT+3:
14:30 GMT + 3 horas = 17:30 hora broker

Ventana de trading:
17:30 (Nov 29) → 01:30 (Nov 30)  [8 horas]
```

**CONFIG:**
```
BrokerGMTOffset = 3
UseDST = false
```

---

### Opción 2: Broker GMT+2 (SIN DST)
```
NY Open: 9:30 AM EST
EST = GMT-5
9:30 AM EST = 14:30 GMT

Broker GMT+2:
14:30 GMT + 2 horas = 16:30 hora broker

Ventana de trading:
16:30 (Nov 29) → 00:30 (Nov 30)  [8 horas]
```

**CONFIG:**
```
BrokerGMTOffset = 2
UseDST = false
```

---

## ⚙️ CÓMO DETERMINAR TU BROKER GMT OFFSET

### Método 1: Verificar horario de apertura NY en MT5

```
1. Abrir gráfico de NAS100 en MT5
2. Buscar día 2024.11.01 (viernes)
3. Buscar el candle de 9:30 AM NY
4. Anotar la HORA DEL BROKER

Si el candle de 9:30 AM NY aparece en:
├─ 14:30 hora broker → BrokerGMTOffset = 0
├─ 15:30 hora broker → BrokerGMTOffset = 1
├─ 16:30 hora broker → BrokerGMTOffset = 2
└─ 17:30 hora broker → BrokerGMTOffset = 3
```

### Método 2: Usar indicador de hora del servidor

```
1. En MT5, crear script simple:
   Print("Hora servidor: ", TimeCurrent());

2. Ejecutar cuando sean exactamente 14:30 GMT
   (usar worldtimebuddy.com para confirmar)

3. Restar 14:30 de la hora que muestra:
   Ej: muestra 17:30 → offset = 3
```

---

## ✅ SOLUCIÓN

### Paso 1: Usa el .set correcto

He creado: **`SimpleNY200_v1.1_NASDAQ_GMT3.set`**

```
BrokerGMTOffset = 3  ← Para broker GMT+3
UseDST = false       ← Noviembre 2024 (después Nov 3)
LogLevel = 3         ← DEBUG para ver logs
```

### Paso 2: Cargar en Strategy Tester

```
1. Strategy Tester → SimpleNY200 v1.1
2. Settings → Load → SimpleNY200_v1.1_NASDAQ_GMT3.set
3. Symbol: NAS100
4. Period: M1
5. Dates: 2024.11.01 - 2024.11.30
6. Start
```

### Paso 3: Verificar logs en Journal

Deberías ver:
```
📅 NY OPEN CALCULATED:
  Broker GMT Offset: GMT+3  ✅
  NY Hour in Broker Time: 17:30  ✅
  NY Open Time: 2024.11.01 17:30:00  ✅
  NY Close Time: 2024.11.02 01:30:00  ✅

⚠️ NY SESSION DIAGNOSTIC:
  Current Time: 2024.11.01 18:30:00
  NY Open: 2024.11.01 17:30:00
  NY Close: 2024.11.02 01:30:00
  In Session: YES  ✅
```

---

## 🎯 RESULTADO ESPERADO

Con la configuración correcta:
```
✅ ~20-22 trades en 1 mes
✅ Trades SOLO en horario 17:30-01:30
✅ Opening Range calculado correctamente
✅ Breakouts detectados
```

---

## 📝 SI AÚN NO OPERA

### Verifica:
1. ✅ LogLevel = 3 (DEBUG)
2. ✅ BrokerGMTOffset correcto
3. ✅ UseDST correcto para el período
4. ✅ Timeframe = M1 (obligatorio)
5. ✅ Datos completos en MT5 para el período

### Busca en logs:
- "NY SESSION DIAGNOSTIC"
- "In Session: YES" ← Debe aparecer
- "Opening Range INICIADO"
- "BREAKOUT ALCISTA/BAJISTA"

---

## 🔧 ARCHIVO CREADO

**Ubicación:**
```
✅ Proyecto: SimpleNY200_v1.1_NASDAQ_GMT3.set
✅ MT5: Profiles/Tester/SimpleNY200/SimpleNY200_v1.1_NASDAQ_GMT3.set
```

**Parámetros clave:**
```
BrokerGMTOffset = 3
UseDST = false
LogLevel = 3 (DEBUG)
FixedLotSize = 0.1 (reducido para testing)
MaxTradesPerDay = 5 (aumentado para testing)
```

---

**Próximo paso:** Ejecuta backtest con el nuevo .set y verifica los logs.

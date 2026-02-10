# SimpleNY200 - Guía de Estructura y Uso

## 📂 Estructura de Carpetas

### MT5 (Carpetas de Trabajo)

```
MetaTrader 5/
├── MQL5/
│   ├── Experts/
│   │   └── Advisors/
│   │       └── SimpleNY200/          ⬅️ CARPETA PRINCIPAL EA
│   │           ├── SimpleNY200_v1.0.mq5
│   │           ├── SimpleNY200_v1.0.ex5
│   │           ├── SimpleNY200_v1.1.ex5  (futuras versiones aquí)
│   │           └── SimpleNY200_v1.2.ex5
│   │
│   └── Profiles/
│       └── Tester/
│           └── SimpleNY200/          ⬅️ CARPETA CONFIGURACIONES
│               ├── SimpleNY200_Default.set
│               ├── SimpleNY200_NASDAQ.set
│               └── SimpleNY200_SP500.set
```

### Google Drive (Respaldo y Control de Versiones)

```
Simple NY 200/
├── README.md                    ⬅️ Documentación completa
├── CHANGELOG.md                 ⬅️ Historial de cambios
├── ESTRUCTURA_Y_USO.md         ⬅️ Esta guía
│
├── SimpleNY200_v1.0.mq5        ⬅️ Versión actual (desarrollo)
├── SimpleNY200_v1.0.ex5
├── SimpleNY200_Default.set
├── SimpleNY200_NASDAQ.set
├── SimpleNY200_SP500.set
│
└── Versions/                    ⬅️ HISTORIAL DE VERSIONES
    ├── v1.0/
    │   ├── VERSION_INFO.txt
    │   ├── SimpleNY200_v1.0.mq5
    │   ├── SimpleNY200_v1.0.ex5
    │   └── *.set (3 archivos)
    │
    ├── v1.1/                    (futuras versiones)
    │   ├── VERSION_INFO.txt
    │   └── ...
    │
    └── v1.2/
        └── ...
```

---

## 🎯 Cómo Usar Esta Estructura

### Para Backtest

1. **Abrir MT5 Strategy Tester** (Ctrl+R)

2. **En "Expert Advisor":**
   - Buscar en la lista: `SimpleNY200\SimpleNY200 v1.0`
   - O simplemente: `SimpleNY200 v1.0`

3. **Cargar configuración:**
   - Click "Expert properties"
   - Click "Load"
   - Buscar carpeta: `SimpleNY200`
   - Seleccionar .set apropiado

4. **Iniciar backtest**

### Para Trading en Vivo

1. **Arrastrar EA al gráfico:**
   - Desde Navigator → Expert Advisors → SimpleNY200 → SimpleNY200 v1.0

2. **Configurar parámetros:**
   - Cargar .set desde: MQL5/Profiles/Tester/SimpleNY200/
   - Ajustar según necesidad

3. **Activar AutoTrading**

---

## 🔄 Workflow para Nuevas Versiones

### Cuando se cree v1.1, v1.2, etc:

#### PASO 1: Desarrollo
```bash
# Editar código en Google Drive
Simple NY 200/SimpleNY200_v1.1.mq5

# Compilar en MT5
→ Genera: SimpleNY200_v1.1.ex5
```

#### PASO 2: Copiar a MT5
```bash
# Copiar archivos a carpeta de trabajo MT5
SimpleNY200_v1.1.ex5 → MQL5/Experts/Advisors/SimpleNY200/
SimpleNY200_*.set    → MQL5/Profiles/Tester/SimpleNY200/
```

#### PASO 3: Archivar Versión
```bash
# Crear carpeta de versión en Google Drive
Simple NY 200/Versions/v1.1/

# Copiar archivos completos
- SimpleNY200_v1.1.mq5
- SimpleNY200_v1.1.ex5
- *.set (3 archivos)
- VERSION_INFO.txt (crear nuevo)
```

#### PASO 4: Actualizar Documentación
```bash
# Actualizar CHANGELOG.md
## v1.1 (YYYY-MM-DD)
- Nueva característica X
- Fix de bug Y
...
```

---

## 📝 Ventajas de Esta Estructura

### ✅ Organización
- Todos los archivos de SimpleNY200 en carpetas dedicadas
- Fácil de encontrar en MT5 Navigator
- No se mezcla con otros EAs

### ✅ Control de Versiones
- Historial completo en `/Versions/`
- Cada versión archivada con su configuración
- Fácil rollback si es necesario

### ✅ Múltiples Versiones Simultáneas
```
SimpleNY200/
├── SimpleNY200_v1.0.ex5  ⬅️ Estable
├── SimpleNY200_v1.1.ex5  ⬅️ Testing
└── SimpleNY200_v1.2.ex5  ⬅️ Beta
```

Puedes tener v1.0 en cuenta real y v1.1 en backtest simultáneamente.

### ✅ Fácil Deployment
```bash
# Para distribuir SimpleNY200 v1.0:
→ Comprimir carpeta: Versions/v1.0/
→ Enviar .zip completo
→ Cliente descomprime en sus carpetas MT5
```

---

## 🗂️ Archivos por Tipo

### Código Fuente (.mq5)
**Ubicación primaria:** Google Drive (desarrollo)
**Ubicación secundaria:** MT5/Advisors/SimpleNY200/ (compilación)

### Ejecutables (.ex5)
**Ubicación primaria:** MT5/Advisors/SimpleNY200/ (uso)
**Ubicación secundaria:** Google Drive (respaldo)

### Configuraciones (.set)
**Ubicación primaria:** MT5/Profiles/Tester/SimpleNY200/ (uso)
**Ubicación secundaria:** Google Drive (respaldo)

### Documentación (.md, .txt)
**Ubicación:** Google Drive exclusivamente

---

## 🚀 Quick Reference

### Backtest con Cuenta $100,000

```
Strategy Tester:
├── EA:      SimpleNY200 v1.0
├── Symbol:  US100
├── Period:  M1
├── Deposit: 100000
└── Config:  SimpleNY200/SimpleNY200_NASDAQ.set
```

### Archivos Activos Actuales

| Archivo | Lote | Optimizado Para |
|---------|------|-----------------|
| SimpleNY200_NASDAQ.set | 1.0 | US100 (alta volatilidad) |
| SimpleNY200_SP500.set | 1.5 | US500 (baja volatilidad) |
| SimpleNY200_Default.set | 1.0 | Uso general |

---

## 📞 Soporte

**Para consultas sobre la estructura:**
- Revisar CHANGELOG.md para historial de versiones
- Revisar VERSION_INFO.txt en cada carpeta Versions/vX.X/
- Revisar README.md para documentación completa

**Para reportar bugs:**
- Especificar versión exacta (e.g., v1.0)
- Indicar archivo .set utilizado
- Adjuntar log de MT5

---

**Última actualización:** 2024-12-11
**Sistema de versiones establecido:** v1.0

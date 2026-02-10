//+------------------------------------------------------------------+
//| SimpleNY200 v1.0 - New York Opening Range Breakout Strategy     |
//| Copyright 2025, Bittrader Development Team                       |
//| https://www.youtube.com/@bittrader9259                           |
//| Estrategia de Breakout del Rango de Apertura de Nueva York      |
//| con filtro SMA 200 para direcci贸n de tendencia                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Bittrader Development Team"
#property link      "https://www.youtube.com/@bittrader9259"
#property version   "1.00"
#property description "SimpleNY200 v1.0 - New York Opening Range Breakout con SMA 200"
#property strict

//+------------------------------------------------------------------+
//| SECTION 1: INCLUDE FILES & CONSTANTS                             |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

// --- Error Definitions
#define ERR_NO_ERROR                0
#define ERR_INVALID_STOPS           130
#define ERR_INVALID_TRADE_PARAMETERS 131
#define ERR_SERVER_BUSY             137
#define ERR_NO_CONNECTION           138
#define ERR_MARKET_CLOSED           133
#define ERR_NOT_ENOUGH_MONEY        134

// --- Additional Constants
#define MIN_MARGIN_LEVEL            50.0
#define MAX_RETRY_ATTEMPTS          3
#define RETRY_DELAY                 500
#define LICENSE_SERVER_URL "http://bittraderbot.com/verificar.php"

// --- Market Constants
#define MIN_VOLUME                  0.01
#define MAX_VOLUME                  100.0
#define VOLUME_STEP                 0.01

// --- Panel Visual Constants
#define COLOR_FONDO_PANEL     C'30,30,40'     // Dark gray background
#define COLOR_BORDE_PANEL     C'70,70,90'     // Blue border
#define COLOR_TEXTO_NORMAL    C'220,220,220'  // Light gray text
#define COLOR_TEXTO_ACTIVO    C'50,255,50'    // Bright green
#define COLOR_TEXTO_ALERTA    C'255,70,70'    // Bright red
#define ANCHO_PANEL           700             // Panel width
#define ALTO_PANEL            280             // Panel height

//+------------------------------------------------------------------+
//| SECTION 2: ENUMERATIONS                                          |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVEL {
    LOG_ERROR,                  // Solo errores
    LOG_WARNING,                // Errores y advertencias
    LOG_INFO,                   // Informaci贸n general
    LOG_DEBUG                   // Informaci贸n detallada
};

//+------------------------------------------------------------------+
//| SECTION 3: INPUT PARAMETERS - LICENSE SYSTEM                     |
//+------------------------------------------------------------------+
input group "==== Sistema de Licencias ===="
input string          LicenseKey         = "";                    // Clave de Licencia (Codigo)

//+------------------------------------------------------------------+
//| SECTION 4: INPUT PARAMETERS - GENERAL SETTINGS                   |
//+------------------------------------------------------------------+
input group "==== Ajustes Generales del EA ===="
input string          EAIdentifier        = "SimpleNY200_v1.0";  // Identificador del EA
input ENUM_LOG_LEVEL  LogLevel           = LOG_INFO;            // Nivel de logging
input int             MagicNumber        = 200200200;            // Magic Number

//+------------------------------------------------------------------+
//| SECTION 5: INPUT PARAMETERS - NY SESSION SETTINGS                |
//+------------------------------------------------------------------+
input group "==== Configuraci贸n Sesi贸n Nueva York ===="
input int       BrokerGMTOffset     = 0;                   // Offset GMT del Broker (horas)
input bool      UseDST              = true;                // Ajustar por horario de verano
input int       NYOpenHour          = 9;                   // Hora apertura NY (EST)
input int       NYOpenMinute        = 30;                  // Minuto apertura NY (EST)

//+------------------------------------------------------------------+
//| SECTION 6: INPUT PARAMETERS - OPENING RANGE SETTINGS             |
//+------------------------------------------------------------------+
input group "==== Configuraci贸n Opening Range ===="
input int       OpeningRangeMinutes = 15;                  // Duraci贸n del rango (minutos) [5-30]
input double    BreakoutBuffer      = 2.0;                 // Buffer de breakout (pips) [0-10]
input bool      RequireCloseOutside = true;                // Requiere cierre fuera del rango

//+------------------------------------------------------------------+
//| SECTION 7: INPUT PARAMETERS - SMA TREND FILTER                   |
//+------------------------------------------------------------------+
input group "==== Filtro de Tendencia SMA ===="
input int       SMAPeriod           = 200;                 // Periodo SMA [50-500]
input bool      UseSMAFilter        = true;                // Activar filtro SMA 200

//+------------------------------------------------------------------+
//| SECTION 8: INPUT PARAMETERS - RISK MANAGEMENT                    |
//+------------------------------------------------------------------+
input group "==== Gesti贸n de Riesgo ===="
input bool      UseFixedLots        = true;                // Usar lote fijo
input double    FixedLotSize        = 0.1;                 // Tama帽o de lote fijo
input double    RiskPercent         = 1.0;                 // Riesgo por operaci贸n (%)
input double    RiskRewardRatio     = 1.5;                 // Risk:Reward [1.0, 1.5, 2.0]
input double    MaxSpreadPips       = 3.0;                 // Spread m谩ximo permitido (pips)

//+------------------------------------------------------------------+
//| SECTION 9: INPUT PARAMETERS - DAILY LIMITS                       |
//+------------------------------------------------------------------+
input group "==== L铆mites Diarios ===="
input int       MaxTradesPerDay     = 1;                   // M谩ximo trades por d铆a
input bool      TradeOnlyFirstSignal = true;               // Solo operar primera se帽al

//+------------------------------------------------------------------+
//| SECTION 10: INPUT PARAMETERS - TRAILING STOP (OPTIONAL)          |
//+------------------------------------------------------------------+
input group "==== Trailing Stop (Opcional) ===="
input bool      UseTrailingStop     = false;               // Activar trailing stop
input double    TrailingStartPips   = 20.0;                // Pips de ganancia para activar
input double    TrailingStopPips    = 10.0;                // Distancia del trailing (pips)

//+------------------------------------------------------------------+
//| SECTION 11: INPUT PARAMETERS - VISUAL PANEL                      |
//+------------------------------------------------------------------+
input group "==== Panel Visual ===="
input bool      ShowPanel           = true;                // Mostrar panel de estado
input int       PanelXPosition      = 20;                  // Posici贸n X
input int       PanelYPosition      = 30;                  // Posici贸n Y

//+------------------------------------------------------------------+
//| SECTION 12: INPUT PARAMETERS - LOGGING                           |
//+------------------------------------------------------------------+
input group "==== Sistema de Logging ===="
input bool      EnableFileLogging   = true;                // Activar logging a archivo
input bool      EnableStatistics    = true;                // Rastrear estad铆sticas

//+------------------------------------------------------------------+
//| SECTION 13: GLOBAL VARIABLES - LICENSE SYSTEM                    |
//+------------------------------------------------------------------+
// Variables internas de licencia (COPIAR EXACTO de GridTrader)
bool           licenciaValida        = false;    // Indica si la licencia es v谩lida
bool           verificacionCompleta  = false;    // Indica si se complet贸 la verificaci贸n
string         mensajeError          = "";       // Mensaje de error para mostrar al usuario
datetime       ultimaVerificacion    = 0;        // Tiempo de la 煤ltima verificaci贸n
int            intentosVerificacion  = 0;        // Contador de intentos de verificaci贸n
int            maxIntentosVerificacion = 3;      // M谩ximo de intentos antes de deshabilitar
int            periodoVerificacion   = 3600;     // Per铆odo entre verificaciones (1 hora)
string         hwid                  = "";       // Hardware ID 煤nico
string         accountInfo           = "";       // Informaci贸n de la cuenta

// Variables para sistema de gracia de 48 horas (COPIAR EXACTO de GridTrader)
datetime       ultimaConexionExitosa = 0;        // 脷ltima conexi贸n exitosa al servidor
datetime       inicioModoGracia      = 0;        // Cu谩ndo comenz贸 el per铆odo de gracia
bool           enModoGracia          = false;    // Si est谩 en per铆odo de gracia
int            horasGracia           = 48;       // Horas de gracia (configurable)
bool           primeraConexionCompleta = false;  // Si complet贸 la primera conexi贸n
string         estadoConexion        = "Conectando..."; // Estado actual de conexi贸n
int            horasRestantes        = 0;        // Horas restantes en modo gracia
int            minutosRestantes      = 0;        // Minutos restantes en modo gracia

//+------------------------------------------------------------------+
//| SECTION 14: GLOBAL VARIABLES - TRADING OBJECTS                   |
//+------------------------------------------------------------------+
CTrade         trade;                            // Trade execution object

//+------------------------------------------------------------------+
//| SECTION 15: GLOBAL VARIABLES - INDICATOR HANDLES                 |
//+------------------------------------------------------------------+
int            g_HandleSMA           = INVALID_HANDLE;     // SMA indicator handle

//+------------------------------------------------------------------+
//| SECTION 16: GLOBAL VARIABLES - NY SESSION & RANGE                |
//+------------------------------------------------------------------+
datetime       g_NYOpenTime          = 0;        // Today's NY open time
datetime       g_RangeStartTime      = 0;        // Opening range start
datetime       g_RangeEndTime        = 0;        // Opening range end
double         g_RangeHigh           = 0.0;      // Opening range high
double         g_RangeLow            = 0.0;      // Opening range low
bool           g_RangeCalculated     = false;    // Range fully calculated
bool           g_RangeActive         = false;    // Currently in range period

//+------------------------------------------------------------------+
//| SECTION 17: GLOBAL VARIABLES - TRADE STATE                       |
//+------------------------------------------------------------------+
bool           g_TradedToday         = false;    // Has traded today
datetime       g_LastTradeDate       = 0;        // Last trade date (for reset)
int            g_TradesToday         = 0;        // Number of trades today
ulong          g_CurrentTicket       = 0;        // Current position ticket
bool           g_PositionOpen        = false;    // Position currently open

//+------------------------------------------------------------------+
//| SECTION 18: GLOBAL VARIABLES - BREAKOUT TRACKING                 |
//+------------------------------------------------------------------+
bool           g_BullishBreakout     = false;    // Bullish breakout detected
bool           g_BearishBreakout     = false;    // Bearish breakout detected
datetime       g_BreakoutTime        = 0;        // Time of breakout
double         g_BreakoutPrice       = 0.0;      // Price at breakout

//+------------------------------------------------------------------+
//| SECTION 19: GLOBAL VARIABLES - STATISTICS (NEW v1.0)             |
//+------------------------------------------------------------------+
int            g_TotalTrades         = 0;        // Total trades executed
int            g_WinningTrades       = 0;        // Winning trades
int            g_LosingTrades        = 0;        // Losing trades
double         g_TotalProfit         = 0.0;      // Total profit
double         g_TotalLoss           = 0.0;      // Total loss
double         g_LargestWin          = 0.0;      // Largest win
double         g_LargestLoss         = 0.0;      // Largest loss
int            g_ConsecutiveWins     = 0;        // Consecutive wins
int            g_ConsecutiveLosses   = 0;        // Consecutive losses
double         g_TotalPipsWon        = 0.0;      // Total pips won
double         g_TotalPipsLost       = 0.0;      // Total pips lost

//+------------------------------------------------------------------+
//| SECTION 20: GLOBAL VARIABLES - FILE LOGGING (NEW v1.0)           |
//+------------------------------------------------------------------+
int            g_FileHandle          = INVALID_HANDLE;     // Log file handle
string         g_LogFileName         = "";                 // Log filename

//+------------------------------------------------------------------+
//| SECTION 21: GLOBAL VARIABLES - VISUAL PANEL                      |
//+------------------------------------------------------------------+
string         g_PanelName           = "SimpleNY200_Panel_";
bool           g_PanelCreated        = false;

//+------------------------------------------------------------------+
//| SECTION 22: TRADING STATE STRUCTURE                              |
//+------------------------------------------------------------------+
struct SNY200State {
    // Session tracking
    bool        isNYSession;
    bool        inOpeningRange;
    int         minutesSinceOpen;

    // Range data
    double      rangeHigh;
    double      rangeLow;
    double      rangeSize;

    // SMA filter
    double      currentSMA;
    double      currentPrice;
    bool        aboveSMA;
    bool        belowSMA;

    // Breakout validation
    bool        bullishBreakoutValid;
    bool        bearishBreakoutValid;
    bool        canTrade;

    // Position data
    double      currentSL;
    double      currentTP;
    double      positionProfit;

    // Statistics
    int         dailyTrades;
    double      dailyPL;
    double      winRate;
    double      profitFactor;
    string      lastSignal;
    datetime    lastUpdate;
};

SNY200State g_State;

//+------------------------------------------------------------------+
//| SECTION 23: LICENSE SYSTEM FUNCTIONS (COPIAR EXACTO)             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funci贸n para obtener informaci贸n de la cuenta                    |
//+------------------------------------------------------------------+
string GetAccountInfo() {
    string info = "";

    // A帽adir informaci贸n b谩sica de la cuenta
    info += "Login: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
    info += ", Server: " + AccountInfoString(ACCOUNT_SERVER);
    info += ", Company: " + AccountInfoString(ACCOUNT_COMPANY);
    info += ", Name: " + AccountInfoString(ACCOUNT_NAME);
    info += ", Currency: " + AccountInfoString(ACCOUNT_CURRENCY);

    return info;
}

//+---------------------------------------------------------------------+
//| Funci贸n para verificar licencia con el servidor (COPIAR EXACTO)     |
//+---------------------------------------------------------------------+
bool VerificarLicencia() {
    // Variables locales para esta funci贸n (evitando conflictos con globales)
    static datetime ultima_verificacion_licencia = 0;

    // Detectar si estamos en modo backtest
    bool estamosEnBacktest = MQLInfoInteger(MQL_TESTER);

    // Si estamos en backtest, aprobar la licencia autom谩ticamente
    if(estamosEnBacktest) {
        Print(">>> BACKTEST MODE DETECTED - License check bypassed");
        LogMessage("Modo backtest detectado - Verificaci贸n de licencia simulada", LOG_INFO);
        licenciaValida = true;
        verificacionCompleta = true;
        ultimaVerificacion = TimeCurrent();
        intentosVerificacion = 0;
        Print(">>> License validated for backtest - returning TRUE");
        return true;
    }

    // Simulaci贸n para pruebas en modo normal (NO Backtest)
    // Evitar verificaciones demasiado frecuentes
    if (TimeCurrent() - ultimaVerificacion < periodoVerificacion && verificacionCompleta) {
        return licenciaValida;
    }

    LogMessage("Iniciando verificaci贸n de licencia con el servidor...", LOG_INFO);

    // Incrementar contador de intentos
    intentosVerificacion++;

    // Inicializar variables de licencia si es la primera vez
    if (hwid == "") {
        hwid = "HW-" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
        accountInfo = GetAccountInfo();
    }

    // Preparar los datos para la solicitud POST
    string postData = "action=verificar" +
    "&codigo=" + LicenseKey +
    "&cuenta_mt5=" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +
    "&hwid=" + hwid +
    "&ea_version=" + EAIdentifier +
    "&saldo_cuenta=" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) +
    "&nombre_setting=" + EAIdentifier +
    "&simbolo=" + _Symbol;

    // A帽adir este mensaje de log m谩s detallado
    LogMessage("Datos de verificaci贸n detallados - EA Version: [" + EAIdentifier +
          "], Cuenta: [" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +
          "], Saldo: [" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "]", LOG_DEBUG);

    char data[];
    StringToCharArray(postData, data);

    // Preparar el encabezado HTTP
    string headers = "Content-Type: application/x-www-form-urlencoded\r\n";

    char result[];
    string result_headers;

    // Realizar la solicitud HTTP POST
    int res = WebRequest("POST", LICENSE_SERVER_URL, headers, 5000, data, result, result_headers);

    LogMessage("C贸digo de respuesta HTTP: " + IntegerToString(res), LOG_INFO);

    // NUEVO SISTEMA DE GRACIA DE 48 HORAS
    // Verificar si hubo error en la solicitud (servidor no responde)
    if (res == -1) {
        int errorCode = GetLastError();
        mensajeError = "Error de conexi贸n con el servidor de licencias: " + IntegerToString(errorCode);
        LogMessage(mensajeError, LOG_ERROR);

        // Si es la primera conexi贸n fallida despu茅s de una exitosa
        if(!enModoGracia && primeraConexionCompleta) {
            enModoGracia = true;
            inicioModoGracia = TimeCurrent();
            ultimaVerificacion = TimeCurrent(); // Actualizar para evitar verificaciones muy frecuentes
            estadoConexion = "MODO GRACIA";

            LogMessage("INICIANDO MODO GRACIA: Servidor no responde. El EA funcionar谩 por " +
                      IntegerToString(horasGracia) + " horas m谩s.", LOG_WARNING);

            Alert("SimpleNY200 v1.0 - MODO GRACIA ACTIVADO\n\n" +
                  "El servidor de licencias no responde.\n" +
                  "El EA seguir谩 funcionando por " + IntegerToString(horasGracia) + " horas.\n\n" +
                  "El sistema intentar谩 reconectar autom谩ticamente cada hora.");

            return true; // Permitir continuar en modo gracia
        }

        // Si ya est谩 en modo gracia, verificar si no se ha agotado el tiempo
        if(enModoGracia) {
            datetime tiempoTranscurrido = TimeCurrent() - inicioModoGracia;
            int horasTranscurridas = (int)(tiempoTranscurrido / 3600);

            if(horasTranscurridas >= horasGracia) {
                // Tiempo de gracia agotado
                mensajeError = "TIEMPO DE GRACIA AGOTADO: No se pudo restablecer conexi贸n con el servidor en " +
                              IntegerToString(horasGracia) + " horas.";
                LogMessage(mensajeError, LOG_ERROR);

                Alert("SimpleNY200 v1.0 - TIEMPO AGOTADO\n\n" +
                      "No se pudo reconectar con el servidor de licencias en " +
                      IntegerToString(horasGracia) + " horas.\n\n" +
                      "El EA se desactivar谩 ahora.");

                ExpertRemove();
                return false;
            }

            // Actualizar tiempo restante para el panel
            horasRestantes = horasGracia - horasTranscurridas;
            minutosRestantes = (int)((tiempoTranscurrido % 3600) / 60);
            minutosRestantes = 60 - minutosRestantes; // Minutos hasta la pr贸xima hora

            // Alertas de advertencia en puntos cr铆ticos
            if(horasRestantes == 24 && minutosRestantes > 50) {
                Alert("SimpleNY200 v1.0 - ADVERTENCIA\n\n" +
                      "Quedan 24 horas de gracia.\n" +
                      "Verifique la conexi贸n del servidor de licencias.");
            }
            else if(horasRestantes == 6 && minutosRestantes > 50) {
                Alert("SimpleNY200 v1.0 - CR脥TICO\n\n" +
                      "Quedan solo 6 horas de gracia.\n" +
                      "El EA se desactivar谩 pronto si no se restablece la conexi贸n.");
            }

            ultimaVerificacion = TimeCurrent();
            return true; // Continuar en modo gracia
        }

        // Si no hab铆a conexi贸n previa exitosa, no permitir iniciar
        if(!primeraConexionCompleta) {
            mensajeError = "No se puede iniciar el EA sin verificaci贸n inicial de licencia.";
            LogMessage(mensajeError, LOG_ERROR);
            ExpertRemove();
            return false;
        }

        return false;
    }

    // Procesar la respuesta
    string response = CharArrayToString(result);
    LogMessage("Respuesta del servidor: " + response, LOG_INFO);

    string parts[];

    // La respuesta debe tener el formato: "estado|mensaje|max_instancias|instancias_actuales"
    StringSplit(response, '|', parts);

    LogMessage("N煤mero de partes en la respuesta: " + IntegerToString(ArraySize(parts)), LOG_INFO);

    if (ArraySize(parts) < 4) {
        mensajeError = "Respuesta inv谩lida del servidor de licencias";
        LogMessage(mensajeError, LOG_ERROR);
        return false;
    }

    string estadoRespuesta = parts[0]; // Cambiado para evitar conflicto con variable global
    string mensaje = parts[1];
    int maxInstancias = (int)StringToInteger(parts[2]);
    int instanciasActuales = (int)StringToInteger(parts[3]);

    // Actualizar estado de verificaci贸n
    verificacionCompleta = true;
    ultimaVerificacion = TimeCurrent();
    intentosVerificacion = 0;

    if (estadoRespuesta == "1") {
        // Licencia v谩lida
        licenciaValida = true;

        // Marcar primera conexi贸n exitosa
        if(!primeraConexionCompleta) {
            primeraConexionCompleta = true;
            ultimaConexionExitosa = TimeCurrent();
        }

        // Salir del modo gracia si estaba activo
        if(enModoGracia) {
            enModoGracia = false;
            LogMessage("Conexi贸n restablecida - Saliendo del modo gracia", LOG_INFO);
            Alert("SimpleNY200 v1.0 - Conexi贸n Restablecida\n\n" +
                  "La conexi贸n con el servidor de licencias se ha restablecido.");
        }

        // Verificar l铆mite de instancias
        if (instanciasActuales > maxInstancias) {
            licenciaValida = false;
            mensajeError = "Su licencia permite hasta " + IntegerToString(maxInstancias) +
                        " EAs activos a la vez. Actualmente est谩 intentando usar " +
                        IntegerToString(instanciasActuales) + " bots, por lo tanto este EA se desactivar谩.\n\n" +
                        "Si desea activar m谩s instancias, contacte al equipo de soporte de Bittrader " +
                        "para adquirir m谩s licencias para su plan.";
            LogMessage(mensajeError, LOG_ERROR);

            // Mostrar alerta al usuario
            Alert(mensajeError);

            // Desactivar el EA
            ExpertRemove();
            return false;
        }

        LogMessage("Licencia verificada correctamente. Instancias: " + IntegerToString(instanciasActuales) +
                 "/" + IntegerToString(maxInstancias), LOG_INFO);
        return true;
    }
    else {
        // Licencia inv谩lida
        licenciaValida = false;
        mensajeError = mensaje;
        LogMessage("Error de licencia: " + mensajeError, LOG_ERROR);

        // Mostrar alerta al usuario
        Alert("Error de licencia: " + mensajeError + "\n\nEl EA se desactivar谩.");

        // Desactivar el EA
        ExpertRemove();
        return false;
    }

    return licenciaValida;
}

//+------------------------------------------------------------------+
//| SECTION 24: UTILITY FUNCTIONS - LOGGING                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogMessage - Logging a consola con niveles                       |
//+------------------------------------------------------------------+
void LogMessage(string message, ENUM_LOG_LEVEL level) {
    if(level < LogLevel) return; // Filter by level

    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    string levelStr = "";

    switch(level) {
        case LOG_ERROR:   levelStr = "[ERROR]"; break;
        case LOG_WARNING: levelStr = "[WARN]"; break;
        case LOG_INFO:    levelStr = "[INFO]"; break;
        case LOG_DEBUG:   levelStr = "[DEBUG]"; break;
    }

    Print(timestamp + " " + levelStr + " " + message);
}

//+------------------------------------------------------------------+
//| SECTION 25: EVENT HANDLERS - INITIALIZATION                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺�");
    Print("鈺� SimpleNY200 v1.0 - Initializing                          鈺�");
    Print("鈺氣攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺�");

    // STEP 1: LICENSE VERIFICATION (CRITICAL - MUST BE FIRST)
    LogMessage("=== STEP 1: Verificaci贸n de Licencia ===", LOG_INFO);

    if(LicenseKey == "" || LicenseKey == NULL) {
        mensajeError = "No se ha ingresado clave de licencia";
        Alert("SimpleNY200: " + mensajeError);
        LogMessage(mensajeError, LOG_ERROR);
        return INIT_PARAMETERS_INCORRECT;
    }

    if(!VerificarLicencia()) {
        LogMessage("Error verificaci贸n de licencia: " + mensajeError, LOG_ERROR);
        Alert("SimpleNY200: Licencia inv谩lida");
        return INIT_FAILED;
    }

    LogMessage("鉁� Licencia verificada correctamente", LOG_INFO);

    // STEP 2: PARAMETER VALIDATION
    LogMessage("=== STEP 2: Validaci贸n de Par谩metros ===", LOG_INFO);

    // Opening Range validation
    if(OpeningRangeMinutes < 5 || OpeningRangeMinutes > 30) {
        Alert("SimpleNY200: OpeningRangeMinutes debe estar entre 5 y 30");
        return INIT_PARAMETERS_INCORRECT;
    }

    // SMA Period validation
    if(SMAPeriod < 50 || SMAPeriod > 500) {
        Alert("SimpleNY200: SMAPeriod debe estar entre 50 y 500");
        return INIT_PARAMETERS_INCORRECT;
    }

    // Risk:Reward validation
    if(RiskRewardRatio < 0.5 || RiskRewardRatio > 5.0) {
        Alert("SimpleNY200: RiskRewardRatio debe estar entre 0.5 y 5.0");
        return INIT_PARAMETERS_INCORRECT;
    }

    // Lot size validation
    if(UseFixedLots) {
        double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

        if(FixedLotSize < minLot || FixedLotSize > maxLot) {
            Alert("SimpleNY200: FixedLotSize fuera de rango permitido");
            return INIT_PARAMETERS_INCORRECT;
        }
    }

    // Trailing stop validation
    if(UseTrailingStop) {
        if(TrailingStartPips < TrailingStopPips) {
            Alert("SimpleNY200: TrailingStartPips debe ser > TrailingStopPips");
            return INIT_PARAMETERS_INCORRECT;
        }
    }

    LogMessage("鉁� Par谩metros validados correctamente", LOG_INFO);

    // STEP 3: INITIALIZE SMA INDICATOR
    LogMessage("=== STEP 3: Inicializaci贸n de Indicador SMA ===", LOG_INFO);

    if(UseSMAFilter) {
        g_HandleSMA = iMA(_Symbol, PERIOD_M1, SMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
        if(g_HandleSMA == INVALID_HANDLE) {
            LogMessage("Error inicializando SMA " + IntegerToString(SMAPeriod), LOG_ERROR);
            return INIT_FAILED;
        }
        LogMessage("鉁� SMA " + IntegerToString(SMAPeriod) + " inicializado", LOG_INFO);
    }

    // STEP 4: CONFIGURE TRADE OBJECT
    LogMessage("=== STEP 4: Configuraci贸n de Objeto CTrade ===", LOG_INFO);
    trade.SetDeviationInPoints(10);
    trade.SetTypeFilling(ORDER_FILLING_FOK);
    trade.SetExpertMagicNumber(MagicNumber);
    trade.SetAsyncMode(false);
    LogMessage("鉁� Objeto CTrade configurado", LOG_INFO);

    // STEP 5: INITIALIZE STATE
    LogMessage("=== STEP 5: Inicializaci贸n de Estado ===", LOG_INFO);
    ResetDailyData();
    g_State.lastUpdate = TimeCurrent();
    LogMessage("鉁� Estado inicializado", LOG_INFO);

    // STEP 6: INITIALIZE LOG FILE (if enabled)
    if(EnableFileLogging) {
        LogMessage("=== STEP 6: Inicializaci贸n de Archivo de Log ===", LOG_INFO);

        string timestamp = TimeToString(TimeCurrent(), TIME_DATE);
        StringReplace(timestamp, ".", "_");
        g_LogFileName = "SimpleNY200_" + timestamp + ".txt";

        g_FileHandle = FileOpen(g_LogFileName, FILE_WRITE|FILE_TXT);

        if(g_FileHandle != INVALID_HANDLE) {
            FileWrite(g_FileHandle, "鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺�");
            FileWrite(g_FileHandle, "鈺�   SimpleNY200 v1.0 - Session Log                  鈺�");
            FileWrite(g_FileHandle, "鈺�   Started: " + TimeToString(TimeCurrent()) + "      鈺�");
            FileWrite(g_FileHandle, "鈺氣攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺�");
            FileFlush(g_FileHandle);
            LogMessage("鉁� Archivo de log creado: " + g_LogFileName, LOG_INFO);
        } else {
            LogMessage("Advertencia: No se pudo crear archivo de log", LOG_WARNING);
        }
    }

    // STEP 7: CREATE VISUAL PANEL (if enabled)
    if(ShowPanel) {
        LogMessage("=== STEP 7: Creaci贸n de Panel Visual ===", LOG_INFO);
        // Panel creation will be implemented in FASE 11
        LogMessage("鉁� Panel visual marcado para creaci贸n", LOG_INFO);
    }

    // STEP 8: LOG CONFIGURATION
    LogMessage("=== CONFIGURACI脫N COMPLETA ===", LOG_INFO);
    LogMessage("S铆mbolo: " + _Symbol, LOG_INFO);
    LogMessage("SMA Period: " + IntegerToString(SMAPeriod), LOG_INFO);
    LogMessage("Opening Range: " + IntegerToString(OpeningRangeMinutes) + " minutos", LOG_INFO);
    LogMessage("Risk:Reward: 1:" + DoubleToString(RiskRewardRatio, 1), LOG_INFO);
    LogMessage("Max Trades/Day: " + IntegerToString(MaxTradesPerDay), LOG_INFO);
    LogMessage("Broker GMT Offset: " + IntegerToString(BrokerGMTOffset), LOG_INFO);
    LogMessage("鉁� SimpleNY200 v1.0 inicializado correctamente", LOG_INFO);

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    LogMessage("SimpleNY200 v1.0 deinicializando - Raz贸n: " + IntegerToString(reason), LOG_INFO);

    // Release indicator handles
    if(g_HandleSMA != INVALID_HANDLE) {
        IndicatorRelease(g_HandleSMA);
        g_HandleSMA = INVALID_HANDLE;
        LogMessage("鉁� Indicador SMA liberado", LOG_INFO);
    }

    // Close log file
    if(g_FileHandle != INVALID_HANDLE) {
        FileWrite(g_FileHandle, "");
        FileWrite(g_FileHandle, "鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺�");
        FileWrite(g_FileHandle, "鈺�   Session Ended: " + TimeToString(TimeCurrent()) + "      鈺�");
        FileWrite(g_FileHandle, "鈺氣攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺佲攢鈺�");
        FileClose(g_FileHandle);
        g_FileHandle = INVALID_HANDLE;
        LogMessage("鉁� Archivo de log cerrado", LOG_INFO);
    }

    // Remove visual panel (will be implemented in FASE 11)
    if(g_PanelCreated) {
        // EliminarIndicadorVisual();
    }

    // Clean up chart objects
    ObjectsDeleteAll(0, g_PanelName);

    Print("SimpleNY200 v1.0 deinicializado exitosamente");
}

//+------------------------------------------------------------------+
//| Expert tick function - MAIN TRADING LOOP                         |
//+------------------------------------------------------------------+
void OnTick()
{
    // STEP 1: LICENSE RE-VERIFICATION (EVERY HOUR)
    if(TimeCurrent() - ultimaVerificacion >= periodoVerificacion) {
        if(!VerificarLicencia()) {
            LogMessage("Re-verificaci贸n de licencia fallida", LOG_ERROR);
            return;
        }
    }

    // STEP 2: DAILY RESET CHECK
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);

    if(dt.hour == 0 && dt.min == 0) {
        if(g_LastTradeDate != currentTime) {
            ResetDailyData();
            LogToFile("鉁� Reset diario ejecutado", LOG_INFO);
        }
    }

    // STEP 3: CHECK IF NY SESSION ACTIVE
    if(!IsNYSession()) {
        g_State.isNYSession = false;
        return; // Outside NY session
    }
    g_State.isNYSession = true;

    // STEP 4: CALCULATE OPENING RANGE
    if(!g_RangeCalculated) {
        if(IsWithinOpeningRange()) {
            UpdateRangeHiLo();
            g_State.inOpeningRange = true;
        } else if(g_RangeActive && !IsWithinOpeningRange()) {
            // Range period ended, finalize
            CalculateOpeningRange();
        }
    }

    // STEP 5: CHECK DAILY TRADE LIMITS
    if(g_TradesToday >= MaxTradesPerDay) {
        g_State.canTrade = false;
        return;
    }

    // STEP 6: WAIT FOR RANGE TO BE CALCULATED
    if(!g_RangeCalculated) {
        return;
    }

    // STEP 7: CHECK IF ALREADY TRADED
    if(g_TradedToday && TradeOnlyFirstSignal) {
        return;
    }

    // STEP 8: CHECK IF POSITION ALREADY OPEN
    if(g_PositionOpen) {
        MonitorOpenPosition();
        return;
    }

    // STEP 9: GET CURRENT PRICE
    MqlTick tick;
    if(!SymbolInfoTick(_Symbol, tick)) {
        LogMessage("Error obteniendo tick actual", LOG_ERROR);
        return;
    }
    double currentPrice = (tick.bid + tick.ask) / 2.0;

    // STEP 10: CHECK SPREAD
    double currentSpread = GetCurrentSpread();
    if(currentSpread > MaxSpreadPips) {
        return;
    }

    // STEP 11: GET SMA VALUE
    double smaValue = 0.0;
    if(UseSMAFilter) {
        smaValue = GetSMAValue();
        if(smaValue == 0.0) return;
        g_State.currentSMA = smaValue;
    }

    // STEP 12: CHECK FOR BREAKOUTS
    bool bullishBreakout = CheckBullishBreakout(currentPrice, smaValue);
    bool bearishBreakout = CheckBearishBreakout(currentPrice, smaValue);

    // STEP 13: EXECUTE TRADES
    if(bullishBreakout) {
        LogMessage("鉁� SE脩AL ALCISTA DETECTADA", LOG_INFO);
        LogToFile("BULLISH BREAKOUT SIGNAL - Price: " + DoubleToString(currentPrice, _Digits), LOG_INFO);
        OpenBuyPosition(currentPrice);
    } else if(bearishBreakout) {
        LogMessage("鉁� SE脩AL BAJISTA DETECTADA", LOG_INFO);
        LogToFile("BEARISH BREAKOUT SIGNAL - Price: " + DoubleToString(currentPrice, _Digits), LOG_INFO);
        OpenSellPosition(currentPrice);
    }
}

//+------------------------------------------------------------------+
//| SECTION 26: NY SESSION MANAGEMENT FUNCTIONS                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if currently in NY trading session                         |
//+------------------------------------------------------------------+
bool IsNYSession()
{
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);

    // Calculate NY open time for today
    datetime nyOpen = GetNYOpenTime();

    // Check if we're past NY open (with 8-hour trading window)
    datetime nyClose = nyOpen + (8 * 3600); // 8 hours after open

    if(currentTime >= nyOpen && currentTime < nyClose) {
        g_NYOpenTime = nyOpen;
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Get today's NY open time adjusted for broker GMT                 |
//+------------------------------------------------------------------+
datetime GetNYOpenTime()
{
    MqlDateTime dt;
    datetime currentTime = TimeCurrent();
    TimeToStruct(currentTime, dt);

    // Calculate NY open time in GMT
    // EST is GMT-5 (9:30 AM EST = 14:30 GMT)
    // EDT is GMT-4 (9:30 AM EDT = 13:30 GMT)
    int estOffset = UseDST ? -4 : -5;
    int nyHourInGMT = NYOpenHour - estOffset;  // 9 - (-5) = 14 GMT

    // Convert GMT to broker time
    int brokerHour = nyHourInGMT + BrokerGMTOffset;  // 14 + 3 = 17 (5:30 PM broker time)

    // Handle day rollover
    if(brokerHour >= 24) {
        dt.day += 1;
        brokerHour -= 24;
    } else if(brokerHour < 0) {
        dt.day -= 1;
        brokerHour += 24;
    }

    dt.hour = brokerHour;
    dt.min = NYOpenMinute;
    dt.sec = 0;

    datetime result = StructToTime(dt);

    // DEBUG: Log the calculated time (only once per day)
    static datetime lastLogDate = 0;
    if(dt.day != TimeDay(lastLogDate)) {
        LogMessage("馃搮 NY Open calculado: " + TimeToString(result, TIME_DATE|TIME_MINUTES) +
                  " (Broker GMT+" + IntegerToString(BrokerGMTOffset) + ")", LOG_DEBUG);
        lastLogDate = result;
    }

    return result;
}

//+------------------------------------------------------------------+
//| Check if currently within opening range period                   |
//+------------------------------------------------------------------+
bool IsWithinOpeningRange()
{
    if(g_NYOpenTime == 0) return false;

    datetime currentTime = TimeCurrent();
    g_RangeStartTime = g_NYOpenTime;
    g_RangeEndTime = g_NYOpenTime + (OpeningRangeMinutes * 60);

    if(currentTime >= g_RangeStartTime && currentTime < g_RangeEndTime) {
        if(!g_RangeActive) {
            g_RangeActive = true;
            LogMessage("鉁� Opening Range INICIADO - Duraci贸n: " +
                      IntegerToString(OpeningRangeMinutes) + " minutos", LOG_INFO);
            LogToFile("Opening Range Started - Duration: " + IntegerToString(OpeningRangeMinutes) + " minutes", LOG_INFO);
        }
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| SECTION 27: OPENING RANGE CALCULATION FUNCTIONS                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Update opening range high/low during range period                |
//+------------------------------------------------------------------+
void UpdateRangeHiLo()
{
    MqlTick tick;
    if(!SymbolInfoTick(_Symbol, tick)) return;

    double high = tick.ask;
    double low = tick.bid;

    // Initialize on first call
    if(g_RangeHigh == 0.0) {
        g_RangeHigh = high;
        g_RangeLow = low;
        return;
    }

    // Update range
    if(high > g_RangeHigh) g_RangeHigh = high;
    if(low < g_RangeLow) g_RangeLow = low;
}

//+------------------------------------------------------------------+
//| Finalize opening range calculation                               |
//+------------------------------------------------------------------+
void CalculateOpeningRange()
{
    if(g_RangeHigh == 0.0 || g_RangeLow == 0.0) {
        LogMessage("Error: Rango no v谩lido", LOG_ERROR);
        return;
    }

    g_RangeCalculated = true;
    g_RangeActive = false;

    double rangeSize = (g_RangeHigh - g_RangeLow) / _Point;
    g_State.rangeSize = rangeSize;

    LogMessage("鉁� Opening Range CALCULADO", LOG_INFO);
    LogMessage("  High: " + DoubleToString(g_RangeHigh, _Digits), LOG_INFO);
    LogMessage("  Low: " + DoubleToString(g_RangeLow, _Digits), LOG_INFO);
    LogMessage("  Size: " + DoubleToString(rangeSize, 1) + " pips", LOG_INFO);

    LogToFile("OPENING RANGE CALCULATED - High: " + DoubleToString(g_RangeHigh, _Digits) +
             " | Low: " + DoubleToString(g_RangeLow, _Digits) +
             " | Size: " + DoubleToString(rangeSize, 1) + " pips", LOG_INFO);
}

//+------------------------------------------------------------------+
//| Reset daily data at start of new trading day                     |
//+------------------------------------------------------------------+
void ResetDailyData()
{
    g_NYOpenTime = 0;
    g_RangeStartTime = 0;
    g_RangeEndTime = 0;
    g_RangeHigh = 0.0;
    g_RangeLow = 0.0;
    g_RangeCalculated = false;
    g_RangeActive = false;
    g_TradedToday = false;
    g_TradesToday = 0;
    g_BullishBreakout = false;
    g_BearishBreakout = false;
    g_LastTradeDate = TimeCurrent();

    LogMessage("鉁� Datos diarios reseteados", LOG_DEBUG);
}

//+------------------------------------------------------------------+
//| SECTION 28: SMA & BREAKOUT DETECTION FUNCTIONS                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get current SMA value                                            |
//+------------------------------------------------------------------+
double GetSMAValue()
{
    if(g_HandleSMA == INVALID_HANDLE) return 0.0;

    double smaBuffer[1];
    if(CopyBuffer(g_HandleSMA, 0, 0, 1, smaBuffer) != 1) {
        LogMessage("Error copiando buffer SMA", LOG_ERROR);
        return 0.0;
    }

    return smaBuffer[0];
}

//+------------------------------------------------------------------+
//| Check for bullish breakout                                       |
//+------------------------------------------------------------------+
bool CheckBullishBreakout(double currentPrice, double smaValue)
{
    // Already detected
    if(g_BullishBreakout) return false;

    // Get current candle data
    double close[1];
    if(CopyClose(_Symbol, PERIOD_M1, 0, 1, close) != 1) return false;

    double currentClose = close[0];

    // Calculate breakout level with buffer
    double breakoutLevel = g_RangeHigh + (BreakoutBuffer * _Point * 10);

    // CONDITION 1: Price above SMA 200 (trend filter)
    if(UseSMAFilter) {
        if(currentPrice <= smaValue) {
            return false;
        }
    }

    // CONDITION 2: Candle closes ABOVE range high
    bool closeAboveRange = false;
    if(RequireCloseOutside) {
        closeAboveRange = currentClose > breakoutLevel;
    } else {
        closeAboveRange = currentPrice > breakoutLevel;
    }

    if(closeAboveRange) {
        g_BullishBreakout = true;
        g_BreakoutTime = TimeCurrent();
        g_BreakoutPrice = currentPrice;
        LogMessage("鉁� BREAKOUT ALCISTA - Precio: " + DoubleToString(currentPrice, _Digits) +
                  " | SMA: " + DoubleToString(smaValue, _Digits), LOG_INFO);
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Check for bearish breakout                                       |
//+------------------------------------------------------------------+
bool CheckBearishBreakout(double currentPrice, double smaValue)
{
    // Already detected
    if(g_BearishBreakout) return false;

    // Get current candle data
    double close[1];
    if(CopyClose(_Symbol, PERIOD_M1, 0, 1, close) != 1) return false;

    double currentClose = close[0];

    // Calculate breakout level with buffer
    double breakoutLevel = g_RangeLow - (BreakoutBuffer * _Point * 10);

    // CONDITION 1: Price below SMA 200 (trend filter)
    if(UseSMAFilter) {
        if(currentPrice >= smaValue) {
            return false;
        }
    }

    // CONDITION 2: Candle closes BELOW range low
    bool closeBelowRange = false;
    if(RequireCloseOutside) {
        closeBelowRange = currentClose < breakoutLevel;
    } else {
        closeBelowRange = currentPrice < breakoutLevel;
    }

    if(closeBelowRange) {
        g_BearishBreakout = true;
        g_BreakoutTime = TimeCurrent();
        g_BreakoutPrice = currentPrice;
        LogMessage("鉁� BREAKOUT BAJISTA - Precio: " + DoubleToString(currentPrice, _Digits) +
                  " | SMA: " + DoubleToString(smaValue, _Digits), LOG_INFO);
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| SECTION 29: ENTRY EXECUTION FUNCTIONS                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Open BUY position                                                |
//+------------------------------------------------------------------+
void OpenBuyPosition(double entryPrice)
{
    // Validate trade conditions
    if(!ValidateTradeConditions()) return;

    // Calculate position size
    double lots = CalculatePositionSize();
    if(lots <= 0) {
        LogMessage("Error: Tama帽o de lote inv谩lido", LOG_ERROR);
        return;
    }

    // Calculate SL and TP
    double sl = CalculateStopLoss(ORDER_TYPE_BUY);
    double tp = CalculateTakeProfit(ORDER_TYPE_BUY, sl);

    // Validate SL/TP
    if(!ValidateSLTP(ORDER_TYPE_BUY, sl, tp)) {
        LogMessage("Error: SL/TP inv谩lidos", LOG_ERROR);
        return;
    }

    // Execute BUY order
    bool result = trade.Buy(lots, _Symbol, 0.0, sl, tp, "SimpleNY200_BUY");

    if(result) {
        g_CurrentTicket = trade.ResultOrder();
        g_PositionOpen = true;
        g_TradedToday = true;
        g_TradesToday++;
        g_TotalTrades++;

        LogMessage("鉁� ORDEN BUY EJECUTADA", LOG_INFO);
        LogMessage("  Ticket: " + IntegerToString(g_CurrentTicket), LOG_INFO);
        LogMessage("  Lote: " + DoubleToString(lots, 2), LOG_INFO);
        LogMessage("  SL: " + DoubleToString(sl, _Digits), LOG_INFO);
        LogMessage("  TP: " + DoubleToString(tp, _Digits), LOG_INFO);

        LogToFile("BUY ORDER EXECUTED - Ticket: " + IntegerToString(g_CurrentTicket) +
                 " | Lots: " + DoubleToString(lots, 2) +
                 " | SL: " + DoubleToString(sl, _Digits) +
                 " | TP: " + DoubleToString(tp, _Digits), LOG_INFO);
    } else {
        LogMessage("Error ejecutando BUY: " + trade.ResultRetcodeDescription(), LOG_ERROR);
    }
}

//+------------------------------------------------------------------+
//| Open SELL position                                               |
//+------------------------------------------------------------------+
void OpenSellPosition(double entryPrice)
{
    // Validate trade conditions
    if(!ValidateTradeConditions()) return;

    // Calculate position size
    double lots = CalculatePositionSize();
    if(lots <= 0) {
        LogMessage("Error: Tama帽o de lote inv谩lido", LOG_ERROR);
        return;
    }

    // Calculate SL and TP
    double sl = CalculateStopLoss(ORDER_TYPE_SELL);
    double tp = CalculateTakeProfit(ORDER_TYPE_SELL, sl);

    // Validate SL/TP
    if(!ValidateSLTP(ORDER_TYPE_SELL, sl, tp)) {
        LogMessage("Error: SL/TP inv谩lidos", LOG_ERROR);
        return;
    }

    // Execute SELL order
    bool result = trade.Sell(lots, _Symbol, 0.0, sl, tp, "SimpleNY200_SELL");

    if(result) {
        g_CurrentTicket = trade.ResultOrder();
        g_PositionOpen = true;
        g_TradedToday = true;
        g_TradesToday++;
        g_TotalTrades++;

        LogMessage("鉁� ORDEN SELL EJECUTADA", LOG_INFO);
        LogMessage("  Ticket: " + IntegerToString(g_CurrentTicket), LOG_INFO);
        LogMessage("  Lote: " + DoubleToString(lots, 2), LOG_INFO);
        LogMessage("  SL: " + DoubleToString(sl, _Digits), LOG_INFO);
        LogMessage("  TP: " + DoubleToString(tp, _Digits), LOG_INFO);

        LogToFile("SELL ORDER EXECUTED - Ticket: " + IntegerToString(g_CurrentTicket) +
                 " | Lots: " + DoubleToString(lots, 2) +
                 " | SL: " + DoubleToString(sl, _Digits) +
                 " | TP: " + DoubleToString(tp, _Digits), LOG_INFO);
    } else {
        LogMessage("Error ejecutando SELL: " + trade.ResultRetcodeDescription(), LOG_ERROR);
    }
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk                            |
//+------------------------------------------------------------------+
double CalculatePositionSize()
{
    double lots = 0.0;

    if(UseFixedLots) {
        lots = FixedLotSize;
    } else {
        // Risk-based calculation
        double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double riskAmount = accountBalance * (RiskPercent / 100.0);

        double rangeSize = (g_RangeHigh - g_RangeLow);
        if(rangeSize <= 0) return 0.0;

        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

        lots = riskAmount / (rangeSize / tickSize * tickValue);
    }

    // Normalize lots
    return NormalizeLots(lots);
}

//+------------------------------------------------------------------+
//| Validate trade conditions before entry                           |
//+------------------------------------------------------------------+
bool ValidateTradeConditions()
{
    // Check if license is valid
    if(!licenciaValida) {
        LogMessage("Licencia no v谩lida", LOG_ERROR);
        return false;
    }

    // Check margin
    double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    if(freeMargin < 100.0) {
        LogMessage("Margen insuficiente", LOG_ERROR);
        return false;
    }

    // Check if market is open
    if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)) {
        LogMessage("Mercado cerrado", LOG_ERROR);
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| SECTION 30: RISK MANAGEMENT FUNCTIONS                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate Stop Loss based on opening range                       |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE orderType)
{
    double sl = 0.0;

    if(orderType == ORDER_TYPE_BUY) {
        // SL at range low (or below with buffer)
        sl = g_RangeLow - (BreakoutBuffer * _Point * 10);
    } else {
        // SL at range high (or above with buffer)
        sl = g_RangeHigh + (BreakoutBuffer * _Point * 10);
    }

    return NormalizeDouble(sl, _Digits);
}

//+------------------------------------------------------------------+
//| Calculate Take Profit based on Risk:Reward ratio                 |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_ORDER_TYPE orderType, double stopLoss)
{
    double tp = 0.0;
    MqlTick tick;
    SymbolInfoTick(_Symbol, tick);

    double entryPrice = (orderType == ORDER_TYPE_BUY) ? tick.ask : tick.bid;
    double slDistance = MathAbs(entryPrice - stopLoss);
    double tpDistance = slDistance * RiskRewardRatio;

    if(orderType == ORDER_TYPE_BUY) {
        tp = entryPrice + tpDistance;
    } else {
        tp = entryPrice - tpDistance;
    }

    return NormalizeDouble(tp, _Digits);
}

//+------------------------------------------------------------------+
//| Validate SL and TP levels                                        |
//+------------------------------------------------------------------+
bool ValidateSLTP(ENUM_ORDER_TYPE orderType, double sl, double tp)
{
    if(sl <= 0 || tp <= 0) return false;

    double minStopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

    MqlTick tick;
    SymbolInfoTick(_Symbol, tick);
    double price = (orderType == ORDER_TYPE_BUY) ? tick.ask : tick.bid;

    if(orderType == ORDER_TYPE_BUY) {
        if((price - sl) < minStopLevel) return false;
        if((tp - price) < minStopLevel) return false;
    } else {
        if((sl - price) < minStopLevel) return false;
        if((price - tp) < minStopLevel) return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| ModificarPosicion() - Modificar SL/TP (COPIED FROM GRIDTRADER)   |
//+------------------------------------------------------------------+
bool ModificarPosicion(ulong ticket, double newSL, double newTP)
{
   if(ticket == 0)
      return false;

   // Seleccionar la posici贸n
   if(!PositionSelectByTicket(ticket))
   {
      LogMessage("Error: No se pudo seleccionar posici贸n #" + IntegerToString(ticket), LOG_ERROR);
      return false;
   }

   // Verificar que la posici贸n pertenece a este EA
   if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
   {
      LogMessage("Error: Posici贸n #" + IntegerToString(ticket) + " no pertenece a este EA", LOG_WARNING);
      return false;
   }

   // Obtener valores actuales
   double currentSL = PositionGetDouble(POSITION_SL);
   double currentTP = PositionGetDouble(POSITION_TP);

   // Normalizar nuevos valores
   if(newSL > 0)
      newSL = NormalizeDouble(newSL, _Digits);
   else
      newSL = currentSL;

   if(newTP > 0)
      newTP = NormalizeDouble(newTP, _Digits);
   else
      newTP = currentTP;

   // Verificar si hay cambios
   if(MathAbs(newSL - currentSL) < _Point && MathAbs(newTP - currentTP) < _Point)
   {
      return true;
   }

   // Intentar modificar con reintentos
   bool resultado = false;
   int intentos = 0;

   while(intentos < MAX_RETRY_ATTEMPTS && !resultado)
   {
      intentos++;

      resultado = trade.PositionModify(ticket, newSL, newTP);

      if(resultado)
      {
         LogMessage("鉁� Posici贸n #" + IntegerToString(ticket) + " modificada - " +
                   "SL: " + DoubleToString(newSL, _Digits) +
                   " | TP: " + DoubleToString(newTP, _Digits), LOG_DEBUG);
         return true;
      }
      else
      {
         int errorCode = GetLastError();
         string errorDesc = trade.ResultRetcodeDescription();

         LogMessage("Error modificando #" + IntegerToString(ticket) + " (Intento " +
                   IntegerToString(intentos) + "/" + IntegerToString(MAX_RETRY_ATTEMPTS) + "): " +
                   IntegerToString(errorCode) + " - " + errorDesc, LOG_WARNING);

         if(errorCode == ERR_SERVER_BUSY || errorCode == ERR_NO_CONNECTION)
         {
            Sleep(RETRY_DELAY);
         }
         else
         {
            break;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| SECTION 31: POSITION MANAGEMENT FUNCTIONS                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CerrarPosicion() - Cerrar posici贸n (COPIED FROM GRIDTRADER)      |
//+------------------------------------------------------------------+
bool CerrarPosicion(ulong ticket)
{
   if(ticket == 0)
      return false;

   // Seleccionar la posici贸n
   if(!PositionSelectByTicket(ticket))
   {
      LogMessage("Error: No se pudo seleccionar posici贸n #" + IntegerToString(ticket), LOG_ERROR);
      return false;
   }

   // Verificar que la posici贸n pertenece a este EA
   if(PositionGetInteger(POSITION_MAGIC) != MagicNumber)
   {
      LogMessage("Error: Posici贸n #" + IntegerToString(ticket) + " no pertenece a este EA", LOG_WARNING);
      return false;
   }

   // Obtener datos de la posici贸n
   string symbol = PositionGetString(POSITION_SYMBOL);
   double volume = PositionGetDouble(POSITION_VOLUME);
   ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   // Intentar cerrar con reintentos
   bool resultado = false;
   int intentos = 0;

   while(intentos < MAX_RETRY_ATTEMPTS && !resultado)
   {
      intentos++;

      resultado = trade.PositionClose(ticket);

      if(resultado)
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         string tipoStr = (posType == POSITION_TYPE_BUY) ? "BUY" : "SELL";

         LogMessage("鉁� Posici贸n " + tipoStr + " cerrada - Ticket: " + IntegerToString(ticket) +
                   " | Profit: " + DoubleToString(profit, 2) + "$", LOG_INFO);
         return true;
      }
      else
      {
         int errorCode = GetLastError();
         string errorDesc = trade.ResultRetcodeDescription();

         LogMessage("Error cerrando #" + IntegerToString(ticket) + " (Intento " +
                   IntegerToString(intentos) + "/" + IntegerToString(MAX_RETRY_ATTEMPTS) + "): " +
                   IntegerToString(errorCode) + " - " + errorDesc, LOG_ERROR);

         // Si es error recuperable, esperar y reintentar
         if(errorCode == ERR_SERVER_BUSY || errorCode == ERR_NO_CONNECTION)
         {
            Sleep(RETRY_DELAY);
         }
         else
         {
            break;
         }
      }
   }

   LogMessage("FALLO al cerrar posici贸n #" + IntegerToString(ticket) + " despu茅s de " +
             IntegerToString(intentos) + " intentos", LOG_ERROR);
   return false;
}

//+------------------------------------------------------------------+
//| Monitor open position                                            |
//+------------------------------------------------------------------+
void MonitorOpenPosition()
{
    if(!g_PositionOpen) return;

    // Check if position still exists
    if(!PositionSelectByTicket(g_CurrentTicket)) {
        // Position was closed
        g_PositionOpen = false;
        // TODO: Get result from history and update statistics
        LogMessage("Posici贸n cerrada - Ticket: " + IntegerToString(g_CurrentTicket), LOG_INFO);
        return;
    }

    // Apply trailing stop if enabled
    if(UseTrailingStop) {
        ApplyTrailingStop();
    }

    // Update current profit
    double profit = PositionGetDouble(POSITION_PROFIT);
    g_State.positionProfit = profit;
}

//+------------------------------------------------------------------+
//| Apply trailing stop to open position                             |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
{
    if(!g_PositionOpen) return;
    if(!PositionSelectByTicket(g_CurrentTicket)) return;

    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentSL = PositionGetDouble(POSITION_SL);
    double currentTP = PositionGetDouble(POSITION_TP);

    MqlTick tick;
    if(!SymbolInfoTick(_Symbol, tick)) return;

    double currentPrice = (posType == POSITION_TYPE_BUY) ? tick.bid : tick.ask;

    // Calculate current profit in pips
    double profitPips = 0;
    if(posType == POSITION_TYPE_BUY) {
        profitPips = (currentPrice - entryPrice) / _Point;
    } else {
        profitPips = (entryPrice - currentPrice) / _Point;
    }

    // Check if profit is enough to start trailing
    if(profitPips < TrailingStartPips) return;

    // Calculate new SL
    double newSL = 0;
    if(posType == POSITION_TYPE_BUY) {
        newSL = currentPrice - (TrailingStopPips * _Point);
        // Only move SL up (never down)
        if(newSL <= currentSL) return;
    } else {
        newSL = currentPrice + (TrailingStopPips * _Point);
        // Only move SL down (never up)
        if(currentSL > 0 && newSL >= currentSL) return;
    }

    // Modify position
    if(ModificarPosicion(g_CurrentTicket, newSL, currentTP)) {
        LogToFile("TRAILING STOP APPLIED - New SL: " + DoubleToString(newSL, _Digits), LOG_INFO);
    }
}

//+------------------------------------------------------------------+
//| SECTION 32: LOGGING & STATISTICS FUNCTIONS                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Log to file                                                      |
//+------------------------------------------------------------------+
void LogToFile(string message, ENUM_LOG_LEVEL level)
{
    if(!EnableFileLogging) return;
    if(g_FileHandle == INVALID_HANDLE) return;

    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
    string levelStr = "";

    switch(level) {
        case LOG_ERROR:   levelStr = "[ERROR]  "; break;
        case LOG_WARNING: levelStr = "[WARN]   "; break;
        case LOG_INFO:    levelStr = "[INFO]   "; break;
        case LOG_DEBUG:   levelStr = "[DEBUG]  "; break;
    }

    string logLine = timestamp + " " + levelStr + message;
    FileWrite(g_FileHandle, logLine);
    FileFlush(g_FileHandle);
}

//+------------------------------------------------------------------+
//| Update statistics after trade close                              |
//+------------------------------------------------------------------+
void UpdateStatistics(double profit, bool isWin)
{
    if(!EnableStatistics) return;

    g_TotalTrades++;

    if(isWin) {
        g_WinningTrades++;
        g_TotalProfit += profit;
        g_ConsecutiveWins++;
        g_ConsecutiveLosses = 0;

        if(profit > g_LargestWin) {
            g_LargestWin = profit;
        }
    } else {
        g_LosingTrades++;
        g_TotalLoss += MathAbs(profit);
        g_ConsecutiveLosses++;
        g_ConsecutiveWins = 0;

        if(MathAbs(profit) > g_LargestLoss) {
            g_LargestLoss = MathAbs(profit);
        }
    }

    // Calculate derived metrics
    g_State.winRate = g_TotalTrades > 0 ?
                      (double)g_WinningTrades / g_TotalTrades * 100.0 : 0.0;

    g_State.profitFactor = g_TotalLoss > 0 ?
                           g_TotalProfit / g_TotalLoss : 0.0;

    // Log statistics
    LogMessage("鈺佲攢鈺� STATISTICS UPDATE 鈺佲攢鈺�", LOG_INFO);
    LogMessage("Total Trades: " + IntegerToString(g_TotalTrades), LOG_INFO);
    LogMessage("Win Rate: " + DoubleToString(g_State.winRate, 1) + "%", LOG_INFO);
    LogMessage("Profit Factor: " + DoubleToString(g_State.profitFactor, 2), LOG_INFO);

    LogToFile("STATISTICS - Total: " + IntegerToString(g_TotalTrades) +
             " | WinRate: " + DoubleToString(g_State.winRate, 1) + "%" +
             " | PF: " + DoubleToString(g_State.profitFactor, 2), LOG_INFO);
}

//+------------------------------------------------------------------+
//| SECTION 33: UTILITY FUNCTIONS                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Normalize lot size                                               |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
{
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

    if(lots < minLot) lots = minLot;
    if(lots > maxLot) lots = maxLot;

    lots = MathFloor(lots / lotStep) * lotStep;

    return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Get current spread in pips                                       |
//+------------------------------------------------------------------+
double GetCurrentSpread()
{
    MqlTick tick;
    if(!SymbolInfoTick(_Symbol, tick)) return 999.9;

    double spread = (tick.ask - tick.bid) / _Point;
    return spread;
}

//+------------------------------------------------------------------+
//| END OF FILE - SimpleNY200 v1.0 COMPLETE                          |
//+------------------------------------------------------------------+

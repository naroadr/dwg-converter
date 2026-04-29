#SingleInstance Force
SetKeyDelay, 50
SetMouseDelay, 50
SetWinDelay, 100

; ============================
; RUTAS
; ============================

CarpetaProcesados := A_ScriptDir . "\Planos procesados"
CarpetaCSV := A_ScriptDir . "\estado procesamiento"
CarpetaLogs := A_ScriptDir . "\Logs"

FileCreateDir, %CarpetaProcesados%
FileCreateDir, %CarpetaCSV%
FileCreateDir, %CarpetaLogs%

; ============================
; LOG
; ============================

FormatoFecha := A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec
LogFile := CarpetaLogs . "\log_" . FormatoFecha . ".txt"

FileAppend, `n`n==============================`n, %LogFile%
FileAppend, Inicio: %A_Now%`n, %LogFile%
FileAppend, ==============================`n, %LogFile%

; ============================
; FUNCIONES
; ============================

Log(Msg) {
    global LogFile
    FileAppend, %Msg%`n, %LogFile%
}

ProcesarArchivo(Nombre) {
    global BORRAR_X, BORRAR_Y, TODO_X, TODO_Y, CONFIRMAR_X, CONFIRMAR_Y
    global CARGAR_X, CARGAR_Y, ALMACENAR_X, ALMACENAR_Y, DWG_X, DWG_Y, CMD_X, CMD_Y
    global CarpetaProcesados, Carpeta, TimeoutGlobal

    Log("Procesando: " . Nombre)
    Inicio := A_TickCount

    ; ============================================================
    ; 1) BORRAR EL PLANO ANTERIOR
    ; ============================================================

    ; CLIC FUERA PARA SALIR DEL MODO ESCRITURA
    Click, 50, 50
    Sleep, 600

    ; DELAY MUY GRANDE PARA QUE ME10 TERMINE DE PENSAR
    Sleep, 5000   ; <--- AQUI EL DELAY GRANDE QUE PEDISTE

    ; AHORA SÍ: BORRAR EL PLANO
    Click, %BORRAR_X%, %BORRAR_Y%
    Sleep, 700


    Click, %TODO_X%, %TODO_Y%
    Sleep, 500

    Click, %CONFIRMAR_X%, %CONFIRMAR_Y%
    Sleep, 900

    ; ============================================================
    ; 2) CARGAR EL NUEVO PLANO
    ; ============================================================

    Click, %CARGAR_X%, %CARGAR_Y%
    Sleep, 600

    Send, '%Nombre%
    Sleep, 600

    Send, {Enter}
    Sleep, 1000

    ; SALIR DEL MODO ESCRITURA
    Send, {Esc}
    Sleep, 300
    Click, 50, 50
    Sleep, 400

    ; ============================================================
    ; 3) EXPORTAR A DWG
    ; ============================================================

    Click, %ALMACENAR_X%, %ALMACENAR_Y%
    Sleep, 500

    Click, %DWG_X%, %DWG_Y%
    Sleep, 500

    Click, %CMD_X%, %CMD_Y%
    Sleep, 400

    Send, '%Nombre%
    Sleep, 400
    Send, {Enter}

    ; ============================================================
    ; ESPERAR A QUE SE GENERE EL DWG
    ; ============================================================

    Loop {
        Sleep, 200

        if FileExist(CarpetaProcesados . "\" . Nombre . ".dwg") {
            Log("OK: " . Nombre)
            return
        }

        if FileExist(Carpeta . "\" . Nombre . ".dwg") {
            FileMove, %Carpeta%\%Nombre%.dwg, %CarpetaProcesados%\%Nombre%.dwg, 1
            Log("OK: " . Nombre)
            return
        }

        if (A_TickCount - Inicio > TimeoutGlobal) {
            Log("ERROR timeout: " . Nombre)
            return
        }
    }
}

; ============================
; SETUP BOTONES
; ============================

MsgBox, 64, Setup, Coloca el raton sobre BORRAR y pulsa F12.
KeyWait, F12, D
MouseGetPos, BORRAR_X, BORRAR_Y

MsgBox, 64, Setup, Coloca el raton sobre TODO y pulsa F12.
KeyWait, F12, D
MouseGetPos, TODO_X, TODO_Y

MsgBox, 64, Setup, Coloca el raton sobre CONFIRMAR y pulsa F12.
KeyWait, F12, D
MouseGetPos, CONFIRMAR_X, CONFIRMAR_Y

MsgBox, 64, Setup, Coloca el raton sobre CARGAR y pulsa F12.
KeyWait, F12, D
MouseGetPos, CARGAR_X, CARGAR_Y

MsgBox, 64, Setup, Coloca el raton sobre ALMACENAR y pulsa F12.
KeyWait, F12, D
MouseGetPos, ALMACENAR_X, ALMACENAR_Y

MsgBox, 64, Setup, Coloca el raton sobre DWG y pulsa F12.
KeyWait, F12, D
MouseGetPos, DWG_X, DWG_Y

MsgBox, 64, Setup, Coloca el raton sobre la linea de comandos y pulsa F12.
KeyWait, F12, D
MouseGetPos, CMD_X, CMD_Y

; ============================
; SELECCIONAR CARPETA
; ============================

FileSelectFolder, Carpeta, , 3, Selecciona la carpeta con los archivos
if Carpeta =
{
    MsgBox, No seleccionaste carpeta. Saliendo.
    ExitApp
}

; ============================
; LISTA DE ARCHIVOS
; ============================

FileList := ""

Loop, %Carpeta%\*.*, 0
{
    NombreCompleto := A_LoopFileName

    if (SubStr(NombreCompleto, -3) = ".dwg")
        continue

    FileList .= NombreCompleto . "`n"
}

; ============================
; PROCESO PRINCIPAL
; ============================

Sleep, 2000

Loop, Parse, FileList, `n, `r
{
    Nombre := A_LoopField
    if (Nombre = "")
        continue

    ProcesarArchivo(Nombre)
}

ExitApp

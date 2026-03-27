Process, Priority, , High
SendMode, Input
ListLines, Off
SetBatchLines, -1
CoordMode, Pixel, Window  
CoordMode, Mouse, Window  
CoordMode, ToolTip, Window  

IniRead, anticipo, config.ini, delays, anticipation, 0
IniRead, ajusteReaccionMin, config.ini, delays, minReactionTime, 0
IniRead, ajusteReaccionMax, config.ini, delays, maxReactionTime, 0

if(!anticipo or !ajusteReaccionMin or !ajusteReaccionMax){
	MsgBox, config.ini > invalid values
	ExitApp
}

atan2 := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "msvcrt.dll", "Ptr"), "AStr", "atan2", "Ptr")
OnExit("ExitFunc")


;centroCirculo := crearPunto(835, 379)

;cuadroObjetivo := {"x1":760, "y1":604, "x2":760+149, "y2":604+149}
cuadroObjetivo := {"x1":760, "y1":304, "x2":760+149, "y2":304+149}
	cx := (cuadroObjetivo.x2 + cuadroObjetivo.x1)//2
	cy := (cuadroObjetivo.y2 + cuadroObjetivo.y1)//2
centroCirculo := crearPunto(cx, cy)

2partes := partirRegion(cuadroObjetivo, 2, 1)
6partes := partirRegion(cuadroObjetivo, 2, 3)
9partes := partirRegion(cuadroObjetivo, 3, 3)
;16partes := partirRegion(cuadroObjetivo, 4, 4)
8fila := partirRegion(cuadroObjetivo, 2, 8)
5columna := partirRegion(cuadroObjetivo, 5, 1)
if (2partes = -1){
	MsgBox, 2partes > -1
	ExitApp
}

if (6partes = -1){
	MsgBox, 6partes > -1
	ExitApp
} 

if (9partes = -1){
	MsgBox, 9partes > -1
	ExitApp
}

if (8fila = -1){
	MsgBox, 9partes > -1
	ExitApp
}

if (5columna = -1){
	MsgBox, 9partes > -1
	ExitApp
}


MsgBox, Instructions:`nCtrl + f11 toggle on/off script`nCtrl + f12 shows/hide overlay

return

1::
	punto := {}
	mode := buscarPuntaFranjaMeta(punto)
	if (mode = -1){
		showDebugMsg("Goal zone missing")
		return
	}
	ToolTip, % "Mode " . mode
	MouseMove, punto.x, punto.y
return

^f11::
	if(Togglef11:=!Togglef11){
		
		setTimer, detectaCirculoLanza, 5
		showDebugMsg("Auto circle On")
	
	}else{

		setTimer, detectaCirculoLanza, Off
		showDebugMsg("Auto circle Off")
	
	}
return


^f12::
	if (Togglef12:=!Togglef12){
		
		wId := WinExist("A")
		pt := []
		pt.push(cuadroObjetivo)
		;pt.push(9partes*)
		;pt.push(fila[1])
		;pt.push(8fila[1])
		;pt.push(8fila[16])
		;pt.push(8fila[15])
		;pt.push(5columna[1])
		;pt.push(5columna[3])
		;pt.push(5columna[5])
		;pt.push(16partes[1])
		;pt.push(16partes[4])
		;pt.push(16partes[13])
		;pt.push(16partes[16])
		ids := []
		loop, % pt.Count(){

			ids[A_Index] := makeSquare()
			drawSquare(wId, ids[A_Index], pt[A_Index].x1, pt[A_Index].y1, pt[A_Index].x2, pt[A_Index].y2)
		}

	}else{
	
		loop, % pt.Count(){

			hideSquare(ids[A_Index]) 

		}
		
	}
return


detectaCirculoLanza(){

	Global centroCirculo, anticipo, ajusteReaccionMin, ajusteReaccionMax
	static mode := 0, puntoFranjaMeta := {}
	
	if (!detectaCirculo()){
		;showDebugMsg("Circle hidden")
		return
	}

	Tooltip
	Random, tiempoReaccion, ajusteReaccionMin, ajusteReaccionMax

	puntoFranjaMeta := {}
	mode := buscarPuntaFranjaMeta(puntoFranjaMeta)
	if (mode = -1){
		showDebugMsg("Goal zone missing")
		return
	}
	
	goal := angulo360EntreCentroPunto(centroCirculo, puntoFranjaMeta)
	
	tLimit := A_TickCount + 3000
	lap := 1
	tail := goal - anticipo 
	leftTail := 0
	if(tail < 0){
		leftTail := 1
		tail := 360 - anticipo + goal
	}

	loop {
		
		showMonitor("Mode " . mode . " || Lap " . lap . " || Cicle " . A_Index)
		puntoFranjaProgresiva := buscarPuntaFranjaProgresiva()
		if (puntoFranjaProgresiva = false){
			showDebugMsg("Progress bar missing")
			return
		}

		pb := angulo360EntreCentroPunto(centroCirculo, puntoFranjaProgresiva)

		
		if (goal = -1 or pb = -1){
			showDebugMsg("Error, -a or -b")
			return
		}

		if(mode = 0){ ;normal mode
		
			;showMonitor(goal . " - " . pb)
			if ((goal - pb ) <= anticipo){
				Sleep, tiempoReaccion
				SoundBeep, 1900
				;sendDowSleepUp(letter)
				Sleep, 400
				return
			}


		}else if(mode = 1){ ;top-rigth mode
			
			
			;skip one lap
			if(pb > 180){
				lap := 2
			}
				

			if(lap = 2){

				if(leftTail){
					if(pb >= tail or pb <= goal){
						Sleep, tiempoReaccion
						SoundBeep, 1900
						;sendDowSleepUp(letter)
						Sleep, 400
						return
					}
				}else{
					if(pb >= tail && pb <= goal){
						Sleep, tiempoReaccion
						SoundBeep, 1900
						;sendDowSleepUp(letter)
						Sleep, 400
						return

					}
				}

			}
	
		}

		if(A_TickCount >= tLimit){
			showDebugMsg("Time over")
			return
		}
	
	}
	

}


;retorna:
;el punto si lo consigue
;false si no lo consigue
buscarPuntaFranjaProgresiva(){

	Global 8fila, 5columna

	;Puedo acelerar la busque si empienso a buscar la franja progresiva solo en la region donde esta
	
	static franjaProgresiva := 0x0F1416 ;BGR 
	;0xFFFFFF	
	static variacion := 32

	punto := pixelSearchDesdeAbajoDerecha(8fila[1], franjaProgresiva, variacion)
	if (punto != 0 and punto != 1 and punto != -1 ){
		return punto
	}

	punto := pixelSearchDesdeArribaIzquierda(5columna[1], franjaProgresiva, variacion)
	if (punto != 0 and punto != 1 and punto != -1 ){
		return punto
	}

		punto := pixelSearchDesdeArribaIzquierda(8fila[15], franjaProgresiva, variacion)
	if (punto != 0 and punto != 1 and punto != -1 ){
		return punto
	}

	punto := pixelSearchDesdeAbajoIzquierda(8fila[16], franjaProgresiva, variacion)
	if (punto != 0 and punto != 1 and punto != -1 ){
		return punto
	}

	punto := pixelSearchDesdeAbajoIzquierda(5columna[5], franjaProgresiva, variacion)
	if (punto != 0 and punto != 1 and punto != -1 ){
		return punto
	}

	punto := pixelSearchDesdeAbajoDerecha(8fila[2], franjaProgresiva, variacion)
	if (punto != 0 and punto != 1 and punto != -1 ){
		return punto
	}

	return false
}


;returns 0 si mode = normal, returns 1 is mode = top-rigth
buscarPuntaFranjaMeta(ByRef pt){
	
	Global 8fila, 5columna
	
	;static colorMeta := [0xDEA832, 0xCFAA31, 0xDDAF37]
	static colorMeta = [0x0F00E9]
	static variacion := 16


	loop, % colorMeta.Count() {
		
		
		punto := pixelSearchDesdeAbajoIzquierda(5columna[1], colorMeta[A_Index], variacion)
		if (punto != 0 and punto != 1 and punto != -1 ){
			pt := punto
			return 0
		}

		punto := pixelSearchDesdeAbajoIzquierda(8fila[1], colorMeta[A_Index], variacion)
		if (punto != 0 and punto != 1 and punto != -1 ){
			pt := punto
			return 0
		}

		punto := pixelSearchDesdeAbajoIzquierda(8fila[2], colorMeta[A_Index], variacion)
		if (punto != 0 and punto != 1 and punto != -1 ){
			pt := punto
			return 1 ;top-rigth mode
		}

		punto := pixelSearchDesdeArribaDerecha(5columna[5], colorMeta[A_Index], variacion)
		if (punto != 0 and punto != 1 and punto != -1 ){
			pt := punto
			return 1 ;top-rigth mode
		}
		
		punto := pixelSearchDesdeAbajoDerecha(8fila[16], colorMeta[A_Index], variacion)
		if (punto != 0 and punto != 1 and punto != -1 ){
			pt := punto
			return 0
		}

		punto := pixelSearchDesdeAbajoDerecha(8fila[15], colorMeta[A_Index], variacion)
		if (punto != 0 and punto != 1 and punto != -1 ){
			pt := punto
			return 0
		}


	}

	return -1	

}



detectaCirculo(){

	Global 9partes
	
	static colorFondoCirculo := 0xD8D9D8 
	static franjaProgresiva := 0xD8D9D8 
	static variacion := 8

	parteObjetivo := 9partes[2]

	PixelSearch, fx, fy, parteObjetivo.x1, parteObjetivo.y1, parteObjetivo.x2, parteObjetivo.y2, franjaProgresiva, variacion, fast
	if ErrorLevel
		return false

	PixelSearch, fx, fy, parteObjetivo.x1, parteObjetivo.y1, parteObjetivo.x2, parteObjetivo.y2, colorFondoCirculo, variacion, fast
	if ErrorLevel
		return false

	return true
}


hSend(key){

	SetKeyDelay, randomValue(30, 60), randomValue(30, 60)
	Send, % key

}





;retorna el punto donde se encontro el pixel
;-1 si entrada invalida
; 1 no found 
; 2 error
pixelSearchDesdeArribaDerecha(region, colorID, variation:=0){
		
	if (!region.x1 or !region.y1 or !region.x2 or !region.y2){
		return -1
	}

	if (colorID is not Xdigit){
		return -1
	}

	if (variation is not number){
		return -1
	}

	PixelSearch, fx, fy, region.x2, region.y1, region.x1, region.y2, colorID, variation, fast
	if(!ErrorLevel){
		return {"x":fx, "y":fy}
	}

	return ErrorLevel

}

;retorna el punto donde se encontro el pixel
;-1 si entrada invalida
; 1 no found 
; 2 error
pixelSearchDesdeAbajoDerecha(region, colorID, variation:=0){
	
	if (!region.x1 or !region.y1 or !region.x2 or !region.y2){
		return -1
	}

	if (colorID is not Xdigit){
		return -1
	}

	if (variation is not number){
		return -1
	}

	PixelSearch, fx, fy, region.x2, region.y2, region.x1, region.y1, colorID, variation, fast
	if(!ErrorLevel){
		return {"x":fx, "y":fy}
	}

	return ErrorLevel
}


;retorna el punto donde se encontro el pixel
;-1 si entrada invalida
; 1 no found 
; 2 error
pixelSearchDesdeAbajoIzquierda(region, colorID, variation:=0){
	
	if (!region.x1 or !region.y1 or !region.x2 or !region.y2){
		return -1
	}

	if (colorID is not Xdigit){
		return -1
	}

	if (variation is not number){
		return -1
	}

	PixelSearch, fx, fy, region.x1, region.y2, region.x2, region.y1, colorID, variation, fast
	if(!ErrorLevel){
		return {"x":fx, "y":fy}
	}

	return ErrorLevel
}

;retorna el punto donde se encontro el pixel
;-1 si entrada invalida
; 1 no found 
; 2 error
pixelSearchDesdeArribaIzquierda(region, colorID, variation:=0){
	
	if (!region.x1 or !region.y1 or !region.x2 or !region.y2){
		return -1
	}

	if (colorID is not Xdigit){
		return -1
	}

	if (variation is not number){
		return -1
	}

	PixelSearch, fx, fy, region.x1, region.y1, region.x2, region.y2, colorID, variation, fast
	if(!ErrorLevel){
		return {"x":fx, "y":fy}
	}

	return ErrorLevel
}


;retorn un arreglo de regiones
; -1 si entrada invalida
partirRegion(region, partesX:=1, partesY:=1){

	if (!region.x1 or !region.y1 or !region.x2 or !region.y2){
		return -1
	}

	if(partesX is not number or partesY is not number){
		return -1
	}


	;Calculo el windth y height de la region
	regionWidth := region.x2 - region.x1
	regionHeight := region.y2 - region.y1

	partesWindth := regionWidth/partesX
	partesHeight := regionHeight/partesY

	partes := []
	parte := {}
	y1 := region.y1
	x1 := region.x1

	;Creo partes desde arriba y desde la izquierda 
	loop, % partesY {

		loop, % partesX {

			parte := region(x1, y1, x1 + partesWindth, y1 + partesHeight)
			partes.push(parte)
			
			x1+=partesWindth

		}

		x1 := region.x1
		y1 += partesHeight

	}


	return partes

}


region(x1, y1, x2, y2){

	if (!x1 or !y1 or !x2 or !y2){
		return -1
	}

	return {"x1":x1, "y1":y1, "x2":x2, "y2":y2}

}

crearPunto(x, y){
	
	if (!x or !y){
		return false
	}
	
	return {"x":x, "y":y}
}

angulo360EntreCentroPunto(centro, punto){

    Global atan2
    if(!centro.x or !centro.y or !punto.x or !punto.y){
        return -1
    }

    static Pi := 4 * ATan(1)
    static Conversion := 180 / Pi  ; Radianes a grados

    angulo := DllCall(atan2, "Double", punto.x-centro.x, "Double", centro.y-punto.y, "CDECL Double") * Conversion
    if (angulo < 0)
        angulo += 360
    return angulo

}

sendDowSleepUp(key){
	
	Random, delay, 50, 110
	Send, { %key% down}
	Sleep, delay
	Send, { %key% up}

}


makeSquare(cc:="Blue") {
	
	Gui, New, +HwndhwndSquare +AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x80020
	Gui, Color, %cc%
	return hwndSquare

}

drawSquare(relativeHwnd:=0, hwndSquare:=0, x1:=0, y1:=0, x2:=0, y2:=0, T:=3){
    
    if (!hwndSquare or !x1 or !y1 or !x2 or !y2)
        return
    if (relativeHwnd != 0){
        win := WinExist(hwnd)
        if !win
            return
        WinGetPos, wx, wy, _, _, ahk_id %relativeHwnd%
        x1+=wx
        y1+=wy
        x2+=wx
        y2+=wy

    }

    W := x2 - x1
    H := y2 - y1
    w2:=W-T
    h2:=H-T
    Gui, %hwndSquare%: +LastFound 
    Gui, %hwndSquare%: Show, w%W% h%H% x%x1% y%y1% NA
    WinSet, Transparent, 150
    WinSet, Region, 0-0 %W%-0 %W%-%H% 0-%H% 0-0 %T%-%T% %w2%-%T% %w2%-%h2% %T%-%h2% %T%-%T%

}


moveSquare(hwndSquare, X:=0, Y:=0){

	if (!hwndSquare)
		return

	WinMove, ahk_id %hwndSquare%, , X, Y
}

hideSquare(hwndSquare){

	if (!hwndSquare)
		return

	Gui, %hwndSquare%:Hide

}


showDebugMsg(msg:=""){
	
	Tooltip, % msg
	setTimer, remTooltip, -500

	return

}


showMonitor(txt){

	static x := A_ScreenWidth//4
	static y := A_ScreenHeight//4

	Tooltip, % txt, x, y, 18 
	setTimer, remTooltip, 5000
	
}


ExitFunc(ExitReason, ExitCode){
    Global atan2
    DllCall("FreeLibrary", "Ptr", atan2)  ; To conserve memory, the DLL may be unloaded after using it.
}

remTooltip(){
	Tooltip
}

randomValue(min, max){
    return  distribucionAlObjetivo(min, ((min+max)//2), max)
}


distribucionAlObjetivo(ini, objetivo, fin){
  
    Random, izq, ini, objetivo
    Random, der, objetivo, fin
    Random, cerca, izq, der
    return cerca

}
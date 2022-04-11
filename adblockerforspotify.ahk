
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;~ gui,+AlwaysOnTop
#Persistent
SetTimer, CheckState, 1000
return

CheckState:
Process, Exist, Spotify.exe
if !ErrorLevel ; Spotify is not running
{
	Sleep 3000
	Tray_Refresh() ; To clean the Toastify icon from the tray
	ExitApp ; Terminate this script
}
else
{
	WinGet, id, List, Advertisement
	Loop, %id%
	{
		this_id := id%A_Index%
		WinGetClass, this_class, ahk_id %this_id%
		if (%this_class% = Chrome_WidgetWin_0)
		{
			Kill_Ad()
			Tray_Refresh()
			break
		}
	}
	return
}

MButton::
	Kill_Ad()
	Tray_Refresh()

Kill_Ad()
{
	WinGet, active_id, ID, A ; Get the ID of an active window
	Process, Close, Spotify.exe
	Process, Close, Toastify.exe
	Run, "%A_AppData%\Spotify\Spotify.exe", , hide
	Run, "%A_ProgramFiles%\Toastify\Toastify.exe", , hide
	WinWaitActive, ahk_exe Spotify.exe ; Wait for Spotify to get focus
	Send {Media_Next}
	Sleep 500 ; If the Media_Next doesn't get triggered, increase this value
	WinActivate, ahk_id %active_id% ; Reactivate the window we were previously using
	return
}

Tray_Refresh()
{
	WM_MOUSEMOVE := 0x200
	HiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On
	TrayTitle := "AHK_class Shell_TrayWnd"
	ControlNN := "ToolbarWindow323"
	IcSz := 24
	Loop, 2
	{
		ControlGetPos, xTray,yTray,wdTray,htTray, %ControlNN%, %TrayTitle%
		y := htTray - 10
		While (y > 0)
		{
			x := wdTray - IcSz/2
			While (x > 0)
			{
				point := (y << 16) + x
				PostMessage, %WM_MOUSEMOVE%, 0, %point%, %ControlNN%, %TrayTitle%
				x -= IcSz/2
			}
			y -= IcSz/2
		}
		TrayTitle := "AHK_class NotifyIconOverflowWindow"
		ControlNN := "ToolbarWindow321"
		IcSz := 32
	}
	DetectHiddenWindows, %HiddenWindows%
	Return
}
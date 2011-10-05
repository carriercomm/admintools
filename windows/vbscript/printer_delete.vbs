'# os: windows
'# version: 1.0
'# purpose:  attempts to delete printer by printer name. It will also add itself to RunOnce to run delete after first reboot

Function DeletePrinter(printer)
	Dim oShell, regKey, regCleanup

	Set oShell = CreateObject("Wscript.Shell")

	oShell.Run "rundll32 printui.dll,PrintUIEntry /dl " & _
					"/n """& printer &""" /q", 0, True

	oShell.Run "rundll32 printui.dll,PrintUIEntry /dd " & _
					"/m """& printer &""" " & _
					"/h ""Intel"" /v ""Windows 2000 or XP"" /q", 0, True

	regKey = "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce\" & printer & " Driver Cleanup"
	regCleanup = "rundll32 printui.dll,PrintUIEntry /dd /m """& printer &""" /h ""Intel"" /v ""Windows 2000 Or XP"" /q"
	oShell.RegWrite regKey, regCleanup, "REG_SZ"

	Set oShell = nothing
End Function

DeletePrinter "HP LaserJet Professional M1212nf MFP"

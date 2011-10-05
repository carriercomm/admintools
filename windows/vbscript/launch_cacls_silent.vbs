# os: windows
# version: 1.0
# purpose:  launch cacls.exe and set permissions on MSI CustomActionData passed to deferred exec stage
#
# requires: MSI Session environment (CustomActionData passed from immediate exec stage)

On Error Resume Next

Function SetPermissions(strWhere,strPerm)
	Dim objShell

	Set objShell = CreateObject("Wscript.Shell")

	objShell.Run "cacls """& strWhere &""" /t /e /c /g "& strPerm, 0, True

	Set objShell = Nothing
End Function

' The CustomActionData directory cannot contain a trailing slash!
SetPermissions Session.Property("CustomActionData"), "Users:C"

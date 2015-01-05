@echo off
SETLOCAL
 
set _FILENAME=C:\Windows\Temp\mssql.vbs
 
call :EXTRACT START_RESOLVE_VBS %_FILENAME%
GOTO :EOF  
 
:EXTRACT
IF DEFINED INSIDE SET INSIDE=
 
for /f "tokens=*" %%A IN ('type %~f0') DO (
  IF DEFINED INSIDE (
    IF "%%A" == "ENDVBS" GOTO :EOF  
    echo %%A>>%~2
  ) ELSE (  
    IF "%%A" == "%~1" SET INSIDE=1  
  )  
)  
GOTO :EOF  
 
START_RESOLVE_VBS
 
Dim strValueName, strSKUName, strEdition, strVersion, strArchitecture 
Dim objWMI, objProp
 
On Error Resume Next
' First try SQL Server 2008/2008 R2:
Set objWMI = GetObject("WINMGMTS:\\.\root\Microsoft\SqlServer\ComputerManagement10")
If Err.Number <> 0 Then
    ' Next, try SQL Server 2005:
    Set objWMI = GetObject("WINMGMTS:\\.\root\Microsoft\SqlServer\ComputerManagement")
    If Err.Number <> 0 Then
        ' Next, try SQL Server 2012:
        Set objWMI = GetObject("WINMGMTS:\\.\root\Microsoft\SqlServer\ComputerManagement11")
    End If
End If
 
 
If Err.Number = 0 Then
 
    On Error Goto 0
    ' Go through the properties (which is just one) and find the name of the SKU.
    For Each objProp In objWMI.ExecQuery("select * from SqlServiceAdvancedProperty where SQLServiceType = 1 AND (PropertyName = 'SKUNAME' OR PropertyName = 'VERSION')")
        If objProp.PropertyName = "SKUNAME" THEN
            strSKUName = objProp.PropertyStrValue
        Else
            strVersion = objProp.PropertyStrValue
        End If
    Next
 
    ' We do not want the number of bits, so chop it off!
    If Instr(strSKUName, " (") <> 0 Then
        strEdition = Left(strSKUName, Instr(strSKUName, " ("))
        strArchitecture = "64-bit"
    Else
        strEdition = strSKUName
        strArchitecture = "32-bit"
    End If
 
    WScript.Echo strEdition & " / " & strSKUName & " / " & strArchitecture
 
End If
 
ENDVBS
 
:EOF
 
CSCRIPT /B %_FILENAME%
 
DEL /F %_FILENAME%
 
ENDLOCAL


<%Option Explicit%>
<html>

<head>
<title>  </title>
</head>

<body>


<%


Response.Write(Request.QueryString) 
'if Request.QueryString("param")= "yes" then 
	Response.write "getComputerName = " & getComputerName() 
'end if 


Function getComputerName() 
	Dim sIP 
	Dim oShell, oExec, sCommand, sOutput 
	sIP = Request.ServerVariables("REMOTE_ADDR") 
	''watch for line wrap - begin 
	sCommand = "%comspec% /c @echo off & for /f ""tokens=2"" %q in ('ping -n 1 -a " & sIP & "^|find /i ""pinging""') do echo %q" 
	''watch for line wrap - end 
	Set oShell = CreateObject("WScript.Shell") 
	Set oExec = oShell.Exec(sCommand) 
	sOutput = oExec.StdOut.ReadAll 
	Set oExec = Nothing 
	Set oShell = Nothing 
	getComputerName = sOutput 
end Function 


%>
</body>
</html>

<%Option Explicit%>
<%Response.Buffer = TRUE%>
<% Response.Clear %>
<html>

<head>
<title>Config File</title>
</head>

<body>


<!-- #include File=adovbs.inc -->


<%

Dim conn			
Dim sql				
Dim rs
Dim FILE_ID

'Get the FILE_ID number for the desired config file.
FILE_ID = Request("ID") 

Set conn = Server.CreateObject("ADODB.Connection")

conn.Open Application("Shark")



sql = "SELECT Data From UnitConfigFiles  WHERE FILE_ID = '" & FILE_ID & "'"



Set rs = conn.Execute(sql)


Response.Clear
Response.ContentType = "text/plain"



Response.Write rs("Data").value



Conn.Close
Set Conn = Nothing


%>


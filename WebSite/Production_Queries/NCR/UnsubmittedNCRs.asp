<%Option Explicit%>
<html>

<head>
<title>Unsubmitted NCRs</title>
</head>

<body>
<!-- #include File=..\Tools\GenericTable.Inc -->

<h2 align="center">Unsubmitted NCRs</h2>
<%
Dim Query
Dim Conn


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("ProductionDatabase")
	
Query = "SELECT * FROM [NCR - Unsubmitted] ORDER BY Filename"

GenericTable Conn, Query

%>
</body>
</html>

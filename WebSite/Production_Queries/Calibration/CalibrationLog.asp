<%Option Explicit%>
<html>

<head>
<title>Calibration Log</title>
</head>

<body>
<!-- #include File=..\Tools\GenericTable.Inc -->

<h2 align="center">Calibration Log</h2>
<%
Dim Query
Dim Conn


Set Conn = Server.CreateObject("ADODB.Connection")
Conn.Open Application("ProductionDatabase")
	
Query = "SELECT * FROM Calibration ORDER BY [Due Date]"


GenericTable Conn, Query

%>
</body>
</html>

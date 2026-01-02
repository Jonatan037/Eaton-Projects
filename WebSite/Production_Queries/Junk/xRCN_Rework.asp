<%Option Explicit%>
<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 3.0">
<title>RCN Rework</title>

<meta name="Microsoft Theme" content="indust 101"></head>
<!-- #include File=GenericTable.inc -->

<body background="../_themes/indust/indtextb.jpg" bgcolor="#FFFFFF" text="#000000" link="#3366CC" vlink="#666666" alink="#FF3300"><!--mstheme--><font face="trebuchet ms, arial, helvetica">

<h2 align="center"><!--mstheme--><font color="#CC6666">RCN Rework Status<!--mstheme--></font></h2>

<!--msthemeseparator--><p align="center"><img src="../_themes/indust/indhorsd.gif" width="300" height="10"></p>

<p><%
	Dim Conn
	Dim SQL

	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Application("ProductionDatabase")


	SQL =	"SELECT DISTINCT(SerialNumber) FROM Index " & _
			"WHERE " & _
 				"(Workcell IN('TF091', 'TF086') AND StartTime >= #05/19/2000# AND Results = 1 AND PartNumber Not Like 'CPR235%') " & _

				"OR " & _
					"(Workcell IN('TF064', 'TF084') AND StartTime BETWEEN #05/25/2000# AND #05/27/2000# " & _
						"AND PartNumber LIKE 'CPR%' AND Results = 1) " & _

				"OR " & _
					"(Workcell IN('TF064', 'TF084') AND StartTime BETWEEN #05/31/2000# AND #06/01/2000# " & _
						"AND PartNumber LIKE 'CPR%' AND SerialNumber LIKE 'GR%' AND Results = 1) " & _

			"ORDER BY SerialNumber"


	Response.Write SQL & "<br><br>"
	'Response.End

	GenericTable Conn, SQL

%> </p>
<!--mstheme--></font></body>
</html>

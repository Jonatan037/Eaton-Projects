<%Option Explicit%>
<% Response.Buffer = TRUE %>
<% Response.Clear %>
<html>

<head>
<title>Failure Informationt</title>
</head>

<body>
<%

	Dim QueryStartDate
	Dim QueryEndDate
	Dim DateRange

	QueryStartDate = Request("StartMonth") & "/" & Request("StartDay") & "/" & Request("StartYear")
	QueryEndDate   = CDate(Request("EndMonth")   & "/" & Request("EndDay")   & "/" & Request("EndYear") ) + 1

	Session("QueryStartDate") = QueryStartDate
	Session("QueryEndDate") = QueryEndDate


	DateRange = "QueryStartDate=" & QueryStartDate & "&QueryEndDate=" & QueryEndDate


	Response.Write "Failure information for " & QueryStartDate & " to " & QueryEndDate - 1 & "<BR><BR>"



	Response.Write "<A HREF='View\FailureInfo_Ferrups.asp?" & DateRange & "'> View 9170/Ferrups Failure Information</A>"
	Response.Write "<BR><BR>"


	Response.Write "<A HREF='View\FailureInfo_EPDU.asp?" & DateRange & "'> View ePDU Failure Information</A>"
	Response.Write "<BR><BR>"


	Response.Write "<A HREF='View\FailureInfo_SPD.asp?" & DateRange & "'> View SPD Failure Information</A>"
	Response.Write "<BR><BR>"



	Response.Write "<BR><BR><BR><BR>"

	Response.Write "<A HREF='Update\ePDU\UDA_Login.asp?" & DateRange & "'> Update ePDU Failure Information</A>"
	Response.Write "<BR><BR>"


%>
</body>
</html>

<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Support_Yields_Test_Report.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_Support_Support_Yields_Test_Report" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Test Report</h2>

    <asp:DetailsView ID="dvReportHeader" runat="server" FieldHeaderStyle-Font-Bold="true">
        <AlternatingRowStyle BackColor="#CCCCCC" />
    </asp:DetailsView>
    <br />

    <asp:GridView ID="gvReportBody" runat="server">
        <AlternatingRowStyle BackColor="#CCCCCC" />
    </asp:GridView>

        <br />
        <br />


    </asp:Content>


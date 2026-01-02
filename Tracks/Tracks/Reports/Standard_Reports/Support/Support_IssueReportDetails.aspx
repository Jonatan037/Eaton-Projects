<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Support_IssueReportDetails.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_ShowIssueReportDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:DetailsView ID="dvIssueReport" runat="server" DataKeyNames="ISSUE_REPORTS_ID"  >

        <AlternatingRowStyle BackColor="#CCCCCC" />

    </asp:DetailsView>


    <asp:Button ID="btnEdit" runat="server" Text="Edit" OnClick="btnEdit_Click" />
    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClick="btnPrint_Click" />

    <!-- maybe put master index details here for reference -->


</asp:Content>


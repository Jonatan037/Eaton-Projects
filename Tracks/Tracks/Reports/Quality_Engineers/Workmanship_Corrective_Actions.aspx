<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Workmanship_Corrective_Actions.aspx.cs" Inherits="Tracks_Reports_Quality_Engineers_Workmanship_Corrective_Actions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Corrective Actions</h2>

    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">
        Get Corrective Actions For <asp:DropDownList ID="ddlNonconformanceType" runat="server"></asp:DropDownList> Issues 
        From <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>   
        <br />
        <asp:Button ID="btnFind" runat="server" Text="Update" OnClick="btnFind_Click" />
        <br />
    </asp:Panel>
    <br />

    <asp:Label ID="lblSummary" runat="server" Text="Summary"/>
    <asp:GridView ID="gvSummary" runat="server" EmptyDataText="No data found for the specified criteria."></asp:GridView>
    <br /><br />

    <asp:Label ID="lblDetails" runat="server" Text="Details"/>
    <asp:GridView ID="gvDetails" runat="server" EmptyDataText="No data found for the specified criteria."></asp:GridView>
    <br /><br />

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />

    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>


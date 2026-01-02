<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Show_Test_Complete_Reports.aspx.cs" Inherits="Tracks_Reports_Miscellaneous_Reports_Show_Test_Complete_Reports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Show Test Complete Reports </h2>

    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;From <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>   
            <br />
            <br />
            <asp:Button ID="btnFind" runat="server" Text="Show Issues" OnClick="btnFind_Click" />
            <br /><br />
    </asp:Panel>


    <asp:GridView ID="GridView1" runat="server"></asp:GridView>

    <br />
    <asp:Button ID="btnDownload" runat="server" Text="Download to Excel" OnClick="btnDownload_Click" ToolTip="Download all of the data in this report to Excel." />
          

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />

    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>


</asp:Content>


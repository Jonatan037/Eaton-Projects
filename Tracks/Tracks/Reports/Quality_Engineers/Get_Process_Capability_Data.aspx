<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Get_Process_Capability_Data.aspx.cs" Inherits="Tracks_Reports_Quality_Engineers_Get_CpK_Data" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Download Process Capability Data For</h2>

    <asp:RadioButtonList ID="RadioButtonList1" runat="server">
        <asp:ListItem >9395</asp:ListItem>
        <asp:ListItem >9395P</asp:ListItem>
        <asp:ListItem >93PM</asp:ListItem>
        <asp:ListItem >93PM-L</asp:ListItem>

        <asp:ListItem >9355</asp:ListItem>
        <asp:ListItem >9x55</asp:ListItem>

    </asp:RadioButtonList>
    <br />


    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">
        From <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>   
        <asp:Button ID="btnFind" runat="server" Text="Download" OnClick="btnFind_Click" />
        <br />
    </asp:Panel>
    <br /><br />

    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>
    <br /><br />

    <asp:GridView ID="GridView1" runat="server" ShowHeaderWhenEmpty="True"></asp:GridView>




    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />



</asp:Content>


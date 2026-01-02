<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Component_Search.aspx.cs" Inherits="Tracks_Reports_Miscellaneous_Reports_Component_Search" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Search</h1>

    <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
        
        <asp:Label ID="Label1" runat="server" Text="Enter component part number"/>
        <br />
        <asp:TextBox ID="txtSearch" runat="server" Width="200px"></asp:TextBox>
        <asp:Button ID="btnSearch" runat="server" Text="Find" OnClick="btnSearch_Click" />

    </asp:Panel>
    <br />
    <asp:Label ID="lblTitle" runat="server" Text="No value selected."></asp:Label>
    <br />
    <br />


    <asp:GridView ID="gvComponents" runat="server" EmptyDataText="No reports found for the specified component part number." ShowHeaderWhenEmpty="True">

        <AlternatingRowStyle BackColor="#CCCCCC" />


    </asp:GridView>
    <br />
    <br />
    
    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>


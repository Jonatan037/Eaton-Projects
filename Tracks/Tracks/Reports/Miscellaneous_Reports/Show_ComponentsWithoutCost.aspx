<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Show_ComponentsWithoutCost.aspx.cs" Inherits="Tracks_Reports_Miscellaneous_Reports_Show_ComponentsWithoutCost" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">
    
    <h1>Components without cost setup</h1>

    <asp:GridView ID="GridView1" runat="server">

        <AlternatingRowStyle BackColor="#CCCCCC" />

    </asp:GridView>
    <br />

    <asp:Label ID="Label1" runat="server" Text=""></asp:Label>

</asp:Content>


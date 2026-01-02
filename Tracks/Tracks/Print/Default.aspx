<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Tracks_Print_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <script type = "text/javascript" src="../../Scripts/PrintPanel.js">
    </script>

    <h1>Print this </h1>
    <hr />

    <asp:Panel ID="pnlContents" runat="server">

        <h3>test</h3>

  

    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    


</asp:Content>


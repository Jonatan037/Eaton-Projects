<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PrintIssueReport - Copy.aspx.cs" Inherits="Tracks_Print_PrintIssueReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <script type = "text/javascript">
        function PrintPanel()
        {
            var panel = document.getElementById("<%=pnlContents.ClientID %>");
            var printWindow = window.open('', '', 'height=800,width=800');
            printWindow.document.write('<html><head><title></title>');
            printWindow.document.write('</head><body >');
            printWindow.document.write(panel.innerHTML);
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            setTimeout(function () { printWindow.print(); }, 500);
            printWindow.onfocus = function () { setTimeout(function () { printWindow.close(); }, 2000); }
            return false;
        }
    </script>

    <h1>Print this issue report</h1>
    <hr />

    <asp:Panel ID="pnlContents" runat="server">

        <h3>Issue Report</h3>

        <br />

        <asp:DetailsView ID="dvIssueReport" runat="server" AutoGenerateRows="true" >

            <AlternatingRowStyle BackColor="#CCCCCC" />

        </asp:DetailsView>

    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    


</asp:Content>


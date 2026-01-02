<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PrintUnitReport.aspx.cs" Inherits="Tracks_Print_PrintUnitReport" %>

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

    <h1>Print unit report</h1>
    <hr />

    <asp:Panel ID="pnlContents" runat="server" Width="670px" BackColor="Yellow">

        <h3>Unit Report</h3>
        <br />

        <h4>Unit Details</h4>
        <asp:DetailsView ID="dvMasterIndex" runat="server" >
            <AlternatingRowStyle BackColor="#CCCCCC" />
        </asp:DetailsView>
        <br />
        <br />

        <h4>Issue Reports</h4>
        <asp:GridView ID="gvIssueReports" runat="server">
            <AlternatingRowStyle BackColor="#CCCCCC" />
        </asp:GridView>


    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    


</asp:Content>


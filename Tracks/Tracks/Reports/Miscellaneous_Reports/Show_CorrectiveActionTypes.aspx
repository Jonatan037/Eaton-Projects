<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Show_CorrectiveActionTypes.aspx.cs" Inherits="NCRs_Miscellaneous_Reports_CorrectiveActionTypes" %>

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
            printWindow.onfocus = function () { setTimeout(function () { printWindow.close(); }, 1000); }
            return false;
        }
    </script>

    <asp:Panel ID="pnlContents" runat="server">

        <h1>Corrective Action Types</h1>

        <asp:GridView ID="GridView1" runat="server" >

            <AlternatingRowStyle BackColor="#CCCCCC" />

        </asp:GridView>

    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    
    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />


</asp:Content>
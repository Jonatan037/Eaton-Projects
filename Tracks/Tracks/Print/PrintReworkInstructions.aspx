<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PrintReworkInstructions.aspx.cs" Inherits="Tracks_Print_PrintIssueReport" %>

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

    <h1>Print rework instructions for this issue report</h1>
    <hr />

    <asp:Panel ID="pnlContents" runat="server">

        <asp:Table ID="Table1" runat="server">

            <asp:TableHeaderRow>
                <asp:TableCell>Serial Number: </asp:TableCell>
                <asp:TableCell><asp:Label ID="lblSerialNumber" runat="server"></asp:Label></asp:TableCell>
            </asp:TableHeaderRow>

           <asp:TableHeaderRow>
                <asp:TableCell>Part Number: </asp:TableCell>
                <asp:TableCell><asp:Label ID="lblPartNumber" runat="server"></asp:Label></asp:TableCell>
            </asp:TableHeaderRow>

           <asp:TableHeaderRow>
                <asp:TableCell>Family: </asp:TableCell>
                <asp:TableCell><asp:Label ID="lblFamily" runat="server"></asp:Label></asp:TableCell>
            </asp:TableHeaderRow>

        </asp:Table>

        <hr />
        <h1>Rework Instructions:</h1>
        <div id="divReworkInstructions" runat="server" style="font-size:x-large; white-space:pre-wrap; font:bold"  ></div>
        <br />
        <br />

        <hr />
        <h3>Problem Description Included For Reference:</h3>
        <div id="divProblemDescription" runat="server" style="white-space:pre-wrap"  ></div>

    </asp:Panel>


    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    


</asp:Content>


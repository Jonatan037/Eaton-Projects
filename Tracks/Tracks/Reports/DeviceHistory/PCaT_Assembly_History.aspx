<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PCaT_Assembly_History.aspx.cs" Inherits="Tracks_Reports_TNT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <script type="text/javascript">
        function divexpandcollapse(divname)
        {
            var div = document.getElementById(divname);
            var img = document.getElementById('img' + divname);

            if (div.style.display == "none") {
                div.style.display = "inline";
                img.src = "minus.gif";
            } else {
                div.style.display = "none";
                img.src = "plus.gif";
            }
        }
    </script>

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


    <asp:Panel ID="pnlContents" runat="server" >

        <h2>PCaT Assembly Record</h2>
        Enter serial number:&nbsp;
        <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox><asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
        <br /><br />

        <asp:GridView ID="GridView1" runat="server" DataKeyNames="SerialNumber" AutoGenerateColumns="false" OnRowDataBound="GridViewMain_RowDataBound" EmptyDataText="No data found" >
            <AlternatingRowStyle BackColor="#CCCCCC" />
        </asp:GridView>

        <br />


    </asp:Panel>

    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" Visible="false" />    

    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>


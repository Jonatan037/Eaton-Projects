<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Support_YieldDetails.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_ShowYieldDetails" %>

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

    <asp:Panel ID="pnlContents" runat="server">

       <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" Caption="Units with Issue Reports" EmptyDataText="No records found">

        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>

            <asp:BoundField DataField="PLANT" HeaderText="PLANT" />
            <asp:BoundField DataField="FAMILY" HeaderText="FAMILY" />
            <asp:BoundField DataField="CATEGORY" HeaderText="CATEGORY" />

            <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" />
            <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" />
            <asp:BoundField DataField="FAILED" HeaderText="FAILED" />

            <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="E#" />
            <asp:BoundField DataField="NONCONFORMANCE_CODE" HeaderText="NC" />

            <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="TIMESTAMP" />

            <asp:BoundField DataField="COMPONENTS" HeaderText="COMPONENTS" HtmlEncode="false" />

            <asp:BoundField DataField="PROBLEM_DESCRIPTION" HeaderText="PROBLEM_DESCRIPTION" />
            <asp:BoundField DataField="NOTES" HeaderText="NOTES" />

        </Columns>

    </asp:GridView>

    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    
    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />


</asp:Content>


<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PrintIssueReport.aspx.cs" Inherits="Tracks_Print_PrintIssueReport" %>

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


        <asp:DetailsView ID="dvIssueReport" runat="server" AutoGenerateRows="false" >
            <AlternatingRowStyle BackColor="#CCCCCC" />
            
            <Fields>
                <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" />
                <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" />
                <asp:BoundField DataField="PLANT" HeaderText="PLANT" />
                <asp:BoundField DataField="FAMILY" HeaderText="FAMILY" />
                <asp:BoundField DataField="CATEGORY" HeaderText="CATEGORY" />
                <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" />
                <asp:BoundField DataField="MASTER_INDEX_ID" HeaderText="MASTER_INDEX_ID" />
                <asp:BoundField DataField="STATION_TYPE" HeaderText="STATION_TYPE" />
                <asp:BoundField DataField="NONCONFORMANCE_CODE" HeaderText="NONCONFORMANCE_CODE" />
                <asp:BoundField DataField="ROOT_CAUSE_CODE" HeaderText="ROOT_CAUSE_CODE" />
                <asp:BoundField DataField="LOCKED" HeaderText="LOCKED" />
                <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID" />
                <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" />
                <asp:BoundField DataField="STATUS" HeaderText="STATUS" />
                <asp:BoundField DataField="CLOSED" HeaderText="CLOSED" />
                <asp:BoundField DataField="KEY" HeaderText="KEY" />

                <asp:BoundField DataField="PROBLEM_DESCRIPTION" HeaderText="PROBLEM_DESCRIPTION" HtmlEncode="false" />
                <asp:BoundField DataField="NOTES" HeaderText="NOTES" HtmlEncode="false" />
                <asp:BoundField DataField="REWORK_INSTRUCTIONS" HeaderText="REWORK_INSTRUCTIONS" HtmlEncode="false" />

            </Fields>


        </asp:DetailsView>


        <br />
        <br />
        <asp:GridView ID="gvComponents" runat="server" Caption="Components">
            <AlternatingRowStyle BackColor="#CCCCCC" />
        </asp:GridView>


    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    


</asp:Content>


<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ShowMasterIndexEntriesByDateRange.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_ShowMasterIndexEntriesByDateRange" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <script type = "text/javascript">
        function PrintPanel() {
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


    <h1>Show master index entries by date range</h1>

    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">

        <asp:Label ID="Label1" runat="server" Text="From "></asp:Label>
        <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox>
        <asp:Label ID="Label2" runat="server" Text=" to "></asp:Label>
        <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>
        <asp:Button ID="btnFind" runat="server" Text="Find" OnClick="btnFind_Click" />

    </asp:Panel>
    <br />



    <asp:Panel ID="pnlContents" runat="server" >

            <asp:GridView ID="gvMasterIndex" runat="server" AutoGenerateColumns="true" DataKeyNames="SERIAL_NUMBER" OnSelectedIndexChanged="gvMasterIndex_SelectedIndexChanged">
        
                <AlternatingRowStyle BackColor="#CCCCCC" />

                <Columns>

                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="lblView" runat="server" CausesValidation="False" CommandName="Select" Text="View"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

        </Columns>

            </asp:GridView>

    </asp:Panel>

    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    
    <asp:Button ID="btnDownload" runat="server" Text="Download to Excel" OnClick="btnDownload_Click" ToolTip="Download all of the data in this report to Excel." />
            
    <br />


    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />

    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>

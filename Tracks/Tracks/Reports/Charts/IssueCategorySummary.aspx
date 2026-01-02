<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="IssueCategorySummary.aspx.cs" Inherits="Tracks_Reports_Charts_IssueCategorySummary" %>

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


    <h2> Show Issue Categories Chart </h2>

    From <asp:TextBox ID="txtStartDate"  runat="server" ></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server" ></asp:TextBox>   
    <br /><br />


    <asp:Table runat="server">

        <asp:TableRow>
            <asp:TableCell>Plant</asp:TableCell>

            <asp:TableCell>

                <asp:DropDownList ID="ddlPlants" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPlants_SelectedIndexChanged">
                    <asp:ListItem>CPO</asp:ListItem>
                    <asp:ListItem Selected="True">YPO</asp:ListItem>
                </asp:DropDownList>

            </asp:TableCell>

        </asp:TableRow>

        <asp:TableRow>
            <asp:TableCell>Line</asp:TableCell>
            <asp:TableCell>  <asp:DropDownList ID="ddlLineName" runat="server" /> </asp:TableCell>
        </asp:TableRow>

        <asp:TableRow>
            <asp:TableCell>Station Type</asp:TableCell>
            <asp:TableCell> <asp:DropDownList ID="ddlStationType" runat="server"/> </asp:TableCell>
        </asp:TableRow>

    </asp:Table>

    <asp:Button ID="btnFind" runat="server" Text="Refresh" OnClick="btnFind_Click" />







    <br />
    <br />

    <asp:Panel ID="pnlContents" runat="server">

        <asp:Chart ID="Chart1" runat="server" Height="600px" Width="900px"  >

            <ChartAreas>
                <asp:ChartArea Name="ChartArea1" BorderWidth="0" />
            </ChartAreas>

        <Legends>
            <asp:Legend Alignment="Center" Docking="Bottom" IsTextAutoFit="False" Name="Default" LegendStyle="Row" />
        </Legends>

    <Titles>
        <asp:Title Font="Times New Roman, 18pt, style=Bold" Name="Title1" Text="" />
        <asp:Title Font="Times New Roman, 10pt, style=Bold" Name="Title2" Text="" />
        <asp:Title Font="Times New Roman, 10pt, style=Bold" Name="Title3" Text="" />
    </Titles>

        </asp:Chart>

    </asp:Panel>

    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />   
    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" /> 
    <br />

    <asp:GridView ID="GridView1" runat="server" Visible="false"></asp:GridView>

    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />


</asp:Content>


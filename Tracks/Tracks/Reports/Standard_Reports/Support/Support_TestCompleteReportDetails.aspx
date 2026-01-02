<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Support_TestCompleteReportDetails.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_Support_Support_TestCompleteReportDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">


    <asp:Panel ID="pnlContents" runat="server">

        <h3>Test Complete Report</h3>

        <asp:DetailsView ID="dvTestCompleteReport" runat="server" DataKeyNames="TEST_COMPLETE_REPORTS_ID"  >

            <AlternatingRowStyle BackColor="#CCCCCC" />

        </asp:DetailsView>


    </asp:Panel>



    <asp:Button ID="btnEdit" runat="server" Text="Edit" OnClick="btnEdit_Click" />
    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClick="btnPrint_Click" />    

        <!-- maybe put master index details here for reference -->

</asp:Content>


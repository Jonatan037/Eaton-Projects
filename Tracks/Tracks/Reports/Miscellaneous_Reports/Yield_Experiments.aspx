<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Yield_Experiments.aspx.cs" Inherits="Tracks_Reports_Yield_Experiments" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Yields</h2>

    <asp:Panel ID="pnlSetup" runat="server" DefaultButton="btnFind">

        <asp:Label ID="Label3" runat="server" Text="Calculate yields where plant is "></asp:Label>

        <asp:DropDownList ID="ddlPlant" runat="server">
            <asp:ListItem>RPO</asp:ListItem>
        </asp:DropDownList>

        <br />
        <asp:Label ID="Label4" runat="server" Text="and"></asp:Label>
        <br />
        <asp:Label ID="Label1" runat="server" Text="date range between: "></asp:Label>

        <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox>
        <asp:Label ID="Label2" runat="server" Text=" and "></asp:Label>
        <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>
        <br /><br />
        
        <asp:CheckBox ID="cbCategory" runat="server" Text="Include Category" />
        <br /><br />
        
        <asp:Button ID="btnFind" runat="server" Text="Shows Yields" OnClick="btnFind_Click"/>
        <asp:Label ID="Label5" runat="server" Text="  OR  "></asp:Label>
        <asp:Button ID="btnDownload" runat="server" Text="Download Raw Data" OnClick="btnDownload_Click" />

    </asp:Panel>

    <br />
    <br />

    <!-- ----------------------------------------------------------------------------------------------------------- -->

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false" Caption="" OnDataBound="GridView1_DataBound" CellPadding="5" ShowHeaderWhenEmpty="True">

        <AlternatingRowStyle BackColor="#CCCCCC" />
        
        <Columns>
 
            <asp:BoundField DataField="PLANT" HeaderText="Plant"/>
            <asp:BoundField DataField="FAMILY" HeaderText="Family" />
            <asp:BoundField DataField="CATEGORY" HeaderText="Category" />

            <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="Black" HeaderStyle-BackColor="Black" />

            <asp:BoundField DataField="QDMS_TESTED" HeaderText="Tested" />
            <asp:BoundField DataField="QDMS_PASSED" HeaderText="Passed" />
            <asp:BoundField DataField="QDMS_FAILED" HeaderText="Failed" />
            <asp:BoundField DataField="QDMS_FPY" HeaderText="FPY" />

            <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="Black" HeaderStyle-BackColor="Black" />

            <asp:BoundField DataField="TRACKS_TESTED" HeaderText="Tested" />
            <asp:BoundField DataField="TRACKS_PASSED" HeaderText="Passed" />
            <asp:BoundField DataField="TRACKS_FAILED" HeaderText="Failed" />
            <asp:BoundField DataField="TRACKS_FPY" HeaderText="FPY" />

            <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="Black" HeaderStyle-BackColor="Black" />            

            <asp:BoundField DataField="ISSUE_COUNT" HeaderText="Count" />
            <asp:BoundField DataField="ISSUES_PER_UNIT" HeaderText="IPU" />

        </Columns>

    </asp:GridView>

    <!-- ----------------------------------------------------------------------------------------------------------- -->
    <br />
    <br />




    <!-- ----------------------------------------------------------------------------------------------------------- -->

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />




</asp:Content>


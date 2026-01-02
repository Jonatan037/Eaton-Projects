<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Yields.aspx.cs" Inherits="Tracks_Reports_Yields" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>
        <span style="background-color:lightgreen;">TRACKS</span>
         Issues Per Unit (IPU)
    </h2>

    <asp:Panel ID="pnlSetup" runat="server" DefaultButton="btnFind">

            <asp:Label ID="Label3" runat="server" Text="Calculate IPU where plant is "></asp:Label>
            <asp:DropDownList ID="ddlPlant" runat="server">
                <asp:ListItem >ALL</asp:ListItem>
                <asp:ListItem >CPO</asp:ListItem>
                <asp:ListItem Selected="True">YPO</asp:ListItem>
            </asp:DropDownList>

            <asp:Label ID="Label1" runat="server" Text=" and date range between "></asp:Label>

            <asp:TextBox ID="txtStartDate"  runat="server" Width = "80"></asp:TextBox>
            <asp:Label ID="Label2" runat="server" Text=" and "></asp:Label>
            <asp:TextBox ID="txtEndDate" runat="server" Width = "80"></asp:TextBox>
            <asp:Button ID="btnResetDates" runat="server" Text="Reset" OnClick="btnResetDates_Click" ToolTip="Reset Dates" />
            <br />
            <asp:CheckBox ID="cbQDMS" runat="server" Text="Include QDMS" BackColor="LightBlue" Visible=" false" />
            <br />
            <asp:CheckBox ID="cbCategory" runat="server" Text="Include Category" Checked="true" />
            <br />
            <asp:CheckBox ID="cbFailureAnalysis" runat="server" Text="Include Failure Analysis" Visible=" true" />
            <br />
            <br /><br />
        
            <asp:Button ID="btnFind" runat="server" Text="Show IPU" OnClick="btnFind_Click"/>
            <asp:Label ID="Label5" runat="server" Text="  or  "></asp:Label>
            <asp:Button ID="btnDownload" runat="server" Text="Download Raw Data" OnClick="btnDownload_Click" />
        
    </asp:Panel>


    <!-- ----------------------------------------------------------------------------------------------------------- -->
    <br />
           
    <asp:GridView 
        ID="gvYields" runat="server" 
        AutoGenerateColumns="false" 
        CellPadding="5" 
        ShowHeaderWhenEmpty="True" 
        DataKeyNames="PLANT, FAMILY, CATEGORY"
        OnRowCommand="gvYields_RowCommand" 
        HeaderStyle-BackColor="LightGreen"
     >

    <AlternatingRowStyle BackColor="#CCCCCC" />
        
    <SelectedRowStyle BackColor="Yellow" />

    <Columns>

        <asp:ButtonField  DataTextField="PLANT"  HeaderText="Plant" CommandName="Issues_Plant" />
        <asp:ButtonField  DataTextField="FAMILY" HeaderText="Family" CommandName="Issues_Family" />
        <asp:ButtonField  DataTextField="CATEGORY" HeaderText="Category" CommandName="Issues_Category" />

        <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="LightBlue" HeaderStyle-BackColor="LightBlue" />
        <asp:ButtonField  DataTextField="QDMS_TESTED" HeaderText="Tested" CommandName="History" ItemStyle-HorizontalAlign="Center" HeaderStyle-BackColor="LightBlue" />
        <asp:BoundField DataField="QDMS_PASSED" HeaderText="Passed" ItemStyle-HorizontalAlign="Center" HeaderStyle-BackColor="LightBlue"  />
        <asp:BoundField DataField="QDMS_FAILED" HeaderText="Failed" ItemStyle-HorizontalAlign="Center" HeaderStyle-BackColor="LightBlue"  />
        <asp:BoundField DataField="QDMS_FPY" HeaderText="FPY" ItemStyle-HorizontalAlign="Center" HeaderStyle-BackColor="LightBlue" />

        <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="LightBlue" HeaderStyle-BackColor="LightBlue" />
        <asp:ButtonField  DataTextField="TRACKS_TESTED" HeaderText="Tested" CommandName="History" />
        <asp:BoundField DataField="TRACKS_PASSED" HeaderText="Passed" ItemStyle-HorizontalAlign="Center" />
        <asp:BoundField DataField="TRACKS_FAILED" HeaderText="Failed" ItemStyle-HorizontalAlign="Center" />
        <asp:BoundField DataField="TRACKS_FPY" HeaderText="Test Yields" ItemStyle-HorizontalAlign="Center" />
  
        <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="LightGreen"/>
        <asp:ButtonField  DataTextField="Component" HeaderText="Component" CommandName="Issues_NC_Component" ItemStyle-HorizontalAlign="Center" />
        <asp:ButtonField  DataTextField="Workmanship" HeaderText="Workmanship" CommandName="Issues_NC_Workmanship" ItemStyle-HorizontalAlign="Center" />
        <asp:ButtonField  DataTextField="Test" HeaderText="Test" CommandName="Issues_NC_Test" ItemStyle-HorizontalAlign="Center" />
        <asp:ButtonField  DataTextField="Design" HeaderText="Design" CommandName="Issues_NC_Design" ItemStyle-HorizontalAlign="Center" />
        <asp:ButtonField  DataTextField="Other" HeaderText="Other" CommandName="Issues_NC_Other" ItemStyle-HorizontalAlign="Center" />
        <asp:ButtonField  DataTextField="Undetermined" HeaderText="Undetermined" CommandName="Issues_NC_Undetermined" ItemStyle-HorizontalAlign="Center" />
        <asp:ButtonField  DataTextField="Troubleshooting" HeaderText="Troubleshooting" CommandName="Issues_NC_Troubleshooting" ItemStyle-HorizontalAlign="Center" />

        <asp:BoundField DataField="" HeaderText=""  ItemStyle-BackColor="LightGreen"/>
        <asp:ButtonField  DataTextField="ISSUE_COUNT" HeaderText="Total" CommandName="Issues_NC_Total" ItemStyle-HorizontalAlign="Center" />
        <asp:BoundField DataField="ISSUES_PER_UNIT" HeaderText="IPU" ItemStyle-HorizontalAlign="Center" />

    </Columns>

</asp:GridView>



    <!-- ----------------------------------------------------------------------------------------------------------- -->
    <br />

    <asp:HyperLink ID="lnkIssues" runat="server" BackColor="Yellow"></asp:HyperLink>
    <asp:GridView 
        ID="gvIssues" 
        runat="server" 
        CellPadding="5" 
        AutoGenerateColumns="false" 
        HeaderStyle-BackColor="LightGreen" 
        OnRowCommand="gvIssues_RowCommand"
        DataKeyNames="SERIAL_NUMBER" 
    >

        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>
            
            <asp:ButtonField  DataTextField="SERIAL_NUMBER"  HeaderText="SerialNumber" CommandName="ShowReport" />
  
            <asp:BoundField DataField="PART_NUMBER" HeaderText="PartNumber" />
            <asp:BoundField DataField="ISSUE_DATE" HeaderText="Date" />
            <asp:BoundField DataField="PROBLEM_DESCRIPTION" HeaderText="ProblemDescription" />
            <asp:BoundField DataField="NOTES" HeaderText="Notes" />
            <asp:BoundField DataField="NONCONFORMANCE_CODE" HeaderText="NC_Code" />
            <asp:BoundField DataField="NC_CATEGORY" HeaderText="NC_Category" />
            <asp:BoundField DataField="STATION_TYPE" HeaderText="StationType" />
            <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="E#" />
             
        </Columns>

    </asp:GridView>

    <!-- ----------------------------------------------------------------------------------------------------------- -->
    <br />
    <asp:HyperLink ID="lnkHistory" runat="server" BackColor="Yellow"></asp:HyperLink>
    <asp:GridView 
        ID="gvHistory" 
        runat="server" 
        CellPadding="5" 
        AutoGenerateColumns="false" 
        HeaderStyle-BackColor="LightGreen" 
        OnRowCommand="gvHistory_RowCommand"
        DataKeyNames="SerialNumber, DBID, IndexID, ResultsID, RecordType"
    >
        
        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>
            
            <asp:ButtonField  DataTextField="SerialNumber"  HeaderText="SerialNumber" CommandName="ShowReport" />
            <asp:BoundField DataField="Date" HeaderText="Date" />
            <asp:BoundField DataField="Source" HeaderText="Source" />
            <asp:BoundField DataField="Plant" HeaderText="Plant" />
            <asp:BoundField DataField="Family" HeaderText="Family" />
            <asp:BoundField DataField="Category" HeaderText="Category" />
            <asp:BoundField DataField="PartNumber" HeaderText="PartNumber" />
            <asp:BoundField DataField="Status" HeaderText="Status" />
            <asp:BoundField DataField="RecordType" HeaderText="RecordType" />
            <asp:BoundField DataField="Note" HeaderText="Note" />
            <asp:BoundField DataField="DBID" HeaderText="DBID" />
            <asp:BoundField DataField="IndexID" HeaderText="IndexID" />
            <asp:BoundField DataField="ResultsID" HeaderText="ResultsID" />
                   

        </Columns>


    </asp:GridView>



    <!-- ----------------------------------------------------------------------------------------------------------- -->

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />




</asp:Content>


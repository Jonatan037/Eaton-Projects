<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Support_Yields_Test_Report_TDM.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_Support_Support_Yields_Test_Report" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Test Report</h2>

    <asp:DetailsView ID="dvReportHeader" runat="server" FieldHeaderStyle-Font-Bold="true" AutoGenerateRows="False" DataKeyNames="TestRunId" DataSourceID="SqlDataSource_dvReportHeader">

        <AlternatingRowStyle BackColor="#CCCCCC" />

        <FieldHeaderStyle Font-Bold="True"></FieldHeaderStyle>
        <Fields>
            <asp:BoundField DataField="TestRunId" HeaderText="TestRunId" ReadOnly="True" SortExpression="TestRunId" />
            <asp:BoundField DataField="FacilityId" HeaderText="FacilityId" SortExpression="FacilityId" />
            <asp:BoundField DataField="LineName" HeaderText="LineName" SortExpression="LineName" />
            <asp:BoundField DataField="WorkstationName" HeaderText="WorkstationName" SortExpression="WorkstationName" />
            <asp:BoundField DataField="ParentStationName" HeaderText="ParentStationName" ReadOnly="True" SortExpression="ParentStationName" />
            <asp:BoundField DataField="ModelNumber" HeaderText="ModelNumber" SortExpression="ModelNumber" />
            <asp:BoundField DataField="SerialNumber" HeaderText="SerialNumber" SortExpression="SerialNumber" />
            <asp:BoundField DataField="ShiftName" HeaderText="ShiftName" SortExpression="ShiftName" />
            <asp:BoundField DataField="OperatorName" HeaderText="OperatorName" SortExpression="OperatorName" />
            <asp:BoundField DataField="Passed" HeaderText="Passed" ReadOnly="True" SortExpression="Passed" />
            <asp:BoundField DataField="StartTime" HeaderText="StartTime" SortExpression="StartTime" />
            <asp:BoundField DataField="StartDate" HeaderText="StartDate" ReadOnly="True" SortExpression="StartDate" />
            <asp:BoundField DataField="TestRunSpan" HeaderText="TestRunSpan" SortExpression="TestRunSpan" />
            <asp:BoundField DataField="TestRunTypeID" HeaderText="TestRunTypeID" SortExpression="TestRunTypeID" />
            <asp:BoundField DataField="TestRunType" HeaderText="TestRunType" ReadOnly="True" SortExpression="TestRunType" />
        </Fields>
    </asp:DetailsView>

    <br />

    <asp:GridView ID="gvReportBody" runat="server" AutoGenerateColumns="false" DataSourceID="SqlDataSource_gvReportBody">

        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>

            <asp:BoundField DataField="InstructionName" HeaderText="InstructionName" SortExpression="InstructionName" />
            <asp:BoundField DataField="UpperLimit" HeaderText="UpperLimit" SortExpression="UpperLimit" />
            <asp:BoundField DataField="Results" HeaderText="Results" ReadOnly="True" SortExpression="Results" />
            <asp:BoundField DataField="LowerLimit" HeaderText="LowerLimit" SortExpression="LowerLimit" />
            <asp:BoundField DataField="Status" HeaderText="Status" SortExpression="Status" />
            <asp:BoundField DataField="TestComments" HeaderText="TestComments" SortExpression="TestComments" />

        </Columns>

    </asp:GridView>



    <asp:SqlDataSource ID="SqlDataSource_dvReportHeader" runat="server" ConnectionString="<%$ ConnectionStrings:TDMEnterpriseConnectionString %>" SelectCommand="SELECT * FROM [vw_PCaT_TestResultRun_DataDog] WHERE ([TestRunId] = @TestRunId)">
        <SelectParameters>
            <asp:QueryStringParameter DefaultValue="0" Name="TestRunId" QueryStringField="REPORT_RESULTS_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>

    <br /><br />



    <asp:SqlDataSource ID="SqlDataSource_gvReportBody" runat="server" 
        ConnectionString="<%$ ConnectionStrings:TDMEnterpriseConnectionString %>" 
        SelectCommand="SELECT * FROM [vw_TDM_TEST_RESULTS] WHERE ([TestRunId] = @TestRunId)">
        <SelectParameters>
            <asp:QueryStringParameter DefaultValue="0" Name="TestRunId" QueryStringField="REPORT_RESULTS_ID" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>

    </asp:Content>


<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="xx.aspx.cs" Inherits="Tracks_Reports_xx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="TestRunId" DataSourceID="SqlDataSource1" OnRowCommand="GridView1_RowCommand">
        
        <AlternatingRowStyle BackColor="#CCCCCC" />
        <SelectedRowStyle BackColor="Yellow" />
        
        <Columns>


                <asp:TemplateField ShowHeader="true">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbSelect" runat="server" CausesValidation="False" CommandName="Select" Text="Select"  CommandArgument='<%# Container.DataItemIndex%>' />
                        <br />
                        <asp:LinkButton ID="lbDetails" runat="server" CausesValidation="False" CommandName="Details" Text="Details" CommandArgument='<%# Container.DataItemIndex%>' />

                    </ItemTemplate>

                </asp:TemplateField>

            <asp:BoundField DataField="TestRunId" HeaderText="TestRunId" SortExpression="TestRunId" />
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


        </Columns>

</asp:GridView>


<asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:TDMEnterpriseConnectionString %>" 
    SelectCommand="SELECT TOP 200 * FROM [vw_PCaT_TestResultRun_DataDog] ORDER BY StartTime Desc"></asp:SqlDataSource>


</asp:Content>


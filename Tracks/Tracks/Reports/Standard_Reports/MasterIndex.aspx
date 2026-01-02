<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="MasterIndex.aspx.cs" Inherits="NCRs_Standard_Reports_MasterIndex" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">



    <h1>Get Master Index Details</h1>

    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">

        <asp:Label ID="Label1" runat="server" Text="Date range between "></asp:Label>
        <br />
        <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox>
        <asp:Label ID="Label2" runat="server" Text=" and "></asp:Label>
        <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>
        <asp:Button ID="btnFind" runat="server" Text="Find" OnClick="btnFind_Click" />

    </asp:Panel>

    <br />
    <asp:GridView ID="gvMasterIndex" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="MASTER_INDEX_ID" OnPageIndexChanging="gvMasterIndex_PageIndexChanging1" OnSorting="gvMasterIndex_Sorting" PageSize="100">
       
        <AlternatingRowStyle BackColor="#CCCCCC" />
        <Columns>
            <asp:BoundField DataField="MASTER_INDEX_ID" HeaderText="MASTER_INDEX_ID" InsertVisible="False" ReadOnly="True" SortExpression="MASTER_INDEX_ID" />
            <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" SortExpression="SERIAL_NUMBER" />
            <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" SortExpression="PART_NUMBER" />
            <asp:BoundField DataField="PRODUCTION_ORDER_NUMBER" HeaderText="PRODUCTION_ORDER_NUMBER" SortExpression="PRODUCTION_ORDER_NUMBER" />
            <asp:BoundField DataField="SALES_ORDER_NUMBER" HeaderText="SALES_ORDER_NUMBER" SortExpression="SALES_ORDER_NUMBER" />
            <asp:BoundField DataField="PLANT" HeaderText="PLANT" SortExpression="PLANT" />
            <asp:BoundField DataField="FAMILY" HeaderText="FAMILY" SortExpression="FAMILY" />
            <asp:BoundField DataField="CATEGORY" HeaderText="CATEGORY" SortExpression="CATEGORY" />
            <asp:BoundField DataField="SUBCATEGORY" HeaderText="SUBCATEGORY" SortExpression="SUBCATEGORY" />
            <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" SortExpression="DESCRIPTION" />
            <asp:BoundField DataField="MATERIAL_TYPE" HeaderText="MATERIAL_TYPE" SortExpression="MATERIAL_TYPE" />
            <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
            <asp:BoundField DataField="CROSS_REFERENCE" HeaderText="CROSS_REFERENCE" SortExpression="CROSS_REFERENCE" />
            <asp:CheckBoxField DataField="INCLUDE_IN_FPY" HeaderText="INCLUDE_IN_FPY" SortExpression="INCLUDE_IN_FPY" />
            <asp:BoundField DataField="COST" HeaderText="COST" SortExpression="COST" />
            <asp:CheckBoxField DataField="LOCKED" HeaderText="LOCKED" SortExpression="LOCKED" />
            <asp:CheckBoxField DataField="HAS_TEST_COMPLETE_REPORT" HeaderText="HAS_TEST_COMPLETE_REPORT" SortExpression="HAS_TEST_COMPLETE_REPORT" />
            <asp:CheckBoxField DataField="HAS_ISSUE_REPORT" HeaderText="HAS_ISSUE_REPORT" SortExpression="HAS_ISSUE_REPORT" />
            <asp:CheckBoxField DataField="HAS_ATE_FAILURE_REPORT" HeaderText="HAS_ATE_FAILURE_REPORT" SortExpression="HAS_ATE_FAILURE_REPORT" />
            <asp:CheckBoxField DataField="FAILED" HeaderText="FAILED" SortExpression="FAILED" />
            <asp:BoundField DataField="FIRST_DATE" HeaderText="FIRST_DATE" SortExpression="FIRST_DATE" />
            <asp:BoundField DataField="FIRST_DATE_NOTE" HeaderText="FIRST_DATE_NOTE" SortExpression="FIRST_DATE_NOTE" />
        </Columns>
    </asp:GridView>

    <br />
    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />
            

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />


</asp:Content>


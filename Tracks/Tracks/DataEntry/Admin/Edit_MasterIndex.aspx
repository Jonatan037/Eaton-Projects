<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_MasterIndex.aspx.cs" Inherits="Tracks_DataEntry_Admin_Edit_MasterIndex" %>

<%@ Register Src="~/Tracks/DataEntry/UserControls/UserControl_MasterIndex_Seach_SerialNumber.ascx" TagPrefix="uc1" TagName="UserControl_MasterIndex_Seach_SerialNumber" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Edit Master Index Entry</h1>

    <uc1:usercontrol_masterindex_seach_serialnumber runat="server" id="ucSearch" />
    <br />
    <asp:Label ID="lblTitle" runat="server" Text=""></asp:Label>
    <br />
    <br />


    <asp:DetailsView ID="DetailsView1" runat="server"  AutoGenerateRows="False" DataKeyNames="MASTER_INDEX_ID" DataSourceID="SqlDataSource1" OnItemCreated="DetailsView1_ItemCreated">
       
        <AlternatingRowStyle BackColor="#CCCCCC" /> 
        
        <Fields>
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
            <asp:BoundField DataField="CROSS_REFERENCE" HeaderText="CROSS_REFERENCE" SortExpression="CROSS_REFERENCE" />
            <asp:CheckBoxField DataField="INCLUDE_IN_FPY" HeaderText="INCLUDE_IN_FPY" SortExpression="INCLUDE_IN_FPY" />
            <asp:BoundField DataField="COST" HeaderText="COST" SortExpression="COST" />
            <asp:CheckBoxField DataField="LOCKED" HeaderText="LOCKED" SortExpression="LOCKED" />
            <asp:CheckBoxField DataField="HAS_TEST_COMPLETE_REPORT" HeaderText="HAS_TEST_COMPLETE_REPORT" SortExpression="HAS_TEST_COMPLETE_REPORT" />
            <asp:CheckBoxField DataField="HAS_ISSUE_REPORT" HeaderText="HAS_ISSUE_REPORT" SortExpression="HAS_ISSUE_REPORT" />
            <asp:CheckBoxField DataField="HAS_ATE_FAILURE_REPORT" HeaderText="HAS_ATE_FAILURE_REPORT" SortExpression="HAS_ATE_FAILURE_REPORT" />
            <asp:CheckBoxField DataField="FAILED" HeaderText="FAILED" SortExpression="FAILED" />
            <asp:BoundField DataField="FIRST_TEST_DATE" HeaderText="FIRST_TEST_DATE" SortExpression="FIRST_TEST_DATE" />
            <asp:BoundField DataField="FIRST_TEST_DATE_NOTE" HeaderText="FIRST_TEST_DATE_NOTE" SortExpression="FIRST_TEST_DATE_NOTE" />
            <asp:BoundField DataField="RECORD_TYPE" HeaderText="RECORD_TYPE" SortExpression="RECORD_TYPE" />
            <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" />
            <asp:BoundField DataField="NOTEs" HeaderText="NOTEs" SortExpression="NOTEs" />
            <asp:CheckBoxField DataField="REQUIRES_ATE_RECORD" HeaderText="REQUIRES_ATE_RECORD" SortExpression="REQUIRES_ATE_RECORD" />
            <asp:CheckBoxField DataField="LAST_TEST_STATUS" HeaderText="LAST_TEST_STATUS" SortExpression="LAST_TEST_STATUS" />

            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />

        </Fields>


    </asp:DetailsView>

    <br />
    <br />
    <asp:Button ID="btnUpdateMetaData" runat="server" Text="Update MetaData" OnClick="btnUpdateMetaData_Click" />
    <br />
    MetaData includes:
    <br />
    PLANT, FAMILY, CATEGORY, SUBCATEGORY, DESCRIPTION, MATERIAL_TYPE, CROSS_REFERENCE, INCLUDE_IN_FPY, COST, REQUIRES_ATE_RECORD 
    <br />

    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" DeleteCommand="DELETE FROM [MASTER_INDEX] WHERE [MASTER_INDEX_ID] = @MASTER_INDEX_ID" InsertCommand="INSERT INTO [MASTER_INDEX] ([SERIAL_NUMBER], [PART_NUMBER], [PRODUCTION_ORDER_NUMBER], [SALES_ORDER_NUMBER], [PLANT], [FAMILY], [CATEGORY], [SUBCATEGORY], [DESCRIPTION], [MATERIAL_TYPE], [CROSS_REFERENCE], [INCLUDE_IN_FPY], [COST], [LOCKED], [HAS_TEST_COMPLETE_REPORT], [HAS_ISSUE_REPORT], [HAS_ATE_FAILURE_REPORT], [FAILED], [FIRST_TEST_DATE], [FIRST_TEST_DATE_NOTE], [RECORD_TYPE], [CREATION_TIMESTAMP], [NOTEs], [REQUIRES_ATE_RECORD], [LAST_TEST_STATUS]) VALUES (@SERIAL_NUMBER, @PART_NUMBER, @PRODUCTION_ORDER_NUMBER, @SALES_ORDER_NUMBER, @PLANT, @FAMILY, @CATEGORY, @SUBCATEGORY, @DESCRIPTION, @MATERIAL_TYPE, @CROSS_REFERENCE, @INCLUDE_IN_FPY, @COST, @LOCKED, @HAS_TEST_COMPLETE_REPORT, @HAS_ISSUE_REPORT, @HAS_ATE_FAILURE_REPORT, @FAILED, @FIRST_TEST_DATE, @FIRST_TEST_DATE_NOTE, @RECORD_TYPE, @CREATION_TIMESTAMP, @NOTEs, @REQUIRES_ATE_RECORD, @LAST_TEST_STATUS)" SelectCommand="SELECT * FROM [MASTER_INDEX] WHERE ([SERIAL_NUMBER] = @SERIAL_NUMBER)" UpdateCommand="UPDATE [MASTER_INDEX] SET [SERIAL_NUMBER] = @SERIAL_NUMBER, [PART_NUMBER] = @PART_NUMBER, [PRODUCTION_ORDER_NUMBER] = @PRODUCTION_ORDER_NUMBER, [SALES_ORDER_NUMBER] = @SALES_ORDER_NUMBER, [PLANT] = @PLANT, [FAMILY] = @FAMILY, [CATEGORY] = @CATEGORY, [SUBCATEGORY] = @SUBCATEGORY, [DESCRIPTION] = @DESCRIPTION, [MATERIAL_TYPE] = @MATERIAL_TYPE, [CROSS_REFERENCE] = @CROSS_REFERENCE, [INCLUDE_IN_FPY] = @INCLUDE_IN_FPY, [COST] = @COST, [LOCKED] = @LOCKED, [HAS_TEST_COMPLETE_REPORT] = @HAS_TEST_COMPLETE_REPORT, [HAS_ISSUE_REPORT] = @HAS_ISSUE_REPORT, [HAS_ATE_FAILURE_REPORT] = @HAS_ATE_FAILURE_REPORT, [FAILED] = @FAILED, [FIRST_TEST_DATE] = @FIRST_TEST_DATE, [FIRST_TEST_DATE_NOTE] = @FIRST_TEST_DATE_NOTE, [RECORD_TYPE] = @RECORD_TYPE, [CREATION_TIMESTAMP] = @CREATION_TIMESTAMP, [NOTEs] = @NOTEs, [REQUIRES_ATE_RECORD] = @REQUIRES_ATE_RECORD, [LAST_TEST_STATUS] = @LAST_TEST_STATUS WHERE [MASTER_INDEX_ID] = @MASTER_INDEX_ID">
        <DeleteParameters>
            <asp:Parameter Name="MASTER_INDEX_ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="SERIAL_NUMBER" Type="String" />
            <asp:Parameter Name="PART_NUMBER" Type="String" />
            <asp:Parameter Name="PRODUCTION_ORDER_NUMBER" Type="String" />
            <asp:Parameter Name="SALES_ORDER_NUMBER" Type="String" />
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
            <asp:Parameter Name="CATEGORY" Type="String" />
            <asp:Parameter Name="SUBCATEGORY" Type="String" />
            <asp:Parameter Name="DESCRIPTION" Type="String" />
            <asp:Parameter Name="MATERIAL_TYPE" Type="String" />
            <asp:Parameter Name="CROSS_REFERENCE" Type="String" />
            <asp:Parameter Name="INCLUDE_IN_FPY" Type="Boolean" />
            <asp:Parameter Name="COST" Type="Double" />
            <asp:Parameter Name="LOCKED" Type="Boolean" />
            <asp:Parameter Name="HAS_TEST_COMPLETE_REPORT" Type="Boolean" />
            <asp:Parameter Name="HAS_ISSUE_REPORT" Type="Boolean" />
            <asp:Parameter Name="HAS_ATE_FAILURE_REPORT" Type="Boolean" />
            <asp:Parameter Name="FAILED" Type="Boolean" />
            <asp:Parameter Name="FIRST_TEST_DATE" Type="DateTime" />
            <asp:Parameter Name="FIRST_TEST_DATE_NOTE" Type="String" />
            <asp:Parameter Name="RECORD_TYPE" Type="String" />
            <asp:Parameter Name="CREATION_TIMESTAMP" Type="DateTime" />
            <asp:Parameter Name="NOTEs" Type="String" />
            <asp:Parameter Name="REQUIRES_ATE_RECORD" Type="Boolean" />
            <asp:Parameter Name="LAST_TEST_STATUS" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="HiddenField1" DefaultValue="&quot;&quot;" Name="SERIAL_NUMBER" PropertyName="Value" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="SERIAL_NUMBER" Type="String" />
            <asp:Parameter Name="PART_NUMBER" Type="String" />
            <asp:Parameter Name="PRODUCTION_ORDER_NUMBER" Type="String" />
            <asp:Parameter Name="SALES_ORDER_NUMBER" Type="String" />
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
            <asp:Parameter Name="CATEGORY" Type="String" />
            <asp:Parameter Name="SUBCATEGORY" Type="String" />
            <asp:Parameter Name="DESCRIPTION" Type="String" />
            <asp:Parameter Name="MATERIAL_TYPE" Type="String" />
            <asp:Parameter Name="CROSS_REFERENCE" Type="String" />
            <asp:Parameter Name="INCLUDE_IN_FPY" Type="Boolean" />
            <asp:Parameter Name="COST" Type="Double" />
            <asp:Parameter Name="LOCKED" Type="Boolean" />
            <asp:Parameter Name="HAS_TEST_COMPLETE_REPORT" Type="Boolean" />
            <asp:Parameter Name="HAS_ISSUE_REPORT" Type="Boolean" />
            <asp:Parameter Name="HAS_ATE_FAILURE_REPORT" Type="Boolean" />
            <asp:Parameter Name="FAILED" Type="Boolean" />
            <asp:Parameter Name="FIRST_TEST_DATE" Type="DateTime" />
            <asp:Parameter Name="FIRST_TEST_DATE_NOTE" Type="String" />
            <asp:Parameter Name="RECORD_TYPE" Type="String" />
            <asp:Parameter Name="CREATION_TIMESTAMP" Type="DateTime" />
            <asp:Parameter Name="NOTEs" Type="String" />
            <asp:Parameter Name="REQUIRES_ATE_RECORD" Type="Boolean" />
            <asp:Parameter Name="LAST_TEST_STATUS" Type="Boolean" />
            <asp:Parameter Name="MASTER_INDEX_ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>


    <asp:HiddenField ID="HiddenField1" runat="server" />

</asp:Content>


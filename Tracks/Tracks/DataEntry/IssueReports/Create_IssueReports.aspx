<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Create_IssueReports.aspx.cs" Inherits="Tracks_Protected_IssueReports_Create" %>

<%@ Register Src="~/Tracks/DataEntry/UserControls/UserControl_MasterIndex_Seach_SerialNumber.ascx" TagPrefix="uc1" TagName="UserControl_MasterIndex_Seach_SerialNumber" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Manage Issue Report</h1>


    <uc1:usercontrol_masterindex_seach_serialnumber runat="server" id="ucSearch" />
    <br />
    <asp:Label ID="lblTitle" runat="server" Text="No serial number selected."></asp:Label>
    <br />
    <br />

    <asp:Panel ID="Panel3" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_pnlIssueReports" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlIssueReports" runat="server" />
        <asp:Panel ID="pnlIssueReports" runat="server">

            <asp:GridView ID="gvIssueReports" AutoGenerateColumns="false" runat="server" DataKeyNames="ISSUE_REPORTS_ID"  OnSelectedIndexChanged="OnSelectedIndexChanged" >


            <AlternatingRowStyle BackColor="#CCCCCC" />

            <Columns>

                <asp:TemplateField ShowHeader="False">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbEdit" runat="server" CausesValidation="False" CommandName="Select" Text="Edit"></asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="DATE" SortExpression="CREATION_TIMESTAMP" DataFormatString="{0:MM/dd/yyyy}"  />
                <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="E#" SortExpression="EMPLOYEE_ID" Visible="true" />
                <asp:BoundField DataField="NONCONFORMANCE_CODE" HeaderText="NC" SortExpression="NONCONFORMANCE_CODE" />
                <asp:BoundField DataField="PROBLEM_DESCRIPTION" HeaderText="PROBLEM_DESCRIPTION" SortExpression="PROBLEM_DESCRIPTION" />

                <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" InsertVisible="False" ReadOnly="True"  Visible="false"/>
                <asp:BoundField DataField="MASTER_INDEX_ID" HeaderText="MASTER_INDEX_ID" SortExpression="MASTER_INDEX_ID" Visible="false" />
                <asp:BoundField DataField="SUMMARY" HeaderText="SUMMARY" SortExpression="SUMMARY" Visible="False" />
                <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" Visible="False" />

                <asp:BoundField DataField="REWORK_INSTRUCTIONS" HeaderText="REWORK_INSTRUCTIONS" SortExpression="REWORK_INSTRUCTIONS" Visible="false" />
                <asp:BoundField DataField="STATION_TYPE" HeaderText="STATION_TYPE" SortExpression="STATION_TYPE" Visible="false" />
                <asp:CheckBoxField DataField="LOCKED" HeaderText="LOCKED" SortExpression="LOCKED" Visible="false" />
                <asp:BoundField DataField="KEY" HeaderText="KEY" SortExpression="KEY" Visible="false" />
                <asp:BoundField DataField="ROOT_CAUSE_CODE" HeaderText="ROOT_CAUSE_CODE" SortExpression="ROOT_CAUSE_CODE" Visible="false" />

            </Columns>

        </asp:GridView>
    
        <br />
        <asp:Button ID="btnNewIssueReport" runat="server" Text="Create New Issue Report" OnClick="btnNewIssueReport_Click" />
        <br />&nbsp;

        </asp:Panel>
    </asp:Panel>
    <br />



    <asp:Panel ID="Panel2" runat="server">

        <asp:Image ID="image_pnlMasterIndex" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlMasterIndex" runat="server" />



        <asp:Panel ID="pnlMasterIndex" runat="server">

            <asp:DetailsView ID="dvMasterIndex" AutoGenerateRows="false" runat="server" AllowPaging="true" DataKeyNames="MASTER_INDEX_ID"  >

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
                    <asp:BoundField DataField="FIRST_TEST_DATE" HeaderText="FIRST_TEST_DATE" SortExpression="FIRST_TEST_DATE" DataFormatString="{0:MM/dd/yyyy}" />
                    <asp:BoundField DataField="FIRST_TEST_DATE_NOTE" HeaderText="FIRST_TEST_DATE_NOTE" SortExpression="FIRST_TEST_DATE_NOTE" />
                    <asp:BoundField DataField="RECORD_TYPE" HeaderText="RECORD_TYPE" SortExpression="RECORD_TYPE" />
                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                </Fields>

                <PagerStyle Font-Size="X-Large" />

            </asp:DetailsView>

        </asp:Panel>

    </asp:Panel>
    <br />




    <asp:Label ID="lblDebug" runat="server" Text="" Visible="true"></asp:Label>
    <br />

    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpeMasterIndex" 
        runat="server" 
        TargetControlID="pnlMasterIndex" 
        CollapseControlID="image_pnlMasterIndex"
        ExpandControlID="image_pnlMasterIndex"
        TextLabelID="lbl_pnlMasterIndex"
        CollapsedText="Show Master Index Details" 
        ExpandedText="Hide Master Index Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlMasterIndex" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>
  

    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpeIssueReports" 
        runat="server" 
        TargetControlID="pnlIssueReports" 
        CollapseControlID="image_pnlIssueReports"
        ExpandControlID="image_pnlIssueReports"
        TextLabelID="lbl_pnlIssueReports"
        CollapsedText="Show Issue Report Details" 
        ExpandedText="Hide Issue Report Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlIssueReports">
    </ajaxToolkit:CollapsiblePanelExtender>
  



</asp:Content>




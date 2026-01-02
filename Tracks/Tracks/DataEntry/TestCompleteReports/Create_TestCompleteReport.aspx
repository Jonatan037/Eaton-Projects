<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Create_TestCompleteReport.aspx.cs" Inherits="Tracks_Protected_TestCompleteReports_Create" %>

<%@ Register Src="~/Tracks/DataEntry/UserControls/UserControl_MasterIndex_Seach_SerialNumber.ascx" TagPrefix="uc1" TagName="UserControl_MasterIndex_Seach_SerialNumber" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Manage Test Complete Report</h1>

    <uc1:usercontrol_masterindex_seach_serialnumber runat="server" id="ucSearch" />
    <br />
    <asp:Label ID="lblTitle" runat="server" Text="No serial number selected."></asp:Label>
    <br />
    <br />


    <asp:Panel ID="Panel3" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_pnlReports" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlReports" runat="server" />
        <asp:Panel ID="pnlReports" runat="server">

            <asp:GridView ID="gvReports" runat="server" AutoGenerateColumns="false"  DataKeyNames="TEST_COMPLETE_REPORTS_ID" OnSelectedIndexChanged="OnSelectedIndexChanged">

                <AlternatingRowStyle BackColor="#CCCCCC" />

                <Columns>

                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbEdit" runat="server" CausesValidation="False" CommandName="Select" Text="Edit"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="TEST_COMPLETE_REPORTS_ID" HeaderText="TEST_COMPLETE_REPORTS_ID" InsertVisible="False" ReadOnly="True"  Visible="false" />
                    <asp:BoundField DataField="MASTER_INDEX_ID" HeaderText="MASTER_INDEX_ID" SortExpression="MASTER_INDEX_ID" Visible="false" />
         
                    <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" SortExpression="SERIAL_NUMBER" />
                    <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" SortExpression="PART_NUMBER" />
                    <asp:BoundField DataField="PRODUCTION_ORDER_NUMBER" HeaderText="PRODUCTION_ORDER_NUMBER" SortExpression="PRODUCTION_ORDER_NUMBER" />
                    <asp:BoundField DataField="SALES_ORDER_NUMBER" HeaderText="SALES_ORDER_NUMBER" SortExpression="SALES_ORDER_NUMBER" />
                    <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID" SortExpression="EMPLOYEE_ID" />
                    
                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" />                  
                    <asp:CheckBoxField DataField="LOCKED" HeaderText="LOCKED" SortExpression="LOCKED" />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />



                </Columns>

            </asp:GridView>


        <br />
        <asp:Button ID="btnNewReport" runat="server" Text="Create New Report" OnClick="btnNewReport_Click" />
        <br />&nbsp;

        </asp:Panel>
    </asp:Panel>
    <br />



    <asp:Panel ID="Panel2" runat="server">

        <asp:Image ID="image_pnlMasterIndex" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlMasterIndex" runat="server" />



        <asp:Panel ID="pnlMasterIndex" runat="server">

            <asp:DetailsView ID="dvMasterIndex" AutoGenerateRows="true" runat="server" AllowPaging="true" DataKeyNames="MASTER_INDEX_ID"  >

                <AlternatingRowStyle BackColor="#CCCCCC" />


                <PagerStyle Font-Size="X-Large" />

            </asp:DetailsView>

        </asp:Panel>

    </asp:Panel>
    <br />




    <asp:Label ID="lblDebug" runat="server" Text="" Visible="true" Font-Size="X-Large"></asp:Label>
    <br />

    <asp:HyperLink ID="HyperLink1" runat="server" Target="_blank" >Show Test Records</asp:HyperLink>
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
        ID="cpeReports" 
        runat="server" 
        TargetControlID="pnlReports" 
        CollapseControlID="image_pnlReports"
        ExpandControlID="image_pnlReports"
        TextLabelID="lbl_pnlReports"
        CollapsedText="Show Report Details" 
        ExpandedText="Hide Report Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlReports">
    </ajaxToolkit:CollapsiblePanelExtender>
  



</asp:Content>






<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Search.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_Search" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Search</h1>

    <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
        
        <asp:Label ID="Label1" runat="server" Text="Enter part number, serial number, production order number, etc. "/>
        <br />
        <asp:TextBox ID="txtSearch" runat="server" Width="200px"></asp:TextBox>
        <asp:Button ID="btnSearch" runat="server" Text="Find" OnClick="btnSearch_Click" />

    </asp:Panel>
    <br />
    <asp:Label ID="lblTitle" runat="server" Text="No value selected."></asp:Label>
    <hr />





    <asp:Panel ID="Panel1" runat="server">

        <asp:Image ID="image_pnlMasterIndex" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlMasterIndex" runat="server" />

        <asp:Panel ID="pnlMasterIndex" runat="server">

            <asp:GridView ID="gvMasterIndex" runat="server" AllowPaging="True" DataKeyNames="MASTER_INDEX_ID" OnPageIndexChanging="gvMasterIndex_PageIndexChanging" AutoGenerateSelectButton="True" OnSelectedIndexChanged="gvMasterIndex_SelectedIndexChanged" PageSize="5">
        
                <AlternatingRowStyle BackColor="#CCCCCC" />
                <PagerStyle Font-Size="X-Large" />

                <RowStyle Wrap="False" />

                <SelectedRowStyle BackColor="Yellow" />

            </asp:GridView>
            <br />    
            <br />

        </asp:Panel>

    </asp:Panel>
    <br />


    <asp:Panel ID="Panel2" runat="server">

        <asp:Image ID="image_pnlIssueReports" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlIssueReports" runat="server" />
        <asp:Panel ID="pnlIssueReports" runat="server">

            <asp:GridView ID="gvIssueReports" AutoGenerateColumns="false" runat="server" DataKeyNames="ISSUE_REPORTS_ID" OnSelectedIndexChanged="gvIssueReports_SelectedIndexChanged">

                <AlternatingRowStyle BackColor="#CCCCCC" />
                <Columns>

                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbEdit" runat="server" CausesValidation="False" CommandName="Select" Text="View"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="DATE" SortExpression="CREATION_TIMESTAMP"  />                   
                    <asp:BoundField DataField="NONCONFORMANCE_CODE" HeaderText="NC CODE" SortExpression="NONCONFORMANCE_CODE" />    
                     
                    <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" InsertVisible="False" ReadOnly="True" SortExpression="ISSUE_REPORTS_ID" Visible="false" />
                    <asp:BoundField DataField="MASTER_INDEX_ID" HeaderText="MASTER_INDEX_ID" SortExpression="MASTER_INDEX_ID" Visible="false"  />
                    
                    <asp:BoundField DataField="SUMMARY" HeaderText="SUMMARY" SortExpression="SUMMARY" Visible="false"  />

                    <asp:BoundField DataField="PROBLEM_DESCRIPTION" HeaderText="PROBLEM_DESCRIPTION" SortExpression="PROBLEM_DESCRIPTION" HtmlEncode="false" />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" HtmlEncode="false" />
                    <asp:BoundField DataField="REWORK_INSTRUCTIONS" HeaderText="REWORK_INSTRUCTIONS" SortExpression="REWORK_INSTRUCTIONS" Visible="false" HtmlEncode="false"  />

                    <asp:BoundField DataField="STATION_TYPE" HeaderText="STATION_TYPE" SortExpression="STATION_TYPE" Visible="false"  />

                    <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID" SortExpression="EMPLOYEE_IDE" Visible="true"  />

                    <asp:CheckBoxField DataField="LOCKED" HeaderText="LOCKED" SortExpression="LOCKED" Visible="false"  />

                    <asp:BoundField DataField="KEY" HeaderText="KEY" SortExpression="KEY" Visible="false"  />                   
                    <asp:BoundField DataField="ROOT_CAUSE_CODE" HeaderText="ROOT_CAUSE_CODE" SortExpression="ROOT_CAUSE_CODE" Visible="false"  />   
                </Columns>

            </asp:GridView>

        </asp:Panel>
    </asp:Panel>
    <br />

    <asp:Panel ID="Panel6" runat="server">

        <asp:Image ID="image_pnlTestCompleteReports" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlTestCompleteReports" runat="server" />
        <asp:Panel ID="pnlTestCompleteReports" runat="server">

            <asp:GridView ID="gvTestCompleteReports" AutoGenerateColumns="false" runat="server" DataKeyNames="TEST_COMPLETE_REPORTS_ID" OnSelectedIndexChanged="gvTestCompleteReports_SelectedIndexChanged">

                <AlternatingRowStyle BackColor="#CCCCCC" />
                <Columns>

                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbEdit" runat="server" CausesValidation="False" CommandName="Select" Text="View"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="TEST_COMPLETE_REPORTS_ID" HeaderText="TEST_COMPLETE_REPORTS_ID" InsertVisible="False" ReadOnly="True" SortExpression="TEST_COMPLETE_REPORTS_ID" />
                    <asp:BoundField DataField="MASTER_INDEX_ID" HeaderText="MASTER_INDEX_ID" SortExpression="MASTER_INDEX_ID" />
                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" />
                    <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" SortExpression="SERIAL_NUMBER" />
                    <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" SortExpression="PART_NUMBER" />
                    <asp:BoundField DataField="PRODUCTION_ORDER_NUMBER" HeaderText="PRODUCTION_ORDER_NUMBER" SortExpression="PRODUCTION_ORDER_NUMBER" />
                    <asp:BoundField DataField="SALES_ORDER_NUMBER" HeaderText="SALES_ORDER_NUMBER" SortExpression="SALES_ORDER_NUMBER" />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                    <asp:CheckBoxField DataField="LOCKED" HeaderText="LOCKED" SortExpression="LOCKED" />
                    <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID" SortExpression="EMPLOYEE_ID" />  
                </Columns>

            </asp:GridView>
            
            <br />&nbsp;

        </asp:Panel>
    </asp:Panel>
    <br />


    <asp:Panel ID="Panel3" runat="server">

        <asp:Image ID="image_pnlAllComponents" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlAllComponents" runat="server" />
        <asp:Panel ID="pnlAllComponents" runat="server">


            <asp:GridView ID="gvAllComponents" AutoGenerateColumns="false" runat="server">

                <AlternatingRowStyle BackColor="#CCCCCC" />
                <Columns>

                    <asp:BoundField DataField="COMPONENTS_ID" HeaderText="COMPONENTS_ID" InsertVisible="False" ReadOnly="True" SortExpression="COMPONENTS_ID" Visible="false" />
                    <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" SortExpression="ISSUE_REPORTS_ID" Visible="false"  />
                    
                    <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" SortExpression="PART_NUMBER" />
                    <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" SortExpression="SERIAL_NUMBER" />
                    <asp:BoundField DataField="COST" HeaderText="COST" SortExpression="COST" />
                    <asp:BoundField DataField="REPLACEMENT_REASON_TYPE" HeaderText="REPLACEMENT_REASON_TYPE" SortExpression="REPLACEMENT_REASON_TYPE" />
                    
                    <asp:BoundField DataField="DISPOSITION_TYPE" HeaderText="DISPOSITION_TYPE" SortExpression="DISPOSITION_TYPE" />
                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" Visible="false"  />

                    <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" SortExpression="DESCRIPTION" Visible="true"  />
                    
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />

                </Columns>

            </asp:GridView>

        </asp:Panel>
    </asp:Panel>
    <br />

    <asp:Panel ID="Panel4" runat="server">

        <asp:Image ID="image_pnlLaborHours" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlLaborHours" runat="server" />
        <asp:Panel ID="pnlLaborHours" runat="server">

            <asp:GridView ID="gvLaborHours" AutoGenerateColumns="false" runat="server">

                <AlternatingRowStyle BackColor="#CCCCCC" />
                <Columns>
                    <asp:BoundField DataField="LABOR_HOURS_ID" HeaderText="LABOR_HOURS_ID" InsertVisible="False" ReadOnly="True" SortExpression="LABOR_HOURS_ID" Visible="false" />
                    <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" SortExpression="ISSUE_REPORTS_ID" Visible="false"  />
                    <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID" SortExpression="EMPLOYEE_ID" />

                    <asp:BoundField DataField="LABOR_HOURS" HeaderText="LABOR_HOURS" SortExpression="LABOR_HOURS" />
                    <asp:BoundField DataField="HOURLY_RATE" HeaderText="HOURLY_RATE" SortExpression="HOURLY_RATE" DataFormatString="{0:C2}" />
                    <asp:BoundField DataField="LABOR_COST" HeaderText="LABOR_COST" SortExpression="LABOR_COST" DataFormatString="{0:C2}"  />

                    <asp:BoundField DataField="LABOR_TYPE" HeaderText="LABOR_TYPE" SortExpression="LABOR_TYPE" />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                </Columns>

            </asp:GridView>

        </asp:Panel>

    </asp:Panel>
    <br />

    <asp:Panel ID="Panel7" runat="server">

        <asp:Image ID="image_FILES" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_FILES" runat="server" />
        
        <asp:Panel ID="pnl_FILES" runat="server">

            <asp:GridView ID="gvFiles" runat="server" AutoGenerateColumns="False" DataKeyNames="FILE_STORAGE_ID">
                
                <AlternatingRowStyle BackColor="#CCCCCC" />

                <Columns>

                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                           <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Select" Text="Edit"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:HyperLinkField  HeaderText="FILENAME" DataTextField="ORIGINAL_FILENAME" DataNavigateUrlFields="FILE_PATH" Target="_blank" />
                    <asp:ImageField HeaderText="PREVIEW"   ItemStyle-Width="50px" DataImageUrlField="FILE_PATH"  ControlStyle-Width="100" ControlStyle-Height = "100"   />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" HtmlEncode="false"  />

                    <asp:BoundField DataField="UPLOADED_TIMESTAMP" HeaderText="TIMESTAMP"   Visible="false"  />
                    <asp:BoundField DataField="FILE_STORAGE_ID" HeaderText="FILE_STORAGE_ID" InsertVisible="False" ReadOnly="True" Visible="false" />
                    <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" Visible="false"  />
                    <asp:CheckBoxField DataField="ARCHIVED" HeaderText="ARCHIVED"  Visible="false"  />
                    <asp:BoundField DataField="ORIGINAL_FILENAME" HeaderText="ORIGINAL_FILENAME"  Visible="false"  />
                    <asp:BoundField DataField="SAVED_AS_FILENAME" HeaderText="SAVED_AS_FILENAME"  Visible="false"  />


                </Columns>

            </asp:GridView>
            
        </asp:Panel>

    </asp:Panel>
    <br />

    <asp:Panel ID="Panel5" runat="server">

        <asp:Image ID="image_pnlCorrectiveActions" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_pnlCorrectiveActions" runat="server" />
        <asp:Panel ID="pnlCorrectiveActions" runat="server">

            <asp:GridView ID="gvCorrectiveActions" AutoGenerateColumns="false" runat="server">

                <AlternatingRowStyle BackColor="#CCCCCC" />
                <Columns>
                <asp:BoundField DataField="CORRECTIVE_ACTIONS_ID" HeaderText="CORRECTIVE_ACTIONS_ID" InsertVisible="False" ReadOnly="True" SortExpression="CORRECTIVE_ACTIONS_ID" />
                <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" SortExpression="ISSUE_REPORTS_ID" />
                <asp:BoundField DataField="ACTION_TYPE" HeaderText="ACTION_TYPE" SortExpression="ACTION_TYPE" />
                <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" Visible="false" />
            </Columns>

            </asp:GridView>

        </asp:Panel>

    </asp:Panel>
    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClick="btnPrint_Click" />



    <asp:Label ID="lblDebug" runat="server" Text="Put debug info here." Visible="false"></asp:Label>
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
        ImageControlID="image_pnlIssueReports"
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>
  
    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpeTestCompleteReports" 
        runat="server" 
        TargetControlID="pnlTestCompleteReports" 
        CollapseControlID="image_pnlTestCompleteReports"
        ExpandControlID="image_pnlTestCompleteReports"
        TextLabelID="lbl_pnlTestCompleteReports"
        CollapsedText="Show Test Complete Report Details" 
        ExpandedText="Hide Test Complete Report Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlTestCompleteReports"
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>


    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpeAllComponents" 
        runat="server" 
        TargetControlID="pnlAllComponents" 
        CollapseControlID="image_pnlAllComponents"
        ExpandControlID="image_pnlAllComponents"
        TextLabelID="lbl_pnlAllComponents"
        CollapsedText="Show Component Details" 
        ExpandedText="Hide Component Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlAllComponents"
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>
  

    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpeLaborHours" 
        runat="server" 
        TargetControlID="pnlLaborHours" 
        CollapseControlID="image_pnlLaborHours"
        ExpandControlID="image_pnlLaborHours"
        TextLabelID="lbl_pnlLaborHours"
        CollapsedText="Show Labor Hour Details" 
        ExpandedText="Hide Labor Hour Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlLaborHours"
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>
  
    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpeCorrectiveActions" 
        runat="server" 
        TargetControlID="pnlCorrectiveActions" 
        CollapseControlID="image_pnlCorrectiveActions"
        ExpandControlID="image_pnlCorrectiveActions"
        TextLabelID="lbl_pnlCorrectiveActions"
        CollapsedText="Show Corrective Action Details" 
        ExpandedText="Hide Corrective Action Details"
        CollapsedSize="0" 
        ScrollContents="True" 
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_pnlCorrectiveActions"
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>

    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_FILES" 
        runat="server" 
        TargetControlID="pnl_FILES" 
        CollapseControlID="image_FILES"
        ExpandControlID="image_FILES"
        TextLabelID="lbl_FILES"
        CollapsedText="Uploaded File Details" 
        ExpandedText="Uploaded File Details"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_FILES" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>
  
    <br />



</asp:Content>





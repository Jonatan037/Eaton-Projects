<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_IssueReports.aspx.cs" Inherits="Tracks_Protected_IssueReports_Edit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">


    <asp:Label ID="lblTitle" runat="server" Text="" Font-Size="X-Large" />
    <br />
 
    <asp:Panel ID="pnl_ComboBoxes" runat="server">
        <asp:Table ID="Table1" runat="server">

            <asp:TableRow>
                <asp:TableCell>NR Code</asp:TableCell>
                <asp:TableCell>Station Type</asp:TableCell>
                <asp:TableCell>Status</asp:TableCell>
            </asp:TableRow>

            <asp:TableRow>
                <asp:TableCell> <asp:DropDownList ID="ddl_NONCONFORMANCE_CODE" runat="server"></asp:DropDownList> &nbsp;&nbsp;&nbsp;&nbsp; </asp:TableCell>
                <asp:TableCell> <asp:DropDownList ID="ddl_STATION_TYPE" runat="server"></asp:DropDownList> &nbsp;&nbsp;&nbsp;&nbsp; </asp:TableCell>
                <asp:TableCell> <asp:DropDownList ID="ddl_STATUS" runat="server"></asp:DropDownList> &nbsp;&nbsp;&nbsp;&nbsp; </asp:TableCell>
            </asp:TableRow>

        </asp:Table>
    </asp:Panel>
    <br />

    <asp:Panel ID="PROBLEM_DESCRIPTION" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_PROBLEM_DESCRIPTION" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_PROBLEM_DESCRIPTION" runat="server" />
        
        <asp:Panel ID="pnl_PROBLEM_DESCRIPTION" runat="server">
            Provide a detailed description of symptoms:
            <br />
            <asp:TextBox ID="txt_PROBLEM_DESCRIPTION" runat="server" Width="90%" Height="100px" TextMode="MultiLine" ></asp:TextBox>
            <br />
            <asp:Button ID="btn_PROBLEM_DESCRIPTION" runat="server" Text="Append Timestamp" OnClick="btn_PROBLEM_DESCRIPTION_Click" />
            <br />&nbsp;
        </asp:Panel>
    </asp:Panel>
    <br />

    <asp:Panel ID="NOTES" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_NOTES" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_NOTES" runat="server" />
        
        <asp:Panel ID="pnl_NOTES" runat="server">


            <asp:Panel ID="pnl_NOTES_INSTRUCTIONS_UPM_LINE" runat="server" Visible="false">
                &nbsp;&nbsp;If you are going to request help, please provide the following information:
                <asp:BulletedList ID="BulletedList1" runat="server" BulletStyle="Numbered" >
                    <asp:ListItem >Upload a screenshot of meter screen.</asp:ListItem>
                    <asp:ListItem >Upload the history dump file.</asp:ListItem>
                    <asp:ListItem >Provide a detailed description of symptoms and the troubleshooting steps that you have already taken.</asp:ListItem>
                </asp:BulletedList>

            </asp:Panel>

            Enter troubleshooting notes here:
            <br />
            <asp:TextBox ID="txt_NOTES" runat="server" Width="90%" Height="100px" TextMode="MultiLine" ></asp:TextBox>
                        <br />
            <asp:Button ID="btn_NOTES_Click" runat="server" Text="Append Timestamp" OnClick="btn_NOTES_Click_Click" />
            <br />&nbsp;
        </asp:Panel>
    </asp:Panel>
    <br />


    <asp:Panel ID="REWORK_INSTRUCTIONS" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_REWORK_INSTRUCTIONS" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_REWORK_INSTRUCTIONS" runat="server" />
        
        <asp:Panel ID="pnl_REWORK_INSTRUCTIONS" runat="server">
            Enter the details of how the line should rework this unit:
            <br />
            <asp:TextBox ID="txt_REWORK_INSTRUCTIONS" runat="server" Width="90%" Height="100px" TextMode="MultiLine" ></asp:TextBox>
            <br />
            <asp:Button ID="btn_REWORK_INSTRUCTIONS" runat="server" Text="Append Timestamp" OnClick="btn_REWORK_INSTRUCTIONS_Click" />
            <asp:Button ID="btn_PRINT_REWORK_INSTRUCTIONS" runat="server" Text="Print Rework Instructions" OnClick="btn_PRINT_REWORK_INSTRUCTIONS_Click" />
            <br />&nbsp;
        </asp:Panel>
    </asp:Panel>
    <br />


    <asp:Panel ID="COMPONENTS" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_COMPONENTS" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_COMPONENTS" runat="server" />
        
        <asp:Panel ID="pnl_COMPONENTS" runat="server">

            <asp:GridView ID="gvComponents" AutoGenerateColumns="false" runat="server" DataKeyNames="COMPONENTS_ID" OnSelectedIndexChanged="gvComponents_SelectedIndexChanged">

                <AlternatingRowStyle BackColor="#CCCCCC" />

                <Columns>

                    <asp:TemplateField ShowHeader="False">
                       <ItemTemplate>
                            <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Select" Text="Edit"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="COMPONENTS_ID" HeaderText="COMPONENTS_ID" SortExpression="COMPONENTS_ID" Visible="false" />
                    <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" SortExpression="ISSUE_REPORTS_ID" Visible="false" />
                    <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" SortExpression="PART_NUMBER" />
                    <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER" SortExpression="SERIAL_NUMBER" />
                    <asp:BoundField DataField="COST" HeaderText="COST" SortExpression="COST" />
                    <asp:BoundField DataField="REPLACEMENT_REASON_TYPE" HeaderText="REPLACEMENT_REASON_TYPE" SortExpression="REPLACEMENT_REASON_TYPE" />
                    <asp:BoundField DataField="DISPOSITION_TYPE" HeaderText="DISPOSITION_TYPE" SortExpression="DISPOSITION_TYPE" />

                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" Visible="false" />
                    <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" SortExpression="DESCRIPTION" Visible="true" />

                </Columns>

            </asp:GridView>
            <br />
            <asp:Button ID="btnAddComponent" runat="server" Text="Add Component" OnClick="btnAddComponent_Click" />
            <br />&nbsp;

        </asp:Panel>
    </asp:Panel>
    <br />

    <asp:Panel ID="LABOR_HOURS" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_LABOR_HOURS" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_LABOR_HOURS" runat="server" />
        
        <asp:Panel ID="pnl_LABOR_HOURS" runat="server">

            <asp:GridView ID="gvLaborHours" runat="server" AutoGenerateColumns="False" DataKeyNames="LABOR_HOURS_ID" OnSelectedIndexChanged="gvLaborHours_SelectedIndexChanged">
                    
                <AlternatingRowStyle BackColor="#CCCCCC" />

                <Columns>

                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                           <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Select" Text="Edit"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="LABOR_HOURS_ID" HeaderText="LABOR_HOURS_ID" SortExpression="LABOR_HOURS_ID" />
                    <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" SortExpression="ISSUE_REPORTS_ID" />
                    <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID" SortExpression="EMPLOYEE_ID" />
                    <asp:BoundField DataField="LABOR_HOURS" HeaderText="LABOR_HOURS" SortExpression="LABOR_HOURS" />
                    <asp:BoundField DataField="LABOR_TYPE" HeaderText="LABOR_TYPE" SortExpression="LABOR_TYPE" />
                    <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                    <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" />

                </Columns>
                </asp:GridView>

            
            <br />
            <asp:Button ID="btnAddLaborHours" runat="server" Text="Add Labor Hours" OnClick="btnAddLaborHours_Click"  />
            <br />&nbsp;

        </asp:Panel>
    </asp:Panel>
    <br />


    <asp:Panel ID="FILES" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_FILES" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_FILES" runat="server" />
        
        <asp:Panel ID="pnl_FILES" runat="server">

            <asp:GridView ID="gvFiles" runat="server" AutoGenerateColumns="False" DataKeyNames="FILE_STORAGE_ID" OnSelectedIndexChanged="gvFiles_SelectedIndexChanged">
                
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
            
            <br />
            <asp:Button ID="btnAddFiles" runat="server" Text="Add Files" OnClick="btnAddFiles_Click" />
            <br />&nbsp;

        </asp:Panel>
    </asp:Panel>
    <br />

    <asp:Panel ID="pnlOptions" runat="server">
        <asp:Panel ID="QUALITY_DEPT_OPTIONS" runat="server" BackColor="SpringGreen" >

            <asp:Image ID="image_QUALITY_DEPT_OPTIONS" runat="server" ImageUrl="~/Images/collapse.jpg"/>
            <asp:Label ID="lbl_QUALITY_DEPT_OPTIONS" runat="server" />
        
            <asp:Panel ID="pnl_QUALITY_DEPT_OPTIONS" runat="server">
               
                <br />  
                <asp:CheckBox ID="cbClosed" runat="server" Text="Check to close this issue report" />
                
                <br />      
                <br />  
                Choose a root cause code:
                <br />
                <asp:DropDownList ID="ddl_ROOT_CAUSE_CODE" runat="server"></asp:DropDownList>
                <br />
     
                <br />  
                If this was a workmanship error, then complete the following items:
                <br />
                Assembly Station: <asp:DropDownList ID="ddl_ASSEMBLY_STATION" runat="server" Visible="true"></asp:DropDownList>&nbsp&nbsp&nbsp&nbsp&nbsp
                Builder: <asp:TextBox ID="txt_BUILDER" runat="server"  Width="300px"></asp:TextBox>&nbsp&nbsp&nbsp&nbsp&nbsp
                Verifier: <asp:TextBox ID="txt_VERIFIER" runat="server"  Width="300px"></asp:TextBox>
                <br />

                <br />            
                Enter the corrective action details here:
                <br />

                <asp:GridView ID="gvCorrectiveActions" runat="server" AutoGenerateColumns="False" DataKeyNames="CORRECTIVE_ACTIONS_ID"  OnSelectedIndexChanged="gvCorrectiveActions_SelectedIndexChanged">
                
                    <AlternatingRowStyle BackColor="#CCCCCC" />

                    <Columns>

                        <asp:TemplateField ShowHeader="False">
                            <ItemTemplate>
                               <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Select" Text="Edit"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>


                            <asp:BoundField DataField="CORRECTIVE_ACTIONS_ID" HeaderText="CORRECTIVE_ACTIONS_ID" InsertVisible="False" ReadOnly="True" visible="false" />
                            <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" SortExpression="ISSUE_REPORTS_ID" Visible="false" />
                            <asp:BoundField DataField="ACTION_TYPE" HeaderText="ACTION_TYPE" SortExpression="ACTION_TYPE" />
                            <asp:BoundField DataField="NOTES" HeaderText="NOTES" SortExpression="NOTES" />
                            <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="CREATION_TIMESTAMP" SortExpression="CREATION_TIMESTAMP" />
                        </Columns>
                    </asp:GridView>

                <br />
                <asp:Button ID="btnAddCorrectiveActions" runat="server" Text="Add Corrective Action"  OnClick="btnAddCorrectiveActions_Click"  />
                <br />&nbsp;

            </asp:Panel>
        </asp:Panel>
        <br />
    </asp:Panel>


    <asp:Panel ID="TEST_ENGINEERING_OPIONS" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_TEST_ENGINEERING_OPIONS" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_TEST_ENGINEERING_OPIONS" runat="server" />
        
        <asp:Panel ID="pnl_TEST_ENGINEERING_OPIONS" runat="server">
                <br />  
                <asp:CheckBox ID="cbLocked" runat="server" Text="Check to lock this issue report" />
                
            <br />

	   <br />&nbsp;
        </asp:Panel>
    </asp:Panel>
    <br />



    <asp:Panel ID="pnl_Buttons" runat="server">
        <asp:Button ID="btnPrint" runat="server" Text="Print" OnClick="btnPrint_Click" />
        <br />
        <br />
        <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
        <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this entry?');" OnClick="btnDelete_Click" />
    </asp:Panel>


    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_PROBLEM_DESCRIPTION" 
        runat="server" 
        TargetControlID="pnl_PROBLEM_DESCRIPTION" 
        CollapseControlID="image_PROBLEM_DESCRIPTION"
        ExpandControlID="image_PROBLEM_DESCRIPTION"
        TextLabelID="lbl_PROBLEM_DESCRIPTION"
        CollapsedText="Problem Description" 
        ExpandedText="Problem Description"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_PROBLEM_DESCRIPTION" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>
  
    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_NOTES" 
        runat="server" 
        TargetControlID="pnl_NOTES" 
        CollapseControlID="image_NOTES"
        ExpandControlID="image_NOTES"
        TextLabelID="lbl_NOTES"
        CollapsedText="Troubleshooting Notes" 
        ExpandedText="Troubleshooting Notes"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_NOTES" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>


    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_REWORK_INSTRUCTIONS" 
        runat="server" 
        TargetControlID="pnl_REWORK_INSTRUCTIONS" 
        CollapseControlID="image_REWORK_INSTRUCTIONS"
        ExpandControlID="image_REWORK_INSTRUCTIONS"
        TextLabelID="lbl_REWORK_INSTRUCTIONS"
        CollapsedText="Rework Instructions" 
        ExpandedText="Rework Instructions"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_REWORK_INSTRUCTIONS" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>


    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_COMPONENTS" 
        runat="server" 
        TargetControlID="pnl_COMPONENTS" 
        CollapseControlID="image_COMPONENTS"
        ExpandControlID="image_COMPONENTS"
        TextLabelID="lbl_COMPONENTS"
        CollapsedText="NCM Components Details" 
        ExpandedText="NCM Components Details"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_COMPONENTS" 
        Collapsed="true" >
    </ajaxToolkit:CollapsiblePanelExtender>

    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_LABOR_HOURS" 
        runat="server" 
        TargetControlID="pnl_LABOR_HOURS" 
        CollapseControlID="image_LABOR_HOURS"
        ExpandControlID="image_LABOR_HOURS"
        TextLabelID="lbl_LABOR_HOURS"
        CollapsedText="Labor Hours Details" 
        ExpandedText="Labor Hours Details"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_LABOR_HOURS" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>

   <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_QUALITY_DEPT_OPTIONS" 
        runat="server" 
        TargetControlID="pnl_QUALITY_DEPT_OPTIONS" 
        CollapseControlID="image_QUALITY_DEPT_OPTIONS"
        ExpandControlID="image_QUALITY_DEPT_OPTIONS"
        TextLabelID="lbl_QUALITY_DEPT_OPTIONS"
        CollapsedText="Quality Department Options" 
        ExpandedText="Quality Department Options"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_QUALITY_DEPT_OPTIONS" 
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


    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_TEST_ENGINEERING_OPIONS" 
        runat="server" 
        TargetControlID="pnl_TEST_ENGINEERING_OPIONS" 
        CollapseControlID="image_TEST_ENGINEERING_OPIONS"
        ExpandControlID="image_TEST_ENGINEERING_OPIONS"
        TextLabelID="lbl_TEST_ENGINEERING_OPIONS"
        CollapsedText="Test Engineering Options" 
        ExpandedText="Test Engineering Options"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_TEST_ENGINEERING_OPIONS" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>


    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>


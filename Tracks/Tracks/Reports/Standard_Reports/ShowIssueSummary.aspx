<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ShowIssueSummary.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_ShowIssuesByDateRange" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <script type = "text/javascript">
        function PrintPanel()
        {
            var panel = document.getElementById("<%=pnlContents.ClientID %>");
            var printWindow = window.open('', '', 'height=800,width=800');
            printWindow.document.write('<html><head><title></title>');
            printWindow.document.write('</head><body >');
            printWindow.document.write(panel.innerHTML);
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            setTimeout(function () { printWindow.print(); }, 500);
            printWindow.onfocus = function () { setTimeout(function () { printWindow.close(); }, 2000); }
            return false;
        }
    </script>


    <h2>Show Issue Report Summary </h2>

    <asp:RadioButtonList ID="rblType" runat="server">
        <asp:ListItem  Value=1>Show All Open Issues</asp:ListItem>
        <asp:ListItem  Value=3>Show Issues Without Root Cause Code</asp:ListItem>
        <asp:ListItem  Value=2 Selected="True">Show All Issues For Date Range  </asp:ListItem>
    </asp:RadioButtonList>


    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;From <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>   
            <br />
            <br />
            <asp:Button ID="btnFind" runat="server" Text="Show Issues" OnClick="btnFind_Click" />
            <br /><br />
    </asp:Panel>



      <asp:Panel ID="COLUMN_SELECTION" runat="server" BackColor="LightGoldenrodYellow">

        <asp:Image ID="image_Columns" runat="server" ImageUrl="~/Images/collapse.jpg"/>
        <asp:Label ID="lbl_Columns" runat="server" />
        
        <asp:Panel ID="pnlColumns" runat="server">

            <asp:CheckBoxList ID="cblColumns" runat="server">
                <asp:ListItem Value="1" Text="PLANT" Selected="True" />
                <asp:ListItem Value="2" Text="FAMILY" Selected="True" />
                <asp:ListItem Value="3" Text="CATEGORY" Selected="True" />
                <asp:ListItem Value="4" Text="SERIAL_NUMBER" Selected="True" />
                <asp:ListItem Value="5" Text="PART_NUMBER" Selected="True" />
                <asp:ListItem Value="6" Text="EMPLOYEE_ID" Selected="True" />
                <asp:ListItem Value="7" Text="STATION_TYPE" Selected="True" />
                <asp:ListItem Value="8" Text="NONCONFORMANCE_CODE" Selected="True" />
                <asp:ListItem Value="9" Text="NC_CATEGORY" Selected="True" />

                <asp:ListItem Value="10" Text="CLOSED" Selected="True" />
                <asp:ListItem Value="11" Text="ISSUE_DATE" Selected="True" />
                <asp:ListItem Value="12" Text="PROBLEM_DESCRIPTION" Selected="True" />
                <asp:ListItem Value="13" Text="NOTES" Selected="True" />
            </asp:CheckBoxList>

            <br />
            <asp:Button ID="btnUpdateColumnSelection" runat="server" Text="Update Column Selection" OnClick="btnUpdateColumnSelection_Click" />

        </asp:Panel>

    </asp:Panel>
  

    <asp:Panel ID="pnlContents" runat="server" >
        <asp:GridView   ID="gvIssues" runat="server" AutoGenerateColumns="false" DataKeyNames="SERIAL_NUMBER, ISSUE_REPORTS_ID" OnRowCommand="gvIssues_RowCommand" EmptyDataText="No data found" ShowHeaderWhenEmpty="True" OnRowDataBound="gvIssues_OnRowDataBound" OnRowDeleting="gvIssues_RowDeleting" >

            <AlternatingRowStyle BackColor="#CCCCCC" />
            <SelectedRowStyle BackColor="Yellow" />
                            
            <Columns>

                <asp:TemplateField ShowHeader="true">

                    <HeaderTemplate>
                       <asp:LinkButton ID="btnReset" runat="server" CausesValidation="False" Text="Reset" OnClick="btnReset_Click" ></asp:LinkButton>
                    </HeaderTemplate>

                    <ItemTemplate>
                        <asp:LinkButton ID="lbSelect" runat="server" CausesValidation="False" CommandName="Select" Text="Select"  CommandArgument='<%# Container.DataItemIndex%>'  />
                        <br />
                        <asp:LinkButton ID="lbView" runat="server" CausesValidation="False" CommandName="View" Text="View" CommandArgument='<%# Container.DataItemIndex%>' />
                        <br />
                        <asp:LinkButton ID="lbPrint" runat="server" CausesValidation="False" CommandName="Print" Text="Print" CommandArgument='<%# Container.DataItemIndex%>' />
                        <br />
                        <asp:LinkButton ID="lbEdit" runat="server" CausesValidation="False" CommandName="Edit" Text="Edit" CommandArgument='<%# Container.DataItemIndex%>' />
                        <br />
                        <asp:LinkButton ID="lbRecords" runat="server" CausesValidation="False" CommandName="Records" Text="History" CommandArgument='<%# Container.DataItemIndex%>' ToolTip="Find records for this serial number in the production database." />
                    
                        <% if (Roles.IsUserInRole("Administrators") == true)
                           { %>
                                    <asp:LinkButton ID="lbDelete" runat="server" CausesValidation="False" CommandName="Delete" Text="Delete" CommandArgument='<%# Container.DataItemIndex%>' OnClientClick="return confirm('Are you sure you want to delete this entry?');"  />
                        <% } %>                    

                    </ItemTemplate>

                </asp:TemplateField>


                <asp:TemplateField>
                    <HeaderTemplate>
                        PLANT
                        <asp:DropDownList ID="PLANT" runat="server"  OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged" AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("PLANT") %>
                    </ItemTemplate>
                </asp:TemplateField>


                <asp:TemplateField>
                    <HeaderTemplate>
                        FAMILY
                        <asp:DropDownList ID="FAMILY" runat="server"  OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged" AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("FAMILY") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        CATEGORY
                        <asp:DropDownList ID="CATEGORY" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"   AutoPostBack="true" AppendDataBoundItems="true">
                        </asp:DropDownList>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("CATEGORY") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        SERIAL_NUMBER
                        <asp:DropDownList ID="SERIAL_NUMBER" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"   AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("SERIAL_NUMBER") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        PART_NUMBER
                        <asp:DropDownList ID="PART_NUMBER" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"    AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("PART_NUMBER") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        EMPLOYEE_ID
                        <asp:DropDownList ID="EMPLOYEE_ID" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"    AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("EMPLOYEE_ID") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        STATION_TYPE
                        <asp:DropDownList ID="STATION_TYPE" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"    AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("STATION_TYPE") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        NONCONFORMANCE_CODE
                        <asp:DropDownList ID="NONCONFORMANCE_CODE" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"    AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("NONCONFORMANCE_CODE") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        NC_CATEGORY
                        <asp:DropDownList ID="NC_CATEGORY" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"    AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("NC_CATEGORY") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField>
                    <HeaderTemplate>
                        CLOSED
                        <asp:DropDownList ID="CLOSED" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"    AutoPostBack="true" AppendDataBoundItems="true" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%# Eval("CLOSED") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="ISSUE_DATE" HeaderText="ISSUE_DATE" SortExpression="ISSUE_DATE" />

                <asp:BoundField DataField="PROBLEM_DESCRIPTION"  HeaderText=PROBLEM_DESCRIPTION HtmlEncode="false" />

                <asp:BoundField DataField="NOTES" HeaderText="NOTES"  HtmlEncode="false"  />

                <asp:BoundField DataField="ASSEMBLY_STATION" HeaderText="ASSEMBLY_STATION" />

                <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" Visible="false" />

            </Columns>



        </asp:GridView>
    </asp:Panel>

    <br />
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClientClick = "return PrintPanel();" />    
    <asp:Button ID="btnDownload" runat="server" Text="Download to Excel" OnClick="btnDownload_Click" ToolTip="Download all of the data in this report to Excel." />
            
    <br />


    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />

    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>


    <ajaxToolkit:CollapsiblePanelExtender 
        ID="cpe_Columns" 
        runat="server" 
        TargetControlID="pnlColumns" 
        CollapseControlID="image_Columns"
        ExpandControlID="image_Columns"
        TextLabelID="lbl_Columns"
        CollapsedText="Show Column Selection Panel" 
        ExpandedText="Hide Column Selection Panel"
        CollapsedSize="0" 
        ScrollContents="false"
        SuppressPostBack="True" 
        ExpandedImage="~/Images/collapse.jpg"  
        CollapsedImage="~/Images/expand.jpg" 
        ImageControlID="image_Columns" 
        Collapsed="true">
    </ajaxToolkit:CollapsiblePanelExtender>



</asp:Content>


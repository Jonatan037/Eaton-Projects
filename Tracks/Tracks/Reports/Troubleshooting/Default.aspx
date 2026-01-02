<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Tracks_Troubleshooting_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">
    
    <h2>Search issue reports for problem descriptions, employee ids, part numbers, serial numbers ... </h2>
    <asp:TextBox ID="txtSearchCriteria" runat="server"></asp:TextBox>
    <asp:Button ID="btnFind" runat="server" Text="Search" />
    <br />
    <br />

    <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource1" AllowPaging="False" AutoGenerateColumns="True" ShowHeaderWhenEmpty="True" EmptyDataText="No data found">
        <AlternatingRowStyle BackColor="#CCCCCC" />
        <SelectedRowStyle BackColor="Yellow" />

        <Columns>
            <asp:TemplateField ShowHeader="false">

                <ItemTemplate>
                <asp:LinkButton ID="lbSelect" runat="server" CausesValidation="False" CommandName="Select" Text="Select"  CommandArgument='<%# Container.DataItemIndex%>' />
                </ItemTemplate>

            </asp:TemplateField>
        </Columns>

    </asp:GridView>


    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" 
        SelectCommand = 
        "SELECT 
           [MASTER_INDEX].SERIAL_NUMBER,
           [MASTER_INDEX].PART_NUMBER,
           [MASTER_INDEX].FAMILY,
           [ISSUE_REPORTS].EMPLOYEE_ID AS [E#], 
           Format([ISSUE_REPORTS].CREATION_TIMESTAMP, 'MM/dd/yyyy') AS [DATE], 
           [ISSUE_REPORTS].PROBLEM_DESCRIPTION, 
           [ISSUE_REPORTS].NOTES
        FROM [MASTER_INDEX] INNER JOIN [ISSUE_REPORTS] ON [MASTER_INDEX].MASTER_INDEX_ID = [ISSUE_REPORTS].MASTER_INDEX_ID
        WHERE 
           ([ISSUE_REPORTS].[PROBLEM_DESCRIPTION] LIKE '%' + @SEARCH_CRITERIA + '%') 
           OR ( [MASTER_INDEX].PART_NUMBER LIKE '%' + @SEARCH_CRITERIA + '%') 
           OR ( [MASTER_INDEX].FAMILY LIKE '%' + @SEARCH_CRITERIA + '%') 
           OR ( [ISSUE_REPORTS].EMPLOYEE_ID LIKE '%' + @SEARCH_CRITERIA + '%') 
           OR ( [ISSUE_REPORTS].NOTES LIKE '%' + @SEARCH_CRITERIA + '%') 
        ORDER BY [ISSUE_REPORTS].[CREATION_TIMESTAMP] DESC"        
  
    >



        <SelectParameters>
            <asp:ControlParameter ControlID="txtSearchCriteria" DefaultValue="xxxxXXXXXXXXX" Name="SEARCH_CRITERIA" PropertyName="Text" Type="String" />
        </SelectParameters>

    </asp:SqlDataSource>



    </asp:Content>


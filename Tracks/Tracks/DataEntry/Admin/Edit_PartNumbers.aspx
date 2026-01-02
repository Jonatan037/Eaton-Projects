<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_PartNumbers.aspx.cs" Inherits="Tracks_DataEntry_Admin_Edit_PartNumbers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Manage Part Numbers</h1>

    <asp:Panel ID="Panel1" runat="server" DefaultButton="btnFind">
        <asp:Label ID="Label1" runat="server" Text="Part number begins with: "></asp:Label>
        <asp:TextBox ID="txtPartNumber" runat="server"></asp:TextBox>
        <asp:Button ID="btnFind" runat="server" Text="Find" OnClick="btnFind_Click" />
    </asp:Panel>
    <br />

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="PART_NUMBER" DataSourceID="SqlDataSource1">
        
        
       <AlternatingRowStyle BackColor="#CCCCCC" />
         
        <Columns>

            <asp:TemplateField ShowHeader="False">


                <EditItemTemplate>
                    <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="True" CommandName="Update" Text="Update"></asp:LinkButton>
                    &nbsp;<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel"></asp:LinkButton>
                </EditItemTemplate>


                <ItemTemplate>
                    <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Edit" Text="Edit"></asp:LinkButton>
                    &nbsp;
                    <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Delete" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this entry?');"></asp:LinkButton>
                </ItemTemplate>


            </asp:TemplateField>
            
            <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" ReadOnly="True" SortExpression="PART_NUMBER" />
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
            <asp:CheckBoxField DataField="REQUIRES_ATE_RECORD" HeaderText="REQUIRES_ATE_RECORD" SortExpression="REQUIRES_ATE_RECORD" />
        </Columns>
    </asp:GridView>


    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" 
        DeleteCommand="DELETE FROM [PART_NUMBERS] WHERE [PART_NUMBER] = @PART_NUMBER" 
        InsertCommand="INSERT INTO [PART_NUMBERS] ([PART_NUMBER], [PLANT], [FAMILY], [CATEGORY], [SUBCATEGORY], [DESCRIPTION], [MATERIAL_TYPE], [NOTES], [CROSS_REFERENCE], [INCLUDE_IN_FPY], [COST], [REQUIRES_ATE_RECORD]) VALUES (@PART_NUMBER, @PLANT, @FAMILY, @CATEGORY, @SUBCATEGORY, @DESCRIPTION, @MATERIAL_TYPE, @NOTES, @CROSS_REFERENCE, @INCLUDE_IN_FPY, @COST, @REQUIRES_ATE_RECORD)" 
        SelectCommand="SELECT * FROM [PART_NUMBERS] WHERE ([PART_NUMBER] LIKE @PART_NUMBER + '%') ORDER BY [PART_NUMBER]" 
        UpdateCommand="UPDATE [PART_NUMBERS] SET [PLANT] = @PLANT, [FAMILY] = @FAMILY, [CATEGORY] = @CATEGORY, [SUBCATEGORY] = @SUBCATEGORY, [DESCRIPTION] = @DESCRIPTION, [MATERIAL_TYPE] = @MATERIAL_TYPE, [NOTES] = @NOTES, [CROSS_REFERENCE] = @CROSS_REFERENCE, [INCLUDE_IN_FPY] = @INCLUDE_IN_FPY, [COST] = @COST, [REQUIRES_ATE_RECORD] = @REQUIRES_ATE_RECORD WHERE [PART_NUMBER] = @PART_NUMBER">
        <DeleteParameters>
            <asp:Parameter Name="PART_NUMBER" Type="String" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="PART_NUMBER" Type="String" />
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
            <asp:Parameter Name="CATEGORY" Type="String" />
            <asp:Parameter Name="SUBCATEGORY" Type="String" />
            <asp:Parameter Name="DESCRIPTION" Type="String" />
            <asp:Parameter Name="MATERIAL_TYPE" Type="String" />
            <asp:Parameter Name="NOTES" Type="String" />
            <asp:Parameter Name="CROSS_REFERENCE" Type="String" />
            <asp:Parameter Name="INCLUDE_IN_FPY" Type="Boolean" />
            <asp:Parameter Name="COST" Type="Double" />
            <asp:Parameter Name="REQUIRES_ATE_RECORD" Type="Boolean" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="txtPartNumber" Name="PART_NUMBER" PropertyName="Text" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
            <asp:Parameter Name="CATEGORY" Type="String" />
            <asp:Parameter Name="SUBCATEGORY" Type="String" />
            <asp:Parameter Name="DESCRIPTION" Type="String" />
            <asp:Parameter Name="MATERIAL_TYPE" Type="String" />
            <asp:Parameter Name="NOTES" Type="String" />
            <asp:Parameter Name="CROSS_REFERENCE" Type="String" />
            <asp:Parameter Name="INCLUDE_IN_FPY" Type="Boolean" />
            <asp:Parameter Name="COST" Type="Double" />
            <asp:Parameter Name="REQUIRES_ATE_RECORD" Type="Boolean" />
            <asp:Parameter Name="PART_NUMBER" Type="String" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <br />
    <br />
    <asp:Button ID="btnAdd" runat="server" Text="Add New Part Number" OnClick="btnAdd_Click" />
    <asp:TextBox ID="txtNewPartNumber" runat="server"></asp:TextBox>
    
    <br />
    <br />
    <asp:Button ID="btnDownload" runat="server" Text="Download All Part Numbers" OnClick="btnDownload_Click" />


</asp:Content>


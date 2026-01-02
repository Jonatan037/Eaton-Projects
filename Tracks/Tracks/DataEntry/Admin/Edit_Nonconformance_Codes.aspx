<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_Nonconformance_Codes.aspx.cs" Inherits="Tracks_DataEntry_Admin_Edit_Nonconformance_Codes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Manage Nonconformance Codes</h1>

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="ID" DataSourceID="SqlDataSource1">

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


            <asp:CheckBoxField DataField="ACTIVE" HeaderText="ACTIVE" SortExpression="ACTIVE" />
            <asp:BoundField DataField="ID" HeaderText="ID" InsertVisible="False" ReadOnly="True" SortExpression="ID" />
            <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION" SortExpression="DESCRIPTION" />
            <asp:BoundField DataField="CATEGORY" HeaderText="CATEGORY" SortExpression="CATEGORY" />
            <asp:BoundField DataField="OLD_NC_CODE" HeaderText="OLD_NC_CODE" SortExpression="OLD_NC_CODE" />

        </Columns>



    </asp:GridView>



    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" DeleteCommand="DELETE FROM [ISSUE_REPORTS_CT_NONCONFORMANCE_CODE] WHERE [ID] = @ID" InsertCommand="INSERT INTO [ISSUE_REPORTS_CT_NONCONFORMANCE_CODE] ([ACTIVE], [DESCRIPTION], [CATEGORY], [OLD_NC_CODE]) VALUES (@ACTIVE, @DESCRIPTION, @CATEGORY, @OLD_NC_CODE)" SelectCommand="SELECT * FROM [ISSUE_REPORTS_CT_NONCONFORMANCE_CODE] ORDER BY [DESCRIPTION]" UpdateCommand="UPDATE [ISSUE_REPORTS_CT_NONCONFORMANCE_CODE] SET [ACTIVE] = @ACTIVE, [DESCRIPTION] = @DESCRIPTION, [CATEGORY] = @CATEGORY, [OLD_NC_CODE] = @OLD_NC_CODE WHERE [ID] = @ID">
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="ACTIVE" Type="Boolean" />
            <asp:Parameter Name="DESCRIPTION" Type="String" />
            <asp:Parameter Name="CATEGORY" Type="String" />
            <asp:Parameter Name="OLD_NC_CODE" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="ACTIVE" Type="Boolean" />
            <asp:Parameter Name="DESCRIPTION" Type="String" />
            <asp:Parameter Name="CATEGORY" Type="String" />
            <asp:Parameter Name="OLD_NC_CODE" Type="String" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>



</asp:Content>


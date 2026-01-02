<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_FPY_Goals.aspx.cs" Inherits="Tracks_DataEntry_Admin_Edit_FPY_Goals" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="PLANT,FAMILY" DataSourceID="SqlDataSource1">

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

            <asp:BoundField DataField="PLANT" HeaderText="PLANT" ReadOnly="True" SortExpression="PLANT" />
            <asp:BoundField DataField="FAMILY" HeaderText="FAMILY" ReadOnly="True" SortExpression="FAMILY" />
            <asp:BoundField DataField="GOAL" HeaderText="GOAL" SortExpression="GOAL" />
        </Columns>
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" DeleteCommand="DELETE FROM [FPY_GOALS] WHERE [PLANT] = @PLANT AND [FAMILY] = @FAMILY" InsertCommand="INSERT INTO [FPY_GOALS] ([PLANT], [FAMILY], [GOAL]) VALUES (@PLANT, @FAMILY, @GOAL)" SelectCommand="SELECT * FROM [FPY_GOALS]" UpdateCommand="UPDATE [FPY_GOALS] SET [GOAL] = @GOAL WHERE [PLANT] = @PLANT AND [FAMILY] = @FAMILY">
        <DeleteParameters>
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
            <asp:Parameter Name="GOAL" Type="Double" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="GOAL" Type="Double" />
            <asp:Parameter Name="PLANT" Type="String" />
            <asp:Parameter Name="FAMILY" Type="String" />
        </UpdateParameters>
    </asp:SqlDataSource>

</asp:Content>



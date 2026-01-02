<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_Corrective_Action_Types.aspx.cs" Inherits="Tracks_Reports_Quality_Engineers_Edit_Assembly_Station_Names" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Manage Corrective Action Types</h2>
    <br />
    <asp:Label ID="Label1" runat="server" Text="New Action Type: "></asp:Label>
    <br />
    <asp:TextBox ID="txtNewName" runat="server" Width="400px" MaxLength="100"></asp:TextBox>
    <asp:Button ID="btnAddNewName" runat="server" Text="Insert" OnClick="btnAddNewName_Click" CausesValidation="true" />&nbsp;

    <br /><br />

    <asp:GridView ID="gvCorrectiveActionTypes" runat="server" AutoGenerateColumns="False" DataKeyNames="ID" DataSourceID="SqlDataSource1" CellPadding="5" >

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


            <asp:BoundField DataField="ID" HeaderText="ID" InsertVisible="False" ReadOnly="True" SortExpression="ID" Visible="false" />

            <asp:BoundField DataField="ACTION_TYPE" HeaderText="CORRECTION_ACTION_TYPE" >
                <ControlStyle Width=" 120%" />
                <ItemStyle Width ="400px" />
            </asp:BoundField >

        </Columns>
    </asp:GridView>

    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>


    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" 
        DeleteCommand="DELETE FROM [CORRECTIVE_ACTIONS_CT_ACTION_TYPES] WHERE [ID] = @ID" 
        SelectCommand="SELECT * FROM [CORRECTIVE_ACTIONS_CT_ACTION_TYPES] ORDER BY [ACTION_TYPE]" 
        UpdateCommand="UPDATE [CORRECTIVE_ACTIONS_CT_ACTION_TYPES] SET [ACTION_TYPE] = @ACTION_TYPE WHERE [ID] = @ID">

        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>


        <UpdateParameters>
            <asp:Parameter Name="STATION_NAME" Type="String" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>

    </asp:SqlDataSource>
</asp:Content>


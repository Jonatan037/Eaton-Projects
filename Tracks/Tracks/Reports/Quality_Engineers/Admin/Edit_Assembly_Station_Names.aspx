<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_Assembly_Station_Names.aspx.cs" Inherits="Tracks_Reports_Quality_Engineers_Edit_Assembly_Station_Names" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Manage Assembly Station Names</h2>
    <br />
    <asp:Label ID="Label1" runat="server" Text="New Station Name: "></asp:Label>
    <br />
    <asp:TextBox ID="txtNewName" runat="server" Width="400px" MaxLength="100"></asp:TextBox>
    <asp:Button ID="btnAddNewName" runat="server" Text="Insert" OnClick="btnAddNewName_Click" CausesValidation="true" />&nbsp;

    <br /><br />

    <asp:GridView ID="gvStationNames" runat="server" AutoGenerateColumns="False" DataKeyNames="ID" DataSourceID="SqlDataSource1" CellPadding="5" >

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

            <asp:BoundField DataField="STATION_NAME" HeaderText="STATION_NAME" SortExpression="STATION_NAME" >
                <ControlStyle Width=" 120%" />
                <ItemStyle Width ="400px" />
            </asp:BoundField >

        </Columns>
    </asp:GridView>

    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>


    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" 
        DeleteCommand="DELETE FROM [ISSUE_REPORTS_CT_ASSEMBLY_STATION_NAMES] WHERE [ID] = @ID" 
        SelectCommand="SELECT * FROM [ISSUE_REPORTS_CT_ASSEMBLY_STATION_NAMES] ORDER BY [STATION_NAME]" 
        UpdateCommand="UPDATE [ISSUE_REPORTS_CT_ASSEMBLY_STATION_NAMES] SET [STATION_NAME] = @STATION_NAME WHERE [ID] = @ID">

        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>


        <UpdateParameters>
            <asp:Parameter Name="STATION_NAME" Type="String" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>

    </asp:SqlDataSource>
</asp:Content>


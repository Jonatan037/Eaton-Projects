<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PCaT_Where_Used.aspx.cs" Inherits="Tracks_Reports_TDM_Where_Used" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">


    <h2>PCaT Component Where Used Report</h2>


    <asp:Label ID="Label1" runat="server" Text="Enter component search criteria: "></asp:Label>
    <asp:TextBox ID="TextBox1" runat="server" Height="16px" Width="300px"></asp:TextBox>
    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"  />
    <br />
    <br />
    <asp:Label ID="Label2" runat="server" Text="Examples: 710-F0138-11-6970929500Y21121, 710-F0138-11-6"></asp:Label>
    <br /><br />



    <!-- Comment Syntax Example. -->

    <asp:GridView ID="GridView1" runat="server"  
        AutoGenerateColumns="true" 
        OnRowCommand="GridView1_RowCommand"  
        EmptyDataText="No data found for the specified search criteria." 
        HeaderStyle-BackColor="LightGreen" 
        DataKeyNames="SerialNumber, TestRunId, DBID" 
        CellPadding="5">
        
        <AlternatingRowStyle BackColor="#CCCCCC" />


        <Columns>

            <asp:TemplateField>

                <ItemTemplate>

                    <asp:LinkButton ID="History" runat="server" CausesValidation="False" CommandName="History" Text="History" CommandArgument='<%# Container.DataItemIndex%>' ToolTip="Show the device history." />
                    <br />
                    <asp:LinkButton ID="Record" runat="server" CausesValidation="False" CommandName="Record" Text="Record" CommandArgument='<%# Container.DataItemIndex%>' ToolTip="Show the test record details for this entry.." />
                    <br />

                </ItemTemplate>

            </asp:TemplateField> 



        </Columns>

    </asp:GridView>
    <br />
    <br />

    <asp:Label ID="lblSQL" runat="server" Text=""></asp:Label>

</asp:Content>


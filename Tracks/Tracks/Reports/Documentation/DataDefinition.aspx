<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="DataDefinition.aspx.cs" Inherits="Tracks_Documentation_DataDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>TRACKS Database Documentation</h2>


    <asp:GridView ID="gvTables" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" Caption="Table Definitions">

        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>
            <asp:BoundField DataField="schema_name" HeaderText="schema_name" ReadOnly="True" SortExpression="schema_name" Visible="false" />
            <asp:BoundField DataField="table_name" HeaderText="table_name" SortExpression="table_name" />
            <asp:BoundField DataField="column_name" HeaderText="column_name" SortExpression="column_name" />
            <asp:BoundField DataField="data_type" HeaderText="data_type" SortExpression="data_type" Visible="false" />
            <asp:BoundField DataField="data_type_ext" HeaderText="data_type_ext" ReadOnly="True" SortExpression="data_type_ext" />
            <asp:BoundField DataField="nullable" HeaderText="nullable" ReadOnly="True" SortExpression="nullable" Visible="false" />
            <asp:BoundField DataField="default_value" HeaderText="default_value" ReadOnly="True" SortExpression="default_value" />
            <asp:BoundField DataField="primary_key" HeaderText="primary_key" ReadOnly="True" SortExpression="primary_key" />
            <asp:BoundField DataField="foreign_key" HeaderText="foreign_key" ReadOnly="True" SortExpression="foreign_key" />
            <asp:BoundField DataField="unique_key" HeaderText="unique_key" ReadOnly="True" SortExpression="unique_key" Visible="false" />
            <asp:BoundField DataField="check_contraint" HeaderText="check_contraint" ReadOnly="True" SortExpression="check_contraint" Visible="false" />
            <asp:BoundField DataField="comments" HeaderText="comments" ReadOnly="True" />
        </Columns>



    </asp:GridView>
    <br /><br />
    



    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:NCRConnectionString %>" 
        SelectCommand="SELECT * FROM [View_Documentation_Tables] WHERE table_name NOT IN ( 'sysdiagrams', 'FPY_GOALS', 'EMPLOYEES' ) ORDER BY table_name, column_name"></asp:SqlDataSource>


</asp:Content>


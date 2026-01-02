<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Device_History.aspx.cs" Inherits="Tracks_Reports_DeviceHistory_Device_History" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>Show Device History</h2>

    <asp:Label ID="Label1" runat="server" Text="Enter serial number: "></asp:Label>
    <asp:TextBox ID="txtCriteria" runat="server"></asp:TextBox>
    <asp:Button ID="btnFind" runat="server" Text="Find" OnClick="btnFind_Click" />


    <br /><br />
    
    <asp:GridView 
        ID="gvHistory" 
        runat="server"
        Font-Name="Segoe UI"
        Font-Size="Small"
        CellPadding="5" 
        AutoGenerateColumns="false" 
        OnRowCommand="gvHistory_RowCommand"
        DataKeyNames="SerialNumber, DBID, IndexID, ResultsID, RecordType"
        EmptyDataText="Minimum of 5 characters required for serial number."
        HeaderStyle-BackColor="#003366"
        HeaderStyle-ForeColor="White"
        HeaderStyle-Font-Bold="True"
        GridLines="Both"
        BorderStyle="Solid"
        BorderWidth="1px">

        
        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>
            
            <asp:ButtonField  DataTextField="SerialNumber"  HeaderText="SerialNumber" CommandName="ShowReport" />
            <asp:BoundField DataField="Date" HeaderText="Date" />
            <asp:BoundField DataField="Source" HeaderText="Source" />
            <asp:BoundField DataField="Plant" HeaderText="Plant" />
            <asp:BoundField DataField="Family" HeaderText="Family" />
            <asp:BoundField DataField="Category" HeaderText="Category" />
            <asp:BoundField DataField="PartNumber" HeaderText="PartNumber" />
            <asp:BoundField DataField="Status" HeaderText="Status" />
            <asp:BoundField DataField="RecordType" HeaderText="RecordType" />

            <asp:BoundField DataField="DBID" HeaderText="DBID" Visible ="false" />
            <asp:BoundField DataField="IndexID" HeaderText="IndexID" Visible ="false" />
            <asp:BoundField DataField="ResultsID" HeaderText="ResultsID" Visible ="false" />

            <asp:BoundField DataField="ParentStation" HeaderText="ParentStation" />
            <asp:BoundField DataField="ChildStation" HeaderText="ChildStation" Visible="false" />

            <asp:BoundField DataField="Note" HeaderText="TestSequenceName" />                   

        </Columns>


    </asp:GridView>


</asp:Content>


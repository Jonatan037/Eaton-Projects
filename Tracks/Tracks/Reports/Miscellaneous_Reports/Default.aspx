<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Tracks_Reports_Miscellaneous_Reports_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Miscellaneous Reports</h1>
    <br />

    <asp:TreeView  ID="TreeView1"  runat="server" DataSourceID="SiteMapDataSource1"  ShowExpandCollapse="true" ExpandDepth="-1" />   

    <asp:SiteMapDataSource ID="SiteMapDataSource1" runat="server" ShowStartingNode="true" StartFromCurrentNode="true"   /> 

</asp:Content>


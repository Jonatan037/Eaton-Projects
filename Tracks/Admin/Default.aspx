<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Admin_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Site Admin</h1>
    <h3>Select from the options shown below:</h3>

    <asp:TreeView  ID="TreeView1"  runat="server" DataSourceID="SiteMapDataSource1"  ShowExpandCollapse="true" ExpandDepth="-1" />   

    <asp:SiteMapDataSource ID="SiteMapDataSource1" runat="server" ShowStartingNode="false" StartFromCurrentNode="true"   /> 

</asp:Content>


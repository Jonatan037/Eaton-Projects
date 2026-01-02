<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Tracks_Protected_Default" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Data Entry</h1>
    <h3>Select from the options shown below:</h3>

    <asp:TreeView  ID="TreeView1"  runat="server" DataSourceID="SiteMapDataSource1"  ShowExpandCollapse="true" ExpandDepth="-1" />   

    <asp:SiteMapDataSource ID="SiteMapDataSource1" runat="server" ShowStartingNode="false" StartFromCurrentNode="true"   /> 

</asp:Content>




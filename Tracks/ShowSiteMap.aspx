<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ShowSiteMap.aspx.cs" Inherits="ShowSiteMap" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:TreeView  ID="TreeView1"  runat="server" DataSourceID="SiteMapDataSource1"  ShowExpandCollapse="true" ExpandDepth="-1" />   

    <asp:SiteMapDataSource ID="SiteMapDataSource1" runat="server" ShowStartingNode="true" StartFromCurrentNode="false"   /> 


</asp:Content>


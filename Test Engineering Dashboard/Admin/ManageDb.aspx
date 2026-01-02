<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageDb.aspx.cs" Inherits="TED_Admin_ManageDb" %>
<%@ Register Src="~/Admin/Controls/AdminHeader.ascx" TagPrefix="uc1" TagName="AdminHeader" %>
<%@ Register Src="~/Admin/Controls/AdminSidebar.ascx" TagPrefix="uc2" TagName="AdminSidebar" %>
<asp:Content ID="TitleC" ContentPlaceHolderID="TitleContent" runat="server">Admin Portal - Manage DB</asp:Content>
<asp:Content ID="HeadC" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    /* Rely on shared Admin shell from AdminSidebar control */
    .admin-container { background:rgba(25,29,37,.46); border:1px solid rgba(255,255,255,.08); border-radius:16px; box-shadow:0 16px 34px -12px rgba(0,0,0,.6), 0 0 0 1px rgba(255,255,255,.05); backdrop-filter:blur(24px) saturate(140%); padding:16px; height:100%; min-height:0; overflow:auto; }
    html.theme-light .admin-container, html[data-theme='light'] .admin-container { background:#ffffff; border:1px solid rgba(0,0,0,.08); box-shadow:0 16px 34px -12px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.05); }
  </style>
</asp:Content>
<asp:Content ID="MainC" ContentPlaceHolderID="MainContent" runat="server">
  <div class="admin-grid">
    <uc2:AdminSidebar ID="AdminSidebar1" runat="server" />
    <div>
      <uc1:AdminHeader ID="AdminHeader1" runat="server" />
      <div class="admin-container">
        <p>Database management stub goes here. We will add whitelisted tables and CRUD later.</p>
      </div>
    </div>
  </div>
</asp:Content>

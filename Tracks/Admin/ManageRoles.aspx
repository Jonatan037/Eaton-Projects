<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageRoles.aspx.cs" Inherits="Admin_ManageRoles" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <b>Create a New Role: </b>
    <asp:TextBox ID="RoleName" runat="server"></asp:TextBox>
    <br />
    <asp:Button ID="CreateRoleButton" runat="server" Text="Create Role" OnClick="CreateRoleButton_Click" />


    
    <asp:GridView ID="RoleList" runat="server"></asp:GridView>



</asp:Content>


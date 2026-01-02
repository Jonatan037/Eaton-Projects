<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default2.aspx.cs" Inherits="Admin_Default2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:GridView ID="gridUsers" runat="server"  AutoGenerateColumns="false" DataKeyNames="UserName" >


        <Columns>
            <asp:BoundField DataField="UserName" HeaderText="User Name" />
            <asp:BoundField DataField="Email" HeaderText="Email" />
            <asp:commandfield ShowSelectButton="true" />
        </Columns>

    </asp:GridView>

</asp:Content>


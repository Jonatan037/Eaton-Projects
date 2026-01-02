<%@ Control Language="C#" AutoEventWireup="true" CodeFile="UserControl_MasterIndex_Seach_SerialNumber.ascx.cs" Inherits="UserControl_MasterIndex_Seach_SerialNumber" %>

<asp:Panel ID="Panel1" runat="server" DefaultButton="btnSearch">

    <asp:Label ID="Label1" runat="server" Text="Enter serial number: "></asp:Label>
    <asp:TextBox ID="txtSerialNumber" runat="server" Width="200px"></asp:TextBox>
    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />

</asp:Panel>

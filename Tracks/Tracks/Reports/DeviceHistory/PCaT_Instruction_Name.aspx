<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PCaT_Instruction_Name.aspx.cs" Inherits="Tracks_Reports_DeviceHistory_PCaT_Instruction_Name" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

        <h2>PCaT Seach By Instruction Name</h2>

        <asp:Label ID="Label1" runat="server" Text="Enter Instuction Name: "></asp:Label>
        <asp:TextBox ID="txtCriteria" runat="server" Text ="PQNA Serial Number"></asp:TextBox>
        &nbsp;
        <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />

        <br /><br />
        <asp:Label ID="lblDebug" runat="server" Text="" ForeColor="Red"></asp:Label>     

        <br /><br />


</asp:Content>


<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_CorrectiveActions.aspx.cs" Inherits="Tracks_Protected_IssueReports_CorrectiveActions_Edit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:Label ID="lblTitle" runat="server" Text="Corrective Actions"></asp:Label>
    <br />
    <br />

    <h3>Enter corrective action data:</h3>

    Action Type:
    <br />
    <asp:DropDownList ID="ddlCorrectiveActionType" runat="server" />
    <br />
    <br />
    Notes:
    <br />
    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" Width="50%" Height="200px" />  
    
    <br />
    <br />

    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
    <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this entry?');" OnClick="btnDelete_Click" />

    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>




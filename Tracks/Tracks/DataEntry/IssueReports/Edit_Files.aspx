<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_Files.aspx.cs" Inherits="Tracks_DataEntry_IssueReports_Edit_Files" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <asp:Label ID="lblTitle" runat="server" Text="Upload File"></asp:Label>
    <br />
    <br />

    <asp:Panel ID="Panel1" runat="server">

        <h3>Choose the file to be uploaded:</h3>
        <asp:FileUpload ID="FileUpload1" runat="server"  Width="450px" />
        <br />
    </asp:Panel>


    Edit Notes:
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


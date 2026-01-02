<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_Components.aspx.cs" Inherits="Tracks_Protected_IssueReports_Components_Edit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">


    <script type="text/javascript" 

        src="http://ajax.microsoft.com/ajax/jquery/jquery-1.4.2.min.js">

    </script>


    <!-- make enter key work as tab for text boxes -->
    <script type="text/javascript">

        $(function() {

            $('input:text:first').focus();

            var $inp = $('input:text');

            $inp.bind('keydown', function(e) {

                //var key = (e.keyCode ? e.keyCode : e.charCode);

                var key = e.which;

                if (key == 13) {

                    e.preventDefault();

                    var nxtIdx = $inp.index(this) + 1;

                    $(":input:text:eq(" + nxtIdx + ")").focus();

                }

            });

        });

    </script>

    <script type="text/javascript">
        function confirmation(message)
        {
            $(window).bind("load", function ()
            {
                if ( confirm(message) )
                    $("#<%= ScriptConfirmation.ClientID%>").click();
            });
        }
    </script>

    <div style="display: none;">
        <asp:Button ID="ScriptConfirmation" runat="server" Text="Confirm" OnClick="ScriptConfirmation_Click"  />
    </div>

    <asp:Label ID="lblTitle" runat="server" Text="Edit Component"></asp:Label>
    <br />
    <br />

    <h3>Enter component data:</h3>
    <asp:Table ID="Table1" runat="server">
                        
    <asp:TableRow>
        <asp:TableCell>Serial Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtSerialNumber" runat="server" Enabled="true" Width="200px"  /> </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>
        
    <asp:TableRow>
        <asp:TableCell>Part Number: </asp:TableCell>
        <asp:TableCell> 
            <asp:TextBox ID="txtPartNumber" runat="server" Width="200px"  />  
            &nbsp;&nbsp;
            <asp:HyperLink ID="hlFindPartNumber" runat="server" NavigateUrl="~/Tracks/Reports/Standard_Reports/Support/Support_PartNumber_Lookup.aspx" Target="_blank">Help me find part number</asp:HyperLink>

        </asp:TableCell>

        <asp:TableCell></asp:TableCell>
    </asp:TableRow>
       
    <asp:TableRow>
        <asp:TableCell>Replacement Reason: </asp:TableCell>
        <asp:TableCell ColumnSpan="2"> <asp:DropDownList ID="ddlReplacementReasonType" runat="server" /> </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    <asp:TableRow>
        <asp:TableCell>Disposition: </asp:TableCell>
        <asp:TableCell ColumnSpan="2"> <asp:DropDownList ID="ddlDispositionType" runat="server" /></asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>


    <asp:TableRow>
        <asp:TableCell>Notes: </asp:TableCell>
        <asp:TableCell ColumnSpan="2"> <asp:TextBox ID="txtNotes" runat="server" Width="400px" />  </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    </asp:Table>
    
    <br />


    <br />
    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
    <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this entry?');" OnClick="btnDelete_Click" />

    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>


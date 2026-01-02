<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CreateNewEntry.aspx.cs" Inherits="Tracks_Protected_MasterIndex_CreateNewEntry" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <script type="text/javascript" 

        src="http://ajax.microsoft.com/ajax/jquery/jquery-1.4.2.min.js">

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
        <asp:Button ID="ScriptConfirmation" runat="server" Text="Confirm" OnClick="ScriptConfirmation_Click"   />
    </div>

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

    <h1>Add a new serial number</h1>
    <br />


    <asp:Table ID="Table1" runat="server">
                        
    <asp:TableRow>
        <asp:TableCell>Serial Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtSerialNumber" runat="server" Enabled="false" Width="200px"  /> </asp:TableCell>
        <asp:TableCell>Required</asp:TableCell>
    </asp:TableRow>
        
    <asp:TableRow>
        <asp:TableCell>CTO Number: </asp:TableCell><asp:TableCell> <asp:TextBox ID="txtPartNumber" runat="server" Width="200px"  />  </asp:TableCell>
        <asp:TableCell>Required</asp:TableCell>
    </asp:TableRow>
        
    <asp:TableRow>
        <asp:TableCell>Production Order Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtProductionOrderNumber" runat="server" Width="200px"  Enabled="true"/>  </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    <asp:TableRow>
        <asp:TableCell>Sales Order Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtSalesOrderNumber" runat="server" Width="200px" Enabled="false" />  </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    <asp:TableRow>
        <asp:TableCell>Notes: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtNotes" runat="server" Width="200px" />  </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    </asp:Table>
    
    <br />
                    

    <asp:Button ID="btnOk" runat="server" Text="Save" OnClick="btnOk_Click" />
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />

    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>



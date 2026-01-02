<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Edit_TestCompleteReport.aspx.cs" Inherits="Tracks_Protected_TestCompleteReports_Edit_TestCompleteReport" %>

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

    <asp:Label ID="lblTitle" runat="server" Text="Edit Test Complete Report"></asp:Label>
    <br />
    <br />


    <h3>Enter test complete report data:</h3>
    <asp:Table ID="Table1" runat="server">
                        
    <asp:TableRow>
        <asp:TableCell>Serial Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtSerialNumber" runat="server" Enabled="false" Width="200px"  /> </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>
        
    <asp:TableRow>
        <asp:TableCell>Part Number: </asp:TableCell>
        <asp:TableCell> 
            <asp:TextBox ID="txtPartNumber" runat="server" Width="200px"  />  
        </asp:TableCell>

        <asp:TableCell></asp:TableCell>
    </asp:TableRow>
       
    <asp:TableRow>
        <asp:TableCell>Production Order Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtProductionOrderNumber" runat="server" Width="200px"  /> </asp:TableCell>  
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    <asp:TableRow>
        <asp:TableCell>Sales Order Number: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtSalesOrderNumber" runat="server" Width="200px" Enabled="false"  /> </asp:TableCell>  
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    <asp:TableRow>
        <asp:TableCell>Employee ID#: </asp:TableCell>
        <asp:TableCell> <asp:TextBox ID="txtEmployeeID" runat="server" Width="200px"  /> </asp:TableCell>  
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    <asp:TableRow>
        <asp:TableCell>Notes: </asp:TableCell>
        <asp:TableCell ColumnSpan="2"> <asp:TextBox ID="txtNotes" runat="server" Width="400px" />  </asp:TableCell>
        <asp:TableCell></asp:TableCell>
    </asp:TableRow>

    </asp:Table>
    
    <br />
    <asp:Button ID="btnPrint" runat="server" Text="Print" OnClick="btnPrint_Click" />    
    <br />
    <br />
    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
    <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this entry?');" OnClick="btnDelete_Click" />

    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>




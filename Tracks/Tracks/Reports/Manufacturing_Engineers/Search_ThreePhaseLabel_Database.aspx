<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Search_ThreePhaseLabel_Database.aspx.cs" Inherits="Tracks_Reports_Manufacturing_Engineers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">


    <h2>Search ThreePhaseLabel Database</h2>
      
    <asp:RadioButtonList ID="rblType" runat="server">
        <asp:ListItem  Value=1 Selected="True">Search By Serial Number</asp:ListItem>
        <asp:ListItem  Value=2>Search By Config</asp:ListItem>
    </asp:RadioButtonList>    

        
    <asp:Label ID="Label1" runat="server" Text="Criteria Like: "></asp:Label>
    <asp:TextBox ID="txtCriteria" runat="server">xxxxx</asp:TextBox>
    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"  />
    <br />
    <br />

    <asp:GridView ID="gvLabels" runat="server" AutoGenerateColumns="False"  ShowHeaderWhenEmpty="True" EmptyDataText="No data found" DataKeyNames="Id">
         
        <AlternatingRowStyle BackColor="#CCCCCC" />
        <SelectedRowStyle BackColor="Yellow" />
                 
        <Columns>

            <asp:TemplateField ShowHeader="false">

                <ItemTemplate>
                    <asp:LinkButton ID="lbSelect" runat="server" CausesValidation="False" CommandName="Select" Text="Select"  CommandArgument='<%# Container.DataItemIndex%>' />
                </ItemTemplate>

            </asp:TemplateField>


             <asp:BoundField DataField="Serial" HeaderText="Serial" SortExpression="Serial" />             
             <asp:BoundField DataField="CONFIG" HeaderText="CONFIG" SortExpression="CONFIG" />

             <asp:BoundField DataField="FULLCTO" HeaderText="FULLCTO" SortExpression="FULLCTO" />
             <asp:BoundField DataField="SYSTR" HeaderText="SYSTR" SortExpression="SYSTR" />
             <asp:BoundField DataField="Linedate" HeaderText="Linedate" SortExpression="Linedate" />
             <asp:BoundField DataField="Id" HeaderText="Id" InsertVisible="False" ReadOnly="True" SortExpression="Id" />

             <asp:BoundField DataField="P" HeaderText="P" SortExpression="P" />
             <asp:BoundField DataField="PLUS" HeaderText="PLUS" SortExpression="PLUS" />
             <asp:BoundField DataField="SERIALREV" HeaderText="SERIALREV" SortExpression="SERIALREV" />
             <asp:BoundField DataField="MODNUM" HeaderText="MODNUM" SortExpression="MODNUM" />
             <asp:BoundField DataField="N6" HeaderText="N6" SortExpression="N6" />
             <asp:BoundField DataField="N7" HeaderText="N7" SortExpression="N7" />
             <asp:BoundField DataField="INVOLT" HeaderText="INVOLT" SortExpression="INVOLT" />
             <asp:BoundField DataField="N9" HeaderText="N9" SortExpression="N9" />
             <asp:BoundField DataField="INAMP" HeaderText="INAMP" SortExpression="INAMP" />
             <asp:BoundField DataField="INHZ" HeaderText="INHZ" SortExpression="INHZ" />
             <asp:BoundField DataField="N12" HeaderText="N12" SortExpression="N12" />
             <asp:BoundField DataField="INPHASE" HeaderText="INPHASE" SortExpression="INPHASE" />
             <asp:BoundField DataField="VDCNUM" HeaderText="VDCNUM" SortExpression="VDCNUM" />
             <asp:BoundField DataField="DCAMP" HeaderText="DCAMP" SortExpression="DCAMP" />
             <asp:BoundField DataField="OUTVOLT" HeaderText="OUTVOLT" SortExpression="OUTVOLT" />
             <asp:BoundField DataField="N17" HeaderText="N17" SortExpression="N17" />
             <asp:BoundField DataField="OUTKVA" HeaderText="OUTKVA" SortExpression="OUTKVA" />
             <asp:BoundField DataField="OUTKW" HeaderText="OUTKW" SortExpression="OUTKW" />
             <asp:BoundField DataField="OUTAMP" HeaderText="OUTAMP" SortExpression="OUTAMP" />
             <asp:BoundField DataField="OUTPHASE" HeaderText="OUTPHASE" SortExpression="OUTPHASE" />
             <asp:BoundField DataField="OUTHZ" HeaderText="OUTHZ" SortExpression="OUTHZ" />
             <asp:BoundField DataField="CABTOT" HeaderText="CABTOT" SortExpression="CABTOT" />
             <asp:BoundField DataField="INPUT" HeaderText="INPUT" SortExpression="INPUT" />
             <asp:BoundField DataField="TRANS" HeaderText="TRANS" SortExpression="TRANS" />
             <asp:BoundField DataField="TRANS2" HeaderText="TRANS2" SortExpression="TRANS2" />
             <asp:BoundField DataField="AGENCY1" HeaderText="AGENCY1" SortExpression="AGENCY1" />
             <asp:BoundField DataField="AGENCY2" HeaderText="AGENCY2" SortExpression="AGENCY2" />
             <asp:BoundField DataField="AGENCY3" HeaderText="AGENCY3" SortExpression="AGENCY3" />
             <asp:BoundField DataField="UPSTYPE1" HeaderText="UPSTYPE1" SortExpression="UPSTYPE1" />
             <asp:BoundField DataField="UPSTYPE2" HeaderText="UPSTYPE2" SortExpression="UPSTYPE2" />
             <asp:BoundField DataField="BYPASS" HeaderText="BYPASS" SortExpression="BYPASS" />
             <asp:BoundField DataField="INAMP2" HeaderText="INAMP2" SortExpression="INAMP2" />
             <asp:BoundField DataField="BYPVOLT" HeaderText="BYPVOLT" SortExpression="BYPVOLT" />
             <asp:BoundField DataField="BYPAMP" HeaderText="BYPAMP" SortExpression="BYPAMP" />
             <asp:BoundField DataField="BYPHZ" HeaderText="BYPHZ" SortExpression="BYPHZ" />
             <asp:BoundField DataField="BYPPHASE" HeaderText="BYPPHASE" SortExpression="BYPPHASE" />
             <asp:BoundField DataField="BYPKVA" HeaderText="BYPKVA" SortExpression="BYPKVA" />
             <asp:BoundField DataField="LABELSTRING" HeaderText="LABELSTRING" SortExpression="LABELSTRING" />
             <asp:BoundField DataField="MULTILABEL" HeaderText="MULTILABEL" SortExpression="MULTILABEL" />
             <asp:BoundField DataField="SERIALTYPE" HeaderText="SERIALTYPE" SortExpression="SERIALTYPE" />
             <asp:BoundField DataField="SerialProcess" HeaderText="SerialProcess" SortExpression="SerialProcess" />

             <asp:BoundField DataField="UPSTYPE" HeaderText="UPSTYPE" SortExpression="UPSTYPE" />
             <asp:BoundField DataField="INA" HeaderText="INA" SortExpression="INA" />


         </Columns>
    </asp:GridView>
    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>


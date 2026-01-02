<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="LabelDatabaseTest.aspx.cs" Inherits="Tracks_Reports_Audits_LabelDatabaseTest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">


    <h2>PCaT Audit For Model Number & Serial Number Accuracy</h2>

    <h4>Compares PCAT values against the Label Database.</h4> 


    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnSearch">

        Perform Audit For&nbsp; <asp:DropDownList ID="ddlLineNames" runat="server"></asp:DropDownList>
        &nbsp;&nbsp;From&nbsp; <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>   
        <asp:Button ID="btnResetDates" runat="server" Text="Reset Dates" OnClick="btnResetDates_Click" ToolTip="Reset dates and requery." />
        <br />

        <asp:RadioButtonList ID="rblDisplayMode" runat="server">
            <asp:ListItem Text="Show Failures Only" Selected="True" />
            <asp:ListItem Text="Show All Results" />
        </asp:RadioButtonList>
        <br />


        <asp:Button ID="btnSearch" runat="server" Text="Run Audit" OnClick="btnSearch_Click" />
        <br /><br />
    </asp:Panel>


    <asp:GridView ID="GridView1" runat="server" 
        EmptyDataText="No audit issues were found for the specified criteria."
        HeaderStyle-BackColor="LightGreen"
        CellPadding="2" 
    >

            <AlternatingRowStyle BackColor="#CCCCCC" />
    </asp:GridView>

    <br /><br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>


    <br />


    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />


</asp:Content>


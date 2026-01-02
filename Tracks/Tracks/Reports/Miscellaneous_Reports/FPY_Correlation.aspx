<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="FPY_Correlation.aspx.cs" Inherits="Tracks_Reports_Miscellaneous_Reports_FPY_Correlation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h2>FPY Correlation</h2>

    From <asp:TextBox ID="txtStartDate"  runat="server" ></asp:TextBox> To <asp:TextBox ID="txtEndDate" runat="server" ></asp:TextBox>   
    <br />

    <asp:Table runat="server">

        <asp:TableRow>

            <asp:TableCell>Plant</asp:TableCell>

            <asp:TableCell>

                <asp:DropDownList ID="ddlPlants" runat="server">
                    <asp:ListItem>CPO</asp:ListItem>
                    <asp:ListItem Selected="True">RPO</asp:ListItem>
                    <asp:ListItem >YPO</asp:ListItem>
                </asp:DropDownList>

            </asp:TableCell>

        </asp:TableRow>

    </asp:Table>

    <asp:Button ID="btnFind" runat="server" Text="Refresh" OnClick="btnFind_Click" />
    <br />
    <br />

    <asp:GridView Caption="Units that impacted yields" CaptionAlign="Left" ID="GridView1" runat="server" EmptyDataText="No records were found for the specified date range." ShowHeaderWhenEmpty="True">

        <AlternatingRowStyle BackColor="#CCCCCC" />
        <SelectedRowStyle BackColor="Yellow" />


    </asp:GridView>

    <br />
    <br />
    <br />

    <asp:Label runat="server" Text=""></asp:Label>
    <asp:GridView Caption="Issue Reports" CaptionAlign="Left" ID="gvIssueReports" runat="server" AutoGenerateColumns="false" EmptyDataText="No records were found for the specified date range." ShowHeaderWhenEmpty="True" AutoGenerateSelectButton="true">

            <AlternatingRowStyle BackColor="#CCCCCC" />
            <SelectedRowStyle BackColor="Yellow" />

            <Columns>

                <asp:BoundField DataField="PLANT" HeaderText="PLANT"/>
                <asp:BoundField DataField="FAMILY" HeaderText="FAMILY"/>
                <asp:BoundField DataField="CATEGORY" HeaderText="CATEGORY"/>
                <asp:BoundField DataField="SERIAL_NUMBER" HeaderText="SERIAL_NUMBER"/>
                <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER"/>
                <asp:BoundField DataField="EMPLOYEE_ID" HeaderText="EMPLOYEE_ID"/>
                <asp:BoundField DataField="STATION_TYPE" HeaderText="STATION_TYPE"/>
                <asp:BoundField DataField="NONCONFORMANCE_CODE" HeaderText="NONCONFORMANCE_CODE"/>
                <asp:BoundField DataField="CLOSED" HeaderText="CLOSED"/>
                <asp:BoundField DataField="CREATION_TIMESTAMP" HeaderText="ISSUE_DATE"/>
                <asp:BoundField DataField="PROBLEM_DESCRIPTION" HeaderText="PROBLEM_DESCRIPTION" HtmlEncode="false" />
                <asp:BoundField DataField="NOTES" HeaderText="NOTES"  HtmlEncode="false"  />
                <asp:BoundField DataField="ISSUE_REPORTS_ID" HeaderText="ISSUE_REPORTS_ID" Visible="false" />

            </Columns>


    </asp:GridView>

    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />

    <br />
    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>




</asp:Content>


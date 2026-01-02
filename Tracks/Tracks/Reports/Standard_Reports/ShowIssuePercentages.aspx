<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ShowIssuePercentages.aspx.cs" Inherits="NCRs_Standard_Reports_ShowIssuePercentages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" Runat="Server">

    <h1>Show Issue Percentages</h1>
    <h3>This report uses a combination of Issue Reports and ATE information to determine if a unit had one or more issues.</h3>
    
    <asp:Panel ID="pnlDates" runat="server" DefaultButton="btnFind">

        <asp:Label ID="Label1" runat="server" Text="Date range between "></asp:Label>
        <br />
        <asp:TextBox ID="txtStartDate"  runat="server"></asp:TextBox>
        <asp:Label ID="Label2" runat="server" Text=" and "></asp:Label>
        <asp:TextBox ID="txtEndDate" runat="server"></asp:TextBox>
        <asp:Button ID="btnFind" runat="server" Text="Refresh" OnClick="btnFind_Click" />

    </asp:Panel>

    <br />
    <br />

    <asp:GridView ID="gvYieldsPlant" Caption="Issue Percentages by Plant" AutoGenerateColumns="true"  runat="server" OnSelectedIndexChanged="gvYieldsPlant_SelectedIndexChanged">

        <AlternatingRowStyle BackColor="#CCCCCC" />

    </asp:GridView>
    <br />
    <br />

    <asp:GridView ID="gvYieldsFamily" Caption="Issue Percentages by Plant and Family" AutoGenerateColumns="true"  runat="server" OnSelectedIndexChanged="gvYieldsFamily_SelectedIndexChanged">

        <AlternatingRowStyle BackColor="#CCCCCC" />

    </asp:GridView>
    <br />
    <br />

    <asp:GridView ID="gvYieldsCategory" Caption="Issue Percentages by Plant, Family, Category " AutoGenerateColumns="true"  runat="server" OnSelectedIndexChanged="gvYieldsCategory_SelectedIndexChanged">

        <AlternatingRowStyle BackColor="#CCCCCC" />

    </asp:GridView>

    <br />
    <asp:Label ID="Label3" runat="server" Text="Download the data that was used in the percentages calculations:"></asp:Label>
    <br />
    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />
            


    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate" />
    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate" />

    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>

</asp:Content>



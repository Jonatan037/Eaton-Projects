<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Support_PartNumber_Lookup.aspx.cs" Inherits="Tracks_Reports_Standard_Reports_Support_Support_PartNumber_Lookup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Look Up Part Number</title>

    <script type = "text/javascript">
        function CopyToClipboard(value) {
            window.clipboardData.setData("Text", value);
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
    <div>


    <h2>Find Part Number </h2>

    <asp:RadioButtonList ID="RadioButtonList1" AutoPostBack="true" runat="server" OnSelectedIndexChanged="RadioButtonList1_SelectedIndexChanged">
        <asp:ListItem Value="liComponentText" Text="Search by entering a value listed on the component."></asp:ListItem>
        <asp:ListItem Value="liCategoryList" Text="Search by selecting a category from the drop list." Selected="True"></asp:ListItem>
    </asp:RadioButtonList>


    <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnFind">
        <br />
        <asp:DropDownList ID="ddlCategory" runat="server"  Width="200px" />
        <asp:TextBox ID="txtSearchCriteria" runat="server" Visible="false" Width="200px" ToolTip="You might not have to enter the whole value. The first 4 or 5 characters might be enough." />
        <asp:Button ID="btnFind" runat="server" Text="Find" OnClick="btnFind_Click"  />
        <br /><br />
    </asp:Panel>

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" EmptyDataText="No data found" ShowHeaderWhenEmpty="True" DataKeyNames="PART_NUMBER" >

        <AlternatingRowStyle BackColor="#CCCCCC" />

        <Columns>

            <asp:TemplateField ShowHeader="true">

                <HeaderTemplate>
                    <asp:LinkButton ID="btnReset" runat="server" CausesValidation="False" Text="Reset" OnClick="btnReset_Click" ToolTip="Reset all filters"></asp:LinkButton>
                </HeaderTemplate>

                <ItemTemplate>
                    <asp:LinkButton OnClientClick='<%# "CopyToClipboard(\"" + Eval("PART_NUMBER") + "\"); return true;" %>' CommandName="Select" Text="Select" runat="server"></asp:LinkButton>
            </ItemTemplate>

            </asp:TemplateField>


            <asp:BoundField DataField="PART_NUMBER" HeaderText="PART_NUMBER" />

            <asp:TemplateField>
                <HeaderTemplate>
                    PLANT
                    <asp:DropDownList ID="PLANT" runat="server"  OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged" AutoPostBack="true" AppendDataBoundItems="true" />
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("PLANT") %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField>
                <HeaderTemplate>
                    FAMILY
                    <asp:DropDownList ID="FAMILY" runat="server"  OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged" AutoPostBack="true" AppendDataBoundItems="true" />
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("FAMILY") %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField>
                <HeaderTemplate>
                    CATEGORY
                    <asp:DropDownList ID="CATEGORY" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"   AutoPostBack="true" AppendDataBoundItems="true">
                    </asp:DropDownList>
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("CATEGORY") %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField>
                <HeaderTemplate>
                    SUBCATEGORY
                    <asp:DropDownList ID="SUBCATEGORY" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"   AutoPostBack="true" AppendDataBoundItems="true">
                    </asp:DropDownList>
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("SUBCATEGORY") %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField>
                <HeaderTemplate>
                    MATERIAL_TYPE
                    <asp:DropDownList ID="MATERIAL_TYPE" runat="server" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged"   AutoPostBack="true" AppendDataBoundItems="true">
                    </asp:DropDownList>
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("MATERIAL_TYPE") %>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="COST" HeaderText="COST"/>

            <asp:BoundField DataField="VENDOR_PART_NUMBER" HeaderText="VENDOR_PART_NUMBER"/>
            <asp:BoundField DataField="SERIAL_NUMBER_STARTS_WITH" HeaderText="SN_STARTS_WITH"/>

            <asp:BoundField DataField="DESCRIPTION" HeaderText="DESCRIPTION"/>
            <asp:BoundField DataField="NOTES" HeaderText="NOTES"/>

        </Columns>

        <SelectedRowStyle BackColor="Yellow" />

    </asp:GridView>
    <br />
    <br />
    <br />



    <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="http://mantech.ch.etn.com" Target="_blank">Work Instructions - UPS</asp:HyperLink>
    <br />
    <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="http://mantech.ch.etn.com/3P_PD.htm" Target="_blank">Work Instructions - DCS</asp:HyperLink>

    <br />
    <br />
    <asp:Label ID="lblDebug" runat="server" Text=""></asp:Label>





    
    </div>
    </form>
</body>
</html>

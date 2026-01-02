


function PrintPanel()
{
    var panel = document.getElementById("<%=pnlContents.ClientID %>");
    var printWindow = window.open('', '', 'height=800,width=800');
    printWindow.document.write('<html><head><title></title>');
    printWindow.document.write('</head><body >');
    printWindow.document.write(panel.innerHTML);
    printWindow.document.write('</body></html>');
    printWindow.document.close();
    setTimeout(function () { printWindow.print(); }, 500);
    printWindow.onfocus = function () { setTimeout(function () { printWindow.close(); }, 2000); }
    return false;
}

<html>

<head>
<title>Production Database Queries</title>
</head>

<body>

<h2 align="center">Production Database Queries</h2>

<hr align="center">
<script LANGUAGE="JavaScript">
<!--
function SetQueryName(form)
{
	form.action = form.QuerySelection[form.QuerySelection.selectedIndex].value;
	return true;
}

function SetToday()
{
	var today = new Date();
	var year;

	document.forms[0].StartMonth.selectedIndex = today.getMonth();
	document.forms[0].EndMonth.selectedIndex   = today.getMonth();

	document.forms[0].StartDay.selectedIndex = today.getDate() - 1;
	document.forms[0].EndDay.selectedIndex   = today.getDate() - 1;


	// Y2K fix.
	year = today.getYear();
	if (year > 1900) year = year - 1900;

	// First year in our list is 1998.
	document.forms[0].StartYear.selectedIndex = year - 98;
	document.forms[0].EndYear.selectedIndex   = year - 98;

	return false;
}

// -->
</script>


<p align="center">&nbsp;</p>

<form>
  <div align="center"></div><div align="center"><div align="center"><center><p>
  <select  SIZE="1" NAME="QuerySelection">

    <option value="ypo\show_empower_yields.asp">Show test yields</option>
    <option value="ypo\AssemblyTest\show_assembly_test_yields.asp">Show sub-assembly test yields</option>
    <option value="ypo\find_unit_record.asp">Find Unit Test Record</option>

	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\BladeUPS\show_bladeups_failure_pareto.asp">BladeUPS - Failure Pareto</option>
	<option value="ypo\show_hp_yields.asp">BladeUPS - Show HP yields</option>

	<option value="">--------------------------------------------------------------------------------</option>
    <option value="ypo\NCR\show_ncr_defect_table_info.asp">NCR - Download Defects Table Data</option>
    <option value="ypo\NCR\show_ncr_logs.asp">NCR - Show NCR UUT LOG</option>
    <option value="ypo\NCR\show_unclosed_ncrs.asp">NCR - Show Unclosed NCRs at YPO</option>
    <option value="ypo\NCR\ncr_search_001_enter_search_parameters.asp">NCR - Search for problem description and analysis</option>
	<option value="ypo\NCR\show_invalid_entries.asp">NCR - Show Possible Data Entry Problems</option>

	<option>--------------------------------------------------------------------------------</option>
	<option value="ypo\9x55\show_9x55_test_logs.asp">9x55 - Show Test Logs</option>

	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\epdu\show_edpu_yields_by_part_number.asp">ePDU - Show Yields By Part Number</option>
    <option value="ypo\epdu\show_edpu_index_table.asp">ePDU - Show Logs</option>


	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\Ferrups\show_ferrups_failure_pareto.asp">FERRUPS - Failure Pareto</option>

	<option value="">--------------------------------------------------------------------------------</option>
    <option value="ypo\PerformanceData\get_performance_data_for_battery_line.asp">Battery Line - Download Performance Data</option>

	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\Panda\get_temp.asp">Panda</option>

	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\FailureInfo\FailureInfo_Main.asp">Failure Information</option>
    <option value="ypo\MSA\get_msa_data.asp">MSA Data</option>
    <option value="ypo\PerformanceData\enter_performance_data_search_parameters.asp">Search for test step performance data</option>

    <option>--------------------------------------------------------------------------------</option>
    <option value="ypo\ProcessCapabilityData\get_data_taa_5115.asp">Process Capability Data - TAA 5115</option>
    <option value="ypo\ProcessCapabilityData\get_data_taa_5130.asp">Process Capability Data - TAA 5130</option>
    <option value="ypo\ProcessCapabilityData\get_data_taa_9130.asp">Process Capability Data - TAA 9130</option>
	<option value="ypo\ProcessCapabilityData\get_data_bladeups_hv.asp">Process Capability Data - BLADEUPS High Voltage</option>
	<option value="ypo\ProcessCapabilityData\get_data_9x55.asp">Process Capability Data - 9x55</option>
	<option value="ypo\ProcessCapabilityData\get_data_9355_15.asp">Process Capability Data - 9355-15</option>
	<option value="ypo\ProcessCapabilityData\get_data_9355_30.asp">Process Capability Data - 9355-30</option>

	<option value="ypo\ProcessCapabilityData\get_data_ferrups_small_medium.asp">Process Capability Data - FERRUPS Small & Medium</option>
	<option value="ypo\ProcessCapabilityData\get_data_ferrups_large.asp">Process Capability Data - FERRUPS Large</option>
	<option value="ypo\ProcessCapabilityData\get_data_spd.asp">Process Capability Data - SPD</option>

	<option value="ypo\Panda\get_panda_process_capability_data.asp">Process Capability Data - 9E (Panda)</option>

    <option>--------------------------------------------------------------------------------</option>
    <option value="ypo\emPowerTools\show_raw_empower_data_as_html.asp">Show Raw emPower Data</option>

    <option>--------------------------------------------------------------------------------</option>
    <option value="ypo\BurnIn\get_BurnIn_data.asp">Unit BurnIn Data</option>

    <option>--------------------------------------------------------------------------------</option>
    <option value="ypo\Shark\show_config_file_header_info.asp">Shark - Unit Configuration Files</option>
	
	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\Eagle\show_eagle_test_results.asp">Eagle - Show Test Results</option>

	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\misc\show_empower_warning_logs.asp">Show Empower Warning Logs</option>

	<option>--------------------------------------------------------------------------------</option>
    <option value="ypo\9390_Completed_Checklists\9390_Completed_Checklists.asp">9390_Completed_Checklists</option>




  </select> </p>

  </center></div><p>&nbsp;&nbsp; </p>
  <dd align="center"><select SIZE="1" NAME="StartMonth">
      <option value="01"> January </option>
      <option value="02"> February </option>
      <option value="03"> March </option>
      <option value="04"> April </option>
      <option value="05"> May </option>
      <option value="06"> June </option>
      <option value="07"> July </option>
      <option value="08"> August </option>
      <option value="09"> September </option>
      <option value="10"> October </option>
      <option value="11"> November </option>
      <option value="12"> December </option>
    </select> <select SIZE="1" NAME="StartDay">
      <option value="01"> 01 </option>
      <option value="02"> 02 </option>
      <option value="03"> 03 </option>
      <option value="04"> 04 </option>
      <option value="05"> 05 </option>
      <option value="06"> 06 </option>
      <option value="07"> 07 </option>
      <option value="08"> 08 </option>
      <option value="09"> 09 </option>
      <option value="10"> 10 </option>
      <option value="11"> 11 </option>
      <option value="12"> 12 </option>
      <option value="13"> 13 </option>
      <option value="14"> 14 </option>
      <option value="15"> 15 </option>
      <option value="16"> 16 </option>
      <option value="17"> 17 </option>
      <option value="18"> 18 </option>
      <option value="19"> 19 </option>
      <option value="20"> 20 </option>
      <option value="21"> 21 </option>
      <option value="22"> 22 </option>
      <option value="23"> 23 </option>
      <option value="24"> 24 </option>
      <option value="25"> 25 </option>
      <option value="26"> 26 </option>
      <option value="27"> 27 </option>
      <option value="28"> 28 </option>
      <option value="29"> 29 </option>
      <option value="30"> 30 </option>
      <option value="31"> 31 </option>
    </select> <select SIZE="1" NAME="StartYear">
      <option value="1998"> 1998 </option>
      <option value="1999"> 1999 </option>
      <option value="2000"> 2000 </option>
      <option value="2001"> 2001 </option>
      <option value="2002"> 2002 </option>
      <option value="2003"> 2003 </option>
      <option value="2004"> 2004 </option>
      <option value="2005"> 2005 </option>
      <option value="2006"> 2006 </option>
      <option value="2007"> 2007 </option>
      <option value="2008"> 2008 </option>
      <option value="2009"> 2009 </option>
      <option value="2010"> 2010 </option>
      <option value="2011"> 2011 </option>
      <option value="2012"> 2012 </option>
      <option value="2013"> 2013 </option>
      <option value="2014"> 2014 </option>
      <option value="2015"> 2015 </option>
      <option value="2016"> 2016 </option>
      <option value="2017"> 2017 </option>
    </select>&nbsp;&nbsp;&nbsp; To&nbsp;&nbsp;&nbsp; <select SIZE="1" NAME="EndMonth">
      <option value="01"> January </option>
      <option value="02"> February </option>
      <option value="03"> March </option>
      <option value="04"> April </option>
      <option value="05"> May </option>
      <option value="06"> June </option>
      <option value="07"> July </option>
      <option value="08"> August </option>
      <option value="09"> September </option>
      <option value="10"> October </option>
      <option value="11"> November </option>
      <option value="12"> December </option>
    </select> <select SIZE="1" NAME="EndDay">
      <option value="01"> 01 </option>
      <option value="02"> 02 </option>
      <option value="03"> 03 </option>
      <option value="04"> 04 </option>
      <option value="05"> 05 </option>
      <option value="06"> 06 </option>
      <option value="07"> 07 </option>
      <option value="08"> 08 </option>
      <option value="09"> 09 </option>
      <option value="10"> 10 </option>
      <option value="11"> 11 </option>
      <option value="12"> 12 </option>
      <option value="13"> 13 </option>
      <option value="14"> 14 </option>
      <option value="15"> 15 </option>
      <option value="16"> 16 </option>
      <option value="17"> 17 </option>
      <option value="18"> 18 </option>
      <option value="19"> 19 </option>
      <option value="20"> 20 </option>
      <option value="21"> 21 </option>
      <option value="22"> 22 </option>
      <option value="23"> 23 </option>
      <option value="24"> 24 </option>
      <option value="25"> 25 </option>
      <option value="26"> 26 </option>
      <option value="27"> 27 </option>
      <option value="28"> 28 </option>
      <option value="29"> 29 </option>
      <option value="30"> 30 </option>
      <option value="31"> 31 </option>
    </select> &nbsp;<select SIZE="1" NAME="EndYear">
      <option value="1998"> 1998 </option>
      <option value="1999"> 1999 </option>
      <option value="2000"> 2000 </option>
      <option value="2001"> 2001 </option>
      <option value="2002"> 2002 </option>
      <option value="2003"> 2003 </option>
      <option value="2004"> 2004 </option>
      <option value="2005"> 2005 </option>
      <option value="2006"> 2006 </option>
      <option value="2007"> 2007 </option>
      <option value="2008"> 2008 </option>
      <option value="2009"> 2009 </option>
      <option value="2010"> 2010 </option>
      <option value="2011"> 2011 </option>
      <option value="2012"> 2012 </option>
      <option value="2013"> 2013 </option>
      <option value="2014"> 2014 </option>
      <option value="2015"> 2015 </option>
      <option value="2016"> 2016 </option>
      <option value="2017"> 2017 </option>
    </select> </dd>
  <div align="center"><center><p>&nbsp;</p>
  </center></div><div align="center"><center><p>&nbsp;&nbsp; <input LANGUAGE="JavaScript"
  TYPE="submit" VALUE="Submit" ONCLICK="return SetQueryName(this.form);" NAME="B1"> &nbsp;<input
  type="reset" value="Reset" ONCLICK="return SetToday();" name="B2"> </p>
  </center></div></div>
</form>

<p align="center">&nbsp; <script LANGUAGE="JavaScript">
<!--

	if (document.cookie.indexOf("DateInitalized=TRUE") == -1)
	{
		document.cookie = "DateInitalized=TRUE";

		var today = new Date();
		var year;

		document.forms[0].StartMonth.selectedIndex = today.getMonth();
		document.forms[0].EndMonth.selectedIndex   = today.getMonth();

		document.forms[0].StartDay.selectedIndex = today.getDate() - 1;
		document.forms[0].EndDay.selectedIndex   = today.getDate() - 1;

		// Y2K fix.
		year = today.getYear();
		if (year > 1900) year = year - 1900;

		// First year in our list is 1998.
		document.forms[0].StartYear.selectedIndex = year - 98;
		document.forms[0].EndYear.selectedIndex   = year - 98;
	}

//-->
    </script></p>

<p align="center">&nbsp;</p>

<p align="center">&nbsp;</p>
</body>
</html>

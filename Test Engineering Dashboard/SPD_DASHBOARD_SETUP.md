# SPD Dashboard Setup

## Quick Setup

1. **Run SQL**: Execute `Setup_SPDDashboard_Complete.sql` on your database
2. **Copy Files**: 
   - SPDLabelDashboard.aspx
   - SPDLabelDashboard.aspx.cs
   - App_Code/TED/SpdDashboardService.cs
3. **Install**: Newtonsoft.Json NuGet package
4. **Done**: Navigate to `~/SPDLabelDashboard.aspx`

## Features

### Key Metrics
- **Tested Units**: All units with passed functional tests (Integrated/Sidemount workcells only)
- **Validated Units**: Units that passed label verification at packout
- **Validation Rate**: Percentage of tested units that have been validated
- **Pass Rate**: Percentage of validations that matched expected material

### By Workcell
- Separate tracking for Integrated and Sidemount lines
- Shows tested count, validated count, and validation rate for each

### Filtering
- Only shows test results from Integrated and Sidemount workcells
- Ignores test results from other production lines

## Important Notes

- The dashboard compares **passed functional tests** from AccessDB vs **label validations** from SQL
- Only units tested in Integrated or Sidemount workcells are tracked
- Validation rate shows what % of tested units have been scanned at packout

# Hipot Test Application

A C# Windows Forms application for capturing and storing Hipot/Ground Bond test results from the Associated Research OMNIA II 8204 Electrical Safety Compliance Analyzer.

## Overview

This application automates the capture and storage of electrical safety test results including:
- **Ground Bond (GND) Testing** - Verifies proper grounding of equipment
- **AC Withstand (ACW) Testing** - Verifies dielectric strength (Hipot)
- **Safety Equipment Checks (FailCHEK)** - Daily verification of test equipment

## Features

- **User Authentication** - Login using employee number and password from existing Users table
- **Shift-based Safety Checks** - Required FailCHEK verification once per shift per operator
- **Automatic Test Data Capture** - Serial communication with OMNIA II for real-time data
- **SQL Server Integration** - All test results stored in TestEngineering database
- **Test History** - View previous tests for each serial number
- **Visual Results Display** - Clear PASS/FAIL indicators with detailed measurements

## Requirements

### Hardware
- Associated Research OMNIA II Model 8204 (or compatible 08204)
- USB-to-Serial adapter (if no native COM port)
- FailCHEK adapter for equipment verification

### Software
- Windows 10 or later
- .NET Framework 4.8
- SQL Server Express (with TestEngineering database)
- Visual Studio 2019+ (for development)

## Project Structure

```
HipotTestApp/
├── Communication/
│   └── OmniaCommunicator.cs    # Serial port communication with OMNIA II
├── Data/
│   └── DatabaseHelper.cs        # SQL Server database operations
├── Forms/
│   ├── LoginForm.cs            # User authentication
│   ├── MainForm.cs             # Main test interface
│   └── SafetyCheckForm.cs      # FailCHEK validation
├── Models/
│   ├── HipotTestResult.cs      # Production test data model
│   ├── SafetyCheckResult.cs    # Safety check data model
│   └── User.cs                 # User information model
├── App.config                   # Application settings
├── HipotTestApp.csproj         # Project file
├── HipotTestApp.sln            # Solution file
└── Program.cs                  # Application entry point
```

## Database Setup

Run the SQL script in the `Database` folder to create the required tables:

```sql
-- Run this script against your Phoenix database
Database/Create_HipotTestResults_Tables.sql
```

This creates:
- `HipotTestResults` - Stores production test results
- `SafetyCheckResults` - Stores daily equipment validation results
- Views and stored procedures for reporting

## Configuration

Edit `App.config` to configure:

### Connection String
```xml
<connectionStrings>
    <add name="PhoenixConnectionString" 
         connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=Phoenix;Integrated Security=True" />
</connectionStrings>
```

### Serial Port Settings
```xml
<appSettings>
    <add key="SerialPort" value="COM3"/>
    <add key="BaudRate" value="9600"/>
    <add key="DataBits" value="8"/>
    <add key="Parity" value="None"/>
    <add key="StopBits" value="One"/>
</appSettings>
```

### Shift Configuration
```xml
<appSettings>
    <add key="Shift1Start" value="06:00"/>
    <add key="Shift2Start" value="14:00"/>
    <add key="Shift3Start" value="22:00"/>
</appSettings>
```

## OMNIA II Communication

The application communicates with the OMNIA II via RS-232 serial connection:

| Parameter | Value |
|-----------|-------|
| Baud Rate | 9600 |
| Data Bits | 8 |
| Stop Bits | 1 |
| Parity | None |
| Flow Control | None |

### Key Commands Used

| Command | Description |
|---------|-------------|
| `*IDN?` | Get device identification |
| `TD?` | Get test data |
| `FD?` | Get FailCHEK data |
| `SS?` | Get system status |
| `TEST` | Start test sequence |
| `FC` | Start FailCHEK sequence |
| `RESET` | Reset device |

## Test Parameters

### Ground Bond Test (Default)
- Current: 25.00 A
- Hi-Limit: 100 mΩ
- Lo-Limit: 0 mΩ
- Dwell Time: 1.0 s
- Frequency: 60 Hz

### AC Withstand Test (Default)
- Voltage: 1960 V
- Hi-Limit: 35.00 mA
- Lo-Limit: 0.001 mA
- Dwell Time: 60.0 s
- Ramp Up: 5.0 s
- Ramp Down: 5.0 s
- Frequency: 60 Hz

## Usage

### First Time Setup
1. Install the application
2. Run the database SQL script
3. Configure `App.config` with correct COM port
4. Add users to the Users table

### Daily Operation
1. Launch the application
2. Login with employee number and password
3. Run Safety Check (FailCHEK) - required once per shift
4. Enter unit serial number
5. Click START TEST
6. View results and proceed to next unit

### Safety Check
- Required once per shift per operator
- Validates test equipment is functioning correctly
- Uses FailCHEK adapter with known values
- Both Continuity and Ground Bond must pass

## Troubleshooting

### Cannot Connect to OMNIA
- Verify USB cable is connected
- Check COM port number in Device Manager
- Ensure no other application is using the port
- Verify baud rate is set to 9600

### Database Connection Failed
- Verify SQL Server is running
- Check connection string in App.config
- Ensure Phoenix database exists
- Verify Windows authentication is enabled

### Test Results Not Saving
- Check database permissions
- Verify tables were created correctly
- Review application log for errors

## Future Enhancements

- [ ] Add barcode scanner support for serial numbers
- [ ] Implement automatic work order lookup
- [ ] Add report generation functionality
- [ ] Create dashboard for test statistics
- [ ] Add email notifications for failures
- [ ] Implement calibration tracking

## Support

For technical support, contact the Test Engineering team.

## Version History

- **v1.0.0** - Initial release
  - Basic test capture and storage
  - User authentication
  - Shift-based safety checks

'
' AppConfig.vb - Application Configuration for Battery Test Application
' Version: 1.0
' Author: J. Arias
' Date: November 2025
'
' CHANGE LOG:
' ===========
' v1.0 (November 2025) - J. Arias
' - Initial implementation for SQL user validation
' - Added ValidateUserAgainstSQL method with department and test line authorization
' - Added configuration reading from SystemConfig.ini
' - Integrated with existing VB.NET Battery Test Application

Imports System.Data.SqlClient
Imports System.Configuration
Imports System.IO

Public Class AppConfig
    Private ReadOnly configPath As String = Path.Combine(Application.StartupPath, "SystemConfig.ini")

    ' Load specific setting from SystemConfig.ini
    Public Function LoadSpecificSetting(setting As String) As String
        Dim output As String = String.Empty

        If File.Exists(configPath) Then
            Dim lines() As String = File.ReadAllLines(configPath)

            For Each line As String In lines
                Dim trimmedLine As String = line.Trim()

                ' Skip empty lines and comments
                If String.IsNullOrEmpty(trimmedLine) OrElse trimmedLine.StartsWith("#") OrElse trimmedLine.StartsWith(";") Then
                    Continue For
                End If

                ' Look for setting=value pattern, allowing spaces around the equals sign
                If trimmedLine.Contains("=") Then
                    Dim parts() As String = trimmedLine.Split(New Char() {"="c}, 2)
                    If parts.Length = 2 Then
                        Dim settingName As String = parts(0).Trim()
                        Dim settingValue As String = parts(1).Trim()

                        If settingName.Equals(setting, StringComparison.OrdinalIgnoreCase) Then
                            output = settingValue
                            Exit For
                        End If
                    End If
                End If
            Next
        End If

        Return output
    End Function

    ' Check if SQL user validation is enabled
    Public Function IsUserSQLValidationEnabled() As Boolean
        Dim setting As String = LoadSpecificSetting("USESQLUSERVALIDATION")
        Return setting.ToUpper() = "TRUE" OrElse setting = "1"
    End Function

    ' Validate user against SQL database with department and test line authorization
    Public Function ValidateUserAgainstSQL(eNumber As String) As (isValid As Boolean, fullName As String)
        Try
            Dim connectionString As String = ConfigurationManager.ConnectionStrings("TestEngineeringConnectionString").ConnectionString

            ' Check if connection string is properly configured
            If String.IsNullOrEmpty(connectionString) OrElse connectionString.Contains("YOUR_SQL_SERVER_NAME") Then
                MessageBox.Show(
                    "SQL validation is enabled but the database connection is not configured.\n\nPlease update the connection string in app.config:\n- Replace 'YOUR_SQL_SERVER_NAME' with your actual SQL Server name\n- Ensure the TestEngineering database is accessible\n- Verify dbo.Users table exists with ENumber, FullName, Department, and TestLine columns",
                    "Database Not Configured",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning)
                Return (False, String.Empty)
            End If

            ' Get battery line ID from config
            Dim batteryLineIDStr As String = LoadSpecificSetting("BATTERYLINEID")
            Dim batteryLineID As Integer
            If String.IsNullOrEmpty(batteryLineIDStr) OrElse Not Integer.TryParse(batteryLineIDStr, batteryLineID) Then
                batteryLineID = 2 ' Default to 2 if not configured
            End If

            ' Add connection timeout to prevent hanging (30 seconds)
            If Not connectionString.Contains("Connection Timeout") Then
                connectionString += ";Connection Timeout=30"
            End If

            Using connection As New SqlConnection(connectionString)
                ' Query to get user info including department and test lines
                Using command As New SqlCommand("SELECT FullName, Department, TestLine FROM dbo.Users WHERE ENumber = @ENumber", connection)
                    command.Parameters.AddWithValue("@ENumber", eNumber)
                    command.CommandTimeout = 30 ' 30 second timeout

                    connection.Open()
                    Using reader As SqlDataReader = command.ExecuteReader()
                        If reader.Read() Then
                            ' User exists, get their information
                            Dim fullName As String = If(reader("FullName") IsNot DBNull.Value, reader("FullName").ToString().Trim(), eNumber)
                            Dim department As String = If(reader("Department") IsNot DBNull.Value, reader("Department").ToString().Trim(), "")
                            Dim testLine As String = If(reader("TestLine") IsNot DBNull.Value, reader("TestLine").ToString().Trim(), "")

                            ' Check department authorization
                            If Not String.IsNullOrEmpty(department) AndAlso department.Equals("Test Engineering", StringComparison.OrdinalIgnoreCase) Then
                                ' Test Engineering department has access to all
                                Return (True, fullName)
                            End If

                            ' Check test line authorization
                            If Not String.IsNullOrEmpty(testLine) Then
                                ' Parse comma-separated test line IDs
                                Dim assignedLines() As String = testLine.Split(New Char() {","c}, StringSplitOptions.RemoveEmptyEntries)
                                For Each line As String In assignedLines
                                    Dim lineID As Integer
                                    If Integer.TryParse(line.Trim(), lineID) AndAlso lineID = batteryLineID Then
                                        ' User has battery line access
                                        Return (True, fullName)
                                    End If
                                Next
                            End If                            ' User exists but doesn't have required department or test line access
                            MessageBox.Show(
                                $"Access denied for {fullName}.\n\nRequired: Department='Test Engineering' OR TestLine contains '{batteryLineID}'",
                                "Authorization Failed",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Warning)
                            Return (False, String.Empty)
                        Else
                            ' User not found
                            MessageBox.Show($"E-number '{eNumber}' not found in the database.",
                                          "User Not Found",
                                          MessageBoxButtons.OK,
                                          MessageBoxIcon.Warning)
                            Return (False, String.Empty)
                        End If
                    End Using
                End Using
            End Using

        Catch sqlEx As SqlException
            ' Show specific SQL error information
            MessageBox.Show(
                $"Database connection error: {sqlEx.Message}\n\nError Number: {sqlEx.Number}\n\nPlease check:\n1. Database server is accessible\n2. Connection string is configured correctly\n3. dbo.Users table exists\n4. Required columns exist: ENumber, FullName, Department, TestLine\n5. You have proper database permissions",
                "SQL Validation Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error)
            Return (False, String.Empty)
        Catch ex As Exception
            ' Show general error information
            MessageBox.Show(
                $"Unexpected error during SQL validation: {ex.Message}\n\nStack Trace: {ex.StackTrace}",
                "Validation Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error)
            Return (False, String.Empty)
        End Try
    End Function
End Class
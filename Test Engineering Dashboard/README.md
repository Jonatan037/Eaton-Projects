Test Engineering Dashboard (WebForms)

Overview
- Sub-application under the main intranet site (Default Web Site) built with ASP.NET Web Forms to match the existing Tracks stack.
- Implements a Login page that authenticates against SQL Server database TestEngineering.dbo.Users.
- Uses ADO.NET with Integrated Security to match existing connection approach.

Paths
- /Test Engineering Dashboard/ (app root)
- /Test Engineering Dashboard/Account/Login.aspx (login)
- /Test Engineering Dashboard/Dashboard.aspx (post-login landing)

Connection
- Web.config key: TestEngineeringConnectionString -> Data Source=.\\SQLEXPRESS; Initial Catalog=TestEngineering; Integrated Security=True

Deploy (IIS)
1) Copy the folder "Test Engineering Dashboard" to the same physical root where WebSite and Tracks live.
2) In IIS Manager -> Default Web Site -> Add Application...
   - Alias: Test Engineering Dashboard (spaces are fine)  
   - Physical path: path to this folder  
   - Application pool: .NET CLR v4.x, Integrated pipeline
3) Authentication (at the application level):
   - Enable Anonymous Authentication (required for Forms Auth)  
   - Enable Forms Authentication  
   - Leave Windows/Basic/Digest disabled for this app
4) Default Document: ensure Default.aspx is enabled.
5) SQL permissions: App pool identity (e.g., IIS APPPOOL\\DefaultAppPool) needs access to SQL Express instance and TestEngineering DB (db_datareader, db_datawriter).

Test user SQL (two options)
- Plain text (dev only):
  INSERT INTO dbo.Users(FullName, ENumber, Email, Password, UserCategory, IsActive, CreatedDate, CreatedBy)
  VALUES (N'Test User', N'E123456', N'test.user@eaton.com', N'eaton123', N'Tester', 1, GETDATE(), N'Setup');

- SHA256 hash (recommended):
  -- password: eaton123
  INSERT INTO dbo.Users(FullName, ENumber, Email, Password, UserCategory, IsActive, CreatedDate, CreatedBy)
  VALUES (N'Test User', N'E123456', N'test.user@eaton.com', N'9c5c44b23b36d2eeb9b31b49205b55df1f7fbe5dd6f6a7b3b90f7d3a4ca1d5d8', N'Tester', 1, GETDATE(), N'Setup');

Navigate
- http://<server>/Test%20Engineering%20Dashboard/
- Or click the link on http://<server>/ (updated in WebSite/Default.asp)

Notes
- App enforces Forms Authentication via Web.config; Login and Default.aspx are anonymously accessible; all other pages require auth. Default.aspx immediately routes to Dashboard.aspx for authenticated users.
- Password checker supports plain text, 64-char SHA256 hex, or prefixed format SHA256:hex.

Database scripts
- Location: Test Engineering Dashboard/Database/Scripts
- Update user categories CHECK constraint (Users.UserCategory) to allow: Admin, Test Engineering, Quality, Tester, Viewer
  1) Open SQL Server Management Studio connected to the instance hosting the TestEngineering database.
  2) Run the script: Update_UserCategory_Check_Constraint.sql
  3) Verify: SELECT DISTINCT UserCategory FROM dbo.Users; should include only the five categories above for new/updated rows.

Notes on categories
- The application standardizes UserCategory values to: Admin, Test Engineering, Quality, Tester, Viewer. Ensure the database constraint matches this list to avoid save errors when creating or updating users.

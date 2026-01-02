-- =============================================
-- Insert Additional Manufacturing Testers from XML
-- Excludes duplicates already inserted and Jeff Anderson
-- Department: Manufacturing
-- Job Role: Tester
-- Test Line: 2
-- User Category: Regular
-- Password: Same as E Number
-- =============================================

-- New users to insert (not in previous batch):
-- C3078442 - Chance Walker
-- C3057268 - Jackie Richardson (contractor)
-- C3072826 - Jakida Taylor
-- E0695600 - Jeff Anderson (EXCLUDED per request)
-- E0841962 - Lisa Campanilla-Nopal
-- C3079270 - Michael Green
-- C3058621 - Oakoya Turner
-- E0379911 - Richard Carter
-- C3076273 - Shandora Williams
-- C3075993 - Tenisha Parker
-- C3058622 - Terry Ward
-- E0067495 - Tyneres Blount
-- C3067497 - Kawana Jones (contractor - different from E0819721 already inserted)

-- Insert new users only (13 users after excluding duplicates and Jeff Anderson)
INSERT INTO dbo.Users (ENumber, FullName, Email, Password, Department, JobRole, TestLine, UserCategory, IsActive, CreatedDate, CreatedBy)
VALUES 
    ('C3078442', 'Chance Walker', 'C3078442@eaton.com', 'C3078442', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3057268', 'Jackie Richardson', 'C3057268@eaton.com', 'C3057268', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3072826', 'Jakida Taylor', 'C3072826@eaton.com', 'C3072826', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0841962', 'Lisa Campanilla-Nopal', 'E0841962@eaton.com', 'E0841962', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3079270', 'Michael Green', 'C3079270@eaton.com', 'C3079270', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3058621', 'Oakoya Turner', 'C3058621@eaton.com', 'C3058621', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0379911', 'Richard Carter', 'E0379911@eaton.com', 'E0379911', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3076273', 'Shandora Williams', 'C3076273@eaton.com', 'C3076273', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3075993', 'Tenisha Parker', 'C3075993@eaton.com', 'C3075993', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3058622', 'Terry Ward', 'C3058622@eaton.com', 'C3058622', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0067495', 'Tyneres Blount', 'E0067495@eaton.com', 'E0067495', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3067497', 'Kawana Jones', 'C3067497@eaton.com', 'C3067497', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System');

PRINT 'Successfully inserted 12 additional Manufacturing Testers';
PRINT 'Excluded duplicates from previous batch:';
PRINT '  - E0617128 (Cemone Robinson)';
PRINT '  - E0805098 (Chakiria Thorne)';
PRINT '  - C3079268 (Chris Tilley)';
PRINT '  - E0857487 (Deonte Bobbitt)';
PRINT '  - E0697896 (Destonee Durham)';
PRINT '  - E0086583 (Domitila Guerra)';
PRINT '  - E0857559 (Fred Baldwin)';
PRINT '  - C3078629 (Jack Vick)';
PRINT '  - E0716835 (Jackie Davis)';
PRINT '  - E0706472 (Jackie Richardson - E number)';
PRINT '  - E0857684 (Jecario Watson)';
PRINT '  - C3078628 (Jermale Avent)';
PRINT '  - E0806800 (Jessica Arrington)';
PRINT '  - E0087594 (Jonathan Williams)';
PRINT '  - C3079266 (KaDaechia Spivey)';
PRINT '  - E0819721 (Kawana Jones - E number)';
PRINT '  - E0809894 (Kiara Whitley)';
PRINT '  - E0810928 (Ma Enriquiz Acero/Acero Enriquez)';
PRINT '  - E0696703 (Rebecca Seward)';
PRINT '  - E0612796 (Rick Evans)';
PRINT '  - E0067523 (Ruby Ruffin)';
PRINT '  - E0089393 (Sonya Coley)';
PRINT '  - C3079100 (Stacy Burton)';
PRINT '  - E0722058 (Trent Hodge)';
PRINT '  - E0058333 (William Ellenburg)';
PRINT 'Excluded per request:';
PRINT '  - E0695600 (Jeff Anderson)';

-- Verification: Show the newly inserted users
SELECT 
    UserID,
    ENumber,
    FullName,
    Email,
    Department,
    JobRole,
    TestLine,
    UserCategory,
    IsActive,
    CreatedDate
FROM dbo.Users
WHERE ENumber IN (
    'C3078442', 'C3057268', 'C3072826', 'E0841962', 'C3079270', 'C3058621',
    'E0379911', 'C3076273', 'C3075993', 'C3058622', 'E0067495', 'C3067497'
)
ORDER BY FullName;

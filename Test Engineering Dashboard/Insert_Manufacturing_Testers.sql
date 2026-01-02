-- =============================================
-- Insert Manufacturing Testers into Users Table
-- Department: Manufacturing
-- Job Role: Tester
-- Test Line: 2
-- User Category: Regular
-- Password: Same as E Number
-- =============================================

-- Insert users
INSERT INTO dbo.Users (ENumber, FullName, Email, Password, Department, JobRole, TestLine, UserCategory, IsActive, CreatedDate, CreatedBy)
VALUES 
    ('E0810928', 'Acero Enriquez', 'E0810928@eaton.com', 'E0810928', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0629512', 'Annie Covington', 'E0629512@eaton.com', 'E0629512', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0617128', 'Cemone Robinson', 'E0617128@eaton.com', 'E0617128', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0805098', 'Chakiria Thorne', 'E0805098@eaton.com', 'E0805098', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0697896', 'Destonee Durham', 'E0697896@eaton.com', 'E0697896', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0086583', 'Domitila Guerra', 'E0086583@eaton.com', 'E0086583', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0716835', 'Jackie Davis', 'E0716835@eaton.com', 'E0716835', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0706472', 'Jackie Richardson', 'E0706472@eaton.com', 'E0706472', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0806800', 'Jessica Arrington', 'E0806800@eaton.com', 'E0806800', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0087594', 'Jonathan Williams', 'E0087594@eaton.com', 'E0087594', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0819721', 'Kawana Jones', 'E0819721@eaton.com', 'E0819721', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0809894', 'Kiara Whitley', 'E0809894@eaton.com', 'E0809894', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0696703', 'Rebecca Seward', 'E0696703@eaton.com', 'E0696703', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0089238', 'Reginald Ray', 'E0089238@eaton.com', 'E0089238', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0612796', 'Rick Evans', 'E0612796@eaton.com', 'E0612796', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0067523', 'Ruby Ruffin', 'E0067523@eaton.com', 'E0067523', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0089393', 'Sonya Coley', 'E0089393@eaton.com', 'E0089393', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3066959', 'Tatiyana Jones', 'C3066959@eaton.com', 'C3066959', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0722058', 'Trent Hodge', 'E0722058@eaton.com', 'E0722058', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0058333', 'William Ellenburg', 'E0058333@eaton.com', 'E0058333', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3076943', 'Deonte Bobbitt', 'C3076943@eaton.com', 'C3076943', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3079268', 'Christopher Tilley', 'C3079268@eaton.com', 'C3079268', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3079266', 'KaDaechia Spivey', 'C3079266@eaton.com', 'C3079266', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0857684', 'Jecario Watson', 'E0857684@eaton.com', 'E0857684', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0857559', 'Fred Baldwin', 'E0857559@eaton.com', 'E0857559', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('E0857487', 'Deonte Bobbitt', 'E0857487@eaton.com', 'E0857487', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3079100', 'Stacy Burton', 'C3079100@eaton.com', 'C3079100', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3078629', 'Jack Vick', 'C3078629@eaton.com', 'C3078629', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System'),
    ('C3078628', 'Jermale Avent', 'C3078628@eaton.com', 'C3078628', 'Manufacturing', 'Tester', '2', 'Regular', 1, GETDATE(), 'System');

PRINT 'Successfully inserted 29 Manufacturing Testers';

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
    'E0810928', 'E0629512', 'E0617128', 'E0805098', 'E0697896', 'E0086583', 
    'E0716835', 'E0706472', 'E0806800', 'E0087594', 'E0819721', 'E0809894', 
    'E0696703', 'E0089238', 'E0612796', 'E0067523', 'E0089393', 'C3066959', 
    'E0722058', 'E0058333', 'C3076943', 'C3079268', 'C3079266', 'E0857684', 
    'E0857559', 'E0857487', 'C3079100', 'C3078629', 'C3078628'
)
ORDER BY FullName;

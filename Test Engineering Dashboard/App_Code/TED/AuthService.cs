using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace TED
{
    public class AuthService
    {
        private readonly string _constr;

        public AuthService()
        {
            _constr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        }

        public class UserRecord
        {
            public int UserID { get; set; }
            public string FullName { get; set; }
            public string ENumber { get; set; }
            public string Email { get; set; }
            public string UserCategory { get; set; }
            public bool IsActive { get; set; }
            public string JobRole { get; set; }
        }

        public UserRecord ValidateCredentials(string identifier, string password)
        {
            // identifier can be email or ENumber
            using (var conn = new SqlConnection(_constr))
            using (var cmd = new SqlCommand(@"SELECT TOP 1 UserID, FullName, ENumber, Email, Password, UserCategory, IsActive, JobRole
                                              FROM dbo.Users
                                              WHERE (LOWER(Email) = LOWER(@identifier) OR LOWER(ENumber) = LOWER(@identifier))", conn))
            {
                cmd.Parameters.AddWithValue("@identifier", identifier);
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (!rdr.Read()) return null;

                    string dbPassword = rdr["Password"] as string ?? string.Empty;
                    bool ok = CheckPassword(password, dbPassword);
                    if (!ok) return null;

                    return new UserRecord
                    {
                        UserID = Convert.ToInt32(rdr["UserID"]),
                        FullName = rdr["FullName"].ToString(),
                        ENumber = rdr["ENumber"].ToString(),
                        Email = rdr["Email"].ToString(),
                        UserCategory = rdr["UserCategory"].ToString(),
                        IsActive = rdr["IsActive"] != DBNull.Value && Convert.ToBoolean(rdr["IsActive"]),
                        JobRole = rdr["JobRole"].ToString()
                    };
                }
            }
        }

        /// <summary>
        /// Looks up a user by email or E-Number without requiring a password. Intended for badge validation workflows.
        /// </summary>
        public UserRecord FindUserByIdentifier(string identifier, bool requireActive = true)
        {
            if (string.IsNullOrWhiteSpace(identifier)) return null;

            using (var conn = new SqlConnection(_constr))
            using (var cmd = new SqlCommand(@"SELECT TOP 1 UserID, FullName, ENumber, Email, UserCategory, IsActive, JobRole
                                              FROM dbo.Users
                                              WHERE (LOWER(Email) = LOWER(@identifier) OR LOWER(ENumber) = LOWER(@identifier))", conn))
            {
                cmd.Parameters.AddWithValue("@identifier", identifier);
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (!rdr.Read()) return null;

                    bool isActive = rdr["IsActive"] != DBNull.Value && Convert.ToBoolean(rdr["IsActive"]);
                    if (requireActive && !isActive) return null;

                    return new UserRecord
                    {
                        UserID = Convert.ToInt32(rdr["UserID"]),
                        FullName = rdr["FullName"].ToString(),
                        ENumber = rdr["ENumber"].ToString(),
                        Email = rdr["Email"].ToString(),
                        UserCategory = rdr["UserCategory"].ToString(),
                        IsActive = isActive,
                        JobRole = rdr["JobRole"].ToString()
                    };
                }
            }
        }

        private bool CheckPassword(string inputPassword, string stored)
        {
            if (string.IsNullOrEmpty(stored)) return false;

            // Support common cases: plain text (dev), SHA256 hex, or salted format 'SHA256:hex'
            if (stored.StartsWith("SHA256:", StringComparison.OrdinalIgnoreCase))
            {
                var hash = stored.Substring("SHA256:".Length);
                return SlowEquals(hash, Sha256Hex(inputPassword));
            }

            // If it's 64-char hex, assume SHA256
            if (stored.Length == 64 && IsHex(stored))
            {
                return SlowEquals(stored, Sha256Hex(inputPassword));
            }

            // Fallback: plain text match
            return stored == inputPassword;
        }

        private string Sha256Hex(string value)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(value));
                var sb = new StringBuilder(bytes.Length * 2);
                foreach (var b in bytes) sb.AppendFormat("{0:x2}", b);
                return sb.ToString();
            }
        }

        private bool IsHex(string s)
        {
            for (int i = 0; i < s.Length; i++)
            {
                char c = s[i];
                bool hex = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
                if (!hex) return false;
            }
            return true;
        }

        private bool SlowEquals(string a, string b)
        {
            if (a == null || b == null || a.Length != b.Length) return false;
            int diff = 0;
            for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
            return diff == 0;
        }

        public void UpdateLastLoginDate(int userId)
        {
            using (var conn = new SqlConnection(_constr))
            using (var cmd = new SqlCommand("UPDATE dbo.Users SET LastLoginDate = GETDATE() WHERE UserID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", userId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;


using System.Web.UI.WebControls;



namespace Tracks.DAL
{
    /// <summary>
    /// Summary description for Tools
    /// </summary>
    public class Tools
    {
        public Tools()
        {
            
        }

#if true
        public void PopulatePlantDropDownList(DropDownList ddl)
        {
            DataTable dtDropDownList = new DataTable();
            DataRow work_row;

            dtDropDownList.Clear();
            dtDropDownList.Columns.Add("Description");
            dtDropDownList.Columns.Add("Criteria");

            dtDropDownList.Rows.Add(new object[] { "All", " " });
            dtDropDownList.Rows.Add(new object[] { "CPO", " AND (PLANT = 'CPO') " });
            dtDropDownList.Rows.Add(new object[] { "RPO", " AND (PLANT = 'RPO') " });
            dtDropDownList.Rows.Add(new object[] { "YPO", " AND (PLANT = 'YPO') " });

            //dtDropDownList.Rows.Add(new object[] { "RPO - 9395 ", " AND (PLANT = 'RPO' AND FAMILY = '9395') " });
            //dtDropDownList.Rows.Add(new object[] { "RPO - 9395P ", " AND (PLANT = 'RPO' AND FAMILY = '9395P') " });
            //dtDropDownList.Rows.Add(new object[] { "RPO - DCS ", " AND (PLANT = 'RPO' AND FAMILY = 'DCS') " });
            //dtDropDownList.Rows.Add(new object[] { "RPO - 93PM ", " AND (PLANT = 'RPO' AND FAMILY = '93PM') " });
            //dtDropDownList.Rows.Add(new object[] { "RPO - 93PM-L ", " AND (PLANT = 'RPO' AND FAMILY = '93PM-L') " });

            // -----------------------------------------------------------------------------------------------------


            DbAccess db = new DbAccess();
            DataTable dtLines = db.GetData("SELECT PLANT, FAMILY FROM MASTER_INDEX GROUP BY PLANT, FAMILY ORDER BY PLANT, FAMILY");


            foreach (DataRow row in dtLines.Rows)
            {
                work_row = dtDropDownList.NewRow();

                work_row["Description"] = row["Plant"].ToString() + " - " + row["Family"].ToString();
                work_row["Criteria"] = " AND ( PLANT = '" + row["Plant"].ToString() + "' AND FAMILY = '" + row["Family"].ToString() + "' ) ";

                dtDropDownList.Rows.Add(work_row);
            }

            ddl.DataSource = dtDropDownList;
            ddl.DataTextField = "Description";
            ddl.DataValueField = "Criteria";
            ddl.DataBind();
        }

#else
        public void PopulatePlantDropDownList(DropDownList ddl)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt.Columns.Add("Plant");
            dt.Rows.Add(new object[] { "All" });
            dt.Rows.Add(new object[] { "CPO" });
            dt.Rows.Add(new object[] { "RPO" });
            dt.Rows.Add(new object[] { "YPO" });


            ddl.DataSource = dt;
            ddl.DataTextField = "Plant";
            ddl.DataValueField = "Plant";
            ddl.DataBind();
        }

#endif


        public void CreateExcelFile(string FileName, ref DataTable DT)
        {
            string text;

            string attach = "attachment;filename=" + FileName + ".xls";

            if (DT == null) return;

                System.Web.HttpContext.Current.Response.Write("");

            System.Web.HttpContext.Current.Response.ClearContent();
            System.Web.HttpContext.Current.Response.AddHeader("content-disposition", attach);
            System.Web.HttpContext.Current.Response.ContentType = "application/ms-excel";

            // Get the column names
            foreach (DataColumn dc in DT.Columns)
            {
                System.Web.HttpContext.Current.Response.Write(dc.ColumnName + "\t");
            }

            // Start a new row
            System.Web.HttpContext.Current.Response.Write(System.Environment.NewLine);

            // Get the data in each row.
            foreach (DataRow dr in DT.Rows)
            {
                for (int i = 0; i < DT.Columns.Count; i++)
                {
                    text = dr[i].ToString();
                    text = text.Replace(System.Environment.NewLine, "");

                    System.Web.HttpContext.Current.Response.Write(text + "\t");
                }

                // Start the next row.
                System.Web.HttpContext.Current.Response.Write(System.Environment.NewLine);
            }

            System.Web.HttpContext.Current.Response.End();

        }

    }

}
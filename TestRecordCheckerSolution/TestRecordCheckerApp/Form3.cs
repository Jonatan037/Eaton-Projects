using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using TestRecordCheckerApp.Classes;

namespace TestRecordCheckerApp
{
    public partial class VerifiedResultsForm : Form
    {
        private AppConfig config = new AppConfig();
        private string plant, productionLine, subLine, stationName, machineName;

        public VerifiedResultsForm()
        {
            InitializeComponent();
            ConfigureHistoryGrid();
            LoadTodaysVerifications();            
            dgvHistory.RowPrePaint += dgvHistory_RowPrePaint;
            loadAppInfo();
        }

        private void LoadTodaysVerifications()
        {
            var reader = new ValidationLogReader();
            dgvHistory.DataSource = reader.GetTodaysValidations();
        }
        public void RefreshHistory()
        {
            var reader = new ValidationLogReader();
            dgvHistory.DataSource = reader.GetTodaysValidations();
        }

        private void label3_Click(object sender, EventArgs e)
        {

        }
        private void dgvHistory_RowPrePaint(object sender, DataGridViewRowPrePaintEventArgs e)
        {
            var grid = sender as DataGridView;
            if (grid?.Rows[e.RowIndex].DataBoundItem is DataRowView rowView)
            {
                string result = rowView["Check Status"]?.ToString()?.ToLower();

                if (result == "pass")
                {
                    grid.Rows[e.RowIndex].DefaultCellStyle.BackColor = System.Drawing.Color.FromArgb(255, 144, 238, 144); // LightGreen
                }
                else if (result == "fail")
                {
                    grid.Rows[e.RowIndex].DefaultCellStyle.BackColor = System.Drawing.Color.FromArgb(255, 240, 128, 128); // LightCoral
                }
            }
        }

        private void loadAppInfo()
        {
            plant = config.LoadSpecificSetting("Plant");
            productionLine = config.LoadSpecificSetting("ProductionLine");
            subLine = config.LoadSpecificSetting("SubLine");
            stationName = config.LoadSpecificSetting("StationName");
            machineName = Environment.MachineName;
            lblSubTitle.Text = plant + " | " + productionLine + " | " + subLine + " | " + stationName;
        }


    }


}

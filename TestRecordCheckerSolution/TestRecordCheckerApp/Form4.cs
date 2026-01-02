/*
 * TestRecordCheckerApp - Feedback Form (Form4.cs)
 * Version: 1.11
 * Author: J. Arias
 * Date: November 2025
 *
 * CHANGE LOG:
 * ===========
 * v1.11 (November 2025) - J. Arias
 * - Added version control and comprehensive documentation
 * - Documented feedback system with GIF animations and sound effects
 *
 * v1.6 (November 2025) - J. Arias
 * - Implemented comprehensive feedback system with animated GIFs and sound effects
 * - Added continuous siren playback with alternating frequencies (1000Hz/700Hz)
 * - Implemented GIF animation refresh timers to maintain smooth animations
 * - Added modal feedback dialogs with professional styling and auto-close timers
 * - Green background for pass notifications, red for fail notifications
 * - Sound fallback system: siren.wav file → Console.Beep → SystemSounds
 * - Proper error handling for missing sound/image files
 *
 * v1.0 (Original) - Basic feedback form without multimedia enhancements
 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Media;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Reflection;
using TestRecordCheckerApp.Classes;

namespace TestRecordCheckerApp
{
    public partial class FeedbackForm : Form
    {
        private bool isPass;
        private bool sirenHighPitch = true; // For alternating siren frequencies

        public FeedbackForm(bool isPass)
        {
            InitializeComponent();
            this.isPass = isPass;
            SetupFeedback();
        }

        private void SetupFeedback()
        {
            if (isPass)
            {
                // Green background for pass
                this.BackColor = Color.LimeGreen;
                this.lblMessage.Text = "Passed Test Record Found\r\n✓ PROCEED WITH PACKAGING";
                this.pictureBoxEmergency.Visible = false;
                this.pictureBoxCheckmark.Visible = true;

                // Load checkmark image from executable directory
                try
                {
                    string exePath = Assembly.GetExecutingAssembly().Location;
                    string exeDir = Path.GetDirectoryName(exePath);
                    string checkmarkPath = Path.Combine(exeDir, "Checkmark.gif");
                    this.pictureBoxCheckmark.Image = Image.FromFile(checkmarkPath);
                    // Ensure GIF animation continues
                    this.pictureBoxCheckmark.Enabled = true;
                    // Force animation to start/restart
                    var temp = this.pictureBoxCheckmark.Image;
                    this.pictureBoxCheckmark.Image = null;
                    this.pictureBoxCheckmark.Image = temp;
                }
                catch
                {
                    // Ignore if image can't be loaded
                }

                // Center the checkmark
                this.pictureBoxCheckmark.Left = (this.ClientSize.Width - this.pictureBoxCheckmark.Width) / 2;
                this.pictureBoxCheckmark.Top = this.lblMessage.Bottom + 50;

                this.timerClose.Interval = 5000; // 5 seconds for pass
                // Start GIF refresh timer to keep animations fluent
                this.timerGifRefresh.Start();
            }
            else
            {
                // Red background for fail
                this.BackColor = Color.Red;
                this.lblMessage.Text = "Passed Test Record Not Found\r\n✗ PLEASE RETEST THE UNIT";
                this.pictureBoxEmergency.Visible = true;
                this.pictureBoxCheckmark.Visible = false;

                // Load emergency light image from executable directory
                try
                {
                    string exePath = Assembly.GetExecutingAssembly().Location;
                    string exeDir = Path.GetDirectoryName(exePath);
                    string emergencyPath = Path.Combine(exeDir, "Emergency_Light.gif");
                    this.pictureBoxEmergency.Image = Image.FromFile(emergencyPath);
                    // Ensure GIF animation continues
                    this.pictureBoxEmergency.Enabled = true;
                    // Force animation to start/restart
                    var temp = this.pictureBoxEmergency.Image;
                    this.pictureBoxEmergency.Image = null;
                    this.pictureBoxEmergency.Image = temp;
                }
                catch
                {
                    // Ignore if image can't be loaded
                }

                // Center the emergency light
                this.pictureBoxEmergency.Left = (this.ClientSize.Width - this.pictureBoxEmergency.Width) / 2;
                this.pictureBoxEmergency.Top = this.lblMessage.Bottom + 50;

                this.timerClose.Interval = 8000; // 8 seconds for fail

                // Start sound timer for continuous horn
                this.timerSound.Start();
                // Start GIF refresh timer to keep animations fluent
                this.timerGifRefresh.Start();
            }

            // Center the message
            this.lblMessage.Left = (this.ClientSize.Width - this.lblMessage.Width) / 2;

            // Start the timer to close the form
            this.timerClose.Start();
        }

        private void FeedbackForm_Load(object sender, EventArgs e)
        {
            // Form is already set up in constructor
            // Ensure GIF animations continue
            if (this.pictureBoxCheckmark.Image != null)
            {
                this.pictureBoxCheckmark.Invalidate();
            }
            if (this.pictureBoxEmergency.Image != null)
            {
                this.pictureBoxEmergency.Invalidate();
            }
        }

        private void timerClose_Tick(object sender, EventArgs e)
        {
            this.timerClose.Stop();
            this.timerSound.Stop(); // Stop the sound when form closes
            this.timerGifRefresh.Stop(); // Stop GIF refresh when form closes
            this.Close();
        }

        private void timerSound_Tick(object sender, EventArgs e)
        {
            // Play continuous siren sound by alternating frequencies
            try
            {
                // Try to play a siren.wav file from the executable directory first
                string exePath = Assembly.GetExecutingAssembly().Location;
                string exeDir = Path.GetDirectoryName(exePath);
                string sirenPath = Path.Combine(exeDir, "siren.wav");

                if (File.Exists(sirenPath))
                {
                    using (var player = new SoundPlayer(sirenPath))
                    {
                        player.Play();
                    }
                }
                else
                {
                    // Create siren effect by alternating between high and low frequencies
                    // "wee-woo" siren pattern
                    if (sirenHighPitch)
                    {
                        Console.Beep(1000, 300); // "wee" - higher pitch, longer
                    }
                    else
                    {
                        Console.Beep(700, 300);  // "woo" - lower pitch, longer
                    }
                    sirenHighPitch = !sirenHighPitch; // Alternate pitches
                }
            }
            catch (Exception)
            {
                // If Console.Beep fails, try system sounds
                try
                {
                    if (sirenHighPitch)
                        SystemSounds.Beep.Play();
                    else
                        SystemSounds.Asterisk.Play();
                    sirenHighPitch = !sirenHighPitch;
                }
                catch
                {
                    // Final fallback
                    SystemSounds.Exclamation.Play();
                }
            }
        }

        private void timerGifRefresh_Tick(object sender, EventArgs e)
        {
            // Keep GIF animations fluent by periodically refreshing them
            if (this.pictureBoxCheckmark.Visible && this.pictureBoxCheckmark.Image != null)
            {
                this.pictureBoxCheckmark.Refresh();
            }
            if (this.pictureBoxEmergency.Visible && this.pictureBoxEmergency.Image != null)
            {
                this.pictureBoxEmergency.Refresh();
            }
        }
    }
}
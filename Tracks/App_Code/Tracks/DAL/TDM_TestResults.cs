using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Create an XML file to be submitted to the TDM database.
/// </summary>
namespace Tracks.DAL
{
    [Serializable]
    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
    public partial class TDM_TestResults 
    {

        /// <summary>
        /// Create an XML file to be submitted to the TDM database.
        /// </summary>
        [System.Xml.Serialization.XmlArrayItemAttribute("TestResult", IsNullable = false)]
        //public TDM_TestResultsTestResult[] TestResults        
        public List<TDM_TestResultsTestResult> TestResults = new List<TDM_TestResultsTestResult>();

    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class TDM_TestResultsTestResult
    {

        private string instructionNameField;

        private string statusField;

        private string testCommentsField;

        private System.DateTime startTimeField;

        private System.DateTime endTimeField;

        private byte sequenceNumberField;

        private string resultsField;

        private string testUnitsField;

        private string testSequenceNameField;

        private string lineNameField;

        private string serialNumberField;

        private string catalogNumberField;

        private byte resultTypeField;

        private string workstationNameField;

        private string parentWorkStationField;

        private string shiftNameField;

        private string operatorNameField;

        private string parametersField;

        /// <remarks/>
        public string InstructionName
        {
            get
            {
                return this.instructionNameField;
            }
            set
            {
                this.instructionNameField = value;
            }
        }

        /// <remarks/>
        public string Status
        {
            get
            {
                return this.statusField;
            }
            set
            {
                this.statusField = value;
            }
        }

        /// <remarks/>
        public string TestComments
        {
            get
            {
                return this.testCommentsField;
            }
            set
            {
                this.testCommentsField = value;
            }
        }

        /// <remarks/>
        public System.DateTime StartTime
        {
            get
            {
                return this.startTimeField;
            }
            set
            {
                this.startTimeField = value;
            }
        }

        /// <remarks/>
        public System.DateTime EndTime
        {
            get
            {
                return this.endTimeField;
            }
            set
            {
                this.endTimeField = value;
            }
        }

        /// <remarks/>
        public byte SequenceNumber
        {
            get
            {
                return this.sequenceNumberField;
            }
            set
            {
                this.sequenceNumberField = value;
            }
        }

        /// <remarks/>
        public string Results
        {
            get
            {
                return this.resultsField;
            }
            set
            {
                this.resultsField = value;
            }
        }

        /// <remarks/>
        public string TestUnits
        {
            get
            {
                return this.testUnitsField;
            }
            set
            {
                this.testUnitsField = value;
            }
        }

        /// <remarks/>
        public string TestSequenceName
        {
            get
            {
                return this.testSequenceNameField;
            }
            set
            {
                this.testSequenceNameField = value;
            }
        }

        /// <remarks/>
        public string LineName
        {
            get
            {
                return this.lineNameField;
            }
            set
            {
                this.lineNameField = value;
            }
        }

        /// <remarks/>
        public string SerialNumber
        {
            get
            {
                return this.serialNumberField;
            }
            set
            {
                this.serialNumberField = value;
            }
        }

        /// <remarks/>
        public string CatalogNumber
        {
            get
            {
                return this.catalogNumberField;
            }
            set
            {
                this.catalogNumberField = value;
            }
        }

        /// <remarks/>
        public byte ResultType
        {
            get
            {
                return this.resultTypeField;
            }
            set
            {
                this.resultTypeField = value;
            }
        }

        /// <remarks/>
        public string WorkstationName
        {
            get
            {
                return this.workstationNameField;
            }
            set
            {
                this.workstationNameField = value;
            }
        }

        /// <remarks/>
        public string ParentWorkStation
        {
            get
            {
                return this.parentWorkStationField;
            }
            set
            {
                this.parentWorkStationField = value;
            }
        }

        /// <remarks/>
        public string ShiftName
        {
            get
            {
                return this.shiftNameField;
            }
            set
            {
                this.shiftNameField = value;
            }
        }

        /// <remarks/>
        public string OperatorName
        {
            get
            {
                return this.operatorNameField;
            }
            set
            {
                this.operatorNameField = value;
            }
        }

        /// <remarks/>
        public string Parameters
        {
            get
            {
                return this.parametersField;
            }
            set
            {
                this.parametersField = value;
            }
        }
    }


}
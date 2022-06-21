using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DHMapper
{
    public partial class resultFrm : Form
    {
        public resultFrm()
        {
            InitializeComponent();
        }

        private void copyBtn_Click(object sender, EventArgs e)
        {
            resultText.SelectAll();
            resultText.Copy();
        }

        private void cerrarBtn_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}

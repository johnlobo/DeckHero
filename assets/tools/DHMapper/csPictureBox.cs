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
    public partial class csPictureBox : PictureBox
    {
        public nodeClass node;

        public csPictureBox()
        {
            InitializeComponent();
            node = new nodeClass(0, 0, 0, 0, 0);
        }
        public csPictureBox(nodeClass n)
        {
            InitializeComponent();
            node = n;
            
        }

        protected override void OnPaint(PaintEventArgs pe)
        {
            base.OnPaint(pe);
        }

    }
}


    
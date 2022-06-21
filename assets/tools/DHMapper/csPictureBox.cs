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
        string tileType;
        int tileID;

        public csPictureBox()
        {
            InitializeComponent();
            TileType = "";
            TileID = 0;
        }

        public string TileType { get => tileType; set => tileType = value; }
        public int TileID { get => tileID; set => tileID = value; }

        protected override void OnPaint(PaintEventArgs pe)
        {
            base.OnPaint(pe);
        }

    }
}


    
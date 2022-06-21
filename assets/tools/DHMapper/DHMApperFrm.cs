namespace DHMapper
{
    public partial class DecHeroMapper : Form
    {
        private int map_x;
        private int map_y;
        private int block_x;
        private int block_y;
        private int[,] map;


        public DecHeroMapper()
        {
            InitializeComponent();

            Map_x = 0;
            Map_y = 13;
            Block_x = 0;
            Block_y = 0;
            this.map = new int[8, 14];
            for (int i = 0; i < 8; i++)
            {
                for (int j = 0; j < 14; j++)
                {
                    this.map[i, j] = 0;
                }
            }
        }

        public int Map_x
        {
            get => map_x;
            set
            {
                map_x = value;
                xyLbl.Text = Convert.ToString(map_x) + "," + Convert.ToString(map_y);
            }
        }
        public int Map_y
        {
            get => map_y;
            set
            {
                map_y = value;
            }
        }
        public int Block_x
        {
            get => block_x;
            set
            {
                block_x = value;
            }
        }
        public int Block_y
        {
            get => block_y;
            set
            {
                block_y = value;
            }
        }



        private void Form1_Load(object sender, EventArgs e)
        {
            csPictureBox[,] tiles = new csPictureBox[8, 14];
            for (int i = 0; i < 14; i++)
            {
                for (int j = 0; j < 8; j++)
                {
                    tiles[j, i] = new csPictureBox();
                    tiles[j, i].MouseClick += new MouseEventHandler(ClickOnTableLayoutPanel);
                    tiles[j, i].TileID = 0xf;
                    tiles[j, i].TileType = "Empty";
                    tiles[j, i].Padding = new Padding(0, 0, 0, 0);
                    tiles[j, i].Margin = new Padding(1, 1, 1, 1);
                    tableLayoutPanel1.Controls.Add(tiles[j, i], j, i);
                }
            }

            Size size24x24 = new Size(48, 48);

            int x = 0, y = 0, width = 12, height = 12;
            Bitmap nodesSource = new Bitmap(Properties.Resources.nodes);
            Bitmap pipesSource = new Bitmap(Properties.Resources.pipes);
            Image[] nodesImg = new Image[20];
            csPictureBox[] blocks = new csPictureBox[20];
            int index, px, py;

            for (index = 0; index < (nodesSource.Width / 12); index++)
            {
                nodesImg[index] = new Bitmap(nodesSource.Clone(new System.Drawing.Rectangle(x + (12 * index), y, width, height), nodesSource.PixelFormat), size24x24);
                blocks[index] = new csPictureBox();
                blocks[index].Image = nodesImg[index];
                blocks[index].MouseClick += new MouseEventHandler(ClickOnTableLayoutPanel2);
                blocks[index].TileID = index;
                blocks[index].TileType = "node";
                px = index % 6;
                py = index / 6;
                tableLayoutPanel2.Controls.Add(blocks[index], px, py);
            }

            int last = index;


            for (; (index - last) < (pipesSource.Width / 12); index++)
            {
                nodesImg[index] = new Bitmap(pipesSource.Clone(new System.Drawing.Rectangle(x + (12 * (index - last)), y, width, height), pipesSource.PixelFormat), size24x24);
                blocks[index] = new csPictureBox();
                blocks[index].Image = nodesImg[index];
                blocks[index].MouseClick += new MouseEventHandler(ClickOnTableLayoutPanel2);
                blocks[index].TileID = index;
                blocks[index].TileType = "pipe";
                px = index % 6;
                py = index / 6;
                tableLayoutPanel2.Controls.Add(blocks[index], px, py);
            }

            Control pb = tableLayoutPanel1.GetControlFromPosition(Map_x, Map_y);

        }

        private void addImageBtn_Click(object sender, EventArgs e)
        {
            csPictureBox p_origin = new csPictureBox();
            p_origin = (csPictureBox)tableLayoutPanel2.GetControlFromPosition(Block_x, Block_y);
            if (p_origin != null)
            {
                csPictureBox p_destiny = new csPictureBox();
                p_destiny = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(Map_x, Map_y);
                p_destiny.Image = p_origin.Image;
                p_destiny.TileID = p_origin.TileID;
                p_destiny.TileType = p_origin.TileType;
                if (Map_x < 7)
                    Map_x++;
                else
                {
                    Map_x = 0;
                    Map_y = (Map_y + 1) % 14;
                }

                tableLayoutPanel1.Refresh();
            }
        }

        private void tableLayoutPanel1_CellPaint(object sender, TableLayoutCellPaintEventArgs e)
        {
            if ((e.Column == this.Map_x) && (e.Row == this.Map_y))
            {
                e.Graphics.FillRectangle(Brushes.Red, e.CellBounds);
                csPictureBox cell = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(Map_x, Map_y);
                typeLbl.Text = cell.TileType;
                idLbl.Text = Convert.ToString(cell.TileID);
            }
            else
                e.Graphics.FillRectangle(Brushes.White, e.CellBounds);
        }

        public void ClickOnTableLayoutPanel(object sender, MouseEventArgs e)
        {
            Map_x = tableLayoutPanel1.GetColumn((Control)sender);
            Map_y = tableLayoutPanel1.GetRow((Control)sender);
            csPictureBox cell = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(Map_x, Map_y);
            typeLbl.Text = cell.TileType;
            idLbl.Text = Convert.ToString(cell.TileID);
            tableLayoutPanel1.Refresh();
        }

        public void ClickOnTableLayoutPanel2(object sender, MouseEventArgs e)
        {
            Block_x = tableLayoutPanel2.GetColumn((Control)sender);
            Block_y = tableLayoutPanel2.GetRow((Control)sender);
            tableLayoutPanel2.Refresh();

            csPictureBox p_origin = new csPictureBox();
            p_origin = (csPictureBox)tableLayoutPanel2.GetControlFromPosition(Block_x, Block_y);
            if (p_origin != null)
            {
                csPictureBox p_destiny = new csPictureBox();
                p_destiny = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(Map_x, Map_y);
                p_destiny.Image = p_origin.Image;
                p_destiny.TileID = p_origin.TileID;
                p_destiny.TileType = p_origin.TileType;
                if (Map_x < 7)
                    Map_x++;
                else
                {
                    Map_x = 0;
                    Map_y = (Map_y + 1) % 14;
                }

                tableLayoutPanel1.Refresh();
            }

        }

        private void tableLayoutPanel2_CellPaint(object sender, TableLayoutCellPaintEventArgs e)
        {
            if ((e.Column == this.Block_x) && (e.Row == this.Block_y))
                e.Graphics.FillRectangle(Brushes.Blue, e.CellBounds);
            else
                e.Graphics.FillRectangle(Brushes.White, e.CellBounds);
        }


        private void deleteImageBtn_Click(object sender, EventArgs e)
        {
            csPictureBox p_destiny = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(Map_x, Map_y);
            p_destiny.Image = null;
            p_destiny.TileID = 0xf;
            p_destiny.TileType = "empty";
        }

        private void button1_Click(object sender, EventArgs e)
        {
            resultFrm result = new resultFrm();
            RichTextBox text = (RichTextBox)result.Controls["resultText"];
            text.AppendText(";;\n");
            text.AppendText(";;Node map\n");
            text.AppendText(";;\n");
            for (int j = 13; j >= 0; j = j - 1)
            {
                text.AppendText(".db ");
                for (int i = 0; i < 8; i = i + 2)
                {
                    csPictureBox cell1 = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(i, j);
                    csPictureBox cell2 = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(i + 1, j);
                    int byteResult = (cell1.TileID << 4) | (cell2.TileID & 15);
                    text.AppendText("#0b" + Convert.ToString(byteResult, 2).PadLeft(8, '0'));
                    if (i < 7)
                        text.AppendText(", ");
                }
                text.AppendText("\n");

            }
            result.ShowDialog();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (Map_x < 7)
                Map_x++;
            else
            {
                Map_x = 0;
                Map_y = (Map_y + 1) % 14;
            }
            tableLayoutPanel1.Refresh();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (Map_x > 0)
                Map_x--;
            else
            {
                Map_x = 7;
                Map_y = (Map_y - 1) % 14;
            }
            tableLayoutPanel1.Refresh();

        }

        private void btnGuardar_Click(object sender, EventArgs e)
        {
            SaveFileDialog saveFile = new SaveFileDialog();
            saveFile.Filter = "Documento de Texto|*.txt";
            saveFile.Title = "Guardar Mapa";
            saveFile.FileName = "Map WIP";
            var result = saveFile.ShowDialog();
            if (result == DialogResult.OK)
            {
                StreamWriter outputFile = new StreamWriter(saveFile.FileName);
                for (int j = 13; j >= 0; j = j - 1)
                {
                    for (int i = 0; i < 8; i = i + 1)
                    {
                        csPictureBox cell = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(i, j);
                        outputFile.WriteLine(cell.TileID.ToString());
                    }

                }
                outputFile.Close();

            }

        }

        private void button6_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            OpenFileDialog loadFile = new OpenFileDialog();
            loadFile.Filter = "Documento de Texto|*.txt";
            loadFile.Title = "Cargar Mapa";
            loadFile.FileName = "Map WIP";
            var result = loadFile.ShowDialog();
            if (result == DialogResult.OK)
            {
                StreamReader inputFile = new StreamReader(loadFile.FileName);
                for (int j = 13; j >= 0; j = j - 1)
                {
                    for (int i = 0; i < 8; i = i + 1)
                    {
                        csPictureBox cell = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(i, j);
                        string inputCell = inputFile.ReadLine();
                        cell.TileID = Convert.ToInt32(inputCell);
                        foreach (csPictureBox cc in tableLayoutPanel2.Controls)
                        {
                            if (cc.TileID == cell.TileID)
                            {
                                cell.Image = cc.Image;
                                break;
                            }
                        }
                    }

                }
                inputFile.Close();
                tableLayoutPanel1.Refresh();

            }
        }

        private void btnBorrarMapa_Click(object sender, EventArgs e)
        {
            DialogResult dialogResult = MessageBox.Show("Quieres borrar el mapa ??", "Borrar mapa", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {

                for (int i = 0; i < 14; i++)
                {
                    for (int j = 0; j < 8; j++)
                    {
                        csPictureBox cell = (csPictureBox)tableLayoutPanel1.GetControlFromPosition(j, i);
                        cell.TileID = 0xf;
                        cell.TileType = "empty";
                        cell.Image = null;
                    }
                }
                tableLayoutPanel1.Refresh();
            }
        }
    }
}

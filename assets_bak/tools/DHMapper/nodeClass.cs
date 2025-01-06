using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DHMapper
{
    public class nodeClass
    {
        private int id;
        private int type;
        private int x, y;
        private int ancestors;

        public int Id { get => id; set => id = value; }
        public int Type { get => type; set => type = value; }
        public int X { get => x; set => x = value; }
        public int Y { get => y; set => y = value; }
        public int Ancestors { get => ancestors; set => ancestors = value; }

        public nodeClass(int id, int type, int x, int y, int anc)
        {
            this.id = id;
            this.type = type;
            this.x = x;
            this.y = y;
            ancestors = anc;   
        }

    }
}

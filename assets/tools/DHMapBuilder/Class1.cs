using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DHMapBuilder
{
    internal class nodeClass
    {

        private int id;
        private string type;
        private int x, y;
        private int ancestors;
        private int descendants;

        public int Id { get => id; set => id = value; }
        public string Type { get => type; set => type = value; }
        public int X { get => x; set => x = value; }
        public int Y { get => y; set => y = value; }
        public int Ancestors { get => ancestors; set => ancestors = value; }
        public int Descendants { get => descendants; set => descendants = value; }

    }
}

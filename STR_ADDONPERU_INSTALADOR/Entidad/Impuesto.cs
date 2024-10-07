using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace STR_ADDONPERU_INSTALADOR.Entidad
{
    public class Impuesto
    {
        public string WTCode { get; set; }
        public string Inactive { get; set; }
        public string WTName { get; set; }
        public string Type { get; set; }
        public string Category { get; set; }
        public string EffecDate { get; set; }
        public double Rate { get; set; }
        public string BaseType { get; set; }
        public double PrctBsAmnt { get; set; }
        public string OffclCode { get; set; }
        public string Account { get; set; }
        public string U_RetImp { get; set; }
    }
}
